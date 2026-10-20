# Robustness Checks Prompt — Incident & Identity

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the incident-identity department (domain: security) for robustness.

Read references/departments/incident-identity/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

INCIDENT LIFECYCLE
 1. Is the evidence log opened in the Declare phase, before any remediation?
 2. Is a commander assigned and WFT-005 started on IRP_001?
 3. Is closure gated on recovery evidence plus the review record, not on containment?
 4. Is the crisis declared by executive-strategy rather than by this department?

FORENSICS
 5. Is evidence hashed on acquisition and re-hashed on transfer?
 6. Is custody recorded for every handoff (time, from, to, purpose)?
 7. On missing or altered evidence (IRP_002), is the limitation stated in the final report?
 8. Is remaining evidence preserved read-only after an IRP_002?

NOTIFICATION
 9. Is IRP_003 escalated to legal-privacy immediately when a window is at risk?
10. Is a provisional notification prepared while the timeline is recorded?
11. Is the clock assessment kept out of the incident run, with its own trace ID?

IDENTITY
12. Is every cross-boundary flow authenticated, with no ambient authority?
13. Are credentials referenced by environment-variable name only, never by value?
14. Is a suspected credential revoked within 15 min, before confirmation?
15. Are unreviewed grants revoked by default on IRP_005, with restoration requiring
    a recorded owner attestation?

OUTPUT
16. Is every incident, revocation and review record masked (template 9) before distribution?
17. Is every one labelled (template 4) and traced (template 7, prefix "irp")?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
