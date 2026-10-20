---
department: finance-treasury
domain: finance
parent: ai-company
roles: [CFO, Treasurer]
error_code_prefix: CFO_
function_blocks: 1
consolidates_group_tier: [financial-management, treasury-budget]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Finance & Treasury — Deep Specification

> D3 depth for [../finance-treasury.md](../finance-treasury.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A commitment must be weighed against the remaining budget | Desirability belongs to `executive-strategy`; affordability belongs here |
| A price is proposed without a margin computation | Pricing models are owned here — `procurement-billing` supplies cost inputs, not the price |
| Two ledgers disagree about the cash position | Treasury reconciliation is owned here; `risk-audit` scores the exposure, it does not reconcile |
| DSO or DPO drifts outside its target band | Working-capital targets are owned here |
| A capex request arrives without a recorded approval | The capex policy gate sits here |

**Not** this department: risk quantification (`risk-audit`), vendor evaluation
(`procurement-billing`), commitment authority beyond the CFO ceiling (`executive-strategy`),
board ratification (`board-and-branch`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The matrix below is the source of truth;
an action outside it is escalated with the rung that holds authority named, not merely refused.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Budget line approval within the envelope | This department | Reversible | — |
| Variance beyond the ceiling (>10 %) | This department + recorded analysis | Reversible with cost | `executive-strategy` |
| Pricing within band, above the floor | This department | Reversible | — |
| Price below the margin floor | `executive-strategy` | Reversible with cost | rung 3 |
| Capex within the policy ceiling | This department | Irreversible | — |
| Capex above the policy ceiling | `board-and-branch` | Irreversible | rung 4 |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
board-and-branch
      ▲  capex above the policy ceiling
      │
executive-strategy
      ▲  budget position for commitment authority
      │
finance-treasury  ◄──── budget requests ────── all departments
      │  ▲
      │  └── contracted spend ───── procurement-billing
      │  └── risk positions ─────── risk-audit
      │  └── source datasets ────── model-data
      ▼  budget decisions, variance directives
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Variance procedure

Triggered by `CFO_001`. The sequence is fixed:

```text
1. Freeze non-essential spend on the affected line immediately.
2. Produce the variance analysis: driver, magnitude, period, recurrence.
3. Split the position: committed / encumbered / free.
4. Submit to executive-strategy with the analysis attached - never as a bare number.
5. Record the decision and the effective date of any re-baseline.
```

⚠️ An overrun absorbed silently into the next quarter's envelope is not a variance — it is a
budget that no longer means anything.

### 3.B Pricing validation

```text
1. Obtain the current cost basis from procurement-billing.
2. Recompute unit economics; compare against the margin floor.
3. Check the elasticity assumption against the sanity band.
4. Fail either check -> CFO_002; revise or reject, never ship unpriced.
5. Record the checked price with both test results attached.
6. Re-validate whenever the cost basis moves beyond the recorded tolerance.
```

A price is re-validated whenever the cost basis moves beyond the recorded tolerance — a price
approved against a stale cost basis is a margin leak wearing an approval stamp.

### 3.C Treasury reconciliation

| Step | Rule |
|---|---|
| Sources | Every source ledger, every day — a weekly reconciliation is not a reconciliation |
| Tolerance | The delta must fit the recorded tolerance, or it is quarantined |
| Quarantine | The delta is named, owned and dated — it is never spread across lines |
| Publication | The reconciled position is published by 09:00 local, with the quarantine list attached |
| Escalation | An unreconciled delta at close raises `CFO_006` and goes to the `internal-audit` function block |

### 3.D Analytics freshness rule

| Source age | Permitted use |
|---|---|
| ≤ 24 h | Publish without caveat |
| > 24 h | `CFO_003`; request the refresh from `model-data` before publishing |
| Urgent | Publish with an explicit data-freshness caveat naming the as-of timestamp |

⚠️ "The data is probably current" is not a freshness statement. The as-of timestamp is published
with the pack, or the pack is withheld — a stale number presented as current is a defect, not a
caveat.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `CFO_001` | Budget overrun | Department spend exceeded its quarterly budget by >10 % | 1. Freeze non-essential spend 2. Produce a variance analysis 3. Submit to `CEO_002` for approval |
| `CFO_002` | Pricing model invalid | A proposed price failed the margin floor or the elasticity sanity band | 1. Recompute unit economics 2. Compare against the margin floor 3. Revise or reject — do not ship an unpriced offer |
| `CFO_003` | Analytics data missing | A financial report was requested but its source dataset is absent or stale >24 h | 1. Identify the missing source 2. Request refresh from `model-data` 3. Publish with an explicit data-freshness caveat if urgency demands |
| `CFO_004` | Working capital target breached | DSO exceeded 45 days or DPO fell below 30 days | 1. Age the receivables/payables ledger 2. Escalate the top 5 exposures 3. Adjust collection or payment cadence |
| `CFO_005` | Capex approval missing | A capital expenditure was initiated without a recorded approval | 1. Halt the expenditure 2. Retro-file the approval request 3. Record the policy exception |
| `CFO_006` | Treasury position inconsistent | Cash position could not be reconciled across sources within tolerance | 1. Re-run reconciliation from source ledgers 2. Quarantine the unreconciled delta 3. Report to `internal-audit` function block |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `executive-strategy` | The budget position is supplied as committed + encumbered + free; a single total is returned as incomplete |
| `procurement-billing` | Contracted spend is reported against budget lines, not against vendors — the budget line is the unit of control |
| `risk-audit` | Risk positions arrive with the FAIR score attached; a position without one is returned |
| `model-data` | Refresh requests carry the report's as-of timestamp; a stale source publishes with an explicit caveat, never silently |

## 6. Constraints

- ❌ Do not approve spend beyond the quarterly budget without a variance analysis (`CFO_001`)
- ❌ Do not ship a price that failed the margin floor or the elasticity band (`CFO_002`)
- ❌ Do not publish analytics on a stale source without the data-freshness caveat (`CFO_003`)
- ❌ Do not initiate capex without a recorded approval (`CFO_005`)
- ❌ Do not publish an unreconciled cash position (`CFO_006`)
- ❌ Do not treat DSO/DPO drift as seasonal before the ledger is aged (`CFO_004`)
- ❌ Do not supply a budget position as a single total
- ❌ Do not approve a tier upgrade — no department may

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Variance analysis lead time | Overrun detection timestamp minus analysis publication timestamp |
| Price first-pass rate | Prices passing floor and band on first submission ÷ total submissions |
| Analytics freshness | Report publication timestamp minus source-dataset as-of timestamp |
| Reconciliation coverage | Days with a completed cross-source reconciliation ÷ business days |
| Working-capital drift | DSO/DPO measurement minus target band, per month |
| Capex approval coverage | Capex items approved before initiation ÷ total capex items |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-CFO-01 · Run the quarterly budget review (WFT-006)

```text
1. Collect every department's budget request with prior-period actuals.
2. Validate each request carries committed, encumbered and free amounts (template 1).
3. Approve or refuse within the envelope; refusals name the missing element.
4. Route any line above the CFO ceiling to executive-strategy before publication.
5. Publish the approved set with trace IDs (template 7, prefix "cfo").
6. Mask (template 9) and label (template 4) before distribution.
7. Set the variance-review date for each line - a budget with no review date is never revisited.
```

### SOP-CFO-02 · Handle a budget overrun

```text
1. On CFO_001, freeze non-essential spend on the affected line.
2. Produce the variance analysis: driver, magnitude, period, recurrence.
3. Split the position: committed / encumbered / free.
4. Submit to executive-strategy with the analysis attached.
5. Record the decision, the re-baseline and its effective date.
6. Never absorb the overrun silently into the next quarter's envelope.
7. Flag the line for the next quarterly review regardless of the decision taken.
```

### SOP-CFO-03 · Validate a pricing model

```text
1. Obtain the current cost basis from procurement-billing.
2. Recompute unit economics; compare against the margin floor.
3. Check the elasticity assumption against the sanity band.
4. Fail either check -> CFO_002; revise or reject, never ship unpriced.
5. Record the price with both test results attached.
6. Re-validate whenever the cost basis moves beyond the recorded tolerance.
```

### SOP-CFO-04 · Reconcile the treasury position

```text
1. Pull every source ledger for the day - bank, payment processor, internal.
2. Re-run reconciliation from source ledgers, never from the prior day's total.
3. If the delta fits tolerance, publish the reconciled position by 09:00 local.
4. If not, quarantine the delta: name, owner, date.
5. Raise CFO_006; report the quarantined delta to the internal-audit function block.
6. Close the quarantine only from source evidence, never by adjusting the total.
```

### SOP-CFO-05 · Rule on a capex request

```text
1. Confirm the request carries a business case and an approval record.
2. Missing approval -> CFO_005; halt the expenditure.
3. Retro-file the approval request; record the policy exception.
4. Within the policy ceiling: rule within 5 business days of a complete request.
5. Above the ceiling: route to board-and-branch with the business case attached.
6. Record the ruling with its authority basis and review date.
7. Track the spend against the approved envelope from the first draw-down.
```

⚠️ The capex gate is the last point at which stopping is cheap. After initiation, stopping is a
write-off; the halt-and-file sequence exists so the cheap stop is never skipped.
