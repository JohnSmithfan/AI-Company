# Intelligence Department -- Method Patterns & Detailed Specifications

> Unified v4.0.0 -- Merged from Director + Analysis + Collection + Operations + Security.

---

## SECTION A: DIRECTOR (Strategic Leadership)

### SOP-D01: Strategic Planning Cycle

```
T-7d  Collect inputs from all leads (collection, analysis, security, operations)
T-5d  Synthesize intelligence landscape and gap analysis
T-3d  Draft strategic objectives with resource requirements
T-2d  Review with HQ, incorporate feedback
T-0   Finalize and disseminate to all leads
```

**Input Template per Lead:**

```markdown
## [Lead Name] Input - [Quarter/Period]
### Completed Objectives
- [Obj ID] Description | Status | Outcome
### Emerging Intelligence
- [Category] Summary | Confidence: [H/M/L] | Impact: [H/M/L]
### Resource Requests
- [Resource] Quantity | Justification | Priority
### Blockers & Escalations
- [Blocker] Description | Impact | Recommended Action
```

### SOP-D02: Resource Allocation

```
1. Assess department-wide needs (collection from all leads)
2. Prioritize by mission criticality score (1-10)
3. Validate against budget constraints
4. Allocate: compute tokens, personnel hours, tool licenses
5. Document allocation decisions with justification
6. Monitor utilization weekly, adjust quarterly
```

| Resource | Collection | Analysis | Security | Operations | Total |
|----------|-----------|----------|----------|------------|-------|
| Agent Hours (weekly) | | | | | |
| Compute Tokens | | | | | |
| Tool Licenses | | | | | |
| Budget ($) | | | | | |

### SOP-D03: HQ Executive Report

```markdown
## Intelligence Department Report - [Date]
### Executive Summary
[3-5 bullets on key intelligence developments]
### Threat Landscape
[Current threat level and major developments]
### Key Assessments
1. [Assessment] | Confidence: [H/M/L] | Impact: [H/M/L]
### Operational Metrics
| Metric | Target | Actual | Status |
### Risk Register
| Risk | Likelihood | Impact | Mitigation |
### Recommendations
1. [Action] | Priority | Owner | Deadline
```

### SOP-D04: Escalation Decision Tree

```
Event Detected
├── Active? → YES → Critical (P1) → HQ within 1h
│   └── Containable? → YES → Notify HQ, manage locally
│                     → NO  → HQ takeover, dept support mode
├── Confirmed? → YES → High (P2) → HQ within 4h
└── Potential? → YES → Medium (P3) → Weekly summary
    └── NO → Low (P4) → Monthly report
```

### SOP-D05: STRIDE Assessment Template

```markdown
## STRIDE Assessment: [Decision/Change Name]
### Scenario
[Description]
### Threat Analysis
| STRIDE | Threat | Likelihood (1-5) | Impact (1-5) | Risk Score | Mitigation |
|--------|--------|-------------------|--------------|------------|------------|
| S - Spoofing | | | | | |
| T - Tampering | | | | | |
| R - Repudiation | | | | | |
| I - Info Disclosure | | | | | |
| D - Denial of Service | | | | | |
| E - Privilege Escalation | | | | | |
### Risk Acceptance
- [ ] All risks below threshold (score < 15)
- [ ] High risks mitigated or accepted by HQ
### Sign-off
Analyst: ___ Date: ___ | Director: ___ Date: ___
```

---

## SECTION B: ANALYSIS (Intelligence Assessment)

### SOP-A01: Core Assessment Process

```
1. Receive raw intelligence (validated by Collection)
2. Validate source reliability (check registry rating)
3. Select analytical methodology
4. Apply methodology systematically
5. Correlate with existing intelligence corpus
6. Identify intelligence gaps
7. Produce assessment product
8. Assign confidence level
9. Mark classification
10. Quality review (peer for mid+, senior for junior)
11. Disseminate to authorized consumers
```

**Assessment Product Template:**

