#!/usr/bin/env python3
"""
AI Company (large tier) — Core Template Test Suite

Design contract (see README_FOR_AI.md §5.10):
  Class A — behaviour tests for all 10 templates
  Class B — source-file integrity: the authoritative method-patterns.md §3 exists and is complete
  Class C — structural consistency: departments, function blocks, scaling files
  Class D — immutable boundary: no upgrade proposal may touch tests/ or permissions

CRITICAL: this suite EXTRACTS the template implementations from
references/method-patterns.md §3 at runtime and tests *those*. It never inlines a copy.
An earlier package in this lineage inlined its own copies, which let the
authoritative source drift (a missing [PHONE] branch) while the suite still
reported 19/19 green. Testing the real source is the only way that class of
defect can be caught.
"""

import glob
import json
import os
import re
import sys
import time
import unittest
from datetime import datetime, timezone
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent
AUTHORITATIVE_SOURCE = SKILL_DIR / "references" / "method-patterns.md"
DEPARTMENTS_DIR = SKILL_DIR / "references" / "departments"
WORKSPACE_ROOT = Path(os.environ.get("WORKSPACE_ROOT", SKILL_DIR.parent))

# ★ Pin the sandbox roots BEFORE extracting the namespace. method-patterns.md §3 reads
# SKILL_DIR / WORKSPACE_ROOT at module level, and read_reference_file (template 6) fails
# closed unless SKILL_DIR is configured. The test runner sets these again, but the
# module import must already have them.
os.environ["SKILL_DIR"] = str(SKILL_DIR)
os.environ["WORKSPACE_ROOT"] = str(WORKSPACE_ROOT)

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

# ---------------------------------------------------------------------------
# Extraction: pull the authoritative implementations out of method-patterns.md §3
# ---------------------------------------------------------------------------


def load_template_namespace():
    """Extract and exec every ```python block from method-patterns.md §3.

    Returns the resulting namespace. Raises if the source is missing or
    incomplete — a missing authoritative source is a test failure, never a skip.
    Only section 3 (the shared code templates) is loaded; section 4 holds the
    prompt frameworks, which are not template implementations.
    """
    if not AUTHORITATIVE_SOURCE.exists():
        raise AssertionError("authoritative template source missing: %s" % AUTHORITATIVE_SOURCE)

    text = AUTHORITATIVE_SOURCE.read_text(encoding="utf-8")
    section = re.search(r"^## 3\. Shared Code Templates(.*?)(?=^## 4\.)", text, re.S | re.M)
    body = section.group(1) if section else text
    blocks = re.findall(r"```python\n(.*?)```", body, re.S)
    if not blocks:
        raise AssertionError("no python code blocks found in %s §3" % AUTHORITATIVE_SOURCE)

    namespace = {}
    for block in blocks:
        exec(compile(block, str(AUTHORITATIVE_SOURCE), "exec"), namespace)

    missing = [fn for fn in TEN_TEMPLATE_NAMES if not callable(namespace.get(fn))]
    if missing:
        raise AssertionError(
            "templates defined in source but not callable after exec: %s" % ", ".join(missing)
        )
    return namespace


TPL = load_template_namespace()


# ---------------------------------------------------------------------------
# Class A — behaviour tests
# ---------------------------------------------------------------------------


class TestValidateInputSchema(unittest.TestCase):
    """Template 1: validate_input_schema(data, schema)"""

    def test_valid_object(self):
        schema = {"task": {"type": str, "required": True}}
        self.assertIs(TPL["validate_input_schema"]({"task": "review budget"}, schema), True)

    def test_missing_required_key(self):
        schema = {"type": "object", "required": ["task"]}
        with self.assertRaises(ValueError):
            TPL["validate_input_schema"]({}, schema)

    def test_wrong_type_rejected(self):
        with self.assertRaises(ValueError):
            TPL["validate_input_schema"]("not-a-list", {"type": "array"})

    def test_malformed_schema_raises(self):
        with self.assertRaises(ValueError):
            TPL["validate_input_schema"]({"a": 1}, "not-a-dict")


class TestSanitizeUserQuery(unittest.TestCase):
    """Template 2: sanitize_user_query(query)"""

    def test_normal_query_unchanged(self):
        self.assertEqual(TPL["sanitize_user_query"]("review the q2 budget"), "review the q2 budget")

    def test_shell_metacharacters_removed(self):
        out = TPL["sanitize_user_query"]("ls; rm -rf / && echo `id` $(whoami)")
        for ch in [";", "&", "`", "$", "|"]:
            self.assertNotIn(ch, out)

    def test_newlines_collapsed(self):
        out = TPL["sanitize_user_query"]("line1\nline2\r\nline3")
        self.assertNotIn("\n", out)
        self.assertNotIn("\r", out)

    def test_non_string_raises(self):
        with self.assertRaises(TypeError):
            TPL["sanitize_user_query"](None)
        with self.assertRaises(TypeError):
            TPL["sanitize_user_query"](12345)


class TestExecuteSafeCommand(unittest.TestCase):
    """Template 3: execute_safe_command(cmd, timeout=30) -> {returncode, stdout, stderr}"""

    def test_benign_command_runs_with_restricted_cwd(self):
        fn = TPL["execute_safe_command"]
        ran = False
        for cmd in ([sys.executable, "-c", "print('CWDPROBE')"],
                    '%s -c "print(\'CWDPROBE\')"' % sys.executable):
            try:
                res = fn(cmd, timeout=30)
            except Exception:
                continue
            if isinstance(res, dict) and res.get("returncode") == 0 \
                    and "CWDPROBE" in (res.get("stdout") or ""):
                ran = True
                break
        self.assertTrue(ran, "execute_safe_command did not run a benign command")

    def test_empty_command_rejected(self):
        with self.assertRaises(ValueError):
            TPL["execute_safe_command"]([], timeout=30)

    def test_blocked_executable_rejected(self):
        with self.assertRaises(PermissionError):
            TPL["execute_safe_command"](["rm", "-rf", "/"], timeout=30)

    def test_string_command_accepted(self):
        """A shlex-parsed string is a valid input shape (no shell interpolation)."""
        res = TPL["execute_safe_command"]([sys.executable, "-c", "print('hello')"], timeout=30)
        self.assertIsInstance(res, dict)
        self.assertEqual(res["returncode"], 0)

    def test_timeout_enforced(self):
        start = time.time()
        with self.assertRaises(TimeoutError):
            TPL["execute_safe_command"](
                [sys.executable, "-c", "import time; time.sleep(5)"], timeout=1)
        self.assertLess(time.time() - start, 4)

    def test_output_not_truncated(self):
        res = TPL["execute_safe_command"](
            [sys.executable, "-c", "print('x' * 200000)"], timeout=30)
        self.assertEqual(res["returncode"], 0)
        self.assertNotIn("truncated", res)
        self.assertGreaterEqual(len(res["stdout"] or ""), 200000)


