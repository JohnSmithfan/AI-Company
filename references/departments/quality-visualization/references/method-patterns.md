# Department Method Patterns — Quality & Visualization

> Department-specific patterns only. The **10 shared templates are NOT here** — they live in
> [../../../method-patterns.md](../../../method-patterns.md), the single authoritative source. This file
> links to them and adds only what is specific to quality gating and information services.

## Shared templates this department uses

Linked, never copied:

| Template | Use in this department | Source |
|---|---|---|
| 4 `format_output_json` | Label every chart, diagram and report (AIGC triple label) | [method-patterns.md §3.4](../../../method-patterns.md) |
| 7 `generate_trace_id` | Prefix `cqo` on gate records, coverage readings and reports | [method-patterns.md §3.7](../../../method-patterns.md) |
| 9 `mask_sensitive_data` | Mask PII before any label, tooltip or axis value is rendered | [method-patterns.md §3.9](../../../method-patterns.md) |
| 1 `validate_input_schema` | Validate a gate submission carries its required fields | [method-patterns.md §3.1](../../../method-patterns.md) |
| 5 `retry_with_backoff` | Retry only after idempotency is verified | [method-patterns.md §3.5](../../../method-patterns.md) |

## Department-specific pattern: quality gate

```text
quality_gate(change, evidence) -> pass | block(CQO_001)
```

| Element | Rule |
|---|---|
| `evidence` | Every criterion carries its measured value — a bare pass/fail is not evidence |
| Outcome | Exactly two: remediate and re-enter, or escalate the block |
| Re-entry | Closed by a re-run, never by an assertion |
| Trace | Gate record carries a template 7 trace ID with prefix `cqo` |

⚠️ This is a **composition** of shared templates, not a new implementation. It must not redefine
masking or labelling — it calls them.

## Department-specific pattern: coverage reading

```text
coverage_reading(test_run, changed_paths) -> reading | block(CQO_003)
```

| Element | Rule |
|---|---|
| Scope | Changed paths first; repo-wide only as context |
| Threshold | 85 % acceptance; raising it is this department's, lowering it is escalated |
| Ordering | Uncovered paths listed highest-risk-first |
| Trace | The reading carries the test-run trace ID so it can be re-derived |

⚠️ A coverage number without its test-run trace ID cannot be re-derived or challenged — it is a
claim, not a measurement.

## Department-specific pattern: multi-source fusion

Fusion follows [../../../data-integration.md](../../../data-integration.md) §3; this department applies
that contract to location, weather and time readings:

```text
fuse(readings) -> value + confidence
  within ±2 %   -> higher-reliability source, delta recorded
  beyond ±2 %   -> keep both, mark contested, report the spread
```

| Situation | Resolution |
|---|---|
| Numeric within ±2 % | Higher-reliability source; record the delta |
| Numeric beyond tolerance | Keep both; mark the field contested |
| Categorical differs | Keep both with source attribution |
| No reliability rating | Exclude from fusion; lead only (`INTEL_003`) |

⚠️ Confidence weighting: Σ(source reliability × agreement) ÷ Σ(reliability). A fused value below
40 % confidence publishes the score, never omits it (`INTEL_002`).

## Constraints

- ❌ Do not reimplement masking, labelling or trace-ID generation here — call the shared templates
- ❌ Do not inline shared template code into this file
- ❌ Do not close a gate on an assertion — a gate is closed by a re-run
- ❌ Do not render a gap as zero, or resolve a contested field silently
