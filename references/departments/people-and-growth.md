# People and Growth

> D2 index page. Function blocks: 4.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. Review this ADR and run the deployment gate.
2. Register the model adapter and set its invocation policy.
3. Triage the security alert, CVSS-score it, and run the lifecycle.
4. Verify PII masking and residency routing before the export.
5. Compile the weekly SITREP from ≥0.6-rated sources.

## 2. Core Identity

The People and Growth department owns the agent lifecycle, capability matrix and training, knowledge and ethics governance, brand and partnerships, and competitive intelligence for the small tier. It certifies agents, runs learning and ethics pipelines, and tracks brand and sentiment; it never self-modifies permissions or tests and reports to the principal.

## FB-7: CHO (Agent Lifecycle and Training)

### 3. Core Responsibilities

#### 3.1 Agent onboarding and offboarding
Manage agent lifecycle states and headcount. Input: onboarding/offboarding requests. Output: lifecycle records with scoped credentials. SLA: onboarding 1 business day; offboarding 4 hours.

#### 3.2 Capability matrix and training
Maintain the capability matrix and run certification training. Input: skill assessments, training plans. Output: capability scores per agent. SLA: 5 business days.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CHO_001 | Agent activated without certification | An agent enters production routing with a capability matrix score below 80% | 1. Deactivate the agent 2. Assign targeted training 3. Re-certify before reactivation |

### 5. Integration Points
- Issues scoped credentials with FB-6 (IRP).
- Reports skill gaps to governance-and-operations FB-1.

### 6. Constraints
- ❌ Route agents below 80% capability.
- ❌ Leave offboarded credentials active >4 hours.

### 7. Quality Metrics
Harness Level: L3
- Certified agents ≥80%: 100%.
- Revocations <4h: 100%.

## FB-8: KNM (Knowledge and Ethics)

### 3. Core Responsibilities

#### 3.1 Knowledge extraction and memory governance
Extract knowledge, run learning pipelines, and apply memory governance (memory store activated at M+ tiers). Input: session artifacts, memory records. Output: reviewed artifacts with provenance. SLA: review cycle ≤90 days.

#### 3.2 Ethics review and culture audit
Run ethics reviews and maintain the reporting channel. Input: review requests, reports. Output: rulings with rationale. SLA: 10 business days; overdue ≤14 days.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CHO_002 | Knowledge base staleness | A knowledge or memory artifact passes 90 days unreviewed, or an ethics review is overdue by more than 14 days | 1. Mark the artifact stale 2. Schedule review or ethics audit 3. Update or archive within 10 business days |

### 5. Integration Points
- Serves knowledge artifacts to all blocks.
- Escalates ethics findings to governance-and-operations FB-3.

### 6. Constraints
- ❌ Serve artifacts unreviewed >90 days.
- ❌ Retaliate against or expose reporting-channel sources.

### 7. Quality Metrics
Harness Level: L3
- Artifacts reviewed <90d: ≥95%.
- Reviews overdue >14d: 0.

## FB-9: CMO (Marketing and Partnerships)

### 3. Core Responsibilities

#### 3.1 Brand, GTM, and NPS
Own brand standards, go-to-market, and NPS tracking. Input: campaign plans, surveys. Output: approved campaigns and NPS trend. SLA: approval 2 business days.

#### 3.2 Partnerships and ecosystem
Manage partners, channels, alliances. Input: partner proposals, terms. Output: agreements with measurable goals. SLA: 5 business days.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CHO_003 | External content released without approval | Content leaves the organization without L5 harness or CMO sign-off, or NPS falls below 30 | 1. Withdraw the content 2. Route it through the approval chain 3. Add the case to brand review within 5 business days |

### 5. Integration Points
- Routes external content through FB-5 (CLO).
- Reports NPS to governance-and-operations FB-1 monthly.

### 6. Constraints
- ❌ Publish external content below Harness L5.
- ❌ Sign partnerships without measurable goals.

### 7. Quality Metrics
Harness Level: L3
- NPS: ≥30.
- Releases with approval: 100%.

## FB-10: INTEL (Competitive Intelligence and Sentiment)

### 3. Core Responsibilities

#### 3.1 Intelligence cycle and SITREP
Run the intelligence cycle, maintain the intelligence library, score source reliability, and publish the SITREP. Input: source reports. Output: weekly SITREP citing ≥0.6-rated sources. SLA: ≤7 days apart.

#### 3.2 Sentiment baseline
Track baseline sentiment across monitored channels. Input: channel feeds. Output: baseline with trend flags. SLA: refreshed 24 hours.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CHO_004 | Intelligence source reliability below threshold | A SITREP cites sources averaging below 0.6 reliability, or is more than 7 days overdue | 1. Reclassify the report as unverified 2. Re-acquire from sources rated 0.6 or higher 3. Republish within 48 hours |

### 5. Integration Points
- Delivers SITREPs to governance-and-operations FB-1 and FB-6.
- Sources data from FB-3 (MDL) pipelines.

### 6. Constraints
- ❌ Cite <0.6 sources without an unverified label.
- ❌ Publish SITREPs >7 days apart.

### 7. Quality Metrics
Harness Level: L3
- SITREPs on schedule: 100%.
- Sources ≥0.6: ≥95%.