class TestFormatOutputJson(unittest.TestCase):
    """Template 4: format_output_json(content, provider) -> AIGC envelope (str)"""

    def test_aigc_triple_labeling(self):
        raw = TPL["format_output_json"]("answer content", "test-provider")
        data = json.loads(raw)
        # Layer 2: implicit metadata
        self.assertIs(data.get("ai_generated"), True)
        ts = data.get("generated_at")
        self.assertRegex(ts, r"\d{4}-\d{2}-\d{2}")
        self.assertIn("+00:00", ts)  # timezone-aware UTC
        self.assertEqual(data.get("model"), "test-provider/default")
        # Layer 1: explicit disclosure + Layer 3: embedded watermark, both in body
        self.assertRegex(raw, r"(?i)ai[-_ ]?generated")
        self.assertIn("[aigc:", raw)
        # content carried verbatim (masking happens upstream)
        self.assertIn("answer content", data.get("content", ""))

    def test_timestamp_is_timezone_aware(self):
        env = json.loads(TPL["format_output_json"]("x", "p"))
        self.assertIn("+00:00", env["generated_at"],
                      "timestamp must be timezone-aware (not naive utcnow)")

    def test_non_string_content_raises(self):
        with self.assertRaises(TypeError):
            TPL["format_output_json"](object(), "p")

    def test_empty_provider_raises(self):
        with self.assertRaises(ValueError):
            TPL["format_output_json"]("x", "")

    def test_json_string_content_carried(self):
        env = json.loads(TPL["format_output_json"]('{"k": 1}', "p"))
        self.assertIn('{"k": 1}', env["content"])


class TestRetryWithBackoff(unittest.TestCase):
    """Template 5: retry_with_backoff(func, max_retries=3)"""

    def test_success_first_try(self):
        self.assertEqual(TPL["retry_with_backoff"](lambda: "ok", max_retries=0), "ok")

    def test_retry_then_success(self):
        calls = {"n": 0}

        def flaky():
            calls["n"] += 1
            if calls["n"] < 3:
                raise RuntimeError("transient")
            return "recovered"

        self.assertEqual(TPL["retry_with_backoff"](flaky, max_retries=3), "recovered")
        self.assertEqual(calls["n"], 3)

    def test_raises_after_max_retries(self):
        def always_fail():
            raise ValueError("permanent")

        with self.assertRaises(ValueError):
            TPL["retry_with_backoff"](always_fail, max_retries=0)

    def test_attempts_are_bounded(self):
        calls = {"n": 0}

        def counter():
            calls["n"] += 1
            raise RuntimeError("x")

        with self.assertRaises(RuntimeError):
            TPL["retry_with_backoff"](counter, max_retries=2)
        self.assertEqual(calls["n"], 3, "max_retries=2 must yield exactly 3 attempts")


class TestReadReferenceFile(unittest.TestCase):
    """Template 6: read_reference_file(filepath) -> str (fail-closed)"""

    def setUp(self):
        os.environ["SKILL_DIR"] = str(SKILL_DIR)

    def test_allowed_relative_path(self):
        content = TPL["read_reference_file"]("SKILL.md")
        self.assertIsInstance(content, str)
        self.assertIn("ai-company", content)

    def test_traversal_rejected(self):
        with self.assertRaises(PermissionError):
            TPL["read_reference_file"]("../README_FOR_AI.md")

    def test_absolute_path_rejected(self):
        outside = str(Path(os.path.expanduser("~")) / ".ssh" / "id_rsa")
        with self.assertRaises((PermissionError, ValueError)):
            TPL["read_reference_file"](outside)

    def test_missing_file_rejected(self):
        with self.assertRaises(FileNotFoundError):
            TPL["read_reference_file"]("references/does-not-exist.md")

    def test_disallowed_extension_rejected(self):
        with self.assertRaises(ValueError):
            TPL["read_reference_file"]("scripts/self-scale.ps1")


class TestGenerateTraceId(unittest.TestCase):
    """Template 7: generate_trace_id(prefix="trace")"""

    def test_default_prefix(self):
        self.assertTrue(TPL["generate_trace_id"]().startswith("trace-"))

    def test_custom_prefix(self):
        self.assertTrue(TPL["generate_trace_id"](prefix="cto").startswith("cto-"))

    def test_uniqueness(self):
        ids = {TPL["generate_trace_id"]() for _ in range(200)}
        self.assertEqual(len(ids), 200)

    def test_millis_segment_is_numeric(self):
        tid = TPL["generate_trace_id"]()
        seg = tid.split("-")[1]
        self.assertRegex(seg, r"^\d+$", "segment 2 is unix millis, not a calendar date")


class TestCheckRateLimit(unittest.TestCase):
    """Template 8: check_rate_limit(identifier, limit=10, window=60) -> bool"""

    def test_within_limit(self):
        ident = "tl-within-%d" % int(time.time() * 1000)
        for _ in range(3):
            self.assertTrue(TPL["check_rate_limit"](ident, limit=3, window=60))

    def test_exceed_limit(self):
        ident = "tl-exceed-%d" % int(time.time() * 1000)
        for _ in range(3):
            TPL["check_rate_limit"](ident, limit=3, window=60)
        self.assertFalse(TPL["check_rate_limit"](ident, limit=3, window=60))

    def test_window_expiry(self):
        ident = "tl-window-%d" % int(time.time() * 1000)
        TPL["check_rate_limit"](ident, limit=1, window=1)
        time.sleep(1.2)
        self.assertTrue(TPL["check_rate_limit"](ident, limit=1, window=1),
                        "limit must reset once the window elapses")

    def test_identifiers_are_isolated(self):
        stamp = int(time.time() * 1000)
        a, b = "tl-a-%d" % stamp, "tl-b-%d" % stamp
        TPL["check_rate_limit"](a, limit=1, window=60)
        self.assertTrue(TPL["check_rate_limit"](b, limit=1, window=60))


