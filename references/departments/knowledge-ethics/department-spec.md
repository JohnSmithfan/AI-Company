---
department: knowledge-ethics
domain: people
parent: ai-company
roles: [Knowledge Steward, Ethics Reviewer]
error_code_prefix: KNM_
function_blocks: 1
consolidates_group_tier: [knowledge-management, ethics-culture]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Knowledge & Ethics — Deep Specification

> D3 depth for [../knowledge-ethics.md](../knowledge-ethics.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A project, incident or quarter has ended and its learning must be extracted | The extraction cadence and the distillation rules live here |
| A memory class has passed its consolidation interval | `KNM_002` fires here; the class is consolidated, not deleted |
| A use case matched an ethics trigger routed by `CLO_005` | The review runs here; the trigger and the baseline clause are recorded by `legal-privacy` |
| A knowledge item is being retired and it still has dependents | Supersession handling is here; a silent retirement is `KNM_005` |
| A whistleblower report arrived | The channel, the log and the retaliation check are here |

**Not** this department: compliance obligations and retention limits (`legal-privacy`),
`Knowledge`-store curation after distillation (`quality-visualization`), execution-outcome
capture (`engineering-tooling`), board reporting (`board-and-branch`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The table below is the source of truth;
an action outside it is refused and the response names the rung that holds authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Extract and distil a knowledge item | This department | Reversible | — |
| Consolidate a memory class and reset its interval | This department | Reversible | — |
| Block a decision awaiting ethics review (`KNM_003`) | This department | Reversible | — |
| Halt an activity that breached the baseline (`KNM_004`) | This department | Reversible with cost | — |
| Confirm an ethics violation and report it | `board-and-branch` | — | rung 4 |
| Change a retention limit or a size bound | `legal-privacy` | — | — |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
executive-strategy
      ▲  ethics posture, culture-audit summaries
      │
knowledge-ethics  ◄──── ethics-review triggers (CLO_005) ◄──── legal-privacy
      │  ▲
      │  └── knowledge sync ────────── operations-coordination
      │  └── execution outcomes ────── engineering-tooling
      │  └── confirmed violations ───► board-and-branch
      ▼  distilled knowledge, review outcomes
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Distillation and supersession rules

| Rule | Requirement |
|---|---|
| Cadence | `Knowledge` and `Learning` distilled every 30 days |
| Provenance | Every item carries a source and an as-of timestamp |
| Supersession | A superseded item is never deleted — it carries a pointer to its successor |
| Volatility separation | `Session` memory is never promoted to `Knowledge` without distillation |
| Size bound | `Knowledge` store ≤ 500 items per department before forced distillation |
| Ownership | Every item has exactly one owning department; no shared ownership without a named primary |

The classes under governance, with their intervals:

| Class | Interval | Bound |
|---|---|---|
| Profile | Agent lifetime — archived at offboarding | One record per agent |
| Session | Session duration | Dropped at session end |
| Knowledge | 30 days | ≤ 500 items per department |
| Learning | 30 days | Until disproven |
| Preference | Until changed | Explicit user statements only |

A distillation that would drop an un-superseded item is not a distillation — it is data loss
wearing a process name. The run stops and `KNM_005` handling applies.

### 3.B Ethics review procedure

Triggered by a `CLO_005` route from `legal-privacy`:

```text
1. Open the review with the use case, the matched trigger rule and the decision context.
2. Block the dependent action immediately - KNM_003 is raised on the decision, not on the review.
3. Evaluate against the recorded ethics baseline, clause by clause.
4. Outcome A: cleared, with conditions recorded per clause.
5. Outcome B: breached - KNM_004. Halt the activity, then remediate or withdraw.
6. Report a confirmed violation to board-and-branch and record it in the culture audit.
7. Record the outcome, the conditions and the reviewer. A pending review never resolves by
   waiting it out.
```

⚠️ The block in step 2 is unconditional. Urgency, revenue and a waiting stakeholder do not
release it; a completed review does.

### 3.C Whistleblower channel

```text
1. Accept the report through the channel only. Reports arriving elsewhere are redirected,
   never discarded.
2. Log within 24 h: receipt timestamp, scope, anonymity status. No identifying detail is
   inferred or stored beyond what was submitted.
3. Open an investigation with a named owner and a review date.
4. Check for retaliation against the reporter as a standing part of the investigation.
5. Any retaliation finding escalates to board-and-branch - it is never handled locally.
6. Close with the outcome recorded. The reporter is informed at the level the channel allows.
```

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `KNM_001` | Knowledge extraction failed | A distillation run produced no usable knowledge item | 1. Check source availability and permissions 2. Re-run with a narrower scope 3. Retain the prior knowledge state |
| `KNM_002` | Memory consolidation overdue | A memory class passed its consolidation interval | 1. Run consolidation for the class 2. Verify no item was dropped without supersession 3. Reset the interval timer |
| `KNM_003` | Ethics review pending | A decision awaits an ethics outcome | 1. Block the dependent action 2. Route to review with the decision context 3. Record the outcome and any conditions |
| `KNM_004` | Ethics violation confirmed | A reviewed item was found to breach the ethics baseline | 1. Halt the activity 2. Remediate or withdraw 3. Report to `board-and-branch` and record in the culture audit |
| `KNM_005` | Knowledge supersession missing | A knowledge item was retired without a replacement reference | 1. Identify dependents of the retired item 2. Provide a replacement or an explicit deprecation notice 3. Update all references |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `legal-privacy` | `CLO_005` triggers arrive with the use case and the matched trigger rule; a review is opened, not merely logged |
| `operations-coordination` | Knowledge sync carries distilled items only — raw session memory never crosses the bus |
| `engineering-tooling` | Execution outcomes are supplied with their trace IDs; an outcome without a trace is not extractable |
| `board-and-branch` | Confirmed violations (`KNM_004`) report with the baseline clause breached and the remediation taken |

## 6. Constraints

- ❌ Do not delete a superseded item silently — successor pointer or explicit deprecation (`KNM_005`)
- ❌ Do not promote `Session` memory to `Knowledge` without distillation
- ❌ Do not persist raw PII in any memory type — mask first, always
- ❌ Do not proceed on a pending ethics review (`KNM_003`)
- ❌ Do not resume a halted activity before remediation and a recorded outcome (`KNM_004`)
- ❌ Do not let a memory class pass its consolidation interval twice
- ❌ Do not act on a report that arrived outside the channel, and never act on one without an investigation
- ❌ Do not treat an unrun culture audit as a passed one

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Distillation cadence adherence | Run timestamp minus due timestamp per class, over a rolling 90 days |
| Consolidation interval breaches | `KNM_002` count per class per quarter |
| Supersession pointer coverage | Retired items with a verified successor pointer ÷ total retirements |
| Ethics review latency | Outcome timestamp minus intake timestamp per review |
| Pending-review blocks honoured | Decisions blocked while a review was open ÷ decisions subject to review |
| Whistleblower investigation coverage | Reports with an opened investigation ÷ reports logged |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-KNM-01 · Extract and distil knowledge from an outcome

```text
1. Confirm the outcome carries a trace ID. Without one it is not extractable - return it.
2. Classify the outcome: project closure, incident review, execution learning.
3. Extract candidate items. Each carries a source and an as-of timestamp.
4. Empty batch → KNM_001. Re-run narrower; retain the prior distilled state.
5. Distil: merge duplicates, resolve contradictions by supersession, never by deletion.
6. Publish into the Knowledge store owned by quality-visualization.
7. Label (template 4) and mask (template 9); trace with prefix "knm" (template 7).
```

### SOP-KNM-02 · Consolidate a memory class

```text
1. On the interval timer (Knowledge and Learning: 30 days), open the consolidation run.
2. A class already past interval → KNM_002; run immediately and record the breach.
3. Merge items, supersede stale ones, and verify no item was dropped without supersession.
4. An item that would be dropped un-superseded stops the run - KNM_005 handling applies.
5. Reset the interval timer.
6. Report the run: items in, items merged, items superseded, size after.
```

### SOP-KNM-03 · Run an ethics review

```text
1. Receive the CLO_005 route with the use case, the matched trigger rule and the context.
2. Block the dependent action. Raise KNM_003 on the decision, not on the review.
3. Evaluate against the recorded baseline, clause by clause.
4. Cleared → record the outcome and its conditions.
5. Breach → KNM_004. Halt the activity first, then remediate or withdraw.
6. Report a confirmed violation to board-and-branch; record it in the culture audit.
7. Record the outcome, the conditions and the reviewer. A pending review never resolves
   by waiting it out.
```

### SOP-KNM-04 · Handle a confirmed ethics violation

```text
1. Confirm the breach against the baseline clause. A suspicion is not a confirmation.
2. Halt the activity. Nothing else happens before the halt.
3. Remediate or withdraw. Record which.
4. Report to board-and-branch with the clause, the activity and the remediation.
5. Record in the culture audit with the trace ID.
6. Resume only on a recorded outcome - never on the absence of further objection.
```

### SOP-KNM-05 · Receive and log a whistleblower report

```text
1. Accept the report through the channel only.
2. Log within 24 h: receipt timestamp, scope, anonymity status.
3. Open an investigation with a named owner and a review date.
4. Check for retaliation as a standing part of the investigation.
5. Any retaliation finding escalates to board-and-branch.
6. Close with the outcome recorded at the level the channel allows.
```

⚠️ Step 2 of SOP-KNM-03 is unconditional. An ethics block released by urgency is an ethics
block that was never real.
