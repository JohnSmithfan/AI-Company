## 3. Error Recovery

Error recovery defines the strategies, policies, and procedures for handling execution failures. The system employs a multi-layered approach: retry with exponential backoff at the operation level, rollback procedures at the transaction level, and circuit breakers at the service level.

### 3.1 Retry with Exponential Backoff

Retry logic is the first line of defense against transient failures. Each failed operation is retried with increasing delays to allow the underlying system to recover.

**Backoff Algorithm:**

```
delay(n) = base_delay * (multiplier ^ n) + jitter

Where:
  n = retry attempt number (0-indexed)
  base_delay = configurable (default: 1000ms)
  multiplier = configurable (default: 2.0)
  jitter = random value in [0, max_jitter] (default: 100ms)

Example sequence with base=1000ms, multiplier=2.0:
  Attempt 0: immediate
  Attempt 1: 1000ms + jitter (0-100ms)
  Attempt 2: 2000ms + jitter (0-100ms)
  Attempt 3: 4000ms + jitter (0-100ms)
  Attempt 4: 8000ms + jitter (0-100ms)
```

**Retry Classification by Error Type:**

| Error Category | Retryable | Max Retries | Base Delay | Strategy |
|---------------|-----------|-------------|------------|----------|
| Network timeout | Yes | 5 | 1000ms | Exponential backoff |
| Rate limit (429) | Yes | 3 | 5000ms | Respect Retry-After header |
| Temporary service unavailable (503) | Yes | 5 | 2000ms | Exponential backoff |
| Resource contention | Yes | 3 | 3000ms | Exponential backoff |
| Data conflict (409) | Yes | 2 | 1000ms | Immediate retry with refreshed data |
| Authentication failure (401) | No | 0 | N/A | Escalate, do not retry |
| Authorization failure (403) | No | 0 | N/A | Escalate, do not retry |
| Validation failure (400) | No | 0 | N/A | Return error to caller |
| Data not found (404) | No | 0 | N/A | Return error to caller |
| Internal server error (500) | Conditional | 2 | 5000ms | Only if idempotent operation |

**Retry Policy Schema:**

```json
{
  "retry_policy": {
    "max_retries": 3,
    "base_delay_ms": 1000,
    "multiplier": 2.0,
    "max_delay_ms": 60000,
    "jitter_ms": 100,
    "retryable_errors": ["TIMEOUT", "RATE_LIMIT", "SERVICE_UNAVAILABLE", "RESOURCE_BUSY"],
    "non_retryable_errors": ["AUTH_FAILED", "FORBIDDEN", "VALIDATION_ERROR", "NOT_FOUND"],
    "idempotency_required": true,
    "retry_on_5xx": true,
    "respect_retry_after_header": true,
    "circuit_breaker_integration": true
  }
}
```

**Retry Event Schema (for audit logging):**

```json
{
  "retry_event": {
    "task_id": "TASK-{NNN}",
    "operation": "string",
    "attempt": 1,
    "max_attempts": 3,
    "error_code": "string",
    "error_message": "string",
    "delay_ms": 1000,
    "timestamp": "ISO-8601",
    "will_retry": true,
    "circuit_breaker_state": "CLOSED|OPEN|HALF_OPEN"
  }
}
```

**Example — API Call Retry Configuration:**

```json
{
  "retry_policy": {
    "max_retries": 5,
    "base_delay_ms": 2000,
    "multiplier": 2.0,
    "max_delay_ms": 60000,
    "jitter_ms": 200,
    "retryable_errors": [
      "TIMEOUT",
      "RATE_LIMIT",
      "SERVICE_UNAVAILABLE",
      "CONNECTION_REFUSED",
      "RESOURCE_BUSY"
    ],
    "non_retryable_errors": [
      "AUTH_FAILED",
      "FORBIDDEN",
      "VALIDATION_ERROR",
      "NOT_FOUND",
      "DATA_CORRUPTION"
    ],
    "idempotency_required": true,
    "retry_on_5xx": true,
    "respect_retry_after_header": true,
    "circuit_breaker_integration": true
  }
}
```

