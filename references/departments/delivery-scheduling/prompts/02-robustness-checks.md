# Robustness Checks Prompt — Delivery & Scheduling

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the delivery-scheduling department (domain: delivery) for robustness.

Read references/departments/delivery-scheduling/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

SCHEDULING AND COMMITMENT
 1. Is every commitment recorded with its scope, date and velocity basis?
 2. Is a missed deadline reported with its remaining scope and re-baselined, never quietly
    re-dated?
 3. Is a deadline cancellation escalated to executive-strategy rather than absorbed here?
 4. Is PMGR_ numbering continuous 001-005 with no gaps?

SPRINT AND TICKETS
 5. Is the next sprint commitment adjusted using the measured velocity after an under-delivery?
 6. Is a commitment exceeding capacity routed to operations-coordination before it is made?
 7. Does every escalation get an owner within 1 h?

DECOMPOSITION AND TRACEABILITY
 8. Is any undecomposed task assignable? (It must not be - PMGR_005.)
 9. Can a work item stay unlinked from an active OKR? (It must not - PMGR_002, then COO_003.)
10. Is discretionary work routed to COO_003 rather than left silent?

LOCALIZATION
11. Is a translation below the quality bar publishable? (It must not be.)
12. Can adaptation drop the source meaning? (It must not - conflicts escalate.)
13. Is a customer-visible translation defect handled as a customer escalation (PMGR_003)?

DEPLOYMENT WINDOWS
14. Is a deployment inside a committed window confirmed with engineering-tooling first?

OUTPUT
15. Is every commitment and escalation record traced (template 7, prefix "pmgr")?
16. Are customer identifiers masked (template 9) in escalation records?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
