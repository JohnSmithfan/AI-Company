# Robustness Checks Prompt — Legal & Privacy

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the legal-privacy department (domain: security) for robustness.

Read references/departments/legal-privacy/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

CONTRACT CONTROL
 1. Is signature blocked while a contract or terms change lacks a review record (CLO_002)?
 2. Are terms ever auto-accepted? They must not be.
 3. Does every review record name the reviewer and the date?
 4. Are the obligations an instrument creates recorded for future CLO_001 checks?

AIGC COMPLIANCE
 5. Are all three label layers verified (label / metadata / watermark)?
 6. Is the remedy re-emission through template 4, not patching the unlabelled copy?
 7. Is the unlabelled copy withdrawn, not merely superseded?

PII AND RESIDENCY
 8. Is a PII flow halted (CLO_001) when it has no recorded legal basis?
 9. Is the transfer mechanism cited by name, with encryption explicitly not accepted as one?
10. On an out-of-region copy, is it deleted or repatriated and recorded under CLO_001?
11. Are storage region and processing region mapped separately?

ROUTING AND RECORDS
12. Does a pending ethics review block the dependent action (CLO_005)?
13. Is the notification-clock assessment kept out of the incident run itself?
14. Is every determination masked (template 9) and labelled (template 4) before distribution?
15. Is every determination traced (template 7, prefix "clo")?
16. Are superseded determinations kept with a pointer rather than deleted?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
