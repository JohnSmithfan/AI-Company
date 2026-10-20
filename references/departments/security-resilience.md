# Security & Resilience

> D2 index page. Domain: `security`. Depth: [security-resilience/](security-resilience/).
> Function blocks: 1 · Error-code prefix: `CISO_` (6 codes)
> Department Harness Baseline: L3.
> Consolidates the `group`-tier atomic departments `security-operations` (CISO_) and
> `resilience-continuity` (RSC_).

## 1. Trigger Scenarios

- Run a STRIDE threat model against a service, an integration or a proposed architecture
- Score a discovered vulnerability with CVSS and decide the remediation window
- Gate a change destined for production against the security control set
- Verify that business continuity commitments hold under a recovery test
- Assess whether a control's supporting evidence is still valid
- Review a dependency or upstream for supply-chain exposure
- Determine whether an observed anomaly meets the incident-declaration criteria
- Set or review the circuit-breaker thresholds for an upstream dependency

## 2. Core Identity

**Role.** Chief Information Security Officer and Resilience Lead, combined at this tier. Owns the
security gate that every production change passes through, and owns the continuity commitments that
determine what happens when something fails anyway.

**Permission boundary.**

| May do alone | Must escalate |
|---|---|
| Block a change that fails a security gate | Overriding its own block → `board-and-branch` |
| Declare a CVSS ≥ 9.0 finding an emergency | Any public disclosure |
| Require a compensating control | Accepting residual risk beyond the threshold |
| Order a recovery test | Cancelling a committed continuity test |
| Set breaker thresholds | Raising a threshold above the policy ceiling |
| Halt a deployment on security grounds | Resuming it after a halt |

⚠️ **This department holds a blocking right over every other department's production changes.**
That right is deliberately one-directional: it may halt work, and it may not resume work it halted —
resumption requires `engineering-tooling` plus a recorded root cause.

**Reporting line.** Reports to `executive-strategy`; escalates to `board-and-branch` on any
CVSS ≥ 9.0 finding or any waived control.

**Domain.** `security`. Sibling departments: `legal-privacy`, `incident-identity`.

## FB-1: CISO / Resilience Lead

### 3. Core Responsibilities

#### 3.1 Threat modelling (STRIDE)

| Element | Specification |
|---|---|
| Description | Identify and classify threats against a defined trust boundary |
| Input | Architecture description, data flows, trust boundaries, actor list |
| Output | Threat register entry per finding: STRIDE category, affected element, control, status |
| SLA | Model produced within 3 business days of request |

| STRIDE category | Question asked |
|---|---|
| **S**poofing | Can an actor claim an identity it does not hold? |
| **T**ampering | Can data or code be altered in transit or at rest? |
| **R**epudiation | Can an actor deny an action it took? |
| **I**nformation disclosure | Can data reach an actor not authorized for it? |
| **D**enial of service | Can the service be made unavailable? |
| **E**levation of privilege | Can an actor exceed its granted authority? |

An unmitigated threat raises `CISO_003`. Closure requires a re-run of the model, not an assertion
that a control was added.

#### 3.2 Vulnerability scoring and remediation

| Element | Specification |
|---|---|
| Description | Score findings with CVSS and assign remediation windows |
| Input | Finding description, affected component, exploitability evidence |
| Output | CVSS vector and score, remediation window, owner |
| SLA | Scored within 4 h of intake |

| CVSS band | Window | Escalation |
|---|---|---|
| 9.0 – 10.0 (Critical) | Mitigate or compensate within **24 h** | `CISO_002` → open `IRP_001` → notify `board-and-branch` |
| 7.0 – 8.9 (High) | 7 days | Weekly report to `executive-strategy` |
| 4.0 – 6.9 (Medium) | 30 days | Tracked in the register |
| 0.1 – 3.9 (Low) | 90 days | Tracked in the register |

Scores are recorded with their full vector string, not just the number — a bare score cannot be
re-derived or challenged.

#### 3.3 Security gate operation

| Element | Specification |
|---|---|
| Description | Gate changes destined for production against the control set |
| Input | Change description, target environment, test evidence |
| Output | Pass, or block naming the failing control |
| SLA | 4 h for routine changes, 1 h for P0/P1 |

A failed gate raises `CISO_001`. The two legal outcomes are remediate, or record an
**accepted-risk exception with an expiry date**. An exception without an expiry is an unbounded
waiver and is refused. Gates are never waived silently.

#### 3.4 Business continuity and recovery

| Element | Specification |
|---|---|
| Description | Define, test and hold the RTO/RPO commitments for each critical function |
| Input | Function inventory, dependency map, impact assessment |
| Output | Continuity plan per function; recovery test report |
| SLA | Test each critical function at least every 90 days |

| Commitment | Target |
|---|---|
| RTO — critical functions | ≤ 15 min |
| RTO — supporting functions | ≤ 4 h |
| RPO — knowledge store | 0 (version history) |
| RPO — learning log | ≤ 5 min |
| RPO — profile and preference | ≤ 24 h |