```markdown
## Intelligence Assessment: [Title]
**Date**: | **Classification**: | **Confidence**: [H/M/L]
**Analyst**: | **Reviewer**:
### Key Judgments
1. **[Judgment]** | Confidence: | Basis: [Source citations]
### Analytical Methodology
- Primary: [e.g., ACH] | Alternatives: [list]
### Source Basis
| Source | Reliability | Contribution |
### Assumptions
| # | Assumption | Impact if Wrong | Mitigation |
### Alternative Scenarios
1. [Scenario A]: | Likelihood: [H/M/L]
### Intelligence Gaps
- [Gap] | Impact | Recommended collection
### Confidence Justification
[Explanation]
```

### SOP-A02: Analysis of Competing Hypotheses (ACH)

```
1. Identify all possible hypotheses (min 3)
2. List all available evidence
3. Create diagnosticity matrix (CC/C/N/I/II)
4. Refine hypotheses (eliminate inconsistent)
5. Assess remaining against aggregated evidence
6. Draw tentative conclusions
7. Identify sensitive indicators
8. Report with confidence levels
```

| Evidence | Hypothesis A | Hypothesis B | Hypothesis C | Diagnosticity |
|----------|-------------|-------------|-------------|---------------|
| [E1] | CC/C/N/I/II | CC/C/N/I/II | CC/C/N/I/II | H/L |
| [E2] | | | | |

### SOP-A03: Red Team Analysis (Senior)

```
1. Define the assessment to challenge
2. Adopt adversary perspective
3. Identify adversary objectives, capabilities, constraints
4. Develop adversary COAs (min 3)
5. Evaluate each COA against defensive posture
6. Document alternative interpretation
7. Produce divergence report
```

### SOP-A04: Threat Forecasting (Mid+)

```markdown
## Threat Forecast: [Title]
**Period**: [Start] to [End] | **Confidence**: [H/M/L]
### Forecast Statement
[Prediction with time-bound outcome]
### Key Indicators
| Indicator | Current | Trend | Trigger Threshold |
### Historical Analogues
| Event | Similarity | Outcome | Relevance |
### Update Triggers
- [Condition requiring immediate update]
```

### SOP-A05: Analytical Bias Checklist

| Bias | Detection | Corrective Action |
|------|-----------|-------------------|
| Confirmation | Contrary evidence sought? | Mandate Team B analysis |
| Anchoring | Multiple sources weighted? | Source-by-source weighting table |
| Groupthink | Dissent documented? | Assign devil's advocate |
| Mirror Imaging | Adversary perspective check? | Red Team review |
| Availability | Historical data balanced? | 30-day lookback comparison |
| Premature Closure | All hypotheses scored? | Checklist before conclusion |

### SOP-A06: Reporting Schedules

| Report | Frequency | Owner | Audience |
|--------|-----------|-------|----------|
| SITREP | Daily | Lead+Senior | Director, all leads |
| Threat Assessment | Weekly | Senior | Director, consumers |
| Strategic Estimate | Monthly | Lead | HQ, Director |
| Flash Report | As needed | Any tier | All relevant |

---

## SECTION C: COLLECTION (OSINT/HUMINT/SIGINT)

### SOP-C01: Source Validation (All Tiers)

```
1. Identify potential source
2. Assess reliability (A-F scale)
3. Validate access to target information
4. Establish collection protocol
5. Document in source registry
6. Schedule periodic re-assessment
```

**Source Registry Entry:**

```markdown
## Source: [ID] - [Codename]
- Type: [OSINT/HUMINT/SIGINT/TECHINT]
- Domain: [Sector/Region/Topic]
- Rating: [A/B/C/D/F] | Last Verified: | Next Review:
- Access: [Information types] | Method: [auto/manual/hybrid]
- Exposure Risk: [L/M/H]
```

### SOP-C02: Collection Tasking

**Lead Collection Plan:**

```markdown
## Collection Plan - [Period]
### Requirements (from Analysis)
| Req ID | Priority | Gap | Source Match | Method |
### Source Allocation
| Source ID | Tasked For | Expected Yield | Timeline |
### Risk Mitigation
- Source protection, redundancy plan
```

### SOP-C03: OSINT Channels

| Channel | Tool | Data Type | Automation |
|---------|------|-----------|------------|
| Web Search | Search APIs | Public documents | Automated |
| Social Media | Monitoring tools | Posts, connections | Semi-auto |
| Public Records | Gov databases | Regulatory filings | Manual |
| Academic | Research DBs | Papers, citations | Semi-auto |
| Technical | CVE, Shodan | Vulnerability data | Automated |
| Financial | SEC, exchanges | Filings, prices | Automated |

