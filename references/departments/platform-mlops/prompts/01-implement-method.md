# Implementation Prompt — Platform & MLOps

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the platform-mlops department (domain: technology) of the AI Company
skill at tier "large".

Read in order:
  references/departments/platform-mlops.md                  this department's D2 page
  references/departments/platform-mlops/department-spec.md  D3 depth + SOPs
  references/departments/platform-mlops/references/method-patterns.md
  references/error-codes.md                                     FW_001 through FW_007
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: platform-framework (FW_) and
mlops-observability (MLO_). At large tier both report under the single prefix FW_; MLO_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Framework standards and modularization -> FW_002 on a layering breach, FW_001 on a schema failure
  3.2 CI/CD pipeline operation               -> FW_007 on a failed run
  3.3 Harness level definitions (L1-L6)      -> FW_006 on over-declaration
  3.4 ADR process and scaffolding            -> FW_005 on generation failure, FW_003 on a registry miss
  3.5 Model health monitoring and A/B tests  -> MDL_003 fallback routing, MDL_005 backoff, FW_004 on pipeline failure
  3.6 Observability

Hard rules specific to this department:
  - Never over-declare a Harness level: implement the constraint or declare the lower level.
  - WFT-010 stops at phase 7. This department RECOMMENDS on a tier upgrade; it never approves and
    never installs. Approval belongs to a human. See department-spec.md SOP-FW-05.
  - A registry lookup never falls back to a default entry silently - register or disambiguate.
  - Every manifest and telemetry payload is schema-validated (template 1) before it is stored or
    forwarded, and every pipeline run and event carries a trace ID with prefix "fw" (template 7).

Report: files created, the FW_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
