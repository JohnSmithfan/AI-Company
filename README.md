# AI-Company

> Unified AI Company Skill — 16 departments consolidated into one.
> Empowering all-AI-employee technology companies with complete governance, engineering, and operations capabilities.

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.5-blue.svg)](_meta.json)
[![Maturity: STABLE](https://img.shields.io/badge/maturity-STABLE-green.svg)](https://github.com/ai-company/ai-company)

---

## Overview

**AI-Company** is a unified skill that consolidates 16 previously separate department skills into a single, cohesive framework. It provides complete operational capabilities for AI-driven technology companies — from strategic governance and financial management to security compliance and localization.

This skill is designed for the [OpenClaw](https://clawhub.ai/) [QClaw](https://qclaw.qq.com/) [WorkBuddy](https://www.codebuddy.cn/) platform and follows the AI Company Governance Framework.

## Features

- **16 Departments in One** — All AI company functions under a single skill
- **10 Core Code Templates** — Reusable implementation patterns
- **3 Prompt Frameworks** — CRISPE / 3WEH / Five-Element
- **L1–L6 Harness Engineering** — Progressive constraint layers
- **CI/CD Pipeline** — Automated build, test, and deploy
- **ADR Process** — Architecture Decision Records
- **AIGC Compliance** — AI-generated content labeling
- **5-Layer Security Gates** — VirusTotal / ClawHub verification for auto-updates
- **Progressive Disclosure** — Context-aware information delivery

## Department Index

| Department | Roles | Reference |
|---|---|---|
| Governance & Strategy | CEO, COO, HQ | [governance-and-strategy.md](references/departments/governance-and-strategy.md) |
| Finance & Risk | CFO, CRO | [finance-and-risk.md](references/departments/finance-and-risk.md) |
| Technology & Engineering | CTO | [technology-and-engineering.md](references/departments/technology-and-engineering.md) |
| Platform & Infrastructure | Framework | [platform-and-infrastructure.md](references/departments/platform-and-infrastructure.md) |
| Security & Compliance | CISO, CLO | [security-and-compliance.md](references/departments/security-and-compliance.md) |
| People & Culture | CHO | [people-and-culture.md](references/departments/people-and-culture.md) |
| Marketing & Partnerships | CMO | [marketing-and-partnerships.md](references/departments/marketing-and-partnerships.md) |
| Quality & Operations | CQO, PMGR | [quality-and-operations.md](references/departments/quality-and-operations.md) |
| Intelligence | Intel | [intelligence.md](references/departments/intelligence.md) |
| Information Services | Information | [information.md](references/departments/information.md) |
| Translation & Localization | Translator | [translation-and-localization.md](references/departments/translation-and-localization.md) |

## Project Structure

```
ai-company/
├── SKILL.md                          # Skill manifest & quick reference
├── _meta.json                        # Metadata (slug, version, owner)
├── LICENSE                           # GNU GPL v3 License
├── README.md                         # This file
├── prompts/                          # Copy-paste ready prompts
│   ├── 01-implement-method.md
│   ├── 02-robustness-checks.md
│   ├── 03-test-cases.md
│   ├── 04-documentation.md
│   └── 05-workflow-execution.md
└── references/                       # Detailed specifications
    ├── method-patterns.md            # Code templates & prompt frameworks
    ├── execution.md                  # Execution workflow
    ├── integrations.md               # External integrations
    ├── memory.md                     # Memory & knowledge management
    ├── visualization.md              # Visualization patterns
    ├── data-integration.md           # Data integration patterns
    └── departments/                  # Department-specific references
        ├── governance-and-strategy.md
        ├── finance-and-risk.md
        ├── technology-and-engineering.md
        ├── platform-and-infrastructure.md
        ├── security-and-compliance.md
        ├── people-and-culture.md
        ├── marketing-and-partnerships.md
        ├── quality-and-operations.md
        ├── intelligence.md
        ├── information.md
        └── translation-and-localization.md
```

## Installation

### Via ClawHub (Recommended)

Install directly from the WorkBuddy skill marketplace.

### Manual

1. Clone this repository:
   ```bash
   git clone https://github.com/JohnSmithfan/AI-Company.git
   ```
2. Copy the `ai-company/` directory to your skills folder:
   ```bash
   # For user-level skills
   cp -r ai-company ~/.workbuddy/skills/
   # For project-level skills
   cp -r ai-company your-project/.workbuddy/skills/
   ```

## Usage

Once installed, the skill activates automatically when AI company operations are needed. You can also invoke it explicitly:

- **Department tasks**: Specify a department via the `department` parameter (`governance-and-strategy`, `finance-and-risk`, `technology-and-engineering`, etc.)
- **Auto-routing**: Set `department: auto` to let the skill determine the appropriate department

### Example Prompts

- "Review the Q2 financial budget and assess risk exposure"
- "Create a new agent following L1-L6 harness constraints"
- "Run a STRIDE threat model on the authentication service"
- "Translate the marketing copy to Japanese with cultural adaptation"

## Auto-Update

This skill supports automatic updates from ClawHub with 5-layer security verification:

| Setting | Value |
|---|---|
| Schedule | Weekly Sunday 02:00 UTC |
| Backup Retention | 10 versions / 30 days |

**Security Gates**: Version Check → Backup Gate → Download Gate → Frontmatter Gate → Danger Pattern Gate

**Manual Update**:
```powershell
pwsh -File "C:\Users\Admin\WorkBuddy\Claw\.workbuddy\scripts\ai-company-auto-update.ps1" -Force
```

## Changelog

| Version | Date | Changes |
|---|---|---|
| 1.1.0 | 2026-04-29 | Intel: Added Intelligence Library (SOP-L01~L06) with auto-triggered library setup on first collection request; SOP-L06 triggers on any intelligence collection request; Added INTEL_006~INTEL_010 error codes |
| 1.0.3 | 2026-04-28 | Security: Scoped file permissions (P0 CISO fix); Finance: Capex policy, DSO/DPO targets (P1); Risk: FAIR thresholds & LEA calculation (P1); CTO: 3-stage deployment gate (P1); CQO: 85% test coverage threshold (P1); CEO: Board escalation ladder (P2); COO: OHS alerting + OKR integration (P2); CLO: DMCA takedown workflow (P2); Intel: 6-phase intelligence cycle (P2); CPO: Semver enforcement (P2) |
| 1.0.2 | 2026-04-27 | Added auto-update: weekly automation, PowerShell script with 5-layer security gates, backup/rollback, publisher allowlist |
| 1.0.1 | 2026-04-27 | CEO review: all 7 reference modules verified and rebuilt; added visualization, integrations, memory, data-integration, execution references |
| 1.0.0 | 2026-04-27 | Initial release to ClawHub as unified AI Company skill; 16 departments consolidated |

## Consolidated From

This unified skill replaces the following 16 individual skills:

| Legacy Skill | Version |
|---|---|
| ai-company-ceo | 3.0.0 |
| ai-company-coo | 3.0.0 |
| ai-company-hq | 3.0.0 |
| ai-company-cfo | 3.0.0 |
| ai-company-cro | 3.0.0 |
| ai-company-cto | 3.0.0 |
| ai-company-framework | 4.0.0 |
| ai-company-ciso | 3.0.0 |
| ai-company-clo | 3.0.0 |
| ai-company-cho | 3.0.0 |
| ai-company-cmo | 3.0.0 |
| ai-company-cqo | 3.0.0 |
| ai-company-pmgr | 3.0.0 |
| ai-company-intel | 4.1.0 |
| ai-company-information | 2.0.0 |
| ai-company-translator | 3.0.0 |

---

## Design Philosophy & Technical Roadmap

### 1. Design Philosophy

#### 1.1 Unified Monolith-First Architecture

AI-Company evolved from **16 independent department skills** (each published separately on ClawHub) into a single unified skill. This consolidation was driven by three core problems with the fragmented approach:

- **Context Fragmentation**: Agents lacked cross-department awareness — the CFO couldn't natively coordinate with CISO on risk assessments
- **Dependency Hell**: Inter-skill dependencies formed an undocumented DAG, making version management unreliable
- **Schema Drift**: Without centralized governance, frontmatter schemas diverged across skills

The unified monolith preserves internal modularity (each department remains a self-contained specification in `references/departments/`) while providing a single entry point, shared memory system, and centralized governance layer.

**Key Insight**: We chose **monolith-first, extract-later** — the unified skill can always be decomposed back into micro-skills if specific departments need independent versioning cadences. This reversibility is by design.

#### 1.2 Progressive Disclosure Architecture

Context windows are the most expensive resource in LLM operations. AI-Company employs a 3-layer progressive disclosure strategy to minimize token consumption while maximizing capability:

| Layer | Content | Token Budget | Loading Strategy |
|-------|---------|-------------|-----------------|
| L1 — Metadata | Role, task, goal, department routing | <100 words | Always loaded (in SKILL.md frontmatter) |
| L2 — Body | Steps, format, constraints, error codes | <5,000 words | Loaded on department trigger match |
| L3 — Reference | Examples, context, full schemas, SOPs | Unlimited | Loaded on-demand via explicit reference read |

This means a simple financial query loads only ~500 tokens of context (L1 routing + L2 finance snippet), while a complex cross-department crisis response progressively loads the full governance, security, and operations specifications as needed.

#### 1.3 Agent-as-Employee Metaphor

The entire framework models AI agents as employees in a real company hierarchy:

```
Board of Directors
    └── CEO (Strategic Decisions)
        ├── COO (Operations, SLA, Resources)
        │   └── PMGR (Project Management)
        ├── CFO (Financial Management)
        │   └── CRO (Risk & Circuit Breakers)
        ├── CTO (Technology, Engineering, Agents)
        │   └── Framework (Standards, CI/CD, L1-L6 Harness)
        ├── CISO (Security, Threat Modeling)
        │   └── CLO (Legal, Compliance, AIGC)
        ├── CHO (Agent Lifecycle, Knowledge)
        ├── CMO (Marketing, Partnerships, Discovery)
        ├── CQO (Quality Gates, Testing)
        ├── Intel (Intelligence, Sentiment Analysis)
        └── Information (Data Services, Localization)
```

This metaphor isn't decorative — it defines **authority boundaries** (CEO_002: "Insufficient authority"), **escalation paths** (5-step Board escalation ladder), and **conflict resolution protocols** (HQ-mediated arbitration). Each department has codified responsibilities, error codes, and SLA commitments that mirror real enterprise governance.

#### 1.4 Security-by-Construction

Every design decision starts from a security-first posture. Rather than bolting security on after the fact, security constraints are embedded in the fundamental building blocks:

- **10 Core Code Templates**: Every template is audited for zero dynamic code execution, zero network calls, zero sensitive path access
- **5-Layer Security Gates** (auto-update): Version Check → Backup → Download → Frontmatter Validation → Danger Pattern Scan
- **VirusTotal/ClawHub Compliance**: NVDB advisory reports ~11.94% of ClawHub skills as malicious — this skill proactively avoids all flagged patterns
- **PII Masking by Default**: Template #9 (`mask_sensitive_data`) is mandatory in all output pipelines
- **AIGC Labeling**: All AI-generated output carries explicit, implicit, and watermark-based identification

#### 1.5 L1–L6 Harness Engineering

The harness system represents a progressive constraint framework for skill creation, from minimal-viable to production-hardened:

| Level | Name | Constraints | Use Case |
|-------|------|-------------|----------|
| L1 | Skeleton | Basic schema, frontmatter | Prototyping |
| L2 | Functional | Input validation, output formatting | Internal tools |
| L3 | Robust | Error handling, retry logic, idempotency | Department tools |
| L4 | Resilient | Circuit breakers, rate limiting, monitoring | Production services |
| L5 | Compliant | AIGC labels, PII masking, audit trails | Customer-facing |
| L6 | Certified | STRIDE model, CVSS scoring, CISO sign-off | Critical infrastructure |

This framework ensures that skill maturity is objectively measurable and incrementally achievable.

### 2. Technical Architecture

#### 2.1 System Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                       User Layer                             │
│    Natural Language → Trigger Matching → Department Routing  │
└──────────────────────────┬───────────────────────────────────┘
                           │
┌──────────────────────────┴───────────────────────────────────┐
│                    SKILL.md (Entry Point)                    │
│  Frontmatter: metadata, triggers, interface, permissions     │
│  Quick Reference: department index, shared resources         │
└──────────────────────────┬───────────────────────────────────┘
                           │
┌──────────────────────────┴───────────────────────────────────┐
│                  Routing & Orchestration                     │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │ Auto-Route  │  │ Execution    │  │ CEO Command        │   │
│  │ (dept: auto)│  │ Engine       │  │ Center             │   │
│  └──────┬──────┘  │ (4 modes)    │  │ (Priority Queue +  │   │
│         │         └──────┬───────┘  │  Resource Alloc +  │   │
│         │                │          │  Monitoring)       │   │
│  ┌──────┴────────────────┴──────────┴────────────────────┐   │
│  │                 HQ Message Bus                        │   │
│  │        (Event-driven inter-department coordination)   │   │
│  └────────────────────────┬──────────────────────────────┘   │
└───────────────────────────┼──────────────────────────────────┘
                            │
┌───────────────────────────┴──────────────────────────────────┐
│                    Department Layer                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐     │
│  │Governance│ │Finance   │ │Technology│ │Security      │     │
│  │&Strategy │ │&Risk     │ │&Eng      │ │&Compliance   │     │
│  ├──────────┤ ├──────────┤ ├──────────┤ ├──────────────┤     │
│  │People    │ │Marketing │ │Quality   │ │Intelligence  │     │
│  │&Culture  │ │&Partners │ │&Ops      │ │(+ Sentiment) │     │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────┘     │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────┴───────────────────────────────────┐
│                  Shared Infrastructure                        │
│  ┌──────────┐ ┌────────────┐ ┌────────────┐ ┌──────────────┐  │
│  │ Memory   │ │Execution   │ │Integrations│ │Visualization │  │
│  │ System   │ │ Subsystem  │ │ Module     │ │ Module       │  │
│  │ (5 types)│ │ (4 modes   │ │ (MCP +     │ │ (Chart.js +  │  │
│  │          │ │ 4 triggers │ │ Webhook +  │ │  Mermaid)    │  │
│  │          │ │ 8 workflows│ │ REST)      │ │              │  │
│  └──────────┘ └────────────┘ └────────────┘ └──────────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌────────────────────────────┐     │
│  │ Method   │ │ Prompt   │ │ Auto-Update                │     │
│  │ Patterns │ │Templates │ │ (5-layer security gates)   │     │
│  │ (10 tpl) │ │ (CRISPE/ │ │                            │     │
│  │          │ │  3WEH/   │ │                            │     │
│  │          │ │ 5-Elem)  │ │                            │     │
│  └──────────┘ └──────────┘ └────────────────────────────┘     │
└───────────────────────────────────────────────────────────────┘
```

#### 2.2 Execution Engine

The execution subsystem defines **4 execution modes** and **4 trigger types**:

**Execution Modes:**
- **Auto**: Full autonomy — for low-risk, well-understood, previously-successful tasks (P3–P4)
- **Approve**: Pre-execution authorization — for tasks with external impact (P0–P2), with tiered approval authority matrix
- **Review**: Post-execution quality gate — for output-quality-sensitive tasks, with per-output-type review criteria
- **Hybrid**: Per-phase mode selection — for complex multi-phase workflows mixing different autonomy levels

**Trigger Types:**
- **Schedule**: Cron-based deterministic execution with overlap policies and maintenance windows
- **Event**: Near-real-time reactive execution via HQ Message Bus with debounce and correlation
- **Webhook**: HTTP callback integration with HMAC-SHA256 signature verification and rate limiting
- **Manual**: User-initiated ad-hoc tasks with authentication and audit logging

**Error Recovery Stack:**
- Operation level: Retry with exponential backoff (configurable per error type)
- Transaction level: Rollback procedures (automatic/semi-automatic/manual with compensating actions)
- Service level: Circuit breaker pattern (CLOSED → OPEN → HALF_OPEN state machine with per-department defaults)

#### 2.3 Memory System

The memory architecture provides 5 distinct memory types organized by scope and volatility:

| Type | Scope | Volatility | Owner | Retention |
|------|-------|-----------|-------|-----------|
| Profile | Per-agent | Low | CHO | Agent lifetime |
| Session | Per-conversation | High | HQ | Session duration |
| Knowledge | Organization-wide | Low | CQO | Until superseded |
| Learning | Per-agent + shared | Medium | CTO + CHO | Until disproven |
| Preference | Per-user + shared | Low | User | Until changed |

The system follows **consolidation over accumulation** — memory is periodically distilled and merged to prevent bloat while preserving institutional intelligence.

#### 2.4 Integration Architecture

Three integration pathways connect AI-Company to external systems:

1. **MCP Servers**: Standardized tool invocation via Model Context Protocol (Tencent Docs, financial data, etc.)
2. **Webhooks**: HMAC-SHA256 secured HTTP callbacks with IP whitelisting and rate limiting
3. **REST API Bridge**: Legacy system integration with timeout handling and circuit breaker protection

All integrations follow **zero secrets in code**, **idempotent operations**, and **audit-by-default** principles.

#### 2.5 Workflow Templates

8 pre-built workflow templates cover common operational scenarios:

| Template | Phases | Trigger | Key Innovation |
|----------|--------|---------|----------------|
| WFT-001 | Data Collection Pipeline | Schedule/Manual | Source discovery → extraction → validation |
| WFT-002 | Report Generation | Schedule | Data prep → content gen → quality review → publication |
| WFT-003 | Alert Response | Event | Triage → investigation → mitigation → verification |
| WFT-004 | Skill Publishing | Manual | 6-phase CI/CD with CQO quality gates |
| WFT-005 | Incident Response | Event | Security incident lifecycle management |
| WFT-006 | Budget Review | Schedule | Department budgeting with CFO approval chain |
| WFT-007 | Deployment | Manual/Webhook | 5-phase deployment with 3-stage gates |
| WFT-008 | Market Intelligence | Schedule/Event | Competitive analysis and trend detection |

### 3. Technical Roadmap

#### Phase 1: Foundation (v1.0.0–v1.0.2) — Completed

**Date**: 2026-04-27 — 2026-04-27

- Consolidated 16 department skills into unified monolith
- Established SKILL.md manifest with ClawHub v1.0 schema
- Implemented 10 core code templates with security annotations
- Defined 3 prompt frameworks (CRISPE, 3WEH, Five-Element)
- Built L1–L6 harness engineering framework
- Created department specifications for all 11 departments
- Added auto-update system with 5-layer security gates and weekly automation

#### Phase 2: Hardening (v1.0.3–v1.0.5) — Completed

**Date**: 2026-04-28 — 2026-04-29

- **Security Hardening (P0)**: Scoped file permissions to WORKSPACE_ROOT, eliminated hardcoded paths
- **Financial Rigor (P1)**: Capex policy, working capital targets (DSO/DPO), FAIR risk thresholds with numeric scoring
- **Deployment Safety (P1)**: 3-stage deployment gate with rollback triggers
- **Quality Gates (P1)**: 85% test coverage acceptance threshold
- **Governance (P2)**: Board escalation ladder, DMCA takedown workflow, semver enforcement
- **Intelligence (P2)**: 6-phase intelligence cycle, Intelligence Library (SOP-L01~L06)
- **Sentiment Analysis Team**: 5-agent pipeline (QueryEngine → MediaEngine → InsightEngine → ReportEngine → ForumEngine)
- **Audit Pass**: All departments passed formal audit (95/100 overall score)

#### Phase 3: Intelligence Augmentation (v1.1.x) — Planned

**Target**: 2026-Q2

- Expand Intelligence Library with automated collection scheduling
- Integrate real-time sentiment monitoring with HQ Message Bus events
- Add competitive intelligence agents with multi-language support
- Build SITREP (Situation Report) automated generation pipeline
- Implement source reliability scoring and confidence-weighted analysis

#### Phase 4: Autonomous Operations (v1.2.x) — Planned

**Target**: 2026-Q3

- Self-healing execution engine with predictive failure detection
- Dynamic resource allocation using ML-based demand forecasting
- Cross-department workflow orchestration with dependency-aware scheduling
- Automated A/B testing framework for prompt optimization
- Continuous compliance monitoring with drift detection

#### Phase 5: Ecosystem Expansion (v2.0.0) — Planned

**Target**: 2026-Q4

- Plugin architecture for third-party department extensions
- Multi-tenant support for managing multiple AI companies from one skill
- Federated memory system across distributed agent networks
- Advanced visualization dashboard with real-time CEO Command Center
- API marketplace for inter-skill service discovery and composition

### 4. Design Principles Summary

| Principle | Implementation |
|-----------|---------------|
| **Modularity** | Each department is self-contained; single responsibility per skill |
| **Progressive Disclosure** | 3-layer token optimization (L1 metadata → L2 body → L3 reference) |
| **Security-by-Construction** | Zero dynamic execution, zero secrets in code, 5-layer gates |
| **Fail-Safe Defaults** | Circuit breakers, rollback procedures, escalation ladders |
| **Audit-by-Default** | Every operation logged with trace IDs; immutable audit trail |
| **Idempotency** | All operations are safely retryable without side effects |
| **Generalization (L3+)** | No company-specific names; template-based; reusable across contexts |
| **AIGC Transparency** | Explicit labels, implicit metadata, embedded watermarks on all output |
| **Semver Discipline** | Mandatory versioning; breaking changes require 90-day deprecation notice |
| **Reversibility** | Monolith can be decomposed; all state changes are rollbackable |

---

## License

This project is licensed under the [GNU GPL v3 License](LICENSE).

Copyright © 2026 AI Company Team

### License Choice Rationale

This skill uses **GNU GPL v3** for the following reasons:

1. **Copyleft Protection**: Ensures derivatives remain open-source
2. **Patent Protection**: Includes explicit patent grant (Section 11)
3. **Anti-Tivoization**: Prevents hardware restrictions on modified software (Section 6)
4. **Compatibility**: Compatible with most open-source projects
5. **Enterprise Use**: Allows modification + redistribution with same license

**Implications**:
- ✅ Free to use, modify, and distribute
- ✅ Must open-source derivatives under GPL v3
- ✅ Must include original copyright + license
- ⚠️ Cannot proprietary-license derivatives

See [LICENSE](LICENSE) file for complete terms.
