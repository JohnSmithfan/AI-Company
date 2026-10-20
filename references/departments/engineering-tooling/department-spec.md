---
department: engineering-tooling
domain: technology
parent: ai-company
roles: [CTO, Developer Tooling Lead]
error_code_prefix: CTO_
function_blocks: 1
consolidates_group_tier: [engineering-architecture, developer-tooling]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Engineering & Tooling — Deep Specification

> D3 depth for [../engineering-tooling.md](../engineering-tooling.md). Read the D2 page first.
>
> ⚠️ Deliberately **not** named `SKILL.md`; carries no `name`, `slug`, `triggers` or `interface`
> fields, so a recursive loader cannot register it as an independent skill.

## 1. Trigger Scenarios (Extended)

| Situation | Why here |
|---|---|
| A design needs checking against recorded constraints before build | Constraint ownership sits here; standards ownership sits in `platform-mlops` |
| An agent must be created and its Harness level assessed | The creation path and the assessment are one procedure |
| A build must be promoted toward production | The three-stage gate is owned here |
| A deployment failed and must be rolled back | Rollback execution is owned here; the halt decision may come from `security-resilience` |
| A team needs an internal tool that does not exist | Tooling request intake |
| A production operation needs a grant check | Grant verification for production scope |
| A pipeline stage keeps failing | Diagnosis before escalation to `platform-mlops` |

**Not** this department: framework standards and CI/CD definitions (`platform-mlops`), model
registry and adapters (`model-data`), security gate criteria (`security-resilience`), quality
thresholds (`quality-visualization`).

## 2. Core Identity (Extended)

### Separation from `platform-mlops`

These two are the most commonly confused pair in the technology domain.

| Concern | `engineering-tooling` | `platform-mlops` |
|---|---|---|
| Architecture conformance | ✅ decides | defines the standard |
| Agent creation | ✅ executes | provides the scaffold (`FW_005`) |
| Harness level | ✅ assesses | defines L1–L6 |
| Deployment gate | ✅ operates the three stages | defines CI/CD |
| ADR | ✅ proposes supersessions | owns the ADR process (`FW_008`) |
| Pipeline failure | ✅ diagnoses | owns the pipeline (`FW_007`) |
| Internal tooling | ✅ builds and maintains | — |
| Model registry | — | — (belongs to `model-data`) |

Rule of thumb: **this department applies standards; `platform-mlops` writes them.**

### Authority model

| Decision class | Authority |
|---|---|
| Approve a design consistent with existing ADRs | This department |
| Canary deployment (≤ 5 % traffic) | This department |
| Staged or full promotion | Requires approval per WFT-007 mode `Approve` |
| Roll back a deployment | This department |
| Resume a deployment halted by `security-resilience` | ❌ Never — requires that department plus a recorded root cause |
| Supersede an ADR | `board-and-branch` ratification |
| Execute a production-scoped operation | Requires the grant (`CTO_004` without it) |

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6. This section adds procedural detail.

### 3.A Architecture Decision Records

| Field | Requirement |
|---|---|
| ADR ID | Sequential, never reused |
| Status | proposed · accepted · superseded · deprecated |
| Context | The constraint set that made this decision necessary |
| Decision | One sentence, testable |
| Consequences | What becomes easier, what becomes harder, what is foreclosed |
| Superseded by | Pointer, when applicable — never a silent deletion |

An ADR is **proposed** by this department and **processed** through `platform-mlops`'s ADR process
(`FW_008`). A design that contradicts an accepted ADR raises `CTO_001`; the two legal outcomes are
redesign or file a supersession. There is no third outcome.

### 3.B Harness level assessment

Assessed against the definitions in [../../method-patterns.md](../../method-patterns.md). The
assessment is evidence-based, not declarative.

| Level | Evidence required |
|---|---|
| L1 Skeleton | Schema present, frontmatter parses |
| L2 Functional | Input validation demonstrated; output format demonstrated |
| L3 Robust | Error handling, retry and idempotency each demonstrated by a test |
| L4 Resilient | Circuit breaker, rate limit and monitoring each demonstrated |
| L5 Compliant | AIGC labelling, PII masking and audit trail each demonstrated |
| L6 Certified | STRIDE model complete, CVSS scored, CISO sign-off recorded |

