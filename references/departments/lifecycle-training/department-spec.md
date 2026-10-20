---
department: lifecycle-training
domain: people
parent: ai-company
roles: [CHO, Training Lead]
error_code_prefix: CHO_
function_blocks: 1
consolidates_group_tier: [agent-lifecycle, capability-training]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Lifecycle & Training — Deep Specification

> D3 depth for [../lifecycle-training.md](../lifecycle-training.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A scaffold-delivered agent has no one running its checklist | Onboarding is the entry gate; an agent active before onboarding is a `CHO_003` waiting to happen |
| An agent's assignments and credentials must be closed out | The offboarding order — commitments, credentials, memory — is defined here |
| Two departments claim the same scarce archetype | Establishment planning decides the mix, not the louder requester |
| A certification is claimed with no artifact attached | Verification belongs here; a claim without evidence is `CHO_004` |
| The roster count no longer matches the declared establishment | Reconciliation authority sits here; either the plan or the roster is wrong, and it is recorded which |

**Not** this department: agent creation and scaffolding (`engineering-tooling`), Harness-level
declarations (`platform-mlops`), dispatch-time routing decisions (`operations-coordination`),
retention limits on stored data (`legal-privacy`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The table below is the source of truth;
an action outside it is refused and the response names the rung that holds authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Mark an onboarding checklist complete | This department | Reversible | — |
| Suspend an agent for a stage violation (`CHO_003`) | This department | Reversible | — |
| Mark a task blocked on an unfilled skill gap (`CHO_002`) | This department | Reversible with cost | — |
| Revoke an unverified certification claim (`CHO_004`) | This department | Reversible with cost | — |
| Amend the approved establishment plan | `executive-strategy` | Reversible with cost | rung 3 |
| Terminate an agent with open customer commitments | `executive-strategy` + owning department | Irreversible | rung 3 |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
executive-strategy
      ▲  establishment plan, capability coverage
      │
lifecycle-training  ◄──── scaffold agents + Harness assessments ◄──── engineering-tooling
      │  ▲
      │  └── routing demand ───────── operations-coordination
      │  └── Profile memory context ─ knowledge-ethics
      ▼  onboarded agents, certification records
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Onboarding checklist structure

Every agent produces a checklist record. A record with an open item is an onboarding that did
not happen.

| Field | Requirement |
|---|---|
| Agent ID | Trace ID from template 7, prefix `cho` |
| Archetype | From the scaffold handover — never inferred |
| Harness level | The assessment's declared level, copied verbatim |
| Checklist items | All closed; closure evidence stored per item |
| Profile memory | Written at onboarding, masked at creation (template 9) |
| Capability entries | Matrix rows the agent satisfies, with their certification references |
| Roster entry | Active, with the onboarding completion timestamp |
| Stage at entry | `Active` — an agent is never active before its checklist closes |
| Review date | Set at onboarding; a record without one is never re-examined |

### 3.B Offboarding sequence

The order is fixed. Reversing steps 2 and 3 strands work.

```text
1. Close or reassign every open assignment. An assignment left open is a customer commitment
   without an owner.
2. Revoke credentials. IRP_004 handling applies where compromise is suspected.
3. Archive Profile memory. The masked copy is retained; retention limits from legal-privacy
   apply.
4. Remove the roster entry and the capability-matrix rows the agent satisfied.
5. Record the exit with its reason and its trace ID.
```

### 3.C Skill-gap closure path

A `CHO_002` gap has exactly two closure routes, chosen explicitly:

| Route | When it applies | Effect |
|---|---|---|
| Training | The gap is narrow and time-bounded | A training plan with a target certification date; the gap stays open meanwhile |
| Recruitment | The gap is structural or recurring | An establishment revision request to `executive-strategy` |

Both routes leave the gap **open** in the matrix until the certification is verified — a gap is
closed by evidence, not by assignment. A task blocked by an unfilled gap is never silently
reassigned to an unqualified agent.

The capability matrix records the gap's state as `open`, `training-in-progress` or
`recruitment-requested`. Only the first two are this department's to move; the third belongs to
`executive-strategy` until the establishment revision is approved.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `CHO_001` | Agent onboarding failed | An agent could not complete its onboarding checklist | 1. Report the unmet checklist item 2. Remediate the gap 3. Re-run onboarding — never mark complete with gaps |
| `CHO_002` | Skill gap detected | A required capability has no assigned competent agent | 1. Record the gap against the capability matrix 2. Route to training or recruitment 3. Mark affected tasks as blocked until filled |
| `CHO_003` | Lifecycle violation | An agent acted outside its lifecycle stage permissions | 1. Suspend the agent 2. Identify the stage mismatch 3. Re-enter at the correct stage |
| `CHO_004` | Training completion unverified | A certification was claimed without verifiable evidence | 1. Request the evidence artifact 2. Revoke the claim until produced 3. Record the verification method |
| `CHO_005` | Headcount plan inconsistent | Declared establishment diverged from the active roster | 1. Reconcile roster against plan 2. Correct the plan or the roster 3. Record which was authoritative |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `engineering-tooling` | Handover includes the archetype, the capability requirements and the Harness assessment; an agent without its assessment is returned, not onboarded |
| `knowledge-ethics` | Profile memory is written at onboarding and masked at creation; capability records are extraction sources, delivered with their trace IDs |
| `operations-coordination` | Routing demand is checked against the capability matrix before an assignment is confirmed; the live roster is the scheduling input |
| `legal-privacy` | Erasure requests are executed at offboarding; Profile memory is never persisted raw |

## 6. Constraints

- ❌ Do not mark an onboarding checklist complete with an open item (`CHO_001`)
- ❌ Do not onboard an agent that arrived without its Harness-level assessment
- ❌ Do not revoke credentials before open customer commitments are closed or routed
- ❌ Do not close a skill gap by reassigning the task to an unqualified agent
- ❌ Do not accept a certification claim without its evidence artifact (`CHO_004`)
- ❌ Do not absorb a roster-plan drift silently — record which side was authoritative (`CHO_005`)
- ❌ Do not create agents; creation belongs to `engineering-tooling`
- ❌ Do not carry a revoked certification in the capability matrix past the next revision

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Onboarding completion | Checklist completion timestamp minus scaffold-handover timestamp |
| Skill-gap response time | Gap-recorded timestamp to routing timestamp for the chosen closure route |
| Stage violations | `CHO_003` count ÷ active agents per measurement window |
| Certification verification rate | Claims verified with an artifact ÷ total claims received |
| Roster-plan drift | Absolute roster-minus-plan count at each monthly reconciliation |
| Offboarding completeness | Offboardings with commitments closed, credentials revoked and memory archived ÷ total offboardings |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-CHO-01 · Onboard an agent

```text
1. Receive the handover from engineering-tooling: manifest, archetype, capability requirements,
   Harness assessment. A missing assessment is returned; the agent is not onboarded.
2. Generate a trace ID (template 7, prefix "cho").
3. Open the checklist. Run every item; record closure evidence per item.
4. Any item that cannot close → CHO_001. Report the unmet item, remediate, re-run.
5. Write Profile memory, masked at creation (template 9).
6. Add the capability-matrix rows the agent satisfies, with certification references.
7. Activate the roster entry with the completion timestamp.
8. Label the record (template 4) and publish completion to operations-coordination.
```

### SOP-CHO-02 · Offboard an agent

```text
1. Approve the offboarding. Open customer commitments route first — an unowned commitment
   escalates to operations-coordination before the exit proceeds.
2. Close or reassign every open assignment.
3. Revoke credentials. Suspected compromise → IRP_004 handling in parallel.
4. Archive Profile memory (masked); apply legal-privacy retention and erasure rules.
5. Remove the roster entry and the capability-matrix rows the agent satisfied.
6. Record the exit with its reason, trace ID and timestamp.
7. A stage mismatch discovered during exit → CHO_003; suspend and re-enter at the correct
   stage before the exit completes.
```

### SOP-CHO-03 · Reconcile the establishment plan against the roster

```text
1. Run the reconciliation monthly.
2. Compare the declared establishment (count per archetype) against the active roster.
3. Divergence → CHO_005.
4. Decide which side is wrong: a stale plan, or uncontrolled roster growth.
5. Correct the wrong side; record which was authoritative.
6. Material corrections route to executive-strategy for the plan amendment.
7. Publish the reconciled plan with its effective date.
```

### SOP-CHO-04 · Close a detected skill gap

```text
1. On CHO_002, record the gap against the capability matrix with the affected tasks.
2. Mark the affected tasks blocked. Never reassign to an unqualified agent.
3. Choose the closure route explicitly: training (time-bounded) or recruitment (structural).
4. Training route: plan the certification with a target date. The gap stays open meanwhile.
5. Recruitment route: raise an establishment revision request to executive-strategy.
6. Close the gap only when the certification is verified under SOP-CHO-05.
7. Still open past its SLA → raise a P2 alert through WFT-003.
```

### SOP-CHO-05 · Verify a certification claim

```text
1. Receive the claim with its evidence artifact and the claimed verification method.
2. No artifact → CHO_004. Revoke the claim until produced; record the revocation.
3. Verify the artifact against the certification's criteria.
4. Record the verification method, not just the outcome.
5. On success, update the capability matrix in the same pass.
6. On failure, the claim is revoked and the training route under SOP-CHO-04 applies.
7. Label and mask the record (templates 4 and 9) before distribution.
```

⚠️ SOP-CHO-04 step 6 is the whole discipline: a gap closes on verified evidence, never on
assignment. A capability-matrix entry that cites an unverified certification is exactly the
defect `CHO_004` exists to catch.
