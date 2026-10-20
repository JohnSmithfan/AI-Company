# Robustness Checks Prompt — Board & Branch

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the board-and-branch department (domain: governance) for robustness.

Read references/departments/board-and-branch/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

QUORUM AND VOTES
 1. Is a binding vote taken only with quorum present, including remote attendees?
 2. Does a missing quorum defer the vote and re-convene within 48 h (BRD_001)?
 3. Is any decision recorded while quorum was absent flagged as invalid?

AUTHORIZATION MATRIX
 4. Is an out-of-matrix action blocked and logged with a trace ID (BRD_002)?
 5. Does a genuinely needed grant amendment route to CEO_002 rather than being granted locally?
 6. Does every matrix revision carry a rationale per changed row and an effective date?

ESCALATION AND REPORTING
 7. Is a top-rung exhaustion frozen and reviewed out-of-cycle within 48 h (BRD_004)?
 8. Is "no decision" recorded as a decision with its rationale when the board declines to decide?
 9. Is an overdue shareholder report generated from the last consistent snapshot and marked late (BRD_003)?

BRANCH AND TIER CONTROL
10. Is a branch promotion blocked until its pilot metrics clear threshold (BRD_005)?
11. Is a capability revoked on a branch autonomy violation (BRD_006) and restored only with a recorded root cause?
12. Is WFT-009 treated as reserved for group tier and not enabled here?
13. Is a tier upgrade only RECOMMENDED here, never approved? Approval is a human's.

OUTPUT
14. Are board minutes and matrix revisions masked (template 9, all three classes) and labelled
    (template 4) before distribution, with trace IDs (template 7, prefix "brd")?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
