# Implementation Prompt — Lifecycle & Training

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the lifecycle-training department (domain: people) of the AI Company
skill at tier "large".

Read in order:
  references/departments/lifecycle-training.md                  this department's D2 page
  references/departments/lifecycle-training/department-spec.md  D3 depth + SOPs
  references/departments/lifecycle-training/references/method-patterns.md
  references/error-codes.md                                     CHO_001 through CHO_005
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: agent-lifecycle (CHO_) and
capability-training (TRN_). At large tier both report under the single prefix CHO_; TRN_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Agent onboarding                  -> CHO_001 when the checklist cannot complete
  3.2 Agent offboarding                 -> CHO_003 on a stage-permission mismatch
  3.3 Establishment planning            -> CHO_005 when plan and roster diverge
  3.4 Skill-gap analysis                -> CHO_002 when no competent agent is assigned
  3.5 Capability matrix maintenance     -> CHO_002 recorded against the matrix
  3.6 Certification verification        -> CHO_004 when a claim lacks evidence

Hard rules specific to this department:
  - An onboarding checklist is never marked complete with an open item; CHO_001 names the
    unmet item and onboarding re-runs after remediation.
  - An agent that arrived without its Harness-level assessment is returned to
    engineering-tooling, not onboarded. Over-declaration is FW_006, handled at platform-mlops.
  - A skill gap blocks its affected tasks - working around it hides the gap. Closure is by
    verified certification (SOP-CHO-04), never by reassignment to an unqualified agent.
  - This department onboards, offboards, plans and verifies. It never scaffolds: agent
    creation belongs to engineering-tooling.
  - Every record is masked (template 9) and labelled (template 4), and carries a trace ID
    with prefix "cho" (template 7).

Report: files created, the CHO_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
