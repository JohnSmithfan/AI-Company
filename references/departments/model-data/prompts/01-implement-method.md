# Implementation Prompt — Model & Data

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the model-data department (domain: technology) of the AI Company
skill at tier "large".

Read in order:
  references/departments/model-data.md                  this department's D2 page
  references/departments/model-data/department-spec.md  D3 depth + SOPs
  references/departments/model-data/references/method-patterns.md
  references/error-codes.md                                     MDL_001 through MDL_006 plus MDL_E007
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: model-management (MDL_) and
data-engineering (DTE_). At large tier both report under the single prefix MDL_; DTE_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Model registry operation          -> MDL_001 on an unknown id, MDL_002 on a missing config
  3.2 Calling policy and fallback chain -> MDL_003 on disabled, MDL_005 on rate limit, MDL_E007 on call failure
  3.3 Provider adapters                 -> MDL_006 on a contract breach
  3.4 Model governance and access       -> MDL_004 reports the variable name only
  3.5 Data pipelines and schemas        -> WFT-001 phases 1-5, FW_001 on a schema failure
  3.6 Multi-source fusion

Hard rules specific to this department:
  - Never invoke an unregistered endpoint; never report a key's value - the variable name only.
  - A disabled model is routed around here and re-enabled only through platform-mlops.
  - Call-time failures use the MDL_E sub-namespace (MDL_E007); configuration faults use
    MDL_001-006. The two are never mixed in one report.
  - Every fused record keeps its per-source provenance; a record whose provenance was dropped is
    quarantined, never published.
  - Every invocation and pipeline stage carries a trace ID with prefix "mdl" (template 7), and
    persisted payloads are masked (template 9) before storage.

Report: files created, the MDL_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
