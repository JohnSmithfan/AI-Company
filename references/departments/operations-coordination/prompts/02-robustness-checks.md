# Robustness Checks Prompt — Operations & Coordination

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the operations-coordination department (domain: governance) for robustness.

Read references/departments/operations-coordination/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

SLA MANAGEMENT
 1. Is a breach raised only after 2 consecutive windows below threshold, never on a single reading?
 2. Does COO_001 trigger WFT-003 with triage inside 15 min?
 3. Is an organization-level SLA amendment refused here and routed to board-and-branch?

RESOURCE SCHEDULING
 4. Is a conflict resolved by priority class (P1-P3), never by arrival order?
 5. Is the losing claimant re-queued with backoff rather than dropped?
 6. Is a deadlock broken by pre-empting the lowest-priority holder, with its work re-queued?
 7. Is the deadlock signature recorded so the same cycle cannot recur silently?

COORDINATION AND ROUTING
 8. Is a coordination timeout raised at 4 h (COO_006) with a re-send at elevated priority?
 9. Is silence past 8 h escalated rather than re-sent indefinitely?
10. Is a task ever routed to an agent outside its archetype? (It must not be.)
11. Is a contradiction routed to executive-strategy for arbitration instead of being decided here?

OUTPUT
12. Does every routing decision, bus event and knowledge sync carry a trace ID (template 7, prefix "coo")?
13. Are SLA registers and audit records masked (template 9, all three classes) and labelled
    (template 4) before distribution?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
