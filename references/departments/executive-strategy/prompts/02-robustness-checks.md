# Robustness Checks Prompt — Executive & Strategy

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the executive-strategy department (domain: governance) for robustness.

Read references/departments/executive-strategy/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

DECISION INTEGRITY
 1. Does every decision record carry a review_date? A record without one is incomplete.
 2. Are all options recorded, including "do nothing"?
 3. Does each evidence item carry a source and an as-of timestamp?
 4. Is the authority basis (matrix row) recorded for every decision?

ARBITRATION
 5. Is the evaluation order fixed: evidence quality > scope authority > reversibility?
 6. Is "compromise" or "split the difference" rejected as an outcome? It must be.
 7. On a full tie, does the item escalate rather than default to one side?
 8. Is the losing position's rationale recorded, not just the verdict?

AUTHORITY
 9. Is an action outside the authorization matrix refused with CEO_002?
10. Does the refusal name the rung that holds authority, rather than just saying "denied"?
11. Is a tier-upgrade proposal only RECOMMENDED here, never approved? Approval is a human's.

CRISIS
12. Are closure criteria stated at declaration time, not at closure time?
13. Is the blacklist guard checked BEFORE the action, never after?
14. Is a crisis closed on verified criteria, not on the absence of further discussion?

OUTPUT
15. Is every decision record and directive masked (template 9 - all three classes) before distribution?
16. Is every one labelled (template 4) and traced (template 7, prefix "ceo")?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
