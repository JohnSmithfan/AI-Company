# Department Method Patterns — Security & Resilience

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md). This file links to them and adds only what is
> specific to security and resilience.

## Shared templates this department uses

| Template | Use in this department | Source |
|---|---|---|
| 1 `validate_input_schema` | Validate a change request before gating it | [method-patterns.md §3.1](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `ciso` on threat models, gate decisions, recovery tests | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask before any finding or evidence is recorded | [method-patterns.md §3.9](../../../method-patterns.md) |
| 4 `format_output_json` | Label every gate decision and test report | [method-patterns.md §3.4](../../../method-patterns.md) |

## Department-specific pattern: gate decision

```text
security_gate(change) -> pass | block(CISO_001, failing_control)
```

| Outcome | Permitted follow-up |
|---|---|
| `pass` | Change proceeds to the next WFT-007 stage |
| `block` | Remediate and re-enter, **or** record an accepted-risk exception **with an expiry** |

⚠️ Two outcomes only. An exception without an expiry is refused — it is an unbounded waiver. There
is no silent-pass path: a gate that can be passed without a record is not a gate.

## Department-specific pattern: CVSS record

```text
score_vulnerability(finding) -> { vector_string, score, band, window, owner }
```

| Field | Rule |
|---|---|
| `vector_string` | Full CVSS vector — **mandatory**, a bare number is rejected |
| `band` | Derived from the score: critical / high / medium / low |
| `window` | 24 h / 7 d / 30 d / 90 d by band |
| escalation | Critical (≥ 9.0) also raises `CISO_002`, opens `IRP_001`, notifies `board-and-branch` |

## Department-specific pattern: STRIDE walk

```text
stride_model(element) -> [threat per category with control + status]
```

Iterates the six categories (Spoofing, Tampering, Repudiation, Information disclosure, Denial of
service, Elevation of privilege) over each element in scope. An unmitigated threat raises
`CISO_003`. Closure re-runs the model — it is never satisfied by an assertion that a control exists.

## Department-specific pattern: recovery verification

```text
verify_recovery(function) -> { rto_measured, rpo_measured, met, level }
```

| Field | Rule |
|---|---|
| `level` | Must be **outcome** for the recovery to count — a command exit code is not recovery evidence |
| `met` | Comparison against the committed RTO/RPO |
| breach | Raises `CISO_005`, naming the bottleneck stage |

⚠️ A test scheduled but not run returns `met = false` with `level = none`. It is reported as a
coverage gap, never as a pass.

## Department-specific pattern: control evidence check

```text
check_evidence(control) -> proven | unproven(CISO_006)
```

An `unproven` control may not be cited as mitigation in a threat model or an accepted-risk
exception. Evidence is superseded with a pointer, never deleted.

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not record a CVSS score without its full vector string
- ❌ Do not allow a silent gate pass
- ❌ Do not accept an exception without an expiry date
- ❌ Do not count an unrun recovery test as a pass
