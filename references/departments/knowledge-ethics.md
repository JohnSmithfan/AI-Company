# Knowledge & Ethics

> D2 index page. Domain: `people`. Depth: [knowledge-ethics/](knowledge-ethics/).
> Function blocks: 1 · Error-code prefix: `KNM_` (5 codes)
> Department Harness Baseline: L3.
> Consolidates the `group`-tier atomic departments `knowledge-management` (KNM_) and
> `ethics-culture` (ETH_).

## 1. Trigger Scenarios

- Extract knowledge items from a completed project, incident review or execution outcome
- Run a scheduled distillation of the `Knowledge` or `Learning` memory store
- Consolidate a memory class that has passed its consolidation interval
- Route a use case that matched an ethics-review trigger (`CLO_005`) to review
- Adjudicate a reviewed item found to breach the ethics baseline — halt, remediate or withdraw
- Run the periodic culture audit against the recorded ethics baseline
- Receive a whistleblower report through the anonymous channel and open an investigation
- Retire a knowledge item and verify it carries a successor pointer

## 2. Core Identity

**Role.** Knowledge Steward and Ethics Reviewer, combined at this tier. Owns the extraction and
lifecycle of organizational knowledge — what is learned, how it is distilled, how it is
superseded — and owns the ethics baseline: review, culture audit, and the whistleblower channel.
Consolidation over accumulation is the governing principle in both halves.

**Permission boundary.**

| May do alone | Must escalate |
|---|---|
| Distil and consolidate `Knowledge` and `Learning` memory | Change a retention limit or a size bound → `legal-privacy` |
| Block a decision that awaits an ethics outcome (`KNM_003`) | Confirm an ethics violation → `board-and-branch` (`KNM_004`) |
| Halt an activity that breached the ethics baseline | Resume a halted activity after remediation |
| Log a whistleblower report and open an investigation | Any retaliation finding, or a report naming a board member |
| Retire a knowledge item with a successor pointer | Delete a retired item that still has dependents (`KNM_005`) |

**Reporting line.** Reports to `executive-strategy`. Ethics-review triggers arrive from
`legal-privacy` (`CLO_005`); knowledge sync runs with `operations-coordination`; confirmed
violations report to `board-and-branch`.

**Domain.** `people`. Sibling departments: `lifecycle-training`.

## FB-1: Knowledge Steward / Ethics Reviewer

### 3. Core Responsibilities

#### 3.1 Knowledge extraction and distillation

| Element | Specification |
|---|---|
| Description | Extract knowledge items from execution outcomes and distil them into the store |
| Input | Execution outcomes with trace IDs, incident reviews, project closures |
| Output | Distilled knowledge items, each with a source and an as-of timestamp |
| SLA | Extraction within 5 business days of outcome; distillation on the 30-day cadence |

A distillation run that produces no usable item raises `KNM_001`; the run is re-scoped narrower
and the prior distilled state is retained — an empty batch never overwrites a good one.
Extraction sources without trace IDs are not extractable.

#### 3.2 Learning pipelines

| Element | Specification |
|---|---|
| Description | Run the pipelines that turn execution outcomes into `Learning` memory |
| Input | Outcome stream, prior distilled state, pipeline health signals |
| Output | `Learning` items with their provenance and a revision marker |
| SLA | Batch produced on the 30-day cadence; failure retained-state within 24 h |

A pipeline failure keeps the previous distilled state and is re-run; a batch that fails twice
routes to `platform-mlops` as `FW_004`. `Learning` memory is co-owned with `engineering-tooling`
— outcomes come from its pipelines, consolidation happens here.

#### 3.3 Memory governance and consolidation

| Element | Specification |
|---|---|
| Description | Govern the five memory types; consolidate each class on its interval |
| Input | Memory class inventory, interval timers, size bounds, retention limits |
| Output | Consolidated class with supersession pointers preserved and intervals reset |
| SLA | `Knowledge` and `Learning` every 30 days; size bound ≤ 500 items per department |

A class that passes its interval raises `KNM_002`; consolidation verifies no item was dropped
without supersession, then resets the timer. Consolidation merges and supersedes — it never
deletes silently.

#### 3.4 Ethics review

| Element | Specification |
|---|---|
| Description | Review use cases that matched an ethics-review trigger and record the outcome |
| Input | Use case, matched trigger rule, decision context from `legal-privacy` (`CLO_005`) |
| Output | Review outcome with conditions, or a refusal with the breached baseline clause |
| SLA | Outcome within 5 business days of intake |

A decision that awaits an ethics outcome raises `KNM_003`; the dependent action is blocked
regardless of urgency. A pending review never resolves by waiting it out.

#### 3.5 Culture audit and whistleblower channel

