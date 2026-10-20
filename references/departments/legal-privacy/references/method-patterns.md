# Department Method Patterns — Legal & Privacy

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to legal and privacy work.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 4 `format_output_json` | Label every determination and withdrawal notice | [method-patterns.md §3.4](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `clo` on every review record and determination | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask a determination before it leaves this department | [method-patterns.md §3.9](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a review request carries its required fields | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: compliance determination

```text
determination(
    subject, obligation, basis, outcome,
    mechanism, reviewer, as_of
) -> labelled, masked, traceable record
```

| Element | Rule |
|---|---|
| `obligation` | The recorded obligation, with its source regulation |
| `basis` | Legal basis for PII flows; mechanism name for transfers |
| `outcome` | Approve / approve-with-changes / reject / halt — never "pending" as a final state |
| `reviewer` | Named — an anonymous review is not a review |
| `as_of` | Mandatory — a determination with no as-of date cannot be re-verified |
| Output | Passed through template 4 (label) and template 9 (mask) before distribution |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: AIGC triple-label gate

```text
aigc_gate(output) -> pass | withdraw(CLO_003)
  layers: label, metadata, watermark - all three, every time
```

| Layer | Failure mode if skipped |
|---|---|
| Label | Human recipients cannot tell generated from sourced |
| Metadata | Downstream systems cannot filter or attribute |
| Watermark | Format conversion strips the identification |

The remedy for any failing layer is **re-emission through template 4**, not patching the copy —
a patched copy keeps its original distribution history.

## Department-specific pattern: residency check

```text
residency_check(dataset) -> permitted(mechanism) | halt(CLO_006)
```

| Check | Rule |
|---|---|
| Storage region | Mapped separately from processing region |
| Transfer mechanism | Cited by name (SCC, standard contract, certification) |
| Encryption | ❌ Never accepted as a mechanism — it protects transit, not permission |
| Determination | Recorded per dataset with an as-of date; re-verified on region change |

⚠️ A residency determination without a named mechanism is an assumption, not a determination.

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not let a determination skip the as-of date or the named reviewer
- ❌ Do not record a cross-border transfer with encryption as its mechanism
