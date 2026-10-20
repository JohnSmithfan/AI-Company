---
department: delivery-scheduling
domain: delivery
parent: ai-company
roles: [Programme Manager, Localization Lead]
error_code_prefix: PMGR_
function_blocks: 1
consolidates_group_tier: [project-management, localization-translation]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Delivery & Scheduling — Deep Specification

> D3 depth for [../delivery-scheduling.md](../delivery-scheduling.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A project schedule must be built or re-baselined against committed dates | Deadline ownership sits here; capacity arithmetic sits with `operations-coordination` |
| Sprint scope must be committed at a measured velocity | Commitment ownership is non-delegable to the executing team |
| A customer issue has met the escalation criteria | The escalation record and its reporting cadence are owned here |
| A task cannot be broken into assignable units | Decomposition is a precondition of assignment, not a phase of it |
| Content must be translated or culturally adapted for a locale | The localization quality bar and language routing are owned here |

**Not** this department: deployment execution (`engineering-tooling`), quality gates and report
templates (`quality-visualization`), resource pool arbitration (`operations-coordination`), OKR
setting (`executive-strategy`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The table below is the source of truth; an
action outside it is escalated, and the response names the role that holds the authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Commit sprint scope within measured velocity | This department | Reversible with cost | — |
| Re-baseline a project schedule with the stakeholder | This department | Reversible with cost | — |
| Cancel a committed deadline | `executive-strategy` | Irreversible | rung 3 |
| Publish a translation below the quality bar | ❌ Never — the bar is the bar | — | — |
| An escalation with regulatory or contractual exposure | `legal-privacy` | — | — |
| A commitment exceeding available capacity | `operations-coordination` | Reversible | — |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
executive-strategy
      ▲  deadline cancellations, OKR linkage
      │
delivery-scheduling  ◄──── window confirmations ──── engineering-tooling
      │  ▲                  (WFT-007, committed schedules)
      │  └── unlinked items ── operations-coordination (PMGR_002 → COO_003)
      │  └── report templates quality-visualization (WFT-002)
      ▼  commitments, schedules, localized content
  requesting departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Commitment record structure

Every commitment produces a record. A commitment without a record is a conversation, not a
commitment.

| Field | Requirement |
|---|---|
| Commitment ID | Trace ID from template 7, prefix `pmgr` |
| Scope | What was committed, in assignable units |
| Date | The committed date and its float |
| Velocity basis | The measured velocity the commitment was set against |
| Re-baseline | Once with the stakeholder; a second requires `executive-strategy` |
| Cause | Recorded on every miss — for trend analysis, not for blame |

### 3.B Customer escalation ladder

| Step | Action | Timing |
|---|---|---|
| 1 Intake | Criteria checked; escalation record opened with its committed cadence | Immediate |
| 2 Owner | Owner assigned | ≤ 1 h |
| 3 Cadence | Status reported at the committed cadence until closed | Per record |
| 4 Exposure | Regulatory or contractual exposure detected | Route to `legal-privacy` |
| 5 Closure | Closed at outcome level with the customer confirmation recorded | Per record |

An escalation that receives no owner within 1 h has already failed — the timer, not the intention,
is the control. A closure recorded without the customer confirmation is an assumption, not a
closure; where the customer cannot confirm, the record states the limitation rather than implying
confirmation.

### 3.C Localization quality bar

| Check | Requirement |
|---|---|
| Meaning | Source meaning intact — adaptation never drops content |
| Terminology | Approved term list per locale |
| Register | Tone appropriate to the locale and the channel |
| Completeness | No untranslated segments shipped |
| Review | Verdict recorded with the reviewer and the locale |

A translation below the bar is not published. Where source meaning and adaptation conflict, the
item escalates rather than being quietly rewritten. Terminology conflicts between the source
glossary and the locale term list are resolved before review, not during it — a reviewer must not
be asked to arbitrate vocabulary.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `PMGR_001` | Project deadline missed | A committed deadline passed with work outstanding | 1. Report the remaining scope 2. Re-baseline with the stakeholder 3. Record the cause for trend analysis |
| `PMGR_002` | OKR unlinked | A work item has no traceable link to an active OKR | 1. Link the item or mark it as discretionary 2. Route discretionary work to `COO_003` 3. Never leave an item unlinked silently |
| `PMGR_003` | Customer escalation | A customer issue met the escalation criteria | 1. Assign an owner within 1 h 2. Open the escalation record 3. Report status at the committed cadence until closed |
| `PMGR_004` | Sprint commitment failed | Committed sprint scope was not delivered | 1. Report delivered vs committed 2. Adjust the next commitment using the measured velocity 3. Record the cause |
| `PMGR_005` | Task decomposition failed | A task could not be decomposed into assignable units | 1. Identify the ambiguity blocking decomposition 2. Route to the requester for clarification 3. Re-decompose — do not assign an undecomposed task |

⚠️ Numbering is continuous `001`–`005`, **no gaps**. Localization findings that at `group` tier
belong to `localization-translation` (`TR_`) are reported under `PMGR_` at this tier; `TR_` is
retired here and revived on upgrade — see [../../scaling.md](../../scaling.md) §3.

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `engineering-tooling` | Deployment windows are negotiated against committed schedules; a window conflict is resolved by priority class, never by deploying anyway |
| `operations-coordination` | Unlinked work items route as `PMGR_002` → `COO_003`; capacity conflicts route to the resource scheduler before the commitment is made |
| `quality-visualization` | Sprint, deadline and deployment-window reporting uses the shared report-template library (WFT-002) |
| `executive-strategy` | Work-item OKR linkage is checked here; a cancelled commitment is escalated, never absorbed silently |

## 6. Constraints

- ❌ Do not assign an undecomposed task (`PMGR_005`)
- ❌ Do not leave a work item unlinked from an active OKR (`PMGR_002`)
- ❌ Do not re-date a missed deadline quietly (`PMGR_001`)
- ❌ Do not repeat a failed sprint commitment unchanged (`PMGR_004`)
- ❌ Do not run an escalation without an owner assigned within 1 h (`PMGR_003`)
- ❌ Do not publish a translation below the quality bar, or one that drops the source meaning
- ❌ Do not deploy inside a committed window without `engineering-tooling` confirming it
- ❌ Do not approve a tier upgrade — no department may

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Committed-deadline hit rate | Deadlines met ÷ committed, per period |
| Re-baseline latency | Re-baseline timestamp minus deadline-miss detection timestamp |
| Sprint delivery rate | Delivered scope ÷ committed scope, per sprint |
| Escalation owner latency | Owner assignment minus escalation intake timestamp |
| Decomposition completeness | Tasks assigned after decomposition ÷ tasks assigned |
| Localization first-pass rate | Translations meeting the bar on first review ÷ total reviews |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-PMGR-01 · Build or re-baseline a project schedule

```text
1. Inventory the scope and the dependency map.
2. Confirm the capacity position with operations-coordination. A commitment exceeding
   capacity is routed there before it is made.
3. Set committed dates with float; record the velocity basis for each.
4. Generate a trace ID (template 7, prefix "pmgr") and open the commitment record.
5. On a material change, re-baseline within 24 h: report remaining scope, re-baseline
   with the stakeholder, record the cause.
6. A missed deadline -> PMGR_001. Never quietly re-date it.
7. Cancelling a committed deadline exceeds this department - escalate to
   executive-strategy.
```

### SOP-PMGR-02 · Commit a sprint

```text
1. Take the backlog and the measured velocity. A velocity with no measurement behind
   it is not a basis.
2. Decompose every candidate item first (SOP-PMGR-04); an undecomposed item is not
   committable.
3. Confirm every item links to an active OKR or is marked discretionary (PMGR_002).
4. Set the commitment before sprint start; record it with the velocity basis.
5. At sprint end, report delivered vs committed within 24 h.
6. Under-delivery -> PMGR_004. Adjust the next commitment using the measured velocity.
7. Record the cause for trend analysis, not for blame.
```

### SOP-PMGR-03 · Run a customer escalation

```text
1. Check the issue against the escalation criteria. Met -> open the escalation record
   with its committed cadence.
2. Assign an owner within 1 h. An escalation without an owner is a complaint, not a
   process.
3. Detect regulatory or contractual exposure -> route to legal-privacy immediately.
4. Report status at the committed cadence until closed.
5. Close at outcome level with the customer confirmation recorded.
6. Any customer-visible translation defect enters here as PMGR_003 - a localization
   defect is a customer-facing defect.
```

### SOP-PMGR-04 · Decompose a task

```text
1. Take the task statement and its acceptance criteria.
2. Attempt decomposition into assignable units within 8 h.
3. Decomposed -> assign the units; record the commitment linkage.
4. Blocked by ambiguity -> PMGR_005. Name the ambiguity precisely.
5. Route to the requester for clarification; do not guess at the missing meaning.
6. Re-decompose on clarification. An undecomposed task is never assigned - a unit
   nobody can own fails silently later.
```

### SOP-PMGR-05 · Review a translation for a locale

```text
1. Identify the target locale and pull its approved term list.
2. Check the four bar items: meaning intact, terminology, register, completeness.
3. All four pass -> approve; record the verdict with the reviewer and the locale.
4. Any fail -> do not publish. Return with the failing item named.
5. Source meaning conflicts with adaptation -> escalate; never quietly rewrite.
6. A defect that already reached a customer -> PMGR_003 (SOP-PMGR-03).
7. Route follow-up locale work through language routing (D2 §3.6) with its trace ID.
```
