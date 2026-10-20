# Robustness Checks Prompt — Security & Resilience

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the security-resilience department (domain: security) for robustness.

Read references/departments/security-resilience/department-spec.md, then check each item.
Answer PASS / FAIL / N-A with one line of evidence. Read the implementation - do not assume.

BLOCKING RIGHT
 1. Can this department halt a production change? (It must be able to.)
 2. Can this department RESUME a change it halted? (It must NOT - that is engineering-tooling's.)
 3. Is the asymmetry enforced in code, or only documented?

THREAT MODELLING
 4. Is the model scoped by trust boundary, not by component?
 5. Is a boundary-crossing flow with no authentication flagged as a finding before STRIDE analysis?
 6. Is a threat closed by re-running the model, or by asserting a control was added? (Must re-run.)

CVSS
 7. Is every score recorded with its full vector string, not a bare number?
 8. Does a CVSS >= 9.0 finding open IRP_001 and notify board-and-branch?

SECURITY GATE
 9. Does a failed gate have exactly two outcomes: remediate, or an accepted-risk exception?
10. Is an exception WITHOUT an expiry date refused? (It must be.)
11. Can a gate be passed without a record? (It must not - a silent waiver is not a gate.)

CONTINUITY
12. Is a recovery test that was scheduled but not run reported as a GAP, not a pass?
13. Is recovery verified at outcome level, not on a command exit code?
14. Does the rollback in a recovery test follow copy-forward -> verify -> replace -> delete?

CONTROL EVIDENCE
15. Is an expired-evidence control marked unproven (CISO_006)?
16. Is an unproven control barred from being cited as mitigation?

BREAKER THRESHOLDS
17. Can a threshold be loosened above the policy ceiling without escalation? (It must not.)
18. Does repeated breaker tripping trigger a structural review rather than another adjustment?

Report each FAIL with file and line and a concrete fix. Items 2-3 are highest severity: a department
that can undo its own halt has a halt that can be quietly reversed.
```
