# Implementation Prompt — Executive & Strategy

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the executive-strategy department (domain: governance) of the AI Company
skill at tier "large".

Read in order:
  references/departments/executive-strategy.md                  this department's D2 page
  references/departments/executive-strategy/department-spec.md  D3 depth + SOPs
  references/departments/executive-strategy/references/method-patterns.md
  references/error-codes.md                                     CEO_001 through CEO_008
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: executive-office (CEO_) and
strategy-planning (STP_). At large tier both report under the single prefix CEO_; STP_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Strategic decision-making          -> CEO_001 when data is missing
  3.2 Escalation and conflict resolution -> CEO_003 on contradiction, CEO_007 on timeout
  3.3 Crisis management                  -> CEO_005 on activation failure, CEO_008 on blacklist hit
  3.4 Strategic planning and OKRs        -> CEO_006 on misalignment
  3.5 Authorization maintenance          -> CEO_002 when outside the matrix
  3.6 Executive communication

Hard rules specific to this department:
  - A decision record must carry a review_date. Without it the record is incomplete.
  - Arbitration evaluates in fixed order: evidence quality > scope authority > reversibility.
    "Compromise" and "split the difference" are NOT valid outcomes - escalate on a full tie.
  - This department RECOMMENDS on a WFT-010 tier upgrade; it never approves and never installs.
    Approval belongs to a human. See department-spec.md SOP-CEO-05.
  - Every decision record and directive is masked (template 9) and labelled (template 4) before
    distribution, and carries a trace ID with prefix "ceo" (template 7).

Report: files created, the CEO_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
