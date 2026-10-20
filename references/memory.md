# Memory System

> L2 shared module. Depth files: [mem/architecture.md](mem/architecture.md) ·
> [mem/management-compliance.md](mem/management-compliance.md)

Five memory types, separated by scope and volatility. Enabled from the `medium` tier upward;
this package is `large`, so all five are in scope.

## 1. The Five Types

| Type | Scope | Volatility | Owner (this tier) | Retention |
|---|---|---|---|---|
| **Profile** | Per agent | Low | `lifecycle-training` | Agent lifetime |
| **Session** | Per conversation | High | `operations-coordination` | Session duration |
| **Knowledge** | Organization-wide | Low | `quality-visualization` | Until superseded |
| **Learning** | Per agent + shared | Medium | `engineering-tooling` + `knowledge-ethics` | Until disproven |
| **Preference** | Per user + shared | Low | the user | Until changed |

Owner mapping note: at `group` tier these duties sit in the atomic departments
`agent-lifecycle`, `hq-coordination`, `quality-assurance`, `engineering-architecture` and
`knowledge-management`. The `large` tier holds the same duties inside the merged departments
listed above — the merge tree preserves the function, only the container differs.

## 2. Governing Principle

**Consolidation over accumulation.**

Memory is periodically distilled and merged so that institutional intelligence is preserved
while volume stays bounded. An ever-growing memory store degrades retrieval precision and
inflates every load, which defeats progressive disclosure.

| Rule | Requirement |
|---|---|
| Distillation cadence | `Knowledge` and `Learning` distilled every 30 days |
| Supersession | A superseded item is never deleted silently — it carries a pointer to its successor |
| Volatility separation | `Session` memory must never be promoted to `Knowledge` without a distillation step |
| Ownership | Every item has exactly one owning department; no shared ownership without a named primary |
| Size bound | `Knowledge` store ≤ 500 items per department before forced distillation |

## 3. Write and Read Paths

| Memory type | Written by | Read by | Persistence |
|---|---|---|---|
| Profile | `lifecycle-training` at onboarding | Any department handling that agent | Durable |
| Session | The acting department | Same conversation only | Ephemeral, dropped at session end |
| Knowledge | `quality-visualization` after distillation | All departments | Durable, versioned |
| Learning | `engineering-tooling` from execution outcomes | Owner + shared pool | Durable until disproven |
| Preference | The user, explicitly | All customer-facing departments | Durable until changed |

⚠️ `Preference` memory is **never inferred**. It is written only from an explicit user
statement. Inferring a preference and storing it as fact is how a system starts acting on
assumptions nobody made.

## 4. Cross-Department Coordination

Memory is the substrate for the coordination mechanisms in [execution.md](execution.md):

| Mechanism | Memory dependency |
|---|---|
| Cross-agent routing (`COO_005` deadlock detection) | `Session` + `Profile` |
| Knowledge sync | `Knowledge` |
| Audit trail | `Session` (immutable, append-only) |
| Learning pipeline (`FW_004`) | `Learning` |
| Memory consolidation (`KNM_002`) | `Knowledge` + `Learning` |

## 5. Compliance Requirements

| Requirement | Applies to | Enforced by |
|---|---|---|
| PII masked before persistence | All types | Template 9, mandatory |
| Audit entries append-only, never edited | `Session` | `IRP_002` on tampering |
| Retention limits honoured | All types | `KNM_002` when overdue |
| Right-to-erasure honoured | `Preference`, `Profile` | `CLO_001` on failure |
| Cross-border storage rules | All types at `group` tier | `CLO_006` |
| Distillation must not drop un-superseded items | `Knowledge`, `Learning` | `KNM_005` |

Detail: [mem/management-compliance.md](mem/management-compliance.md)

## 6. Constraints

- ❌ Do not persist raw PII in any memory type — mask first, always
- ❌ Do not edit or delete an audit entry
- ❌ Do not promote `Session` memory to `Knowledge` without distillation
- ❌ Do not infer and store a user `Preference`
- ❌ Do not leave a superseded knowledge item without a successor pointer
- ❌ Do not let a memory class exceed its size bound without distilling

## 7. Quality Metrics

| Metric | Threshold |
|---|---|
| Distillation runs on schedule | ≥ 95 % of due windows executed within 7 days |
| Knowledge items past retention without review | 0 |
| Unmasked PII detected in persisted memory | 0 |
| Audit entries modified after write | 0 |
| Superseded items lacking a successor pointer | 0 |
| Retrieval precision on the `Knowledge` store | ≥ 80 % |
