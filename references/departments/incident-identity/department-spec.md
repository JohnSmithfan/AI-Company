---
department: incident-identity
domain: security
parent: ai-company
roles: [Incident Commander, IAM Lead]
error_code_prefix: IRP_
function_blocks: 1
consolidates_group_tier: [incident-response, identity-access]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Incident & Identity — Deep Specification

> D3 depth for [../incident-identity.md](../incident-identity.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| `security-resilience` raised `CISO_004` | Declaration criteria are theirs; the lifecycle is ours — execution starts at `IRP_001` |
| An alert correlation looks like a security event but is undeclared | Triage against the declaration criteria before anything is remediated |
| A breach may trigger a regulatory clock | We assess the window and escalate the clock to `legal-privacy` (`IRP_003`) |
| A credential may be exposed | Revocation authority sits here (`IRP_004`) — minutes matter, not approvals |
| A new integration needs an identity pattern | Authentication and authorization design sits here; `security-resilience` gates it |
| An access review is overdue | Default-revoke authority sits here (`IRP_005`) |

**Not** this department: threat modelling and control evidence (`security-resilience`),
notification obligations and wording (`legal-privacy`), crisis declaration
(`executive-strategy`), model registry access (`model-data`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The table below is the source of truth;
an action outside it escalates, and the response names the rung that holds the authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Declare an incident and start `WFT-005` | This department | Reversible | — |
| Revoke a suspected credential | This department | Reversible with cost | — |
| Preserve evidence read-only; halt destructive remediation | This department | Reversible | — |
| Require mTLS on a new service boundary | This department | Reversible | — |
| Revoke unreviewed grants by default | This department | Reversible | — |
| Declare a crisis | `executive-strategy` | — | rung 3 |
| Public disclosure of a breach | `legal-privacy` + `board-and-branch` | Irreversible | rung 4 |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
board-and-branch
      ▲  breach disclosure, evidence destruction requests
      │
executive-strategy
      ▲  crisis declaration when severity crosses the threshold
      │
incident-identity  ◄──── declarations (CISO_004) ◄──── security-resilience
      │  ▲              alerts (WFT-003) ◄────────── operations-coordination
      │  └── notification clocks (IRP_003) ──► legal-privacy
      │  └── identity patterns ──► engineering-tooling, platform-mlops, model-data
      ▼  incident records, revocation records
  affected departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Incident lifecycle phases

| Phase | Action | Exit criterion |
|---|---|---|
| Declare | Criteria confirmed; commander assigned; evidence log opened | `IRP_001` record exists |
| Contain | Blast radius bounded; suspected credentials revoked (`IRP_004`) | Spread stopped |
| Eradicate | Root cause removed, not merely the symptom | Cause recorded |
| Recover | Service restored; identity posture re-verified | Recovery evidence attached |
| Review | Timeline, notification clocks, lessons — recorded | Review record closed |

The evidence log opens in **Declare**, before any remediation. A lifecycle that starts with
containment has already destroyed evidence.

Severity is classified at declaration and drives the containment plan and the notification
assessment — it is never revised upward silently after the fact.

| Severity | Signal | Containment clock | Notification assessment |
|---|---|---|---|
| SEV-1 | Credential compromise, data exposure, or loss of an identity control | Immediate | Mandatory at declaration (`IRP_003` assessed) |
| SEV-2 | Contained unauthorized access, control degradation | ≤ 1 h | Assessed; recorded either way |
| SEV-3 | Policy violation with no exposure path | ≤ 4 h | Recorded as not required, with the reason |

⚠️ A severity downgrade requires a recorded reason and the commander's name. Severity is the
input to the notification clock — quietly reclassifying an incident is how a window gets missed.

### 3.B Evidence preservation

| Rule | Requirement |
|---|---|
| Order | Preserve → analyse → remediate. Never remediate → discover → regret |
| Integrity | Hash on acquisition; re-hash on transfer |
| Custody | Every handoff recorded with time, from, to, purpose |
| Missing evidence | Record what is missing and why (`IRP_002`); remaining evidence read-only |
| Limitation | Stated in the final report — a silent gap is a false report |

### 3.C Identity control baseline

| Control | Requirement |
|---|---|
| Authentication | Every cross-boundary flow authenticates; no anonymous trust |
| Authorization | Least privilege; no ambient authority; grants have owners |
| Credentials | Referenced by environment-variable name only — never by value |
| Service identity | mTLS between components; certificates rotated before expiry |
| Review | Periodic access review; overdue → default-revoke (`IRP_005`) |

`security-resilience` gates every new design against its control set; this baseline is what we
assert inside that gate. Where the two disagree, the stricter requirement stands until
`security-resilience` records an accepted-risk exception with an expiry.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `IRP_001` | Incident declared | A security event met the declaration criteria | 1. Assign an incident commander 2. Start `WFT-005` 3. Open the evidence log before remediation |
| `IRP_002` | Forensic evidence incomplete | Evidence required for analysis was unavailable or altered | 1. Record what is missing and why 2. Preserve remaining evidence read-only 3. Note the limitation in the final report |
| `IRP_003` | Notification deadline at risk | A regulatory notification window will not be met | 1. Escalate to `legal-privacy` immediately 2. Prepare a provisional notification 3. Record the timeline |
| `IRP_004` | Credential compromise suspected | An indicator suggested a credential may be exposed | 1. Revoke the credential 2. Rotate downstream dependencies 3. Audit usage for the exposure window |
| `IRP_005` | Access review overdue | A periodic access review passed its due date | 1. Run the review immediately 2. Revoke unreviewed grants by default 3. Record the lapse |

⚠️ At `group` tier the identity findings move to `identity-access` under prefix `IAM_`.
Here they report under `IRP_`; `IAM_` is retired at this tier and revived on upgrade — see
[../../scaling.md](../../scaling.md) §3.

## 5. Integration Points

Detailed in the D2 page §5. Protocol notes:

| Counterpart | Protocol |
|---|---|
| `security-resilience` | `CISO_004` hands us the declaration; we take execution. Evidence is preserved before remediation because remediation destroys it |
| `legal-privacy` | `IRP_003` hands them the notification clock. We own the clock and the timeline; they own the obligation and the wording |
| `executive-strategy` | We report severity; they declare the **crisis**. Running an incident and declaring a crisis are distinct acts and may run concurrently |
| `engineering-tooling` | Production-operation grants and deployment identity follow our pattern; we supply mTLS and service-identity requirements |
| `model-data` | Model access control and API credential governance; registry access follows the least-privilege baseline (§3.C) |
| `operations-coordination` | `WFT-003` alerts arrive as declaration candidates; correlation and debounce happen before declaration, never after |

## 6. Constraints

- ❌ Do not remediate before the evidence log is open (`IRP_002`)
- ❌ Do not declare a crisis — that belongs to `executive-strategy`
- ❌ Do not let a notification window close without escalating `IRP_003` to `legal-privacy`
- ❌ Do not record a credential by its value — the environment-variable name only
- ❌ Do not restore a default-revoked grant without a recorded owner attestation
- ❌ Do not close an incident on containment — closure requires recovery evidence and the review record
- ❌ Do not destroy evidence to restore service faster
- ❌ Do not approve a tier upgrade — no department may

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Commander assignment latency | Commander timestamp minus declaration timestamp |
| Evidence-log-before-remediation | Incidents where the log predates the first remediation ÷ total incidents |
| Notification windows met | Windows met ÷ windows assessed — an unassessed window is a miss |
| Credential revocation latency | Revocation timestamp minus indicator timestamp |
| Exposure-window audit completion | Audits completed within 24 h ÷ audits opened |
| Access review cadence attainment | Reviews completed on cadence ÷ reviews due |
| Default-revoke enforcement | Unreviewed grants revoked ÷ unreviewed grants found |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-IRP-01 · Declare and run an incident

```text
1. Confirm the declaration criteria (security-resilience owns the criteria; we own the call).
2. Raise IRP_001: assign a commander, start WFT-005.
3. Open the evidence log BEFORE any remediation (3.B).
4. Assess severity; if the crisis threshold is crossed, notify executive-strategy -
   they declare the crisis, we keep running the incident.
5. Contain: bound the blast radius; revoke suspected credentials (SOP-IRP-04).
6. Eradicate: remove the root cause, not the symptom.
7. Recover: restore service; re-verify the identity posture (3.C).
8. Review: record timeline, clocks, lessons. Close on the review record.
```

### SOP-IRP-02 · Preserve forensic evidence

```text
1. On IRP_001, open the evidence log before touching anything.
2. Hash on acquisition; re-hash on every transfer.
3. Record custody for every handoff: time, from, to, purpose.
4. Evidence unavailable or altered → IRP_002:
   record what is missing and why; preserve the rest read-only.
5. State the limitation in the final report - a silent gap is a false report.
6. Remediation that would alter evidence waits for the analysis, or proceeds only
   with the alteration recorded in advance.
```

### SOP-IRP-03 · Run the regulatory notification clock

```text
1. At declaration, list affected data classes and jurisdictions.
2. For each jurisdiction, compute the window from the clock start.
3. Window at risk → IRP_003: escalate to legal-privacy immediately.
4. Prepare a provisional notification while the timeline is recorded.
5. legal-privacy owns the obligation and the wording; we own the clock and the timeline.
6. Never perform the clock assessment inside the incident run itself - it is a
   separate record with its own trace ID (template 7, prefix "irp").
```

### SOP-IRP-04 · Revoke and rotate a compromised credential

```text
1. Indicator suggests exposure → IRP_004.
2. Revoke the credential immediately (<= 15 min) - do not wait for confirmation.
3. Rotate downstream dependencies that held the same secret.
4. Audit usage across the exposure window (<= 24 h).
5. Reference the credential by environment-variable name only - never by value.
6. Record the revocation with its trace ID; feed the audit result to the incident record.
```

### SOP-IRP-05 · Run an access review

```text
1. Review due → pull the grant inventory with owners.
2. Overdue → IRP_005: run immediately; record the lapse.
3. Unreviewed grants are revoked BY DEFAULT - an unreviewed grant is an unowned grant.
4. Restoration requires a recorded owner attestation, not a request.
5. Check least privilege on every confirmed grant (3.C): no ambient authority.
6. Record confirmed, tightened and revoked grants; reset the cadence timer.
```
