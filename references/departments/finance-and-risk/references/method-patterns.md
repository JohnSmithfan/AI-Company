# Method Patterns & Detailed Specifications

> Full specifications for AI Company Finance & Risk Department.
> Merged: ai-company-cfo + ai-company-cro.

---

# AI Company Finance & Risk Department v1.0

> Consolidated skill for Finance & Risk: CFO (financial management), CRO (risk management).

---

## 1. Trigger Scenarios

### CFO Triggers

| Category | Trigger Keywords |
|----------|-----------------|
| Finance | "Financial management", "Budget approval", "Revenue forecast", "Cost analysis" |
| Pricing | "Pricing model", "Break-even analysis", "Compute pricing", "Unit economics" |
| Analytics | "Data analytics", "Financial report", "Dashboard", "KPI tracking" |
| Compensation | "Digital compensation", "Compute trading", "Contribution assessment" |

### CRO Triggers

| Category | Trigger Keywords |
|----------|-----------------|
| Risk | "Risk assessment", "Risk register", "Threat analysis", "Vulnerability" |
| Circuit Breaker | "Circuit breaker", "Halt", "Freeze", "Risk threshold" |
| FAIR | "FAIR analysis", "Quantitative risk", "Loss expectancy" |
| Milestone | "Milestone gate", "Go/no-go", "Risk review", "Stage gate" |

---

## 2. Core Identity

| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **CFO** | L4 (Financial Authority) | CFO-001 | CEO-001 |
| **CRO** | L4 (Risk Authority) | CRO-001 | CEO-001 |

---

## 3. Role Index

