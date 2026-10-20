# Robustness Checks Prompt — Risk & Audit

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the risk-audit department (domain: finance) for robustness.

Read references/departments/risk-audit/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

FAIR QUANTIFICATION
 1. Are all four FAIR inputs present before a risk decision is taken?
 2. On a missing input, is the decision refused with CRO_003 rather than taken on partial FAIR?
 3. Does every estimate carry a stated confidence, never presented as a measurement?

BREAKERS AND THRESHOLDS
 4. Is the breaker state confirmed OPEN before the offending flow is stopped (CRO_002)?
 5. Does the breaker move to HALF_OPEN only after the cool-down, with probe traffic?
 6. Does every breaker-open incident carry a recorded owner and a review date?
 7. Is a threshold breach re-scored with current data before the mitigation is applied (CRO_001)?

STAGE GATES AND REGISTER
 8. Is a gate failure reported with its measured value, never waived silently (CRO_004)?
 9. Is a register entry re-scored once it passes its review date by >30 days (CRO_005)?
10. Is residual risk above threshold escalated rather than accepted quietly?

AUDIT AND AUTHORITY
11. Is an audit request refused with CRO_006 when the evidence was never retained?
12. Is retention extended for the affected class after an evidence gap?
13. Is the gap reported to board-and-branch, not absorbed internally?
14. Is a tier-upgrade proposal only RECOMMENDED here, never approved? Approval is a human's.

OUTPUT
15. Is every risk record and audit report masked (template 9 - all three classes) before distribution?
16. Is every one labelled (template 4) and traced (template 7, prefix "cro")?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
