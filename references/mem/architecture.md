# Memory Architecture

> L3 depth file for [../memory.md](../memory.md). Owning department: `knowledge-ethics`
> (distillation and governance), with `lifecycle-training` owning Profile memory.

## 1. Storage Topology

| Type | Store | Key | Lifetime | Visibility |
|---|---|---|---|---|
| Profile | Durable record per agent | agent id | Agent lifetime | All departments handling that agent |
| Session | In-process | conversation id | Session duration | The acting department only |
| Knowledge | Versioned document store | topic slug | Until superseded | Organization-wide |
| Learning | Append-only event log + distilled view | outcome id | Until disproven | Owner + shared pool |
| Preference | Durable record per user | user id + key | Until changed | Customer-facing departments |

⚠️ `Session` memory is **in-process by design**. Persisting it would blur the volatility boundary
and create a retention obligation nobody asked for.

## 2. Lifecycle

```text
capture → validate → mask → store → retrieve → distill → supersede or retire
```

| Stage | Requirement | Failure code |
|---|---|---|
| Capture | Source and timestamp recorded | — |
| Validate | Structure checked with template 1 | `FW_001` |
| Mask | Template 9 applied — **EMAIL / IP / PHONE, all three** | `CLO_001` |
| Store | Exactly one owning department assigned | `KNM_005` if ownership ambiguous |
| Retrieve | Scoped to the requester's visibility | `CLO_001` on over-broad read |
| Distill | Every 30 days for Knowledge and Learning | `KNM_002` when overdue |
| Supersede | Successor pointer written, never a silent delete | `KNM_005` |
| Retire | Only with an explicit deprecation notice | `KNM_005` |

## 3. Consolidation Rules

**Consolidation over accumulation** — the governing principle.

| Rule | Threshold |
|---|---|
| Knowledge store size | ≤ 500 items per department, else forced distillation |
| Duplicate detection | Items with ≥ 90 % content overlap are merged, keeping the higher-reliability source |
| Contradiction handling | Both retained, marked contested, escalated to the owning department |
| Staleness | Knowledge items unreviewed for 180 days are flagged, not silently trusted |
| Learning promotion | A Learning item promoted to Knowledge requires a distillation step — never a direct copy |

⚠️ **Session → Knowledge promotion without distillation is forbidden.** Raw session content
carries context that is meaningless or misleading once the session ends.

## 4. Retrieval Scoping

| Requester | May read |
|---|---|
| The acting department | Profile (its agents), Session (its own), Knowledge (all), Learning (its own + shared), Preference (its users) |
| A different department | Knowledge (all), Learning (shared pool only) |
| Audit function (`risk-audit`) | Session audit entries — **read-only, append-only source** |
| The user | Their own Preference and Profile |

Cross-department reads of `Profile`, `Session` or `Preference` require an explicit, logged reason.

## 5. Durability and Recovery

| Type | Backup | Recovery objective |
|---|---|---|
| Profile | Daily | RPO 24 h, RTO 1 h |
| Session | None — ephemeral by design | Not applicable |
| Knowledge | Versioned, every write | RPO 0 (version history), RTO 15 min |
| Learning | Append-only log, streamed | RPO 5 min, RTO 1 h |
| Preference | Daily | RPO 24 h, RTO 1 h |

Recovery follows copy-forward-then-delete ordering — see
[../exec/error-recovery.md](../exec/error-recovery.md) §2.

## 6. Audit Properties

| Property | Requirement |
|---|---|
| Append-only | Audit entries are never edited or deleted |
| Trace linkage | Every entry carries the trace ID from template 7 |
| Actor attribution | Every write names the acting department and, for manual actions, the actor |
| Tamper evidence | Modification of an audit entry raises `IRP_002` |
| Retention | Audit entries retained ≥ 365 days |

## 7. Constraints

- ❌ Do not persist raw PII — mask with template 9 first, all three classes
- ❌ Do not edit or delete an audit entry
- ❌ Do not promote Session memory to Knowledge without distillation
- ❌ Do not infer a user Preference and store it as fact
- ❌ Do not supersede an item without writing a successor pointer
- ❌ Do not read another department's Profile or Session memory without a logged reason
- ❌ Do not let the Knowledge store exceed its size bound without distilling
