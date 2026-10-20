---
mode: agent-invoked
id: 03-test-cases
title: Test Cases
output_language: user-specified
harness_level: L3
---

> **Mode**: agent-invoked (loaded automatically by an agent inside this skill)
> **Purpose**: Generate test cases for a capability, or review whether an existing test suite actually tests what it claims.
>
> **Expected output artifacts**: the generated test file, written under `{WORKSPACE_ROOT}` as `{WORKSPACE_ROOT}/<TEST_FILE_NAME>.py`; when the task is to extend the shipped suite, the reviewed suite content is delivered for `{SKILL_DIR}/tests/test-method-patterns.py` (this skill never writes into `{SKILL_DIR}` itself).
> **Failure error codes**: `SCL_005` (test self-modification attempted), `SCL_006` (upgrade package validation failed), `SCL_010` (function block conservation violated).
> **Referenced template anchors**: `method-patterns.md#3-1-validate_input_schema`, `method-patterns.md#3-2-sanitize_user_query`, `method-patterns.md#3-3-execute_safe_command`, `method-patterns.md#3-4-format_output_json`, `method-patterns.md#3-5-retry_with_backoff`, `method-patterns.md#3-6-read_reference_file`, `method-patterns.md#3-7-generate_trace_id`, `method-patterns.md#3-8-check_rate_limit`, `method-patterns.md#3-9-mask_sensitive_data`, `method-patterns.md#3-10-build_prompt_from_template`.
>
> **Output language**: follow the language you are currently using in this conversation.

## Prompt

(The block below is copied as a whole)

```text
You are writing test cases for a capability in the AI Company skill (large tier).

Read first:
  {SKILL_DIR}/references/method-patterns.md       the 10 shared templates and their contracts - the templates' single authoritative source
  {SKILL_DIR}/references/exec/error-recovery.md   failure modes and recovery bounds
  {SKILL_DIR}/references/data/schema-security.md  validation and injection controls
  {SKILL_DIR}/tests/test-method-patterns.py       the existing suite structure (four classes A-D)

Target: <describe the function, template or workflow phase under test>

Generate test cases in these four classes. Every class is mandatory.

CLASS A - BEHAVIOUR
  For each function under test, cover:
   - the happy path with representative input
   - each documented boundary (empty, maximum, one past maximum)
   - each rejection path, asserting the specific error code returned
   - type confusion (wrong type supplied where another is declared)
   - idempotency where claimed (run twice, assert identical effects)

CLASS B - SOURCE INTEGRITY
  Assert that the authoritative source file exists and contains what it must:
   - the file path is real
   - every expected definition appears in it
   - contract literals appear (for masking: EMAIL, IP and PHONE placeholders)
  These tests read the real source. They never inline a copy of it.

CLASS C - STRUCTURAL CONSISTENCY
  Assert package-level invariants:
   - department count on disk == metadata.department_count (18 at large)
   - function-block total == the tier expectation (18 at large)
   - no department subdirectory contains a copy of the root manifest
   - rows in {SKILL_DIR}/references/department-index.md and disk directories match bidirectionally
   - error-code numbering has no gaps within any prefix
   - no broken relative markdown links
   - file count == the tier specification (148 files at large)

CLASS D - IMMUTABLE BOUNDARY
  Assert that nothing in the self-scaling path can alter its own acceptance criteria:
   - no proposal package contains any path under {SKILL_DIR}/tests/
   - no proposal package changes the permissions block
   - the shipped manifest grants write only to {WORKSPACE_ROOT}
   - the deny list carries all five entries

For each test case report:
  name, class, what it asserts, the failure message it should produce, and which error code
  or invariant it guards.

Constraints:
  - Tests must be deterministic: no reliance on wall-clock timing beyond explicit sleeps with
    generous margins, no network, no ambient environment state
  - Use datetime.now(timezone.utc), never the deprecated utcnow()
  - Where a test needs a token that the security sweep forbids (for example a remote-execution
    cmdlet name), assemble the token at runtime by concatenation so the suite does not flag itself
  - Tests that must not pass while the package is incomplete should FAIL loudly with a clear
    message, not skip silently
```

## Variant: auditing an existing suite

```text
You are auditing a test suite for false confidence.

Read {SKILL_DIR}/tests/test-method-patterns.py and answer:

 1. Does the suite import or read the implementation it claims to test, or does it carry an
    inlined copy? Name the exact lines.
 2. For each assertion, what change to the SOURCE would make it fail? If the answer is "none",
    the assertion is decorative - list it.
 3. Does any test pass for a reason unrelated to what its name claims?
 4. Are there silent skips, bare excepts, or assertions on truthy values that could never be false?
 5. Does the suite verify its own preconditions (that the files it reads exist)?
 6. Run the suite. Report the actual counts, not the expected ones.

Report each finding with file and line, and a concrete replacement assertion.
```

## Notes

- **Class B is the reason this prompt exists.** A predecessor package's suite inlined its own copy of the 10 templates and never read `{SKILL_DIR}/references/method-patterns.md`, while its docstring claimed it tested that file. The authoritative source was missing an entire masking branch and the suite reported 19/19 green. A test that cannot see its subject cannot fail.
- **Class D guards a new risk class.** Once a package can propose changes to itself, the thing under test can rewrite the test. Raising the conservation expectation from 18 to 20 would hide a lost function; the only defence is asserting that no proposal may touch `{SKILL_DIR}/tests/` at all.
- **"Tests must fail loudly, not skip"** - during generation many structural tests cannot pass yet because files do not exist. A suite that skips those would report green on an empty package.

## Expected Output

The AI should return, in the language of the current conversation: (1) the test cases in the report format above - name, class, what it asserts, expected failure message, guarded error code or invariant - with all four classes A-D covered; (2) the generated test file written to `{WORKSPACE_ROOT}/<TEST_FILE_NAME>.py`; (3) in audit mode, each finding with file and line, a concrete replacement assertion, and the suite's actual run counts rather than the expected ones. The suite runs at Harness L3 minimum: error handling, retry and idempotency are present in what it produces.

## Self-Check Checklist

After the run, verify each item:

- [ ] All four classes A-D are present; every class is mandatory and none is empty.
- [ ] Class B tests read the real authoritative source; no inlined copy of any template exists in the suite.
- [ ] Masking tests assert all three placeholder classes: EMAIL, IP and PHONE.
- [ ] Class C assertions use the current tier figures: 18 departments, 18 function blocks, 148 files.
- [ ] Class D asserts the immutable boundary: no proposal touches `{SKILL_DIR}/tests/`, the permissions block is unchanged, write is limited to `{WORKSPACE_ROOT}`, and the deny list is complete.
- [ ] Every rejection-path test asserts a specific error code.
- [ ] Tests are deterministic: no network, no ambient environment state, no unbounded timing reliance.
- [ ] Timestamps use datetime.now(timezone.utc).
- [ ] Forbidden tokens are assembled at runtime by concatenation, never written literally.
- [ ] Incomplete-package tests fail loudly with a clear message rather than skipping.
- [ ] The suite file was written under `{WORKSPACE_ROOT}`, never into `{SKILL_DIR}`.
