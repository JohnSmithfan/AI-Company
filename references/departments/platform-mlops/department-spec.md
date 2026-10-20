---
department: platform-mlops
domain: technology
parent: ai-company
roles: [Framework Steward, MLOps Lead]
error_code_prefix: FW_
function_blocks: 1
consolidates_group_tier: [platform-framework, mlops-observability]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Platform & MLOps — Deep Specification

> D3 depth for [../platform-mlops.md](../platform-mlops.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A module's dependency graph breaks the layering rule | Framework standards are owned here (`FW_002`); `engineering-tooling` reviews designs against the rules, it does not set them |
| A pipeline run failed and the owning department cannot tell which stage | Pipeline operation and its logs are owned here (`FW_007`) |
| A capability needs a Harness level declared, verified or challenged | The L1–L6 definitions and the certification evidence live here (`FW_006`) |
| A shared architectural decision needs an ADR opened, amended or superseded | The ADR process is owned here; `engineering-tooling` cites ADRs, this department records them |
| A model's health degraded and traffic must be routed around it | Health monitoring and the routing decision sit here; the registry itself belongs to `model-data` |

**Not** this department: architecture review of a specific design (`engineering-tooling`),
model registry entries and access control (`model-data`), security gate operation
(`security-resilience`), production deployments (`engineering-tooling`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The matrix below is the source of
truth; an action outside it is refused and the response names the rung that holds authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Enforce framework standards on a submitted module | This department | Reversible | — |
| Re-run a failed pipeline | This department | Reversible | — |
| Certify a capability at Harness L1–L5 | This department | Reversible | — |
| Certify Harness L6 | This department + `security-resilience` sign-off | Reversible | — |
| Amend the framework standards themselves | `executive-strategy` | — | rung 3 |
| Supersede an ADR with organization-level impact | `executive-strategy` | — | rung 3 |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
executive-strategy
      ▲  standard amendments · ADR supersessions · WFT-010 proposals
      │
platform-mlops  ◄──── pipeline failures ───── engineering-tooling
      │  ▲
      │  └── registry health signals ── model-data
      │  └── control-set results ────── security-resilience
      │  └── gate results ───────────── quality-visualization
      ▼  standards, scaffolds, certifications
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements
each. This section adds the procedural detail.

### 3.A Harness level definitions (L1–L6)

Each level is a constraint set, not a label. A certification cites the evidence per
constraint; a level whose constraints are not all evidenced is not granted.

| Level | Name | Constraint set (summary) |
|---|---|---|
| L1 | Assisted | Single tool call per turn; a human reviews every output before use |
| L2 | Supervised | Multi-step within one session; side effects require human approval |
| L3 | Bounded autonomous | Runs a declared workflow end to end; escalates on scope exit |
| L4 | Cross-session | Persists state across sessions; owns a departmental SLA |
| L5 | Delegated authority | Holds a standing grant inside the authorization matrix |
| L6 | Certified autonomous | Acts on production without per-action approval; requires `security-resilience` sign-off |

⚠️ L6 is the only level another department's blocking right depends on.
`security-resilience` certifies it jointly; this department never certifies L6 alone.

### 3.B ADR lifecycle

```text
proposed -> accepted -> (superseded | deprecated)
```

| Field | Requirement |
|---|---|
| ADR ID | Trace ID from template 7, prefix `fw` |
| Status | proposed / accepted / superseded / deprecated |
| Context | The forces at play, stated without the decision |
| Decision | The chosen position, in one sentence |
| Consequences | What becomes easier, and what becomes harder |
| Supersedes | Pointer to the ADR this one replaces — never a deletion |

An ADR is closed only within its recorded scope. A design checked against a recorded
constraint raises `CTO_001` in `engineering-tooling`, and the citation names the ADR.
Superseding an ADR that breaks a recorded constraint is an `executive-strategy` decision,
not a platform one.

### 3.C Model health monitoring and A/B readout

| Signal | Breach condition | Action |
|---|---|---|
| Error rate | > 2 % over 5 min | Route around; open a health verdict |
| p95 latency | > 2× the 7-day baseline | Route around; record the provider class |
| Rate-limit headroom | < 10 % of configured `rpm` | Apply template 8 backoff; shift load |
| Disabled flag | Set with a reason | `MDL_003`; the next fallback entry serves |

An A/B test is registered before it runs: variants, metric, success criterion, window. A
readout without a pre-registered criterion is not a readout. On a significant result the
winning variant is promoted through `engineering-tooling`; on a tie the incumbent stays.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| FW_001 | Schema validation failed | A manifest or payload failed its declared schema | 1. Report the offending field and expected type 2. Correct the producer 3. Re-validate before proceeding |
| FW_002 | Modularization violation | A module took a dependency that breaks the layering rule | 1. Cite the violated layering rule 2. Invert or extract the dependency 3. Re-run the dependency check |
| FW_003 | Registry lookup failed | A requested registry entry was absent or ambiguous | 1. Confirm the lookup key 2. Register the missing entry or disambiguate 3. Never fall back to a default entry silently |
| FW_004 | Learning pipeline error | The knowledge-distillation pipeline failed or produced an empty batch | 1. Check source availability 2. Re-run the batch 3. Retain the previous distilled state if the re-run fails |
| FW_005 | Scaffolding generation failed | A scaffold could not be generated for the requested archetype | 1. Validate the archetype name against the registry 2. Check template availability 3. Fall back to the nearest lower archetype |
| FW_006 | Harness constraint violation | A capability was declared at a Harness level it does not satisfy | 1. Report the unmet constraint for the claimed level 2. Either implement the constraint or declare the lower level 3. Never over-declare |
| FW_007 | CI/CD pipeline failed | A pipeline run ended in failure | 1. Read the failing job log 2. Fix or revert the offending change 3. Re-run the pipeline from the start |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `engineering-tooling` | Standards, gate results and Harness definitions are versioned artefacts; consumers cite the version in use, never a local copy |
| `model-data` | Registry health events (`MDL_001`–`MDL_006`) feed monitoring; a disabled model is routed around here and re-enabled only through `model-data` |
| `security-resilience` | The control set runs as CI/CD stages; Harness L6 certification requires its sign-off |
| `executive-strategy` | WFT-010 proposals are sent with all six gate results; the decision is recorded there and **a human performs the approval** — this department never installs |

## 6. Constraints

- ❌ Do not over-declare a Harness level (`FW_006`)
- ❌ Do not let WFT-010 install anything — phase 7 is "stop"
- ❌ Do not amend the framework standards without escalation
- ❌ Do not fall back to a default registry entry silently (`FW_003`)
- ❌ Do not run an A/B readout without a pre-registered success criterion
- ❌ Do not certify Harness L6 without `security-resilience` sign-off
- ❌ Do not treat a pipeline as green because the failure looked flaky — re-run from the start
- ❌ Do not approve a tier upgrade — no department may

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Pipeline success rate | Green runs ÷ total runs, from the CI/CD log |
| Pipeline diagnosis latency | Failure-to-diagnosis timestamp delta per run |
| Certification evidence completeness | Certifications with every constraint evidenced ÷ total |
| Scaffold generation latency | Request-to-artifact timestamp delta |
| Health detection latency | Degradation-onset-to-detection delta from monitoring |
| A/B readout discipline | Tests with a pre-registered criterion ÷ total tests |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-FW-01 · Validate a module against framework standards

```text
1. Receive the module manifest, dependency graph and declared schema.
2. Validate the manifest and payloads against the schema (template 1).
   Failure → FW_001: report the offending field and its expected type; return to the producer.
3. Walk the dependency graph against the layering rules.
   Breach → FW_002: cite the violated rule; invert or extract the dependency.
4. Re-run the dependency check after remediation.
5. Record the verdict with a trace ID (template 7, prefix "fw").
6. Pass only when schema and layering are both clean.
```

### SOP-FW-02 · Operate a failed CI/CD pipeline

```text
1. On FW_007, read the failing job log — never guess from the exit code alone.
2. Name the failing job and the offending change in the diagnosis.
3. Decide: fix forward, or revert. Record which and why.
4. Re-run the pipeline from the start — a partial re-run hides ordering faults.
5. If the build stage itself failed, surface CTO_003 to engineering-tooling.
6. Two consecutive failures at the same stage → escalate to engineering-tooling.
7. Keep the security control-set stages mandatory — a skipped stage is a gate breach.
```

### SOP-FW-03 · Certify a Harness level

```text
1. Receive the capability description, the claimed level and the evidence set.
2. Check the evidence against every constraint of the claimed level (D3 §3.A).
   Any unmet constraint → FW_006: report it; the claim is not granted.
3. If L6 is claimed, route to security-resilience for sign-off before certifying.
4. Certify at the highest level whose full constraint set is evidenced.
5. Record the certification with the evidence references and a trace ID.
6. Publish the level so consumers cite the version in use.
```

### SOP-FW-04 · Run the ADR process

```text
1. Receive the decision context — stated without the decision itself.
2. Open the ADR with status "proposed" and a trace ID (template 7, prefix "fw").
3. Record context, decision, consequences and the supersedes pointer.
4. Accept, or return with the missing field named — an ADR is never half-recorded.
5. On supersession, keep the old ADR with a pointer; never delete it.
6. If the ADR breaks a recorded constraint, escalate to executive-strategy before accepting.
```

### SOP-FW-05 · Handle a WFT-010 upgrade proposal

```text
1. Evaluate T1–T4 against .scaling-state.json metrics.
2. Look up the target tier in the merge tree — table lookup only, never improvisation.
3. Build the complete package at {WORKSPACE_ROOT}/.skill-upgrade/<timestamp>/.
4. Run gates G1–G6; any failure deletes the package and records the SCL_ code.
5. Run the full acceptance suite against the package on its own.
6. Write UPGRADE-PROPOSAL.md with all six gate results.
7. Send to executive-strategy with board-and-branch; the decision is recorded there.
8. STOP. Nothing is installed. A HUMAN approves; an external installer applies.
```

⚠️ Step 8 is the whole point of the three-stage model. This department produces the
proposal; it is input to a human decision, not the decision.