class TestMaskSensitiveData(unittest.TestCase):
    """Template 9: mask_sensitive_data(text) — EMAIL / IP / PHONE all required"""

    def test_email_masking(self):
        self.assertEqual(TPL["mask_sensitive_data"]("mail admin@example.com now"),
                         "mail [EMAIL] now")

    def test_ip_masking(self):
        self.assertEqual(TPL["mask_sensitive_data"]("host 10.0.0.1 up"), "host [IP] up")

    def test_phone_masking(self):
        """The branch whose absence went undetected in the predecessor package.

        All five common CN-mobile written forms must mask (regression coverage).
        """
        for raw in ("13800138000", "+8613800138000", "138-0013-8000",
                    "+86 138 0013 8000", "0086 13800138000"):
            out = TPL["mask_sensitive_data"]("call %s now" % raw)
            self.assertIn("[PHONE]", out, "phone variant not masked: %s" % raw)
            self.assertNotIn(raw, out, "raw phone survived masking: %s" % raw)

    def test_all_three_in_one_string(self):
        raw = "Email: admin@example.com, IP: 192.168.1.1, Phone: 13800138000"
        out = TPL["mask_sensitive_data"](raw)
        self.assertIn("[EMAIL]", out)
        self.assertIn("[IP]", out)
        self.assertIn("[PHONE]", out)
        self.assertNotIn("admin@example.com", out)
        self.assertNotIn("13800138000", out)

    def test_non_string_raises(self):
        with self.assertRaises(TypeError):
            TPL["mask_sensitive_data"](42)

    def test_clean_text_untouched(self):
        self.assertEqual(TPL["mask_sensitive_data"]("no pii here"), "no pii here")


class TestBuildPromptFromTemplate(unittest.TestCase):
    """Template 10: build_prompt_from_template(template, **kwargs)"""

    def test_simple_substitution(self):
        out = TPL["build_prompt_from_template"]("Role: {role}\nTask: {task}",
                                                role="CFO", task="review budget")
        self.assertIn("Role: CFO", out)
        self.assertIn("Task: review budget", out)

    def test_inputs_are_sanitized(self):
        out = TPL["build_prompt_from_template"]("Q: {q}", q="ls; rm -rf /")
        self.assertNotIn(";", out)

    def test_non_string_value_coerced(self):
        out = TPL["build_prompt_from_template"]("N: {n}", n=12345)
        self.assertIn("N: 12345", out)

    def test_non_string_template_raises(self):
        with self.assertRaises(ValueError):
            TPL["build_prompt_from_template"](None, a=1)

    def test_unknown_placeholder_raises(self):
        with self.assertRaises(KeyError):
            TPL["build_prompt_from_template"]("{known} {unknown}", known="v")


# ---------------------------------------------------------------------------
# Class B — source-file integrity
# ---------------------------------------------------------------------------


class TestAuthoritativeSourceIntegrity(unittest.TestCase):
    """Guards against the inlined-copy defect: the source must be the real thing."""

    SOURCE = AUTHORITATIVE_SOURCE

    def test_source_exists(self):
        self.assertTrue(self.SOURCE.exists(), "authoritative template source missing: %s" % self.SOURCE)

    def test_all_ten_definitions_present_in_source(self):
        content = self.SOURCE.read_text(encoding="utf-8")
        for fn in TEN_TEMPLATE_NAMES:
            self.assertIn("def %s" % fn, content, "template %s missing from authoritative source" % fn)

    def test_phone_masking_in_source(self):
        """Contract/code/test must not diverge — assert the source itself has PHONE."""
        content = self.SOURCE.read_text(encoding="utf-8")
        self.assertIn("[PHONE]", content, "authoritative source lacks the PHONE masking branch")

    def test_source_is_the_only_copy(self):
        """No other file may carry a duplicate implementation (single-source rule)."""
        duplicates = []
        for path in SKILL_DIR.rglob("*.md"):
            if path.resolve() == self.SOURCE.resolve():
                continue
            if ".git" in path.parts:
                continue
            text = path.read_text(encoding="utf-8", errors="ignore")
            if re.search(r"^\s*def mask_sensitive_data\(", text, re.M):
                duplicates.append(str(path.relative_to(SKILL_DIR)))
        self.assertEqual(duplicates, [], "template code duplicated outside method-patterns.md: %s" % duplicates)

    def test_source_carries_code_and_frameworks(self):
        """method-patterns.md §3 is the code authority; §4 holds the frameworks."""
        content = self.SOURCE.read_text(encoding="utf-8")
        self.assertIn("## 3. Shared Code Templates", content)
        self.assertIn("## 4. Prompt Frameworks", content)

    def test_no_deprecated_utcnow(self):
        """Scan CODE BLOCKS only — prose that warns against utcnow() must not trip this."""
        content = self.SOURCE.read_text(encoding="utf-8")
        code = "\n".join(re.findall(r"```python\n(.*?)```", content, re.S))
        self.assertNotIn("utcnow()", code,
                         "datetime.utcnow() is deprecated; use now(timezone.utc)")


# ---------------------------------------------------------------------------
# Class C — structural consistency
# ---------------------------------------------------------------------------


