# Error Recovery

> L3 depth file for [../execution.md](../execution.md). Owning department: `operations-coordination`,
> with `risk-audit` owning the breaker thresholds.

Three recovery layers, applied innermost-first. Each layer has a bound; none may retry forever.

## 1. Layer 1 — Operation: Retry with Backoff

Implemented by template 5 (`retry_with_backoff`) — see [../method-patterns.md](../method-patterns.md).

| Parameter | Value |
|---|---|
| Schedule | 0.5 × 2^N before retry N (N 0-based): 0.5 s, 1 s, 2 s for the default 3 retries |
| Max retries | 3 (4 total attempts) |
| Jitter | ±25 % per wait (multiplier drawn from [0.75, 1.25)) — avoids thundering-herd synchronization |

Retry is legal **only** for idempotent operations.

| Operation class | Retry? | Instead |
|---|---|---|
| Read / query | ✅ | — |
| Create with a client-supplied idempotency key | ✅ | — |
| Create without an idempotency key | ❌ | Compensate or abandon |
| Update to a known target state | ✅ | — |
| Delete | ❌ | Verify state first; deletion is already terminal |
| Send a message / publish | ❌ | Dedupe on the receiver; never blind-retry |
| Financial commit | ❌ | Reverse via a compensating entry |

⚠️ Blindly retrying a non-idempotent operation creates duplicates. `CQO_002` covers the case
where a repeated operation produced divergent side effects.

## 2. Layer 2 — Transaction: Rollback

| Rollback class | When | Mechanism |
|---|---|---|
| **Automatic** | All steps reversible, compensations defined | Execute compensating actions in reverse order |
| **Semi-automatic** | Some steps need a decision | Reverse what is reversible, park the rest for a human |
| **Manual** | Irreversible steps already committed | Human-directed remediation with a recorded plan |

**Compensating action** requirements:

| Requirement | Detail |
|---|---|
| Defined before execution | A step without a compensation cannot be part of an automatic-rollback transaction |
| Idempotent | Compensation may itself need retrying |
| Verified | After compensating, confirm the pre-state actually holds — do not assume |
| Logged | Every compensation carries the original trace ID |

**Ordering rule (applies to every rollback, including the external installer):**

```text
copy forward → verify → atomic replace → delete old only after success
```

⚠️ Never delete first and restore second. If the restore fails after a delete, the data is gone
with no automatic recovery path. This is the single most destructive pattern in this domain, and
a predecessor package shipped exactly it in its update script.

## 3. Layer 3 — Service: Circuit Breaker

```text
CLOSED ──(5 consecutive failures, or 50% of 20 calls)──► OPEN
OPEN ──(60 s elapsed)──► HALF_OPEN
HALF_OPEN ──(3 probes all succeed)──► CLOSED
HALF_OPEN ──(any probe fails)──► OPEN (timer restarts)
```

| State | Behaviour |
|---|---|
| `CLOSED` | Requests pass; failures counted in a sliding window of 20 |
| `OPEN` | Requests fail fast with the documented degraded response; no upstream call |
| `HALF_OPEN` | Up to 3 probe requests pass; all others fail fast |

Per-department defaults:

| Parameter | Value |
|---|---|
| Failure threshold (consecutive) | 5 |
| Failure threshold (ratio) | 50 % over 20 calls |
| Open duration | 60 s |
| Half-open probes | 3 |
| Max open incidents per department per 30 days | 1 (above this → structural review) |

While open, the department must serve a **documented degraded path** — not an error. Examples:

| Department | Degraded path while open |
|---|---|
| `model-data` | Serve the last cached model response with a staleness marker |
| `intelligence-sentiment` | Report collection unavailable; publish prior SITREP marked as such |
| `quality-visualization` | Emit the data table instead of the chart |
| `incident-identity` | Fall back to manual credential rotation procedure |

⚠️ A degraded response must say it is degraded. Serving stale data as if fresh is worse than
failing.

## 4. Error Code Mapping

| Symptom | Code |
|---|---|
| Retry budget exhausted on a model call | `MDL_E007` |
| Upstream rate limited | `MDL_005` |
| Circuit breaker opened | `CRO_002` |
| Stage gate failed | `CRO_004` |
| Risk threshold crossed | `CRO_001` |
| Scheduling deadlock | `COO_005` |
| SLA breached | `COO_001` |
| Idempotency violation observed | `CQO_002` |
| Deployment failed | `CTO_006` |
| Pipeline stage failed | `CTO_005` |
| Incident declared | `IRP_001` |

Full table with resolution steps: [../error-codes.md](../error-codes.md)

## 5. Recovery Verification

Recovery is **not** complete when the error stops. Three levels of evidence, cheapest sufficient:

| Level | Evidence | Use when |
|---|---|---|
| Execution | Exit code / no exception | Never sufficient alone for recovery claims |
| Configuration | Read the value back from the same store that was written | The change's whole effect is the value written |
| Outcome | Observe the downstream effect through the user's actual path | User-visible behaviour is the deliverable |

⚠️ A successful command proves only that it ran. Claiming "recovered" or "fixed" on execution-level
evidence alone is an unverified claim — state what was verified and what was not.

## 6. Constraints

- ❌ Do not retry a non-idempotent operation
- ❌ Do not delete before a verified copy exists
- ❌ Do not leave a breaker open without a degraded path and a review date
- ❌ Do not serve stale data as if it were fresh
- ❌ Do not declare recovery on execution-level evidence alone
- ❌ Do not define a compensation after the step has already run
- ❌ Do not retry past the bound "just once more"
