# Department Method Patterns — Risk & Audit

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to risk quantification and internal audit.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 7 `generate_trace_id` | Prefix `cro` on every risk score and audit finding | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask before an audit finding is distributed | [method-patterns.md §3.9](../../../method-patterns.md) |
| 4 `format_output_json` | Label every risk position and gate report | [method-patterns.md §3.4](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a risk request carries all four FAIR inputs | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: FAIR scoring

```text
fair_score(loss_event_frequency, probable_loss_magnitude,
           vulnerability, control_strength) -> annualized loss expectation
```

| Element | Rule |
|---|---|
| Four inputs | All four are mandatory; a missing input raises `CRO_003` |
| Estimates | Permitted, but each carries a stated confidence |
| Output | The score plus the residual-after-mitigation value |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: breaker state machine

```text
breaker(flow) -> CLOSED | OPEN | HALF_OPEN
  open:  5 consecutive failures, or 50 % over 20 calls
  cool-down: 60 s, then 3 probes; all 3 succeed -> CLOSED
```

| State | Behaviour |
|---|---|
| CLOSED | Flow passes; failures counted |
| OPEN | Flow stopped; owner and review date recorded |
| HALF_OPEN | Probe traffic only; any failure returns to OPEN |

Defaults are fixed in [../../../exec/error-recovery.md](../../../exec/error-recovery.md) §3.

## Department-specific pattern: stage-gate evaluation

```text
stage_gate(criterion, measured) -> pass | fail(CRO_004)
```

| Element | Rule |
|---|---|
| Report | Failing criterion plus its measured value — never a bare "fail" |
| Waiver | Never; gates are never waived silently |
| Re-entry | After remediation, the gate is re-run from the start |

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not score a risk without all four FAIR inputs
- ❌ Do not approve a tier upgrade here — approval belongs to a human
