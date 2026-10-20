# Department Method Patterns — Delivery & Scheduling

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to programme management and localization.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 7 `generate_trace_id` | Prefix `pmgr` on commitments, schedules and escalation records | [method-patterns.md §3.7](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a commitment carries scope, date and velocity basis | [method-patterns.md §3.1](../../../method-patterns.md) |
| 4 `format_output_json` | Label localized deliverables and status reports | [method-patterns.md §3.4](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask customer identifiers in escalation records | [method-patterns.md §3.9](../../../method-patterns.md) |

## Department-specific pattern: commitment record

```text
commitment(scope, date, velocity_basis) -> record | return(PMGR_005)
```

| Element | Rule |
|---|---|
| `scope` | Assignable units only — an undecomposed task is returned, never assigned |
| `velocity_basis` | The measured velocity the commitment was set against |
| Re-baseline | Once with the stakeholder; a second requires `executive-strategy` |
| Trace | Template 7, prefix `pmgr` |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: escalation timer

```text
escalation_timer(record) -> owner_within_1h | breach(PMGR_003)
```

| Stage | Rule |
|---|---|
| Intake | Criteria checked; record opened with its committed cadence |
| Owner | Assigned within 1 h — an escalation without an owner is not a process |
| Exposure | Regulatory or contractual exposure routes to `legal-privacy` |
| Closure | At outcome level, with the customer confirmation recorded |

## Department-specific pattern: language routing

```text
route(item_text) -> locale_path + trace_id
```

| Element | Rule |
|---|---|
| Detection | Language detected before routing; ambiguous detection asks, never guesses |
| Linkage | Every routed item links to an active OKR or is marked discretionary (`PMGR_002`) |
| Quality bar | Meaning intact · approved terminology · locale register · completeness |
| Below bar | Not published; conflicts escalate rather than being quietly rewritten |

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not assign an undecomposed task, or leave an item unlinked from an active OKR
- ❌ Do not deploy inside a committed window without `engineering-tooling` confirming it
