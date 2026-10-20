---
department: quality-visualization
domain: delivery
parent: ai-company
roles: [CQO, Information Services Lead]
error_code_prefix: CQO_
function_blocks: 1
consolidates_group_tier: [quality-assurance, information-services]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Quality & Visualization — Deep Specification

> D3 depth for [../quality-visualization.md](../quality-visualization.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A release is ready for its quality gate | Gate operation sits here; the promote/halt decision sits with `engineering-tooling` |
| Coverage must be measured before a release proceeds | The 85 % acceptance threshold is owned here |
| A DORA reading is needed for a department or a window | DORA reporting is owned here organization-wide |
| An operation is about to be marked retry-safe | Idempotency verification is a precondition, not an afterthought |
| A chart, diagram or report is requested | The template library and the viz standards are owned here |

**Not** this department: deployment execution (`engineering-tooling`), security gate criteria
(`security-resilience`), CI/CD definitions (`platform-mlops`), schedule commitments
(`delivery-scheduling`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The table below is the source of truth; an
action outside it is escalated, and the response names the role that holds the authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Pass or block this department's own gate | This department | Reversible | — |
| Raise the coverage threshold above 85 % | This department | Reversible | — |
| Lower the coverage threshold below 85 % | `board-and-branch` | — | rung 4 |
| Override this department's block | `board-and-branch` | — | rung 4 |
| Publish a report on a new template or externally | `executive-strategy` | Reversible with cost | — |
| Resolve a contested field that is decision-critical | `model-data` under the fusion rules | — | — |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
executive-strategy
      ▲  escalations, decision-support requests
      │
quality-visualization  ◄──── gate submissions ──── engineering-tooling
      │  ▲                    coverage + DORA readings
      │  └── report requests ── operations-coordination (WFT-002)
      │  └── template standards platform-mlops
      │  └── fusion inputs ──── model-data
      ▼  gates, metrics, charts, reports
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Gate evidence structure

Every gate run produces a record. A gate result without a record did not happen.

| Field | Requirement |
|---|---|
| Gate ID | Trace ID from template 7, prefix `cqo` |
| Change | The change description and its target environment |
| Criterion | Each criterion with its measured value — a bare pass/fail is not evidence |
| Verdict | Pass, or a block naming the failing criterion |
| Remediation | What must change before re-entry |
| Re-entry | The re-run result — a gate is closed by a re-run, not by an assertion |

### 3.B Coverage and DORA measurement

| Rule | Requirement |
|---|---|
| Changed paths first | Coverage is reported per changed path, repo-wide only as context |
| Risk ordering | Uncovered paths are listed highest-risk-first |
| Traceability | The reading carries the test-run trace ID (template 7) so it can be re-derived |
| Threshold | 85 % acceptance; raising it is this department's, lowering it is not |
| DORA refresh | Weekly per department; a breach is routed within 24 h and tracked over four deployments |

### 3.C Visualization, information services and fusion

Every visual is generated content and therefore carries AIGC identification like any other output.
Chart selection follows [../../visualization.md](../../visualization.md); report sections follow
the shared template library there. Information services — location, weather and time — fuse
multi-source readings under the [../../data-integration.md](../../data-integration.md) contract:

| Situation | Resolution |
|---|---|
| Numeric values differ within ±2 % | Take the higher-reliability source; record the delta |
| Numeric values differ beyond tolerance | Keep both, mark the field contested, report the spread |
| Categorical values differ | Keep both with source attribution |
| A source has no reliability rating | Exclude it from fusion; use it only as a lead (`INTEL_003`) |

⚠️ **A gap is not a zero.** Rendering missing data as 0 fabricates a decline that never happened,
and a trend claimed from fewer than 3 points is a story, not a measurement.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `CQO_001` | Quality gate failed | A gate check failed during `WFT-004` or `WFT-007` | 1. Report the failing criterion with measured value 2. Remediate 3. Re-enter the gate — never bypass |
| `CQO_002` | Idempotency violation | A repeated operation produced divergent side effects | 1. Identify the non-idempotent step 2. Add the missing guard or make the step retry-safe 3. Re-test with a double invocation |
| `CQO_003` | Test coverage below threshold | Coverage fell below the 85 % acceptance threshold | 1. Report the uncovered paths 2. Add tests for the highest-risk gaps first 3. Re-measure before release |
| `CQO_004` | Documentation incomplete | A required document section was missing or stale | 1. List the missing sections 2. Complete them 3. Re-run the structure-vs-disk consistency check |
| `CQO_005` | DORA metric breach | A DORA metric crossed its committed threshold | 1. Identify the breaching metric 2. Route to the owning department 3. Track recovery over the next four deployments |

⚠️ Numbering is continuous `001`–`005`, **no gaps**. Visualization and information-service
findings that at `group` tier belong to `information-services` (`INFO_`) are reported under
`CQO_` at this tier; `INFO_` is retired here and revived on upgrade — see
[../../scaling.md](../../scaling.md) §3.

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `engineering-tooling` | Submits the change, the test evidence and the coverage reading at each gate; receives pass or a block naming the failing criterion with its measured value |
| `platform-mlops` | WFT-004 phase 2 gates and the phase 4 documentation check run inside CI/CD; chart and report template standards arrive from here |
| `security-resilience` | The security gate runs ahead of the quality gate; a `CISO_001` block is not overridden by a green quality gate |
| `model-data` | Fusion inputs follow the data-integration contract; a contested field is marked and reported, never silently resolved |

## 6. Constraints

- ❌ Do not bypass a failed gate — remediate and re-enter, or escalate the block (`CQO_001`)
- ❌ Do not lower the coverage threshold below 85 % without escalation
- ❌ Do not mark an operation idempotent without a double-invocation test (`CQO_002`)
- ❌ Do not close a documentation gap on an assertion — re-run the consistency check (`CQO_004`)
- ❌ Do not render a gap as zero or claim a trend from fewer than 3 data points
- ❌ Do not publish a visual without the AIGC triple label and template 9 masking
- ❌ Do not resolve a contested field silently — keep both values and report the spread
- ❌ Do not approve a tier upgrade — no department may

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| First-time gate pass rate | Gates passed without a block ÷ total gates |
| Coverage at release | Coverage reading at the release gate against the 85 % threshold |
| DORA breach routing latency | Routing timestamp minus breach-detection timestamp |
| Idempotency verdicts with a double-invocation test | Verdicts with a recorded test ÷ total verdicts |
| Documentation checks before publication | Checks completed pre-publication ÷ total publications |
| WFT-002 delivery within SLA | Report completion minus trigger, against the 2 h workflow SLA |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-CQO-01 · Run a quality gate

```text
1. Confirm the submission carries the change description, target environment and test evidence.
2. Validate the submission (template 1); an incomplete submission is returned, not guessed at.
3. Generate a trace ID (template 7, prefix "cqo").
4. Check each criterion and record its measured value. A bare pass/fail is not evidence.
5. All criteria green -> pass; record the gate evidence per §3.A.
6. Any criterion red -> CQO_001. Report the failing criterion with its measured value.
7. Exactly two paths forward: remediate and re-enter, or escalate the block to board-and-branch.
8. Close the gate only on a re-run result - never on an assertion.
```

### SOP-CQO-02 · Measure test coverage

```text
1. Identify the changed paths for the release under gate.
2. Run the test suite; record the test-run trace ID (template 7).
3. Measure coverage per changed path; repo-wide only as context.
4. List uncovered paths highest-risk-first.
5. Reading >= 85 % -> pass; record the reading with its trace ID.
6. Reading < 85 % -> CQO_003, block the release, report the uncovered paths.
7. After tests are added, re-measure before release. A promise is not a reading.
8. Raising the threshold is this department's call; lowering it escalates to board-and-branch.
```

### SOP-CQO-03 · Compute DORA metrics and route breaches

```text
1. Collect the four readings: deployment frequency, lead time, change failure rate,
   time to restore.
2. Compute per department per deployment window; label each reading with its source
   and as-of timestamp.
3. Compare each against its committed threshold.
4. A crossing -> CQO_005. Identify the breaching metric and route it to the owning
   department within 24 h.
5. Track recovery over the next four deployments; a single green reading does not
   close a breach.
6. Publish the organization-wide view; engineering-tooling reports its own set here.
```

### SOP-CQO-04 · Verify idempotency

```text
1. Take the operation description and its retry path.
2. Identify every step with a side effect.
3. Run the double-invocation test: execute twice, compare side effects.
4. Identical -> mark retry-safe and record the verdict with the test evidence.
5. Divergent -> CQO_002. Identify the non-idempotent step.
6. Fix the step (add the missing guard) or make it retry-safe; re-test with a double
   invocation.
7. Never blind-retry a non-idempotent step - compensate instead (execution.md §4).
```

### SOP-CQO-05 · Generate a WFT-002 report or visual

```text
1. Confirm the request names the report type and its template from the library
   (visualization.md §3).
2. Assemble the dataset with freshness labels per source.
3. Verify every required section is present. A missing section -> CQO_004, return the
   draft with the section named.
4. Select the chart by the question being answered, never by what looks good.
5. Apply template 9 masking before any label, tooltip or axis value is rendered.
6. Apply the AIGC triple label (template 4) and the trace ID (template 7, prefix "cqo").
7. State data freshness: name each source and its age. A gap is rendered as a break,
   never as zero.
8. Submit for review (WFT-002 mode is Review); publish only after the reviewer confirms
   every figure traces to a source.
```
