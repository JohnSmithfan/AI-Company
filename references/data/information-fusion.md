# Information Fusion

> L3 depth file for [../data-integration.md](../data-integration.md). Owning department: `model-data`,
> with `intelligence-sentiment` as the primary consumer.

Reconciling multiple sources into one product without hiding the disagreement.

## 1. The Core Rule

**Never pick one source silently.**

A fused value that quietly discards dissent looks like consensus. The reader then assigns it the
confidence of agreement when the underlying evidence was contested. Every fusion records what was
dropped and why.

## 2. Fusion Procedure

```text
1. collect candidate values, each with: source, reliability rating, as-of timestamp
2. exclude sources with no reliability rating        -> INTEL_003
3. group by comparable basis (same unit, same adjustment, same period)
4. detect divergence
5. resolve per the table in section 3
6. compute confidence per section 4
7. publish value + confidence + dissent record
```

Step 3 is where most fusion errors originate: comparing an adjusted close against an unadjusted
one, a quarterly figure against a trailing-twelve-month figure, or two different currencies
produces divergence that is an artifact of basis, not of disagreement.

## 3. Divergence Resolution

| Situation | Resolution | Recorded as |
|---|---|---|
| Numeric, within tolerance (±2 %) | Take the higher-reliability source | agreed, delta noted |
| Numeric, beyond tolerance | Keep both | **contested** |
| Categorical, values differ | Keep both with attribution | **contested** |
| One source stale (> 24 h) | Prefer the fresh source | superseded, with the stale timestamp |
| Source unrated | Exclude from fusion, retain as a lead | excluded (`INTEL_003`) |
| Source compromised | Exclude entirely | excluded (`INTEL_013` at group tier) |
| Bases differ | Normalize to one basis, then re-compare | normalized |

A **contested** field is never resolved by averaging. Averaging two contradictory claims produces a
third claim that no source made.

## 4. Confidence Weighting

```text
confidence = Σ(reliability_i × agreement_i) / Σ(reliability_i)
```

| Term | Definition |
|---|---|
| `reliability_i` | Source rating from the register, 0.0–1.0 |
| `agreement_i` | 1.0 if source i agrees with the fused value, 0.0 if it dissents, partial for numeric proximity |

| Confidence band | Publication rule |
|---|---|
| ≥ 70 % | Publish normally |
| 40 – 69 % | Publish with the score stated prominently |
| < 40 % | Publish **with** the score and the dissent record — `INTEL_002` requires the score, never suppression |

⚠️ A low-confidence finding is information. Suppressing it because it is weak removes the signal
that the evidence is thin, which is worse than publishing a qualified claim.

## 5. Source Reliability Register

Maintained by `intelligence-sentiment`; consumed here.

| Field | Content |
|---|---|
| Source id | Stable identifier |
| Rating | 0.0–1.0 |
| Rating basis | Track record, correction history, independence |
| Last verified | Timestamp — a rating unverified for 90 days decays by 0.1 |
| Status | active / degraded / excluded |

Register corruption raises `INTEL_006`; restore from the last consistent snapshot and re-verify
entries touched since.

## 6. Temporal Fusion

Values from different times are not directly comparable.

| Rule | Detail |
|---|---|
| As-of mandatory | Every value carries its own timestamp |
| Window declaration | The fusion window is stated in the product |
| No forward fill | A missing period is a gap, not a repeat of the prior value |
| Staleness decay | Confidence decays linearly past the class's freshness ceiling |
| Mixed-vintage fusion | Prohibited without an explicit normalization step |

⚠️ Forward filling is the temporal equivalent of rendering a gap as zero — both fabricate
continuity that was not observed.

## 7. Provenance

Every fused product records:

| Element | Purpose |
|---|---|
| Input source list with ratings | Reproducibility |
| Excluded sources and the reason | Auditing the exclusion |
| Dissent record | Preserving the disagreement |
| Confidence score and its band | Calibrating the reader |
| Fusion timestamp and window | Temporal context |
| Trace ID (template 7) | Linking to the originating operation |

A product without provenance cannot be re-derived, which means it cannot be audited or corrected.

## 8. Constraints

- ❌ Do not resolve a conflict by picking one source silently
- ❌ Do not average contradictory values
- ❌ Do not fuse values on different bases without normalizing
- ❌ Do not fuse from an unrated or excluded source
- ❌ Do not suppress a low-confidence finding
- ❌ Do not forward-fill a temporal gap
- ❌ Do not publish a fused product without its dissent record and provenance
