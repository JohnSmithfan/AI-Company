# Department Index — Large Tier

> Referenced by the root `SKILL.md` (Departments section) and
> `references/execution.md` (two-level routing). Loaded on demand (D2 layer).
> This file is the **authoritative copy** of the `department` enum for the `large` tier:
> the frontmatter inlines the legal values (`auto` + the 18 slugs below, verified by
> gate G6), and this file carries the full routing detail behind them.
>
> **18 departments · 7 domains · 18 function blocks · 19 error-code prefixes (18 department + `SCL_`)**

## Domain: governance（治理与战略）

| Department slug | Prefix | Roles | Functions | D2 | D3 |
|---|---|---|---|---|---|
| `executive-strategy` | CEO_ | CEO, Chief Strategy Officer | Strategic decisions, vision, crisis management, executive communication, OKR set, roadmap, strategic alignment, market entry | [→](departments/executive-strategy.md) | [→](departments/executive-strategy/) |
| `operations-coordination` | COO_ | COO, HQ Coordinator | SLA management, resource scheduling, PDCA process optimization, cross-department coordination, agent routing, message bus, knowledge sync, audit trail | [→](departments/operations-coordination.md) | [→](departments/operations-coordination/) |
| `board-and-branch` | BRD_ | Board Secretary, Branch Manager | Board escalation ladder, authorization matrix, shareholder reporting, headquarters-branch model, branch lifecycle, remote communication, cross-border deployment | [→](departments/board-and-branch.md) | [→](departments/board-and-branch/) |

Domain keywords: strategy, decision, crisis, board, escalation, OKR, roadmap, SLA, scheduling, coordination, branch, headquarters, authorization

## Domain: finance（财务与风险）

| Department slug | Prefix | Roles | Functions | D2 | D3 |
|---|---|---|---|---|---|
| `finance-treasury` | CFO_ | CFO, Treasurer | Budget approval and variance, pricing models, financial analytics, cash position, DSO/DPO targets, capex policy | [→](departments/finance-treasury.md) | [→](departments/finance-treasury/) |
| `risk-audit` | CRO_ | CRO, Chief Auditor | FAIR quantification, circuit breakers, risk thresholds, stage gates, internal audit, financial compliance, evidence retention | [→](departments/risk-audit.md) | [→](departments/risk-audit/) |
| `procurement-billing` | PRC_ | Procurement Lead, Billing Lead | Vendor evaluation, contract cost control, purchase approvals, metered billing, cost allocation, unit economics | [→](departments/procurement-billing.md) | [→](departments/procurement-billing/) |

Domain keywords: budget, spend, pricing, margin, cash, treasury, risk, FAIR, audit, procurement, vendor, contract, invoice, billing, unit economics

## Domain: technology（技术与工程）

| Department slug | Prefix | Roles | Functions | D2 | D3 |
|---|---|---|---|---|---|
| `engineering-tooling` | CTO_ | CTO, Developer Tooling Lead | Architecture decisions, agent creation, three-stage deployment gate, internal tooling, SDKs, developer experience, template library | [→](departments/engineering-tooling.md) | [→](departments/engineering-tooling/) |
| `platform-mlops` | FW_ | Framework Steward, MLOps Lead | Framework standards, CI/CD, Harness L1–L6, ADR process, scaffolding, model health monitoring, A/B testing, observability | [→](departments/platform-mlops.md) | [→](departments/platform-mlops/) |
| `model-data` | MDL_ | Model Manager, Data Engineer | Model registry, calling policy, adapters, model governance and access control, data pipelines, schema management, multi-source fusion | [→](departments/model-data.md) | [→](departments/model-data/) |

Domain keywords: architecture, agent creation, deployment, CI/CD, harness, ADR, scaffolding, MLOps, monitoring, model registry, adapter, data pipeline, schema, fusion

## Domain: security（安全与合规）

| Department slug | Prefix | Roles | Functions | D2 | D3 |
|---|---|---|---|---|---|
| `security-resilience` | CISO_ | CISO, Resilience Lead | STRIDE threat modelling, CVSS scoring, security gates, penetration testing, business continuity, disaster recovery, RTO/RPO | [→](departments/security-resilience.md) | [→](departments/security-resilience/) |
| `legal-privacy` | CLO_ | CLO, Privacy Officer | Legal review, AIGC compliance, DMCA takedown, IP protection, PII handling, GDPR/PIPL/CCPA, data residency | [→](departments/legal-privacy.md) | [→](departments/legal-privacy/) |
| `incident-identity` | IRP_ | Incident Commander, IAM Lead | Security incident lifecycle, forensics, regulatory notification, authentication, authorization, credential management, mTLS, least privilege | [→](departments/incident-identity.md) | [→](departments/incident-identity/) |

Domain keywords: threat model, STRIDE, CVSS, vulnerability, incident, forensics, breach, contract review, AIGC label, privacy, GDPR, residency, identity, credential, access

## Domain: people（人与文化）

