---
department: executive-strategy
domain: governance
parent: ai-company
roles: [CEO, Chief Strategy Officer]
error_code_prefix: CEO_
function_blocks: 1
consolidates_group_tier: [executive-office, strategy-planning]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Executive & Strategy — Deep Specification

> D3 depth for [../executive-strategy.md](../executive-strategy.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| Two departments are both right and the answers conflict | Arbitration authority sits here (`CEO_003`); `operations-coordination` coordinates but does not decide |
| A decision has no owner because it crosses three domains | Cross-domain authority is not delegable to any single domain |
| An item has bounced between rungs without resolution | This is rung 3; rungs 4–5 go to `board-and-branch` |
| Someone asks "should we do this at all?" | Feasibility belongs to the executing department; desirability belongs here |
| A commitment must be cancelled, not delayed | Cancelling committed work exceeds every other role's authority |
| The organization's direction needs restating after a material change | Direction ownership is non-delegable |

**Not** this department: resource scheduling (`operations-coordination`), budget arithmetic
(`finance-treasury`), risk quantification (`risk-audit`), board-level ratification
(`board-and-branch`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The matrix below is the source of truth;
an action outside it raises `CEO_002` and the response must name the rung that holds authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Routine resource commitment (P3) | This department | Reversible | — |
| Committed-schedule change (P2) | This department | Reversible with cost | `board-and-branch` if customer-visible |
| New market entry | This department + board ratification | Irreversible | `board-and-branch` |
| Organization SLA amendment | `board-and-branch` | — | rung 4 |
| Cancelling a committed OKR | `board-and-branch` | — | rung 4 |
| Crisis extension beyond 72 h | `board-and-branch` | — | rung 4 |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
board-and-branch
      ▲  escalation rungs 3→4→5
      │
executive-strategy  ◄──── arbitration intake ◄──── operations-coordination
      │  ▲
      │  └── incident declarations ── incident-identity
      │  └── risk positions ───────── risk-audit
      │  └── market context ──────── intelligence-sentiment
      │  └── upgrade proposals ───── platform-mlops (WFT-010)
      ▼  decisions, directives
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Decision record structure

Every decision produces a record. A decision without a record did not happen.

| Field | Requirement |
|---|---|
| Decision ID | Trace ID from template 7, prefix `ceo` |
| Question | The question actually decided, in one sentence |
| Options considered | ≥ 2, including "do nothing" |
| Evidence | Named sources with as-of timestamps |
| Chosen option | Plus the rejected options and why |
| Reversibility | Reversible / reversible-with-cost / irreversible |
| Authority basis | The matrix row that grants it |
| Review date | Mandatory — a decision with no review date is a decision that is never revisited |
| Affected departments | Each receives the record within 4 h |

### 3.B Arbitration procedure

Triggered by `CEO_003`. Order of evaluation is fixed:

```text
1. Freeze both recommendations. Neither may proceed.
2. State the contradiction precisely: which claim, resting on which evidence.
3. Evaluate in this order:
   a. evidence quality   - source reliability, freshness, sample size
   b. scope authority    - which department actually owns this decision
   c. reversibility      - prefer the option that is cheaper to undo
4. Record the rationale, including why the losing position lost.
5. Release the winner. Send the loser the rationale, not just the verdict.
```

⚠️ Splitting the difference is not arbitration — it produces a third position nobody argued for
and nobody owns. "Let both teams compromise" is a failure to decide.

### 3.C Crisis protocol

| Phase | Action | Timing |
|---|---|---|
| Declare | Confirm criteria met; assign a commander; open the crisis record | ≤ 15 min |
| Contain | Blacklist enforcement active; `CTO_004` blocks production operations | ≤ 1 h |
| Assess | Facts established, blast radius bounded | ≤ 4 h |
| Decide | Options weighed under crisis rules — reversibility weighted higher | ≤ 8 h |
| Execute | Directives issued with trace IDs | per plan |
| Recover | Closure criteria verified at outcome level | ≤ 72 h |

Closure criteria are stated **at declaration time**. A crisis closed because it stopped being
discussed is not closed. Extension past 72 h requires `board-and-branch`.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `CEO_001` | Decision requires data | A decision is requested with no supporting dataset attached | 1. Identify the missing evidence class 2. Request it from `intelligence-sentiment` or `model-data` 3. Re-submit with the data reference. Never decide on assumption |
| `CEO_002` | Insufficient authority | The requested action exceeds the acting role's matrix grant | 1. Locate the matrix row 2. Name the rung that holds authority 3. Escalate with the full context 4. Record the escalation |
| `CEO_003` | Cross-agent conflict | Two or more departments returned contradictory recommendations | 1. Freeze both 2. Run §3.B 3. Record the rationale 4. Release the winner |
| `CEO_004` | Orchestration pipeline failed | A multi-department pipeline aborted mid-sequence | 1. Identify the failing stage from the trace ID 2. Re-run only that stage (idempotent) 3. On a second failure open `PMGR_005` |
| `CEO_005` | Crisis protocol activation failed | A trigger fired but the protocol did not start within 60 s | 1. Verify the trigger source is live 2. Start the protocol manually 3. File a post-incident review under `IRP_001` |
| `CEO_006` | Strategic alignment check failed | A proposed initiative conflicts with the active OKR set | 1. Diff against active OKRs 2. Amend the initiative or amend the OKR 3. Never bypass — an unaligned initiative that proceeds silently invalidates the OKR set |
| `CEO_007` | Escalation timeout | An escalated item received no decision within its SLA (24 h default) | 1. Re-escalate to the next rung 2. Notify the item owner 3. Log the timeout against the responsible role |
| `CEO_008` | Crisis blacklist violation attempted | A blacklisted action was requested during an active crisis | 1. Refuse outright 2. Record the attempt with its trace ID 3. Report to `board-and-branch` |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `operations-coordination` | Arbitration intake carries both positions, both evidence sets and both owners. A partial intake is returned |
| `incident-identity` | Incident declaration is inbound only; this department declares the **crisis**, `incident-identity` runs the **incident**. They are distinct and may run concurrently |
| `board-and-branch` | Escalation payload includes the rungs already traversed and their outcomes, so the board does not re-litigate |
| `platform-mlops` | WFT-010 proposals arrive with all six gate results. This department records the decision; **a human performs the approval** |

## 6. Constraints

- ❌ Do not decide without data (`CEO_001`)
- ❌ Do not act outside the authorization matrix
- ❌ Do not split the difference as a substitute for deciding
- ❌ Do not close a crisis without verifying its stated closure criteria
- ❌ Do not issue a directive with no traceable decision record
- ❌ Do not approve a tier upgrade — no department may
- ❌ Do not amend an organization SLA or cancel a committed OKR alone
- ❌ Do not re-litigate an arbitration when new evidence arrives; open a new decision record that supersedes the old one

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Decisions within SLA | Decision record timestamp minus intake timestamp, per priority class |
| Rationale completeness | Records with all §3.A fields present ÷ total records |
| Escalation timeout rate | `CEO_007` count ÷ escalation count |
| Arbitration rationale recorded | Records where the losing position's reasoning is stated ÷ total arbitrations |
| Crisis declaration latency | Declaration timestamp minus criteria-met timestamp |
| OKR publication lead | Days before period start that the set was published |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-CEO-01 · Render a binding decision

```text
1. Confirm the request carries a dataset. Absent → CEO_001, return it.
2. Confirm authority: locate the matrix row. Outside it → CEO_002, name the rung.
3. Generate a trace ID (template 7, prefix "ceo").
4. Enumerate ≥2 options including "do nothing".
5. Assess reversibility for each.
6. Decide. Record all §3.A fields.
7. Mask the record (template 9) and label it (template 4) before distribution.
8. Distribute to affected departments within 4 h.
9. Set the review date. A record without one is incomplete.
```

### SOP-CEO-02 · Arbitrate a cross-department contradiction

```text
1. On CEO_003, freeze both recommendations immediately.
2. Request from operations-coordination: both positions, both evidence sets, both owners.
   Incomplete intake → return it; do not arbitrate on partial facts.
3. State the contradiction in one sentence: which claim, which evidence.
4. Evaluate in fixed order: evidence quality → scope authority → reversibility.
5. Record the rationale including why the loser lost.
6. Release the winner; send the loser the rationale.
7. Link both original recommendations to the arbitration record.
```

### SOP-CEO-03 · Declare and run a crisis

```text
1. Confirm criteria met. Criteria are defined in advance, not improvised here.
2. Declare within 15 min. Assign a commander.
3. State closure criteria AT DECLARATION TIME.
4. Activate the blacklist; production operations now require grant (CTO_004).
5. If the protocol fails to start within 60 s → CEO_005, start manually, file IRP_001.
6. Contain (1 h) → Assess (4 h) → Decide (8 h) → Execute → Recover (72 h).
7. Weight reversibility higher than normal during crisis decisions.
8. Any blacklist violation attempt → CEO_008, refuse, record, report to board-and-branch.
9. Close only when the stated closure criteria are verified at outcome level.
10. Extension past 72 h → escalate to board-and-branch.
```

### SOP-CEO-04 · Review the authorization matrix

```text
1. Scheduled quarterly, or out-of-cycle within 48 h of a BRD_002 violation.
2. Inputs: escalation history, incident outcomes, audit findings, CEO_002 occurrences.
3. For each recurring CEO_002, ask: is the authority misplaced, or was it misused?
   Misplaced → amend the matrix. Misused → do not amend; address through the owner.
4. Draft the revision with an effective date and a rationale per changed row.
5. Submit to board-and-branch for ratification.
6. Publish to all departments; acknowledge receipt.
7. Supersede the prior version with a pointer — never delete it.
```

### SOP-CEO-05 · Handle a WFT-010 upgrade proposal

```text
1. Receive the proposal with all six gate results from platform-mlops.
2. If any of G1, G2, G3 failed → treat as a security event, not a workflow error.
   Report to board-and-branch and to the human operator. Do not proceed.
3. If G4, G5 or G6 failed → return to platform-mlops; the package is not installable.
4. If all six passed → verify the change list and the frontmatter diff show permissions unchanged.
5. Record the department's recommendation.
6. Hand to a HUMAN for approval. This department recommends; it does not approve.
7. Never invoke an installer. Phase 7 of WFT-010 is "stop".
```

⚠️ Step 6 is the whole point of the three-stage model. A recommendation from this department is
input to a human decision, not the decision.
