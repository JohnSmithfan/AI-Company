# Implementation Prompt — Risk & Audit

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the risk-audit department (domain: finance) of the AI Company
skill at tier "large".

Read in order:
  references/departments/risk-audit.md                  this department's D2 page
  references/departments/risk-audit/department-spec.md  D3 depth + SOPs
  references/departments/risk-audit/references/method-patterns.md
  references/error-codes.md                                     CRO_001 through CRO_006
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: risk-management (CRO_) and
internal-audit (AUD_). At large tier both report under the single prefix CRO_; AUD_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 FAIR quantification                -> CRO_003 when any of the four inputs is missing
  3.2 Circuit breakers                   -> CRO_002 on a threshold crossing
  3.3 Risk thresholds                    -> CRO_001 when a scored risk crosses its threshold
  3.4 Stage gates                        -> CRO_004 on a failed gate
  3.5 Internal audit                     -> CRO_006 when retained evidence cannot satisfy a request
  3.6 Evidence retention and compliance  -> CRO_005 when a register entry goes stale

Hard rules specific to this department:
  - Four FAIR inputs or no decision; an estimate is permitted only with a stated confidence.
  - Gates are never waived silently - report the failing criterion with its measured value.
  - A breaker left OPEN carries a recorded owner and a review date, always.
  - A tier-upgrade proposal is only RECOMMENDED here, never approved and never installed.
    Approval belongs to a human. See department-spec.md §2 (authority model).
  - Every risk record and audit report is masked (template 9) and labelled (template 4) before
    distribution, and carries a trace ID with prefix "cro" (template 7).

Report: files created, the CRO_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
