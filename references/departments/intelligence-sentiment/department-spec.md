---
department: intelligence-sentiment
domain: growth
parent: ai-company
roles: [Intelligence Officer, Sentiment Analyst]
error_code_prefix: INTEL_
function_blocks: 1
consolidates_group_tier: [competitive-intelligence, sentiment-analysis]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Intelligence & Sentiment — Deep Specification

> D3 depth for [../intelligence-sentiment.md](../intelligence-sentiment.md). Read the D2 page
> first; this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| The weekly WFT-008 window opened, or a competitor signal fired the event trigger | The cycle runs here on both trigger types |
| A subscribed department needs a SITREP | Production and dissemination are here; a partial with gaps marked beats a late one |
| A source failed verification | The register is here; the source is downgraded and excluded until re-verified |
| Material was handled below its classification | Re-classification and the exposure record are here (`INTEL_004`); the rules come from `security-resilience` |
| Sentiment must be collected on a registered topic | The sentiment line runs inside the same cycle, under the same confidence rules |

**Not** this department: classification policy (`security-resilience`), collection-scope
legality for named individuals (`legal-privacy`), brand and channel decisions
(`marketing-partnerships`), strategic interpretation of findings (`executive-strategy`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The table below is the source of truth;
an action outside it is refused and the response names the rung that holds authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Run the WFT-008 cycle and publish with confidence scores | This department | Reversible | — |
| Downgrade a source and exclude it until re-verified (`INTEL_003`) | This department | Reversible | — |
| Re-classify material and restrict distribution (`INTEL_004`) | This department | Reversible with cost | — |
| Issue a partial SITREP with gaps marked (`INTEL_005`) | This department | Reversible | — |
| Restore the register from the last consistent snapshot (`INTEL_006`) | This department + `platform-mlops` | — | — |
| Release material above a requester's clearance | `security-resilience` | — | — |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
executive-strategy
      ▲  SITREP and market context
      │
intelligence-sentiment  ◄──── WFT-008 triggers (schedule / event) ◄──── operations-coordination
      │  ▲
      │  └── classification rules ── security-resilience
      │  └── scope reviews ───────── legal-privacy
      ▼  products to subscribed departments
  marketing-partnerships, executive-strategy, all subscribers
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A The six-phase cycle

The intelligence library's SOP-L01~L06 set is the reference procedure set for the cycle:

| Phase | Entry condition | Exit criterion | Code on failure |
|---|---|---|---|
| 1 Collection | Sources registered | Raw signals gathered with source attribution | `INTEL_001` |
| 2 Processing | Collection complete | Deduplicated, normalized, classified | `INTEL_004` |
| 3 Analysis | Processing complete | Findings with a confidence score per finding | `INTEL_002` |
| 4 Production | Analysis complete | SITREP generated | `INTEL_005` |
| 5 Dissemination | Production complete | Delivered to subscribed departments | — |
| 6 Feedback | Dissemination done | Source reliability ratings updated | `INTEL_003` |

SLA for the whole cycle is 6 h (WFT-008, mode `Auto`). Phases are skipped only with a recorded
reason — a cycle that stops silently is indistinguishable from a cycle that never ran.

### 3.B Source reliability scoring

| Rating | Meaning | Product use |
|---|---|---|
| A — Verified | Multiple independent confirmations, consistent history | Usable as primary evidence |
| B — Usually reliable | Confirmed history, occasional correction | Usable with corroboration |
| C — Unverified | No confirmation attempt yet | Excluded until verified |
| D — Degraded | Two failed collection runs or a failed verification | Excluded; restoration needs re-verification |
| X — Corrupted entry | Register integrity failure | Restored only via snapshot restore |

Every register entry carries its rating, its last-verified timestamp and its verification
history. A rating is never edited in place without the verification attempt recorded.

### 3.C SITREP structure

| Field | Requirement |
|---|---|
| SITREP ID | Trace ID from template 7, prefix `intel` |
| As-of timestamp | The collection window the report reflects |
| Findings | Each with its confidence score and its source rating |
| Source list | Rating per source; a source below C is excluded and named as excluded |
| Gaps | Explicitly marked; a gap is a statement, not an omission |
| Classification | The highest classification among its contents |
| Distribution | The subscription list, verbatim |

A SITREP with an unmarked gap is worse than a late one: downstream readers cannot tell a
missing signal from a quiet market.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `INTEL_001` | Intelligence collection failed | A collection run returned no usable items | 1. Verify source availability and credentials 2. Re-run with a broader window 3. Record the source as degraded if it fails twice |
| `INTEL_002` | Analysis confidence low | A product's confidence score fell below 40 % | 1. Identify the weakest evidence link 2. Collect corroborating sources 3. Publish with the confidence score stated, never omit it |
| `INTEL_003` | Source verification failed | A source could not be verified against the reliability register | 1. Downgrade the source rating 2. Exclude it from products until re-verified 3. Record the verification attempt |
| `INTEL_004` | Classification violation | Material was handled at a classification below its required level | 1. Re-classify immediately 2. Restrict distribution to the corrected level 3. Record the exposure window |
| `INTEL_005` | SITREP generation failed | A situation report could not be produced on schedule | 1. Identify the missing input 2. Issue a partial SITREP with gaps marked 3. Re-issue in full once inputs arrive |
| `INTEL_006` | Source registry corrupted | The reliability register failed its integrity check | 1. Restore from the last consistent snapshot 2. Re-verify entries touched since that snapshot 3. Record the corruption cause |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `executive-strategy` | SITREPs carry the confidence score per finding and the source list with reliability ratings |
| `marketing-partnerships` | Market datasets arrive with their collection window and confidence; a request without a named decision is returned |
| `security-resilience` | Classification rules are inbound only; a downgrade request is a security event, not a workflow error |
| `model-data` | Collection pipelines run over the registered adapters; a failed adapter maps to `MDL_E007`, never a fabricated result |

## 6. Constraints

- ❌ Do not publish a product without its confidence score (`INTEL_002`)
- ❌ Do not include an unverifiable source in a product until re-verified (`INTEL_003`)
- ❌ Do not handle material below its classification, or leave the exposure window unrecorded (`INTEL_004`)
- ❌ Do not delay a SITREP for missing inputs — partial with gaps marked (`INTEL_005`)
- ❌ Do not edit the register around the integrity check — restore from snapshot (`INTEL_006`)
- ❌ Do not collect sentiment on named individuals without a `legal-privacy` scope review
- ❌ Do not disseminate outside the subscription list
- ❌ Do not let a source fail twice without recording it as degraded

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Cycle schedule adherence | Cycle completion timestamp minus window-open timestamp, weekly |
| SITREP punctuality | Production timestamp minus committed schedule time, per issue |
| Confidence publication | Products with a stated score ÷ total products — target 1.00 |
| Register currency | Sources verified within their interval ÷ total sources |
| Register integrity | Passed checks ÷ daily checks |
| Sentiment SLA adherence | Sentiment result timestamps minus cadence due times |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-INTEL-01 · Run the WFT-008 cycle

```text
1. Open on the trigger: schedule (weekly) or event (competitor signal). Mode Auto, SLA 6 h.
2. Phase 1 Collection: gather from registered sources with attribution. No usable items →
   INTEL_001; re-run with a broader window; a source failing twice is recorded degraded.
3. Phase 2 Processing: deduplicate, normalize, classify. Material below its classification →
   INTEL_004; re-classify and restrict immediately.
4. Phase 3 Analysis: confidence score per finding. Below 40 % → INTEL_002; the score is
   published with the product, never omitted.
5. Phase 4 Production: generate the SITREP (SOP-INTEL-03).
6. Phase 5 Dissemination: deliver to the subscription list, verbatim (SOP-INTEL-03 step 5).
7. Phase 6 Feedback: update source ratings from consumer feedback and performance.
8. Close the cycle record. A skipped phase needs a recorded reason.
```

### SOP-INTEL-02 · Score a source and maintain the register

```text
1. Register the source with its class, its access path and its initial rating C.
2. On each verification attempt, record the attempt - pass or fail - with a timestamp.
3. Failure → INTEL_003. Downgrade the rating; exclude the source from products.
4. Two failed collection runs record the source degraded (rating D).
5. Restoration requires re-verification; it is never a manual edit.
6. Integrity check runs daily. Failure → INTEL_006; restore from the last consistent
   snapshot and re-verify every entry touched since.
7. Record the corruption cause and report it to platform-mlops.
```

### SOP-INTEL-03 · Produce a SITREP

```text
1. Confirm analysis is complete; each finding carries a confidence score.
2. Missing input → INTEL_005. Identify the missing input; the partial path is step 5.
3. Assemble per §3.C: findings with scores, source list with ratings, classification,
   as-of timestamp.
4. A gap in coverage is a marked field, never an omission.
5. Partial path: issue with gaps marked; diary the re-issue for when inputs arrive.
6. Distribute to the subscription list verbatim - no department outside it receives a copy.
7. Re-issue in full once inputs arrive; the partial carries a pointer to the full issue.
```

### SOP-INTEL-04 · Collect and analyse sentiment

```text
1. Confirm the topic is registered and its scope confirmed with legal-privacy when named
   individuals are involved. Unconfirmed scope → do not collect.
2. Run collection inside the same window as the intelligence cycle.
3. No usable items → INTEL_001, same handling as SOP-INTEL-01 step 2.
4. Analyse for volume, polarity and confidence; below 40 % → INTEL_002, stated.
5. Handle results at their classification; INTEL_004 applies identically.
6. Publish to the subscription list with the trend against the prior cycle attached.
```

### SOP-INTEL-05 · Handle a classification violation

```text
1. Detect the mismatch: material handled below its required level.
2. Re-classify immediately. Classification rules are inbound from security-resilience.
3. Restrict distribution to the corrected level; recall copies already sent.
4. INTEL_004. Record the exposure window: what was accessible, to whom, for how long.
5. Report to security-resilience with the exposure record.
6. A downgrade request is a security event, not a workflow error - it is never granted
   locally for convenience.
```

⚠️ SOP-INTEL-03 step 6 is the discipline: a SITREP that reaches a department outside the
subscription list is a disclosure incident, however good the analysis was.
