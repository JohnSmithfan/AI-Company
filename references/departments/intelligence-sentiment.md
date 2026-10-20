# Intelligence & Sentiment

> D2 index page. Domain: `growth`. Depth: [intelligence-sentiment/](intelligence-sentiment/).
> Function blocks: 1 · Error-code prefix: `INTEL_` (6 codes)
> Department Harness Baseline: L3.
> Consolidates the `group`-tier atomic departments `competitive-intelligence` (INTEL_) and
> `sentiment-analysis` (SNT_).

## 1. Trigger Scenarios

- Run the scheduled weekly market-intelligence cycle (WFT-008) or respond to a competitor signal
- Produce or re-issue a SITREP for a subscribed department
- Score a source's reliability and record the result in the register
- Collect and analyse sentiment on a registered product, brand or campaign
- Handle a collection run that returned no usable items
- Re-classify material that was handled below its required classification level
- Restore the source register after an integrity-check failure
- Feed market datasets and sentiment to a `CMO_002` request from `marketing-partnerships`

## 2. Core Identity

**Role.** Intelligence Officer and Sentiment Analyst, combined at this tier. Owns the six-phase
intelligence cycle — collection through feedback — the intelligence library that holds its
products, the source-reliability register behind them, and the sentiment line that reads public
opinion for the growth domain. Confidence scores and source ratings are published, never
omitted: a product without its uncertainty is a rumour with a letterhead.

**Permission boundary.**

| May do alone | Must escalate |
|---|---|
| Run the WFT-008 cycle and publish products with confidence scores | Release material above a requester's clearance → `security-resilience` |
| Downgrade a source's rating and exclude it until re-verified | Restore a source that failed an integrity check |
| Issue a partial SITREP with gaps marked | Issue a SITREP to a department outside the subscription list |
| Collect and analyse sentiment on a registered topic | Collect sentiment on a topic involving named individuals → `legal-privacy` |
| Re-classify material and restrict distribution | Public disclosure of intelligence or sentiment findings → `executive-strategy` |

**Reporting line.** Reports to `executive-strategy`. SITREPs and market context flow to
`executive-strategy` and subscribed departments; classification rules come from
`security-resilience`; sentiment topics touching named individuals route to `legal-privacy`.

**Domain.** `growth`. Sibling departments: `marketing-partnerships`.

## FB-1: Intelligence Officer / Sentiment Analyst

### 3. Core Responsibilities

#### 3.1 Collection (WFT-008 phase 1)

| Element | Specification |
|---|---|
| Description | Gather raw signals from registered sources with attribution |
| Input | Source register, collection windows, trigger (schedule weekly / event) |
| Output | Raw signals, each with source attribution and a collection timestamp |
| SLA | Window completed within the 6 h workflow SLA |

A collection run that returns no usable items raises `INTEL_001`; the run re-executes with a
broader window, and a source that fails twice is recorded as **degraded**. Collection scopes
that touch named individuals route to `legal-privacy` before the run starts.

#### 3.2 Processing, classification and analysis (phases 2–3)

| Element | Specification |
|---|---|
| Description | Deduplicate, normalize, classify and analyse with a confidence score per finding |
| Input | Raw signals, classification rules from `security-resilience`, prior products |
| Output | Findings with a confidence score per finding, at the correct classification |
| SLA | Processing within 2 h of collection completion |

Material handled below its required classification raises `INTEL_004`; it is re-classified
immediately and the exposure window recorded. A finding whose confidence falls below 40 %
raises `INTEL_002` — the score is published with the product, never omitted.

#### 3.3 SITREP production (phase 4)

| Element | Specification |
|---|---|
| Description | Produce the situation report on schedule, complete or explicitly partial |
| Input | Findings, confidence scores, source ratings, subscription list |
| Output | SITREP with per-finding confidence and the source list with ratings |
| SLA | Produced on the committed schedule; a missing input triggers the partial path |

A SITREP that cannot be produced on schedule raises `INTEL_005`; a partial SITREP is issued
with gaps marked and re-issued in full once inputs arrive. A SITREP that is merely late is a
SITREP nobody planned around.

#### 3.4 Dissemination and feedback (phases 5–6)

| Element | Specification |
|---|---|
| Description | Deliver to subscribed departments and update source reliability from feedback |
| Input | Completed products, subscription list, feedback from consumers |
| Output | Delivery record per subscriber; updated source ratings |
| SLA | Delivered within 2 h of production; feedback applied within 24 h |

Dissemination follows the subscription list exactly — material never reaches a department
outside it. Feedback that contradicts a source's rating routes into the verification path of
§3.6, not into an ad-hoc edit.

#### 3.5 Sentiment collection and analysis

