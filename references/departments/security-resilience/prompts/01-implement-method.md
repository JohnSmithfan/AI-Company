# Implementation Prompt — Security & Resilience

> Department-specific implementation prompt. Read the shared prompt at
> [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the security-resilience department (domain: security) of the AI Company
skill at tier "large".

Read in order:
  references/departments/security-resilience.md                  this department's D2 page
  references/departments/security-resilience/department-spec.md  D3 depth + SOPs
  references/departments/security-resilience/references/method-patterns.md
  references/error-codes.md                                      CISO_001 through CISO_006
  references/method-patterns.md                                  only when you need an implementation

This department consolidates two group-tier atomic departments: security-operations (CISO_) and
resilience-continuity (RSC_). At large tier both report under the single prefix CISO_; RSC_ is
retired here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Threat modelling (STRIDE)        -> CISO_003 on an unmitigated threat
  3.2 Vulnerability scoring (CVSS)     -> CISO_002 on CVSS >= 9.0
  3.3 Security gate operation          -> CISO_001 on a failed control
  3.4 Business continuity / recovery   -> CISO_005 on an RTO/RPO breach
  3.5 Control evidence management      -> CISO_006 on expired evidence
  3.6 Circuit-breaker threshold ownership

Hard rules specific to this department:
  - This department holds a ONE-DIRECTIONAL blocking right. It may halt a deployment; it may NEVER
    resume one it halted - that requires engineering-tooling plus a recorded root cause.
  - A CVSS score is recorded with its FULL vector string, never a bare number.
  - A security gate has exactly two outcomes: remediate, or record an accepted-risk exception WITH
    an expiry date. An exception without an expiry is refused. Gates are never waived silently.
  - A threat is closed by RE-RUNNING the model, not by asserting a control was added.
  - A recovery test that is scheduled but not run is a coverage GAP, reported as such - never a pass.
  - An unproven control (expired evidence) may not be cited as mitigation.

Report: files created, the CISO_ codes you wired, and any control whose evidence source you could
not determine.
```
