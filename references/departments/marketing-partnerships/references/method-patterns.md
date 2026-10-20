# Department Method Patterns — Marketing & Partnerships

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to brand, go-to-market and partnership work.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 4 `format_output_json` | Label every externally facing payload (AIGC triple) | [method-patterns.md §3.4](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `cmo` on every published record | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask content that carries personal data before release | [method-patterns.md §3.9](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a GTM plan carries all §3.B components | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: brand conformance review

```text
brand_review(payload) -> conformant | divergent(CMO_001)
  rule: checked before publication, against recorded rules only
```

| Element | Rule |
|---|---|
| rulebook | The recorded rules are the only authority — taste is not a criterion |
| divergence | Name the divergent element; regenerate within the rules; withdraw the old copy |
| post-publication | A late finding is a withdrawal, never a quiet edit |
| new element | A rules change — route to `executive-strategy`, never legislate inside a review |
| Output | Passed through template 4 (label) before release |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
labelling or masking — it calls them.

## Department-specific pattern: partnership conflict guard

```text
conflict_guard(term_sheet) -> clear | conflict(CMO_003) -> legal-privacy
```

Evaluated **before** signature, against the existing commitment register:

| Check | Rule |
|---|---|
| Register scan | Every existing commitment is scanned for the conflicting clause |
| Determination | Owned by `legal-privacy` — this department never judges the clause itself |
| Signature state | Blocked while the conflict stands; an unsigned conflict is a delay, not a loss |
| Exit terms | Confirmed before the commitment is scored final |

⚠️ A conflict resolved by optimism rather than by a determination is a breach with a delay
attached. The guard returns a routing, never a local verdict.

## Constraints

- ❌ Do not reimplement labelling, masking or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not quietly edit a post-publication divergence — withdraw it
- ❌ Do not let a partnership be signed on a locally judged conflict
