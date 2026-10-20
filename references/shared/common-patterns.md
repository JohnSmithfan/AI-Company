# Common Operational Patterns

> Shared patterns used across departments (medium tier).

## Crisis command

1. Acknowledge within 15 minutes. 2. Assign a named owner. 3. Activate the protocol.
4. File a post-mortem within 24 hours.

## Quality gate

- Coverage >= 85%. - No case requires network access. - Every test asserts one behavior.

## Error handling

- Quarantine the failing unit. - Add error handling, retry, and idempotency.
- Re-assess before re-delivery. - Record the bypass in the audit trail.

## Audit trail

- Persist every agent-to-agent hop. - Hash evidence chains for internal audit.
- Never self-modify permissions, tests, or gating scripts.