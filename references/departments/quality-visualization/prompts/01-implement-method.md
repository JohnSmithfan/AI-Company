# Implementation Prompt — Quality & Visualization

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the quality-visualization department (domain: delivery) of the AI Company
skill at tier "large".

Read in order:
  references/departments/quality-visualization.md                  this department's D2 page
  references/departments/quality-visualization/department-spec.md  D3 depth + SOPs
  references/departments/quality-visualization/references/method-patterns.md
  references/error-codes.md                                     CQO_001 through CQO_005
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: quality-assurance (CQO_) and
information-services (INFO_). At large tier both report under the single prefix CQO_; INFO_ is
retired here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Quality gate operation              -> CQO_001 on a failed gate check
  3.2 Test coverage                       -> CQO_003 below the 85 % acceptance threshold
  3.3 DORA metrics                        -> CQO_005 on a threshold crossing
  3.4 Idempotency verification            -> CQO_002 on divergent side effects
  3.5 Documentation completeness          -> CQO_004 on a missing or stale section
  3.6 Visualization and information services -> charts per visualization.md, fusion per data-integration.md

Hard rules specific to this department:
  - A failed gate has exactly two legal outcomes: remediate and re-enter, or escalate the block.
    Bypassing a gate silently is never one of them.
  - Coverage is measured on changed paths, highest-risk gaps first. Raising the 85 % acceptance
    threshold is this department's call; lowering it requires escalation.
  - Idempotency is verified by a double-invocation test before an operation is marked retry-safe.
    A non-idempotent step is fixed or compensated - never blind-retried.
  - Every visual is generated content: AIGC triple label (template 4), PII masking (template 9),
    source attribution and a data-freshness statement. A gap is never rendered as zero.
  - Multi-source fusion follows data-integration.md: within +/-2 % take the higher-reliability
    source and record the delta; beyond tolerance keep both and mark the field contested.

Report: files created, the CQO_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
