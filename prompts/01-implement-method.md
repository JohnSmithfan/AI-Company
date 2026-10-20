---
mode: human-paste
id: 01-implement-method
title: Implement Method
output_language: user-specified
harness_level: L3
---

> **Mode**: human-paste (paste into any AI chat window)
> **Purpose**: Copy this prompt into any AI chat window and have that AI implement or extend one department page of the AI Company skill to the standard below.
> **This file is not invoked automatically by an agent.**
>
> **Fill in before use**:
> - `<DEPARTMENT_NAME>` - display name of the department to implement
> - `<DOMAIN>` - the domain the department belongs to
> - `<CONSTRAINTS>` - project-specific constraints or known risks
>
> **Output language**: follow the language you are currently using in this conversation.

## Prompt

(The block below is copied as a whole)

```text
You are implementing a department page for the AI Company skill, an enterprise
governance specification that models AI agents as company staff.

The skill is at scale tier "large": 18 departments across 7 domains, 18
function blocks, 117 error codes over 19 prefixes, 148 files total. Do not
assume any other department count.

Your task: implement the department <DEPARTMENT_NAME> in the domain <DOMAIN>,
honoring the project-specific constraints: <CONSTRAINTS>

## Canonical template contracts

Wherever your implementation touches input or output handling, it must honor
these ten canonical signatures. Adapt names only if the project already uses
different ones, and say so explicitly:

1. validate_input_schema(data, schema) - validate input against a schema before
   any processing; no external I/O.
2. sanitize_user_query(query) - neutralize prompt injection and shell
   metacharacters; no dynamic code execution.
3. execute_safe_command(cmd, timeout=30) - run a command in a sandbox with a
   hard timeout and a restricted working directory.
4. format_output_json(content, provider) - produce standard JSON output with
   AI-content identification.
5. retry_with_backoff(func, max_retries=3) - retry a transiently failing call
   with exponential backoff.
6. read_reference_file(filepath) - read a file only after path validation;
   reject paths outside allowed roots.
7. generate_trace_id(prefix="trace") - produce a stateless unique audit-trace
   identifier.
8. check_rate_limit(identifier, limit=10, window=60) - in-memory rate limiting
   only; never persist counters to disk.
9. mask_sensitive_data(text) - mask email addresses, IP addresses, and phone
   numbers.
10. build_prompt_from_template(template, **kwargs) - build a prompt from a
    template; sanitize all inputs first.

## Mandatory data-handling rules

- PII masking: every output path must replace email addresses with [EMAIL],
  IPv4 addresses with [IP], and phone numbers in their common written forms
  (international country code and separators included) with [PHONE]. All three
  placeholder kinds are mandatory; omitting any one of them is a defect.
- AI-generated content identification: every artifact you produce must carry
  all three layers - (1) a visible label such as "AI-Generated Content",
  (2) structured metadata with "ai_generated": true, "generated_at":
  "<ISO8601 timestamp>", and "model": "<provider/model>", and (3) a
  tamper-evident disclosure marker embedded in the content body that is
  derived from the content, so editing the body invalidates it.

## Department page structure

The department page follows one fixed skeleton - no variants:

    # <DEPARTMENT_NAME>
    > Domain: <DOMAIN>. Function blocks: 1. Harness baseline: L3.

    ## 1. Trigger Scenarios      5-10 concrete task descriptions, natural language
    ## 2. Core Identity          role, permission boundary, reporting line, domain

Each function block then repeats sections 3-7 under its own top-level heading.
Headings must be mechanically countable: an uppercase block code, a hyphen,
the block ordinal (from 1, no gaps), a colon and the role.

    ### 3. Core Responsibilities  each entry = description + input + output + SLA
    ### 4. Error Codes            each code = message + trigger condition + resolution steps
    ### 5. Integration Points     which departments, via which mechanism
    ### 6. Constraints            forbidden actions, as a list
    ### 7. Quality Metrics        quantified indicators, each with a numeric threshold

    ## Prompts
    - links to this department's own prompt files

Structural rules:

- Section numbering starts at 1 and never skips.
- Every responsibility entry carries all four elements: description, input,
  output and SLA. An entry missing any element is a defect.
- Every error code carries all three elements: message, trigger condition and
  resolution steps.
- Every quality metric carries a numeric threshold; a metric without a
  threshold is not a metric.
- At this scale every department carries exactly one function block, and the
  total across all 18 departments must equal 18.
- The department's depth document is not a manifest: it carries no name, slug,
  trigger or interface fields, and it must not reuse the root manifest's file
  name.
- Never inline a shared template implementation into a department page -
  reference the canonical signatures above instead, so the code exists in one
  place only.
- Never hardcode a machine-specific absolute path.
- Never write a credential value; configuration holds environment variable
  names only.

## Requirements

- Author the department page in English: every source file in this skill is
  written in English. This rule governs the artifact, not your reply - see the
  output contract.
- Harness level L3 or above for every capability (L3 = error handling, retry,
  idempotency). Do not declare a level the content does not evidence.
- No eval, no exec, no remote loading, no dynamic code execution.
- If asked to add a department rather than implement one: adding a department
  is a scale change that goes through the proposal flow, not through direct
  editing. Say so and stop; do not invent a nineteenth department.

## Output contract

Respond in the language I am currently using in this conversation, and return:
1. The complete department page in one code block, plus the depth document if
   one was requested.
2. The function-block count for the department and the package-wide total.
3. A compliance note confirming the three PII placeholders, the three
   AI-content identification layers and the four-element responsibility
   entries, or explaining any deviation.
4. Any specification ambiguity you had to resolve, stated explicitly.
```

## Expected Output

The AI should return: (1) the full department page for `<DEPARTMENT_NAME>` following the fixed skeleton, plus the depth document if one was requested; (2) the function-block count for the department and the package-wide total; (3) a compliance note covering the three PII masking placeholders, the three AI-content identification layers and the four-element responsibility entries, or documented deviations; (4) any specification ambiguity resolved, stated explicitly. Code blocks are expected; prose around them should be brief.

## Self-Check Checklist

After receiving the reply, verify each item:

- [ ] The reply is written in the same language as this conversation.
- [ ] The page follows the fixed skeleton: sections 1-2, then 3-7 repeated under each function block, then the prompts section; numbering starts at 1 and never skips.
- [ ] Every responsibility entry carries all four elements: description, input, output and SLA.
- [ ] Every error code carries all three elements: message, trigger condition and resolution steps.
- [ ] Every quality metric carries a numeric threshold.
- [ ] PII masking covers all three kinds: [EMAIL], [IP], and [PHONE].
- [ ] AI-generated artifacts carry all three identification layers (visible label, structured metadata, embedded disclosure marker).
- [ ] No shared template implementation is inlined into the page; the canonical signatures are referenced instead.
- [ ] No machine-specific absolute path and no credential value appears anywhere.
- [ ] The Harness level claimed is L3 or above and is evidenced by the content.
- [ ] If a new department was requested instead of an implementation, the reply routed it to the proposal flow rather than inventing content.
