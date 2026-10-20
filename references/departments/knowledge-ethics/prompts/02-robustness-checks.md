# Robustness Checks Prompt — Knowledge & Ethics

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the knowledge-ethics department (domain: people) for robustness.

Read references/departments/knowledge-ethics/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

KNOWLEDGE LIFECYCLE
 1. Does a distillation run that produces no usable item raise KNM_001 and retain the
    prior distilled state?
 2. Is consolidation run on the interval, and is a twice-overdue class raised as KNM_002?
 3. Is a retired item's successor pointer verified before the retirement is recorded
    (KNM_005)?
 4. Is Session memory never promoted to Knowledge without distillation?

ETHICS
 5. Does a pending review block the dependent action (KNM_003), regardless of urgency?
 6. Is the review outcome recorded with its conditions, not just pass/fail?
 7. On a confirmed violation (KNM_004), is the activity halted before any remediation
    begins?
 8. Is the violation reported to board-and-branch and recorded in the culture audit?

CULTURE AND CHANNEL
 9. Is every whistleblower report logged through the channel with an investigation opened?
10. Is a retaliation finding escalated to board-and-branch rather than handled locally?
11. Is an unrun culture audit treated as a failure, not a pass?

BOUNDARIES
12. Are retention limits and size bounds taken from legal-privacy, never set here?
13. Is raw PII masked (template 9) before any persistence, with no exception path?

OUTPUT
14. Is every distilled item and review record labelled (template 4) and traced
    (template 7, prefix "knm")?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
