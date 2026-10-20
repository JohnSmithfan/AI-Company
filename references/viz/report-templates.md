# Report Templates

> L3 depth file for [../visualization.md](../visualization.md). Owning department: `quality-visualization`.

## 1. Mandatory Elements (every report)

| Element | Source | Why |
|---|---|---|
| Generation timestamp, TZ-aware UTC | Template 4 | Naive timestamps make cross-region comparison ambiguous |
| Trace ID | Template 7 | Auditability back to the triggering operation |
| AIGC triple label | Template 4 envelope | Explicit label + implicit metadata + watermark |
| Data-freshness statement | Each source's collection time | A reader must know how stale the inputs are |
| Source list | Named per data series | Reproducibility |
| Authoring department | The owning slug | Accountability |

A report missing any of these is incomplete — `CQO_004`.

## 2. Template: Operational Daily

Produced by WFT-002. Audience: department owners.

```markdown
# Operational Daily — <date> — <department>

| Metric | Value | Threshold | Status |
|---|---|---|---|
| <metric> | <value> | <threshold> | OK / BREACH |

## Exceptions
- <exception> — owner <slug> — action due <date>

## Actions due
| Action | Owner | Due | Status |
|---|---|---|---|

## Data freshness
| Source | Collected at | Age |
|---|---|---|
```

Rule: a metric in BREACH must have a named owner and a due date in the same report. Reporting a
breach without an owner is how breaches become permanent.

## 3. Template: Weekly Department

```markdown
# Weekly — <week> — <department>

## Quality metrics vs threshold
| Metric | This week | Last week | Threshold | Trend |
|---|---|---|---|---|

## Highlights
## Risks
| Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|

## Next week commitments
```

Trend column rules: compute from ≥ 3 points; a 2-point change is a delta, not a trend; a gap is
never treated as zero.

## 4. Template: Incident Post-mortem

Produced by WFT-005 phase 7. Audience: `board-and-branch`, `risk-audit`.

```markdown
# Post-mortem — <incident id> — <severity>

## Summary (≤ 5 sentences)
## Timeline
| Time (UTC) | Event | Actor | Evidence |
|---|---|---|---|

## Root cause
## Contributing factors
## Containment
## Actions
| Action | Owner | Due | Type (prevent/detect/mitigate) |
|---|---|---|---|

## Evidence preservation note
```

Rules:
- The timeline starts at **detection**, not at the underlying fault, and states the detection lag
- Root cause is a mechanism, not a person. "The agent misconfigured X" is a mechanism; "the
  engineer was careless" is not acceptable content
- Every action has an owner, a due date and a type
- The evidence note records what was preserved before remediation — remediation destroys evidence,
  so its preservation must be explicit (`IRP_002` when incomplete)

## 5. Template: Budget Variance

Produced by WFT-006. Audience: `board-and-branch`.

```markdown
# Budget variance — <period> — <department>

| Line | Budget | Actual | Variance | Variance % | Driver |
|---|---|---|---|---|---|

## Forecast to period end
## Working capital
| Metric | Value | Target |
|---|---|---|
| DSO | <days> | ≤ 45 |
| DPO | <days> | ≥ 30 |

## Approval chain
```

Rule: every variance beyond ±10 % carries a named driver. An unexplained variance does not pass
WFT-006 phase 3 — `CFO_001` on overrun.

## 6. Template: Market Intelligence SITREP

Produced by WFT-008. Audience: `executive-strategy`, requesting departments.

```markdown
# SITREP — <period> — <topic>

## Bottom line up front (≤ 3 sentences)
## Findings
| Finding | Confidence | Sources | As-of |
|---|---|---|---|

## Source reliability
| Source | Rating | Notes |
|---|---|---|

## Recommended action
## What would change this assessment
```

Rules:
- Confidence is published for every finding, including when it is below 40 % (`INTEL_002`) — a low
  score is information, not an embarrassment
- "What would change this assessment" is mandatory; an assessment without falsification conditions
  is not analysis
- Unverifiable sources are listed separately and excluded from findings (`INTEL_003`)

## 7. Template: Upgrade Proposal

Produced by WFT-010. The authoritative template lives in [../scaling.md](../scaling.md) §7 — do not
duplicate it here. This entry exists so the report family is complete.

## 8. Constraints

- ❌ Do not publish a report missing any mandatory element
- ❌ Do not report a threshold breach without an owner and a due date
- ❌ Do not claim a trend from fewer than 3 data points
- ❌ Do not treat a data gap as zero
- ❌ Do not name a person as a root cause
- ❌ Do not omit the confidence score on an intelligence finding
- ❌ Do not duplicate the upgrade proposal template — link to scaling.md
