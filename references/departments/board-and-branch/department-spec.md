---
department: board-and-branch
domain: governance
parent: ai-company
roles: [Board Secretary, Branch Manager]
error_code_prefix: BRD_
function_blocks: 1
consolidates_group_tier: [board-governance, branch-management]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Board & Branch — Deep Specification

> D3 depth for [../board-and-branch.md](../board-and-branch.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| An escalation has reached the top rung unresolved | Rung 5 is terminal; the only remaining action is a recorded board review (`BRD_004`) |
| A role needs authority its matrix row does not grant | Amendment is ratified here, never by the requesting department |
| A branch promotion is requested before its pilot cleared | The gate is held here (`BRD_005`); the pilot itself runs in the branch |
| A branch acted outside its scoped operations matrix | Revocation and restoration are owned here (`BRD_006`) |
| A scheduled shareholder report has passed its due date | Register and recovery procedure are owned here (`BRD_003`) |

**Not** this department: day-to-day operations and coordination (`operations-coordination`),
strategic decisions (`executive-strategy` decides; this department ratifies), branch staffing
(`lifecycle-training`), cross-border legal determinations (`legal-privacy`).

## 2. Core Identity (Extended)

### Authority model

Authority at this tier is **structural**: the board bounds every other role and is itself bounded
by the owners and, for structural change, by a human.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Defer a vote that lacks quorum | This department | Reversible | — |
| Ratify an authorization-matrix revision | This department | — | — |
| Convene an out-of-cycle board review | This department | Reversible | — |
| Open a branch within the approved structure | This department | Reversible with cost | — |
| Restore a revoked branch capability | This department + recorded root cause | — | — |
| Public disclosure beyond the scheduled set | `legal-privacy` + this department | Irreversible | — |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
owners / shareholders
      ▲  scheduled reports (BRD_003), approval requests
      │
board-and-branch  ◄──── escalations at rungs 4-5 ◄──── executive-strategy
      │  ▲
      │  └── rung-2 outcomes ──── operations-coordination
      │  └── WFT-010 gates ────── platform-mlops (co-owner)
      ▼  matrix ratifications, branch directives
  all departments and branches
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Escalation ladder

Rungs 1–2 run inside the owning department and `operations-coordination`; this department owns
rung-4 action and the terminal rung 5.

| Rung | Holder | Action on timeout |
|---|---|---|
| 1 | Owning department | Escalate at its SLA |
| 2 | `operations-coordination` | `COO_006` at 4 h; escalate at 8 h |
| 3 | `executive-strategy` | `CEO_007` at its SLA |
| 4 | This department | Convene an out-of-cycle review within 48 h |
| 5 | This department, terminal | `BRD_004` — freeze and record, including "no decision" |

### 3.B Matrix ratification record

| Field | Requirement |
|---|---|
| Revision ID | Trace ID from template 7, prefix `brd` |
| Changed rows | One rationale per row — "miscellaneous" is not a rationale |
| Trigger | The `BRD_002` or `CEO_002` history that prompted it |
| Effective date | Mandatory — a matrix with no effective date is not in force |
| Supersedes | Pointer to the prior version; the prior version is never deleted |

### 3.C Branch lifecycle gates

| Gate | Criterion | On failure |
|---|---|---|
| Open | Structure inside the approved archetype set; scoped matrix issued | `BRD_005` — do not open |
| Pilot | Quantitative success criteria met across the pilot window | `BRD_005` — extend the window, report measured values |
| Promote | Pilot metrics cleared; headquarters sign-off recorded | `BRD_005` — re-evaluate at the next gate |
| Delegate | Autonomy scoped by the matrix; audit cadence agreed | `BRD_006` on any out-of-scope action |

⚠️ WFT-009 Branch Rollout encodes these gates but is **not enabled at this tier** — it arrives
with the `group` tier. A request for it here returns `SCL_002`.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `BRD_001` | Board quorum not met | Fewer than the required number of board roles present for a binding vote | 1. Defer the vote 2. Notify absent members 3. Re-convene within 48 h |
| `BRD_002` | Authorization matrix violation | An action was attempted outside the matrix grant for the acting role | 1. Block the action 2. Log with trace ID 3. Route to `CEO_002` if a grant amendment is genuinely needed |
| `BRD_003` | Shareholder report overdue | A scheduled report passed its due date without publication | 1. Generate from the last consistent snapshot 2. Mark it as late in the register 3. Record the cause |
| `BRD_004` | Escalation ladder exhausted | An item reached the top rung without resolution | 1. Freeze the item 2. Convene an out-of-cycle board review 3. Record the decision, including "no decision" |
| `BRD_005` | Branch rollout criteria not met | A branch promotion was requested before its pilot metrics cleared threshold | 1. Report the unmet criteria with measured values 2. Extend the pilot window 3. Re-evaluate at the next gate |
| `BRD_006` | Branch autonomy violation | A branch acted outside its scoped operations matrix | 1. Revoke the offending capability 2. Restore the pre-action state 3. Report to `CEO_002` and record in the branch register |

⚠️ At `group` tier the branch-management functions move to `branch-management` under prefix
`BRN_`. Here they report under `BRD_`; `BRN_` is retired at this tier and revived on upgrade — see
[../../scaling.md](../../scaling.md) §3.

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `executive-strategy` | Escalation payloads arrive with the rungs already traversed and their outcomes. The board does not re-litigate settled ground — it decides what remains |
| `operations-coordination` | Rung-2 outcomes arrive with their trace IDs; a coordination timeout that reaches rung 4 carries its `COO_006` history |
| `platform-mlops` | WFT-010 is co-owned: they build and gate the package, this department convenes the review. **A human approves.** The department recommends; it never installs |
| `legal-privacy` | Cross-border deployments and disclosures beyond the scheduled set are determined there before this department acts |

## 6. Constraints

- ❌ Do not take a binding vote without quorum
- ❌ Do not approve a tier upgrade — no department may
- ❌ Do not amend the matrix without a rationale per changed row and an effective date
- ❌ Do not publish a shareholder report from an inconsistent snapshot
- ❌ Do not promote a branch before its pilot metrics clear threshold
- ❌ Do not restore a revoked branch capability without a recorded root cause
- ❌ Do not treat WFT-009 as enabled at this tier
- ❌ Do not close a top-rung escalation — record the decision, including "no decision"

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Quorum adherence | Binding votes with quorum present ÷ binding votes taken |
| Matrix revision discipline | Revisions with all §3.B fields ÷ total revisions |
| Top-rung resolution | Items resolved at rung 5 ÷ items reaching rung 5 |
| Out-of-cycle review latency | Review convened timestamp minus `BRD_004` timestamp |
| Report punctuality | Reports published on the scheduled date ÷ reports due |
| Promotion gate adherence | Promotions with pilot metrics cleared ÷ promotions granted |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-BRD-01 · Convene a binding board vote

```text
1. Verify quorum before the session opens: required roles present,
   including remote attendees.
2. Missing quorum → BRD_001: defer the vote, notify absent members,
   re-convene within 48 h.
3. State each motion in one sentence, with its matrix row where
   authority is at issue.
4. Record votes per role, with abstentions named - an unnamed
   abstention is a missing vote.
5. Record the outcome with a trace ID (template 7, prefix "brd").
6. Distribute the minute to affected departments; mask (template 9)
   and label (template 4) first.
```

### SOP-BRD-02 · Ratify an authorization-matrix revision

```text
1. Receive the proposal from executive-strategy with its
   BRD_002 / CEO_002 history.
2. Verify each changed row carries a rationale and the revision
   carries an effective date. Missing → return it; an unrationalized
   row is not ratifiable.
3. Convene the vote (SOP-BRD-01).
4. On ratification: publish to all departments with the effective date.
5. Supersede the prior version with a pointer - never delete it.
6. Out-of-cycle reviews are convened within 48 h of a BRD_002 violation.
```

### SOP-BRD-03 · Handle an exhausted escalation

```text
1. On BRD_004, freeze the item. It is not closed, and it is not
   reassigned.
2. Assemble the payload: rungs traversed, their outcomes, both
   positions where relevant.
3. Convene an out-of-cycle board review within 48 h.
4. Weigh the item on its evidence, not on how long it has been open.
5. Record the decision - including an explicit "no decision" with its
   rationale.
6. Route the outcome down the ladder with its trace ID.
```

### SOP-BRD-04 · Gate a branch promotion

```text
1. Receive the promotion request with its pilot metrics pack.
2. Check every gate criterion in §3.C against measured values,
   not assertions.
3. Any criterion unmet → BRD_005: report the unmet criteria with
   measured values, extend the pilot window, re-evaluate at the
   next gate.
4. All met → record headquarters sign-off and promote.
5. Issue the branch's scoped operations matrix at promotion -
   autonomy is scoped, not assumed.
6. WFT-009 is not invoked: it is reserved for group tier and
   returns SCL_002 here.
```

### SOP-BRD-05 · Handle a branch autonomy violation

```text
1. On BRD_006, revoke the offending capability immediately.
2. Restore the pre-action state - copy forward, verify, atomic
   replace, then delete.
3. Report to CEO_002 and record in the branch register with the
   trace ID.
4. Assess blast radius: which other actions the ungoverned
   capability enabled.
5. Restoration of the capability requires a recorded root cause
   and a board review.
6. Feed the event into the next matrix review (SOP-BRD-02).
```
