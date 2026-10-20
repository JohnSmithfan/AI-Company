# Robustness Checks Prompt — Platform & MLOps

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the platform-mlops department (domain: technology) for robustness.

Read references/departments/platform-mlops/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

FRAMEWORK STANDARDS
 1. Is a module that breaks the layering rule refused with FW_002, citing the rule?
 2. Is every manifest and payload schema-validated (template 1) before storage or forwarding?
 3. Does a failed registry lookup register or disambiguate - never silently default (FW_003)?

CI/CD
 4. Does a failed pipeline run raise FW_007 with the failing job named?
 5. Is a re-run started from the beginning, not from a flaky-failure assumption?
 6. Does the security control set run as CI/CD stages, fed by security-resilience?

HARNESS
 7. Are all six levels (L1-L6) defined with explicit constraint sets?
 8. Is an over-declared level refused with FW_006 - implement the constraint or declare lower?
 9. Does L6 certification require security-resilience sign-off?

MLOPS AND OBSERVABILITY
10. Is a disabled model (MDL_003) routed around, and re-enabled only through model-data?
11. Does a rate-limit response apply template 8 backoff before shifting to the fallback model?
12. Is an A/B readout run against a pre-registered success criterion?
13. Is WFT-010 stopped at phase 7 - nothing installed, human approval only?

OUTPUT
14. Is every pipeline run and event traced (template 7, prefix "fw") and labelled where generated
    (template 4)?
15. Is telemetry masked (template 9) before it leaves the platform boundary?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
