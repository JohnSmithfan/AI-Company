# Department Method Patterns — Procurement & Billing

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to procurement, billing and unit economics.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 7 `generate_trace_id` | Prefix `prc` on every purchase decision and invoice reconciliation | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask before a contract or invoice record is distributed | [method-patterns.md §3.9](../../../method-patterns.md) |
| 4 `format_output_json` | Label every unit-economics publication | [method-patterns.md §3.4](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a purchase request carries its approval rung | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: vendor evaluation

```text
vendor_evaluation(candidates, dimensions) -> ranked shortlist
  rule: every dimension scored, or a justified waiver recorded
```

| Element | Rule |
|---|---|
| `dimensions` | The required scoring set; an unscored dimension raises `PRC_001` |
| Waiver | Permitted only with a recorded justification — never silently |
| Output | Ranked shortlist with the score per dimension per candidate |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: invoice-to-contract diff

```text
invoice_diff(invoice_lines, contract_schedule) -> matched | mismatch(PRC_002)
  tolerance: >2 % divergence from the contracted rate
```

| Element | Rule |
|---|---|
| Diff | Line by line against the contract schedule, never in total |
| On mismatch | Dispute the delta with the vendor; withhold the disputed portion |
| Record | The dispute reference is recorded before any withholding |

## Department-specific pattern: billing reconciliation

```text
billing_reconcile(billed_units, metered_usage) -> matched | quarantined(PRC_004)
```

| Element | Rule |
|---|---|
| Re-meter | The period is re-metered before any adjustment is issued |
| Quarantine | Unmatched units are quarantined, never written off |
| Settlement | A credit or a supplemental invoice closes the quarantined delta |

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not pay an invoice >2 % off the contracted rate without a recorded dispute
- ❌ Do not approve a tier upgrade here — approval belongs to a human
