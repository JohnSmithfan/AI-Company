---
department: risk-audit
domain: finance
parent: ai-company
roles: [CRO, Chief Auditor]
error_code_prefix: CRO_
function_blocks: 1
consolidates_group_tier: [risk-management, internal-audit]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Risk & Audit — Deep Specification

> D3 depth for [../risk-audit.md](../risk-audit.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A decision needs a risk number, not a risk adjective | FAIR quantification is owned here |
| An error or loss rate looks like it has crossed a line | Breaker ownership sits here |
| A gated workflow has reached its gate | Stage-gate criteria are owned here |
| An audit request arrives from inside or outside the organization | Internal audit is owned here |
| Residual risk stays above threshold after mitigation | Quiet acceptance is not this department's to give |

**Not** this department: budget arithmetic (`finance-treasury`), vendor scoring
(`procurement-billing`), security gates (`security-resilience`), board ratification
(`board-and-branch`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The matrix below is the source of truth;
an action outside it is escalated, never quietly absorbed.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| FAIR scoring within the method | This department | Reversible | — |
| Breaker open / half-open / close | This department | Reversible | — |
| Stage-gate pass within criteria | This department | Reversible | — |
| Stage-gate waiver | Never — gates are never waived silently | — | — |
| Accepting residual risk above threshold | `executive-strategy` + `board-and-branch` | — | rung 3–4 |
| Publishing an audit finding rated severe | This department reports; the finding's owner remediates | — | `board-and-branch` |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
board-and-branch
      ▲  severe audit findings, accepted residual risk
      │
executive-strategy  ◄──── risk positions, FAIR scores ──── risk-audit
      │  ▲
      │  └── threshold breaches ─── operations-coordination (WFT-003)
      │  └── budget risk positions ─ finance-treasury (WFT-006)
      │  └── security risk scores ── security-resilience
      ▼  thresholds, gate criteria
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A FAIR assessment procedure

```text
1. Confirm all four inputs are present: loss-event frequency, probable loss magnitude,
   vulnerability, control strength. Missing -> CRO_003; list them and stop.
2. Estimates are permitted; each carries a stated confidence, never presented as measurement.
3. Compute the annualized loss expectation.
4. Compute the residual value after the pre-agreed mitigation.
5. Compare against the accepted threshold for the decision class.
6. Record the score, the confidence per estimate, and the review date.
```

⚠️ A decision taken on partial FAIR is not a risk decision — it is a preference wearing a number.

### 3.B Circuit-breaker state machine

| State | Entry | Exit |
|---|---|---|
| CLOSED | Default; failures counted | 5 consecutive failures, or 50 % over 20 calls → OPEN |
| OPEN | Threshold crossed (`CRO_002`) | Cool-down 60 s elapsed → HALF_OPEN |
| HALF_OPEN | Probe traffic only | All 3 probes succeed → CLOSED; any failure → OPEN |

Defaults are fixed in [../../exec/error-recovery.md](../../exec/error-recovery.md) §3. A
department may request tighter thresholds; loosening above the policy ceiling requires escalation.

⚠️ An OPEN breaker with no recorded owner and no review date is an outage nobody is watching.

### 3.C Stage-gate operation

```text
1. The gate is reached; criteria arrive with their measured values.
2. Compare each measured value against its criterion.
3. All pass -> pass, record the result.
4. Any fail -> CRO_004; report the failing criterion with its measured value.
5. The workflow remediates, then re-enters the gate from the start.
6. Never waive: a gate passed by waiver is a gate that no longer exists.
```

### 3.D Evidence retention schedule

| Class | Retention | Review |
|---|---|---|
| Decision and gate records | ≥ 7 years | Annually |
| FAIR assessments and confidences | ≥ 5 years | Annually |
| Audit findings and remediation | ≥ 7 years | Annually |
| Breaker state transitions | ≥ 3 years | Annually |

Evidence is refreshed before its retention window closes; an item past the window is treated as
absent and the control it supported is marked unproven until re-collected.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `CRO_001` | Risk threshold exceeded | A FAIR-scored risk crossed its accepted threshold | 1. Re-score with current data 2. Apply the pre-agreed mitigation 3. Notify `executive-strategy` if residual risk stays above threshold |
| `CRO_002` | Circuit breaker triggered | Error rate or loss rate crossed the breaker threshold | 1. Confirm the breaker state (OPEN) 2. Stop the offending flow 3. Move to HALF_OPEN after the cool-down and probe |
| `CRO_003` | FAIR assessment incomplete | A risk decision was requested without all four FAIR inputs | 1. List the missing inputs 2. Collect or estimate with a stated confidence 3. Re-run the assessment — never decide on partial FAIR |
| `CRO_004` | Gate failure | A stage-gate check failed during a gated workflow | 1. Report the failing criterion with measured value 2. Remediate 3. Re-enter the gate — gates are never waived silently |
| `CRO_005` | Risk register stale | A register entry passed its review date by >30 days | 1. Re-score the entry 2. Confirm or retire it 3. Update the next review date |
| `CRO_006` | Audit evidence insufficient | An audit request could not be satisfied from the retained evidence | 1. Identify the evidence gap 2. Extend retention for the affected class 3. Report the gap to `board-and-branch` |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `executive-strategy` | Risk positions carry the FAIR score and the residual-after-mitigation value; a position without both is returned |
| `operations-coordination` | Threshold breaches arrive with the measured value and the threshold; an alert without both is returned unactioned |
| `finance-treasury` | WFT-006 risk positions are supplied per commitment, not per budget line |
| `security-resilience` | Security risk is FAIR-scored jointly; breaker thresholds are owned here, security gates there |

## 6. Constraints

- ❌ Do not decide on partial FAIR — four inputs or no decision (`CRO_003`)
- ❌ Do not waive a stage gate silently (`CRO_004`)
- ❌ Do not leave a breaker open without a recorded owner and review date
- ❌ Do not let a register entry pass its review date (`CRO_005`)
- ❌ Do not close an audit request against evidence that was never retained (`CRO_006`)
- ❌ Do not accept residual risk above threshold without escalation
- ❌ Do not re-score a risk to reach a preferred answer
- ❌ Do not approve a tier upgrade — no department may

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| FAIR completeness | Decisions with all four inputs ÷ total risk decisions |
| Breaker state discipline | OPEN incidents with owner and review date ÷ total OPEN incidents |
| Gate reporting | Failures reported with measured value ÷ total failures |
| Register currency | Entries within review date ÷ total entries |
| Audit evidence coverage | Requests satisfied from retained evidence ÷ total requests |
| Threshold breach latency | Breach detection timestamp minus alert timestamp |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-CRO-01 · Run a FAIR assessment

```text
1. Confirm all four inputs are present. Missing -> CRO_003, list them, stop.
2. Mark each estimate with its stated confidence.
3. Compute the annualized loss expectation.
4. Compute the residual value after the pre-agreed mitigation.
5. Compare against the accepted threshold for the decision class.
6. Record the score, the confidences and the review date.
7. Mask (template 9) and label (template 4) before distribution; trace (template 7, prefix "cro").
8. Attach the score to the decision request; a decision routed without it is returned.
```

### SOP-CRO-02 · Operate a circuit breaker

```text
1. On a threshold crossing, confirm the state is OPEN before stopping the flow (CRO_002).
2. Stop the offending flow; record the owner and the review date.
3. Wait the cool-down (60 s default), then admit probe traffic (HALF_OPEN).
4. All 3 probes succeed -> CLOSED. Any failure -> OPEN again.
5. A second breaker-open incident for the same department within 30 days ->
   open a structural review; do not adjust the threshold again.
```

### SOP-CRO-03 · Run a stage-gate check

```text
1. Collect the criteria with their measured values.
2. Compare each measured value against its criterion.
3. All pass -> record the pass with the measured values attached.
4. Any fail -> CRO_004; report the failing criterion with its measured value.
5. The workflow remediates, then re-enters the gate from the start.
6. Never waive; never re-run only the failing criterion in isolation.
7. Record the gate result with its trace ID for the audit trail.
```

### SOP-CRO-04 · Maintain the risk register

```text
1. Every entry carries a review date at creation.
2. Weekly, flag entries within 30 days of their review date.
3. An entry past its review date by >30 days -> CRO_005.
4. Re-score the entry, then confirm or retire it.
5. Update the next review date; a retired entry is superseded, never deleted silently.
6. Report the register's stale-entry count in the monthly risk summary.
```

### SOP-CRO-05 · Handle an internal audit request

```text
1. Log the request with its scope and its requester.
2. Attempt to satisfy it from retained evidence only.
3. Cannot -> CRO_006; identify the evidence gap.
4. Extend retention for the affected class; record the extension.
5. Report the gap to board-and-branch - an audit gap is never absorbed internally.
6. Publish the findings with severity and owner; severe findings go to board-and-branch.
7. Track each finding to remediation closure; an unclosed finding is a finding, not a note.
```

⚠️ The audit function exists to say what is true, not what is convenient. A finding softened to
avoid an escalation is a compliance failure wearing an audit report.
