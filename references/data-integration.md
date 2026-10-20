# Data Integration

> L2 shared module. Depth files: [data/financial-news.md](data/financial-news.md) ·
> [data/information-fusion.md](data/information-fusion.md) · [data/schema-security.md](data/schema-security.md)
>
> Owning department: `model-data` (prefix `MDL_`).

How external data enters the package, how conflicting sources are reconciled, and how schemas
are kept safe.

## 1. Three Integration Pathways

| Pathway | Use | Security | Failure code |
|---|---|---|---|
| **MCP Servers** | Standardized tool invocation (documents, financial data) | Transport-level auth; no secrets in config | `MDL_E007` |
| **Webhooks** | Inbound event callbacks | **HMAC-SHA256 signature** + IP allowlist + rate limit | `CISO_001` |
| **REST API Bridge** | Legacy systems | Timeout 30 s + circuit breaker + retry via template 5 | `MDL_E007` |

Shared principles across all three: **zero secrets in code** (environment variable names only),
**idempotent operations** (safe to replay), **audit-by-default** (every call carries a trace ID
from template 7).

Detail: [integrations.md](integrations.md)

## 2. Ingestion Pipeline

```text
discover source → validate schema → extract → normalize → fuse → persist → index
```

| Stage | Gate | On failure |
|---|---|---|
| Discover | Source registered in the reliability register | Reject unregistered sources (`INTEL_003`) |
| Validate | Payload matches its declared schema — template 1 | Reject with the offending field named (`FW_001`) |
| Extract | Rate limit respected — template 8 | Back off, then `MDL_005` |
| Normalize | Units, timezone (UTC), encoding unified | Quarantine the record, never coerce silently |
| Fuse | Conflict resolution applied (§3) | Mark the field contested, keep both values |
| Persist | PII masked — template 9 | Refuse to persist raw PII (`CLO_006`) |
| Index | Trace ID attached | Retry; unindexed data is not retrievable |

## 3. Multi-Source Fusion

When sources disagree, **do not pick one silently**.

| Situation | Resolution |
|---|---|
| Numeric values differ within tolerance (±2 %) | Take the higher-reliability source; record the delta |
| Numeric values differ beyond tolerance | Keep both, mark the field **contested**, report the spread |
| Categorical values differ | Keep both with source attribution; escalate if decision-critical |
| One source is stale (> 24 h) | Prefer the fresh source; note the stale one's timestamp |
| A source has no reliability rating | Exclude it from fusion; use it only as a lead (`INTEL_003`) |

Confidence weighting: fused value confidence = Σ(source reliability × agreement) ÷ Σ(reliability).
A fused product whose confidence falls below 40 % must publish that score, never omit it
(`INTEL_002`).

Detail: [data/information-fusion.md](data/information-fusion.md)

## 4. Financial Data Specifics

| Requirement | Value |
|---|---|
| Quote staleness ceiling | 15 min for intraday decisions, else mark as delayed |
| Currency | Always carry the currency code; never assume |
| Rounding | Preserve source precision; round only at presentation |
| Adjustment | State whether a figure is adjusted or reported |
| As-of timestamp | Mandatory on every financial value |

Detail: [data/financial-news.md](data/financial-news.md)

## 5. Schema Security

| Control | Requirement |
|---|---|
| Validation before use | Template 1 on every inbound payload — no exceptions |
| No dynamic schema evaluation | Schemas are data, never code; no expression evaluation |
| Field allowlist | Only declared fields are persisted; unknown fields dropped and logged |
| Type coercion | Never silent — a string that looks numeric stays a string unless converted explicitly |
| Size bound | Payload ≤ 1 MB; larger payloads rejected before parsing |
| Injection surface | Query construction uses parameters, never string interpolation |

Detail: [data/schema-security.md](data/schema-security.md)

## 6. Constraints

- ❌ Do not ingest from an unregistered source
- ❌ Do not accept an unsigned webhook
- ❌ Do not silently pick one value when sources conflict
- ❌ Do not persist raw PII — mask first
- ❌ Do not coerce types silently
- ❌ Do not build a query by string interpolation
- ❌ Do not store a secret in a config file — only the environment variable name

## 7. Quality Metrics

| Metric | Threshold |
|---|---|
| Inbound payloads schema-validated | 100 % |
| Webhook signature verification rate | 100 % |
| Contested fields left unresolved past 48 h | 0 |
| Fused products missing a confidence score | 0 |
| Financial values missing an as-of timestamp | 0 |
| Raw PII found in persisted data | 0 |
| Ingestion pipeline success rate | ≥ 98 % |