⚠️ Declaring a level without the evidence raises `FW_006`. Over-declaration is a defect, not
optimism — it causes downstream consumers to rely on guarantees that do not exist.

**Every department in this package is specified at L3 or above.**

### 3.C Deployment gate evidence

Each stage produces evidence, and evidence is collected at the right level:

| Stage | Evidence level required |
|---|---|
| Canary | Configuration-level: the deployed version reads back correctly, plus error-rate telemetry |
| Staged | Configuration-level plus outcome-level for the affected user path |
| Full | **Outcome-level**: the user-visible path behaves correctly, observed through normal access |

⚠️ A successful deployment command proves the command ran. Claiming "deployed and working" on that
basis alone is an unverified claim — the full stage requires observing the downstream effect.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `CTO_001` | Architecture violation | A proposed design breaks a recorded architectural constraint | 1. Cite the violated constraint and its ADR 2. Redesign, or file an ADR supersession 3. Never merge without one of the two |
| `CTO_002` | Agent creation failed | An agent scaffold could not be produced from the template | 1. Validate template inputs 2. Check the target namespace is free 3. Re-run; on a second failure open `FW_005` |
| `CTO_003` | Skill build failed | A skill package failed its build stage | 1. Read the build log 2. Fix the reported schema or dependency error 3. Rebuild — never skip the failing stage |
| `CTO_004` | Production operation denied | A production-scoped operation was attempted without the required grant | 1. Refuse the operation 2. Name the rung that can grant it 3. Record the attempt |
| `CTO_005` | MLOps pipeline error | A pipeline stage failed or produced no artifact | 1. Identify the failing stage 2. Re-run from the last good checkpoint 3. Escalate to `platform-mlops` after two consecutive failures at the same stage |
| `CTO_006` | Deployment failed | A deployment did not reach healthy state within its window | 1. Trigger the pre-defined rollback 2. Capture failure evidence 3. Block re-deploy until the root cause is recorded |
| `CTO_007` | Developer tooling unavailable | An internal tool required by a workflow was unreachable | 1. Check the tool health endpoint 2. Fall back to the documented manual path 3. Open an incident if downtime exceeds 30 min |
| `CTO_008` | Three-stage deployment gate failed | A deployment failed one of canary / staged / full | 1. Identify the failing gate and metric 2. Halt promotion 3. Roll back to the previous stage 4. Re-enter the gate only after remediation |

⚠️ Numbering is continuous `001`–`008`, **no gaps**.

## 5. Integration Points

Detailed in the D2 page §5. Protocol notes:

| Counterpart | Protocol |
|---|---|
| `platform-mlops` | Requests scaffold generation with the archetype name; receives `FW_005` on failure rather than a partial artifact |
| `security-resilience` | Submits the change description, target environment and test evidence; receives pass or a named failing control. A halt from this counterpart is not resumable by us |
| `quality-visualization` | Submits coverage and DORA readings at each gate; a coverage reading below 85 % blocks phase 2 of WFT-004 |
| `model-data` | Deploys model services through the same three-stage gate; model config changes are treated as deployments |
| `delivery-scheduling` | Deployment windows are negotiated against committed schedules; a window conflict is resolved by priority class, not by deploying anyway |

## 6. Constraints

- ❌ Do not merge a design that violates a constraint without an ADR supersession
- ❌ Do not deploy without a **tested** rollback plan — an untested plan is a hypothesis
- ❌ Do not promote past a failed stage
- ❌ Do not re-deploy after a failure until the root cause is recorded
- ❌ Do not resume a deployment halted by `security-resilience`
- ❌ Do not declare a Harness level without the corresponding evidence
- ❌ Do not execute a production operation without the grant
- ❌ Do not publish tooling without documentation
- ❌ Do not roll back by deleting first — copy forward, verify, atomic replace, delete last
- ❌ Do not claim "deployed and working" on a command exit code alone

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Change failure rate | Deployments requiring rollback ÷ total deployments |
| MTTR | Time from failure detection to verified restoration, measured at outcome level |
| First-time gate pass rate | Deployments passing all three stages without a halt ÷ total |
| Review latency | Architecture review completion minus submission timestamp |
| Diagnosis latency | Pipeline diagnosis completion minus failure timestamp |
| Ungated production operations | Count — target is 0, and any occurrence is investigated individually |

