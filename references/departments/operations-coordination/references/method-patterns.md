# Department Method Patterns — Operations & Coordination

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to operations and coordination.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 7 `generate_trace_id` | Prefix `coo` on every routing decision, bus event and register entry | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask before any register, log or audit record is distributed | [method-patterns.md §3.9](../../../method-patterns.md) |
| 4 `format_output_json` | Label every WFT-003 alert summary and PDCA report | [method-patterns.md §3.4](../../../method-patterns.md) |
| 5 `retry_with_backoff` | Bounded backoff when re-queueing a losing claimant or re-sending a request | [method-patterns.md §3.5](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate an allocation or coordination request carries its required fields | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: priority-class arbitration

```text
arbitrate_resource(claim_a, claim_b) -> grant + requeue
  order: priority_class (P1 > P2 > P3) > requested_window > arrival
```

| Element | Rule |
|---|---|
| `priority_class` | P1 outranks P2 outranks P3 — arrival order is never consulted |
| `winner` | Receives the grant immediately |
| `loser` | Re-queued with backoff (template 5), never discarded |
| `tie` | Equal class and window → escalate to `executive-strategy`; the resource is never split |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
backoff or masking — it calls them.

## Department-specific pattern: deadlock breaker

```text
break_deadlock(queue) -> preempted + signature
  victim = lowest-priority holder in the detected cycle
```

| Element | Rule |
|---|---|
| `cycle` | Circular wait across ≥ 2 queued operations |
| `victim` | The lowest-priority holder in the cycle |
| `preempted work` | Re-queued with its original trace ID intact — never discarded |
| `signature` | Recorded so the same cycle cannot recur silently |
| `raise` | `COO_005` on detection |

## Department-specific pattern: coordination timeout ladder

```text
coordinate(request) -> ack | timeout(COO_006) | escalate
  0 h  send, trace ID attached
  4 h  no ack  -> COO_006, re-send at elevated priority, notify the owner
  8 h  silent  -> escalate up the ladder
```

| Elapsed | Action | Never |
|---|---|---|
| 0 h | Send to the owning department | Send without a trace ID |
| 4 h | `COO_006`: re-send elevated, notify the owner | Treat one late reply as a breach |
| 8 h | Escalate up the ladder | Re-send indefinitely |

⚠️ A request re-sent forever is a request nobody owns. The ladder exists so every request has a
terminal owner at every point in its life.

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not resolve a resource conflict by arrival order — priority class decides
- ❌ Do not discard pre-empted work when breaking a deadlock
