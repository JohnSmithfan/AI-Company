# Department Method Patterns — Executive & Strategy

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to governance decision-making.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 4 `format_output_json` | Label every decision record and directive | [method-patterns.md §3.4](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `ceo` on every decision record | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask before a decision record is distributed | [method-patterns.md §3.9](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a decision request carries its required fields | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: decision record

```text
decision_record(
    question, options, evidence, chosen,
    reversibility, authority_basis, review_date
) -> labelled, masked, traceable record
```

| Element | Rule |
|---|---|
| `options` | ≥ 2, always including "do nothing" |
| `evidence` | Each item carries a source and an as-of timestamp |
| `authority_basis` | The authorization-matrix row that grants the decision |
| `review_date` | Mandatory — a record without one is incomplete |
| Output | Passed through template 4 (label) and template 9 (mask) before distribution |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: arbitration evaluation

Fixed-order comparison used by SOP-CEO-02:

```text
arbitrate(position_a, position_b) -> winner + rationale
  order: evidence_quality  >  scope_authority  >  reversibility
```

| Rank | Criterion | Tiebreak |
|---|---|---|
| 1 | Evidence quality (source reliability, freshness, sample size) | → rank 2 |
| 2 | Scope authority (which department owns the decision) | → rank 3 |
| 3 | Reversibility (cheaper to undo wins) | → escalate to `board-and-branch` |

⚠️ Splitting the difference is **not** an outcome of this function. If all three criteria tie, the
item escalates; it is not halved.

## Department-specific pattern: crisis state guard

```text
crisis_guard(action) -> allow | deny(CEO_008)
```

During an active crisis, any action on the blacklist is refused and the attempt is recorded. The
guard is checked **before** the action, never after.

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not let a decision record skip the review-date field
- ❌ Do not produce an arbitration outcome of "compromise"
