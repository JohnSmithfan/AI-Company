# Workflow Schema

> L3 depth file for [../execution.md](../execution.md). Owning department: `operations-coordination`.

Ten core workflows. This tier (`large`) enables **nine**; WFT-009 is `group`-only.

Core-set numbering is **append-only** — a new core workflow takes WFT-011, never a slot inside
001–010. Domain-specific extensions use `WFT-1<domain#><nn>` and must be referenced from the
owning domain's D2 page.

## Schema Definition

Every workflow entry carries these fields:

| Field | Meaning |
|---|---|
| `id` | `WFT-0NN` (core) or `WFT-1DNN` (extension) |
| `name` | Stable human name — never renamed, only deprecated |
| `trigger` | One of Schedule / Event / Webhook / Manual |
| `mode` | One of Auto / Approve / Review / Hybrid |
| `owner` | Department slug |
| `phases` | Ordered phase list, each with an entry condition and an exit criterion |
| `sla` | Wall-clock target from trigger to completion |
| `on_failure` | Recovery action and error code |
| `idempotent` | Whether the whole workflow is safely re-runnable |

* * *

## WFT-001 · Data Collection Pipeline

| Field | Value |
|---|---|
| Trigger | Schedule (daily 02:00 UTC) / Manual |
| Mode | `Auto` |
| Owner | `model-data` |
| SLA | 30 min |
| Idempotent | ✅ |

| Phase | Entry condition | Exit criterion |
|---|---|---|
| 1 Source discovery | Registered sources listed in the reliability register | Source set frozen for this run |
| 2 Extraction | Source reachable, rate limit available — template 8 | Raw payloads staged with trace IDs |
| 3 Validation | Payload received | Schema passes template 1; failures quarantined |
| 4 Normalization | Validation passed | Units, TZ (UTC), encoding unified |
| 5 Persistence | Normalization complete | PII masked (template 9), records indexed |

On failure: retry per [error-recovery.md](error-recovery.md) §1; persistent source failure marks
the source degraded and raises `INTEL_003`. Quarantined records are reported, never dropped
silently.

## WFT-002 · Report Generation

| Field | Value |
|---|---|
| Trigger | Schedule (weekly Monday 06:00 UTC) |
| Mode | `Review` |
| Owner | `quality-visualization` |
| SLA | 2 h |
| Idempotent | ✅ |

| Phase | Entry condition | Exit criterion |
|---|---|---|
| 1 Data preparation | Source data fresh within its stated ceiling | Dataset assembled with freshness labels |
| 2 Content generation | Dataset ready | Draft report with AIGC triple label (template 4) |
| 3 Quality review | Draft complete | Reviewer confirms every figure traces to a source |
| 4 Publication | Review passed | Distributed; distribution logged |

On failure: review rejection returns the draft with the specific failing criterion — "needs work"
is not a review result. `CQO_004` if a required section is missing.

## WFT-003 · Alert Response

| Field | Value |
|---|---|
| Trigger | Event (debounce 2 s, correlation ID inherited) |
| Mode | `Hybrid` — containment `Auto`, disclosure `Approve` |
| Owner | `operations-coordination` |
| SLA | Triage 15 min · containment 1 h · resolution 24 h |
| Idempotent | ✅ (deduped on correlation ID) |

| Phase | Entry condition | Exit criterion |
|---|---|---|
| 1 Triage | Alert received, deduped | Severity classed P0–P3, owner assigned |
| 2 Investigation | Owner assigned | Root cause hypothesis with evidence |
| 3 Mitigation | Hypothesis formed | Containment applied (`Auto`), verified by read-back |
| 4 Verification | Containment applied | Metric returned inside threshold for 2 consecutive windows |

On failure: escalation ladder rung 2 after 1 h without containment (`COO_001`). A P0 alert with no
containment in 15 min escalates to rung 3 immediately.

## WFT-004 · Skill Publishing

| Field | Value |
|---|---|
| Trigger | Manual |
| Mode | `Approve` |
| Owner | `platform-mlops` |
| SLA | 4 h |
| Idempotent | ✅ (versioned) |

