# Schema Security

> L3 depth file for [../data-integration.md](../data-integration.md). Owning department: `model-data`,
> with `security-resilience` reviewing the controls.

Schemas are data, never code. This file defines how inbound structure is validated without
creating an execution or injection surface.

## 1. Validation Contract

Every inbound payload passes template 1 (`validate_input_schema`) **before** any field is read.

| Property | Requirement |
|---|---|
| Order | Validate → then parse → then use. Never use-then-validate |
| Failure mode | Reject with the offending field named — `FW_001` |
| Fallback | When the optional `jsonschema` package is absent, structural checks still run (required keys, declared types). Validation never silently passes because a dependency is missing |
| Depth | Nested objects and arrays validated recursively |
| Bypass | None. No "trusted source" exemption |

⚠️ A trusted source that is compromised is still a source. The exemption is what turns one
compromised upstream into a package-wide failure.

## 2. Schema Authoring Rules

| Rule | Reason |
|---|---|
| Declare `type` on every property | An undeclared type accepts anything |
| Declare `required` explicitly | Absence of a required list means every field is optional |
| Bound every numeric | Unbounded values enable resource exhaustion |
| Bound every string length | Same |
| Bound every array length | Same |
| Enumerate closed sets | An open string where a set was intended accepts injection payloads |
| No `additionalProperties: true` on inbound schemas | Unknown fields become an smuggling channel |
| Nesting depth ≤ 5 | Deep nesting enables parser exhaustion |

## 3. Field Allowlist

Only declared fields are persisted.

```text
inbound payload → validate against schema → project onto the allowlist → persist
```

| Behaviour | Detail |
|---|---|
| Unknown field | Dropped **and logged** |
| Repeated unknown fields from one source | Rate-limited (template 8), then the source is reviewed |
| Field present but null | Treated as absent unless the schema declares null valid |
| Field of wrong type | Rejected — never coerced silently |

⚠️ **Silent type coercion is forbidden.** A string that looks numeric stays a string unless an
explicit conversion step converts it. Coercion is how `"1; DROP"` becomes a query fragment and how
`"true"` becomes truthy in a language where non-empty strings are true.

## 4. Size and Resource Bounds

| Bound | Value |
|---|---|
| Payload size | ≤ 1 MB — rejected before parsing |
| Field count | ≤ 200 per object |
| Nesting depth | ≤ 5 |
| String length | ≤ 64 KB per field |
| Array length | ≤ 10 000 items |
| Parse time | ≤ 5 s, else abort |

Rejecting **before** parsing is the point: a payload that exhausts the parser has already won.

## 5. Injection Surface Control

| Surface | Control |
|---|---|
| Query construction | Parameters only — never string interpolation |
| Command construction | Template 3, list arguments, `shell=False`; a string argument is rejected outright |
| Prompt construction | Template 10, which sanitizes every interpolated value via template 2 |
| Path construction | Template 6, resolve then confine to the skill directory |
| Template rendering | Literal `{placeholder}` replacement only — no attribute or index access, no expression evaluation |
| Log construction | Values masked (template 9) and control characters stripped |

⚠️ Template 3 rejecting a string command is not defensive over-caution. A string argument implies
shell interpretation, and shell interpretation of untrusted text is command injection by
construction.

## 6. Schema Versioning

| Rule | Detail |
|---|---|
| Version field | Every schema carries a version |
| Additive change | Minor version; existing producers keep working |
| Breaking change | Major version; both versions accepted during a deprecation window |
| Deprecation notice | 90 days minimum before a major version is withdrawn |
| Registry | Schemas registered; an unregistered schema is not usable (`FW_003`) |

Silently changing a schema in place breaks every producer at once and produces failures that look
like data problems rather than contract problems.

## 7. Model Registry Schema Security

Applies to `models/config/models-registry.json` and each model config.

| Control | Requirement |
|---|---|
| `config_path` resolution | Relative to `models/`, then existence-checked — an unresolvable path raises `MDL_002` |
| Path traversal | A `config_path` containing `..` is rejected before resolution |
| Field completeness | Every actual config carries every field the template declares (`MDL_006` otherwise) |
| Credentials | `env_var_name` holds a variable **name**; a value in that field is a leaked secret |
| Endpoint | Declared explicitly; no default endpoint is inferred |

⚠️ A registry entry pointing at a missing file breaks the whole fallback chain, not just that
model — the adapter raises on the first resolution failure. Every `config_path` must be
existence-checked after generation.

## 8. Audit

| Event | Logged |
|---|---|
| Validation failure | Field, schema version, source, trace ID |
| Unknown field dropped | Field name, source |
| Payload rejected on size | Declared size, source |
| Coercion attempted | Rejected, with the reason |
| Schema version change | Old and new version, approver |

Log entries carry masked values only — template 9 before the log line is written.

## 9. Constraints

- ❌ Do not read a field before validating the payload
- ❌ Do not exempt a "trusted" source from validation
- ❌ Do not coerce types silently
- ❌ Do not build a query, command, path or prompt by string interpolation
- ❌ Do not accept `additionalProperties: true` on an inbound schema
- ❌ Do not parse before the size bound is checked
- ❌ Do not store a credential value in a config file
- ❌ Do not change a schema in place without a version bump