### 3.2 Rollback Procedures

Rollback procedures restore the system to a consistent state after a failed operation. Rollback is mandatory for any operation that modified external state. Read-only operations require no rollback.

**Rollback Classification:**

| Operation Type | Rollback Strategy | Rollback Window |
|---------------|-------------------|-----------------|
| Database write | Transaction rollback or compensating transaction | Within transaction timeout |
| File write | Restore from backup snapshot | Within 24 hours |
| Configuration change | Revert to previous configuration version | Within 7 days |
| State change | Restore from state snapshot | Within 6 hours |
| External API call | Compensating API call (if supported) | Within SLA window |
| Deployment | Rollback to previous version | Within 1 hour |
| Permission change | Revert permission grant | Immediate |

**Rollback Procedure Schema:**

```json
{
  "rollback_config": {
    "enabled": true,
    "strategy": "AUTOMATIC|MANUAL|SEMI_AUTOMATIC",
    "snapshot_before_execution": true,
    "snapshot_retention": "ISO-8601-duration",
    "compensating_actions": [
      {
        "action_id": "COMP-{NNN}",
        "description": "string",
        "target": "string",
        "method": "REVERT|COMPENSATE|RESTORE",
        "pre_condition": "string (optional)",
        "post_condition": "string (optional)"
      }
    ],
    "verification_after_rollback": true,
    "rollback_timeout": "ISO-8601-duration",
    "notify_on_rollback": true,
    "escalate_if_rollback_fails": true
  }
}
```

**Rollback Execution Flow:**

```
ROLLBACK EXECUTION FLOW:

  [Operation Failed] -> [Determine Rollback Strategy]
                                    |
                          AUTOMATIC? ----+---- MANUAL?
                            |                 |
                    [Execute Rollback]   [Notify Operator] -> [Wait for Confirmation]
                            |                                           |
                    [Verify Rollback]                          [Execute Rollback]
                            |                                           |
                      [Report Result]                          [Verify Rollback]
                                                                [Report Result]

  ROLLBACK FAILURE PATH:
  [Rollback Failed] -> [Alert Operations] -> [Escalate to CEO] -> [Manual Intervention]
```

**Example — Database Migration Rollback:**

```json
{
  "rollback_config": {
    "enabled": true,
    "strategy": "AUTOMATIC",
    "snapshot_before_execution": true,
    "snapshot_retention": "PT72H",
    "compensating_actions": [
      {
        "action_id": "COMP-001",
        "description": "Reverse schema migration v2.4.1",
        "target": "production_database",
        "method": "REVERT",
        "pre_condition": "migration_was_applied",
        "post_condition": "schema_matches_v2.4.0"
      },
      {
        "action_id": "COMP-002",
        "description": "Invalidate affected cache entries",
        "target": "redis_cache",
        "method": "COMPENSATE"
      }
    ],
    "verification_after_rollback": true,
    "rollback_timeout": "PT30M",
    "notify_on_rollback": true,
    "escalate_if_rollback_fails": true
  }
}
```

### 3.3 Circuit Breaker Pattern

The circuit breaker pattern prevents cascading failures by temporarily halting operations to a failing service. It operates in three states: CLOSED (normal operation), OPEN (operations blocked), and HALF_OPEN (probe single request to test recovery).

**Circuit Breaker State Machine:**

```
                 Success                     Failure
  CLOSED --------+--------> CLOSED    CLOSED ------+------> OPEN
                     (reset counter)            (threshold exceeded)
                                                    |
                                              (timeout expires)
                                                    v
                                               HALF_OPEN
                                              /         \
                                       Success           Failure
                                          /               \
                                    CLOSED                 OPEN
                                    (reset)           (timeout reset)
```

**Configuration Parameters:**

| Parameter | Default | Description |
|-----------|---------|-------------|
| failure_threshold | 5 | Consecutive failures before opening |
| success_threshold | 2 | Consecutive successes in half-open to close |
| timeout | 60s | Duration to wait before transitioning to half-open |
| half_open_max_calls | 1 | Max concurrent probes in half-open state |
| monitored_errors | All retryable errors | Error types that count toward threshold |
| excluded_errors | Validation errors | Errors that do not affect circuit state |