| Phase | Entry condition | Exit criterion |
|---|---|---|
| 1 Pre-flight | Package complete | File count, structure tree and manifest agree |
| 2 Quality gates | Pre-flight passed | `CQO_001` suite green; coverage ≥ 85 % |
| 3 Security scan | Gates passed | No forbidden construct, no secret literal, no hardcoded path |
| 4 Documentation check | Scan passed | README structure tree matches disk exactly |
| 5 Versioning | Docs checked | Semver assigned; changelog entry present and undated-conflict-free |
| 6 Publish | Approved | Published; approval recorded with actor and timestamp |

On failure: any gate failure blocks publication — gates are never waived silently (`CQO_001`,
`FW_007`). Frontmatter over budget blocks at phase 1.

## WFT-005 · Incident Response

| Field | Value |
|---|---|
| Trigger | Event |
| Mode | `Hybrid` — containment `Auto`, notification `Approve` |
| Owner | `incident-identity` |
| SLA | Declaration 15 min · containment 4 h · notification per regulation |
| Idempotent | ❌ — compensation-based, never blind-retried |

| Phase | Entry condition | Exit criterion |
|---|---|---|
| 1 Declaration | Criteria met | Incident commander assigned, `IRP_001` raised |
| 2 Evidence preservation | Commander assigned | Evidence captured **read-only before any remediation** |
| 3 Containment | Evidence preserved | Attack path closed, verified |
| 4 Eradication | Containment verified | Root cause removed, not merely masked |
| 5 Recovery | Eradication confirmed | Service restored, outcome-level evidence observed |
| 6 Notification | Recovery or regulatory clock | Notification sent within the legal window (`IRP_003`) |
| 7 Post-mortem | Incident closed | Timeline, root cause, actions with owners and dates |

On failure: `IRP_002` if evidence is incomplete or altered. Evidence is preserved **before**
remediation because remediation destroys it.

## WFT-006 · Budget Review

| Field | Value |
|---|---|
| Trigger | Schedule (quarterly, first business day) |
| Mode | `Approve` |
| Owner | `finance-treasury` |
| SLA | 5 business days |
| Idempotent | ✅ |

| Phase | Entry condition | Exit criterion |
|---|---|---|
| 1 Department budgeting | Period closed | Each department submits actuals and next-period request |
| 2 Consolidation | Submissions complete | Organization-level position computed |
| 3 Variance analysis | Consolidated | Every variance > 10 % has a named driver |
| 4 CFO approval chain | Analysis complete | Approved, or returned with the specific objection |
| 5 Publication | Approved | Published to `board-and-branch` and requesting departments |

On failure: `CFO_001` on overrun > 10 %; `CFO_003` if source data is absent or stale > 24 h.
A variance without a named driver does not pass phase 3.

## WFT-007 · Deployment

| Field | Value |
|---|---|
| Trigger | Manual / Webhook |
| Mode | `Approve` |
| Owner | `engineering-tooling` |
| SLA | Per stage; 4 h total |
| Idempotent | ❌ — three-stage gate with explicit rollback |

| Phase | Entry condition | Exit criterion |
|---|---|---|
| 1 Pre-deployment | Build green, `FW_007` clear | Rollback plan documented and tested |
| 2 Canary (stage 1) | Approved | ≤ 5 % traffic, error rate ≤ 1 % for 30 min |
| 3 Staged (stage 2) | Canary healthy | ≤ 25 % traffic, error rate ≤ 1 % for 60 min |
| 4 Full (stage 3) | Staged healthy | 100 % traffic, SLO met for 24 h |
| 5 Post-deployment | Full rollout stable | Metrics confirmed at outcome level, not just exit code |

On failure: any stage breach halts promotion and rolls back to the previous stage (`CTO_008`,
`CTO_006`). Rollback follows copy-forward-then-delete ordering. Re-deployment is blocked until the
root cause is recorded.

## WFT-008 · Market Intelligence

| Field | Value |
|---|---|
| Trigger | Schedule (weekly) / Event (competitor signal) |
| Mode | `Auto` |
| Owner | `intelligence-sentiment` |
| SLA | 6 h |
| Idempotent | ✅ |

