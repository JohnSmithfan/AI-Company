# Implementation Prompt — Incident & Identity

> Department-specific implementation prompt. Copy into an AI chat to build or extend this
> department. Read the shared prompt at [../../../../prompts/01-implement-method.md](../../../../prompts/01-implement-method.md) first.

```text
You are implementing the incident-identity department (domain: security) of the AI Company
skill at tier "large".

Read in order:
  references/departments/incident-identity.md                  this department's D2 page
  references/departments/incident-identity/department-spec.md  D3 depth + SOPs
  references/departments/incident-identity/references/method-patterns.md
  references/error-codes.md                                     IRP_001 through IRP_005
  references/method-patterns.md                                 only when you need an implementation

This department consolidates two group-tier atomic departments: incident-response (IRP_) and
identity-access (IAM_). At large tier both report under the single prefix IRP_; IAM_ is retired
here and revived on upgrade to group.

Implement these six responsibilities, each with description + input + output + SLA:
  3.1 Incident lifecycle management     -> IRP_001 on declaration
  3.2 Forensics and evidence            -> IRP_002 on missing or altered evidence
  3.3 Regulatory notification           -> IRP_003 when a window is at risk
  3.4 Authentication and authorization  -> least privilege; no ambient authority
  3.5 Credential management             -> IRP_004 on suspected compromise
  3.6 Access review and least privilege -> IRP_005 when a review is overdue

Hard rules specific to this department:
  - The evidence log opens BEFORE any remediation. Remediation that alters evidence is a
    second incident, not a fix.
  - This department RUNS the incident; executive-strategy DECLARES the crisis. Never declare
    a crisis here.
  - The notification clock is escalated to legal-privacy (IRP_003) - we own the clock and the
    timeline, they own the obligation and the wording. The clock assessment is never performed
    inside the incident run.
  - Credentials are referenced by environment-variable name only, never by value.
  - Every incident, revocation and review record is masked (template 9) and labelled
    (template 4), and carries a trace ID with prefix "irp" (template 7).

Report: files created, the IRP_ codes you wired, and any responsibility whose SLA you could not
determine from the spec.
```