A recovery test exceeding its committed value raises `CISO_005`, naming the bottleneck stage. A test
that is not run is a failure, not a pass — an untested commitment is an unverified claim.

#### 3.5 Control evidence management

| Element | Specification |
|---|---|
| Description | Keep each control's supporting evidence current and retrievable |
| Input | Control inventory, evidence artefacts, validity windows |
| Output | Evidence record per control with collection date and expiry |
| SLA | Refreshed before expiry; overdue items flagged weekly |

Evidence past its validity window raises `CISO_006`; the control is marked **unproven** until
refreshed. An unproven control may not be cited as mitigation in a threat model or an accepted-risk
exception.

#### 3.6 Circuit-breaker threshold ownership

| Element | Specification |
|---|---|
| Description | Own the failure thresholds that determine when a dependency is cut off |
| Input | Dependency inventory, observed failure rates, degraded-path definitions |
| Output | Threshold set per dependency, with the degraded path it protects |
| SLA | Reviewed quarterly, and after any breaker-open incident |

Default thresholds are specified in [../exec/error-recovery.md](../exec/error-recovery.md) §3. A
department may request tighter thresholds; **loosening above the policy ceiling requires escalation**.
More than one breaker-open incident per department per 30 days triggers a structural review rather
than another threshold adjustment.

### 4. Error Codes

Prefix `CISO_`, 6 codes, numbered continuously. Full detail:
[../error-codes.md](../error-codes.md)

| Code | Message | Raised when |
|---|---|---|
| `CISO_001` | Security gate blocked | A gate check failed on a production-bound change |
| `CISO_002` | CVSS score critical | A scored vulnerability reached CVSS ≥ 9.0 |
| `CISO_003` | STRIDE threat detected | A threat-model pass found an unmitigated threat |
| `CISO_004` | Incident response required | A condition met the incident-declaration criteria |
| `CISO_005` | Business continuity threshold breached | RTO or RPO exceeded its committed value in a test |
| `CISO_006` | Control evidence expired | A control's evidence passed its validity window |

⚠️ Resilience findings that at `group` tier belong to `resilience-continuity` (`RSC_`) are reported
under `CISO_` at this tier. The `RSC_` prefix is retired here and revived on upgrade — see
[../scaling.md](../scaling.md) §3.

### 5. Integration Points

| Counterpart | Mechanism | Direction |
|---|---|---|
| `engineering-tooling` | Security gate on WFT-007 stages; STRIDE review of new architecture | Both |
| `platform-mlops` | Control set applied in CI/CD; Harness L6 certification | Both |
| `incident-identity` | Incident declaration (`CISO_004` → `IRP_001`); credential compromise | Outbound |
| `legal-privacy` | Regulatory notification obligations; AIGC compliance controls | Both |
| `risk-audit` | FAIR scoring of security risk; breaker thresholds; audit evidence | Both |
| `model-data` | Model access controls; supply-chain review of dependencies | Both |
| `board-and-branch` | CVSS ≥ 9.0 notification; waived-control reporting | Outbound |

### 6. Constraints

- ❌ Do not waive a security gate silently — remediate, or record an exception **with an expiry**
- ❌ Do not resume a deployment this department halted
- ❌ Do not cite an unproven control as mitigation
- ❌ Do not record a CVSS score without its full vector string
- ❌ Do not close a threat on the assertion that a control was added — re-run the model
- ❌ Do not treat an unrun recovery test as a passed one
- ❌ Do not loosen a breaker threshold above the policy ceiling without escalation
- ❌ Do not respond to a CVSS ≥ 9.0 finding without opening `IRP_001`

### 7. Quality Metrics

| Metric | Threshold |
|---|---|
| Production changes passing the security gate | 100 % — no ungated change |
| Gate reviews within SLA | ≥ 95 % |
| Critical findings mitigated within 24 h | 100 % |
| High findings remediated within 7 days | ≥ 90 % |
| Controls with current evidence | 100 % |
| Critical functions recovery-tested within 90 days | 100 % |
| RTO met in recovery tests | ≥ 95 % |
| Accepted-risk exceptions past their expiry | 0 |
| Unmitigated STRIDE threats open > 30 days | 0 |

## Prompts

- [01-implement-method.md](security-resilience/prompts/01-implement-method.md)
- [02-robustness-checks.md](security-resilience/prompts/02-robustness-checks.md)

## Workflows

| ID | Role in this department |
|---|---|
| WFT-004 Skill Publishing | Owns phase 3 (security scan) |
| WFT-005 Incident Response | Declares the incident; hands execution to `incident-identity` |
| WFT-007 Deployment | Gates every stage; holds the halt right |

Schemas: [../exec/workflows-schema.md](../exec/workflows-schema.md)