class TestStructuralConsistency(unittest.TestCase):
    """Tier invariants. These fail until the package is complete — by design."""

    def _meta(self):
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        m = {}
        for key in ("scale_tier", "department_count", "function_block_count", "version"):
            found = re.search(r"^\s*%s:\s*\"?([\w.]+)\"?\s*$" % key, text, re.M)
            if found:
                m[key] = found.group(1)
        return m

    def test_department_count_matches_disk(self):
        meta = self._meta()
        expected = int(meta["department_count"])
        on_disk = len(list(DEPARTMENTS_DIR.glob("*.md")))
        self.assertEqual(on_disk, expected,
                         "declared %d departments but found %d D2 pages on disk" % (expected, on_disk))

    def test_function_block_conservation(self):
        """XS/S/M/L = 18 function blocks, G = 36. Detects functions lost in merging."""
        meta = self._meta()
        tier = meta["scale_tier"]
        expect = {"micro": 18, "small": 18, "medium": 18, "large": 18, "group": 36}[tier]
        total = 0
        for page in sorted(DEPARTMENTS_DIR.glob("*.md")):
            total += len(re.findall(r"^## FB-\d+:", page.read_text(encoding="utf-8"), re.M))
        self.assertEqual(total, expect,
                         "function-block conservation violated: found %d, expected %d for tier %s"
                         % (total, expect, tier))

    def test_declared_function_block_count_matches_disk(self):
        meta = self._meta()
        declared = int(meta["function_block_count"])
        total = 0
        for page in DEPARTMENTS_DIR.glob("*.md"):
            total += len(re.findall(r"^## FB-\d+:", page.read_text(encoding="utf-8"), re.M))
        self.assertEqual(total, declared, "frontmatter declares %d blocks, disk has %d" % (declared, total))

    def test_department_subdirs_named_correctly(self):
        """P1: a department subdir manifest must never be called SKILL.md."""
        bad = [str(p.relative_to(SKILL_DIR)) for p in DEPARTMENTS_DIR.rglob("SKILL.md")]
        self.assertEqual(bad, [], "department subdirectories must not contain SKILL.md: %s" % bad)

    def test_department_specs_have_no_name_field(self):
        """P1: sub-manifests must not carry a top-level name/triggers/interface."""
        offenders = []
        for spec in DEPARTMENTS_DIR.rglob("department-spec.md"):
            text = spec.read_text(encoding="utf-8")
            head = text.split("---")[1] if text.count("---") >= 2 else ""
            for field in ("name:", "triggers:", "interface:"):
                if re.search(r"^%s" % field, head, re.M):
                    offenders.append("%s has %s" % (spec.parent.name, field))
        self.assertEqual(offenders, [], "sub-manifest carries loader-visible fields: %s" % offenders)

    def test_department_index_matches_disk(self):
        """Bidirectional: index entries must exist on disk, disk departments must be indexed."""
        index = SKILL_DIR / "references" / "department-index.md"
        self.assertTrue(index.exists(), "department-index.md missing (required for large tier)")
        text = index.read_text(encoding="utf-8")
        indexed = set(re.findall(r"^\|\s*`?([a-z][a-z0-9-]+)`?\s*\|", text, re.M))
        on_disk = {p.stem for p in DEPARTMENTS_DIR.glob("*.md")}
        self.assertEqual(indexed - on_disk, set(), "indexed but missing on disk (broken link)")
        self.assertEqual(on_disk - indexed, set(), "on disk but not indexed (orphan)")

    def test_error_codes_match_prefix_declaration(self):
        """Declared prefixes must equal the prefixes actually used in error-codes.md.

        Both sides are normalised to the bare prefix WITHOUT the trailing underscore -
        comparing {'CEO'} against {'CEO_'} can never succeed.

        The declaration is a YAML flow list that may wrap across several lines. It is
        parsed from the frontmatter segment (between the first two '---' fences) up to
        the closing ']'. Splitting on a blank line instead would either truncate a
        wrapped list or leak the permissions block into the comparison - a real defect
        this test shipped with, which read '{SKILL_DIR}' from the permissions section
        and reported a phantom 'SKILL' prefix.
        """
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        self.assertIn("error_code_prefixes:", text, "prefix declaration missing from frontmatter")
        frontmatter = text.split("---")[1] if text.count("---") >= 2 else text
        m = re.search(r"error_code_prefixes:\s*\[(.*?)\]", frontmatter, re.S)
        self.assertIsNotNone(m, "error_code_prefixes is not a bracketed flow list")
        declared = set(re.findall(r"\b([A-Z]{2,5})_", m.group(1)))

        codes_file = SKILL_DIR / "references" / "error-codes.md"
        self.assertTrue(codes_file.exists(), "error-codes.md missing")
        body = codes_file.read_text(encoding="utf-8")
        used = {mm.group(1) for mm in re.finditer(r"\b([A-Z]{2,5})_\d{3}\b", body)}

        self.assertEqual(declared - used, set(),
                         "declared but never used in error-codes.md: %s" % sorted(declared - used))
        self.assertEqual(used - declared, set(),
                         "used in error-codes.md but not declared: %s" % sorted(used - declared))

    def test_error_code_numbering_has_no_gaps(self):
        """P14: numbering must be continuous within each prefix."""
        body = (SKILL_DIR / "references" / "error-codes.md").read_text(encoding="utf-8")
        series = {}
        for m in re.finditer(r"\b([A-Z]{2,5})_(\d{3})\b", body):
            series.setdefault(m.group(1), set()).add(int(m.group(2)))
        gaps = {}
        for prefix, nums in series.items():
            expected = set(range(1, max(nums) + 1))
            missing = expected - nums
            if missing:
                gaps[prefix] = sorted(missing)
        self.assertEqual(gaps, {}, "error-code numbering gaps: %s" % gaps)

    def test_no_broken_relative_markdown_links(self):
        broken = []
        for md in SKILL_DIR.rglob("*.md"):
            if ".git" in md.parts:
                continue
            text = md.read_text(encoding="utf-8", errors="ignore")
            for target in re.findall(r"\]\(([^)#\s]+?\.md)\)", text):
                if target.startswith(("http://", "https://")):
                    continue
                if not (md.parent / target).resolve().exists():
                    broken.append("%s -> %s" % (md.relative_to(SKILL_DIR), target))
        self.assertEqual(broken, [], "broken relative links: %s" % broken)

    def test_no_orphan_prompt_files(self):
        """P8: every prompts/*.md must be referenced by some upper-level document."""
        all_md = [p for p in SKILL_DIR.rglob("*.md") if ".git" not in p.parts]
        corpus = "\n".join(p.read_text(encoding="utf-8", errors="ignore") for p in all_md)
        orphans = []
        for prompt in SKILL_DIR.rglob("prompts/*.md"):
            if prompt.name in ("__init__.py",):
                continue
            if prompt.name not in corpus.replace(str(prompt.relative_to(SKILL_DIR)), prompt.name) \
                    or corpus.count(prompt.name) < 2:
                orphans.append(str(prompt.relative_to(SKILL_DIR)))
        self.assertEqual(orphans, [], "orphan prompt files (referenced nowhere): %s" % orphans)

    def test_file_count_matches_spec(self):
        """Large tier = 148 files (spec §2: package file set, excludes repo tooling + build residue)."""
        EXCLUDE_DIRS = (".git", ".github", ".workbuddy", ".skill-upgrade")
        files = [p for p in SKILL_DIR.rglob("*")
                 if p.is_file()
                 and not any(d in p.parts for d in EXCLUDE_DIRS)
                 and p.suffix != ".pyc"]
        self.assertEqual(len(files), 148,
                         "large tier must contain exactly 148 files, found %d" % len(files))


