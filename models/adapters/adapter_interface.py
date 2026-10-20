#!/usr/bin/env python3
"""
Unified model-calling interface for the AI Company skill package (large tier).

Design constraints (verified by tests/test-method-patterns.py):
  * Compiles under Python 3.9+ with the standard library only.
  * Reads credentials from environment variables BY NAME - never a literal key.
  * Does NOT perform real network I/O in this reference implementation; the transport
    is a seam (`_transport`) so the module is importable and unit-testable offline.
  * Maps every failure onto an MDL_ error code (see references/error-codes.md).
  * Enforces the fallback chain: one broken config_path must not silently pass.

Error codes (references/error-codes.md):
    MDL_001 model not found in registry
    MDL_002 model config file missing
    MDL_003 model disabled
    MDL_004 API key missing
    MDL_005 rate limit exceeded
    MDL_006 model config invalid
    MDL_E007 model invocation failed
"""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional

# models/ is the parent of this file's directory (models/adapters/adapter_interface.py)
MODELS_DIR = Path(__file__).resolve().parent.parent
CONFIG_DIR = MODELS_DIR / "config"
REGISTRY_PATH = CONFIG_DIR / "models-registry.json"
POLICY_PATH = CONFIG_DIR / "calling-policy.json"

# Required fields a model config must carry (mirrors models/api/template/config.json).
REQUIRED_CONFIG_FIELDS = (
    "id", "provider", "type", "endpoint",
    "context_window", "max_output_tokens", "pii_filtering", "rate_limits",
)


class ModelError(Exception):
    """An error carrying an MDL_ code and a human-readable message."""

    def __init__(self, code: str, message: str):
        super().__init__("%s: %s" % (code, message))
        self.code = code
        self.message = message


def load_registry() -> Dict[str, Any]:
    """Load and structurally validate the model registry."""
    if not REGISTRY_PATH.is_file():
        raise ModelError("MDL_002", "model registry missing at %s" % REGISTRY_PATH)
    try:
        with open(REGISTRY_PATH, "r", encoding="utf-8") as fh:
            registry = json.load(fh)
    except (ValueError, OSError) as exc:
        raise ModelError("MDL_006", "registry unparseable: %s" % exc) from exc
    if "models" not in registry or not isinstance(registry["models"], list):
        raise ModelError("MDL_006", "registry has no 'models' list")
    return registry


def load_policy() -> Dict[str, Any]:
    """Load the calling policy; tolerate absence with a permissive default."""
    if not POLICY_PATH.is_file():
        return {"rate_limits": {"default": {"rpm": 60, "tpm": 90000, "daily": 5000}}}
    try:
        with open(POLICY_PATH, "r", encoding="utf-8") as fh:
            return json.load(fh)
    except (ValueError, OSError) as exc:
        raise ModelError("MDL_006", "policy unparseable: %s" % exc) from exc


def _reject_traversal(config_path: str) -> None:
    """Refuse a config_path that attempts to escape models/ (schema-security §7)."""
    normalized = config_path.replace("\\", "/")
    if normalized.startswith("/") or ".." in normalized.split("/"):
        raise ModelError("MDL_002", "config_path traversal rejected: %s" % config_path)


def resolve_model(registry: Dict[str, Any], model_id: str) -> Dict[str, Any]:
    """Return the registry entry for model_id, or raise MDL_001."""
    for entry in registry["models"]:
        if entry.get("id") == model_id:
            return entry
    raise ModelError("MDL_001", "model not found in registry: %s" % model_id)