**OSINT Validation Checklist:**

```
□ Source URL accessible and verifiable
□ Publication date confirmed
□ Author/org credibility checked
□ Cross-referenced with ≥1 other source
□ No signs of manipulation
□ Data format standardized
```

### SOP-C04: Source Lifecycle

```
IDENTIFY → ASSESS → DEVELOP → VALIDATE → MAINTAIN → RETIRE
```

### SOP-C05: Collection Quality Scoring

| Dimension | Weight | Criteria |
|-----------|--------|----------|
| Accuracy | 30% | Matches reality |
| Timeliness | 25% | Within required window |
| Completeness | 20% | All required fields |
| Consistency | 15% | No contradictions |
| Relevance | 10% | Matches requirement |

### SOP-C06: Source Reliability Decision Tree

```
Rating A/B → Maintain
Rating C → Re-validate within 72h → Improves? → Yes: Update | No: Add corroboration flag
Rating D → Restricted use, re-validate 24h → Improves? → Yes: Supervised | No: RETIRE
Rating F → IMMEDIATE RETIREMENT, purge from active registry
```

---

## SECTION D: OPERATIONS (Records, Sysadmin, Training)

### SOP-O01: Records Lifecycle (Archivist)

```
1. Receive intelligence product
2. Validate mandatory metadata (classification, source, date, author, type)
3. Assign archive ID: INT-[CLASS]-[YYYY]-[TYPE]-[SEQ]
4. Apply retention schedule
5. Store in appropriate tier
6. Index for searchability
```

| Tier | Classification | Storage | Access Speed | Retention |
|------|---------------|---------|-------------|-----------|
| Hot | UNCLASSIFIED | Primary SSD | <1s | Active |
| Warm | CONFIDENTIAL | Secondary SSD | <5s | 1 year |
| Cold | SECRET | Encrypted | <1h | Per policy |
| Vault | TOP SECRET | Air-gapped | Manual | Permanent |

**Search Query:** `class:[LEVEL] type:[TYPE] date:[FROM]-[TO] keyword:[TERM] entity:[NAME]`

### SOP-O02: System Health (Sysadmin)

**Daily Checks:**

```
□ Collection systems: Online, <200ms response
□ Analysis platforms: Online, compute <80%
□ Storage: Online, disk <85%, backups verified
□ Network: Latency <50ms, packet loss <0.1%
□ Security tools: IDS/EDR/DLP green
```

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| CPU | >70% sustained | >90% | Scale/optimize |
| Memory | >80% | >95% | Restart/upgrade |
| Disk | >80% | >95% | Archive/expand |
| Response | >1s | >5s | Investigate |

### SOP-O03: Patch Priority

| Severity | SLA | Example |
|----------|-----|---------|
| Critical | <24h | Zero-day in production |
| High | <72h | CVSS 9.0+ |
| Medium | <14d | CVSS 7.0-8.9 |
| Low | Next cycle | CVSS <7.0 |

### SOP-O04: Backup & Recovery

```
Hot: Continuous replication | Warm: Daily incr, weekly full
Cold: Weekly incr, monthly full | Vault: Monthly full, off-site
```

| Tier | Test Frequency | RTO |
|------|---------------|-----|
| Hot | Monthly | <1h |
| Warm | Monthly | <4h |
| Cold | Quarterly | <24h |
| Vault | Annually | <72h |

### SOP-O05: Onboarding Curriculum (40h)

| Week | Module | Hours |
|------|--------|-------|
| 1 | Org & Mission | 4 |
| 1 | Security Basics | 4 |
| 1 | Tools & Systems | 6 |
| 1 | Collection 101 | 3 |
| 1 | Analysis 101 | 3 |
| 2 | Domain Track | 12 |
| 2 | Practice Exercises | 6 |
| 2 | Assessment | 2 |

### SOP-O06: Competency Assessment Rubric

