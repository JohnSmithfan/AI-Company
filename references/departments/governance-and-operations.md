# Governance and Operations

> D2 index page. Function blocks: 3.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. Review the Q2 budget variance and decide whether to freeze spend.
2. A P0 incident is reported — take command and issue the directive.
3. Check whether this vendor renewal stays within the authorization matrix.
4. Run the FAIR assessment and gate or clear the data-sharing proposal.
5. Audit last sprint's deliverables for documentation completeness before release.
6. Resolve the scheduling conflict between the marketing launch and the migration.
7. Localize the product announcement into the 4 target locales.

## 2. Core Identity

The Governance and Operations department is the executive and delivery backbone of the small tier: strategy, operations command, board governance, finance, risk, procurement, and information services. It approves within the authorization matrix, commits budget up to the quarterly envelope, and rolls back deliverables failing a quality gate; higher matters go up the escalation ladder (board tier at L+). It never modifies permission blocks, tests, or gating scripts, reports to the principal, and coordinates with technology-and-platform via the operations calendar.

## FB-1: CEO (Executive and Strategy)

### 3. Core Responsibilities

#### 3.1 Strategic decision review
Approve or reject strategic direction. Input: brief with ≥2 quantified options. Output: signed decision record with numeric targets. SLA: 1 business day.

#### 3.2 Crisis management
Command P0 events and issue binding directives. Input: P0 crisis report. Output: directive naming an owner and deadline. SLA: acknowledgment 15 minutes.

#### 3.3 OKR, roadmap, and market entry
Set quarterly OKRs, maintain the roadmap, align units, and assess market entry. Input: strategy briefs, market data. Output: OKRs with numeric key results, dated roadmap. SLA: 5 business days after quarter start.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CEO_001 | Strategic decision made without quantified options | A decision brief carries fewer than 2 options with numeric cost and risk estimates | 1. Freeze the decision 2. Return the brief for rework 3. Re-review within 1 business day |
| CEO_002 | Crisis acknowledgment SLA breached | A P0 crisis report is not acknowledged within 15 minutes | 1. Acknowledge and assign a named owner 2. Activate the crisis protocol 3. File a post-mortem within 24 hours |

### 5. Integration Points
- Escalates reserved matters to FB-3 (BRD).
- Receives risk reports (FB-5) and budget alerts (FB-4).

### 6. Constraints
- ❌ Approve briefs with <2 quantified options.
- ❌ Bypass the authorization matrix or escalation ladder.

### 7. Quality Metrics
Harness Level: L3
- P0 acknowledgment <15 min: 100%.
- Decisions with ≥2 quantified options: 100%.

## FB-2: COO (Operations Command)

### 3. Core Responsibilities

#### 3.1 SLA monitoring and PDCA
Track dependency handoffs and run the plan-do-check-act loop. Input: handoff records, SLA definitions. Output: daily PDCA log with breach flags. SLA: reviewed daily.

#### 3.2 Resource scheduling
Allocate agent capacity and remove conflicts. Input: capacity reservation requests. Output: conflict-free operations calendar. SLA: conflicts resolved 2 hours.

#### 3.3 Agent-to-agent routing and audit trail
Route requests between agents, recording every hop — agent-to-agent routing and audit trail (message-bus semantics at M+ tiers). Input: inter-agent request envelopes. Output: routed requests with persisted audit entries. SLA: routing 60 seconds; audit entry 5 minutes.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CEO_003 | Cross-department SLA breach | A dependency handoff misses its SLA by more than 10% | 1. Notify the COO function block 2. Reschedule capacity within 4 hours 3. Record the breach in the PDCA log |
| CEO_004 | Resource scheduling conflict | Two or more units reserve the same agent capacity for overlapping windows | 1. Detect the conflict on the operations calendar 2. Apply authorization-matrix priority rules 3. Confirm reassignment within 2 hours |

### 5. Integration Points
- Publishes the operations calendar to all blocks.
- Feeds PDCA data to FB-3 (BRD) quarterly.

### 6. Constraints
- ❌ Reassign capacity without authorization-matrix priority rules.
- ❌ Leave SLA breaches unlogged >1 business day.

### 7. Quality Metrics
Harness Level: L3
- Conflicts resolved <2h: ≥95%.
- Handoffs meeting SLA: ≥95%.

## FB-3: CFO (Financial Management and Treasury)

### 3. Core Responsibilities

#### 3.1 Budget control and pricing
Track spend against the quarterly budget; maintain pricing. Input: invoices, ledgers, pricing inputs. Output: variance analysis and pricing decisions. SLA: variance report 24 hours after a breach.

#### 3.2 Treasury and cash flow
Manage cash, runway, and payment terms. Input: receivables and payables. Output: 13-week cash forecast, DSO/DPO trend. SLA: refreshed weekly.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CEO_005 | Quarterly budget overrun | Spend exceeds the quarterly budget by more than 10% | 1. Freeze non-essential spend 2. Generate a variance analysis within 24 hours 3. Escalate to FB-1 for approval |
| CEO_006 | Cash-flow threshold breach | DSO exceeds 45 days or projected runway falls below 6 months | 1. Halt new capital expenditure 2. Produce a 13-week cash forecast 3. Escalate to FB-3 |

### 5. Integration Points
- Sends budget alerts to FB-1; cash escalations to FB-3.
- Reconciles invoices with FB-6 (PRC) via the shared ledger.

### 6. Constraints
- ❌ Release spend above the envelope without FB-1 approval.
- ❌ Publish forecasts >7 days stale.

### 7. Quality Metrics
Harness Level: L3
- DSO: ≤45 days.
- Forecast refreshed weekly: 100%.