def load_model_config(entry: Dict[str, Any]) -> Dict[str, Any]:
    """Resolve and validate a model's config file.

    Raises MDL_002 if the file is missing, MDL_003 if disabled, MDL_006 if invalid.
    """
    if not entry.get("enabled", True):
        raise ModelError("MDL_003", "model disabled: %s" % entry.get("id"))

    config_path = entry.get("config_path")
    if not config_path:
        raise ModelError("MDL_006", "registry entry has no config_path: %s" % entry.get("id"))
    _reject_traversal(config_path)

    full_path = MODELS_DIR / config_path
    if not full_path.is_file():
        # This is the exact failure a predecessor package shipped: a registry entry
        # pointing at a nonexistent file, breaking the whole fallback chain.
        raise ModelError("MDL_002", "model config file missing: %s" % config_path)

    try:
        with open(full_path, "r", encoding="utf-8") as fh:
            config = json.load(fh)
    except (ValueError, OSError) as exc:
        raise ModelError("MDL_006", "config unparseable for %s: %s" % (entry.get("id"), exc)) from exc

    missing = [f for f in REQUIRED_CONFIG_FIELDS if f not in config]
    if missing:
        raise ModelError("MDL_006",
                         "config for %s missing fields: %s" % (entry.get("id"), ", ".join(missing)))
    return config


def resolve_api_key(config: Dict[str, Any]) -> Optional[str]:
    """Read the credential from the environment BY NAME.

    Local engines (ollama, llama.cpp) perform no authentication; their configs leave
    env_var_name empty and receive the conventional local placeholder instead. A value
    is never read from the config file itself.
    """
    env_var = config.get("env_var_name") or ""
    if not env_var:
        # Local, unauthenticated engine.
        return "ollama" if config.get("provider") == "ollama" else None
    key = os.getenv(env_var)
    if not key:
        # Report the variable NAME only - never a value, and never guess one.
        raise ModelError("MDL_004",
                         "API key missing: environment variable %s is not set" % env_var)
    return key


def _apply_rate_limit(policy: Dict[str, Any], model_id: str,
                      limiter: Optional[Callable[..., Any]] = None) -> None:
    """Apply the configured rate limit through an injected limiter (a seam).

    This is deliberately NOT named after template 8: the shared
    `check_rate_limit` implementation lives only in
    references/method-patterns.md (P10/P44 single authoritative source). A
    deployment injects that template (or any compatible limiter) here, which
    also keeps this module importable and testable without the templates file.
    When no limiter is injected, rate limiting is skipped and the caller is
    responsible for enforcing it.
    """
    if limiter is None:
        return
    limits = policy.get("rate_limits", {})
    effective = limits.get("per_model_overrides", {}).get(model_id) or limits.get("default", {})
    rpm = int(effective.get("rpm", 60))
    allowed, retry_after = limiter("model:%s" % model_id, rpm, 60)
    if not allowed:
        raise ModelError("MDL_005",
                         "rate limit exceeded for %s; retry after %ss" % (model_id, retry_after))


def _default_transport(config: Dict[str, Any], payload: Dict[str, Any],
                       api_key: Optional[str]) -> Dict[str, Any]:
    """Reference transport seam.

    The shipped implementation does NOT perform network I/O - it echoes a structured
    stub so the module is importable, testable and safe offline. A deployment wires a
    real transport here. Keeping this a seam is deliberate: the surrounding validation,
    key resolution and rate limiting are the parts under test, not the HTTP call.
    """
    return {
        "model": config.get("id"),
        "provider": config.get("provider"),
        "endpoint": config.get("endpoint"),
        "stub": True,
        "note": "reference transport - no network call performed",
        "authenticated": api_key is not None,
        "echo": payload,
    }


def call_model(model_id: str, messages: List[Dict[str, str]],
               registry: Optional[Dict[str, Any]] = None,
               policy: Optional[Dict[str, Any]] = None,
               transport: Optional[Callable[..., Any]] = None,
               limiter: Optional[Callable[..., Any]] = None) -> Dict[str, Any]:
    """Invoke a model end to end: resolve -> validate -> authenticate -> limit -> call.

    Every failure surfaces as a ModelError carrying its MDL_ code. The caller decides
    whether to walk the fallback chain (see call_with_fallback).
    """
    registry = registry if registry is not None else load_registry()
    policy = policy if policy is not None else load_policy()
    transport = transport or _default_transport

    entry = resolve_model(registry, model_id)
    config = load_model_config(entry)
    api_key = resolve_api_key(config)
    _apply_rate_limit(policy, model_id, limiter=limiter)

    payload = {"model": model_id, "messages": messages}
    try:
        return transport(config, payload, api_key)
    except ModelError:
        raise
    except Exception as exc:  # transport-level failure
        raise ModelError("MDL_E007", "invocation failed for %s: %s" % (model_id, exc)) from exc


