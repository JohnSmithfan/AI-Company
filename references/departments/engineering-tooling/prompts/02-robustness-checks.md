# Robustness Checks Prompt — Engineering & Tooling

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the engineering-tooling department (domain: technology) for robustness.

Read references/departments/engineering-tooling/department-spec.md, then check each item.
Answer PASS / FAIL / N-A with one line of evidence. Read the implementation - do not assume.

COMMAND EXECUTION
 1. Is every command run through template 3 with a LIST of arguments?
 2. Is any shell string passed to execution? (It must not be - a string implies shell interpretation.)
 3. Is a timeout set on every command, with a hard ceiling?

DEPLOYMENT GATE
 4. Can a stage be skipped forward? (It must not - only halt or promote.)
 5. Does a failed stage roll back rather than retry in place?
 6. Is re-deployment blocked until the root cause is recorded, not just the symptom cleared?
 7. Is the full stage verified at OUTCOME level, or only on an exit code?

ROLLBACK
 8. Is the ordering copy-forward -> verify -> atomic-replace -> delete-old?
 9. Is there ANY path that deletes before a verified copy exists? (Flag as critical.)
10. Is the rollback plan tested, or merely documented? An untested plan is a hypothesis.

RETRY
11. Is retry applied only to idempotent stages? Name any non-idempotent stage that is retried.
12. Is the retry budget bounded (max 3, backoff capped at 30 s)?

HARNESS
13. Is the declared Harness level backed by the evidence in spec §3.B?
14. Is any level over-declared? (FW_006.)

AUTHORITY
15. Does this department ever resume a deployment that security-resilience halted? (It must not.)
16. Is a production operation grant-checked before execution (CTO_004)?

ERROR CODES
17. Is CTO_ numbering continuous 001-008 with no gaps?

Report each FAIL with file and line and a concrete fix. Items 8-9 are the highest severity:
delete-before-copy is the single most destructive pattern in this domain.
```
