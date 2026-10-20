# Implementation Prompt — Marketing & Partnerships

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the marketing-partnerships department (domain: growth) of the AI Company
skill at tier "large".

Read in order:
  references/departments/marketing-partnerships.md                  this department's D2 page
  references/departments/marketing-partnerships/department-spec.md  D3 depth + SOPs
  references/departments/marketing-partnerships/references/method-patterns.md
  references/error-codes.md                                     CMO_001 through CMO_005
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: marketing-brand (CMO_) and
partnerships-ecosystem (PTN_). At large tier both report under the single prefix CMO_; PTN_ is
retired here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Brand voice governance           -> CMO_001 on divergence from the recorded rules
  3.2 Content production and review   -> CMO_001 withdrawal on post-publication divergence
  3.3 GTM planning                    -> CMO_005 on missing components, CMO_002 on missing data
  3.4 NPS and voice-of-customer       -> CMO_004 below the committed threshold
  3.5 Partnership evaluation          -> CMO_003 on a conflicting commitment
  3.6 Ecosystem and channel management -> CMO_002 on data-free channel decisions

Hard rules specific to this department:
  - Brand conformance is checked BEFORE publication. A divergence found afterwards is a
    withdrawal (CMO_001), never a quiet edit.
  - A GTM decision without its market dataset proceeds only when time-critical and only with
    an explicit uncertainty caveat (CMO_002); it is re-decided once the dataset arrives.
  - No signature while a partnership conflict stands unresolved (CMO_003) - the determination
    comes from legal-privacy, and contract review is the CLO_002 route before signature.
  - NPS is reported with detractor segmentation; an unsegmented score is not a report (CMO_004).
    The threshold itself changes only at executive-strategy.
  - Every published payload carries the AIGC label (template 4) and a trace ID with prefix
    "cmo" (template 7); masking (template 9) applies where content carries personal data.

Report: files created, the CMO_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
