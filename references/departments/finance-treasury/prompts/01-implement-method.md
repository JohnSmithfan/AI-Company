# Implementation Prompt — Finance & Treasury

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the finance-treasury department (domain: finance) of the AI Company
skill at tier "large".

Read in order:
  references/departments/finance-treasury.md                  this department's D2 page
  references/departments/finance-treasury/department-spec.md  D3 depth + SOPs
  references/departments/finance-treasury/references/method-patterns.md
  references/error-codes.md                                     CFO_001 through CFO_006
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: financial-management (CFO_) and
treasury-budget (TRS_). At large tier both report under the single prefix CFO_; TRS_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Budget approval and variance      -> CFO_001 when spend exceeds the quarterly budget by >10 %
  3.2 Pricing models                    -> CFO_002 when the margin floor or elasticity band fails
  3.3 Financial analytics               -> CFO_003 when the source dataset is absent or stale >24 h
  3.4 Cash position and treasury        -> CFO_006 when sources cannot be reconciled
  3.5 Working capital targets           -> CFO_004 when DSO > 45 days or DPO < 30 days
  3.6 Capex policy                      -> CFO_005 when the approval is missing

Hard rules specific to this department:
  - A budget position is supplied as committed + encumbered + free; a single total is incomplete.
  - A price that fails the margin floor is revised or rejected - never shipped unpriced.
  - A financial report on a stale source publishes with an explicit data-freshness caveat.
  - A tier-upgrade proposal is only RECOMMENDED here, never approved and never installed.
    Approval belongs to a human. See department-spec.md §2 (authority model).
  - Every budget decision and report is masked (template 9) and labelled (template 4) before
    distribution, and carries a trace ID with prefix "cfo" (template 7).

Report: files created, the CFO_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