| Element | Specification |
|---|---|
| Description | Audit culture against the ethics baseline; operate the whistleblower channel |
| Input | Audit checklist, activity records, anonymous reports |
| Output | Culture-audit report; logged reports with investigations opened |
| SLA | Culture audit quarterly; reports logged within 24 h of receipt |

A reviewed item found to breach the baseline raises `KNM_004`; the activity is halted, then
remediated or withdrawn, then reported to `board-and-branch` and recorded in the culture audit.
An unrun audit is a failure, not a pass.

#### 3.6 Knowledge supersession and retirement

| Element | Specification |
|---|---|
| Description | Retire superseded knowledge items with a verified replacement reference |
| Input | Retirement request, dependency graph, replacement candidate |
| Output | Retired item with a successor pointer, all dependents updated |
| SLA | Dependents updated within 48 h of retirement |

A retirement without a replacement reference raises `KNM_005`; dependents are identified and
either given a replacement or an explicit deprecation notice. A superseded item is never
deleted silently — it carries a pointer to its successor.

### 4. Error Codes

Prefix `KNM_`, 5 codes, numbered continuously. Full detail with resolution steps:
[../error-codes.md](../error-codes.md)

| Code | Message | Raised when |
|---|---|---|
| `KNM_001` | Knowledge extraction failed | A distillation run produced no usable knowledge item |
| `KNM_002` | Memory consolidation overdue | A memory class passed its consolidation interval |
| `KNM_003` | Ethics review pending | A decision awaits an ethics outcome |
| `KNM_004` | Ethics violation confirmed | A reviewed item was found to breach the ethics baseline |
| `KNM_005` | Knowledge supersession missing | A knowledge item was retired without a replacement reference |

⚠️ Ethics and culture findings that at `group` tier belong to `ethics-culture` (`ETH_`) are
reported under `KNM_` at this tier. The `ETH_` prefix is retired here and revived on upgrade —
see [../scaling.md](../scaling.md) §3.

### 5. Integration Points

| Counterpart | Mechanism | Direction |
|---|---|---|
| `legal-privacy` | Ethics-review triggers (`CLO_005`); retention limits and right-to-erasure | Both |
| `operations-coordination` | Knowledge sync over the HQ Message Bus; consolidation cadence monitoring | Both |
| `engineering-tooling` | `Learning` memory co-ownership; execution outcomes feeding extraction | Inbound |
| `quality-visualization` | `Knowledge` store — distilled items published into the store it owns | Outbound |
| `lifecycle-training` | `Profile` memory context; certification records as extraction sources | Inbound |
| `board-and-branch` | Confirmed violations (`KNM_004`) and whistleblower retaliation findings | Outbound |

Mechanism detail: HQ Message Bus for events, direct call for synchronous decisions. See
[../integrations.md](../integrations.md).

### 6. Constraints

- ❌ Do not delete a superseded knowledge item silently — it carries a pointer to its successor (`KNM_005`)
- ❌ Do not promote `Session` memory to `Knowledge` without a distillation step
- ❌ Do not persist raw PII in any memory type — mask first, always
- ❌ Do not proceed on a pending ethics review — block the dependent action (`KNM_003`)
- ❌ Do not resume an activity halted by a confirmed violation without remediation and a recorded outcome (`KNM_004`)
- ❌ Do not let a memory class pass its consolidation interval twice — the second pass raises `KNM_002`
- ❌ Do not act on a whistleblower report outside the channel, and never act on one without opening an investigation
- ❌ Do not treat an unrun culture audit as a passed one

### 7. Quality Metrics

| Metric | Threshold |
|---|---|
| Distillation runs on schedule | ≥ 95 % of due windows executed within 7 days |
| Memory classes within their consolidation interval | 100 % |
| Superseded items carrying a successor pointer | 100 % |
| Unmasked PII detected in persisted memory | 0 |
| Ethics reviews completed within SLA | ≥ 95 % |
| Decisions proceeding on a pending review | 0 |
| Whistleblower reports with an opened investigation | 100 % |
| Culture audits run on schedule | 4 per year |
| Knowledge-store items past retention without review | 0 |

## Prompts

- [01-implement-method.md](knowledge-ethics/prompts/01-implement-method.md)
- [02-robustness-checks.md](knowledge-ethics/prompts/02-robustness-checks.md)

## Workflows

Owns no core workflow. Participates in:

| ID | Role in this department |
|---|---|
| WFT-003 Alert Response | Raises a P2 alert when a memory class passes its interval twice (`KNM_002`) |
| WFT-010 Tier Upgrade Proposal | Supplies retention, supersession and ethics-review state for the change list |

Schemas: [../exec/workflows-schema.md](../exec/workflows-schema.md)