**Circuit Breaker Schema:**

```json
{
  "circuit_breaker": {
    "name": "string",
    "state": "CLOSED|OPEN|HALF_OPEN",
    "failure_threshold": 5,
    "success_threshold": 2,
    "timeout_ms": 60000,
    "half_open_max_calls": 1,
    "monitored_errors": ["TIMEOUT", "SERVICE_UNAVAILABLE", "CONNECTION_REFUSED"],
    "excluded_errors": ["VALIDATION_ERROR", "NOT_FOUND"],
    "metrics": {
      "failure_count": 0,
      "success_count": 0,
      "last_failure": "ISO-8601 (optional)",
      "last_success": "ISO-8601 (optional)",
      "state_since": "ISO-8601",
      "total_trips": 0,
      "last_trip": "ISO-8601 (optional)"
    },
    "notifications": {
      "on_open": ["COO", "CTO"],
      "on_close": ["COO"],
      "on_half_open": []
    }
  }
}
```

**Per-Department Circuit Breaker Defaults:**

| Department | Failure Threshold | Timeout | Success Threshold | Rationale |
|-----------|-------------------|---------|-------------------|-----------|
| Finance | 3 | 30s | 2 | Financial operations require rapid detection |
| Security | 2 | 15s | 1 | Security services must fail fast |
| Operations | 5 | 60s | 2 | Operational resilience priority |
| Technology | 5 | 45s | 2 | Engineering services with normal variance |
| Intelligence | 5 | 120s | 3 | External data sources may be intermittently unavailable |
| All others | 5 | 60s | 2 | Standard resilience profile |

**Example — External API Circuit Breaker:**

```json
{
  "circuit_breaker": {
    "name": "market-data-api",
    "state": "CLOSED",
    "failure_threshold": 3,
    "success_threshold": 2,
    "timeout_ms": 30000,
    "half_open_max_calls": 1,
    "monitored_errors": ["TIMEOUT", "SERVICE_UNAVAILABLE", "RATE_LIMIT"],
    "excluded_errors": ["VALIDATION_ERROR", "NOT_FOUND", "AUTH_FAILED"],
    "metrics": {
      "failure_count": 0,
      "success_count": 12,
      "last_failure": null,
      "last_success": "2026-04-27T15:30:00Z",
      "state_since": "2026-04-27T14:00:00Z",
      "total_trips": 2,
      "last_trip": "2026-04-26T09:15:00Z"
    },
    "notifications": {
      "on_open": ["CTO", "COO", "CFO"],
      "on_close": ["CTO"],
      "on_half_open": []
    }
  }
}
```

### 3.4 Error Classification and Routing

All execution errors are classified and routed according to their severity and type. This ensures that the appropriate recovery strategy is applied and the right stakeholders are notified.

**Error Classification Matrix:**

| Error Code Prefix | Department | Recovery Strategy | Notification |
|-------------------|-----------|-------------------|--------------|
| CEO_ | Governance | Escalate to Board if critical | CEO + Board |
| COO_ | Operations | Retry + fallback procedure | COO + affected department |
| CFO_ | Finance | Compensating transaction | CFO + CRO |
| CRO_ | Risk | Circuit breaker + risk assessment | CRO + CEO |
| CTO_ | Technology | Rollback + retry | CTO + COO |
| CISO_ | Security | Immediate containment | CISO + CEO + Board |
| CLO_ | Legal | Stop execution, legal review | CLO + CEO |
| CQO_ | Quality | Halt pipeline, quality review | CQO + CTO |
| FW_ | Framework | Rollback to last stable version | CTO + CQO |
| PMGR_ | Project | Reprioritize + reassign | PMGR + COO |
| INTEL_ | Intelligence | Fallback data source | Intel + CMO |
| INFO_ | Information | Cache + retry | Info + CTO |
| TR_ | Translation | Fallback to original language | Translator + CMO |

---

