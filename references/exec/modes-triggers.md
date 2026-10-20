# Execution Modes and Triggers

> L3 depth file for [../execution.md](../execution.md). Owning department: `operations-coordination`.

## 1. Mode Selection Matrix

Mode is determined by **reversibility × external visibility**, not by preference.

| | Reversible, internal | Reversible, external | Irreversible, internal | Irreversible, external |
|---|---|---|---|---|
| **Low risk** | `Auto` | `Review` | `Approve` | `Approve` |
| **Medium risk** | `Review` | `Approve` | `Approve` | `Approve` |
| **High risk** | `Approve` | `Approve` | `Approve` + second reviewer | `Approve` + second reviewer |

Risk class comes from the department's D2 §6 Constraints and §7 Quality Metrics.

⚠️ **Nothing in the "irreversible, external" column may ever be `Auto`.** Deployment, publication,
outbound messaging and tier upgrades all live there.

## 2. Mode Semantics

### Auto
- No human in the loop
- Preconditions: the operation is idempotent, previously succeeded with the same shape, and has no external side effect
- Mandatory: trace ID (template 7), rate limit (template 8), output masking (template 9)
- Abort condition: any precondition unverifiable at runtime → downgrade to `Review`, do not proceed

### Approve
- Authorization **before** execution
- The approval request must state: what will change, what is irreversible, who is affected, and how to roll back
- Approval is scoped: granted for the described action only, never standing authorization for a class of actions
- Expiry: an unused approval lapses after 24 h

### Review
- Execution first, quality gate before release
- The reviewer sees the produced artifact plus its inputs and trace ID
- Rejection returns the item to the producer with the specific failing criterion — "needs work" is not a review result
- Review SLA: 4 h for routine output, 1 h for customer-facing

### Hybrid
- Per-phase mode selection inside one workflow
- Each phase declares its own mode; the strictest phase governs the workflow's overall classification
- Phase boundaries must be checkpointed so a failure does not force a full restart

## 3. Trigger Configuration

### Schedule (cron)

| Property | Value |
|---|---|
| Expression | 5-field cron (minute hour day month weekday) |
| Timezone | Explicit; default `UTC` |
| Overlap policy | **skip** — a run still in progress blocks the next tick |
| Maintenance window | Configurable; ticks inside it are deferred, not dropped |
| Missed-tick policy | Run once on recovery if the data is still relevant, else skip and log |
| Monthly edge case | "day 31" must fall back to the last day of shorter months |

⚠️ Overlap policy is `skip` rather than `concurrent` because every workflow here is required to be
idempotent but is **not** required to be concurrency-safe.

### Event

| Property | Value |
|---|---|
| Delivery | Near-real-time, target < 5 s from emit to handler start |
| Debounce | 2 s — coalesce duplicates within the window |
| Correlation | Every event carries a correlation ID; derived events inherit it |
| Ordering | Best-effort per partition; handlers must tolerate reordering |
| Poison event | After 3 failed attempts, park it and raise `COO_005` if it blocks a queue |

### Webhook

Full control list: [../integrations.md](../integrations.md) §3. Summary: IP allowlist → timestamp
freshness (300 s) → HMAC-SHA256 constant-time compare → schema validation → idempotency dedupe.

### Manual

| Property | Value |
|---|---|
| Authentication | Required; anonymous manual invocation is rejected |
| Audit | Every manual invocation logged with actor, timestamp, arguments (masked) |
| Confirmation | Destructive or external actions require explicit confirmation, never inferred from prior approval |
| Scope | A manual approval applies to the stated action only |

## 4. Mode × Trigger Legality

Not every combination is permitted:

| Trigger | Auto | Approve | Review | Hybrid |
|---|:--:|:--:|:--:|:--:|
| Schedule | ✅ | ✅ | ✅ | ✅ |
| Event | ✅ | ✅ | ✅ | ✅ |
| Webhook | ❌ | ✅ | ✅ | ✅ |
| Manual | ❌ | ✅ | ✅ | ✅ |

❌ **Webhook + Auto is forbidden**: an externally-triggered action running with no human and no
post-gate means an outside party can cause unreviewed effects.
❌ **Manual + Auto is contradictory**: a human initiated it, so a human is already in the loop.

## 5. Workflow Mode Assignments (fixed)

| Workflow | Mode | Rationale |
|---|---|---|
| WFT-001 Data Collection | `Auto` | Read-only, idempotent |
| WFT-002 Report Generation | `Review` | Output quality is the deliverable |
| WFT-003 Alert Response | `Hybrid` | Containment auto; disclosure approved |
| WFT-004 Skill Publishing | `Approve` | External, hard to reverse |
| WFT-005 Incident Response | `Hybrid` | Containment auto; notification approved |
| WFT-006 Budget Review | `Approve` | Financial commitment |
| WFT-007 Deployment | `Approve` | External, three-stage gate |
| WFT-008 Market Intelligence | `Auto` | Read-only collection and analysis |
| WFT-009 Branch Rollout | `Approve` | Structural, `group` tier only |
| WFT-010 Tier Upgrade Proposal | **`Approve`** | Breaking change — never `Auto` |

## 6. Constraints

- ❌ Do not run an irreversible external action in `Auto`
- ❌ Do not combine `Webhook` or `Manual` triggers with `Auto`
- ❌ Do not treat one approval as standing authorization for a class of actions
- ❌ Do not accept a review result that does not name the failing criterion
- ❌ Do not run concurrent scheduled instances of the same workflow
- ❌ Do not downgrade a mode to avoid an approval — raise the risk class instead