| Department slug | Prefix | Roles | Functions | D2 | D3 |
|---|---|---|---|---|---|
| `lifecycle-training` | CHO_ | CHO, Training Lead | Agent onboarding and offboarding, establishment planning, skill-gap analysis, capability matrix, certification | [→](departments/lifecycle-training.md) | [→](departments/lifecycle-training/) |
| `knowledge-ethics` | KNM_ | Knowledge Steward, Ethics Reviewer | Knowledge extraction, learning pipelines, memory governance and consolidation, ethics review, culture audit, whistleblower channel | [→](departments/knowledge-ethics.md) | [→](departments/knowledge-ethics/) |

Domain keywords: onboarding, offboarding, lifecycle, headcount, skill gap, training, certification, knowledge, memory, distillation, ethics, culture, whistleblower

## Domain: growth（增长与情报）

| Department slug | Prefix | Roles | Functions | D2 | D3 |
|---|---|---|---|---|---|
| `marketing-partnerships` | CMO_ | CMO, Partnerships Lead | Brand voice, GTM planning, NPS, content, partnership evaluation, ecosystem and channel management | [→](departments/marketing-partnerships.md) | [→](departments/marketing-partnerships/) |
| `intelligence-sentiment` | INTEL_ | Intelligence Officer, Sentiment Analyst | Six-phase intelligence cycle, intelligence library SOP-L01~L06, SITREP generation, source reliability scoring, sentiment collection and analysis | [→](departments/intelligence-sentiment.md) | [→](departments/intelligence-sentiment/) |

Domain keywords: brand, marketing, GTM, NPS, campaign, partnership, ecosystem, channel, intelligence, SITREP, source reliability, sentiment, public opinion

## Domain: delivery（交付与质量）

| Department slug | Prefix | Roles | Functions | D2 | D3 |
|---|---|---|---|---|---|
| `quality-visualization` | CQO_ | CQO, Information Services Lead | Quality gates, test coverage, DORA metrics, idempotency verification, documentation completeness, chart and Mermaid generation, report templates, location/weather/time services, multi-source fusion | [→](departments/quality-visualization.md) | [→](departments/quality-visualization/) |
| `delivery-scheduling` | PMGR_ | Programme Manager, Localization Lead | Project scheduling, sprint commitment, ticket SLA, customer escalation, task decomposition, translation quality, cultural adaptation, language routing | [→](departments/delivery-scheduling.md) | [→](departments/delivery-scheduling/) |

Domain keywords: quality gate, coverage, DORA, idempotency, documentation, chart, diagram, report template, location, weather, project, sprint, ticket, escalation, translation, localization

* * *

## Routing Rules

### Two-level routing algorithm

```text
1. task text → match frontmatter triggers → skill activated
2. department given explicitly?
   ├─ present in the tables above            → use it directly
   ├─ absent, but present in the Alias Map   → resolve via references/scaling.md#alias-map
   │                                           (may be one-to-many → require clarification)
   └─ absent from both                       → report invalid department
3. department omitted or "auto":
   a. match DOMAIN (7 choices) using the domain keyword lines above
   b. match DEPARTMENT within the domain (≤3 choices) using each D2 §1 Trigger Scenarios
4. read that department's D2 page
   → need depth? read its D3 directory (department-spec.md §8 SOPs)
   → need shared code? read references/method-patterns.md
```

### Disambiguation policy

| Situation | Action |
|---|---|
| Domain ambiguous (2+ domains score equally) | Ask the user to choose a domain; do not guess |
| Department ambiguous within a domain | Ask the user to choose; cite each candidate's §1 Trigger Scenarios |
| Legacy slug resolves one-to-many | Ask the user which successor department applies; report `SCL_003` if unresolvable |
| No domain matches | Fall back to `executive-strategy` (CEO) for triage, and say so explicitly |

### Coverage guarantee

Every one of the 7 domains has **2 or 3** departments; no domain is empty and none exceeds 3,
so step 3b is always a choice among at most three options.

## Function-Block Conservation

| Tier | Departments | Function blocks | Blocks per department |
|---|---:|---:|---|
| large (this package) | 18 | **18** | 1 each |

Each department page carries exactly **one** `## FB-N:` block. The block covers the merged scope
of the two group-tier atomic departments it consolidates — for example `executive-strategy`
covers both `executive-office` and `strategy-planning` functions inside a single FB.

Conservation is verified by `tests/test-method-patterns.py::test_function_block_conservation`
and by upgrade gate G4. See [scaling.md](scaling.md).

## Cross-References

| Resource | Path |
|---|---|
| Error codes (117) | [error-codes.md](error-codes.md) |
| Code templates (authoritative) | [method-patterns.md](method-patterns.md) |
| Template index + prompt frameworks | [method-patterns.md](method-patterns.md) |
| Self-scaling spec + Alias Map | [scaling.md](scaling.md) |
| Execution engine + routing detail | [execution.md](execution.md) |
| Memory system | [memory.md](memory.md) |
| Visualization | [visualization.md](visualization.md) |
| Data integration | [data-integration.md](data-integration.md) |
| External integrations | [integrations.md](integrations.md) |
