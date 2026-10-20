---
department: procurement-billing
domain: finance
parent: ai-company
roles: [Procurement Lead, Billing Lead]
error_code_prefix: PRC_
function_blocks: 1
consolidates_group_tier: [procurement-vendor, billing-unit-economics]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Procurement & Billing — Deep Specification

> D3 depth for [../procurement-billing.md](../procurement-billing.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A vendor must be chosen between several candidates | Vendor evaluation is owned here |
| An invoice diverges from the contracted rate | Contract cost control is owned here |
| A purchase exceeds the self-approval limit | Approval routing is owned here |
| Billed units do not match metered usage | Metered billing reconciliation is owned here |
| A pricing decision lacks a cost basis | Unit economics is owned here |

**Not** this department: budget approval (`finance-treasury`), risk scoring (`risk-audit`),
contract legal review (`legal-privacy`), commitment authority (`executive-strategy`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The matrix below is the source of truth;
an action outside it is routed, never quietly executed.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Vendor selection within scored dimensions | This department | Reversible with cost | — |
| Invoice payment within the 2 % tolerance | This department | Reversible | — |
| Purchase within the self-approval limit | This department | Reversible | — |
| Purchase above the self-approval limit | The correct approval rung | Reversible | per policy |
| Contract signature | This department + `legal-privacy` review | Irreversible | — |
| Unit-economics publication | This department | Reversible | — |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
legal-privacy
      ▲  contract review before signature
      │
executive-strategy
      ▲  purchases above the department ceiling
      │
procurement-billing  ◄──── purchase requests ──── all departments
      │  ▲
      │  └── unit-cost components ── finance-treasury
      │  └── vendor risk scores ──── risk-audit
      │  └── metered usage ───────── model-data
      ▼  purchase decisions, invoices, unit economics
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Vendor evaluation procedure

```text
1. Fix the required scoring dimensions before candidates are seen.
2. Score every candidate on every dimension.
3. An unscored dimension -> PRC_001; collect it or record a justified waiver.
4. Attach the vendor risk score from risk-audit before commitment.
5. Rank the shortlist; record the waiver where one was used.
6. Never select on a partial shortlist - an unscored dimension is an unmeasured risk.
```

A waiver is a recorded judgement, not a silence: it names the dimension, the reason and the
person who accepted the gap. An unrecorded waiver is an unscored dimension that nobody owns.

### 3.B Invoice-to-contract cost control

| Step | Rule |
|---|---|
| Diff | Line by line against the contract schedule, never in total |
| Tolerance | ≤ 2 % divergence pays; beyond it, `PRC_002` |
| Dispute | The delta is disputed with the vendor before any payment |
| Withholding | The disputed portion is withheld against a recorded dispute reference |
| Closure | The dispute closes with a credit, a corrected invoice or an accepted variance |

⚠️ Paying first and disputing later converts a contract control into a collection problem.

### 3.C Metered billing reconciliation

```text
1. Pull metered usage for the period from the source of record.
2. Match billed units to metered usage within the recorded tolerance.
3. All matched -> issue the invoice.
4. Unmatched -> PRC_004; re-meter the period before any adjustment.
5. Quarantine the unmatched units; never write them off silently.
6. Close the quarantine with a credit or a supplemental invoice.
```

A quarantine closed by estimation is a quarantine that was never reconciled — the adjustment
follows the re-metered figure, or it does not follow at all.

### 3.D Cost allocation rules

| Rule | Content |
|---|---|
| Driver stated | Every allocation line names its driver; a line without one is withdrawn |
| Driver change | Recorded before it takes effect; never retroactive to a closed period |
| Shared pool | Allocated in full — an unallocated remainder is an error, not a reserve |
| Publication | The schedule is published ≤ 5 business days after period close |
| Challenge window | Any department may challenge a line within 10 business days of publication |

A challenge is answered with the driver data, not with a re-run: the schedule stands unless the
driver itself is shown to be wrong.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `PRC_001` | Vendor evaluation incomplete | A procurement decision was requested with fewer than the required evaluation dimensions scored | 1. List the unscored dimensions 2. Collect scores or record a justified waiver 3. Re-run the evaluation |
| `PRC_002` | Contract cost mismatch | Invoiced amount diverged from the contracted rate by >2 % | 1. Diff invoice lines against contract schedule 2. Dispute the delta with the vendor 3. Withhold the disputed portion |
| `PRC_003` | Procurement approval missing | A purchase was initiated above the self-approval limit | 1. Halt the purchase 2. Route to the correct approval rung 3. Record the policy exception |
| `PRC_004` | Billing reconciliation failed | Billed units could not be matched to metered usage within tolerance | 1. Re-meter the period 2. Quarantine unmatched units 3. Issue a credit or a supplemental invoice |
| `PRC_005` | Unit economics unavailable | A pricing or investment decision lacked a computable unit-cost basis | 1. Identify the missing cost component 2. Source it from `finance-treasury` 3. Defer the decision if the basis remains unknown |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `finance-treasury` | Cost components are requested by name; a missing component defers the decision (`PRC_005`) |
| `risk-audit` | Vendor risk scores arrive before commitment, not after signature |
| `legal-privacy` | A contract enters review before signature; terms are never auto-accepted |
| `model-data` | Metered usage is pulled per period; re-metering is preferred over estimating the delta |

## 6. Constraints

- ❌ Do not decide a procurement with unscored evaluation dimensions (`PRC_001`)
- ❌ Do not pay an invoice >2 % off the contracted rate without a dispute (`PRC_002`)
- ❌ Do not initiate a purchase above the self-approval limit (`PRC_003`)
- ❌ Do not bill units unmatched to metered usage (`PRC_004`)
- ❌ Do not decide pricing or investment without a computable unit-cost basis (`PRC_005`)
- ❌ Do not sign a contract before `legal-privacy` review
- ❌ Do not withhold a disputed portion without a recorded dispute reference
- ❌ Do not approve a tier upgrade — no department may

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Evaluation completeness | Decisions with all dimensions scored ÷ total decisions |
| Invoice accuracy | Invoices within 2 % of contract rate ÷ total invoices |
| Approval routing | Purchases above limit routed before initiation ÷ total such purchases |
| Billing match rate | Billed units matched within tolerance ÷ total billed units |
| Unit-economics availability | Decisions with a computable basis ÷ total decisions |
| Dispute discipline | Withheld portions with a dispute reference ÷ total withheld portions |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-PRC-01 · Evaluate a vendor

```text
1. Fix the required scoring dimensions before candidates are seen.
2. Score every candidate on every dimension.
3. Unscored dimension -> PRC_001; collect or record a justified waiver.
4. Attach the vendor risk score from risk-audit.
5. Rank the shortlist; record any waiver used.
6. Mask (template 9) and label (template 4) the evaluation before distribution.
7. Trace the selection with template 7, prefix "prc".
```

### SOP-PRC-02 · Control contract cost on an invoice

```text
1. Diff invoice lines against the contract schedule, line by line.
2. Within 2 % -> pay; record the match.
3. Beyond 2 % -> PRC_002; dispute the delta with the vendor.
4. Withhold the disputed portion against a recorded dispute reference.
5. Never pay first and dispute later - that converts control into collection.
6. Close the dispute with a credit, a corrected invoice or an accepted variance.
```

### SOP-PRC-03 · Route a purchase approval

```text
1. Compare the purchase value against the self-approval limit.
2. Within the limit -> approve and record.
3. Above the limit -> PRC_003; halt the purchase.
4. Route to the correct approval rung with the budget line attached.
5. Record the policy exception; the halt always precedes the routing.
6. Confirm the budget line has room with finance-treasury before the routing is sent.
```

### SOP-PRC-04 · Reconcile metered billing

```text
1. Pull metered usage for the period from the source of record.
2. Match billed units to metered usage within tolerance.
3. All matched -> issue the invoice.
4. Unmatched -> PRC_004; re-meter the period before any adjustment.
5. Quarantine the unmatched units; never write them off silently.
6. Close with a credit or a supplemental invoice; record which.
7. Publish the reconciliation summary with the period close.
```

### SOP-PRC-05 · Compute unit economics

```text
1. List the cost components the decision requires.
2. Source each from finance-treasury or the allocation schedule.
3. A component that cannot be sourced -> PRC_005; identify it by name.
4. Defer the decision while the basis remains unknown - a guess is not a basis.
5. Publish the model with each component sourced and dated.
6. Re-publish when any sourced component moves beyond the recorded tolerance.
```

⚠️ Unit economics is the number every pricing and investment decision quietly rests on. A model
published with an unsourced component is not a basis — it is a preference with decimals.