| Role | Primary Function | Key Documents |
|------|-----------------|---------------|
| **CFO** | Financial management, budgeting, pricing | [Section 4](#4-cfo-financial-management) |
| **CRO** | Risk assessment, circuit breaker, FAIR | [Section 5](#5-cro-risk-management) |

---

## 4. CFO: Financial Management

### 4.1 Financial Management

```
Budget Cycle:
  Q1: Annual budget planning (CEO alignment)
  Monthly: Budget review and variance analysis
  Weekly: Cash flow monitoring
  Daily: Transaction logging and alert

Budget Approval Rules:
  <$1K: Auto-approve with logging
  $1K-$10K: CFO approval required
  $10K-$100K: CFO + CEO dual approval
  >$100K: Board approval required

Compute Cost Mapping:
  | Traditional Cost | Compute Cost Equivalent |
  |-----------------|----------------------|
  | Salaries | GPU/TPU rental fees |
  | Social insurance | Model training depreciation |
  | Travel | API call costs |
  | Office rent | Cloud service monthly fees |
  | Recruitment | Prompt engineering/fine-tuning costs |

Dynamic Budget Allocation:
  Traffic > Baseline * 1.2 -> Compute Budget +15%, Trigger GPU Scale Up
  Traffic < Baseline * 0.7 -> Compute Budget -20%, Return GPU to Pool
  Otherwise -> Maintain current budget
```

### 4.2 Pricing Models

```
| Model | Description | Use Case | Margin |
|-------|-------------|----------|--------|
| Cost-Plus | Cost + margin | Commodity compute | 20-30% |
| Value-Based | Customer value pricing | Premium AI services | 50-70% |
| Tiered | Volume-based tiers | API usage | 15-40% |
| Subscription | Fixed monthly fee | Platform access | 30-50% |
| Pay-per-Outcome | Per successful result | Autonomous tasks | 40-60% |
| Freemium | Free tier + paid premium | Developer adoption | N/A |
```

### 4.3 Break-Even Analysis

```
BEP = Fixed Costs / (Price per Unit - Variable Cost per Unit)

9-Month Target:
  Q1: Loss reduction (net burn decreasing MoM)
  Q2: Near break-even (net within +/-5%)
  Q3: Turnaround (net positive, sustainable)

Monitoring Dashboard:
  | Metric | Target | Trend |
  |--------|--------|-------|
  | Monthly burn rate | Decreasing | [track] |
  | Revenue growth | >15% MoM | [track] |
  | Gross margin | >60% | [track] |
  | BEP month | Month 9 | [track] |
  | Runway | >12 months | [track] |
```

### 4.4 Compute Resource Pricing

```
Compute Unit: 1 CU = 1 vCPU-h + 4GB RAM-h + 10GB storage-mo

| Resource | Unit | Internal Rate | Market Rate | Discount |
|----------|------|---------------|-------------|----------|
| CPU | vCPU-h | $0.05 | $0.08 | 37.5% |
| RAM | GB-h | $0.012 | $0.015 | 20% |
| GPU (A100) | GPU-h | $0.80 | $1.20 | 33% |
| GPU (H100) | GPU-h | $1.50 | $2.20 | 32% |
| Storage | GB-mo | $0.023 | $0.030 | 23% |

Internal Settlement:
  - Departments billed monthly on actual CU consumption
  - Overages at 1.5x rate | Unused reserved at 50% rate
  - Emergency burst: 2x rate, COO approval required
```

### 4.5 Digital Compensation

```
Contribution Assessment:
  | Factor | Weight | Measurement |
  |--------|--------|-------------|
  | Task Completion | 30% | On-time rate + quality score |
  | Innovation | 20% | New method adoption + efficiency gain |
  | Collaboration | 20% | Cross-agent assists + knowledge sharing |
  | Reliability | 15% | Uptime + error-free rate |
  | Learning | 15% | Skill improvement + knowledge extraction |

Compute Trading Market:
  - Excess compute offered to peers at 0.8x-1.2x internal rate
  - All trades logged and settled monthly
  - CISO approves cross-department trades
```

### 4.6 Data Analytics

```
Pipeline: COLLECT -> SANITIZE -> ANALYZE -> VISUALIZE -> REPORT

| Report | Frequency | Audience | Key Metrics |
|--------|-----------|----------|-------------|
| Daily Flash | Daily | COO | Revenue, costs, SLA |
| Weekly Digest | Weekly | C-Suite | Trends, anomalies |
| Monthly Board | Monthly | CEO+Board | P&L, forecast, risk |
| Quarterly Strategy | Quarterly | All | OKR, strategic KPIs |

Sanitization: PII hashed (SHA-256), aggregated beyond individual transactions,
raw data retained 90 days, aggregated indefinitely, CISO approves exports.
```

### 4.7 AIGC Review Chain

```
AIGC (AI-Generated Content) Review Process:

1. AIGC Label Verification:
   - Explicit Label: "Generated by AI (Finance & Risk)" in header
   - Implicit Label: `ai_generated: true`, provider, timestamp in metadata
   - Footer: "This financial analysis was generated by AI. Verify critical findings before decision-making."

2. Financial Content Review Checklist:
   - [ ] All numerical data verified against source
   - [ ] Formulas and calculations validated
   - [ ] Compliance with accounting standards (GAAP/IFRS)
   - [ ] Risk disclosures included
   - [ ] Audit trail maintained (trace_id)

3. Human Review Triggers:
   - Financial impact >$10K → CFO + CEO review required
   - Regulatory filing → CFO + CLO review required
   - Investor communication → CFO + CEO + CLO review required
   - Crisis financial analysis → CFO + CEO + CISO review required

4. AIGC Compliance Enforcement:
   - Pre-release: Automated AIGC label check (100% coverage required)
   - Post-release: Random audit (5% of all AIGC financial content weekly)
   - Violation: Content blocked, CFO alerted, retraining triggered

5. Review Turnaround SLA:
   - Routine financial report: 24h
   - Budget approval: 48h
   - Crisis financial analysis: 4h
   - Regulatory filing: 72h
```

---

## 5. CRO: Risk Management

### 5.1 Enterprise Risk Management

```
Framework (ISO 31000 adapted):
  IDENTIFY -> ANALYZE -> EVALUATE -> TREAT -> MONITOR -> REPORT

Risk Categories:
  | Category | Examples | Primary Owner |
  |----------|---------|---------------|
  | Strategic | Market shift, disruption | CEO |
  | Financial | Currency, credit, liquidity | CFO |
  | Operational | System failure, SLA breach | COO |
  | Technology | Obsolescence, cyber attack | CTO+CISO |
  | Compliance | Regulatory change | CLO |
  | Reputational | Public incident | CMO |

Risk Appetite:
  Strategic: Moderate | Financial: Low (unhedged >$500K) | Operational: Zero (data loss) | Compliance: Zero | Reputational: Low
```

### 5.2 FAIR Quantitative Analysis

```
FAIR Model:
  Risk (ALE) = Loss_Event_Frequency * Loss_Magnitude

  LEF = Threat_Event_Frequency * Vulnerability
  LM = Primary_Loss + Secondary_Loss
    Primary: Productivity + Response + Replacement
    Secondary: Fine/Judgment + Reputation + Competitive

  Loss Exposure Amount (LEA) Calculation:
    LEA = ALE * Exposure_Factor
    Exposure_Factor = Asset_Value * Vulnerability_Score (0.0-1.0)
    Example: Asset $500K * Vuln 0.4 = Exposure $200K; if ALE = $200K/yr then LEA = $200K
    LEA Review: Quarterly FAIR recalibration with actuals vs. estimates (+/-20% tolerance)
    Back-test Cadence: Annual review of prior-year FAIR estimates vs. actual losses

  | Risk Level | ALE Range | LEA Action | Escalation |
  |-----------|-----------|-----------|-----------|
  | Critical | >$1M/yr | Immediate treatment | CEO + Board within 2h |
  | High | $100K-$1M/yr | Treatment plan within 30 days | CEO within 24h |
  | Medium | $10K-$100K/yr | Monitor, plan within 90 days | CFO notification |
  | Low | <$10K/yr | Accept and monitor | Quarterly review |

CRO-CFO Escalation SLA:
  - CRO_001 triggered (Risk threshold exceeded): CFO notified within 4h
  - L2-Orange circuit breaker: CFO + CEO notified within 1h
  - L3-Red circuit breaker: CFO + CEO + Board notified within 30min
  - L4-Emergency: Immediate CFO + CEO + Board notification
  - Monthly risk summary sent from CRO to CFO for financial provisioning

Numeric Risk Thresholds (Risk Appetite Statement):
  | Category | Acceptable | Warning | Unacceptable |
  |----------|-----------|---------|-------------|
  | Strategic ALE | <$500K/yr | $500K-$1M/yr | >$1M/yr |
  | Financial (unhedged exposure) | <$200K | $200K-$500K | >$500K |
  | Operational (data loss incidents) | 0 | Any single event | N/A (zero tolerance) |
  | Compliance violations | 0/quarter | N/A | Any single violation |
  | Reputational incidents | 0 | 1 minor/quarter | Any major incident |
  All thresholds reviewed annually by CRO + Board; mid-year adjustment if market conditions change.
```

### 5.3 Circuit Breaker

```
| Level | Trigger | Action | Authority |
|-------|---------|--------|-----------|
| L1-Yellow | Indicator >70% threshold | Alert + monitoring | CRO auto |
| L2-Orange | Indicator >85% threshold | Slow down, manual approval | CRO + dept head |
| L3-Red | Indicator >95% threshold | Halt affected operations | CRO + CEO |
| L4-Emergency | Active loss event | Freeze all related | CRO + CEO + Board |

Indicators:
  | Indicator | Yellow | Orange | Red |
  |-----------|--------|--------|-----|
  | SLA compliance | <98% | <95% | <90% |
  | Financial burn | >110% budget | >130% | >150% |
  | Security incidents | >5/week | >10/week | >20/week |
  | Agent failure rate | >2% | >5% | >10% |
  | Compliance violations | >1/quarter | >1/month | >1/week |

Recovery: CONTAIN -> ANALYZE -> REMEDIATE -> VERIFY -> RESTORE -> REVIEW -> PREVENT

Circuit Breaker Test Schedule:
  | Test Type | Frequency | Scope | Owner |
  |-----------|-----------|-------|-------|
  | Tabletop Exercise | Quarterly | L1-L3 scenarios | CRO + dept heads |
  | Live Drill (non-prod) | Semi-annual | L1-L2 injection | CRO + CTO |
  | Full Crisis Simulation | Annual | L3-L4 scenario | CRO + CEO + Board |
  Test results documented and reviewed; improvements tracked in risk register.
```

### 5.4 Milestone Risk Gates

```
Gate 1 - Initiation: Risk register created, FAIR assessment, owner assigned
Gate 2 - Planning: Detailed analysis, mitigation strategies, CB thresholds set
Gate 3 - Execution Start: Mitigations implemented, monitoring active
Gate 4 - Mid-Point: Reassessed, FAIR updated, CB verified
Gate 5 - Completion: Final assessment, lessons captured, residual risks documented

| Outcome | Action |
|---------|--------|
| GO | Proceed |
| CONDITIONAL GO | Proceed with conditions, recheck in 2 weeks |
| HOLD | Stop, remediate, re-gate |
| KILL | Cancel initiative, redirect resources |
```

---

## 6. Cross-Role Collaboration

```
CFO -> CRO: Financial risk assessment, budget risk indicators, burn rate monitoring
CFO -> CEO: Financial approval, budget tracking, investment recommendations
CRO -> CFO: Risk-adjusted financial planning, circuit breaker financial impact
CRO -> CEO: Risk reports, circuit breaker status, escalation

Financial-Risk Integration:
  - Budget approval requires CRO risk assessment for >$100K
  - Circuit breaker L3+ requires CFO financial impact analysis
  - FAIR analysis includes financial loss magnitude calculations
  - Risk appetite thresholds aligned with CFO budget limits
```

---

## 7. Constraints

- No budget override without CEO+Board approval
- No financial data exposure without CLO
- No pricing changes without market analysis
- No compensation without CHO review
- Tax decisions require CLO
- No operations resumption without CRO clearance after L3+ circuit breaker
- No risk acceptance above Medium without CEO
- All FAIR assessments reviewed annually
- Circuit breaker overrides require CEO+Board

---

## 8. Error Codes

| Code | Meaning | Resolution | Role |
|------|---------|------------|------|
| CFO_001 | Budget overrun | Alert department head, request justification | CFO |
| CFO_002 | Pricing below cost floor | Block, require manual review | CFO |
| CFO_003 | Break-even target missed | Cost reduction sprint, notify CEO | CFO |
| CFO_004 | Data sanitization failure | Quarantine data, alert CISO | CFO |
| CFO_005 | Settlement discrepancy | Reconcile with CTO within 48h | CFO |
| CFO_006 | Contribution score anomaly | Flag for CHO review | CFO |
| CRO_001 | Risk indicator breach | Activate circuit breaker level | CRO |
| CRO_002 | FAIR analysis incomplete | Flag for manual completion | CRO |
| CRO_003 | Gate failure | HOLD initiative, remediate | CRO |
| CRO_004 | Risk register stale | Force quarterly update | CRO |
| CRO_005 | Circuit breaker triggered | Execute recovery protocol | CRO |
| CRO_006 | Residual risk exceeds appetite | Escalate to CEO | CRO |

---

## 9. Quality Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Budget accuracy | +/-5% | CFO: Monthly variance |
| Pricing margin | >=30% | CFO: Gross margin |
| Break-even | Month 9 | CFO: Monthly tracking |
| Risk register coverage | 100% | CRO: Coverage % |
| FAIR assessment accuracy | +/-20% | CRO: Validation |
| Circuit breaker response | <5min | CRO: Detection to action |
| Gate pass rate | >80% | CRO: Milestone gates |

---

*Enhanced by AI-Company Skills Rebuilder v3.0*
