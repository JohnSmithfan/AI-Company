# External Integrations

> L2 shared module. No depth subdirectory — this page is complete.
> Related: [data-integration.md](data-integration.md) · [execution.md](execution.md)

Three pathways connect this skill to systems outside itself. All three obey the same
non-negotiables: **zero secrets in code**, **idempotent operations**, **audit-by-default**.

## 1. Pathway Comparison

| Pathway | Direction | Latency target | Auth mechanism | Retry |
|---|---|---|---|---|
| MCP Servers | Outbound tool calls | < 5 s | Transport-level (host session) | Template 5, ≤ 3 |
| Webhooks | Inbound callbacks | < 30 s | HMAC-SHA256 signature + IP allowlist | Caller-driven; we dedupe |
| REST API Bridge | Outbound to legacy | < 30 s | Bearer token from an env var | Template 5 + circuit breaker |

⚠️ Credentials are referenced by **environment variable name only**. A config file that contains
a token value is a leaked secret, regardless of intent.

## 2. MCP Servers

Standardized tool invocation via the Model Context Protocol.

| Property | Requirement |
|---|---|
| Declared in frontmatter | `permissions.mcp: [sessions_send, subagents]` |
| Tool discovery | Resolve the exact tool name from a search result — never construct one from a service label |
| Schema | Use the returned input schema verbatim; do not guess field names |
| Failure | Map to `MDL_E007`; do not fabricate a tool result |
| Audit | Attach a trace ID (template 7) to every call |

**Rule:** a service status label is not a callable tool name. Inferring a tool name from a label
or from user intent produces a call that cannot exist.

## 3. Webhooks

Inbound HTTP callbacks. Verification is mandatory, not best-effort.

| Control | Requirement |
|---|---|
| Signature | HMAC-SHA256 over the raw body with the shared secret; **constant-time comparison** |
| Timestamp | Reject payloads older than 300 s (replay window) |
| IP allowlist | Enforce before signature verification to shed unsolicited traffic |
| Rate limit | Template 8, keyed on the sender identity, default 10 per 60 s |
| Idempotency | Deduplicate on the caller's event ID; a replay must not double-apply |
| Failure response | Return the error class, never a stack trace |

| Check order | Reason |
|---|---|
| 1. IP allowlist | Cheapest rejection first |
| 2. Timestamp freshness | Blocks replay before any crypto work |
| 3. HMAC signature | Authenticates the body |
| 4. Schema validation (template 1) | Validates structure |
| 5. Idempotency dedupe | Blocks double-apply |

Unsigned or mismatched payloads are rejected and logged; the rejection raises `CISO_001` when the
sender was expected to be valid.

## 4. REST API Bridge

Legacy system integration.

| Control | Requirement |
|---|---|
| Timeout | 30 s hard ceiling (matches template 3's default) |
| Circuit breaker | Per upstream; `CLOSED → OPEN → HALF_OPEN`, thresholds in [execution.md](execution.md) §4 |
| Retry | Template 5, exponential backoff, only for idempotent methods |
| Non-idempotent calls | **Never retried** — compensate instead |
| Response cap | 100 KB, matching template 3's output cap |
| Error mapping | Transport failure → `MDL_E007`; auth failure → `MDL_004`; rate limit → `MDL_005` |

## 5. Shared Security Requirements

| Requirement | Enforced by |
|---|---|
| No secret literal in any file | Test sweep `test_no_embedded_secrets` |
| No remote download-and-execute construct | Test sweep `test_no_remote_execution_patterns` |
| No hardcoded absolute user path | Test sweep `test_no_hardcoded_user_paths` |
| Every outbound call rate-limited | Template 8 |
| Every call auditable | Template 7 trace ID |
| Every response PII-masked before logging | Template 9 |

The forbidden constructs are named descriptively above rather than spelled out, because writing
their literal tokens into a package file would make this page fail its own sweep.

## 6. Failure Handling

| Symptom | First action | Escalation |
|---|---|---|
| Upstream timeout | Retry with backoff (idempotent only) | Open the breaker after 5 consecutive |
| 429 rate limited | Honour `Retry-After`, then template 8 backoff | Shift load to the fallback upstream |
| 401/403 | Stop; report the env var **name** that is missing | `MDL_004`, never log a value |
| Signature mismatch | Reject, log the sender and timestamp | `CISO_001` if the sender is expected |
| Schema violation | Reject, name the offending field | `FW_001` |
| Breaker open | Serve the documented degraded path | Notify the owning department; set a review date |

## 7. Constraints

- ❌ Do not store a credential value in any file — only the environment variable name
- ❌ Do not accept an unsigned or stale webhook
- ❌ Do not retry a non-idempotent request
- ❌ Do not construct an MCP tool name from a service label
- ❌ Do not log a response before masking it
- ❌ Do not leave a circuit breaker open without an owner and a review date
- ❌ Do not raise the timeout above 30 s to "fix" a slow upstream — fix the upstream

## 8. Quality Metrics

| Metric | Threshold |
|---|---|
| Webhook signature verification rate | 100 % |
| Replay attempts accepted | 0 |
| Secret literals found in the package | 0 |
| Outbound calls with a trace ID | 100 % |
| Integration success rate (excluding upstream outages) | ≥ 98 % |
| Breaker open incidents per department per 30 days | ≤ 1 |
| Non-idempotent retries observed | 0 |
