# Robustness Checks Prompt — Marketing & Partnerships

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the marketing-partnerships department (domain: growth) for robustness.

Read references/departments/marketing-partnerships/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

BRAND AND CONTENT
 1. Is content checked against the recorded brand rules before publication?
 2. Is a post-publication divergence withdrawn, not quietly edited (CMO_001)?
 3. Does the withdrawal record name the divergent element?
 4. Does every published payload carry the AIGC label (template 4)?

GTM AND DATA
 5. Is a launch refused when a required component is missing and no deferral is recorded
    (CMO_005)?
 6. Does a GTM decision without market data proceed only when time-critical and only with
    an explicit caveat (CMO_002)?
 7. Is the decision re-taken once the dataset arrives?

PARTNERSHIPS AND NPS
 8. Is a partnership held unsigned while a conflict stands unresolved (CMO_003)?
 9. Is the conflict routed to legal-privacy for a determination rather than judged locally,
    with no signature before the ruling?
10. Is NPS reported with detractor segmentation and routed drivers (CMO_004)?
11. Is the NPS threshold escalated to executive-strategy rather than adjusted locally?

OUTPUT
12. Is published content traced (template 7, prefix "cmo"), and masked (template 9) where it
    carries personal data?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
