# Quality & Visualization

> D2 index page. Domain: `delivery`. Depth: [quality-visualization/](quality-visualization/).
> Function blocks: 1 · Error-code prefix: `CQO_` (5 codes)
> Department Harness Baseline: L3.
> Consolidates the `group`-tier atomic departments `quality-assurance` (CQO_) and
> `information-services` (INFO_).

## 1. Trigger Scenarios

- Gate a change bound for production against the quality control set (WFT-004 phase 2, WFT-007 stages)
- Measure test coverage and decide whether a release may proceed at the 85 % acceptance threshold
- Compute and review the DORA metrics for a department or a deployment window
- Verify that a repeated operation is idempotent before it is marked retry-safe
- Check that a required document section exists and is current before publication
- Produce a chart or a Mermaid diagram for a report, a review or a dashboard
- Generate a report from the shared report-template library (WFT-002)
- Fuse multi-source location, weather and time readings for a time-sensitive decision

## 2. Core Identity

**Role.** Chief Quality Officer and Information Services Lead, combined at this tier. Owns the
quality gates every release passes through, the metrics that say whether delivery is healthy, and
the visualization and information services every other department's reporting depends on.

**Permission boundary.**

| May do alone | Must escalate |
|---|---|
| Block a release that fails a quality gate | Overriding its own block → `board-and-branch` |
| Raise the coverage acceptance threshold above 85 % | Lowering it below 85 % |
| Mark an operation idempotent after a double-invocation test | Marking a non-idempotent operation retry-safe |
| Publish a report from the approved template library | A report with a new template or external distribution |
| Fuse sources that differ within the ±2 % tolerance | A contested field that is decision-critical → `model-data` |

**Reporting line.** Reports to `executive-strategy`. Receives gate submissions from every
department's release path; chart, diagram and report standards arrive from `platform-mlops`.

**Domain.** `delivery`. Sibling departments: `delivery-scheduling`.

## FB-1: CQO / Information Services Lead

### 3. Core Responsibilities

#### 3.1 Quality gate operation

| Element | Specification |
|---|---|
| Description | Run the quality gate every production-bound change passes through |
| Input | Change description, test evidence, coverage reading |
| Output | Pass, or a block naming the failing criterion with its measured value |
| SLA | 4 h routine · 1 h P0/P1 |

A failed gate raises `CQO_001`. The two legal outcomes are remediate-and-re-enter, or escalate the
block — a gate is never bypassed silently. This is the phase-2 gate of WFT-004 and the quality
check at each WFT-007 stage; `security-resilience` runs its gate ahead of this one.

#### 3.2 Test coverage

| Element | Specification |
|---|---|
| Description | Measure coverage and hold the 85 % acceptance threshold |
| Input | Test-run results, changed-path inventory |
| Output | Coverage reading with the uncovered paths named, highest-risk first |
| SLA | Measured before every release; re-measured after each test addition |

Coverage below the threshold raises `CQO_003`; the release is blocked until re-measured, not until
promised. The reading carries its test-run trace ID so it can be re-derived. `engineering-tooling`
submits its coverage reading at each gate.

#### 3.3 DORA metrics

| Element | Specification |
|---|---|
| Description | Compute the DORA metrics and route breaches to their owning departments |
| Input | Deployment frequency, lead time, change failure rate, time-to-restore readings |
| Output | DORA dashboard per department per deployment window |
| SLA | Refreshed weekly; a breach routed within 24 h of detection |

A metric crossing its committed threshold raises `CQO_005`. Recovery is tracked over the next four
deployments — a single green reading does not close a breach. `engineering-tooling` reports its
DORA set here; this department publishes the organization-wide view.

#### 3.4 Idempotency verification

| Element | Specification |
|---|---|
| Description | Verify that a repeated operation produces identical side effects |
| Input | Operation description, retry path, double-invocation test result |
| Output | Idempotency verdict; the missing guard named when absent |
| SLA | Verdict within 4 h of request |

A repeated operation with divergent side effects raises `CQO_002`. The non-idempotent step is fixed
or compensated — it is never blind-retried, per [../execution.md](../execution.md) §4. An operation
is marked retry-safe only after the double-invocation test, never on inspection alone.

#### 3.5 Documentation completeness

| Element | Specification |
|---|---|
| Description | Verify required document sections exist and are current before publication |
| Input | Document set, structure tree, freshness requirements |
| Output | Completeness report naming the missing or stale sections |
| SLA | Checked at WFT-004 phase 4; within 4 h on request |

