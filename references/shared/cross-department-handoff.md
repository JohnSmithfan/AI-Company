# Cross-Department Handoff

> Shared handoff guidance (medium tier). See also references/scaling.md.

## Handoff SLA

- A dependency handoff must meet its SLA within 10% or escalate to CFO (FB-3).
- Risk-gating blocks Technology and Platform deployments via the risk gate.
- External content is routed through Legal and Risk (FB-2) before release.
- Procurement reconciles invoices with Finance (FB-3) via the shared ledger.
- Intelligence (FB-1) delivers SITREPs to Governance and Operations (FB-1, FB-2).

## Routing rule

- "department: auto" selects the target from the frontmatter interface enum.
- A misroute is a routing-accuracy miss and is recorded in the scaling state file.