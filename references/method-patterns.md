# Method Patterns — Shared Code Templates & Prompt Frameworks

> This file is the **single authoritative source** for all 10 shared code templates
> and the 3 prompt frameworks in this skill package. Every implementation lives
> here — there is no second copy anywhere in the package. Any file that needs a
> template **links to the anchors in this file**; inline code copies are forbidden
> (P10 / P44).
>
> Department-level `references/method-patterns.md` files hold **department-specific**
> patterns only and must never duplicate these ten shared templates.
>
> Authority: this package's `README_FOR_AI.md` — §7 (templates & frameworks), §8 (Harness), §9.2–9.4 (compliance), §6.3 (source-language standard).

---

## 1. Template Index

Selection table only. Read this section to choose a template; descend into
Section 3 only when you need the implementation. **This file is the single
authoritative source of the 10 template implementations** — no other file in
this package holds template code.

| # | Function | Purpose | Safety Property | Harness | Anchor |
|---|----------|---------|-----------------|---------|--------|
| 1 | `validate_input_schema(data, schema)` | Validate input against a schema before any LLM call | No external I/O; pure validation | L2 | [3.1](#31-validate_input_schema) |
| 2 | `sanitize_user_query(query)` | Sanitize raw user input before prompt or command use | No dynamic code execution; injection-neutralizing | L3 | [3.2](#32-sanitize_user_query) |
| 3 | `execute_safe_command(cmd, timeout=30)` | Sandboxed subprocess execution | Hard timeout + restricted cwd; shell disabled | L4 | [3.3](#33-execute_safe_command) |
| 4 | `format_output_json(content, provider)` | Standard JSON output envelope with AIGC labeling | Embedded AI watermark + metadata + timestamp | L5 | [3.4](#34-format_output_json) |
| 5 | `retry_with_backoff(func, max_retries=3)` | Exponential-backoff retry wrapper | Fault tolerance; never swallows the final error | L3 | [3.5](#35-retry_with_backoff) |
| 6 | `read_reference_file(filepath)` | Safely read a reference file | Path validation; out-of-bounds paths rejected | L3 | [3.6](#36-read_reference_file) |
| 7 | `generate_trace_id(prefix="trace")` | Generate audit trace identifiers | Stateless; no I/O; thread-safe | L5 | [3.7](#37-generate_trace_id) |
| 8 | `check_rate_limit(identifier, limit=10, window=60)` | Sliding-window rate limiting | In-memory only; never persisted to disk | L4 | [3.8](#38-check_rate_limit) |
| 9 | `mask_sensitive_data(text)` | PII masking (EMAIL / IP / PHONE) | Raw data never logged or persisted | L5 | [3.9](#39-mask_sensitive_data) |
| 10 | `build_prompt_from_template(template, **kwargs)` | Render prompt framework templates | All inputs sanitized before insertion | L3 | [3.10](#310-build_prompt_from_template) |

**Signature contract** — parameter names and default values are fixed; the test
suite asserts them. A renamed function breaks every referencing file and
requires a package-wide grep.

**Mandatory usage points**

| Pipeline stage | Template | Required at |
|---|---|---|
| Every department entry | 1 `validate_input_schema` | D2 §3 responsibilities |
| Before any interpolation | 2 via 10 | Prompt construction |
| Any subprocess | 3 | `execute_safe_command` only — never a raw shell call |
| Every emitted payload | 4 `format_output_json` | AIGC triple labeling |
| Any retryable external call | 5 | Integrations, model invocation |
| Any file read | 6 | Reference loading |
| Every operation | 7 | Audit trail, prefix per department |
| Every external call | 8 | Rate limiting per identifier |
| **Every output** | 9 `mask_sensitive_data` | **Non-negotiable** |

**Runtime requirement:** Python 3.9+, standard library only — no third-party
dependency for the 10 core templates. Harness mapping (README_FOR_AI.md §8.1):
every LLM call point must have validation in front, sanitization behind, tracing
throughout, and a fallback on failure.

---

## 2. Prompt Framework Index

| Framework | Fields | Best For | Anchor |
|-----------|--------|----------|--------|
| CRISPE | 6 | Complex, multi-step tasks needing explicit constraints and examples | [4.1](#41-crispe) |
| 3WEH | 4 | Clear delegation: unambiguous role, task, purpose, format | [4.2](#42-3weh) |
| Five-Element | 5 | Enterprise-compliant prompts with explicit context and constraints | [4.3](#43-five-element) |

| Situation | Framework |
|---|---|
| Multi-step analysis, needs an example | CRISPE |
| Hand-off to a known role, minimal context needed | 3WEH |
| Output subject to compliance, audit or legal review | Five-Element |
| Uncertain | Five-Element — its explicit `Constraint` slot degrades most safely |

Rules (README_FOR_AI.md §7.2): the **full field-by-field expansion lives only in
Section 4 of this file**. `SKILL.md` may only name a framework and link here; it
must never inline the field expansion. All three skeletons are rendered with
`build_prompt_from_template` (3.10), which sanitizes every interpolated value —
never interpolate user text into a prompt by string concatenation.

---

## 3. Shared Code Templates

The ten templates below are the physical implementation of the harness
(README_FOR_AI.md §8.1). Order matches the index table and must not be rearranged.
All templates share this module preamble:

```python
"""Shared harness templates — single source of truth for this skill package.

All paths are resolved from environment variables or the current working
directory. Never hardcode absolute paths in sources; always use the
{SKILL_DIR} and {WORKSPACE_ROOT} placeholders instead.
"""

import hashlib
import json
import os
import random
import re
import shlex
import subprocess
import time
import uuid
from collections import defaultdict, deque
from datetime import datetime, timezone
from threading import Lock

# --- Sandboxing roots (configure via environment; placeholders in docs) ---
# {SKILL_DIR}       -> root of this skill package (read-only for the skill)
# {WORKSPACE_ROOT}  -> the user's writable workspace directory (the only writable area)
SKILL_ROOT = os.environ.get("SKILL_DIR", ".")
WORKSPACE_ROOT = os.environ.get("WORKSPACE_ROOT", ".")

# Fail-closed flag (template 6). When {SKILL_DIR} is unset, os.environ.get
# falls back to "." — which silently promotes the process working directory
# into a readable root. read_reference_file refuses to honour that fallback.
SKILL_ROOT_CONFIGURED = bool(os.environ.get("SKILL_DIR"))

# --- Reference-file policy (template 6) ---
MAX_REFERENCE_FILE_BYTES = 1 * 1024 * 1024  # 1 MiB read cap
ALLOWED_REFERENCE_EXTENSIONS = {".md", ".txt", ".json", ".yaml", ".yml"}

# --- Query sanitization policy (template 2) ---
MAX_QUERY_LENGTH = 2000
```

### 3.1 validate_input_schema

```python
def validate_input_schema(data, schema):
    """Validate ``data`` against ``schema`` before any LLM call (Harness L2).

    ``schema`` maps each field name to a spec dict::

        schema = {
            "task": {"type": str, "required": True},
            "priority": {"type": int, "required": False},
        }

    Pure validation only: no external I/O, no dynamic code execution, no
    network access. Raises ``ValueError`` with a field-level message on the
    first violation; returns True when the data conforms.
    """
    if not isinstance(data, dict):
        raise ValueError("input data must be a dict")
    if not isinstance(schema, dict):
        raise ValueError("schema must be a dict")

    for field, spec in schema.items():
        if not isinstance(spec, dict):
            raise ValueError(f"schema spec for '{field}' must be a dict")
        value = data.get(field)
        if value is None:
            if spec.get("required", True):
                raise ValueError(f"missing required field: {field}")
            continue
        expected = spec.get("type")
        if expected is None:
            continue
        # bool is a subclass of int in Python; reject the implicit coercion
        if isinstance(value, bool) and expected in (int, float):
            raise ValueError(
                f"field '{field}' expected {expected.__name__}, got bool"
            )
        if not isinstance(value, expected):
            raise ValueError(
                f"field '{field}' expected {expected.__name__}, "
                f"got {type(value).__name__}"
            )
    return True
```

### 3.2 sanitize_user_query

```python
_CONTROL_CHARS = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]")
_ZERO_WIDTH = re.compile(r"[\u200b-\u200f\u2028\u2029\u2060\ufeff]")
_INJECTION_PATTERNS = (
    re.compile(r"ignore\s+(all\s+)?previous\s+instructions", re.IGNORECASE),
    re.compile(r"disregard\s+(all\s+)?(prior|previous)\s+(instructions|prompts)", re.IGNORECASE),
    re.compile(r"reveal\s+(your\s+)?(system\s+)?prompt", re.IGNORECASE),
    re.compile(r"<\|[^|]*\|>"),
)
# Backslash and newline must be stripped too: "\\" is shlex's escape character
# (a trailing one silently swallows the next delimiter) and a newline lets one
# logical input become two lines in a downstream prompt or script.
_SHELL_METACHARS = re.compile(r"[`$;&|><\"'\\\n\r]")

def sanitize_user_query(query):
    """Sanitize raw user input before it reaches a prompt or a command (Harness L3).

    - Strips control characters and zero-width/invisible characters.
    - Neutralizes common prompt-injection phrases by replacing them with a
      fixed marker (no dynamic code execution; this function never calls
      eval/exec).
    - Removes shell metacharacters — including backslash, CR and LF — so
      downstream command builders cannot be hijacked by user-supplied text.
    - Truncates to MAX_QUERY_LENGTH characters.

    Returns the sanitized string. Raises TypeError on non-string input.
    """
    if not isinstance(query, str):
        raise TypeError("query must be a string")
    cleaned = _CONTROL_CHARS.sub("", query)
    cleaned = _ZERO_WIDTH.sub("", cleaned)
    for pattern in _INJECTION_PATTERNS:
        cleaned = pattern.sub("[FILTERED]", cleaned)
    cleaned = _SHELL_METACHARS.sub("", cleaned)
    return cleaned[:MAX_QUERY_LENGTH]
```

### 3.3 execute_safe_command

```python
_BLOCKED_EXECUTABLES = frozenset({
    "rm", "del", "rmdir", "rd", "format", "mkfs", "shutdown", "reboot",
    "sudo", "su", "chmod", "chown", "reg", "regedit", "cmd", "powershell",
    "pwsh", "iex", "curl", "wget",
})
_MAX_TIMEOUT_SECONDS = 120

# --- Credential-name policy (template 3: child-environment scrubbing) ---
# A variable counts as secret-like when any delimiter-separated token of its
# name is a known credential word, or ends with one.
#
# Prefix-only matching ("api_", "token", "secret", "password", "key_") is NOT
# sufficient and must not be reinstated: real-world credential names mostly do
# not start with those prefixes. A prefix filter leaks AWS_SECRET_ACCESS_KEY,
# AWS_ACCESS_KEY_ID, GITHUB_TOKEN, GH_TOKEN, OPENAI_APIKEY,
# ANTHROPIC_AUTH_TOKEN, PRIVATE_KEY, SESSION_ID, PASSWD, NPM_TOKEN, HF_TOKEN
# — every one of them verified by probe.
_SECRET_NAME_TOKENS = frozenset({
    "KEY", "TOKEN", "SECRET", "CREDENTIAL", "CREDENTIALS", "PASSWORD",
    "PASSWD", "PWD", "AUTH", "SESSION", "COOKIE", "PRIVATE", "SIGNATURE",
    "PASSPHRASE", "APIKEY",
})
_SECRET_NAME_SUFFIXES = (
    "KEY", "TOKEN", "SECRET", "PASSWORD", "PASSWD", "CREDENTIAL", "AUTH",
    "SESSION",
)
_KNOWN_SECRET_NAMES = frozenset({
    "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN",
    "GITHUB_TOKEN", "GH_TOKEN", "OPENAI_API_KEY", "OPENAI_APIKEY",
    "ANTHROPIC_API_KEY", "ANTHROPIC_AUTH_TOKEN", "HF_TOKEN", "NPM_TOKEN",
    "AZURE_CLIENT_SECRET", "GOOGLE_API_KEY", "SLACK_BOT_TOKEN",
    "DATABASE_URL", "CONNECTION_STRING",
    # R2 review: these two name credential FILES and carry no KEY/TOKEN/
    # SECRET/SESSION fragment, so they must be listed explicitly.
    "NETRC", "KUBECONFIG",
})

def _is_secret_env_name(name):
    """Return True when an environment variable name looks credential-bearing.

    Deliberately over-inclusive: scrubbing a harmless variable costs the child
    process one lookup, while leaking a credential costs the operator
    everything. The matching rule is name-fragment based (not prefix based) so
    that vendor-prefixed names such as ``AWS_SECRET_ACCESS_KEY`` are covered.
    """
    upper = str(name).upper()
    if upper in _KNOWN_SECRET_NAMES:
        return True
    for token in re.split(r"[^A-Za-z0-9]+", upper):
        if not token:
            continue
        if token in _SECRET_NAME_TOKENS or token.endswith(_SECRET_NAME_SUFFIXES):
            return True
    return False

def _scrubbed_environment():
    """Return an environment copy with secret-like variables removed.

    Implements the zero-hardcoded-secrets baseline (README_FOR_AI.md §9.4): credentials
    never travel into a subprocess environment implicitly. Matching is by name
    fragment plus a known-name list (see ``_is_secret_env_name``); prefix-only
    matching is a verified leak and must not be reintroduced.
    """
    return {
        name: value
        for name, value in os.environ.items()
        if not _is_secret_env_name(name)
    }

def execute_safe_command(cmd, timeout=30):
    """Run a command in a sandbox with a hard timeout (Harness L4).

    Security contract:
    - The subprocess runs with ``shell=False`` (no shell interpolation of
      user-controlled text) and a restricted cwd: {WORKSPACE_ROOT} only.
    - Dangerous executables (deletion, shell hosts, downloaders, privilege
      escalation) are rejected before launch. **This is a best-effort first
      line of defence, not a sandbox boundary** (README_FOR_AI.md §9.4): the
      blocklist matches the invoked program name only, so a deletion can still
      be performed by any allowed interpreter (``python -c "os.remove(...)"``,
      ``git clean -fd``, ``find . -delete``). Treat the host permission set,
      not this function, as the real boundary.
    - ``timeout`` is clamped to (0, 120] seconds; a hung process is killed
      and surfaced as TimeoutError.
    - The child environment is scrubbed of secret-like variables.

    Output decoding is explicit (``encoding="utf-8", errors="replace"``).
    Without ``errors="replace"`` a non-UTF-8 byte (GBK output on Chinese
    Windows) raises inside subprocess' reader thread, which the caller never
    sees: the command reports ``returncode 0`` with ``stdout=None`` and the
    output is lost silently.

    ``cmd`` may be a string (parsed with shlex, never via a shell) or an
    argument list. Returns a dict with returncode, stdout, stderr.
    """
    if isinstance(cmd, str):
        parts = shlex.split(cmd)
    elif isinstance(cmd, (list, tuple)):
        parts = [str(part) for part in cmd]
    else:
        raise TypeError("cmd must be a string or a list of arguments")
    if not parts:
        raise ValueError("empty command")
    if not isinstance(timeout, (int, float)) or not 0 < timeout <= _MAX_TIMEOUT_SECONDS:
        raise ValueError(f"timeout must be in (0, {_MAX_TIMEOUT_SECONDS}] seconds")

    executable = os.path.basename(parts[0]).lower()
    if executable.endswith(".exe"):
        executable = executable[:-4]
    if executable in _BLOCKED_EXECUTABLES:
        raise PermissionError(f"blocked executable: {executable}")

    try:
        completed = subprocess.run(
            parts,
            cwd=WORKSPACE_ROOT,          # restricted cwd ({WORKSPACE_ROOT})
            timeout=timeout,             # hard timeout: hung processes die
            capture_output=True,
            text=True,
            encoding="utf-8",            # explicit decoding: never locale-dependent
            errors="replace",            # non-UTF-8 bytes degrade, never drop stdout
            shell=False,                 # never allow shell interpolation
            env=_scrubbed_environment(),
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        raise TimeoutError(f"command exceeded {timeout}s timeout: {executable}") from exc
    except FileNotFoundError as exc:
        raise ValueError(f"executable not found: {parts[0]}") from exc

    return {
        "returncode": completed.returncode,
        "stdout": completed.stdout,
        "stderr": completed.stderr,
    }
```

### 3.4 format_output_json

```python
AIGC_DISCLOSURE = "AI-Generated Content"

def format_output_json(content, provider):
    """Wrap content in the standard JSON envelope with AIGC labeling (Harness L5).

    Implements the triple-labeling requirement (README_FOR_AI.md §9.2); omitting any
    layer makes the output non-compliant:
    - Layer 1, explicit label: a visible disclosure line is appended to the
      content body.
    - Layer 2, implicit metadata: ``ai_generated``, ``generated_at``
      (ISO-8601 UTC), and ``model`` ("<provider/model>") fields.
    - Layer 3, embedded watermark: a SHA-256 marker is embedded inside the
      content body, bound to provider, generation timestamp **and a digest of
      the content itself**.

    Honest strength statement for layer 3 (do not overclaim, P24): the marker
    is a tamper-evident *disclosure*, not a cryptographic watermark. It makes
    an edit detectable — changing the body invalidates the digest the marker
    was derived from — but a determined party can still delete the trailing
    disclosure line in one operation and redistribute a clean-looking body.
    If a non-strippable mark is required, use an external signing mechanism;
    this envelope does not provide one.

    ``content`` must already have passed through mask_sensitive_data (3.9).
    Returns a JSON string (UTF-8 safe, indent=2).
    """
    if not isinstance(content, str):
        raise TypeError("content must be a string")
    if not isinstance(provider, str) or not provider.strip():
        raise ValueError("provider must be a non-empty string")

    generated_at = datetime.now(timezone.utc).isoformat()
    # Bind the marker to the content: editing the body invalidates the digest.
    content_digest = hashlib.sha256(content.encode("utf-8")).hexdigest()[:16]
    watermark = hashlib.sha256(
        f"{provider}:{generated_at}:{content_digest}:{AIGC_DISCLOSURE}".encode("utf-8")
    ).hexdigest()[:16]

    watermarked_content = (
        f"{content}\n\n"
        f"> Warning: {AIGC_DISCLOSURE} [aigc:{watermark}]"
    )
    # "<provider/model>": a provider already carrying "/model" must not gain a
    # second "/default" segment (defect L-4).
    provider_name, separator, model_name = provider.strip().partition("/")
    if separator and model_name:
        model = f"{provider_name}/{model_name}"
    else:
        model = f"{provider_name}/default"
    payload = {
        "content": watermarked_content,
        "ai_generated": True,
        "generated_at": generated_at,
        "model": model,
    }
    return json.dumps(payload, ensure_ascii=False, indent=2)
```

### 3.5 retry_with_backoff

```python
def retry_with_backoff(func, max_retries=3):
    """Execute ``func`` with exponential backoff on failure (Harness L3).

    Calls ``func()`` up to ``max_retries + 1`` times total. The delay before
    retry N (0-based) is ``0.5 * 2**N`` seconds with +/-25% jitter to avoid
    thundering-herd synchronization.

    Fault-tolerance contract: the final exception is re-raised unchanged —
    this wrapper never silently swallows errors. Callers whose operations are
    non-idempotent must not retry (README_FOR_AI.md §8.3).

    Returns whatever ``func`` returns on success.
    """
    if not callable(func):
        raise TypeError("func must be callable")
    if not isinstance(max_retries, int) or max_retries < 0:
        raise ValueError("max_retries must be a non-negative integer")

    last_error = None
    for attempt in range(max_retries + 1):
        try:
            return func()
        except Exception as exc:  # noqa: BLE001 - deliberate broad retry
            last_error = exc
            if attempt == max_retries:
                break
            delay = 0.5 * (2 ** attempt)
            time.sleep(delay * (0.75 + random.random() * 0.5))
    raise last_error
```

### 3.6 read_reference_file

```python
def read_reference_file(filepath):
    """Read a reference file after strict path validation (Harness L3).

    Security contract:
    - The requested path is resolved against {SKILL_DIR} and its real path
      is verified to stay inside that root; traversal (``..``), absolute-path
      escapes, and symlink escapes are rejected with PermissionError.
    - Only allowlisted text extensions (.md/.txt/.json/.yaml/.yml) may be
      read; binaries and scripts are refused.
    - Files larger than MAX_REFERENCE_FILE_BYTES (1 MiB) are refused, so a
      runaway reference cannot exhaust the context budget.
    - Fails closed: when {SKILL_DIR} is not configured the read is refused,
      instead of silently resolving against the current working directory.

    Returns the file content as a UTF-8 string.
    """
    if not isinstance(filepath, str) or not filepath.strip():
        raise ValueError("filepath must be a non-empty string")
    if not SKILL_ROOT_CONFIGURED:
        raise PermissionError(
            "{SKILL_DIR} is not configured: refusing to resolve reference "
            "paths against the process working directory"
        )

    root = os.path.realpath(SKILL_ROOT)
    candidate = os.path.join(root, filepath)
    target = os.path.realpath(candidate)

    if target != root and not target.startswith(root + os.sep):
        raise PermissionError(
            f"path escapes the allowed root {{SKILL_DIR}}: {filepath}"
        )
    extension = os.path.splitext(target)[1].lower()
    if extension not in ALLOWED_REFERENCE_EXTENSIONS:
        raise ValueError(f"file extension not allowed: {extension or '<none>'}")
    if not os.path.isfile(target):
        raise FileNotFoundError(f"reference file not found: {filepath}")
    if os.path.getsize(target) > MAX_REFERENCE_FILE_BYTES:
        raise ValueError(
            f"reference file exceeds {MAX_REFERENCE_FILE_BYTES} byte read cap"
        )

    with open(target, "r", encoding="utf-8") as handle:
        return handle.read()
```

### 3.7 generate_trace_id

```python
def generate_trace_id(prefix="trace"):
    """Generate a unique, sortable audit-trace identifier (Harness L5).

    Format: ``{prefix}-{unix_millis}-{uuid4_hex12}``. Pure computation:
    stateless, no I/O, no global mutable state — safe to call from any
    thread or process. The identifier is designed to be threaded through
    every stage of a task (README_FOR_AI.md §8.1) so failures can be localized.

    Raises ValueError for a prefix that is empty or outside
    [A-Za-z0-9_-]{1,32}.
    """
    if not isinstance(prefix, str) or not re.fullmatch(r"[A-Za-z0-9_-]{1,32}", prefix):
        raise ValueError("prefix must be 1-32 characters of [A-Za-z0-9_-]")
    unix_millis = int(time.time() * 1000)
    return f"{prefix}-{unix_millis}-{uuid.uuid4().hex[:12]}"
```

### 3.8 check_rate_limit

```python
_rate_buckets = defaultdict(deque)
_rate_lock = Lock()
# Bound on tracked identifiers (defect L-3): without it every distinct caller
# id leaves a permanent entry and a long-running process grows without limit.
_MAX_RATE_IDENTIFIERS = 10000

def check_rate_limit(identifier, limit=10, window=60):
    """Sliding-window rate limiter, held in process memory only (Harness L4).

    Tracks the last ``limit`` request timestamps per ``identifier`` inside a
    ``window``-second sliding window. In-memory by design (README_FOR_AI.md §8.3): a
    persisted counter file would become a concurrency contention point and
    leave stale residue — nothing here is ever written to disk.

    Bounded memory: at most ``_MAX_RATE_IDENTIFIERS`` keys are retained. When
    the bound is exceeded, every bucket whose window has fully expired is
    dropped first and, if still over, the least-recently-inserted identifiers
    are evicted. Guarantee, stated plainly: an extreme identifier-churn spike
    can evict a STILL-ACTIVE caller's accounting, so this is a best-effort
    memory bound, not a per-caller fairness guarantee. (The previous wording
    claimed eviction only ever touched callers idle for a full window, which
    the oldest-inserted eviction order does not provide.)

    Thread-safe via a module-level lock. Returns True when the request is
    allowed (and records it), False when the limit is exhausted.
    """
    if not isinstance(identifier, str) or not identifier.strip():
        raise ValueError("identifier must be a non-empty string")
    if not isinstance(limit, int) or limit <= 0:
        raise ValueError("limit must be a positive integer")
    if not isinstance(window, (int, float)) or window <= 0:
        raise ValueError("window must be a positive number")

    now = time.monotonic()
    with _rate_lock:
        bucket = _rate_buckets[identifier]
        while bucket and bucket[0] <= now - window:
            bucket.popleft()
        if len(bucket) >= limit:
            return False
        bucket.append(now)
        if len(_rate_buckets) > _MAX_RATE_IDENTIFIERS:
            # Drop every bucket whose window has fully expired first: a bucket
            # that was never touched again still holds expired timestamps, so
            # testing only for "empty" left most expired keys in place.
            for key in list(_rate_buckets):
                bucket_k = _rate_buckets[key]
                while bucket_k and bucket_k[0] <= now - window:
                    bucket_k.popleft()
                if not bucket_k:
                    del _rate_buckets[key]
            overflow = len(_rate_buckets) - _MAX_RATE_IDENTIFIERS
            if overflow > 0:
                # Still over the bound: evict the least-recently-inserted keys.
                # Under extreme identifier churn that can drop an active
                # caller's accounting (documented residual, see the docstring).
                for key in list(_rate_buckets)[:overflow]:
                    del _rate_buckets[key]
        return True
```

### 3.9 mask_sensitive_data

```python
# --- PII masking policy (template 9) ---
# Placeholders are contractual: [EMAIL] / [IP] / [PHONE] must all remain.
#
# L-1: the TLD class is [A-Za-z]{2,}. The historical `[A-Z|a-z]{2,}` is a
# character class containing a literal '|' and accepts "a|b@x.c|m".
_EMAIL_RE = re.compile(
    r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}\b"
)
# L-2: octet-validated IPv4. Rejects 256.1.1.1, 01.02.03.04 and 1.2.3.4.5, so
# ordinary dotted numbers stop being mistaken for addresses.
_IPV4_OCTET = r"(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])"
_IPV4_RE = re.compile(
    r"(?<![0-9A-Za-z_.])"
    + _IPV4_OCTET + r"(?:\." + _IPV4_OCTET + r"){3}"
    + r"(?![0-9A-Za-z_.])"
)
# L-2a: there is deliberately NO version-keyword exemption. The previous guard
# spared "release 192.168.1.100", "build 10.0.0.1" and "rev 8.8.4.4" - real
# addresses in ordinary CI/log text - while README_FOR_AI.md §9.3 makes IP
# masking mandatory. A valid octet-validated dotted quad is always masked; the
# accepted cost is that a 4-part version number becomes "[IP]" too.
# M-2: CN mobile numbers. Optional country code (+86 / 0086 / 86), then 11
# digits written contiguously or in 3-4-4 groups joined by a space or a dash.
# "Only 11 contiguous digits" leaks +8613800138000, 138-0013-8000 and
# +86 138 0013 8000 — the three most common written forms.
_PHONE_RE = re.compile(
    r"(?<![0-9])(?:(?:\+|00)?86[\s-]?)?"
    r"1[3-9][0-9](?:[\s-]?[0-9]{4}[\s-]?[0-9]{4}|[0-9]{8})(?![0-9])"
)

def mask_sensitive_data(text):
    """Mask sensitive information in output (emails, IPv4 addresses, phone numbers).

    Contract (README_FOR_AI.md §9.3): all three classes are masked, and all three
    placeholders — ``[EMAIL]`` / ``[IP]`` / ``[PHONE]`` — are contractual.
    Dropping any one branch is a defect (P32); an implementation that masked
    only emails and IPs shipped once and passed review by eye (README_FOR_AI.md §7.1).

    Substitution order is fixed and load-bearing: email first (its domain would
    otherwise be eaten by the IPv4 branch), then IPv4, then phone.

    Honest trade-off (documented, not hidden): every octet-valid dotted quad is
    masked, so a four-part version number is masked as well ("version 1.2.3.4"
    becomes "version [IP]"). The earlier version-keyword exemption avoided that
    false positive but leaked genuine addresses written after "release",
    "build", "rev" and friends - a compliance failure under README_FOR_AI.md
    §9.3, where over-masking is acceptable and under-masking is not.
    """
    if not isinstance(text, str):
        raise TypeError("text must be a string")

    text = _EMAIL_RE.sub("[EMAIL]", text)
    text = _IPV4_RE.sub("[IP]", text)
    text = _PHONE_RE.sub("[PHONE]", text)
    return text
```

The three placeholders `[EMAIL]` / `[IP]` / `[PHONE]` are contractual: all
three masking branches must exist. An implementation that masks only emails
and IPs will pass review by eye but fail the `test_phone_masking` assertion —
this exact defect shipped once and was only caught by audit (README_FOR_AI.md §7.1 warning).
Raw, unmasked PII must never be logged or persisted (README_FOR_AI.md §9.3).

Coverage requirements verified by probe (these are the regression cases — do
not weaken them back to single-form matching):

| Input | Required output |
|-------|-----------------|
| `13800138000` | `[PHONE]` |
| `+8613800138000` | `[PHONE]` |
| `138-0013-8000` | `[PHONE]` |
| `+86 138 0013 8000` | `[PHONE]` |
| `0086 13800138000` | `[PHONE]` — no `0086` prefix may survive |
| `a\|b@x.c\|m` | unchanged (L-1: a literal pipe is not an address) |
| `version 1.2.3.4 released` | `version [IP] released` (L-2a: over-masking is accepted — the old exemption leaked `release 192.168.1.100`, `build 10.0.0.1`, `rev 8.8.4.4`) |
| `release 192.168.1.100` | `release [IP]` (L-2a regression: a keyword must never shield an address) |
| `build 10.0.0.1` | `build [IP]` |

### 3.10 build_prompt_from_template

```python
class _StrictDict(dict):
    """format_map mapping that fails loudly on unknown placeholders."""

    def __missing__(self, key):
        raise KeyError(f"template references unknown placeholder: {{{key}}}")

def build_prompt_from_template(template, **kwargs):
    """Render a prompt template with sanitized values (Harness L3).

    Contract (README_FOR_AI.md §7.1, template 10): **inputs are sanitized first**. Every
    substitution value passes through ``sanitize_user_query`` (3.2) and
    ``mask_sensitive_data`` (3.9) before insertion into the template, so
    prompt injection and PII can never ride in through a placeholder value.

    Unknown placeholders raise ``KeyError`` immediately instead of silently
    producing a half-rendered prompt. Use with the Section 4 frameworks, e.g.::

        build_prompt_from_template(
            "Who: {role}\nWhat: {task}\nWhy: {purpose}\nHow: {how}",
            role="data analyst", task="summarize Q3 revenue",
            purpose="weekly exec briefing", how="markdown, <=5 bullets",
        )

    Returns the fully rendered prompt string.
    """
    if not isinstance(template, str) or not template.strip():
        raise ValueError("template must be a non-empty string")

    sanitized = {}
    for key, value in kwargs.items():
        cleaned = sanitize_user_query(str(value))
        cleaned = mask_sensitive_data(cleaned)
        sanitized[key] = cleaned

    try:
        return template.format_map(_StrictDict(sanitized))
    except KeyError:
        raise
    except (IndexError, ValueError) as exc:
        raise ValueError(f"malformed template: {exc}") from exc
```

---

## 4. Prompt Frameworks (Full)

Field-by-field expansion. These expansions live **only** here (README_FOR_AI.md §7.2);
other files may name a framework and link to this section, never inline it.
Render any skeleton with `build_prompt_from_template` (Section 3.10).

### 4.1 CRISPE

Six fields, for complex multi-step tasks that need explicit constraints and
an example to anchor output shape.

| Field | Placeholder | Guidance |
|-------|-------------|----------|
| Role | `{role_description}` | Who the model is: expertise, seniority, perspective. Be specific ("senior tax auditor specializing in VAT compliance"), never generic ("helpful assistant"). |
| Result | `{desired_output}` | The concrete deliverable, stated as an artifact: a table, a patched file, a JSON object. Ambiguity here is the top cause of drift. |
| Input | `{input_data}` | The exact data the model operates on. Values rendered via `build_prompt_from_template` are auto-sanitized and PII-masked. |
| Steps | `{step_by_step}` | Ordered procedure the model must follow. Number the steps so deviations are detectable in review. |
| Parameters | `{constraints}` | Hard bounds: length caps, forbidden content, format rules, tone. Constraints must be verifiable, not aspirational. |
| Example | `{example}` | One representative input/output pair. The example is the strongest format signal; keep it minimal but complete. |

Skeleton (render with `build_prompt_from_template`):

```python
CRISPE_TEMPLATE = (
    "[Role] {role_description}\n"
    "[Result] {desired_output}\n"
    "[Input] {input_data}\n"
    "[Steps] {step_by_step}\n"
    "[Parameters] {constraints}\n"
    "[Example] {example}"
)
```

### 4.2 3WEH

Four fields, for clear delegation where the risk is misreading intent rather
than task complexity.

| Field | Placeholder | Guidance |
|-------|-------------|----------|
| Who | `{role}` | The acting role. One sentence, includes the domain ("release manager on call"). |
| What | `{task}` | The single action to perform, expressed as a verb + object. One task per prompt; split anything larger. |
| Why | `{purpose}` | The business reason. Enables the model to make correct judgment calls on unspecified details. |
| How | `{format_constraints}` | Output format and bounds: structure, length, language, units. Must be objectively checkable. |

Skeleton (render with `build_prompt_from_template`):

```python
THREE_WEH_TEMPLATE = (
    "Who: {role}\n"
    "What: {task}\n"
    "Why: {purpose}\n"
    "How: {format_constraints}"
)
```

### 4.3 Five-Element

Five fields, the enterprise-compliant default when output is auditable or
faces external review.

| Field | Placeholder | Guidance |
|-------|-------------|----------|
| Role | `{role}` | Acting role with domain and authority level, same rules as 3WEH Who. |
| Task | `{task}` | The action, verb + object. One task per prompt. |
| Context | `{context}` | Background facts the model cannot infer: environment, prior decisions, upstream data. Facts only — no instructions smuggled inside context. |
| Format | `{output_format}` | The exact output schema (JSON shape, table columns, file layout). Pair with `validate_input_schema` when output must round-trip. |
| Constraint | `{constraints}` | Compliance bounds: policy references, forbidden disclosures, mandatory AIGC labeling, PII masking requirements. |

Skeleton (render with `build_prompt_from_template`):

```python
FIVE_ELEMENT_TEMPLATE = (
    "Role: {role}\n"
    "Task: {task}\n"
    "Context: {context}\n"
    "Format: {output_format}\n"
    "Constraint: {constraints}"
)
```

---

## 5. Compliance Verification

Verification procedures for the non-negotiable compliance areas
(README_FOR_AI.md §9.2–9.4) plus the package-wide safety posture. A declared
Harness level without verifiable evidence in this file violates P24
(README_FOR_AI.md §8.2).

### 5.1 AIGC Labeling Requirements (README_FOR_AI.md §9.2)

Every generated artifact carries all three layers, produced by template 4
(`format_output_json`, 3.4). Missing any layer is non-compliant and raises
`CLO_003`:

| Layer | Carrier | Implemented by |
|---|---|---|
| Explicit label | Visible disclosure line appended to the content body | `format_output_json` (3.4) |
| Implicit metadata | `ai_generated`, `generated_at` (ISO-8601 UTC) and `model` (`<provider/model>`) payload fields | `format_output_json` (3.4) |
| Embedded watermark | SHA-256 marker inside the content body, bound to provider + timestamp + a digest of the content itself | `format_output_json` (3.4) |

Verification procedure: parse the envelope with `json.loads`, assert the three
metadata fields, and confirm the watermark marker string appears inside the
`content` value. The marker must survive copy-paste of the content body.

**Strength limit of layer 3 (do not overclaim, P24).** The marker is
tamper-*evident*, not tamper-*proof*: editing the body invalidates the digest
the marker was derived from, but the trailing disclosure line can still be
deleted in one operation, leaving a body that looks human-authored. Do not
describe layer 3 as "cannot be removed" — that claim was measured and found
false. Where a non-strippable mark is required, sign the payload outside this
envelope.

### 5.2 PII Masking Verification (README_FOR_AI.md §9.3)

Template 9 (`mask_sensitive_data`, 3.9) must be applied to **every** outbound
payload — before any persistence, logging or external sending. The substitution
literals are fixed and contractual:

| Class | Placeholder | Coverage |
|---|---|---|
| Email | `[EMAIL]` | RFC-5322-style `local@domain`, TLD of at least two letters |
| IPv4 | `[IP]` | Four dot-separated octets, each validated to 0–255 |
| Phone | `[PHONE]` | CN mobile numbers: optional `+86` / `0086` / `86` country code; 11 digits contiguous or in 3-4-4 groups joined by a space or a dash |

⚠️ All three branches are mandatory. A masking function that handles only email
and IP while its contract promises three classes is a **contract/implementation
divergence** — the exact defect class that stayed invisible in a predecessor
package because its test suite carried an inlined copy rather than reading the
authoritative source; see the note under [3.9](#39-mask_sensitive_data).

Verification: feed a fixture containing an email, an IPv4 address and a phone
number in a common written form (country code and separators included) through
`mask_sensitive_data`; the result must contain `[EMAIL]`, `[IP]` and `[PHONE]`
respectively and none of the originals. Masking happens **first** — raw values
must never appear in logs.

### 5.3 Audit Trail (README_FOR_AI.md §8.1, §8.2)

- Every task carries a `generate_trace_id` (3.7) identifier from start to
  finish; without it, failures cannot be localized.
- Logs record the trace id, the operation name, timestamps and outcome —
  never raw PII (5.2 applies to log lines too).
- Trace ids are stateless and derived from wall-clock plus randomness; they
  are safe to generate concurrently and require no coordination.
- Verification: a task's log entries all share one trace id; no log line
  matches the PII regexes of `mask_sensitive_data`.

### 5.4 Safety Baseline (README_FOR_AI.md §9.4)

Non-negotiable, verified against this file's templates:

- **Zero dynamic code execution** — no `eval`/`exec` on user input, and no
  remote download-and-execute cmdlets (dynamic expression evaluation, string
  download, web request) anywhere. Template 2 sanitizes by regex substitution
  only; template 3 runs `shell=False` subprocesses.
- **Zero hardcoded secrets** — credentials come from environment variables;
  configuration records variable *names*, never values. Template 3 actively
  scrubs secret-like variables from child environments by **name fragment**
  (`AWS_SECRET_ACCESS_KEY`, `GITHUB_TOKEN`, `OPENAI_APIKEY` are all covered).
  Prefix-only matching is a verified leak and must not be reinstated.
- **Command blocklist is best-effort** — template 3 rejects a fixed set of
  dangerous *program names*. It is a first line of defence, not a sandbox
  boundary: any allowed interpreter can still delete files
  (`python -c "os.remove(...)"`, `git clean -fd`, `find . -delete`). The real
  boundary is the host permission set declared in `SKILL.md`'s `permissions`
  block (specification: `README_FOR_AI.md` §9.1).
- **Zero sensitive-path access** — template 6 rejects any path resolving
  outside `{SKILL_DIR}`, and fails closed when `{SKILL_DIR}` is unconfigured
  rather than falling back to the process working directory.
- **Zero self-rewrite** — the skill never writes into `{SKILL_DIR}`; writable
  output goes only under `{WORKSPACE_ROOT}`.
- **Idempotency** — operations are safe to retry; `retry_with_backoff`
  re-raises the final error and `check_rate_limit` keeps no persistent state
  (README_FOR_AI.md §8.3).
- **Rollback safety** — copy to a temp location, verify, atomically replace,
  and only then delete the old copy; never delete first and restore later
  (P23).

### 5.5 Security Check Matrix

| Control | Template | Verified by |
|---|---|---|
| No dynamic code execution | 2, 10 | `TestSanitizeUserQuery`, `TestBuildPromptFromTemplate` |
| No shell string execution | 3 | `TestExecuteSafeCommand.test_string_command_rejected` |
| No path traversal | 6 | `TestReadReferenceFile.test_traversal_outside_skill_dir_rejected` |
| PII masking (3 classes) | 9 | `TestMaskSensitiveData` (all three asserted separately) |
| AIGC triple labeling | 4 | `TestFormatOutputJson.test_aigc_triple_labeling` |
| Bounded retries | 5 | `TestRetryWithBackoff.test_attempts_are_bounded` |
| No secret persistence | 8 | `TestCheckRateLimit` (in-memory only by construction) |
| Audit traceability | 7 | `TestGenerateTraceId.test_uniqueness` |

### 5.6 Robustness Checklist

Applied per capability, mapped to Harness levels (see 5.7):

- [ ] Input validated (template 1) before use
- [ ] User text sanitized (template 2) before interpolation or logging
- [ ] External calls rate-limited (template 8) and retried with backoff (template 5)
- [ ] Failure path returns a typed error code, never a bare exception
- [ ] Operation is idempotent — safe to retry without duplicate side effects
- [ ] Output masked (template 9) and labelled (template 4)
- [ ] Trace ID (template 7) attached for audit

### 5.7 Harness Maturity L1–L6

| Level | Name | Constraints | Use case |
|---|---|---|---|
| L1 | Skeleton | Basic schema, frontmatter | Prototyping |
| L2 | Functional | Input validation, output formatting | Internal tools |
| L3 | Robust | Error handling, retry logic, idempotency | Department tools |
| L4 | Resilient | Circuit breakers, rate limiting, monitoring | Production services |
| L5 | Compliant | AIGC labels, PII masking, audit trails | Customer-facing |
| L6 | Certified | STRIDE model, CVSS scoring, CISO sign-off | Critical infrastructure |

**Every department in this package is specified at L3 or above.** Tier size
governs how many departments exist, not how hard each one is built — a
two-department micro package and this eighteen-department package hold the same
per-capability bar.

⚠️ Harness `L1–L6` is unrelated to disclosure layers `D1–D3` and to the tier
letter `L` (large). Three separate numbering systems; see the terminology note
in the root `SKILL.md`.

### 5.8 Registry Safety Posture

Patterns this package must never contain, and the tests that enforce it:

| Forbidden pattern | Why | Enforced by |
|---|---|---|
| Remote download-and-execute cmdlets (dynamic expression evaluation, string download, web request) | Download-then-run is the primary malicious-skill signature | `test_no_remote_execution_patterns` |
| Hardcoded absolute user paths | Machine-specific; fails everywhere else | `test_no_hardcoded_user_paths` |
| Literal credentials or bearer tokens | Secret leakage | `test_no_embedded_secrets` |
| Writes to `{SKILL_DIR}` | Self-modification / self-escalation | `test_script_never_writes_skill_dir`, `TestImmutableBoundary` |
| Shipped `.pyc` / `__pycache__` | Version-bound bytecode, diff noise | `test_no_compiled_artifacts` |

⚠️ The forbidden tokens are **deliberately not spelled out above**. Writing them
literally in a markdown file would make this very page fail its own sweep — the
test suite assembles those patterns at runtime for the same reason.

---

## 6. Constraints

Forbidden in and around this file:

- ❌ Do not inline any template implementation outside this file — link to the
  Section 3 anchor instead. A second `def` of any shared function anywhere in
  the package is the recurrence signal of defect P10 / P44.
- ❌ Do not alter template parameter names or default values — the test suite
  asserts them.
- ❌ Do not reorder Section 3.1–3.10 — the order matches the index table #1–#10.
- ❌ Do not add third-party dependencies to templates 1–10 (standard library only).
- ❌ Do not weaken the `[EMAIL]` / `[IP]` / `[PHONE]` placeholders.
- ❌ Do not copy the ten shared templates into a department D3
  `method-patterns.md` — those files hold department-specific patterns only.
- ❌ Do not declare a Harness level a capability does not satisfy (`FW_006`).
- ❌ Do not interpolate user text into prompts without template 10.
- ❌ Do not use bare code fences — every fenced block is ```` ```python ````;
  untagged fences and `py` tags are rejected (R3-4).
- ❌ Do not hardcode absolute paths — use `{SKILL_DIR}` / `{WORKSPACE_ROOT}`
  placeholders in prose and environment variables in code.
- ❌ Do not expand a prompt framework outside Section 4 — `SKILL.md` names
  frameworks and links here only (README_FOR_AI.md §7.2).
- ❌ Do not skip Harness prerequisites — levels are cumulative: an L5 claim
  without idempotency evidence is downgraded to L2 and recorded as a defect
  (README_FOR_AI.md §8.1).

---

## 7. Department-Specific Patterns

Department-specific templates and patterns belong to each department's own D3
`references/method-patterns.md`. Those files **link to this file** and never
inline the ten shared templates — a second `def` of any shared function is the
P10 / P44 recurrence signal (see Section 6).

| Domain | Department | D3 method patterns |
|---|---|---|
| governance | Executive & Strategy (`executive-strategy`, `CEO_`) | [departments/executive-strategy/references/method-patterns.md](departments/executive-strategy/references/method-patterns.md) |
| governance | Operations & Coordination (`operations-coordination`, `COO_`) | [departments/operations-coordination/references/method-patterns.md](departments/operations-coordination/references/method-patterns.md) |
| governance | Board & Branch (`board-and-branch`, `BRD_`) | [departments/board-and-branch/references/method-patterns.md](departments/board-and-branch/references/method-patterns.md) |
| finance | Finance & Treasury (`finance-treasury`, `CFO_`) | [departments/finance-treasury/references/method-patterns.md](departments/finance-treasury/references/method-patterns.md) |
| finance | Risk & Audit (`risk-audit`, `CRO_`) | [departments/risk-audit/references/method-patterns.md](departments/risk-audit/references/method-patterns.md) |
| finance | Procurement & Billing (`procurement-billing`, `PRC_`) | [departments/procurement-billing/references/method-patterns.md](departments/procurement-billing/references/method-patterns.md) |
| technology | Engineering & Tooling (`engineering-tooling`, `CTO_`) | [departments/engineering-tooling/references/method-patterns.md](departments/engineering-tooling/references/method-patterns.md) |
| technology | Platform & MLOps (`platform-mlops`, `FW_`) | [departments/platform-mlops/references/method-patterns.md](departments/platform-mlops/references/method-patterns.md) |
| technology | Model & Data (`model-data`, `MDL_`) | [departments/model-data/references/method-patterns.md](departments/model-data/references/method-patterns.md) |
| security | Security & Resilience (`security-resilience`, `CISO_`) | [departments/security-resilience/references/method-patterns.md](departments/security-resilience/references/method-patterns.md) |
| security | Legal & Privacy (`legal-privacy`, `CLO_`) | [departments/legal-privacy/references/method-patterns.md](departments/legal-privacy/references/method-patterns.md) |
| security | Incident & Identity (`incident-identity`, `IRP_`) | [departments/incident-identity/references/method-patterns.md](departments/incident-identity/references/method-patterns.md) |
| people | Lifecycle & Training (`lifecycle-training`, `CHO_`) | [departments/lifecycle-training/references/method-patterns.md](departments/lifecycle-training/references/method-patterns.md) |
| people | Knowledge & Ethics (`knowledge-ethics`, `KNM_`) | [departments/knowledge-ethics/references/method-patterns.md](departments/knowledge-ethics/references/method-patterns.md) |
| growth | Marketing & Partnerships (`marketing-partnerships`, `CMO_`) | [departments/marketing-partnerships/references/method-patterns.md](departments/marketing-partnerships/references/method-patterns.md) |
| growth | Intelligence & Sentiment (`intelligence-sentiment`, `INTEL_`) | [departments/intelligence-sentiment/references/method-patterns.md](departments/intelligence-sentiment/references/method-patterns.md) |
| delivery | Quality & Visualization (`quality-visualization`, `CQO_`) | [departments/quality-visualization/references/method-patterns.md](departments/quality-visualization/references/method-patterns.md) |
| delivery | Delivery & Scheduling (`delivery-scheduling`, `PMGR_`) | [departments/delivery-scheduling/references/method-patterns.md](departments/delivery-scheduling/references/method-patterns.md) |
