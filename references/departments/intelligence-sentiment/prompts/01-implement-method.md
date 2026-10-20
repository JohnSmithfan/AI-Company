# Implementation Prompt — Intelligence & Sentiment

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the intelligence-sentiment department (domain: growth) of the AI Company
skill at tier "large".

Read in order:
  references/departments/intelligence-sentiment.md                  this department's D2 page
  references/departments/intelligence-sentiment/department-spec.md  D3 depth + SOPs
  references/departments/intelligence-sentiment/references/method-patterns.md
  references/error-codes.md                                     INTEL_001 through INTEL_006
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: competitive-intelligence
(INTEL_) and sentiment-analysis (SNT_). At large tier both report under the single prefix
INTEL_; SNT_ is retired here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Collection (WFT-008 phase 1)         -> INTEL_001 when a run returns no usable items
  3.2 Processing and analysis (phases 2-3) -> INTEL_004 on low classification, INTEL_002 on low confidence
  3.3 SITREP production (phase 4)          -> INTEL_005 when the report misses its schedule
  3.4 Dissemination and feedback           -> subscription-list delivery; ratings updated in phase 6
  3.5 Sentiment collection and analysis    -> same code set as the intelligence cycle
  3.6 Source reliability register          -> INTEL_003 on verification failure, INTEL_006 on corruption

This department OWNS workflow WFT-008 Market Intelligence (Schedule weekly / Event competitor
signal, mode Auto, SLA 6 h). All other workflow mentions are participation only.

Hard rules specific to this department:
  - Every product carries its confidence score; the score is published, never omitted and
    never rounded up (INTEL_002).
  - A source that fails verification is downgraded and excluded until re-verified; a second
    failed collection run records it degraded (INTEL_001, INTEL_003).
  - A SITREP is issued on schedule even when incomplete - partial with gaps marked, re-issued
    in full later (INTEL_005). Late is a failure; silently incomplete is worse.
  - Classification rules come from security-resilience; this department re-classifies and
    records the exposure window (INTEL_004), it never reinterprets the policy.
  - Every product is labelled (template 4) and traced (template 7, prefix "intel"); masking
    (template 9) applies wherever sentiment sources carry personal data.

Report: files created, the INTEL_ codes you wired, and any responsibility whose SLA you could
not determine from the spec.
```