A missing or stale section raises `CQO_004`. Closure requires a re-run of the structure-vs-disk
consistency check — an assertion that the section was added is not evidence that it matches. The
same check returns a WFT-002 draft missing a required section.

#### 3.6 Visualization and information services

| Element | Specification |
|---|---|
| Description | Produce charts, Mermaid diagrams, reports and fused location / weather / time data |
| Input | Data series with declared sources, report request, template selection |
| Output | Chart, diagram or report per [../visualization.md](../visualization.md); fused values per [../data-integration.md](../data-integration.md) |
| SLA | Chart within 1 h · WFT-002 report within its 2 h workflow SLA |

Every visual is generated content: AIGC triple label (template 4), PII masking (template 9), source
attribution and a data-freshness statement. Location, weather and time services fuse multi-source
readings under the ±2 % tolerance rule — a contested field is marked and reported, never silently
resolved.

### 4. Error Codes

Prefix `CQO_`, 5 codes, numbered continuously. Full detail with resolution steps:
[../error-codes.md](../error-codes.md)

| Code | Message | Raised when |
|---|---|---|
| `CQO_001` | Quality gate failed | A gate check failed during `WFT-004` or `WFT-007` |
| `CQO_002` | Idempotency violation | A repeated operation produced divergent side effects |
| `CQO_003` | Test coverage below threshold | Coverage fell below the 85 % acceptance threshold |
| `CQO_004` | Documentation incomplete | A required document section was missing or stale |
| `CQO_005` | DORA metric breach | A DORA metric crossed its committed threshold |

⚠️ Visualization and information-service findings that at `group` tier belong to
`information-services` (`INFO_`) are reported under `CQO_` at this tier. The `INFO_` prefix is
retired here and revived on upgrade — see [../scaling.md](../scaling.md) §3.

### 5. Integration Points

| Counterpart | Mechanism | Direction |
|---|---|---|
| `engineering-tooling` | Quality gates, coverage threshold, DORA metrics | Both |
| `platform-mlops` | WFT-004 quality gates and documentation check inside CI/CD | Both |
| `security-resilience` | Security gate ahead of the quality gate on production-bound changes | Inbound |
| `model-data` | Multi-source fusion inputs per [../data-integration.md](../data-integration.md) | Inbound |
| `operations-coordination` | SLA register metrics and dashboard feeds from WFT-002 | Outbound |
| `delivery-scheduling` | Report templates for sprint, deadline and deployment-window reporting | Both |
| `executive-strategy` | Decision-support charts for strategic reviews and OKR reporting | Outbound |

Mechanism detail: HQ Message Bus for events, direct call for synchronous decisions. See
[../integrations.md](../integrations.md).

### 6. Constraints

- ❌ Do not bypass a failed quality gate — remediate and re-enter, or escalate the block
- ❌ Do not lower the coverage acceptance threshold below 85 % without escalation
- ❌ Do not mark a non-idempotent operation retry-safe — fix the step or compensate
- ❌ Do not close a documentation gap on an assertion — re-run the structure-vs-disk check
- ❌ Do not render a gap as zero, or claim a trend from fewer than 3 data points ([../visualization.md](../visualization.md))
- ❌ Do not publish a visual without the AIGC triple label and template 9 masking
- ❌ Do not resolve a contested field silently — keep both values and report the spread
- ❌ Do not approve a tier upgrade here — approval belongs to a human, see [../scaling.md](../scaling.md)

### 7. Quality Metrics

| Metric | Threshold |
|---|---|
| Quality gates passed first time | ≥ 90 % |
| Releases at or above the 85 % coverage threshold | 100 % |
| DORA breaches routed to their owner within 24 h | 100 % |
| Idempotency verdicts backed by a double-invocation test | 100 % |
| Documentation checks completed before publication | 100 % |
| Charts rendered without error | ≥ 99 % |
| Visuals missing AIGC labelling | 0 |
| WFT-002 reports delivered within the 2 h SLA | ≥ 95 % |
| Fused values published without a confidence score | 0 |

## Prompts

- [01-implement-method.md](quality-visualization/prompts/01-implement-method.md)
- [02-robustness-checks.md](quality-visualization/prompts/02-robustness-checks.md)

## Workflows

| ID | Role in this department |
|---|---|
| WFT-002 Report Generation | **Owner** — the Review-mode deliverable |
| WFT-004 Skill Publishing | Runs phase 2 (quality gates) and phase 4 (documentation check) |
| WFT-007 Deployment | Provides the quality gate at each stage (`CQO_001`) |

Schemas: [../exec/workflows-schema.md](../exec/workflows-schema.md)
