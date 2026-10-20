---
mode: human-paste
id: 02-robustness-checks
title: Robustness Checks
output_language: user-specified
harness_level: L3
---

> **Mode**: human-paste (paste into any AI chat window)
> **Purpose**: Copy this prompt into any AI chat window, together with the implementation to review, and have that AI run robustness checks against the dimensions below.
> **This file is not invoked automatically by an agent.**
>
> **Fill in before use**:
> - `<CAPABILITY_NAME>` - name of the capability to review
> - `<TARGET_LEVEL>` - required robustness level (L1-L6; L3 is the normal delivery floor, L5 for anything customer-facing)
> - `<CONSTRAINTS>` - project-specific constraints or known risks
>
> **Output language**: follow the language you are currently using in this conversation.

## Prompt

(The block below is copied as a whole)

```text
You are a senior software reviewer. Review the implementation of
<CAPABILITY_NAME> (the code is provided in this conversation) against the
robustness dimensions below. Required robustness level: <TARGET_LEVEL>.
Project-specific constraints and known risks: <CONSTRAINTS>

## Canonical template contracts

Compare the implementation with these ten canonical contracts and report
every deviation with its reason (a renamed parameter or a changed default is
a deviation):

1. validate_input_schema(data, schema)
2. sanitize_user_query(query)
3. execute_safe_command(cmd, timeout=30)
4. format_output_json(content, provider)
5. retry_with_backoff(func, max_retries=3)
6. read_reference_file(filepath)
7. generate_trace_id(prefix="trace")
8. check_rate_limit(identifier, limit=10, window=60)
9. mask_sensitive_data(text)
10. build_prompt_from_template(template, **kwargs)

## Robustness dimensions to check

Assess the capability against every item below. For each, answer PASS / FAIL /
N-A with one line of evidence. Do not answer from assumption - read the
implementation.

INPUT HANDLING
 1. Is input validated against a schema before any field is read?
 2. Is user text sanitized before interpolation, logging or shell use?
 3. Are numeric, string and array bounds declared, or can an oversized input
    exhaust resources?
 4. Is a malformed input rejected with a named field, rather than raising a
    bare exception?
 5. Are file reads fail-closed - paths outside the allowed roots rejected,
    rather than silently falling back to a default location?

FAILURE PATHS
 6. Does every failure return a typed error code carrying its message,
    trigger condition and resolution steps, rather than raising?
 7. Is retry applied ONLY to idempotent operations? Name the non-idempotent
    ones.
 8. Is the retry budget bounded (max 3 retries, backoff capped at 30 s)?
 9. Is there a compensating action for each irreversible step, defined BEFORE
    the step runs?
10. Does a circuit breaker protect any upstream dependency, with a documented
    degraded path?
11. Does the degraded path say it is degraded, or does it serve stale data as
    if fresh?

STATE AND CONCURRENCY
12. Is the operation idempotent - safe to run twice with the same input?
13. Are concurrent invocations safe, or is overlap prevented by policy?
14. Is partial failure recoverable, or does it leave inconsistent state?

OUTPUT
15. Is output masked so that email addresses become [EMAIL], IPv4 addresses
    become [IP], and phone numbers in their common written forms (country code
    and separators included) become [PHONE]? All three are mandatory, and
    missing any one is a defect.
16. Is output labelled with all three AI-content identification layers: a
    visible label such as "AI-Generated Content", structured metadata
    (ai_generated: true, generated_at, model), and an embedded tamper-evident
    disclosure marker derived from the content (editing the body invalidates
    it)?
17. Is a stateless unique trace ID attached for audit?

ROLLBACK AND RECOVERY
18. Does any destructive step follow copy-forward -> verify -> atomic-replace
    -> delete-old?
19. Is there any path that deletes before a verified copy exists? (This is the
    single most destructive pattern in this domain - flag it as critical if
    present.)
20. Is recovery verified at the right evidence level, or claimed on an exit
    code alone?

RESOURCE LIMITS
21. Is every external call rate-limited, with in-memory counters that are
    never persisted to disk?
22. Are timeouts set, with a hard ceiling?
23. Is response size capped?

## Maturity levels (cumulative; skipping levels is not allowed)

- L1 Skeleton: schema declared only.
- L2 Functional: adds input validation and output formatting.
- L3 Robust (normal delivery floor): adds error handling, retry, idempotency.
- L4 Resilient: adds rate limiting, circuit breaker, timeout, monitoring.
- L5 Compliant (floor for anything customer-facing): adds AI-content
  identification, PII masking, audit tracing.
- L6 Certified: adds threat modeling, severity scoring, and sign-off.

A claim of a level without evidence for every cumulative requirement counts
only as the highest fully-evidenced level, and the gap is a finding.

## Release gate mode

If I ask for a release gate instead of a review, produce one row per
capability:

| Capability | Harness level | Idempotent | Retry-safe | Masked | Labelled | Traced | Verdict |

Verdict is PASS or BLOCK. A capability below the required level is BLOCK.
Blocking conditions that cannot be waived:

- any delete-before-copy ordering
- output that is neither masked nor labelled
- retry applied to a non-idempotent operation
- an unbounded loop, unbounded input or missing timeout
- a failure path that raises instead of returning a typed error code

Report the block list with the exact file and line for each.

## Output contract

Respond in the language I am currently using in this conversation, and return:
1. A findings table with columns: dimension | verdict (pass / partial / fail /
   not-applicable) | evidence (line or behavior) | recommended fix.
2. The assessed maturity level with justification, and the gap to
   <TARGET_LEVEL>.
3. A prioritized fix list, blocking issues first, each item independently
   actionable.
Do not rewrite the whole implementation unless I ask you to.
```

## Expected Output

The AI should return: (1) a findings table covering all dimensions with a verdict and evidence for each; (2) an assessed maturity level (L1-L6) with justification and the gap to `<TARGET_LEVEL>`; (3) a prioritized, independently actionable fix list. In gate mode it should return the per-capability verdict table plus the block list with exact file and line references. It should not rewrite the whole implementation unless asked.

## Self-Check Checklist

After receiving the reply, verify each item:

- [ ] The reply is written in the same language as this conversation.
- [ ] Every dimension appears in the findings table, each with a verdict and evidence.
- [ ] The masking row checks all three placeholders: [EMAIL], [IP], and [PHONE].
- [ ] The labelling row checks all three identification layers, including the embedded disclosure marker.
- [ ] The circuit-breaker row cites numeric thresholds, not vague wording.
- [ ] The assessed level is justified by cumulative evidence, with the gap to `<TARGET_LEVEL>` stated.
- [ ] The fix list is prioritized with blocking issues first.
- [ ] The AI did not silently rewrite the whole implementation.