| Competency | Junior | Mid | Senior |
|-----------|--------|-----|--------|
| Task completion | >90% w/ review | >95% independent | 100% + mentors |
| Quality | Meets after review | Meets first pass | Exceeds |
| Methodology | Follows guided steps | Selects method | Develops methods |
| Problem solving | Escalates | Resolves w/ guidance | Independent |
| Communication | Clear basic reports | Structured assessments | Executive briefs |

---

## SECTION E: SECURITY (STRIDE, Access, Incident Response)

### SOP-S01: Access Provisioning

```
Request → Validate Clearance → Apply Need-to-Know → Provision Minimum → Log → Schedule Review
```

| Action | Junior | Mid | Senior | Lead |
|--------|--------|-----|--------|------|
| Request access | With review | Self-initiate | Self-initiate | Full |
| Grant UNCLASSIFIED | With review | With review | Direct | Direct |
| Grant CONFIDENTIAL | No | With review | Direct | Direct |
| Grant SECRET | No | No | With review | Direct |
| Grant TOP SECRET | No | No | No | Director only |

### SOP-S02: Incident Response

**Priority Matrix:**

| Priority | Scenario | Containment SLA |
|----------|----------|-----------------|
| P1 | Active breach | <30 min |
| P2 | Confirmed exploitation | <2 h |
| P3 | Potential vulnerability | <8 h |
| P4 | Policy violation | <24 h |

**P1 Response:**

```
1. Isolate affected systems
2. Block attacker access (firewall, credential reset)
3. Preserve evidence (memory dump, disk image, logs)
4. Notify Director + HQ within 5 min
5. Activate incident response team
```

**Post-Incident Report:**

```markdown
## Incident Report: [ID]
### Summary
Severity: | Duration: | Systems: | Data exposure:
### Timeline
| Time | Event |
### Root Cause
[Primary cause + contributing factors]
### Lessons Learned
1. [What went well] 2. [Improvement needed] 3. [Action item]
### Metrics
MTTD: | MTTC: | MTTR:
```

### SOP-S03: STRIDE Threat Modeling

```markdown
## STRIDE Threat Model: [System/Process]
### System Overview
[Data flow diagram or component description]
### Trust Boundaries
[Boundary 1: User → App] [Boundary 2: App → DB] [Boundary 3: Internal → External]
### STRIDE Analysis
| STRIDE | Threat | Component | Mitigation | Gap? | New Control |
|--------|--------|-----------|------------|------|-------------|
| S - Spoofing | | | | | |
| T - Tampering | | | | | |
| R - Repudiation | | | | | |
| I - Info Disclosure | | | | | |
| D - DoS | | | | | |
| E - Priv Escalation | | | | | |
### Risk Scoring
| Threat | Likelihood (1-5) | Impact (1-5) | Score | Priority |
```

### SOP-S04: Classification Decision Tree

```
Disclosure harms national security? → TOP SECRET
Causes serious damage? → SECRET
Causes damage? → CONFIDENTIAL
Causes minor embarrassment? → CONFIDENTIAL
No significant harm → UNCLASSIFIED
```

| Level | Review | Downgrade | Destroy |
|-------|--------|-----------|---------|
| TOP SECRET | 5 years | Age + diminished sensitivity | 25 years / Director |
| SECRET | 10 years | Age + public availability | 25 years |
| CONFIDENTIAL | 10 years | Public availability + no PII | 10 years |

### SOP-S05: Monthly Security Audit

```
□ Access control: Reviewed, dormant disabled
□ Classification: All docs properly marked
□ Encryption: At-rest + in-transit verified
□ Logging: Audit logs → SIEM
□ Patching: Within SLA
□ Incident response: Drill within 90 days
□ Training: Monthly security awareness complete
□ Backup: Recovery tested within 30 days
□ Vendor access: Reviewed and current
```

---

## CROSS-CUTTING: Integration Decision Trees

### Intelligence Cycle

```
COLLECTION → Raw intel received?
  YES → PROCESSING → Source reliability >= B?
    YES → ANALYSIS → Methodology selected?
      YES → Apply → Multiple hypotheses?
        YES → ACH matrix → Confidence HIGH?
          YES → DISSEMINATE
          NO (MED) → Note gaps, proceed
          NO (LOW) → Re-collection → Success?
            YES → Re-analyze
            NO → Escalate to Lead
        NO → Identify gaps, broaden
      NO → Default to Structured Analytic Techniques
    NO → Flag for corroboration
  NO → Return to Collection with gap report
```

