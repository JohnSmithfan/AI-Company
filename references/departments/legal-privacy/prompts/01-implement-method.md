# Implementation Prompt — Legal & Privacy

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the legal-privacy department (domain: security) of the AI Company
skill at tier "large".

Read in order:
  references/departments/legal-privacy.md                  this department's D2 page
  references/departments/legal-privacy/department-spec.md  D3 depth + SOPs
  references/departments/legal-privacy/references/method-patterns.md
  references/error-codes.md                                     CLO_001 through CLO_006
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: legal-compliance (CLO_) and
privacy-data-protection (PRV_). At large tier both report under the single prefix CLO_; PRV_ is
retired here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Legal review and contract control   -> CLO_002 on an unreviewed instrument, CLO_001 on breach
  3.2 AIGC compliance                     -> CLO_003 on a missing label layer
  3.3 IP protection and DMCA takedown     -> CLO_004 on suspected protected material
  3.4 PII handling and privacy regulation -> CLO_001 on a flow with no legal basis
  3.5 Data residency and cross-border     -> CLO_006 on out-of-region data
  3.6 Ethics routing and records          -> CLO_005 on a trigger match

Hard rules specific to this department:
  - Signature without a review record is blocked - terms are never auto-accepted.
  - AIGC verification checks all three layers (label / metadata / watermark); a patched copy is
    not a remedy, re-emission is.
  - Encryption is not a cross-border transfer mechanism; the mechanism is cited by name.
  - This department owns the regulatory notification OBLIGATION; incident-identity owns the clock
    and the run. Never run a clock assessment inside the incident itself.
  - Every determination is masked (template 9) and labelled (template 4) before it leaves this
    department, and carries a trace ID with prefix "clo" (template 7).

Report: files created, the CLO_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
