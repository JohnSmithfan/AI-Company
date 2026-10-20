# Robustness Checks Prompt — Quality & Visualization

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the quality-visualization department (domain: delivery) for robustness.

Read references/departments/quality-visualization/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

QUALITY GATES
 1. Does a failed gate have exactly two legal outcomes: remediate and re-enter, or escalate?
 2. Is any gate bypass path reachable without escalation? (It must not be.)
 3. Does a block name the failing criterion with its measured value, not just "failed"?
 4. Is CQO_ numbering continuous 001-005 with no gaps?

COVERAGE AND DORA
 5. Is coverage measured on changed paths, not only repo-wide?
 6. Is the 85 % acceptance threshold enforced, and is lowering it escalated?
 7. Are uncovered paths listed highest-risk-first?
 8. Is a DORA breach routed to the owning department and tracked over four deployments?

IDEMPOTENCY AND DOCUMENTATION
 9. Is idempotency verified by a double-invocation test before retry-safe marking?
10. Is any non-idempotent step blind-retried? (It must not be - fix or compensate.)
11. Is a documentation gap closed by a re-run of the structure-vs-disk check, not an assertion?

VISUALIZATION AND FUSION
12. Is any gap rendered as zero, or any trend claimed from fewer than 3 data points?
13. Is a contested field kept and marked, never silently resolved?
14. Does every fused value carry a confidence score?

OUTPUT
15. Is every visual labelled (template 4) and masked (template 9) before release?
16. Is every report traced (template 7, prefix "cqo") with a data-freshness statement?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
