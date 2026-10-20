# Execution Engine

> L2 shared module. Depth files: [exec/modes-triggers.md](exec/modes-triggers.md) ·
> [exec/command-center.md](exec/command-center.md) · [exec/error-recovery.md](exec/error-recovery.md) ·
> [exec/workflows-schema.md](exec/workflows-schema.md)

Defines **how work runs** once routing has picked a department: the autonomy mode, the trigger
class, the recovery behaviour, and the pre-built workflow templates.

## 1. Four Execution Modes

| Mode | Autonomy | Applies to | Approval point |
|---|---|---|---|
| `Auto` | Full | Low-risk, well-understood, previously-succeeded work | None |
| `Approve` | Pre-execution authorization | Anything with external impact | **Before** execution |
| `Review` | Post-execution quality gate | Output-quality-sensitive work | **After** execution, before release |
| `Hybrid` | Per-phase mode selection | Multi-phase workflows mixing autonomy levels | Per phase |

**Mode assignment is not discretionary.** These are fixed:

| Work class | Mode | Why it cannot be lowered |
|---|---|---|
| Tier upgrade proposal (WFT-010) | `Approve` | Breaking change; see [scaling.md](scaling.md) §1 |
| Production deployment (WFT-007) | `Approve` | External, hard to reverse |
| Incident response (WFT-005) | `Hybrid` | Containment auto, disclosure approved |
| Report generation (WFT-002) | `Review` | Output quality is the deliverable |
| Data collection (WFT-001) | `Auto` | Read-only, idempotent |

⚠️ Setting WFT-010 to `Auto` would let the skill upgrade itself unattended — forbidden
(spec red line P36).

## 2. Four Trigger Types

| Trigger | Determinism | Latency | Security requirement |
|---|---|---|---|
| `Schedule` | Deterministic (cron) | Interval-bound | Overlap policy + maintenance window |
| `Event` | Reactive | < 5 s | Debounce 2 s + correlation ID |
| `Webhook` | External | < 30 s | **HMAC-SHA256 signature verification** + IP allowlist + rate limit |
| `Manual` | On demand | Immediate | Authentication + audit log entry |

Tier enablement: `large` supports all four. Overlap policy for `Schedule` is **skip** (a run
still in progress blocks the next tick rather than starting a concurrent duplicate), because
every workflow here is required to be idempotent but not concurrent-safe.

## 3. Two-Level Routing

Routing decides **which department acts**; triggers decide **when**. Both live here because the
routing decision is what a trigger fires.

```text
1. task text → match frontmatter triggers → skill activated
2. department given explicitly?
   ├─ present in department-index.md        → use directly
   ├─ absent, present in the Alias Map      → resolve (may fan out one-to-many)
   └─ absent from both                      → report invalid department
3. department omitted or "auto":
   a. match DOMAIN   (7 choices, domain name + domain keywords)
   b. match DEPARTMENT within domain (≤3 choices, D2 §1 Trigger Scenarios)
4. read that department's D2 page
   → need depth? read its D3 directory (department-spec.md §8 SOPs)
   → need shared code? read method-patterns.md
```

Full rules, domain keyword lists and the disambiguation policy:
[department-index.md](department-index.md)

| Ambiguity | Required action |
|---|---|
| 2+ domains score equally | Ask the user to choose a domain — never guess |
| 2+ departments tie within a domain | Ask, citing each candidate's D2 §1 |
| Legacy alias fans out one-to-many | Ask which successor applies; unresolvable → `SCL_003` |
| No domain matches | Fall back to `executive-strategy` (CEO) for triage and say so explicitly |

## 4. Error Recovery Stack

Three layers, applied innermost-first:

| Layer | Mechanism | Bound |
|---|---|---|
| Operation | Retry with exponential backoff — template 5 | 1 s, 2 s, 4 s; capped at 30 s; ≤ 3 retries |
| Transaction | Rollback with compensating actions | Automatic / semi-automatic / manual, per workflow |
| Service | Circuit breaker | `CLOSED → OPEN → HALF_OPEN` |

Circuit-breaker defaults for this tier:

| Parameter | Value |
|---|---|
| Failure threshold to open | 5 consecutive, or 50 % over 20 calls |
| Open duration | 60 s |
| Half-open probe count | 3 |
| Close condition | All 3 probes succeed |

Rollback ordering rule (applies to every workflow and to the external installer):
**copy forward → verify → atomic replace → delete old only after success.**
Deleting first and restoring second loses everything if the restore fails.

Details: [exec/error-recovery.md](exec/error-recovery.md)

## 5. Workflow Templates

Core set WFT-001~010. This tier enables **9 of 10** (WFT-009 is `group`-only).

| ID | Name | Trigger | Mode | Owner department |
|---|---|---|---|---|
| WFT-001 | Data Collection Pipeline | Schedule/Manual | Auto | `model-data` |
| WFT-002 | Report Generation | Schedule | Review | `quality-visualization` |
| WFT-003 | Alert Response | Event | Hybrid | `operations-coordination` |
| WFT-004 | Skill Publishing | Manual | Approve | `platform-mlops` |
| WFT-005 | Incident Response | Event | Hybrid | `incident-identity` |
| WFT-006 | Budget Review | Schedule | Approve | `finance-treasury` |
| WFT-007 | Deployment | Manual/Webhook | Approve | `engineering-tooling` |
| WFT-008 | Market Intelligence | Schedule/Event | Auto | `intelligence-sentiment` |
| WFT-009 | Branch Rollout | Manual | Approve | *(not enabled — `group` tier only)* |
| WFT-010 | Tier Upgrade Proposal | Event/Manual | **Approve** | `platform-mlops` + `board-and-branch` |

Core-set numbering is **append-only**: a new core workflow takes WFT-011, never a slot inside
001–010. Domain-specific extensions use `WFT-1<domain#><nn>` (e.g. `WFT-101` for governance) and
must be referenced from the owning domain's D2 page.

Phase definitions, failure handling and SLA per workflow:
[exec/workflows-schema.md](exec/workflows-schema.md)

## 6. Constraints

- ❌ Do not run a workflow in a mode below its assigned class
- ❌ Do not accept an unsigned webhook — verification is mandatory, not best-effort
- ❌ Do not retry a non-idempotent operation; compensate instead
- ❌ Do not start a scheduled run while the previous one is still in progress
- ❌ Do not leave a circuit breaker open without a recorded owner and review date
- ❌ Do not resolve an ambiguous route by picking the first candidate

## 7. Quality Metrics

| Metric | Threshold | Source |
|---|---|---|
| Routing accuracy (`department: auto`) | ≥ 85 % over 3 consecutive evaluations | Runtime log aggregation |
| Webhook signature verification rate | 100 % — unsigned requests rejected | Integration log |
| Retry exhaustion rate | ≤ 2 % of retryable operations | Operation log |
| Circuit-breaker open incidents | ≤ 1 per department per 30 days | Service log |
| Workflow completion within SLA | ≥ 95 % | Workflow log |
| Ambiguity resolved by asking, not guessing | 100 % | Routing log |

Routing accuracy below 85 % for three consecutive evaluations is trigger **T3** for a tier
upgrade proposal — see [scaling.md](scaling.md) §4.