### Escalation to HQ

```
P1 Critical → HQ within 1h → Director directly involved
P2 High → HQ within 4h → Director oversight
P3 Medium → Weekly summary → Director informed
P4 Low → Monthly report → Routine channel
```
---

## Extended Reference (Original Source Content)

This section contains additional specifications from the original ai-company-intel v4.1.0 source.

### Intelligence Operations Details

```
Intelligence Cycle:
  | Phase | Activity | Output |
  |-------|----------|--------|
  | Planning | Define intelligence requirements | Collection plan |
  | Collection | Execute collection plan | Raw intelligence data |
  | Processing | Sanitize, normalize, enrich | Structured intelligence |
  | Analysis | Apply models, assess reliability | Intelligence product |
  | Dissemination |Distribute to consumers | Actionable intelligence |
  | Feedback | Consumer feedback, re-assessment | Updated intelligence |

Reliability Scale (adopted from NATO):
  | Level | Description | Action |
  |-------|-------------|--------|
  | 1 -Confirmed | Conclusively verifiable | Use for critical decisions |
  | 2 -Highly Likely | Strong evidence, minor doubt | Use with standard verification |
  | 3 -Possibly True | Plausible but unverified | Require additional collection |
  | 4 -Possibly False | Plausibly negative | Challenge assumptions |
  | 5 -Improbable | Strong evidence against | Reject or re-source |
  | 6 -True Nor False | Contradictory evidence | Resolve contradiction first |
```

### Threat Assessment Supplement

```
Threat Classification:
  | Level | Description | Response |
  |-------|-------------|----------|
  | Critical | Existential threat to operations | Immediate escalation to CEO |
  | High | Severe impact, high probability | Response plan within 1h |
  | Medium | Significant impact, medium probability | Assessment within 4h |
  | Low | Minimal impact, low probability | Monitor, reassess periodically |

Threat Sources:
  - External: Competitors, bad actors, nation-state
  - Internal: Insider threat, unintentional disclosure
  - Environmental: Natural disaster, infrastructure failure
```

---

*Enhanced by AI-Company Skills Rebuilder v3.0*
*Source file: ai-company-intel v4.1.0*

---

## SECTION G: SENTIMENT ANALYSIS TEAM (Social Media Monitoring)

### SOP-SENT01: 5-Agent Pipeline Overview

```
QueryEngine → MediaEngine → InsightEngine → ReportEngine → ForumEngine
  (Search)     (Analyze)      (Mine)          (Generate)     (Discuss)
```

**Pipeline Flow:**
1. QueryEngine collects news/search data via Tavily API
2. MediaEngine performs multimodal analysis via Bocha API
3. InsightEngine mines data from MediaCrawlerDB
4. ReportEngine generates HTML/Markdown reports
5. ForumEngine validates via Qwen3 collaborative discussion

### SOP-SENT02: Agent Specifications

| Agent | Function | APIs/Tools | Pipeline Position |
|-------|----------|------------|-------------------|
| **QueryEngine** | News Searcher | Tavily API | Stage1: Data Collection |
| **MediaEngine** | Multimodal Analyst | Bocha API | Stage2: Content Analysis |
| **InsightEngine** | Insight Miner | MediaCrawlerDB | Stage3: Deep Mining |
| **ReportEngine** | Report Generator | LLM Templates | Stage4: Output |
| **ForumEngine** | Forum Moderator | Qwen3 | Stage5: Validation |

### SOP-SENT03: QueryEngine (News Search)

**Function:** News search via Tavily API
**Tier:** Junior+
**Output:** Structured search results

**Code Template:**
```python
def validate_query_input(query: str) -> dict:
    # Query schema validation
    pass

def sanitize_search_keyword(keyword: str) -> str:
    # Keyword sanitization - no dynamic code execution
    pass

def execute_api_call_safe(url: str, params: dict) -> dict:
    # Sandboxed API execution with timeout + retry
    pass
```

**Error Code:** SENT_001 (Search query failed)

