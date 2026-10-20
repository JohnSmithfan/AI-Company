---
department: operations-coordination
domain: governance
parent: ai-company
roles: [COO, HQ Coordinator]
error_code_prefix: COO_
function_blocks: 1
consolidates_group_tier: [operations-command, hq-coordination]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Operations & Coordination — Deep Specification

> D3 depth for [../operations-coordination.md](../operations-coordination.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A committed SLA has missed threshold in two consecutive windows | Detection and the WFT-003 trigger sit here; amendment authority does not |
| Two departments need the same exclusive agent, window or resource | Priority-class arbitration is owned here; `executive-strategy` arbitrates value conflicts, not resource conflicts |
| A department's local targets diverge from the organization OKR set | Divergence surfaces in PDCA here; the realignment decision belongs to `executive-strategy` |
| A coordination request has gone unanswered for 4 h | Timeout detection and re-send sit here; silence past 8 h leaves this department's hands |
| Two queued operations are waiting on each other | Deadlock detection and cycle-breaking are owned here |

**Not** this department: strategic decisions and arbitration (`executive-strategy`), matrix
ratification (`board-and-branch`), budget arithmetic (`finance-treasury`), capability certification
(`lifecycle-training`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**. Coordination authority never converts into decision
authority: this department routes, schedules and records — it does not settle value conflicts.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Trigger WFT-003 and declare containment | This department | Reversible | — |
| Grant an exclusive resource by priority class | This department | Reversible | — |
| Re-schedule a P3 task inside its window | This department | Reversible | — |
| Amend an organization-level SLA | `board-and-branch` | — | rung 4 |
| Realign a department's targets to the OKR set | `executive-strategy` | — | rung 3 |
| Re-baseline a customer-visible committed schedule | `executive-strategy` | — | rung 3 |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
board-and-branch
      ▲  escalation rungs 4-5 (top rung)
      │
executive-strategy  ◄──── contradictions (CEO_003), OKR realignment (COO_003)
      ▲
      │  SLA breaches, resource conflicts, coordination timeouts
operations-coordination
      │  ▲
      │  └── committed schedules ── delivery-scheduling
      │  └── agent roster ───────── lifecycle-training
      │  └── bus health ─────────── platform-mlops
      ▼  routing decisions, bus events
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A SLA register structure

Every committed SLA is a register row. A metric without a row is not managed.

| Field | Requirement |
|---|---|
| Metric ID | Trace ID from template 7, prefix `coo` |
| Owning department | The department whose commitment it is |
| Committed threshold | Numeric, with its measurement window |
| Breach rule | 2 consecutive windows below threshold — never a single reading |
| Current state | healthy / warning / breached |
| Last breach | Timestamp plus the WFT-003 trace ID it triggered |
| Breach history | Retained for trend analysis — a register entry is superseded, never deleted |

### 3.B Resource arbitration procedure

Triggered by `COO_002`. The order is fixed and impersonal:

```text
1. Freeze both claims. Neither may proceed while arbitration runs.
2. Compare priority classes: P1 > P2 > P3. Arrival order is never consulted.
3. Equal class → the earlier requested window wins.
4. Equal class and equal window → escalate to executive-strategy; never split the resource.
5. Grant the winner. Re-queue the loser with backoff.
6. Record both outcomes in the resource log with their trace IDs.
```

⚠️ Splitting an exclusive resource is not arbitration — an exclusive resource divided is two
departments each holding half a hazard. "Let them share it" is a failure to schedule.

### 3.C Coordination timeout ladder

Triggered by `COO_006`. The ladder has exactly three rungs:

| Elapsed | Action |
|---|---|
| 0 h | Request sent to the owning department, trace ID attached |
| 4 h | No acknowledgement → `COO_006`: re-send at elevated priority, notify the owner |
| 8 h | Still silent → escalate up the ladder; the request is no longer this department's to chase |

A request that is re-sent indefinitely without escalation is not persistence, it is a request
nobody owns. The terminal rung is not a failure of coordination — it is the designed hand-off
point, and reaching it on schedule is the ladder working as specified.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `COO_001` | SLA breach detected | A committed SLA metric fell below threshold for 2 consecutive measurement windows | 1. Identify the breaching metric 2. Trigger `WFT-003` Alert Response 3. Notify the owning department 4. Record in the SLA register |
| `COO_002` | Resource conflict | Two departments claimed the same exclusive resource in the same window | 1. Compare priority classes (P1–P3) 2. Grant to the higher class 3. Re-queue the loser with backoff |
| `COO_003` | OKR misalignment | A department's local targets diverge from the organization OKR set | 1. Diff local vs organizational targets 2. Route to `executive-strategy` 3. Realign or formally record the exception |
| `COO_004` | Resource allocation failed | Allocation request could not be satisfied within the requested window | 1. Check pool utilization 2. Offer the next available window 3. Escalate to `CEO_002` if the request is P1 |
| `COO_005` | Scheduling deadlock | Circular wait detected across ≥2 queued operations | 1. Break the cycle by pre-empting the lowest-priority holder 2. Re-queue pre-empted work 3. Record the deadlock signature to prevent recurrence |
| `COO_006` | Cross-department coordination timeout | A coordination request received no acknowledgement within 4 h | 1. Re-send with elevated priority 2. Notify the target department's owner 3. Escalate to `HQ` arbitration if silent past 8 h |

⚠️ At `group` tier the headquarters-coordination functions move to `hq-coordination` under prefix
`HQ_`. Here they report under `COO_`; `HQ_` is retired at this tier and revived on upgrade — see
[../../scaling.md](../../scaling.md) §3.

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `executive-strategy` | A `CEO_003` arbitration intake is prepared here: both positions, both evidence sets, both owners. A partial intake is returned by that department — coordination assembles the facts, arbitration decides |
| `board-and-branch` | Escalation payloads include the rungs already traversed and their outcomes, so the board does not re-litigate settled ground |
| `delivery-scheduling` | Committed schedules arrive as the resource calendar. A window conflict is resolved by priority class, not by moving a committed date |
| `lifecycle-training` | Routing consumes the capability matrix. An agent whose certification has lapsed is not routed to, regardless of load |

## 6. Constraints

- ❌ Do not decide a contradiction — route it to `executive-strategy` (`CEO_003`)
- ❌ Do not amend an organization-level SLA
- ❌ Do not grant a resource by arrival order
- ❌ Do not discard pre-empted work when breaking a deadlock
- ❌ Do not re-send a coordination request past 8 h of silence — escalate it
- ❌ Do not route to an agent outside its archetype or with lapsed certification
- ❌ Do not approve a tier upgrade — no department may
- ❌ Do not record a PDCA cycle without its adopt-or-revert decision

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Breach detection latency | Second consecutive miss timestamp minus breach-raise timestamp |
| Priority-class adherence | Conflicts resolved by class ÷ total conflicts — arrival-order outcomes are defects |
| Coordination timeout rate | `COO_006` count ÷ coordination requests sent |
| Deadlock recurrence | Distinct deadlock signatures per quarter — a repeat signature is a design defect |
| First-choice routing success | Tasks completed by the first-routed agent ÷ tasks routed |
| Audit completeness | Operations with a resolvable trace ID ÷ operations performed |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-COO-01 · Detect an SLA breach and trigger WFT-003

```text
1. Read the metric's two most recent windows against its committed threshold.
2. One window below → state "warning", notify the owner, no alert.
3. Two consecutive windows below → COO_001.
4. Trigger WFT-003: triage within 15 min, containment within 1 h, resolution within 24 h.
5. A P0 alert with no containment in 15 min escalates to rung 3 immediately.
6. Notify the owning department and record the breach in the SLA register.
7. Verify recovery at outcome level: the metric inside threshold for 2 consecutive windows.
```

### SOP-COO-02 · Arbitrate a resource conflict

```text
1. On COO_002, freeze both claims.
2. Compare priority classes (P1-P3). Arrival order is never consulted.
3. Equal class → the earlier requested window wins.
4. Equal class and equal window → escalate to executive-strategy.
5. Grant the winner; re-queue the loser with backoff.
6. Record both outcomes with their trace IDs in the resource log.
```

### SOP-COO-03 · Break a scheduling deadlock

```text
1. On COO_005, build the wait-for graph across all queued operations.
2. Identify every cycle; a cycle across >= 2 holders is a deadlock.
3. Choose the victim: the lowest-priority holder in the cycle.
4. Pre-empt the victim; re-queue its work with its original trace ID intact.
5. Record the deadlock signature so the same cycle cannot recur silently.
6. Re-run the §3.B procedure if the deadlock was caused by a resource
   conflict rather than by ordering.
```

### SOP-COO-04 · Route a cross-department coordination request

```text
1. Validate the request carries owner, payload and priority (template 1).
2. Route to the owning department over the bus, trace ID attached
   (template 7, prefix "coo").
3. Track acknowledgement. 4 h silent → COO_006: re-send at elevated
   priority, notify the owner.
4. 8 h silent → escalate up the ladder; stop chasing it here.
5. Record the outcome against the request's trace ID.
```

### SOP-COO-05 · Run a PDCA cycle

```text
1. PLAN: state the baseline, the hypothesis and the measurement that
   would falsify it.
2. DO: apply the change to one department's process, never organization-wide.
3. CHECK: measure against the baseline. Divergence from the OKR set →
   COO_003, route to executive-strategy.
4. ACT: record adopt-or-revert with its rationale. A cycle without the
   decision is incomplete.
5. Publish the result to the affected departments within 24 h.
6. Supersede the prior process record with a pointer - never delete it.
```