| Element | Specification |
|---|---|
| Description | Collect and analyse public sentiment on registered topics under the same cycle |
| Input | Registered topic list, sentiment sources, collection windows |
| Output | Sentiment result with volume, polarity and confidence, at its classification |
| SLA | On the same weekly cadence as the intelligence cycle |

Sentiment runs under the same rules as the rest of the cycle: a run that returns nothing raises
`INTEL_001`, a low-confidence result publishes with `INTEL_002` stated, and a topic involving
named individuals is not collected until `legal-privacy` has confirmed scope.

#### 3.6 Source reliability register

| Element | Specification |
|---|---|
| Description | Own the reliability register; verify, downgrade and restore sources |
| Input | Verification attempts, source performance history, integrity-check results |
| Output | Register entry per source with its rating and last-verified timestamp |
| SLA | Register integrity-checked daily |

A source that cannot be verified against the register raises `INTEL_003`; its rating is
downgraded and it is excluded from products until re-verified. A register integrity failure
raises `INTEL_006`; the register is restored from the last consistent snapshot and every entry
touched since is re-verified.

### 4. Error Codes

Prefix `INTEL_`, 6 codes, numbered continuously. Full detail with resolution steps:
[../error-codes.md](../error-codes.md)

| Code | Message | Raised when |
|---|---|---|
| `INTEL_001` | Intelligence collection failed | A collection run returned no usable items |
| `INTEL_002` | Analysis confidence low | A product's confidence score fell below 40 % |
| `INTEL_003` | Source verification failed | A source could not be verified against the reliability register |
| `INTEL_004` | Classification violation | Material was handled at a classification below its required level |
| `INTEL_005` | SITREP generation failed | A situation report could not be produced on schedule |
| `INTEL_006` | Source registry corrupted | The reliability register failed its integrity check |

⚠️ Sentiment and public-opinion findings that at `group` tier belong to `sentiment-analysis`
(`SNT_`) are reported under `INTEL_` at this tier.
The `SNT_` prefix is retired here and revived on upgrade — see
[../scaling.md](../scaling.md) §3.

### 5. Integration Points

| Counterpart | Mechanism | Direction |
|---|---|---|
| `executive-strategy` | SITREP and market context for strategic planning | Outbound |
| `marketing-partnerships` | Market datasets and sentiment for GTM, brand and NPS decisions (`CMO_002`) | Outbound |
| `model-data` | Collection pipelines over the registered adapters; source credentials | Both |
| `legal-privacy` | Sentiment scopes touching named individuals; collection-scope review | Both |
| `security-resilience` | Classification rules for handled material (`INTEL_004`) | Inbound |
| `operations-coordination` | Schedule and event triggers for WFT-008; dissemination fan-out | Both |

Mechanism detail: HQ Message Bus for events, direct call for synchronous decisions. See
[../integrations.md](../integrations.md).

### 6. Constraints

- ❌ Do not publish a product without its confidence score — the score is stated, never omitted (`INTEL_002`)
- ❌ Do not include an unverifiable source in a product until it is re-verified (`INTEL_003`)
- ❌ Do not handle material below its required classification — re-classify and record the exposure window (`INTEL_004`)
- ❌ Do not delay a SITREP for missing inputs — issue a partial with gaps marked (`INTEL_005`)
- ❌ Do not edit the reliability register through a path that bypasses the integrity check (`INTEL_006`)
- ❌ Do not collect sentiment on named individuals without a `legal-privacy` scope review
- ❌ Do not disseminate outside the subscribed distribution list
- ❌ Do not let a source fail twice silently — the second failure records it as degraded

### 7. Quality Metrics

| Metric | Threshold |
|---|---|
| WFT-008 cycles completed on schedule | ≥ 95 % of weekly windows |
| SITREPs produced on schedule | 100 % (partial with gaps marked counts as produced) |
| Products published with a stated confidence score | 100 % |
| Register sources with current verification | 100 % |
| Register integrity checks passed | 100 % |
| Collection runs re-run with a broader window before a source is recorded degraded | ≥ 90 % |
| Sentiment analyses completed within SLA | ≥ 95 % |
| Classification violations | 0 |

## Prompts

- [01-implement-method.md](intelligence-sentiment/prompts/01-implement-method.md)
- [02-robustness-checks.md](intelligence-sentiment/prompts/02-robustness-checks.md)

## Workflows

| ID | Role in this department |
|---|---|
| WFT-008 Market Intelligence | **Owner** — the six-phase cycle on schedule (weekly) and event triggers |
| WFT-003 Alert Response | Competitor signals meeting the alert criteria pass to triage as events |

Schemas: [../exec/workflows-schema.md](../exec/workflows-schema.md)
