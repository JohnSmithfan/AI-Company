# Robustness Checks Prompt — Lifecycle & Training

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the lifecycle-training department (domain: people) for robustness.

Read references/departments/lifecycle-training/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

ONBOARDING AND OFFBOARDING
 1. Is an onboarding checklist marked complete only when every item is closed?
    A record with gaps is CHO_001 and must not exist.
 2. Is an agent returned rather than onboarded when its Harness assessment is missing?
 3. Does offboarding close or route commitments before credentials are revoked?
 4. Is a stage-permission mismatch suspended under CHO_003 and re-entered at the correct stage?

CAPABILITY POSITION
 5. Is every detected skill gap recorded against the capability matrix (CHO_002) before routing?
 6. Are tasks blocked on an unfilled gap actually blocked, never worked around?
 7. Is the establishment reconciled against the roster on cadence, with the authoritative
    side recorded (CHO_005)?
 8. Is a revoked certification removed from the matrix in the same pass that revoked it
    (CHO_004)?

VERIFICATION
 9. Is a certification claim without its evidence artifact revoked at once (CHO_004)?
10. Is the verification method recorded, not just the outcome?

AUTHORITY
11. Is scaffold handover the only intake path? Creation stays with engineering-tooling.
12. Is a termination with open customer commitments routed rather than executed?

OUTPUT
13. Is every certification record and roster export masked (template 9 - all three classes)
    and labelled (template 4) before distribution?
14. Does each record carry a trace ID with prefix "cho" (template 7)?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
