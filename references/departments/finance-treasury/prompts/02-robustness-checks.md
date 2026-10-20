# Robustness Checks Prompt — Finance & Treasury

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the finance-treasury department (domain: finance) for robustness.

Read references/departments/finance-treasury/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

BUDGET CONTROL
 1. Is a variance analysis produced before any spend beyond the quarterly ceiling is approved?
 2. Is the budget position supplied as committed + encumbered + free, never as a single total?
 3. Does a budget overrun freeze non-essential spend before the analysis is submitted (CFO_001)?

PRICING
 4. Is every price checked against the margin floor and the elasticity sanity band?
 5. Is a failing price revised or rejected, never shipped unpriced (CFO_002)?
 6. Are unit economics recomputed from the current cost basis, not from last quarter's?

ANALYTICS AND TREASURY
 7. Is a stale source (>24 h) published with an explicit data-freshness caveat (CFO_003)?
 8. Is the cash position reconciled across sources before publication (CFO_006)?
 9. Is the unreconciled delta quarantined rather than absorbed into the published total?

WORKING CAPITAL AND CAPEX
10. Is the receivables/payables ledger aged before DSO/DPO drift is explained (CFO_004)?
11. Is a capex halted when its approval is missing, and the exception recorded (CFO_005)?
12. Is a tier-upgrade proposal only RECOMMENDED here, never approved? Approval is a human's.

OUTPUT
13. Is every budget decision and report masked (template 9 - all three classes) before distribution?
14. Is every one labelled (template 4) and traced (template 7, prefix "cfo")?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
