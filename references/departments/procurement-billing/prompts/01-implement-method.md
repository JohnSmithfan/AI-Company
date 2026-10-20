# Implementation Prompt — Procurement & Billing

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the procurement-billing department (domain: finance) of the AI Company
skill at tier "large".

Read in order:
  references/departments/procurement-billing.md                  this department's D2 page
  references/departments/procurement-billing/department-spec.md  D3 depth + SOPs
  references/departments/procurement-billing/references/method-patterns.md
  references/error-codes.md                                     PRC_001 through PRC_005
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: procurement-vendor (PRC_) and
billing-unit-economics (BIL_). At large tier both report under the single prefix PRC_; BIL_ is
retired here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Vendor evaluation       -> PRC_001 when dimensions are unscored
  3.2 Contract cost control   -> PRC_002 when an invoice diverges >2 % from the contract rate
  3.3 Purchase approvals      -> PRC_003 when a purchase exceeds the self-approval limit
  3.4 Metered billing         -> PRC_004 when billed units cannot be matched to metered usage
  3.5 Cost allocation         -> no PRC_ code; driver changes are recorded before effect
  3.6 Unit economics          -> PRC_005 when the unit-cost basis is not computable

Hard rules specific to this department:
  - An unscored dimension is either collected or covered by a recorded justified waiver.
  - The disputed portion is withheld only against a recorded dispute reference.
  - A contract enters legal-privacy review before signature - never auto-accept terms.
  - A tier-upgrade proposal is only RECOMMENDED here, never approved and never installed.
    Approval belongs to a human. See department-spec.md §2 (authority model).
  - Every purchase decision and invoice reconciliation is masked (template 9) and labelled
    (template 4) before distribution, and carries a trace ID with prefix "prc" (template 7).

Report: files created, the PRC_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