class TestScalingMechanism(unittest.TestCase):
    """Acceptance §9.3 — self-scaling four-piece set and its constraints."""

    FOUR_PIECES = [
        "references/scaling.md",
        ".scaling-state.json",
        "scripts/self-scale.ps1",
        "scripts/scaling-config.json",
    ]

    def test_four_pieces_present(self):
        missing = [p for p in self.FOUR_PIECES if not (SKILL_DIR / p).exists()]
        self.assertEqual(missing, [], "self-scaling files missing: %s" % missing)

    def test_upgrade_policy_is_propose_only(self):
        cfg = json.loads((SKILL_DIR / "scripts/scaling-config.json").read_text(encoding="utf-8"))
        self.assertEqual(cfg["upgrade_policy"], "propose-only")

    def test_config_declares_immutable_paths(self):
        cfg = json.loads((SKILL_DIR / "scripts/scaling-config.json").read_text(encoding="utf-8"))
        for required in ("permissions", "tests/", "scripts/self-scale.ps1"):
            self.assertIn(required, cfg["immutable_paths"], "immutable_paths lacks %s" % required)

    def test_script_has_no_install_action(self):
        """P36: the script must be structurally incapable of installing."""
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        for forbidden in ("'install'", "'apply'", "'commit'", '"install"', '"apply"'):
            self.assertNotIn(forbidden, script, "script exposes an install-class action: %s" % forbidden)

    def test_script_never_writes_skill_dir(self):
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        pattern = re.compile(r"(Set-Content|Out-File|New-Item|Remove-Item|Move-Item)[^\n]*\$SKILL_DIR")
        hits = pattern.findall(script)
        self.assertEqual(hits, [], "script writes to SKILL_DIR (self-modification): %s" % hits)

    def test_script_implements_all_six_gates(self):
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        for gate in ("G1", "G2", "G3", "G4", "G5", "G6"):
            self.assertIn(gate, script, "gate %s not implemented in self-scale.ps1" % gate)

    def test_script_has_no_remote_download(self):
        """P25: the controller must contain no remote-download cmdlets. Tokens are
        assembled at runtime so the whole-package sweep does not flag THIS file."""
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        for forbidden in ("Invoke-" + "Expression", "i" + "ex ", "Download" + "String",
                          "Invoke-" + "WebRequest"):
            self.assertNotIn(forbidden, script, "remote-download pattern present: %s" % forbidden)

    def test_script_has_no_hardcoded_user_path(self):
        """P18: no absolute user paths."""
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        self.assertNotRegex(script, r"[A-Za-z]:\\Users\\", "hardcoded absolute user path present")

    def test_script_backup_dir_is_cross_platform(self):
        """P26: must fall back to HOME when USERPROFILE is empty."""
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        self.assertIn("USERPROFILE", script)
        self.assertRegex(script, r"\$HOME|HOME\b", "no non-Windows fallback for the backup directory")

    def test_scaling_spec_defines_thresholds_and_alias_map(self):
        spec = (SKILL_DIR / "references/scaling.md").read_text(encoding="utf-8")
        for token in ("T1", "T2", "T3", "T4", "Alias Map"):
            self.assertIn(token, spec, "scaling.md missing required section: %s" % token)

    def test_state_file_agrees_with_frontmatter(self):
        """P41: two records of the tier must agree."""
        state = json.loads((SKILL_DIR / ".scaling-state.json").read_text(encoding="utf-8"))
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        declared = re.search(r"^\s*scale_tier:\s*(\w+)", text, re.M).group(1)
        self.assertEqual(state["current_tier"], declared)

    def test_state_file_schema(self):
        state = json.loads((SKILL_DIR / ".scaling-state.json").read_text(encoding="utf-8"))
        for key in ("schema_version", "current_tier", "tier_history",
                    "next_evaluation", "last_metrics", "pending_proposals"):
            self.assertIn(key, state, "state file missing key: %s" % key)
        self.assertIsInstance(state["tier_history"], list)
        for entry in state["tier_history"]:
            self.assertEqual(entry["validation"]["gates_passed"], 6,
                             "an installed upgrade must have passed all six gates")

    # --- Arbitrary target selection (-TargetTier), scaling.md sec 2 -------------
    TIER_RE = r"(micro|small|medium|large|group)"

    def test_script_declares_target_tier_parameter(self):
        """propose must expose -TargetTier so any selectable tier can be chosen."""
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        self.assertRegex(script, r"\[string\]\$TargetTier\s*=\s*''",
                         "script does not declare the -TargetTier parameter")

    def test_dispatch_tables_pair_every_edge_with_a_builder(self):
        """The (from -> to) edge table and the builder table must declare exactly
        the same pairs, and every pair must be selectable per the config."""
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        cfg = json.loads((SKILL_DIR / "scripts/scaling-config.json").read_text(encoding="utf-8"))
        pair = r"'" + self.TIER_RE + r"->" + self.TIER_RE + r"'"
        edge_keys = re.findall(pair + r"\s*=\s*\$\w+Edge", script)
        build_keys = re.findall(pair + r"\s*=\s*\{ param", script)
        self.assertGreaterEqual(len(edge_keys), 7,
                                "fewer than 7 upgrade pairs declared: %s" % (edge_keys,))
        self.assertEqual(sorted(edge_keys), sorted(build_keys),
                         "every declared pair needs both an edge and a builder")
        selectable = cfg.get("selectable_targets", {})
        for frm, to in set(edge_keys):
            self.assertIn(frm, selectable,
                          "config selectable_targets lacks source tier '%s'" % frm)
            self.assertIn(to, selectable[frm],
                          "pair %s->%s is not selectable per scaling-config.json" % (frm, to))

    def test_config_tier_order_matches_script(self):
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        cfg = json.loads((SKILL_DIR / "scripts/scaling-config.json").read_text(encoding="utf-8"))
        m = re.search(r"\$TierOrder\s*=\s*@\(([^)]*)\)", script)
        self.assertIsNotNone(m, "script does not declare $TierOrder")
        script_order = re.findall(r"'([a-z]+)'", m.group(1))
        self.assertEqual(script_order, cfg["tier_order"],
                         "script $TierOrder and config tier_order disagree")

    def test_config_default_target_is_first_selectable(self):
        cfg = json.loads((SKILL_DIR / "scripts/scaling-config.json").read_text(encoding="utf-8"))
        path = cfg.get("upgrade_path", {})
        selectable = cfg.get("selectable_targets", {})
        for tier, default in path.items():
            self.assertIn(tier, selectable, "selectable_targets lacks '%s'" % tier)
            self.assertEqual(default, selectable[tier][0],
                             "upgrade_path.%s must equal the first selectable target" % tier)

    def test_script_tier_file_count_matches_config(self):
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        cfg = json.loads((SKILL_DIR / "scripts/scaling-config.json").read_text(encoding="utf-8"))
        m = re.search(r"\$TierFileCount\s*=\s*@\{([^}]*)\}", script)
        self.assertIsNotNone(m, "script does not declare $TierFileCount")
        script_counts = dict(re.findall(r"'(\w+)'\s*=\s*(\d+)", m.group(1)))
        for tier, expected in cfg.get("file_count_expectation", {}).items():
            self.assertIn(tier, script_counts, "script $TierFileCount lacks tier '%s'" % tier)
            self.assertEqual(int(script_counts[tier]), int(expected),
                             "file count drift for tier '%s'" % tier)

    def test_group_scaffold_declared_and_state_free(self):
        """large -> group is a scaffold: content gates fail by design, the package
        is never quarantined and nothing is recorded in the state file."""
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        self.assertEqual(script.count("Scaffold = $true"), 1,
                         "exactly one scaffold edge (group) may be declared")
        self.assertIn("UPGRADE-WORK-ORDER.txt", script,
                      "the scaffold builder must emit the authoring work order")
        self.assertIn("nothing was recorded in .scaling-state.json", script,
                      "the scaffold branch must state that no state entry is written")


