# Financial News and Market Data

> L3 depth file for [../data-integration.md](../data-integration.md). Owning department: `model-data`,
> with `finance-treasury` and `risk-audit` as consumers.

## 1. Data Classes

| Class | Freshness ceiling | Use |
|---|---|---|
| Real-time quote | 15 min for intraday decisions | Trading-adjacent analysis |
| Delayed quote | Must be labelled as delayed | General reference |
| End-of-day | Same business day | Reporting, variance analysis |
| Fundamental (financials) | Latest filed period | Valuation, budget context |
| News item | Timestamp of publication | Sentiment and event detection |

⚠️ **Every financial value carries an as-of timestamp.** A number without one cannot be assessed
for staleness, and stale numbers presented as current are the most common failure in this domain.

## 2. Mandatory Field Contract

| Field | Requirement |
|---|---|
| `value` | Source precision preserved — never pre-rounded |
| `currency` | ISO 4217 code, always explicit |
| `as_of` | TZ-aware UTC timestamp |
| `adjusted` | Boolean — adjusted for splits and dividends, or as reported |
| `source` | Named provider |
| `delay` | Real-time or the delay interval |
| `unit` | Per-share, total, thousands, millions — stated, never implied |

Rounding happens only at presentation. Rounding at ingestion compounds across every downstream
calculation and cannot be undone.

## 3. Ingestion Rules

| Rule | Detail |
|---|---|
| Registered sources only | An unregistered source is a lead, not data (`INTEL_003`) |
| Rate limit | Template 8, per provider identifier |
| Retry | Template 5, idempotent reads only |
| Circuit breaker | Per provider; degraded path serves the last cached value **marked as stale** |
| Schema validation | Template 1 before any value is accepted |
| Duplicate handling | Dedupe on (symbol, as_of, source) |

⚠️ Serving a cached value is legitimate. Serving it **without a staleness marker** is not —
that is presenting old data as current.

## 4. Conflict Resolution

When providers disagree on the same value:

| Divergence | Action |
|---|---|
| Within ±0.5 % | Take the higher-reliability provider; record the delta |
| 0.5 % – 2 % | Take the higher-reliability provider; flag as contested |
| Beyond 2 % | Keep both, mark contested, escalate to `risk-audit` |
| One provider stale | Prefer the fresh one; note the stale timestamp |
| Adjustment basis differs | Never compare directly — normalize to the same basis first |

The last row is the subtle one: an adjusted close and an unadjusted close for the same day are
different numbers by design. Comparing them produces a phantom movement.

## 5. News and Sentiment

| Requirement | Detail |
|---|---|
| Publication timestamp | Separate from the ingestion timestamp |
| Source reliability rating | From the register maintained by `intelligence-sentiment` |
| Deduplication | Near-duplicate detection across syndicated copies |
| Sentiment score | Carries a confidence value; below 40 % it is published with the score, not suppressed (`INTEL_002`) |
| Entity resolution | The company referred to must be resolved, not string-matched |

⚠️ Entity resolution matters: two companies with similar names are not the same subject. A
string match on a ticker-like token is not resolution.

## 6. Compliance

| Requirement | Detail |
|---|---|
| No investment advice | This package produces information and analysis, not a recommendation to a specific person |
| Licensing | Provider licence terms recorded per source |
| Redistribution | Only within the licence; a report that embeds third-party data states the source |
| PII | Template 9 before persistence — news text can contain personal data |
| Audit | Every ingestion carries a trace ID from template 7 |

⚠️ Financial and legal analysis produced here is **information, not a professional conclusion**.
Where a decision carries legal or financial consequence, the output must state that a qualified
professional should be consulted.

## 7. Consumers and Contracts

| Consumer | Needs | SLA |
|---|---|---|
| `finance-treasury` | End-of-day and fundamentals for budget variance (WFT-006) | Same business day |
| `risk-audit` | Contested values and FAIR inputs | On demand, 4 h |
| `intelligence-sentiment` | News items for SITREP (WFT-008) | 6 h |
| `executive-strategy` | Market context for strategic decisions | On demand |
| `quality-visualization` | Series for charts with as-of labels | Per report cycle |

## 8. Constraints

- ❌ Do not store or serve a financial value without an as-of timestamp
- ❌ Do not round at ingestion
- ❌ Do not omit the currency code
- ❌ Do not compare adjusted against unadjusted values
- ❌ Do not serve a cached value without a staleness marker
- ❌ Do not ingest from an unregistered source
- ❌ Do not present analysis as personalized investment advice