def call_with_fallback(messages: List[Dict[str, str]],
                       registry: Optional[Dict[str, Any]] = None,
                       policy: Optional[Dict[str, Any]] = None,
                       transport: Optional[Callable[..., Any]] = None,
                       limiter: Optional[Callable[..., Any]] = None) -> Dict[str, Any]:
    """Walk the configured fallback chain until one model succeeds.

    A model that fails to CONFIGURE (MDL_002 missing file, MDL_006 invalid) is a
    registry defect, not a transient outage - it aborts the chain immediately, because
    continuing would mask a broken registry. Transient failures (MDL_005, MDL_E007)
    advance to the next model.
    """
    registry = registry if registry is not None else load_registry()
    policy = policy if policy is not None else load_policy()

    chain = registry.get("fallback_chain") or [m["id"] for m in registry["models"]]
    errors: List[str] = []

    for model_id in chain:
        try:
            return call_model(model_id, messages, registry=registry, policy=policy,
                              transport=transport, limiter=limiter)
        except ModelError as exc:
            errors.append("%s -> %s" % (model_id, exc.code))
            if exc.code in ("MDL_002", "MDL_006"):
                # Registry/config defect: stop, do not paper over it with a fallback.
                raise ModelError(exc.code,
                                 "fallback aborted on registry defect (%s): %s"
                                 % (exc.code, "; ".join(errors)))

    raise ModelError("MDL_E007", "fallback chain exhausted: %s" % "; ".join(errors))


def validate_registry_paths(registry: Optional[Dict[str, Any]] = None) -> Dict[str, bool]:
    """Check that every config_path resolves. Used by tests and by pre-flight checks.

    Returns a mapping of config_path -> exists. A single False means the fallback chain
    is broken and must be fixed before any invocation.
    """
    registry = registry if registry is not None else load_registry()
    result: Dict[str, bool] = {}
    for entry in registry["models"]:
        cp = entry.get("config_path", "")
        result[cp] = bool(cp) and (MODELS_DIR / cp.replace("\\", "/")).is_file()
    return result


if __name__ == "__main__":
    # Offline self-check.
    #   1. Validate the registry: every config_path must resolve. This is the real
    #      assertion - a broken path silently kills the whole fallback chain.
    #   2. Demonstrate the call path against a no-auth LOCAL model, so the check runs
    #      offline. API models (gpt-4o, claude) require their env var at runtime and
    #      are intentionally NOT called here.
    reg = load_registry()
    paths = validate_registry_paths(reg)
    broken = [p for p, ok in paths.items() if not ok]
    print("registry models : %d" % len(reg["models"]))
    print("config paths ok : %d/%d" % (len(paths) - len(broken), len(paths)))
    if broken:
        print("BROKEN PATHS    : %s" % ", ".join(broken))
        raise SystemExit(1)

    # Pick a local model that needs no credential for the offline demo call.
    local_id = None
    for entry in reg["models"]:
        try:
            cfg = load_model_config(entry)
        except ModelError:
            continue
        if cfg.get("type") == "local" and not (cfg.get("env_var_name") or ""):
            local_id = entry["id"]
            break
    if local_id is None:
        print("no credential-free local model to demo; registry validation still passed")
    else:
        demo = call_model(local_id, [{"role": "user", "content": "ping"}])
        print("offline demo call (%s, stub): %s"
              % (local_id, json.dumps(demo, ensure_ascii=False)[:120]))
    print("OK")

