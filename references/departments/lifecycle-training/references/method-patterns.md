# Department Method Patterns — Lifecycle & Training

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to agent lifecycle management.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 4 `format_output_json` | Label every onboarding record and certification record | [method-patterns.md §3.4](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `cho` on every lifecycle record | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask Profile memory fields before any persistence | [method-patterns.md §3.9](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate an onboarding checklist carries its required fields | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: onboarding checklist

```text
onboarding_checklist(
    agent_manifest, archetype, harness_assessment
) -> completed record | incomplete(CHO_001)
  rule: every item must close with evidence
```

| Element | Rule |
|---|---|
| `harness_assessment` | Required — an agent without it is returned to `engineering-tooling`, never onboarded |
| item closure | Each item stores its closure evidence; a checkmark without evidence is not a closure |
| failure | Raise `CHO_001` naming the unmet item; the record stays open until re-run |
| `Profile memory` | Written during onboarding, masked at creation through template 9 |
| Output | Passed through template 4 (label) and template 7 (trace, prefix `cho`) |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: lifecycle stage guard

```text
stage_guard(agent, action) -> allow | suspend(CHO_003)
```

An agent's permitted actions are a function of its lifecycle stage. The guard is evaluated
**before** the action, never after.

| Stage | Permitted | Blocked |
|---|---|---|
| Onboarding | Checklist items, Profile memory writes | Production assignments |
| Active | Assigned work within capability scope | Stage-escalating operations |
| Suspended | Read-only diagnostics | Any state-changing action |
| Offboarding | Exit steps 3–5 of SOP-CHO-02 | New assignments |

⚠️ Suspension is recorded with the mismatch identified; an agent is never suspended without a
diagnosis, and re-entry happens at the correct stage only.

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not let a checklist close on a checkmark without closure evidence
- ❌ Do not resolve a stage violation by widening the stage instead of correcting the agent
