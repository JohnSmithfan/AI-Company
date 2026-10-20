# Department Method Patterns — Platform & MLOps

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to platform and MLOps work.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 1 `validate_input_schema` | Validate manifests and telemetry payloads (`FW_001`) | [method-patterns.md §3.1](../../../method-patterns.md) |
| 5 `retry_with_backoff` | Pipeline stage and model-call retries | [method-patterns.md §3.5](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `fw` on every pipeline run, ADR and event | [method-patterns.md §3.7](../../../method-patterns.md) |
| 8 `check_rate_limit` | Provider rate-limit headroom for model calls (`MDL_005`) | [method-patterns.md §3.8](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask telemetry before it leaves the platform boundary | [method-patterns.md §3.9](../../../method-patterns.md) |

## Department-specific pattern: harness certification

```text
certify_harness(capability, level) -> evidence | deny(FW_006)
  levels L1..L6, each an explicit constraint set
```

| Level | Rule |
|---|---|
| L1–L3 | Certified by this department on constraint evidence alone |
| L4–L5 | Certified by this department; the standing grant is checked against the authorization matrix |
| L6 | Certified jointly — `security-resilience` sign-off is mandatory, never assumed |
| Output | A certification record naming every evidenced constraint, traced with prefix `fw` |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not
redefine trace-ID generation or masking — it calls them.

## Department-specific pattern: pipeline stage guard

```text
pipeline_guard(run) -> green | fail(FW_007)
  order: schema-validate stage inputs → run stage → verify stage output
```

| Stage | Rule |
|---|---|
| Input | Validated against its declared schema before the stage executes (`FW_001` on breach) |
| Execution | The failing job is named from its log, never inferred from an exit code alone |
| Re-run | Always from the start — a partial re-run hides ordering faults |
| Security stages | The control set is mandatory; a skipped stage is a gate breach, reported to `security-resilience` |

⚠️ Skipping a stage to "get to green" converts the pipeline into an unverifiable claim. The
guard exists so that green means verified, not merely exited-zero.

## Department-specific pattern: model health router

```text
health_router(signal, model) -> keep | route_around
  signals: error_rate · p95_latency · rate_headroom · disabled_flag
```

| Signal | Breach condition | Action |
|---|---|---|
| Error rate | > 2 % over 5 min | Route around; open a health verdict |
| p95 latency | > 2× the 7-day baseline | Route around; record the provider class |
| Rate headroom | < 10 % of configured `rpm` | Template 8 backoff; shift load (`MDL_005`) |
| Disabled flag | Set with a reason | `MDL_003`; next fallback entry serves |

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not certify a Harness level on partial evidence — the constraint set is all-or-nothing
- ❌ Do not let WFT-010 install anything — phase 7 is "stop", and a human approves