### SOP-SENT04: MediaEngine (Multimodal Analysis)

**Function:** Multimodal analysis via Bocha API
**Tier:** Mid+
**Output:** Analyzed media content with sentiment scores

**Code Template:**
```python
def check_platform_rate_limit(platform: str) -> bool:
    # Per-platform rate limiting - in-memory throttle
    pass

def mask_pii_in_content(content: str) -> str:
    # PII masking for user content
    pass
```

**Error Code:** SENT_002 (Media analysis failed)

### SOP-SENT05: InsightEngine (Data Mining)

**Function:** Data mining from MediaCrawlerDB
**Tier:** Mid+
**Output:** Mined insights and patterns

**Code Template:**
```python
def read_reference_safe(file_path: str) -> str:
    # Safe file reading - path traversal protection
    pass

def build_sentiment_prompt(data: dict) -> str:
    # Sentiment analysis prompt builder - input sanitized
    pass
```

**Error Code:** SENT_003 (Data mining failed)

### SOP-SENT06: ReportEngine (Report Generation)

**Function:** HTML/Markdown report generation
**Tier:** Junior+
**Output:** Formatted analysis reports

**Code Template:**
```python
def format_sentiment_result(data: dict) -> dict:
    # Standardized JSON + AIGC label
    # AI watermark embedded
    pass

def generate_analysis_trace_id() -> str:
    # Audit trace ID generator - stateless, UUID-based
    pass
```

**Error Code:** SENT_004 (Report generation failed)

### SOP-SENT07: ForumEngine (Collaborative Discussion)

**Function:** Collaborative discussion validation via Qwen3
**Tier:** Senior
**Output:** Validated conclusions

**Code Template:**
```python
def retry_with_exponential_backoff(fn: callable, *args) -> any:
    # Fault-tolerant API calls
    # Max 3 retries, jitter
    pass
```

**Error Code:** SENT_005 (Forum discussion failed)

### SOP-SENT08: Shared Prompt Frameworks

**CRISPE (Complex Analysis Tasks):**
```
[Role] {analyst_role_description}
[Result] {desired_analysis_output}
[Input] {query_data + platform_data}
[Steps] {step_by_step_analysis_pipeline}
[Parameters] {constraints_and_thresholds}
[Example] {example_analysis_scenario}
```

**3WEH (Clear Task Delegation):**
```
Who: {agent_role}
What: {analysis_task}
Why: {business_purpose}
How: {output_format_constraints}
```

**Five-Element (Enterprise Compliance):**
```
Role: {agent_role}
Task: {analysis_task}
Context: {project_background}
Format: {output_format}
Constraint: {security_and_quality_constraints}
```

### SOP-SENT09: Compliance Verification

**Security Check Matrix:**

| Risk Category | Prohibited Behavior | Safe Alternative |
|---------------|---------------------|------------------|
| Permission Abuse | Reading ~/.ssh, ~/.aws, system paths | Workspace-scoped file access only |
| Remote Execution | curl/wget to unknown URLs | Whitelisted APIs only (Tavily, Bocha) |
| Dynamic Eval | eval(), exec(), subprocess shell=True | Pre-defined function libraries |
| Data Exfiltration | Sending user data externally unencrypted | Encrypted API channels only |
| Obfuscation | Minified or encoded logic | Clear, readable source |

**AIGC Labeling Requirements:**
- Explicit: "Generated by AI (Sentiment Analysis)" in report header
- Implicit: `ai_generated: true`, provider, timestamp in metadata
- Footer: "This report was generated by AI. Verify critical findings before action."

### SOP-SENT10: Constraints

- Progressive disclosure mandatory: L1 <100 words, L2 <5000 words
- No circular dependencies between agents
- Pipeline order: QueryEngine → MediaEngine → InsightEngine → ReportEngine → ForumEngine
- English-only compiled content; supports multilingual analysis input
- No dynamic code execution in templates
- AIGC labeling on all AI-generated output
- Rate limiting on all external API calls
- PII masking for all user-facing content
- Environment variables for all API credentials (TAVILY_API_KEY, BOCHA_API_KEY, DB config, LLM keys)

---

*Sentiment Analysis Team specifications merged from ai-company-sentiment-analysis-team*
