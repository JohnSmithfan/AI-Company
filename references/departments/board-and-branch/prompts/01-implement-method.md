# Implementation Prompt — Board & Branch

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the board-and-branch department (domain: governance) of the AI Company
skill at tier "large".

Read in order:
  references/departments/board-and-branch.md                  this department's D2 page
  references/departments/board-and-branch/department-spec.md  D3 depth + SOPs
  references/departments/board-and-branch/references/method-patterns.md
  references/error-codes.md                                     BRD_001 through BRD_006
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: board-governance (BRD_) and
branch-management (BRN_). At large tier both report under the single prefix BRD_; BRN_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Escalation ladder (rungs 4-5)      -> BRD_004 on exhaustion
  3.2 Authorization matrix ratification  -> BRD_002 on an out-of-matrix attempt
  3.3 Shareholder reporting              -> BRD_003 on an overdue report
  3.4 Headquarters-branch model          -> BRD_006 on an out-of-scope branch action
  3.5 Branch lifecycle                   -> BRD_005 on unmet promotion criteria
  3.6 Remote communication and cross-border deployment -> BRD_001 on a missing quorum

Hard rules specific to this department:
  - A binding vote is never taken without quorum. Defer, notify absent members, re-convene
    within 48 h.
  - A tier upgrade is only RECOMMENDED here (WFT-010, co-owned with platform-mlops); it is never
    approved and never installed. Approval belongs to a human.
  - WFT-009 Branch Rollout is defined for numbering stability but reserved for group tier;
    a request for it here returns SCL_002.
  - Every matrix revision carries a rationale per changed row and an effective date; the prior
    version is superseded with a pointer, never deleted.
  - Every board record and minute is masked (template 9) and labelled (template 4) before
    distribution, and carries a trace ID with prefix "brd" (template 7).

Report: files created, the BRD_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
