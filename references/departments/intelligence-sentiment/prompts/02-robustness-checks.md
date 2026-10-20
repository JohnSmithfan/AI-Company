# Robustness Checks Prompt — Intelligence & Sentiment

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the intelligence-sentiment department (domain: growth) for robustness.

Read references/departments/intelligence-sentiment/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

CYCLE AND CONFIDENCE
 1. Does every WFT-008 run complete all six phases, or record where and why it stopped?
 2. Does a collection run that returns nothing raise INTEL_001 and re-run with a broader
    window before any source is recorded degraded?
 3. Is a source recorded degraded only after a second failure, never the first?
 4. Is every product's confidence score published, never omitted or rounded up (INTEL_002)?

REGISTER AND CLASSIFICATION
 5. Is an unverifiable source downgraded and excluded until re-verified (INTEL_003)?
 6. Is a register integrity failure restored from the last consistent snapshot with every
    entry touched since re-verified (INTEL_006)?
 7. Is material handled below its classification re-classified with the exposure window
    recorded (INTEL_004), and the rules taken from security-resilience?

SITREP AND SENTIMENT
 8. Is a SITREP issued on schedule as a partial with gaps marked when inputs are missing
    (INTEL_005)?
 9. Is the full SITREP re-issued once inputs arrive, with the partial pointing to it?
10. Is dissemination limited to the subscription list, verbatim?
11. Is sentiment collection on named individuals routed to legal-privacy before collection
    starts?

OUTPUT
12. Is every product labelled (template 4) and traced (template 7, prefix "intel"), and
    masked (template 9) where sources carry personal data?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
