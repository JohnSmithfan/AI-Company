# Robustness Checks Prompt — Model & Data

> Department-specific robustness review. Read the shared prompt at
> [../../../../prompts/02-robustness-checks.md](../../../../prompts/02-robustness-checks.md) first.

```text
You are reviewing the model-data department (domain: technology) for robustness.

Read references/departments/model-data/department-spec.md, then check each item below.
Answer PASS / FAIL / N-A with one line of evidence per item. Read the implementation - do not assume.

REGISTRY
 1. Is an unknown model id refused with MDL_001, never served from an unregistered endpoint?
 2. Is every config_path resolved by the registry path check before any invocation (MDL_002)?
 3. Is a config contract breach caught at registration with MDL_006, not at first call?

CALLING POLICY
 4. Is the fallback-chain order fixed: registered -> config -> enabled -> key -> headroom -> invoke?
 5. Is a disabled model routed around (MDL_003) and re-enabled only through platform-mlops?
 6. Does MDL_004 halt the invocation and report the variable NAME only, never the value?
 7. Is a transport or provider error raised under the MDL_E sub-namespace (MDL_E007), retried
    via template 5 before the fallback takes over?

DATA PIPELINES
 8. Do all five WFT-001 phases run in order, with template 8 limiting extraction?
 9. Are quarantined records reported, never dropped silently?
10. Is PII masked (template 9) at the persistence phase, before storage?
11. Does a breaking schema change wait for downstream consumer acknowledgement?

GOVERNANCE AND FUSION
12. Is a grant outside the access matrix refused and routed to security-resilience?
13. Does every fused record keep its per-source provenance?
14. Where sources disagree, are both values recorded rather than picking the first?

OUTPUT
15. Is every invocation and pipeline stage traced (template 7, prefix "mdl")?
16. Is a source that fails twice marked degraded and reported, not retried forever?

Report each FAIL with file and line and a concrete fix. State anything you could not verify as
unverified rather than assumed passing.
```
