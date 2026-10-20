# Implementation Prompt — Engineering & Tooling

> Department-specific implementation prompt. Read the shared prompt at
> [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the engineering-tooling department (domain: technology) of the AI Company
skill at tier "large".

Read in order:
  references/departments/engineering-tooling.md                  this department's D2 page
  references/departments/engineering-tooling/department-spec.md  D3 depth + SOPs
  references/departments/engineering-tooling/references/method-patterns.md
  references/error-codes.md                                      CTO_001 through CTO_008
  references/method-patterns.md                                  only when you need an implementation

This department consolidates two group-tier atomic departments: engineering-architecture (CTO_)
and developer-tooling (DXT_). At large tier both report under the single prefix CTO_; DXT_ is
retired here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Architecture integrity        -> CTO_001 on a constraint violation
  3.2 Agent creation                -> CTO_002 on scaffold failure, FW_006 on over-declaration
  3.3 Three-stage deployment gate   -> CTO_008 on a stage failure, CTO_006 on unhealthy state
  3.4 Production operation control  -> CTO_004 without a grant
  3.5 Pipeline health               -> CTO_005 / CTO_003
  3.6 Internal tooling and templates-> CTO_007 on unavailability

Hard rules specific to this department:
  - CTO_ numbering is continuous 001-008 with NO gaps. A predecessor jumped 006->009 and nobody
    could later tell if the missing numbers were deprecated or forgotten.
  - The three-stage gate may only halt or promote. Never skip forward; a failed stage rolls back
    and re-enters after remediation.
  - Rollback ordering is copy-forward -> verify -> atomic-replace -> delete-old. NEVER invert it.
  - This department does NOT resume a deployment that security-resilience halted.
  - Command execution uses template 3 with a LIST of arguments, never a shell string.
  - Do not claim "deployed and working" on a command exit code alone - the full stage requires
    outcome-level verification of the user-visible path.

Report: files created, the CTO_ codes you wired, and any stage criterion you could not determine.
```
