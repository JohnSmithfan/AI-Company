# Command Center

> L3 depth file for [../execution.md](../execution.md). Owning department: `operations-coordination`.

The command center is the coordination layer: it holds the priority queue, allocates resources
across departments, and monitors execution health.

## 1. Priority Queue

| Class | Definition | Pre-emption | SLA (start within) |
|---|---|---|---|
| **P0** | Active security incident, data loss in progress, regulatory deadline < 24 h | May pre-empt P2 and P3 | 5 min |
| **P1** | Customer-facing impact, SLA breach in progress | May pre-empt P3 | 30 min |
| **P2** | Committed internal work with a deadline | No pre-emption | 4 h |
| **P3** | Routine, background, discretionary | Yields to all | Next available window |

Queue discipline:

| Rule | Detail |
|---|---|
| FIFO within a class | No queue-jumping inside the same priority |
| Starvation guard | A P3 item waiting > 72 h is promoted to P2 automatically |
| Fair share | No single department may hold > 40 % of active slots |
| Deadlock detection | Circular wait across ≥ 2 queued operations → `COO_005` |
| Deadlock breaking | Pre-empt the lowest-priority holder, re-queue its work, record the signature |

## 2. Resource Allocation

| Resource | Unit | Contention policy |
|---|---|---|
| Model invocation budget | USD per day | Higher priority class wins; loser re-queued with backoff |
| Rate-limit quota | Calls per minute per provider | Shared pool, template 8 enforced per identifier |
| Concurrent workflow slots | Count | Fair share cap of 40 % per department |
| Context budget | Tokens | Progressive disclosure D1→D2→D3, never load D3 speculatively |

Allocation failure raises `COO_004`; the requester receives the next available window rather than
a bare refusal.

## 3. Monitoring

| Signal | Threshold | Action on breach |
|---|---|---|
| Workflow completion within SLA | ≥ 95 % | Investigate the slowest phase |
| Error rate per department | ≤ 5 % over 1 h | Open the circuit breaker |
| Queue depth | ≤ 50 items | Shed P3 work, notify `executive-strategy` |
| Oldest queued item age | ≤ 72 h | Starvation guard promotes it |
| Retry exhaustion rate | ≤ 2 % | Review the upstream dependency |
| Routing accuracy | ≥ 85 % | Third consecutive breach → trigger T3 |

Monitoring data is written to `Session` memory for the current window and distilled into
`Knowledge` on the 30-day cycle — see [../memory.md](../memory.md).

## 4. Escalation Ladder

| Rung | Decision authority | Response SLA |
|---|---|---|
| 1 | Owning department | 4 h |
| 2 | `operations-coordination` (COO) | 2 h |
| 3 | `executive-strategy` (CEO) | 1 h |
| 4 | `board-and-branch` (Board) | 30 min |
| 5 | Out-of-cycle board review | Immediate |

An item that reaches rung 5 without resolution is frozen and recorded, including a recorded
decision of "no decision" — an unresolved item is never silently dropped (`BRD_004`).
Escalation timeout at any rung raises `CEO_007`.

## 5. Cross-Department Arbitration

When two departments return contradictory recommendations (`CEO_003`):

```text
1. freeze both recommendations
2. identify the contradiction precisely - which claim, which evidence
3. operations-coordination arbitrates using:
   a. evidence quality (source reliability, freshness, sample size)
   b. scope authority (which department owns the decision)
   c. reversibility (prefer the recommendation that is cheaper to undo)
4. record the arbitration rationale in the audit trail
5. release the winning recommendation; the loser gets the rationale
```

Arbitration is never a coin flip and never "ask both to compromise" — one recommendation wins and
the reasoning is recorded so the decision can be revisited when new evidence arrives.

## 6. Constraints

- ❌ Do not let one department hold more than 40 % of active slots
- ❌ Do not drop an unresolved escalation silently
- ❌ Do not break a deadlock by killing the highest-priority holder
- ❌ Do not arbitrate a contradiction without recording the rationale
- ❌ Do not promote a P3 item manually past the starvation guard without a reason
- ❌ Do not allocate resources to an unauthenticated manual request
