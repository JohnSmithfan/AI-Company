# Department Method Patterns — Finance & Treasury

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to financial management and treasury.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 7 `generate_trace_id` | Prefix `cfo` on every budget decision and report | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask before a budget position is distributed | [method-patterns.md §3.9](../../../method-patterns.md) |
| 4 `format_output_json` | Label every financial report and variance directive | [method-patterns.md §3.4](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a budget request carries its required fields | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: budget position

```text
budget_position(period) -> committed + encumbered + free
```

| Element | Rule |
|---|---|
| `committed` | Approved commitments not yet spent |
| `encumbered` | Open purchase orders and contracts against the line |
| `free` | The remainder — the only figure that may be committed against |
| Output | A single total is incomplete; all three components are returned |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: variance gate

```text
variance_gate(actual, budget) -> pass | overrun(CFO_001)
  threshold: >10 % of the quarterly budget
```

| Band | Response |
|---|---|
| ≤ 10 % | Record the variance; no gate |
| > 10 % | `CFO_001`; freeze non-essential spend, produce the analysis, submit for approval |

⚠️ The gate fires on the measured value, never on a forecast. A forecasted overrun is a warning,
not a gate.

## Department-specific pattern: pricing validation

```text
pricing_check(price, cost_basis) -> pass | invalid(CFO_002)
  tests: margin floor, then elasticity sanity band
```

| Test | Rule |
|---|---|
| Margin floor | Recomputed unit economics must clear the floor |
| Elasticity band | The demand assumption must sit inside the sanity band |
| Outcome | Revise or reject — an unpriced offer is never shipped |

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not publish a budget position as a single total
- ❌ Do not approve a tier upgrade here — approval belongs to a human