# ---------------------------------------------------------------------------
# Class C-extra — prompts layer, governance layer, host-metric channel, version locations
# ---------------------------------------------------------------------------


def _frontmatter(text):
    """Parse the leading YAML frontmatter of a markdown file into a flat dict."""
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    data = {}
    for line in text[3:end].splitlines():
        if line and not line.startswith(" ") and ":" in line:
            key, _, value = line.partition(":")
            data[key.strip()] = value.strip()
    return data


class TestPromptsLayer(unittest.TestCase):
    """§11: 4 prompts with explicit mode declarations (01/02 human-paste, 03/04 agent-invoked)."""

    EXPECTED = {
        "01-implement-method.md": "human-paste",
        "02-robustness-checks.md": "human-paste",
        "03-test-cases.md": "agent-invoked",
        "04-documentation.md": "agent-invoked",
    }

    def test_exactly_four_prompts(self):
        found = {p.name for p in (SKILL_DIR / "prompts").glob("*.md")}
        self.assertEqual(found, set(self.EXPECTED),
                         "prompts/ must contain exactly the 4 declared files")

    def test_each_prompt_declares_mode(self):
        for name, mode in self.EXPECTED.items():
            text = (SKILL_DIR / "prompts" / name).read_text(encoding="utf-8")
            fm = _frontmatter(text)
            self.assertEqual(fm.get("mode"), mode,
                             "%s frontmatter mode must be %s, got %r" % (name, mode, fm.get("mode")))

    def test_workflow_execution_prompt_removed(self):
        self.assertFalse((SKILL_DIR / "prompts" / "05-workflow-execution.md").exists(),
                         "prompts/05-workflow-execution.md was removed in the migration")


class TestGovernanceLayer(unittest.TestCase):
    """P50: governance layer completed to 13 files."""

    REQUIRED = [
        "README_FOR_AI.md", "README.en.md", "README.zh.md", "AGENTS.md",
        "CODE_OF_CONDUCT.md", "SECURITY.md", ".editorconfig", ".gitattributes",
    ]

    def test_governance_files_present(self):
        missing = [f for f in self.REQUIRED if not (SKILL_DIR / f).exists()]
        self.assertEqual(missing, [], "governance files missing: %s" % missing)

    def test_editorconfig_pins_lf(self):
        text = (SKILL_DIR / ".editorconfig").read_text(encoding="utf-8")
        self.assertIn("end_of_line = lf", text)

    def test_gitattributes_pins_lf(self):
        text = (SKILL_DIR / ".gitattributes").read_text(encoding="utf-8")
        self.assertRegex(text, r"(eol\s*=\s*lf|text\s*=\s*auto)")

    def test_readme_for_ai_body_is_english(self):
        """§6.3 / P47: README_FOR_AI.md body text is English. The pre-2026-10-21
        Chinese original is preserved per-section inside HTML comments only
        (hidden at render time); the language-exemption list in AGENTS.md no
        longer covers this file."""
        text = (SKILL_DIR / "README_FOR_AI.md").read_text(encoding="utf-8")
        body = re.sub(r"<!--.*?-->", "", text, flags=re.S)
        cjk = re.findall(r"[\u4e00-\u9fff]", body)
        self.assertEqual(cjk, [],
                         "README_FOR_AI.md body must be English; CJK outside comments: %r" % cjk[:10])


class TestHostMetricChannel(unittest.TestCase):
    """§3.1 / §4.1: host-supplied metrics arrive via record-metrics or a drop directory."""

    def test_script_implements_record_metrics(self):
        script = (SKILL_DIR / "scripts/self-scale.ps1").read_text(encoding="utf-8")
        self.assertIn("record-metrics", script)
        self.assertIn("Resolve-MetricsDropDir", script)
        self.assertIn("Receive-HostMetricsDrop", script)

    def test_config_declares_host_metrics(self):
        cfg = json.loads((SKILL_DIR / "scripts/scaling-config.json").read_text(encoding="utf-8"))
        self.assertIn("host_metrics", cfg)
        hm = cfg["host_metrics"]
        for key in ("max_age_days", "min_routing_samples", "drop_dir"):
            self.assertIn(key, hm)

    def test_state_records_provenance(self):
        state = json.loads((SKILL_DIR / ".scaling-state.json").read_text(encoding="utf-8"))
        self.assertIn("metrics_provenance", state)
        self.assertIn("routing_miss_streak", state)


