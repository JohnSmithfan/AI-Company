# Incident & Identity

> D2 index page. Domain: `security`. Depth: [incident-identity/](incident-identity/).
> Function blocks: 1 · Error-code prefix: `IRP_` (5 codes)
> Department Harness Baseline: L3.
> Consolidates the `group`-tier atomic departments `incident-response` (IRP_) and
> `identity-access` (IAM_).

## 1. Trigger Scenarios

- A security event meets the declaration criteria and an incident must be opened
- Preserve forensic evidence before remediation destroys it
- Assess whether a regulatory notification window is at risk
- Revoke and rotate a credential suspected of compromise
- Design or review authentication and authorization for a new integration
- Establish mTLS or service identity between components
- Run or chase an overdue periodic access review
- Confirm least privilege on a grant before it takes effect

## 2. Core Identity

**Role.** Incident Commander and IAM Lead, combined at this tier. Owns the incident lifecycle
from declaration to closure, and owns who and what may authenticate, authorize and hold a
credential.

**Permission boundary.**

| May do alone | Must escalate |
|---|---|
| Declare an incident and open `WFT-005` | Declaring a crisis → `executive-strategy` |
| Revoke a suspected credential immediately | Public disclosure of a breach → `legal-privacy` + `board-and-branch` |
| Preserve evidence read-only; halt destructive remediation | Destroying evidence to restore service → `board-and-branch` |
| Require mTLS on a new service boundary | Granting an exception to the requirement → `board-and-branch` |
| Revoke unreviewed access grants by default | Restoring a grant revoked for a least-privilege breach → `board-and-branch` |

**Reporting line.** Reports to `executive-strategy`. Receives incident declarations from
`security-resilience` (`CISO_004`); feeds notification obligations to `legal-privacy`
(`IRP_003`).

**Domain.** `security`. Sibling departments: `security-resilience`, `legal-privacy`.

## FB-1: Incident Commander / IAM Lead

### 3. Core Responsibilities

#### 3.1 Incident lifecycle management

| Element | Specification |
|---|---|
| Description | Run the incident lifecycle: declare, contain, eradicate, recover, close |
| Input | Declaration criteria met (`CISO_004`), alert correlation, severity signal |
| Output | Incident record with commander, timeline, actions, closure evidence |
| SLA | Commander assigned ≤ 15 min · containment per severity plan |

A security event meeting the declaration criteria raises `IRP_001`; a commander is assigned and
`WFT-005` starts. This department runs the **incident** — `executive-strategy` declares the
**crisis** when severity crosses the threshold, and the two may run concurrently.

#### 3.2 Forensics and evidence preservation

| Element | Specification |
|---|---|
| Description | Preserve evidence before any remediation that could alter it |
| Input | Affected systems, logs, memory and disk images, chain-of-custody form |
| Output | Evidence log with hashes, custody records and analysis notes |
| SLA | Evidence log opened before the first remediation action |

Evidence unavailable or altered raises `IRP_002`: what is missing and why is recorded, remaining
evidence is preserved read-only, and the limitation is stated in the final report. Remediation
that destroys evidence is not remediation — it is a second incident.

#### 3.3 Regulatory notification

| Element | Specification |
|---|---|
| Description | Keep regulatory notification windows visible and met |
| Input | Incident record, affected data classes, jurisdiction set, clock start |
| Output | Notification timeline with owners, provisional notice where required |
| SLA | Clock assessed at declaration · provisional notice before the window closes |

A notification window that will not be met raises `IRP_003` and escalates to `legal-privacy`
immediately; a provisional notification is prepared while the timeline is recorded. This
department owns the clock; `legal-privacy` owns the obligation and the wording.

#### 3.4 Authentication and authorization design

| Element | Specification |
|---|---|
| Description | Set the authentication and authorization pattern for every boundary |
| Input | Integration description, actors, trust boundaries, data classification |
| Output | Identity design: mechanism, grant model, boundary enforcement points |
| SLA | Design review within 3 business days of request |

Every cross-boundary flow authenticates, and authorization is least-privilege with no ambient
authority. `security-resilience` gates the design; this department owns the identity pattern
inside it. A boundary without an enforcement point is a finding, not a design.

#### 3.5 Credential management

| Element | Specification |
|---|---|
| Description | Issue, rotate, revoke and audit credentials and service identities |
| Input | Credential inventory, exposure indicators, rotation policy |
| Output | Revocation and rotation record; exposure-window audit result |
| SLA | Suspected compromise: revoke ≤ 15 min · audit ≤ 24 h |

