# Department Method Patterns — Intelligence & Sentiment

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to intelligence-cycle work.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 4 `format_output_json` | Label every SITREP and intelligence product | [method-patterns.md §3.4](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `intel` on every product and register entry | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask sentiment sources that carry personal data | [method-patterns.md §3.9](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a product carries confidence, source list and classification | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: confidence gate

```text
confidence_gate(product) -> publish(score) | corroborate(INTEL_002)
  rule: the score is published, never omitted
```

| Element | Rule |
|---|---|
| threshold | Below 40 % raises `INTEL_002`; the product still publishes, with the score stated |
| corroboration | The weakest evidence link is identified and corroborating sources collected |
| publication | The score is printed on the product; an unmarked low-confidence product is refused |
| rounding | Never upward — a rounded score is a fabricated score |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
labelling or masking — it calls them.

## Department-specific pattern: source reliability register

```text
register_entry(source, attempt) -> rating | downgrade(INTEL_003) | degraded(INTEL_001)
```

| Event | Register effect |
|---|---|
| Verification pass | Rating raised at most one band per attempt, with the attempt recorded |
| Verification failure | `INTEL_003` — downgrade, exclude from products until re-verified |
| Second failed collection run | Rating D (degraded); restoration requires re-verification |
| Integrity-check failure | `INTEL_006` — restore from the last consistent snapshot; re-verify entries touched since |

⚠️ A rating is never edited in place without the attempt recorded. The register's value is its
history, not its current value.

## Department-specific pattern: SITREP assembler

```text
sitrep(findings, sources, gaps) -> report | partial(gaps marked, INTEL_005)
```

Gaps are marked fields, not omissions: a reader must be able to tell a missing signal from a
quiet market. Distribution is the subscription list, verbatim — a recipient outside the list is
a disclosure incident regardless of content quality.

## Constraints

- ❌ Do not reimplement labelling, masking or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not publish a product without its confidence score
- ❌ Do not edit a register rating without recording the verification attempt
