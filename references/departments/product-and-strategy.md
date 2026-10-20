# Product and Strategy

> D2 index page. Function blocks: 2.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. A strategic decision brief needs quantified options.
2. A SITREP must be compiled from >=0.6-rated sources.
3. An authorization-matrix violation must be routed for ruling.
4. Market entry or roadmap alignment is on the table.
5. A board escalation needs a shareholder report.

## 2. Core Identity

The Product and Strategy department owns board governance, the authorization matrix, competitive intelligence, and sentiment for the medium tier. It maintains decision authority levels, runs the intelligence cycle, and tracks baseline sentiment; it never self-modifies permissions or tests and reports to the principal.
## FB-2: CPO BRD (Board Governance)

### 3. Core Responsibilities

#### 3.1 Authorization matrix maintenance
Own and update decision authority levels. Input: approval-level change requests. Output: versioned authorization matrix. SLA: published 2 business days after approval.

#### 3.2 Escalation ladder and shareholder reporting
Route reserved matters up the escalation ladder (board tier at L+) and issue shareholder reports. Input: escalation notices, quarterly logs. Output: rulings and the quarterly shareholder report. SLA: ruling 2 business days; report 5 after close.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CPO_002 | Authorization matrix violation | A decision is executed above or outside its defined approval level | 1. Halt the decision 2. Route it to the correct escalation level 3. Log the violation for quarterly board review |

### 5. Integration Points
- Receives escalations from FB-1 (CEO) and FB-5 (CRO).
- Consumes PDCA and finance logs from FB-2/FB-4.

### 6. Constraints
- ❌ Approve matters outside the authorization matrix.
- ❌ Publish shareholder reports without FB-4 sign-off.

### 7. Quality Metrics
Harness Level: L3
- Authorization matrix violations per quarter: 0.
- Shareholder report ≤5d after close: 100%.

## FB-1: CPO INTEL (Competitive Intelligence and Sentiment)

### 3. Core Responsibilities

#### 3.1 Intelligence cycle and SITREP
Run the intelligence cycle, maintain the intelligence library, score source reliability, and publish the SITREP. Input: source reports. Output: weekly SITREP citing ≥0.6-rated sources. SLA: ≤7 days apart.

#### 3.2 Sentiment baseline
Track baseline sentiment across monitored channels. Input: channel feeds. Output: baseline with trend flags. SLA: refreshed 24 hours.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CPO_001 | Intelligence source reliability below threshold | A SITREP cites sources averaging below 0.6 reliability, or is more than 7 days overdue | 1. Reclassify the report as unverified 2. Re-acquire from sources rated 0.6 or higher 3. Republish within 48 hours |

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
