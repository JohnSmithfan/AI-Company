---
department: security-resilience
domain: security
parent: ai-company
roles: [CISO, Resilience Lead]
error_code_prefix: CISO_
function_blocks: 1
consolidates_group_tier: [security-operations, resilience-continuity]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Security & Resilience — Deep Specification

> D3 depth for [../security-resilience.md](../security-resilience.md). Read the D2 page first.
>
> ⚠️ Deliberately **not** named `SKILL.md`; carries no `name`, `slug`, `triggers` or `interface`
> fields, so a recursive loader cannot register it as an independent skill.

## 1. Trigger Scenarios (Extended)

| Situation | Why here |
|---|---|
| A new service or integration needs a threat model before build | STRIDE ownership sits here |
| A vulnerability is discovered and needs a score and a window | CVSS scoring and remediation windows are owned here |
| A production change needs a security gate decision | This department holds the blocking right |
| A continuity commitment needs testing or has been breached | RTO/RPO ownership sits here |
| A control's evidence has aged out | Evidence validity is tracked here |
| A dependency needs supply-chain review | Upstream exposure assessment |
| An anomaly may meet incident criteria | Declaration criteria are defined here; execution is `incident-identity` |
| A circuit-breaker threshold needs setting or review | Threshold ownership sits here |

**Not** this department: legal and privacy obligations (`legal-privacy`), incident execution and
identity (`incident-identity`), risk quantification in financial terms (`risk-audit`), PII handling
policy (`legal-privacy`).

## 2. Core Identity (Extended)

### The blocking right

This department holds a **one-directional blocking right** over every other department's
production-bound changes.

| Direction | Permitted |
|---|---|
| Halt a deployment or publication | ✅ On security grounds, unilaterally |
| Resume a deployment this department halted | ❌ Never — requires `engineering-tooling` plus a recorded root cause |
| Block a skill publication (WFT-004 phase 3) | ✅ |
| Unblock after a failed scan | ❌ Only after the finding is remediated and re-scanned |

⚠️ The asymmetry is deliberate. A department that can both halt and resume its own halt is a
department whose halt can be quietly undone. Separating the two makes a halt durable until the
underlying condition is genuinely fixed.

### Authority model

| Decision class | Authority |
|---|---|
| Block a change failing a control | This department |
| Declare CVSS ≥ 9.0 an emergency | This department |
| Require a compensating control | This department |
| Accept residual risk beyond threshold | `board-and-branch` |
| Order a recovery test | This department |
| Cancel a committed continuity test | `board-and-branch` |
| Raise a breaker threshold above policy ceiling | `board-and-branch` |
| Resume a halted deployment | ❌ `engineering-tooling` + recorded root cause |

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6. This section adds procedural detail.

### 3.A Trust boundaries and data flows

A threat model is scoped by trust boundary, not by component. Before modelling:

| Step | Output |
|---|---|
| Enumerate actors | Human, agent, external service, anonymous |
| Draw data flows | Each flow crosses zero or more boundaries |
| Mark boundaries | Where authentication, authorization or a change of trust occurs |
| Classify data on each flow | Public, internal, confidential, PII |

A flow that crosses a boundary without an authentication step is a finding before any STRIDE
analysis begins.

### 3.B CVSS vector discipline

Scores are recorded with the **full vector string**, never the bare number.

| Element | Required |
|---|---|
| Base metrics | Attack vector, complexity, privileges required, user interaction, scope, CIA impact |
| Vector string | e.g. `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` |
| Temporal metrics | Exploit code maturity, remediation level, report confidence — when known |
| Environmental | Adjusted for this deployment's exposure |

⚠️ A bare score cannot be re-derived, challenged or compared. Two findings both scored 7.5 may have
completely different attack vectors and therefore completely different remediation.

### 3.C Control set

The gate in §3.3 of the D2 page checks this control set:

| Control | Check |
|---|---|
| Authentication | Every cross-boundary flow authenticates |
| Authorization | Least privilege; no ambient authority |
| Input validation | Template 1 on every inbound payload |
| Output masking | Template 9, all three classes, on every outbound payload |
| Secret handling | Environment variable names only; no literal in any file |
| AIGC labelling | Template 4 triple label on generated output |
| Audit trail | Template 7 trace ID on every operation |
| No dynamic execution | No evaluation of untrusted input as code |
| No remote fetch-execute | No download-and-run construct anywhere in the package |
| Dependency provenance | Each dependency has a known source and version |

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `CISO_001` | Security gate blocked | A gate check failed on a production-bound change | 1. Name the failing control from §3.C 2. Remediate, or record an accepted-risk exception **with an expiry date** 3. Re-enter the gate. An exception without an expiry is refused |
| `CISO_002` | CVSS score critical | A scored vulnerability reached CVSS ≥ 9.0 | 1. Open `IRP_001` immediately 2. Mitigate or apply a compensating control within 24 h 3. Notify `board-and-branch` |
| `CISO_003` | STRIDE threat detected | A threat-model pass identified an unmitigated threat | 1. Classify the STRIDE category 2. Assign a control 3. Re-run the model to confirm closure — do not close on the assertion that a control was added |
| `CISO_004` | Incident response required | A condition met the incident-declaration criteria | 1. Declare the incident 2. Hand execution to `incident-identity` (`IRP_001`) 3. Preserve evidence before remediation |
| `CISO_005` | Business continuity threshold breached | RTO or RPO exceeded its committed value in a recovery test | 1. Report measured vs committed 2. Identify the bottleneck stage 3. Re-test after remediation |
| `CISO_006` | Control evidence expired | A control's supporting evidence passed its validity window | 1. Re-collect the evidence 2. Mark the control **unproven** until refreshed 3. An unproven control may not be cited as mitigation |

⚠️ At `group` tier the resilience findings move to `resilience-continuity` under prefix `RSC_`.
Here they report under `CISO_`; `RSC_` is retired at this tier and revived on upgrade — see
[../../scaling.md](../../scaling.md) §3.

## 5. Integration Points

Detailed in the D2 page §5. Protocol notes:

| Counterpart | Protocol |
|---|---|
| `engineering-tooling` | Receives change description + target environment + test evidence; returns pass or a named failing control. A halt we issue is resumable only by them with a recorded root cause |
| `incident-identity` | `CISO_004` hands off to `IRP_001`. We declare; they execute. Evidence is preserved before remediation because remediation destroys it |
| `legal-privacy` | CVSS ≥ 9.0 with personal-data exposure triggers a notification-clock assessment there |
| `risk-audit` | Security risk is FAIR-scored there; we supply the threat register and control status |
| `platform-mlops` | The §3.C control set is enforced in CI/CD; Harness L6 certification requires our sign-off |
| `model-data` | Model access controls and dependency supply-chain review |

## 6. Constraints

- ❌ Do not waive a gate silently — remediate, or record an exception with an expiry
- ❌ Do not resume a deployment this department halted
- ❌ Do not cite an unproven control as mitigation
- ❌ Do not record a CVSS score without its full vector string
- ❌ Do not close a threat on the assertion a control was added — re-run the model
- ❌ Do not treat an unrun recovery test as passed
- ❌ Do not loosen a breaker threshold above the policy ceiling without escalation
- ❌ Do not respond to a CVSS ≥ 9.0 finding without opening `IRP_001`
- ❌ Do not accept an accepted-risk exception with no expiry date

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Ungated production changes | Count — target 0; each occurrence investigated individually |
| Critical finding MTTR | Mitigation timestamp minus intake timestamp, for CVSS ≥ 9.0 |
| Control evidence currency | Controls with in-date evidence ÷ total controls |
| Recovery test coverage | Critical functions tested in the last 90 days ÷ total critical functions |
| RTO attainment | Tests meeting the committed RTO ÷ tests run |
| Expired exceptions | Accepted-risk exceptions past expiry — target 0 |
| Open unmitigated threats > 30 days | Count — target 0 |

