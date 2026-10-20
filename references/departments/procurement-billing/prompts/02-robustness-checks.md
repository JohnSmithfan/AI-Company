# Robustness Checks Prompt — Procurement & Billing

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the procurement-billing department (domain: finance) for robustness.

Read references/departments/procurement-billing/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

VENDOR AND CONTRACT
 1. Are all required evaluation dimensions scored before a procurement decision (PRC_001)?
 2. Is an unscored dimension either collected or covered by a recorded justified waiver?
 3. Is an invoice >2 % off the contracted rate disputed, with the delta withheld (PRC_002)?
 4. Is the invoice diffed against the contract schedule line by line, never in total?

PURCHASE APPROVALS AND BILLING
 5. Is a purchase above the self-approval limit halted and routed to the correct rung (PRC_003)?
 6. Is the policy exception recorded, not just the halt?
 7. Are billed units re-metered before a credit or supplemental invoice is issued (PRC_004)?
 8. Are unmatched units quarantined rather than written off?

UNIT ECONOMICS AND AUTHORITY
 9. Is a missing cost component sourced from finance-treasury before the decision (PRC_005)?
10. Is the decision deferred while the unit-cost basis remains unknown?
11. Is a contract held for legal-privacy review before signature?
12. Is a tier-upgrade proposal only RECOMMENDED here, never approved? Approval is a human's.

OUTPUT
13. Is every purchase decision and invoice reconciliation masked (template 9 - all three classes)?
14. Is every one labelled (template 4) and traced (template 7, prefix "prc")?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
