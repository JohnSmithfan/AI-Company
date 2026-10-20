# Department Method Patterns — Knowledge & Ethics

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to knowledge governance and ethics review.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 4 `format_output_json` | Label every distilled knowledge item and review record | [method-patterns.md §3.4](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `knm` on every extraction and review record | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask before any knowledge item is persisted | [method-patterns.md §3.9](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate an extraction source carries its trace ID and provenance | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: distillation with supersession

```text
distill(batch) -> merged store | empty(KNM_001) | lossy(KNM_005)
  rule: merge and supersede - never delete
```

| Element | Rule |
|---|---|
| empty result | Raise `KNM_001`; retain the prior distilled state — an empty batch never overwrites a good one |
| duplicates | Merged, with both provenance records kept |
| contradictions | Resolved by supersession, never by deletion |
| un-superseded drop | Stops the run — `KNM_005`; loss is not a distillation outcome |
| cadence | `Knowledge` and `Learning` every 30 days; the interval resets only after verification |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: ethics review guard

```text
ethics_guard(decision) -> allow | block(KNM_003)
```

While a review is open, the dependent action is blocked. The guard is checked **before** the
action, never after.

| State | Effect on the dependent action |
|---|---|
| Review open | Blocked — `KNM_003` raised on the decision |
| Cleared with conditions | Permitted only within the recorded conditions |
| Breach confirmed | Halted under `KNM_004`; resume needs a recorded outcome |
| No review required | Not routed here — `legal-privacy` owns the trigger list |

⚠️ A block released by urgency was never a real block. Only a completed review moves the
state.

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not let a consolidation run drop an item without a successor pointer
- ❌ Do not release an ethics block without a recorded review outcome
