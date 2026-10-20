# Implementation Prompt — Operations & Coordination

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the operations-coordination department (domain: governance) of the AI Company
skill at tier "large".

Read in order:
  references/departments/operations-coordination.md                  this department's D2 page
  references/departments/operations-coordination/department-spec.md  D3 depth + SOPs
  references/departments/operations-coordination/references/method-patterns.md
  references/error-codes.md                                     COO_001 through COO_006
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: operations-command (COO_) and
hq-coordination (HQ_). At large tier both report under the single prefix COO_; HQ_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 SLA management                    -> COO_001 on a 2-window breach
  3.2 Resource scheduling and allocation -> COO_002 on conflict, COO_004 on unsatisfied allocation
  3.3 PDCA process optimization         -> COO_003 on OKR divergence
  3.4 Cross-department coordination     -> COO_006 on a 4 h acknowledgement timeout
  3.5 Agent routing                     -> COO_002 on a contested agent, CEO_004 on a pipeline abort
  3.6 Message bus, knowledge sync, audit trail

Hard rules specific to this department:
  - A contradiction between departments is routed to executive-strategy (CEO_003). This department
    coordinates; it does not decide.
  - Resource conflicts are resolved by priority class (P1-P3), never by arrival order.
  - A deadlock is broken by pre-empting the lowest-priority holder; the pre-empted work is
    re-queued, never discarded.
  - A coordination request silent past 8 h escalates up the ladder - it is not re-sent forever.
  - Every routing decision, bus event and knowledge sync carries a trace ID with prefix "coo"
    (template 7); records are masked (template 9, all three classes) and labelled (template 4)
    before distribution.
  - WFT-003 containment runs Auto; disclosure runs Approve. Never collapse the two into one mode.

Report: files created, the COO_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
