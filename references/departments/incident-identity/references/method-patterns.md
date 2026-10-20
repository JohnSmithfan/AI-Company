# Department Method Patterns — Incident & Identity

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to incident response and identity work.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 4 `format_output_json` | Label every incident record and revocation notice | [method-patterns.md §3.4](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `irp` on every incident, revocation and review record | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask an incident record before distribution | [method-patterns.md §3.9](../../../method-patterns.md) |
| 5 `retry_with_backoff` | Bounded retry when re-hashing or re-verifying evidence | [method-patterns.md §3.5](../../../method-patterns.md) |

## Department-specific pattern: evidence-first incident guard

```text
incident_guard(action) -> analyse_first | remediate(recorded_alteration)
  order: preserve -> analyse -> remediate
```

| Step | Rule |
|---|---|
| Preserve | Hash on acquisition; evidence log opens in Declare |
| Analyse | Read-only against the preserved copy |
| Remediate | Only after analysis, or with the alteration recorded in advance |
| Violation | Raises `IRP_002` — remediation that alters evidence is a second incident |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: credential exposure response

```text
credential_guard(indicator) -> revoke -> rotate -> audit(IRP_004)
```

| Step | Rule |
|---|---|
| Revoke | ≤ 15 min from indicator — never wait for confirmation |
| Rotate | Every downstream dependency holding the same secret |
| Audit | Usage across the exposure window, ≤ 24 h |
| Reference | Environment-variable name only — never the value |

## Department-specific pattern: default-revoke access review

```text
access_review(grants) -> confirm | tighten | revoke(IRP_005)
  default for unreviewed grants: revoke
```

| State | Rule |
|---|---|
| Confirmed | Owner attestation recorded |
| Tightened | Reduced to least privilege; no ambient authority |
| Unreviewed | Revoked by default — an unreviewed grant is an unowned grant |
| Restore | Requires a recorded owner attestation, not a request |

⚠️ Default-revoke is deliberate. A review that restores by default converts a control into a
rubber stamp.

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not let remediation precede evidence preservation in any code path
- ❌ Do not record or log a credential by its value — the environment-variable name only