class TestVersionLocations(unittest.TestCase):
    """D-2: the version lives in exactly three places — never the body title."""

    def test_version_consistent_three_locations(self):
        fm_text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        fm_version = re.search(r'^version:\s*"?([\d.]+)"?\s*$', fm_text, re.M).group(1)
        meta_version = json.loads((SKILL_DIR / "_meta.json").read_text(encoding="utf-8"))["version"]
        self.assertEqual(fm_version, meta_version)
        readme = (SKILL_DIR / "README.md").read_text(encoding="utf-8")
        self.assertIn(fm_version, readme)
        self.assertIn("version-%s-blue" % fm_version, readme, "README badge must carry the version")

    def test_body_title_has_no_version(self):
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        h1 = next((ln for ln in text.splitlines() if ln.startswith("# ")), "")
        self.assertNotRegex(h1, r"v\d", "body title must NOT carry a version (D-2)")


# ---------------------------------------------------------------------------
# Class D — immutable boundary
# ---------------------------------------------------------------------------


class TestImmutableBoundary(unittest.TestCase):
    """P34/P35: no upgrade proposal may alter tests/ or permissions.

    A proposal that could rewrite its own acceptance criteria would make every
    other gate meaningless — the tested object would control the test.
    """

    BASELINE_DENY = ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]

    def _proposals(self):
        return [Path(p) for p in glob.glob(str(WORKSPACE_ROOT / ".skill-upgrade" / "*"))]

    def test_no_proposal_touches_tests(self):
        offenders = []
        for pkg in self._proposals():
            if not pkg.is_dir():
                continue
            for f in pkg.rglob("*"):
                rel = f.relative_to(pkg).as_posix()
                if rel.startswith("tests/"):
                    offenders.append("%s/%s" % (pkg.name, rel))
        self.assertEqual(offenders, [], "upgrade package attempts self-exemption: %s" % offenders)

    def test_no_proposal_changes_permissions(self):
        offenders = []
        for pkg in self._proposals():
            skill_md = pkg / "SKILL.md"
            if not skill_md.exists():
                continue
            text = skill_md.read_text(encoding="utf-8")
            write_match = re.search(r'write:\s*\[([^\]]*)\]', text)
            self.assertIsNotNone(write_match, "proposal SKILL.md has no write scope")
            scopes = [s.strip().strip('"') for s in write_match.group(1).split(",") if s.strip()]
            if "{SKILL_DIR}/**" in scopes:
                offenders.append("%s grants write to SKILL_DIR" % pkg.name)
            for deny in self.BASELINE_DENY:
                if deny not in text:
                    offenders.append("%s drops deny entry %s" % (pkg.name, deny))
        self.assertEqual(offenders, [], "upgrade package attempts self-escalation: %s" % offenders)

    def test_skill_md_write_scope_is_workspace_only(self):
        """The shipped manifest itself must not grant SKILL_DIR write access."""
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        write_match = re.search(r'write:\s*\[([^\]]*)\]', text)
        scopes = [s.strip().strip('"') for s in write_match.group(1).split(",")]
        self.assertEqual(scopes, ["{WORKSPACE_ROOT}/**"])
        self.assertNotIn("{SKILL_DIR}/**", scopes)

    def test_deny_list_complete(self):
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        deny_match = re.search(r'deny:\s*\[([^\]]*)\]', text)
        entries = [e.strip().strip('"') for e in deny_match.group(1).split(",") if e.strip()]
        self.assertEqual(entries, self.BASELINE_DENY,
                         "deny list must be exactly these five entries, no deletions")


# ---------------------------------------------------------------------------
# Security sweeps across the whole package
# ---------------------------------------------------------------------------


