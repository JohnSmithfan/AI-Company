# Customer and Partnerships

> D2 index page. Function blocks: 2.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. A vendor invoice deviates by more than 5%.
2. External content needs approval before release.
3. A partner agreement needs measurable goals.
4. A procurement contract needs cost scoring.
5. A billing or unit-economics report is due.

## 2. Core Identity

The Customer and Partnerships department owns procurement, billing, brand and partnerships, and external-content approval for the medium tier. It scores vendors, allocates costs, governs partnerships, and gates external content at Harness L5; it never self-modifies permissions or tests and reports to the principal.
## FB-1: CCO PRC (Procurement and Billing)

### 3. Core Responsibilities

#### 3.1 Vendor evaluation and contracts
Score vendors and manage contract costs. Input: vendor proposals, evaluation criteria. Output: scored vendor matrix and contract terms. SLA: evaluation 5 business days.

#### 3.2 Billing and unit economics
Allocate costs and track unit economics. Input: usage meters, invoices. Output: per-unit cost report. SLA: 3 business days after month close.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CCO_001 | Vendor cost deviation | A final vendor invoice exceeds the contracted amount by more than 5% | 1. Suspend payments to the vendor 2. Request a written reconciliation 3. Enforce the penalty clause within 5 business days |

### 5. Integration Points
- Reconciles invoices with FB-4 (CFO).
- Sources tooling and model capacity from technology-and-platform.

### 6. Constraints
- ❌ Pay invoices deviating >5% without reconciliation.
- ❌ Onboard vendors scoring below 0.7.

### 7. Quality Metrics
Harness Level: L3
- Reconciliation <5 business days: ≥95%.
- Unit-economics report monthly: 100%.

## FB-2: CCO CMO (Marketing and Partnerships)

### 3. Core Responsibilities

#### 3.1 Brand, GTM, and NPS
Own brand standards, go-to-market, and NPS tracking. Input: campaign plans, surveys. Output: approved campaigns and NPS trend. SLA: approval 2 business days.

#### 3.2 Partnerships and ecosystem
Manage partners, channels, alliances. Input: partner proposals, terms. Output: agreements with measurable goals. SLA: 5 business days.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CCO_002 | External content released without approval | Content leaves the organization without L5 harness or CMO sign-off, or NPS falls below 30 | 1. Withdraw the content 2. Route it through the approval chain 3. Add the case to brand review within 5 business days |

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