An indicator suggesting exposure raises `IRP_004`: the credential is revoked, downstream
dependencies are rotated, and usage across the exposure window is audited. Credentials are
referenced by environment-variable name only — never by value (see `MDL_004`).

#### 3.6 Access review and least privilege

| Element | Specification |
|---|---|
| Description | Run periodic access reviews; keep grants at least privilege |
| Input | Grant inventory, review cadence, owner attestations |
| Output | Review record with confirmed, tightened and revoked grants |
| SLA | Review on cadence · overdue reviews run immediately |

A review past its due date raises `IRP_005`: the review runs immediately, unreviewed grants are
revoked by default, and the lapse is recorded. Default-revoke is deliberate — an unreviewed
grant is an unowned grant.

### 4. Error Codes

Prefix `IRP_`, 5 codes, numbered continuously. Full detail:
[../error-codes.md](../error-codes.md)

| Code | Message | Raised when |
|---|---|---|
| `IRP_001` | Incident declared | A security event met the declaration criteria |
| `IRP_002` | Forensic evidence incomplete | Evidence required for analysis was unavailable or altered |
| `IRP_003` | Notification deadline at risk | A regulatory notification window will not be met |
| `IRP_004` | Credential compromise suspected | An indicator suggested a credential may be exposed |
| `IRP_005` | Access review overdue | A periodic access review passed its due date |

⚠️ Identity findings that at `group` tier belong to `identity-access` (`IAM_`) are reported
under `IRP_` at this tier. The `IAM_` prefix is retired here and revived on upgrade — see
[../scaling.md](../scaling.md) §3.

### 5. Integration Points

| Counterpart | Mechanism | Direction |
|---|---|---|
| `security-resilience` | Incident declaration intake (`CISO_004` → `IRP_001`); credential compromise signals | Inbound |
| `legal-privacy` | Regulatory notification obligations (`IRP_003`); breach disclosure timeline | Outbound |
| `executive-strategy` | Crisis declaration when severity crosses the threshold; this department runs the incident, not the crisis | Outbound |
| `model-data` | Model access control; API credential governance | Both |
| `engineering-tooling` | mTLS and service identity for deployments; grants for production operations | Both |
| `platform-mlops` | Harness-level identity requirements; CI/CD federation | Both |
| `operations-coordination` | Alert intake (`WFT-003`) as declaration candidates | Inbound |

Mechanism detail: HQ Message Bus for events, direct call for synchronous decisions. See
[../integrations.md](../integrations.md).

### 6. Constraints

- ❌ Do not remediate before the evidence log is open — remediation that alters evidence raises `IRP_002`
- ❌ Do not run the crisis protocol — declare it to `executive-strategy` and run the incident
- ❌ Do not let a notification window close silently — raise `IRP_003` and escalate to `legal-privacy`
- ❌ Do not record a credential by its value — reference the environment-variable name only
- ❌ Do not restore a grant revoked by default-revoke without a recorded owner attestation
- ❌ Do not treat an unauthenticated boundary as acceptable "temporarily"
- ❌ Do not close an incident on containment — closure requires the recovery evidence and the review record
- ❌ Do not destroy evidence to restore service faster — restoring service is not a licence to alter the record

### 7. Quality Metrics

| Metric | Threshold |
|---|---|
| Incidents with a commander assigned ≤ 15 min | ≥ 95 % |
| Evidence logs opened before first remediation | 100 % |
| Regulatory notification windows met | 100 % |
| Suspected credentials revoked ≤ 15 min | 100 % |
| Exposure-window audits completed ≤ 24 h | ≥ 95 % |
| Access reviews completed on cadence | ≥ 95 % |
| Unreviewed grants revoked by default | 100 % |
| Incidents closed with recovery evidence and review record | 100 % |

## Prompts

- [01-implement-method.md](incident-identity/prompts/01-implement-method.md)
- [02-robustness-checks.md](incident-identity/prompts/02-robustness-checks.md)

## Workflows

| ID | Role in this department |
|---|---|
| WFT-003 Alert Response | Receives P0 alerts as incident-declaration candidates |
| WFT-005 Incident Response | **Owner** — full lifecycle from declaration to closure |

Schemas: [../exec/workflows-schema.md](../exec/workflows-schema.md)