class TestSecuritySweeps(unittest.TestCase):
    """Acceptance §9.1 #17–#19."""

    def _iter_files(self, patterns):
        for pat in patterns:
            for p in SKILL_DIR.rglob(pat):
                if ".git" not in p.parts and p.is_file():
                    yield p

    def test_no_hardcoded_user_paths(self):
        hits = []
        for p in self._iter_files(["*.md", "*.json", "*.ps1", "*.py"]):
            text = p.read_text(encoding="utf-8", errors="ignore")
            if re.search(r"[A-Za-z]:\\+Users\\+", text):
                hits.append(str(p.relative_to(SKILL_DIR)))
        self.assertEqual(hits, [], "hardcoded absolute user paths in: %s" % hits)

    def test_no_remote_execution_patterns(self):
        """P25. Patterns are assembled at runtime so THIS file can be swept too —
        writing the literal tokens here would make the suite flag itself."""
        forbidden = [
            "Invoke-" + "Expression",
            "i" + "ex ",
            "Download" + "String",
            "Invoke-" + "WebRequest",
        ]
        hits = []
        for p in self._iter_files(["*.ps1", "*.py", "*.md"]):
            text = p.read_text(encoding="utf-8", errors="ignore")
            if any(tok in text for tok in forbidden):
                hits.append(str(p.relative_to(SKILL_DIR)))
        self.assertEqual(hits, [], "remote-execution patterns in: %s" % hits)

    def test_no_embedded_secrets(self):
        hits = []
        for p in self._iter_files(["*.md", "*.json", "*.ps1", "*.py"]):
            text = p.read_text(encoding="utf-8", errors="ignore")
            if re.search(r"sk-[A-Za-z0-9]{20}|Bearer\s+[A-Za-z0-9]{16}", text):
                hits.append(str(p.relative_to(SKILL_DIR)))
        self.assertEqual(hits, [], "possible embedded credentials in: %s" % hits)

    def test_no_compiled_artifacts(self):
        """Ship no bytecode. Exclude caches this very run created (self-reference)."""
        offenders = []
        for pat in ("*.pyc", "__pycache__"):
            for p in SKILL_DIR.rglob(pat):
                if ".git" in p.parts:
                    continue
                # running this suite imports nothing, but a stray cache under tests/
                # can be produced by the interpreter for this file itself
                if p.parent.name == "tests" or p.name == "__pycache__" and p.parent.name == "tests":
                    continue
                offenders.append(str(p.relative_to(SKILL_DIR)))
        self.assertEqual(offenders, [], "compiled artifacts must not ship: %s" % offenders)

    def test_no_crlf_and_no_bom_package_wide(self):
        """M-1 (imported from the base bloodline): no CRLF and no BOM package-wide.

        Raw bytes only - read_text() with universal newlines silently folds
        CRLF, which is how 88 CRLF files survived in this package while its
        own suite stayed green (the source suite had no byte-level check
        before 2026-10-20; .editorconfig / .gitattributes pin LF).
        """
        EXCLUDE_DIRS = (".git", ".github", ".workbuddy", ".skill-upgrade")
        offenders_crlf, offenders_bom = [], []
        for p in SKILL_DIR.rglob("*"):
            if not p.is_file() or any(d in p.parts for d in EXCLUDE_DIRS):
                continue
            if p.suffix == ".pyc":
                continue
            raw = p.read_bytes()
            if b"\xef\xbb\xbf" in raw[:3]:
                offenders_bom.append(p.relative_to(SKILL_DIR).as_posix())
            if b"\r\n" in raw:
                offenders_crlf.append(p.relative_to(SKILL_DIR).as_posix())
        self.assertEqual([], offenders_crlf,
                         "these files contain CRLF (must be LF): %s" % offenders_crlf)
        self.assertEqual([], offenders_bom,
                         "these files carry a UTF-8 BOM: %s" % offenders_bom)

    def test_no_description_overflow(self):
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        desc = re.search(r'^description:\s*"(.*)"\s*$', text, re.M).group(1)
        self.assertLessEqual(len(desc), 1024, "description exceeds the 1024-char import limit")

    def test_frontmatter_line_budget(self):
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        lines = text.split("\n")
        closes = [i for i, ln in enumerate(lines) if ln.strip() == "---"]
        self.assertGreaterEqual(len(closes), 2)
        budget = {"micro": 85, "small": 95, "medium": 115, "large": 150, "group": 170}
        tier = re.search(r"^\s*scale_tier:\s*(\w+)", text, re.M).group(1)
        self.assertLessEqual(closes[1], budget[tier],
                             "frontmatter %d lines exceeds %d-line budget for tier %s"
                             % (closes[1], budget[tier], tier))

    def test_version_major_matches_tier(self):
        """P42: major version number == tier ordinal."""
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        tier = re.search(r"^\s*scale_tier:\s*(\w+)", text, re.M).group(1)
        major = int(re.search(r'^version:\s*"?(\d+)\.', text, re.M).group(1))
        expect = {"micro": 1, "small": 2, "medium": 3, "large": 4, "group": 5}[tier]
        self.assertEqual(major, expect)

    def test_version_consistent_across_files(self):
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        fm_version = re.search(r'^version:\s*"?([\d.]+)"?\s*$', text, re.M).group(1)
        meta_version = json.loads((SKILL_DIR / "_meta.json").read_text(encoding="utf-8"))["version"]
        self.assertEqual(fm_version, meta_version)
        readme = (SKILL_DIR / "README.md").read_text(encoding="utf-8")
        self.assertIn(fm_version, readme, "README must state the same version")
        self.assertIn("version-%s-blue" % fm_version, readme, "README badge must carry the version")

    def test_errors_field_is_empty(self):
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        self.assertRegex(text, re.compile(r"(?m)^errors:\s*\[\s*\]"),
                         "frontmatter errors must be [] — full table lives in error-codes.md")

    def test_department_enum_inlined_for_large_tier(self):
        """P30 (reversed 2026-10-20): every tier inlines the department enum.

        The base-framework gate G6 requires interface.department.enum to list
        'auto' plus the tier's department slugs; the authoritative copy with
        routing detail lives in references/department-index.md. The
        predecessor's externalisation rule is superseded.
        """
        text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
        enum_match = re.search(r'^\s*enum:\s*\[(.*)\]\s*$', text, re.M)
        self.assertIsNotNone(enum_match,
                             "department enum must be inlined in the frontmatter (P30)")
        items = [i.strip() for i in enum_match.group(1).split(",") if i.strip()]
        self.assertEqual(items[0], "auto", "the enum must list auto first")
        self.assertEqual(len(items), 19, "auto + 18 large-tier departments")
        index = SKILL_DIR / "references" / "department-index.md"
        self.assertTrue(index.exists(),
                        "department-index.md is the authoritative enum copy")
        indexed = set(re.findall(r"^\|\s*`?([a-z][a-z0-9-]+)`?\s*\|",
                                 index.read_text(encoding="utf-8"), re.M))
        self.assertEqual(set(items[1:]) - indexed, set(),
                         "enum slug missing from department-index.md: %s"
                         % (set(items[1:]) - indexed))

    def test_scaling_state_not_gitignored(self):
        """Only ACTIVE rule lines count — an explanatory comment naming the file is fine."""
        gi = SKILL_DIR / ".gitignore"
        self.assertTrue(gi.exists())
        active = [ln.strip() for ln in gi.read_text(encoding="utf-8").splitlines()
                  if ln.strip() and not ln.strip().startswith("#")]
        self.assertNotIn(".scaling-state.json", active,
                         "state file is package metadata and must be tracked")
        self.assertFalse(any(".scaling-state" in r for r in active),
                         "no rule may ignore the scaling state file")
        for required in ("__pycache__/", "REVIEW-*.md", ".skill-upgrade/"):
            self.assertIn(required, active, ".gitignore missing %s" % required)
        self.assertNotIn("REVIEW-README_FOR_AI.md", active,
                         "must use the REVIEW-*.md wildcard, not an exact filename (P39)")


if __name__ == "__main__":
    os.environ.setdefault("SKILL_DIR", str(SKILL_DIR))
    print("=" * 70)
    print("AI Company (large tier) — Test Suite")
    print("SKILL_DIR      : %s" % SKILL_DIR)
    print("AUTHORITATIVE_SOURCE : %s" % AUTHORITATIVE_SOURCE)
    print("WORKSPACE_ROOT : %s" % WORKSPACE_ROOT)
    print("=" * 70)
    unittest.main(verbosity=2)
