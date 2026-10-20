# Data and Analytics

> D2 index page. Function blocks: 2.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. A model needs registration or an invocation policy.
2. A data pipeline schema drifts and must be restored.
3. Multi-source data must be fused into a consistent answer.
4. Localization coverage must reach 100% of locales.
5. A dataset shows conflicting fields across sources.

## 2. Core Identity

The Data and Analytics department owns the model registry, invocation policy, data pipelines, schema contracts, information fusion, and localization for the medium tier. It registers models, enforces schema contracts on pipelines, fuses multi-source data, and routes requests by language; it never self-modifies permissions or tests and reports to the principal.
## FB-1: CDO MDL (Model and Data)

### 3. Core Responsibilities

#### 3.1 Model registry and invocation policy
Maintain the model registry, adapters, invocation policies. Input: onboarding requests, telemetry. Output: registered models with policy bindings. SLA: 1 business day.

#### 3.2 Data pipelines and schema contracts
Operate pipelines with enforced schema contracts and multi-source data fusion. Input: source schemas, pipeline jobs. Output: fused datasets with drift reports. SLA: drift flagged 1 hour.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CDO_001 | Model or data governance violation | An invoked model is absent from the registry, or a pipeline schema drifts by more than 2 fields | 1. Reject the invocation or run 2. Register the model or restore the schema contract 3. Backfill affected records within 24 hours |

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

## FB-2: CDO INFO (Information and Localization)

### 3. Core Responsibilities

#### 3.1 Project scheduling and ticket SLA
Own project scheduling, sprint commitments, ticket SLAs, and customer escalations. Input: project plans, sprint backlogs, support tickets. Output: committed sprint plan, SLA dashboard, escalation resolutions. SLA: sprint committed pre-start; tickets triaged 4 hours; escalations answered 1 business day.

#### 3.2 Localization and language routing
Translate and culturally adapt content; route requests by language. Input: source content, target locale list. Output: localized content for 100% of locales. SLA: 2 business days.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CDO_002 | Information fusion inconsistency | Multi-source lookups disagree on more than 15% of fields, or localization coverage is below 100% | 1. Flag the conflicting fields 2. Re-query the authoritative source 3. Correct the fusion rule within 4 hours |

### 5. Integration Points
- Publishes sprint and SLA status to FB-2 (COO).
- Routes user-language requests per the runtime policy.

### 6. Constraints
- ❌ Leave tickets untriaged >4 hours.
- ❌ Ship localization below 100% locale coverage.

### 7. Quality Metrics
Harness Level: L3
- Ticket triage <4h: ≥95%.
- Locale coverage: 100%.
