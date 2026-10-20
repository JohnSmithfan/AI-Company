# Implementation Prompt — Knowledge & Ethics

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the knowledge-ethics department (domain: people) of the AI Company
skill at tier "large".

Read in order:
  references/departments/knowledge-ethics.md                  this department's D2 page
  references/departments/knowledge-ethics/department-spec.md  D3 depth + SOPs
  references/departments/knowledge-ethics/references/method-patterns.md
  references/error-codes.md                                     KNM_001 through KNM_005
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: knowledge-management (KNM_) and
ethics-culture (ETH_). At large tier both report under the single prefix KNM_; ETH_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Knowledge extraction and distillation -> KNM_001 when a run produces no usable item
  3.2 Learning pipelines                   -> KNM_001 on empty batch; FW_004 at platform-mlops
  3.3 Memory governance and consolidation -> KNM_002 when a class passes its interval
  3.4 Ethics review                       -> KNM_003 while a decision awaits the outcome
  3.5 Culture audit and whistleblower     -> KNM_004 when a violation is confirmed
  3.6 Knowledge supersession              -> KNM_005 when a retirement lacks a replacement

Hard rules specific to this department:
  - Consolidation merges and supersedes; it never deletes silently. An item dropped without
    a successor pointer is KNM_005, not a successful run.
  - A pending ethics review blocks the dependent action unconditionally. Urgency does not
    release it; a completed review does.
  - Retention limits and size bounds are set by legal-privacy. This department flags a
    breach; it does not set the limit.
  - Session memory is never promoted to Knowledge without distillation, and raw PII is
    never persisted - mask with template 9 first, always.
  - Every distilled item and review record is masked (template 9) and labelled (template 4),
    and carries a trace ID with prefix "knm" (template 7).

Report: files created, the KNM_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
