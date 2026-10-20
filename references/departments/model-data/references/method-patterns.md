# Department Method Patterns — Model & Data

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to model and data work.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 1 `validate_input_schema` | Validate configs, payloads and schema contracts (`MDL_006`) | [method-patterns.md §3.1](../../../method-patterns.md) |
| 5 `retry_with_backoff` | Model-call retries before fallback (`MDL_E007`) | [method-patterns.md §3.5](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `mdl` on every invocation and pipeline stage | [method-patterns.md §3.7](../../../method-patterns.md) |
| 8 `check_rate_limit` | Provider rate-limit headroom and extraction limiting (`MDL_005`) | [method-patterns.md §3.8](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask PII at the pipeline persistence phase | [method-patterns.md §3.9](../../../method-patterns.md) |

## Department-specific pattern: fallback chain resolution

```text
resolve_model(request) -> model | raise(MDL_001..006)
  order: registered -> enabled -> key present -> headroom -> invoke
```

| Step | Rule |
|---|---|
| 1 registered | Unknown id → `MDL_001`; confirm spelling, register or select an alternative |
| 2 config | Unresolvable `config_path` → `MDL_002`; run the path check first |
| 3 enabled | Disabled flag set → `MDL_003`; next chain entry serves |
| 4 key | Variable unset → `MDL_004`; **halt** — shifting load moves the failure, it does not fix it |
| 5 headroom | Rate-limited → `MDL_005`; template 8 backoff, then shift load |
| 6 invoke | Transport or provider error → `MDL_E007`; retry via template 5, then fallback |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not
redefine backoff, masking or trace-ID generation — it calls them.

## Department-specific pattern: config contract check

```text
check_config(entry) -> ok | invalid(MDL_006)
  diff against models/api/template/config.json
```

| Element | Rule |
|---|---|
| Parse | A file that does not parse is reported as missing, not invalid (`MDL_002`) |
| Diff | Every template field must be present and correctly typed |
| Remediation | Add the missing fields, then re-validate before use |
| Timing | The check runs at registration, not at first call — a late breach is a defect |

## Department-specific pattern: provenance-preserving fusion

```text
fuse(sources) -> dataset | quarantine(record)
  every record keeps: source chain · retrieval timestamps · transform chain
```

| Rule | Reason |
|---|---|
| Per-record provenance is mandatory | A record whose source cannot be traced cannot be challenged or corrected |
| Disagreement is recorded, not resolved by order | Silent first-wins hides which source was authoritative |
| Provenance-dropped records are quarantined | Publishing them launders unverifiable data into the dataset |

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not report an API key's value anywhere — the variable name only (`MDL_004`)
- ❌ Do not publish a fused record whose provenance was dropped — quarantine it
