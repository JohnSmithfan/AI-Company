# Department Method Patterns — Board & Branch

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to board governance and branch control.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 7 `generate_trace_id` | Prefix `brd` on every vote, matrix revision and branch register entry | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask before any minute, revision or register is distributed | [method-patterns.md §3.9](../../../method-patterns.md) |
| 4 `format_output_json` | Label every shareholder report and board minute | [method-patterns.md §3.4](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a vote record or matrix revision carries its required fields | [method-patterns.md §3.1](../../../method-patterns.md) |

## Department-specific pattern: quorum gate

```text
quorum_gate(vote) -> proceed | defer(BRD_001)
```

| Element | Rule |
|---|---|
| `present` | Required board roles present at call time, remote attendees included |
| `defer` | Missing quorum defers the vote; absent members notified; re-convene within 48 h |
| `never` | A binding decision is never taken on a partial board — there is no override path |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
labelling or masking — it calls them.

## Department-specific pattern: matrix ratification record

```text
ratify_matrix(revision) -> effective(revision) | return(revision)
```

| Element | Rule |
|---|---|
| `rationale` | One per changed row — "miscellaneous" is not a rationale |
| `effective_date` | Mandatory — a matrix with no effective date is not in force |
| `supersedes` | Pointer to the prior version; the prior version is never deleted |
| `return` | A revision missing a field is returned, not ratified with a note |

## Department-specific pattern: branch autonomy guard

```text
branch_guard(action, scope) -> allow | revoke(BRD_006)
```

| Element | Rule |
|---|---|
| `scope` | The branch's scoped operations matrix |
| `revoke` | The offending capability is revoked and the pre-action state restored |
| `restore` | Requires a recorded root cause and a board review — never a verbal assurance |

⚠️ Autonomy is granted by the matrix and exists only inside it. A branch that exceeds its scope
has not been entrepreneurial; it has been ungoverned.

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not take a binding vote without quorum
- ❌ Do not approve a tier upgrade here — approval belongs to a human
