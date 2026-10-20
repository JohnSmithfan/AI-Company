# Implementation Prompt — Delivery & Scheduling

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the delivery-scheduling department (domain: delivery) of the AI Company
skill at tier "large".

Read in order:
  references/departments/delivery-scheduling.md                  this department's D2 page
  references/departments/delivery-scheduling/department-spec.md  D3 depth + SOPs
  references/departments/delivery-scheduling/references/method-patterns.md
  references/error-codes.md                                     PMGR_001 through PMGR_005
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: project-management (PMGR_) and
localization-translation (TR_). At large tier both report under the single prefix PMGR_; TR_ is
retired here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Project scheduling and deadline ownership -> PMGR_001 on a missed deadline
  3.2 Sprint commitment management              -> PMGR_004 on under-delivery
  3.3 Ticket SLA and customer escalation        -> PMGR_003 when criteria are met
  3.4 Task decomposition                        -> PMGR_005 on blocking ambiguity
  3.5 Translation quality and cultural adaptation -> PMGR_003 on a customer-visible defect
  3.6 Language routing and work-item traceability -> PMGR_002 unlinked, COO_003 discretionary

Hard rules specific to this department:
  - An undecomposed task is never assigned. Route the blocking ambiguity back to the requester.
  - A work item is never left unlinked from an active OKR - link it or mark it discretionary,
    and route discretionary work to COO_003.
  - A missed deadline is reported with its remaining scope and re-baselined with the stakeholder.
    Quietly re-dating it is the failure mode this department exists to prevent.
  - An escalation gets an owner within 1 h. The timer, not the intention, is the control.
  - A translation below the quality bar is not published, and adaptation never drops the source
    meaning - conflicts escalate rather than being quietly rewritten.
  - Deployment windows are negotiated with engineering-tooling against committed schedules; a
    window conflict is resolved by priority class, never by deploying anyway.

Report: files created, the PMGR_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