DORA alignment: the first three metrics are the standard DORA set; `quality-visualization` reports
them organization-wide.

## 8. SOPs / Operational Procedures

### SOP-CTO-01 · Review an architecture proposal

```text
1. Identify the affected components and their trust boundaries.
2. Retrieve every accepted ADR touching those components.
3. Check the proposal against each constraint.
4. If consistent → approve, record the ADRs checked.
5. If a constraint is violated → CTO_001, cite the constraint and its ADR.
   Offer exactly two paths: redesign, or file a supersession.
6. If a supersession is filed → route to platform-mlops (FW_008), then to
   board-and-branch for ratification.
7. If the design introduces a new trust boundary → request a STRIDE model from
   security-resilience before approval.
8. Record the decision with a trace ID (template 7, prefix "cto").
```

### SOP-CTO-02 · Create an agent

```text
1. Confirm the archetype is registered. Unregistered → FW_003, do not improvise one.
2. Confirm the target namespace is free.
3. Request scaffold generation from platform-mlops.
   Failure → CTO_002; second failure → FW_005.
4. Assess the Harness level against §3.B, collecting the evidence for each level claimed.
5. Over-declaration → FW_006. Assess at the level the evidence supports.
6. Confirm the minimum baseline regardless of level:
   - input validation (template 1)
   - output masking (template 9, all three classes)
   - AIGC labelling (template 4)
   - trace ID (template 7)
7. Register the agent with lifecycle-training for onboarding.
8. Record the assessment with its evidence.
```

### SOP-CTO-03 · Run the three-stage deployment gate

```text
PRE-FLIGHT
 1. Confirm the build is green (FW_007 clear).
 2. Confirm a rollback plan exists AND has been tested. Untested → halt, do not proceed.
 3. Confirm approval is recorded (WFT-007 mode is Approve).
 4. Confirm security-resilience has passed the change. A pending gate is not a pass.
 5. Confirm the deployment window with delivery-scheduling.

STAGE 1 - CANARY
 6. Deploy to <= 5% traffic.
 7. Observe 30 min. Pass criterion: error rate <= 1%.
 8. Fail → CTO_008, halt, roll back to pre-deployment state.

STAGE 2 - STAGED
 9. Promote to <= 25% traffic.
10. Observe 60 min. Pass criterion: error rate <= 1%.
11. Fail → CTO_008, halt, roll back to canary.

STAGE 3 - FULL
12. Promote to 100%.
13. Observe 24 h against the SLO.
14. Fail → CTO_006, roll back to staged, block re-deploy until root cause is recorded.

POST
15. Verify at OUTCOME level - exercise the user-visible path through normal access.
16. Record stage evidence for all three stages.
17. Report completion. Do not claim success on an exit code alone.
```

### SOP-CTO-04 · Roll back a deployment

```text
1. Determine the target state (previous stage, or pre-deployment).
2. Copy the target state forward to a staging location.
3. VERIFY the staged copy is complete and consistent.
4. Atomically replace the live state.
5. Confirm the replacement at outcome level.
6. Only now delete the superseded state.
7. Record the rollback with the originating trace ID.
```

⚠️ **Never invert steps 2–6.** Deleting first and restoring second loses everything if the restore
fails. A predecessor package shipped exactly this ordering in its update script.

### SOP-CTO-05 · Handle a pipeline failure

```text
1. Read the failing job log. Do not re-run before reading.
2. Classify: schema/dependency error → CTO_003; stage produced no artifact → CTO_005.
3. Fix the reported cause, or revert the offending change.
4. Re-run from the last good checkpoint rather than from the start where possible.
5. Two consecutive failures at the same stage → escalate to platform-mlops.
6. Record the diagnosis with its latency, for the metric in §7.
```

### SOP-CTO-06 · Intake a tooling request

```text
1. Record the request and the workflow it unblocks.
2. Triage within 4 h: build / adapt existing / refuse with an alternative.
3. Before building, search the template library — a near-miss adapted is cheaper than a new tool.
4. Build with documentation. An undocumented tool is refused at review.
5. Confirm the tool is idempotent and rate-limited (template 8) if it touches external systems.
6. Publish to the template library with a version.
7. If the tool is unavailable later → CTO_007, point users at the documented manual path,
   and open an incident if downtime exceeds 30 min.
```