| Phase | Entry condition | Exit criterion |
|---|---|---|
| 1 Collection | Sources registered | Raw signals gathered with source attribution |
| 2 Processing | Collection complete | Deduplicated, normalized, classified |
| 3 Analysis | Processing complete | Findings with a confidence score per finding |
| 4 Production | Analysis complete | SITREP generated (`INTEL_005` on failure) |
| 5 Dissemination | Production complete | Delivered to subscribed departments |
| 6 Feedback | Dissemination done | Source reliability ratings updated |

On failure: `INTEL_002` when confidence falls below 40 % — the score is published, never omitted.
`INTEL_003` for an unverifiable source; such a source is excluded from products until re-verified.

## WFT-009 · Branch Rollout

| Field | Value |
|---|---|
| Trigger | Manual |
| Mode | `Approve` |
| Owner | `board-and-branch` |
| SLA | Per phase; weeks-scale |
| Idempotent | ❌ |
| **Enablement** | ⚠️ **`group` tier only — not enabled at `large`** |

Defined here for numbering stability. At `large` tier a request for this workflow returns
`SCL_002` (path undefined for the current tier) and the report notes that the headquarters-branch
architecture arrives with the `group` tier.

Phases (when enabled): PROPOSE → PILOT → STAGED → FULL → DELEGATE, each CEO-gated with
quantitative success criteria (success rate ≥ 95 % → accuracy ≥ 90 % → OHS ≥ 85). Auto-rollback
triggers: error rate > 5 %, SLA breach, security incident, OHS < 70.

## WFT-010 · Tier Upgrade Proposal

| Field | Value |
|---|---|
| Trigger | Event (`next_evaluation` due) / Manual |
| Mode | **`Approve`** — never `Auto` |
| Owner | `platform-mlops` + `board-and-branch` |
| SLA | Proposal within 1 h of trigger |
| Idempotent | ✅ (timestamped package; re-running supersedes) |

| Phase | Entry condition | Exit criterion |
|---|---|---|
| 1 Evaluate | State file readable | T1–T4 thresholds compared against measured metrics |
| 2 Lookup | A trigger fired | Target tier derived from the merge tree — table lookup only |
| 3 Build | Path resolved | Complete package written to the workspace |
| 4 Gates | Package built | All six gates pass (G1–G6) |
| 5 Acceptance | Gates passed | The package passes the full acceptance suite on its own |
| 6 Report | Acceptance passed | UPGRADE-PROPOSAL.md written |
| 7 **Stop** | Report written | **Nothing installed. The skill does not touch its own directory** |

On failure: `SCL_001` (no threshold met, forced run) · `SCL_002` (no path) · `SCL_003` (alias
collision) · `SCL_004`/`SCL_005` (self-modification attempt — **non-waivable**) · `SCL_006`
(acceptance failed) · `SCL_007` (state corrupt) · `SCL_009` (already at maximum) · `SCL_010`
(conservation violated).

Full specification: [../scaling.md](../scaling.md)

* * *

## Extension Workflows (`WFT-1xx`)

| Rule | Content |
|---|---|
| Naming | `WFT-1<domain#><nn>`, domain numbers per the domain table in [../department-index.md](../department-index.md) |
| Example | `WFT-101` = governance domain, first extension |
| Budget | `large` tier: 0–4 extensions total, at most 2 per domain |
| Constraint | Must never occupy 001–099; must be referenced from the owning domain's D2 page |
| Registration | Add to this file with the full schema above before first use |

This package currently defines **no** extension workflows — the nine enabled core workflows cover
the `large` tier's operational surface.

## Constraints

- ❌ Do not renumber or reorder WFT-001~010
- ❌ Do not place an extension workflow inside 001–099
- ❌ Do not run a workflow in a mode below its assigned class
- ❌ Do not skip a phase or waive a gate silently
- ❌ Do not remediate an incident before preserving evidence
- ❌ Do not deploy without a tested rollback plan
- ❌ Do not let WFT-010 install anything — it stops at phase 7
