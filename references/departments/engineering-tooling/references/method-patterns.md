# Department Method Patterns — Engineering & Tooling

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md). This file links to them and adds only what is
> specific to engineering and deployment.

## Shared templates this department uses

| Template | Use in this department | Source |
|---|---|---|
| 3 `execute_safe_command` | Run build and diagnostic commands — list args, never a shell string | [method-patterns.md §3.3](../../../method-patterns.md) |
| 5 `retry_with_backoff` | Retry idempotent pipeline stages only | [method-patterns.md §3.5](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `cto` on deployments and agent creations | [method-patterns.md §3.7](../../../method-patterns.md) |
| 8 `check_rate_limit` | Bound tool and CI invocation rates | [method-patterns.md §3.8](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate an agent manifest before creation | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: three-stage gate

```text
deployment_gate(build, stage) -> promote | halt(CTO_008)
```

| Stage | Traffic | Pass criterion | On fail |
|---|---|---|---|
| canary | ≤ 5 % | error rate ≤ 1 %, 30 min | halt, roll back to pre-deployment |
| staged | ≤ 25 % | error rate ≤ 1 %, 60 min | halt, roll back to canary |
| full | 100 % | SLO met, 24 h | `CTO_006`, roll back to staged, block re-deploy |

⚠️ A stage may only **halt or promote**. It may never skip forward, and a failed stage is never
retried in place — it rolls back and re-enters after remediation.

## Department-specific pattern: atomic rollback

The ordering is fixed and must not be inverted:

```text
rollback(target_state):
    1. copy target_state forward to staging
    2. VERIFY the staged copy is complete and consistent
    3. atomically replace live state
    4. confirm at outcome level
    5. only now delete the superseded state
```

⚠️ **Never delete before a verified copy exists.** A predecessor package ran a recursive
force-delete on the whole directory and restored afterward; any failure during restore left the
package gone with no recovery path.

## Department-specific pattern: Harness assessment

```text
assess_harness(capability) -> L1..L6 with evidence
```

Returns the highest level whose evidence is present, not the level claimed. Over-declaration raises
`FW_006`. Evidence requirements per level are in the D3 spec §3.B.

## Department-specific pattern: grant check

```text
production_grant(operation) -> allow | deny(CTO_004)
```

Checked **before** execution. A denial names the rung that can grant it, so the requester has a path
forward rather than a dead end.

## Constraints

- ❌ Do not reimplement safe command execution, retry or rate limiting here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not pass a shell string to command execution — list arguments only
- ❌ Do not invert the rollback ordering
- ❌ Do not retry a non-idempotent pipeline stage