⚠️ "Recovery test coverage" counts tests **actually run**, not tests scheduled. An unrun test is a
gap, not a pass.

## 8. SOPs / Operational Procedures

### SOP-CISO-01 · Run a STRIDE threat model

```text
1. Scope by trust boundary (§3.A), not by component.
2. Enumerate actors, data flows, boundaries, data classification.
3. Flag any boundary-crossing flow with no authentication step - that is a finding already.
4. For each element, walk the six STRIDE categories (D2 §3.1 table).
5. For each threat: assign a control, an owner, a status.
6. An unmitigated threat → CISO_003.
7. Closure requires RE-RUNNING the model, not asserting a control was added.
8. Record with a trace ID (template 7, prefix "ciso").
```

### SOP-CISO-02 · Score and triage a vulnerability

```text
1. Reproduce or confirm the finding.
2. Score with the FULL CVSS vector string (§3.B), not a bare number.
3. Assign the remediation window by band (D2 §3.2):
   9.0-10.0 → 24 h + CISO_002 + IRP_001 + notify board-and-branch
   7.0-8.9  → 7 days
   4.0-6.9  → 30 days
   0.1-3.9  → 90 days
4. Assign an owner.
5. If personal data is exposed → notify legal-privacy for the notification clock.
6. Track to remediation; re-score after the fix to confirm the vector changed.
```

### SOP-CISO-03 · Gate a production change

```text
1. Receive: change description, target environment, test evidence.
2. Check every control in §3.C.
3. All pass → return PASS to engineering-tooling.
4. Any fail → CISO_001, name the failing control.
5. Two legal outcomes only:
   a. remediate and re-enter the gate
   b. record an accepted-risk exception WITH an expiry date
6. An exception without an expiry is refused - it is an unbounded waiver.
7. Never waive silently. A gate that can be passed without a record is not a gate.
8. If we halt: resumption is NOT ours - it requires engineering-tooling plus a recorded root cause.
```

### SOP-CISO-04 · Run a business continuity test

```text
1. Select a critical function and its committed RTO/RPO (D2 §3.4).
2. Simulate the failure scenario.
3. Execute recovery following the copy-forward-verify-replace-delete ordering.
4. Measure actual RTO and RPO.
5. Compare against the commitment. Breach → CISO_005, name the bottleneck stage.
6. Record the result whether it passed or failed - an unrecorded test did not happen.
7. Verify recovery at OUTCOME level, not on a command exit code.
8. Schedule the next test within 90 days.
```

⚠️ A test that is scheduled but not run is a coverage gap, reported as such — never as a pass.

### SOP-CISO-05 · Refresh control evidence

```text
1. Weekly, list controls whose evidence is within 14 days of expiry.
2. Re-collect the evidence for each.
3. On successful refresh, update the record with the new collection date and validity window.
4. On failure to refresh → CISO_006, mark the control UNPROVEN.
5. An unproven control:
   - may not be cited as mitigation in a threat model
   - may not support an accepted-risk exception
   - is reported in the weekly metrics until refreshed
6. Supersede the prior evidence with a pointer; never delete it.
```

### SOP-CISO-06 · Set or review a circuit-breaker threshold

```text
1. Pull the dependency's observed failure rate and its degraded-path definition.
2. Start from the defaults in ../../exec/error-recovery.md §3.
3. A department may request TIGHTER thresholds - approve if justified.
4. Loosening above the policy ceiling → escalate to board-and-branch; do not approve locally.
5. Confirm a documented degraded path exists before opening any breaker.
   A breaker with no degraded path just turns a slow failure into a fast one.
6. More than one breaker-open incident per department per 30 days → trigger a STRUCTURAL review,
   not another threshold adjustment. Repeated tripping means the dependency is wrong, not the number.
7. Record the threshold set with its rationale and review date (quarterly).
```
