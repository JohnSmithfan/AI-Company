---
mode: agent-invoked
id: 03-test-cases
title: Generate Test Cases
output_language: user-specified
harness_level: L3
---

> **Mode**: agent-invoked (executed by the agent runtime; not pasted by a human)
> **Purpose**: Generate a boundary-aware test-case suite for one method that was
> implemented to this skill's shared standard, and write it into the workspace.
>
> **Expected artifact path**:
> - `{WORKSPACE_ROOT}/tests/<METHOD_NAME>_test.py` - the generated test file
>   (standard library only; the file is created, never overwritten without an
>   explicit user confirmation)
>
> **Failure error codes**:
> - `CTO_003` - the generated suite assesses below Harness L3 (error handling,
>   retry, or idempotency coverage missing)
> - `CTO_002` - the generated suite fails the quality gate (a case has no
>   assertion, requires network access, or imports a non-standard library)
> - `SCL_006` - the generated artifact fails package validation
>
> **Referenced template anchors** (link, never inline - the authoritative code
> lives in `references/method-patterns.md`):
> - `references/method-patterns.md#3-1-validate_input_schema`
> - `references/method-patterns.md#3-5-retry_with_backoff`
> - `references/method-patterns.md#3-9-mask_sensitive_data`
>
> **Output language**: follow the language the user is currently using.

## Prompt

Inputs (supplied by the invoking agent):

- `<METHOD_NAME>` - the method to generate test cases for
- `<SPEC_SUMMARY>` - the method's contract: parameters, return value, and
  documented failure modes
- `<TARGET_LEVEL>` - required harness level (default L3)

Task: produce a test suite for `<METHOD_NAME>` covering, at minimum:

1. Normal path - at least one case per documented behavior.
2. Input validation - invalid inputs are rejected before any processing
   (see `references/method-patterns.md#3-1-validate_input_schema`).
3. Retry behavior - transient failures are retried and the retry limit is
   enforced (see `references/method-patterns.md#3-5-retry_with_backoff`).
4. PII masking - outputs replace email addresses, IPv4 addresses, and
   phone numbers in their common written forms with their placeholders (see
   `references/method-patterns.md#3-9-mask_sensitive_data`).
5. Boundary conditions - empty input, single element, maximum size, and
   off-by-one cases.

Requirements: standard library only; no network access; every test asserts
exactly one behavior and carries a docstring naming the covered dimension.

## Expected Output

A single test file at `{WORKSPACE_ROOT}/tests/<METHOD_NAME>_test.py`, plus a
summary stating: the dimensions covered, the number of cases per dimension,
and any dimension that cannot be tested, with the reason.

## Self-Check Checklist

- [ ] The artifact lands at the expected path under `{WORKSPACE_ROOT}/tests/`.
- [ ] No case requires network access or non-standard libraries.
- [ ] Every dimension above has at least one case or a stated reason.
- [ ] Any generation failure is reported with the error codes listed above.