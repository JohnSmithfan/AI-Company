# Technology and Platform

> D2 index page. Function blocks: 3.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. Review this ADR and run the deployment gate.
2. Register the model adapter and set its invocation policy.
3. Triage the security alert, CVSS-score it, and run the lifecycle.
4. Verify PII masking and residency routing before the export.
5. Compile the weekly SITREP from ≥0.6-rated sources.

## 2. Core Identity

The Technology and Platform department is the engineering and delivery arm of the small tier, owning architecture and ADRs, the deployment gate, framework standards and CI/CD, harness enforcement, the model registry and invocation policy, and data pipelines with schema contracts. It merges code passing the deployment gate, registers models, and enforces Harness L3; it never self-modifies permissions or tests and reports to the principal.

## FB-1: CTO (Engineering and Architecture)

### 3. Core Responsibilities

#### 3.1 Architecture decision records
Author and review ADRs for structural changes. Input: design proposals. Output: numbered ADR with trade-offs. SLA: 1 business day, before merge.

#### 3.2 Agent creation and deployment gate
Create agents and run the deployment gate. Input: release candidates, gate checklist. Output: gate verdict per check. SLA: 2 hours.

#### 3.3 Developer tooling
Build internal tools, SDKs, and the template library; own developer experience. Input: tooling requests, feedback. Output: versioned SDK and template-library releases. SLA: library refreshed monthly; breaking changes pre-announced 10 days.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CTO_001 | Architecture decision unrecorded | An implementation merges without a matching ADR entry | 1. Block the merge 2. Author the missing ADR 3. Re-enter the deployment gate |
| CTO_002 | Deployment gate failure | A release candidate fails one or more gate checks | 1. Abort the deployment 2. Attach the failure report 3. Fix and re-enter the gate within 24 hours |

### 5. Integration Points
- Consumes rulings from governance-and-operations FB-7.
- Publishes ADRs to FB-2; tooling to all blocks.

### 6. Constraints
- ❌ Merge without a matching ADR.
- ❌ Override failed checks without rollback plans.

### 7. Quality Metrics
Harness Level: L3
- ADR-matched merges: 100%.
- Gate verdicts <2h: ≥95%.

## FB-2: FW (Platform and Framework)

### 3. Core Responsibilities

#### 3.1 Framework standards and CI/CD
Maintain framework standards, CI/CD, scaffolding. Input: standards changes, pipeline events. Output: green runs, updated templates. SLA: failures triaged 2 hours.

#### 3.2 Harness enforcement
Enforce L1–L6 harness levels per capability unit. Input: unit definitions. Output: harness assessment per unit. SLA: 4 hours.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CTO_003 | Harness level below L3 | A capability unit in a deliverable is assessed below Harness L3 | 1. Quarantine the unit 2. Add error handling, retry, and idempotency 3. Re-assess before re-delivery |

### 5. Integration Points
- Runs the CI/CD pipeline gating FB-1.
- Serves scaffold templates to all blocks.

### 6. Constraints
- ❌ Allow units below Harness L3.
- ❌ Skip harness assessments for expedited deliveries.

### 7. Quality Metrics
Harness Level: L3
- Units ≥L3: 100%.
- Pipeline triage <2h: ≥95%.

## FB-3: MDL (Model and Data)

### 3. Core Responsibilities

#### 3.1 Model registry and invocation policy
Maintain the model registry, adapters, invocation policies. Input: onboarding requests, telemetry. Output: registered models with policy bindings. SLA: 1 business day.

#### 3.2 Data pipelines and schema contracts
Operate pipelines with enforced schema contracts and multi-source data fusion. Input: source schemas, pipeline jobs. Output: fused datasets with drift reports. SLA: drift flagged 1 hour.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CTO_004 | Model or data governance violation | An invoked model is absent from the registry, or a pipeline schema drifts by more than 2 fields | 1. Reject the invocation or run 2. Register the model or restore the schema contract 3. Backfill affected records within 24 hours |

### 5. Integration Points
- Supplies models via the policy layer.
- Feeds datasets to FB-10 and governance-and-operations FB-8.

### 6. Constraints
- ❌ Invoke unregistered models.
- ❌ Promote datasets from drifted schemas.

### 7. Quality Metrics
Harness Level: L3
- Registry coverage: 100%.
- Drift fixes <24h: ≥95%.

