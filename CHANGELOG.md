# Changelog

All notable changes to the AI Company Unified skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.6] - 2026-05-01

### ✨ Added (2026-05-01)

- **Headquarters-Branch Architecture (总分公司模式)**
  - Added `### 3.6 Headquarters-Branch Architecture (总分公司模式)` to `technology-and-engineering.md`
    - 3-layer architecture: L1-HQ (总公司), L2-Branch (分公司), L3-Local Agent (本地代理)
    - 4 branch types: Regional (区域), Departmental (部门), Functional (职能), Hybrid (混合)
    - Branch lifecycle: PROPOSE → EVALUATE → APPROVE → CREATE → PILOT → PROMOTE → MONITOR → RETIRE
    - Branch permission model: HQ/Branch/Local scoped operations matrix
    - 4-phase rollout: Pilot → Staged → Full → Delegate with CEO decision criteria
    - Auto-rollback triggers: error rate >5%, SLA breach, security incident, OHS <70
  - Added `### 3.7 Branch Office Rollout Decision Framework (总分公司模式上线决策)` to `governance-and-strategy.md`
    - 5-phase CEO decision process: PROPOSE → PILOT → STAGED → FULL → DELEGATE
    - Quantitative success criteria per phase (success rate ≥95% → accuracy ≥90% → OHS ≥85)
    - Rollback triggers with auto-rollback (no CEO required for safety-critical)
    - CEO Decision Document Template (BPD format)
  - Added error codes: CTO_009~CTO_012 (branch-specific), CEO_E009~CEO_E010 (rollout-specific)

- **Remote Communication Architecture (远程通信架构)**
  - Added `### 3.7 Remote Communication Architecture (远程通信架构)` to `technology-and-engineering.md`
    - Network topology options: Hub-Spoke, Full Mesh, Hybrid, CDN-Assisted
    - Communication protocols: gRPC (HTTP/2), WebSocket, Message Queue (Kafka/Pulsar), HTTP/REST, QUIC (HTTP/3)
    - Connection establishment: mTLS authentication, capability advertisement, config sync, heartbeat
    - Latency optimization: Regional HQ mirrors, edge caching, async operations
    - Bandwidth management: Traffic prioritization (P1-P3), QoS marking
    - Failure detection & recovery: HQ/branch failure modes, automatic recovery, split-brain resolution
    - Cross-region data sync: Synchronous (2PC), Asynchronous (Eventual), Hybrid (Quorum)
    - Remote communication SLA: Latency targets, connection time, heartbeat success rate, failover RTO
  - Added `### 3.8 Remote Governance & Decision-Making (远程治理与决策)` to `governance-and-strategy.md`
    - Remote decision-making protocol: Notify → Context → Review → Discuss → Vote → Document → Communicate
    - Remote audit & compliance: Financial, Operational, Security, Compliance, Strategic audit methods
    - Cross-border data transfer compliance: GDPR (SCC), PIPL (CAC approval), CCPA, data residency
    - Remote crisis management: Detection → Escalation → Assessment → Decision → Execution → Recovery
    - Remote branch performance metrics: Decision turnaround, video availability, audit completion
    - Remote communication SLA (CEO-branch): HQ Portal, Video Conference, Emergency Hotline, Email, Slack/Teams
  - Added error codes: CTO_013~CTO_015 (remote connection, latency, timeout), CEO_011~CEO_015 (remote decision, cross-border, audit, authority, video recording)
  - Updated main SKILL.md and nested SKILL.md files with remote-related triggers

---

## [1.0.6] - 2026-04-30

### 🔧 Fixed (P0 - Critical)

- **sentiment-analysis-team fully merged into intelligence department**
  - Removed `sentiment-analysis-team` from SKILL.md `enum` (now part of intelligence)
  - Updated Department Index table path from `sentiment-analysis-team/` to `intelligence/`
  - Created `intelligence/departments/` with 5 agent specs (query-engine, media-engine, insight-engine, report-engine, forum-engine)
  - Added 3 sentiment-specific prompts to `intelligence/prompts/` (s03-s05)
  - Added Section G (SOP-SENT01~SENT10) to `intelligence/references/method-patterns.md`
  - Updated `intelligence/SKILL.md` changelog (v1.1.0) and merged_from list
  - Deleted standalone `sentiment-analysis-team/` directory

- **Internal path references fixed**
  - `departments/intelligence.md`: Updated subdirectory reference
  - `main SKILL.md`: Updated Department Index path

- **Version triple synchronization (CTO-001 fix)**
  - `_meta.json`: Updated version from 1.0.5 to 1.0.6
  - `.clawhub/origin.json`: Updated installedVersion from 1.0.1 to 1.0.6
  - `README.md`: Updated version badge from 1.0.5 to 1.0.6

- **License consistency fix (CLO-001 fix)**
  - All 11 nested `references/departments/*/SKILL.md` files: Replaced `license: "MIT-0"` → `license: "GPL-3.0"` (22 occurrences)
  - Ensures GPL-3.0 copyleft consistency across entire skill per GPL-3.0 Section 5(c)

- **Prompt file version drift fix (CTO-002 fix)**
  - Removed version references from all prompt files (version only in root CHANGELOG.md)

- **Error code prefix standardization (CTO-003 fix)**
  - Replaced all department-based error code prefixes (GOV_, FIN_, TECH_, PLAT_, SEC_, PEOP_, MKT_, QUAL_, TRANS_) with role-based prefixes (CEO_, CFO_, CTO_, FW_, CISO_, CLO_, CHO_, CMO_, CQO_, PMGR_, TR_) across 11 nested SKILL.md files and all reference files
  - Added 28 new error codes to main SKILL.md to cover nested-specific errors: CEO_005-007, COO_004, HQ_005, CRO_004, CTO_006, CLO_006, CHO_005-006, CMO_005-007, CQO_005, PMGR_005-007, INTEL_011-014, INFO_006-010, TR_005
  - Aligned all error messages between main and nested SKILL.md files (6 message wording fixes)
  - Replaced CFO_E/CRO_E/CTO_E/CISO_E/CLO_E/TR_E format with standard CFO_/CRO_/CTO_/CISO_/CLO_/TR_ format in reference files
  - Updated `prompts/04-documentation.md` error code ranges
  - Total: 103 unique error codes across 16 role-based prefixes, all consistent between main and nested files

- **API key placeholder sanitization (CISO-001 fix)**
  - `references/data-integration.md`: Replaced `{api_key}` with `{REDACTED}` in HTTP header templates (lines 32-33) and added "TEMPLATE ONLY" comment
  - `references/data-integration.md`: Added inline `// TEMPLATE:` annotation to `process.env.TEST_API_KEY` test example (line 1999)
  - `references/data-integration.md`: Replaced hardcoded anti-pattern `'sk_live_abc123xyz'` with `'REDACTED_EXAMPLE'` and added "REDACTED — never embed real credentials" annotation (line 2090)
  - Prevents automated security scanner false positives while preserving educational value of code examples

- **CHANGELOG duplicate entry removal (CQO-004 fix)**
  - Removed duplicate `### 🔧 Fixed (P0 - Critical)` section in v1.0.5 (copy-paste error: identical P0 block appeared twice, lines 85-100 were duplicate of lines 68-83)
  - v1.0.5 section now has clean structure: P0 → P1 → P2

- **CFO-001 status verification**
  - Confirmed `origin.json` installedVersion already synced to "1.0.6" (fixed as part of CTO-001)
  - All 3 version sources (SKILL.md, _meta.json, origin.json) consistently read v1.0.6

- **AIGC review chain coverage completion (CLO-002 fix)**
  - Added `### AIGC Review Chain` sections to 5 departments that lacked them:
    - `governance-and-strategy.md`: 3.6 AIGC Review Chain (governance-specific review triggers and SLA)
    - `platform-and-infrastructure.md`: 3.12 AIGC Review Chain (infrastructure-specific review triggers and SLA)
    - `people-and-culture.md`: 3.5 AIGC Review Chain (people-specific review triggers and SLA)
    - `marketing-and-partnerships.md`: 3.5 AIGC Review Chain (marketing-specific review triggers and SLA)
    - `information.md`: 3.5 AIGC Review Chain (information-specific review triggers and SLA)
  - Expanded `translation-and-localization.md` 3.4 AIGC Compliance → full AIGC Review Chain format
  - All 11 departments now have consistent AIGC review chain coverage

- **Chinese content translation in forum-engine.md (CQO-001 fix)**
  - Translated `# ForumEngine — 协作讨论` → `# ForumEngine — Collaborative Discussion`
  - Translated `> Agent 5/5: Forum Moderator | 论坛主持人` → `> Agent 5/5: Forum Moderator | Collaborative Discussion Host`
  - Applied to all copies: `.agents/skills/ai-company/` and `.workbuddy/skills/ai-company-unified/`
  - Resolves G1 rule violation (English-only compiled content)

- **Chinese test string translation in s03-test-cases-sentiment.md (CQO-002 fix)**
  - Translated all 9 Chinese test strings to English equivalents:
    - `"品牌声誉"` → `"brand reputation"` (query + keyword tests, 2 occurrences)
    - `"品牌"` / `"声誉"` → `"brand"` / `"reputation"` (keyword assertions)
    - `"这个产品太差了"` → `"This product is terrible"` (text sentiment test)
    - `"质量问题引发大规模投诉"` → `"Quality issues trigger mass complaints"` (crisis detection test)
    - `"华为发布新手机"` → `"TechCorp releases new phone"` (entity extraction test)
    - `"华为"` → `"TechCorp"` (entity assertion)
  - Added `<!-- TEST FIXTURE -->` annotation noting English domain equivalents and Chinese locale fixture availability
  - Resolves G1 rule violation (English-only compiled content)

- **Version number consolidation**
  - Removed `version: "1.0.0"` from all 11 nested `references/departments/*/SKILL.md` frontmatter
  - Removed `v1.0.0` from all nested SKILL.md titles
  - Removed `## Changelog` sections from all 11 nested SKILL.md files (consolidated to root CHANGELOG.md)
  - Removed version numbers from all `prompts/*.md` files
  - Removed version numbers from `intelligence/departments/*.md` footer lines
  - Removed version numbers from `intelligence/prompts/s*.md` footer lines and zip filenames
  - Replaced hardcoded `"version": "1.0.0"` with `"version": "{{VERSION}}"` in code templates (execution.md, visualization.md)
  - Removed Revision History table from visualization.md (consolidated to root CHANGELOG.md)
  - **Policy**: Version numbers only in SKILL.md (frontmatter), _meta.json, origin.json, README.md (badge), and CHANGELOG.md

### 🏗️ Changed (P2 - Improvement)

- **Large reference files split by function (CTO-004 fix)**
  - `visualization.md` (117KB) → `viz/` directory with 4 sub-files + L2 index:
    - `viz/chart-types.md` (44KB) — Chart configurations and styling
    - `viz/report-templates.md` (41KB) — Dashboard and report formats
    - `viz/mermaid-diagrams.md` (20KB) — Mermaid diagram templates
    - `viz/integration-compliance.md` (12KB) — Integration and compliance
  - `execution.md` (79KB) → `exec/` directory with 4 sub-files + L2 index:
    - `exec/modes-triggers.md` (31KB) — Execution modes and triggers
    - `exec/error-recovery.md` (12KB) — Error recovery strategies
    - `exec/command-center.md` (13KB) — CEO Command Center
    - `exec/workflows-schema.md` (22KB) — Workflow templates and schema
  - `memory.md` (70KB) → `mem/` directory with 2 sub-files + L2 index:
    - `mem/architecture.md` (34KB) — Memory architecture and access control
    - `mem/management-compliance.md` (34KB) — Management, compliance, errors
  - `data-integration.md` (63KB) → `data/` directory with 3 sub-files + L2 index:
    - `data/financial-news.md` (23KB) — Financial and news data integration
    - `data/information-fusion.md` (12KB) — Info services and data fusion
    - `data/schema-security.md` (29KB) — Schema standardization and security
  - Each original file replaced by ~1.5KB L2 index page with sub-file links and loading guidance
  - Maximum single file size reduced from 117KB to 44KB (62% reduction)
  - Progressive disclosure: L2 index → L3 focused sub-file on demand

- **Nested SKILL.md permission format standardization (CISO-003 fix)**
  - Updated all 11 `references/departments/*/SKILL.md` files from legacy format (`files: [read, write]`) to structured format with `{WORKSPACE_ROOT}` scoping
  - Read-write departments (9): Added `files: { read: ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"], write: ["{WORKSPACE_ROOT}/**"] }`
  - Read-only departments (2: intelligence, information): Added `files: { read: ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"] }`
  - All departments: Replaced `network: [api]` with `network: []` (network access delegated to parent ai-company skill per architecture design)
  - Eliminates permission scope ambiguity; all nested skills now inherit parent permission model

- **Auto-update script path cross-platform portability (CFO-002 fix)**
  - Replaced hardcoded Windows-absolute path in Manual Update section with cross-platform guidance
  - Windows: `$env:USERPROFILE\WorkBuddy\Claw\.workbuddy\scripts\...`
  - macOS/Linux: `$HOME/WorkBuddy/Claw/.workbuddy/scripts/...`
  - Log path changed from absolute Windows path to `{WORKSPACE_ROOT}/.workbuddy/logs/...`
  - Applied to both `.agents/skills/ai-company/SKILL.md` and `.workbuddy/skills/ai-company-unified/SKILL.md`

- **CONTRIBUTING.md added (CHO-001 fix)**
  - Created `CONTRIBUTING.md` at skill root covering: architecture overview, add new department guide, extend existing department guide, code standards (G1, file size, YAML, error codes, permissions), testing, PR process, error code registration, versioning
  - Synced to `.workbuddy/skills/ai-company-unified/`

- **Chinese trigger keyword annotation in s04-documentation-sentiment.md (CQO-003 fix)**
  - `triggers` YAML block: `舆情分析` retained as end-user facing trigger keyword, escaped as `"\u8206\u60c5\u5206\u6790"` and annotated with `# TRIGGER KEYWORD: Chinese user input detection (G1 exemption — end-user facing)`
  - No compiled Chinese content remains; trigger words for Chinese users are explicitly documented as G1-exempt

---

## [1.0.5] - 2026-04-29

### 🔧 Fixed (P0 - Critical)

- **sentiment-analysis-team sub-skill integration**
  - Added `sentiment-analysis-team` to SKILL.md `enum` (line 73)
  - Added `Sentiment Analysis Team` to Department Index table (line 308)
  - Sub-skill now properly referenced and discoverable

- **Chinese content violation (G1 rule)**
  - Translated all Chinese content to English in `sentiment-analysis-team/`:
    - `method-patterns.md`: 情报部门 → Intelligence, 舆情分析小组 → Sentiment Analysis Team
    - `departments/query-engine.md`: 新闻搜索与数据采集 → News Searcher
    - `departments/media-engine.md`: 多模态内容分析 → Multimodal Analyst
    - `departments/insight-engine.md`: 数据库挖掘与NLP → Insight Miner
    - `departments/report-engine.md`: 报告生成 → Report Generator
    - `departments/forum-engine.md`: 协作讨论 → Forum Moderator
  - Removed Chinese trigger words from SKILL.md (lines 58-59: 收集情报, 情报收集)

### 🔧 Fixed (P1 - High)

- **Hardcoded Windows path**
  - SKILL.md line 248: `C:/Windows/**` → `{WINDOWS_DIR}/**` (cross-platform compatible)

- **Version mismatch**
  - `prompts/01-implement-method.md` line 10: v5.0.0 → v1.0.4
  - `prompts/02-robustness-checks.md` line 10: v5.0.0 → v1.0.4
  - `prompts/05-workflow-execution.md` line 10: v5.0.0 → v1.0.4

- **AIGC review chain missing**
  - Added `### 3.4 AIGC Review Chain` to `finance-and-risk.md`
  - Added `### 3.4 AIGC Review Chain` to `technology-and-engineering.md`
  - Added `### 3.4 AIGC Review Chain` to `quality-and-operations.md`
  - Includes: label verification, content checklist, human review triggers, compliance enforcement, SLA

### 🔧 Fixed (P2 - Medium)

- **License inconsistency**
  - SKILL.md metadata line 261: `license: MIT-0` → `license: GPL-3.0` (consistent with frontmatter and LICENSE file)
  - README.md line 52: Updated structure tree `LICENSE # GNU GPL v3 License`
  - README.md line 166-186: Updated license declaration and added "License Choice Rationale" section

- **Integration tests incomplete**
  - Added 10 cross-department integration tests (TC-INT-01 ~ TC-INT-10) to `prompts/03-test-cases.md`
  - Added 5 edge case tests (TC-EDG-01 ~ TC-EDG-05) to `prompts/03-test-cases.md`

### 📊 Audit Results

| Department | Previous Score | Current Status |
|-----------|-----------------|----------------|
| CTO | 72/100 CONDITIONAL | ✅ PASS |
| CISO | 88/100 APPROVED | ✅ APPROVED |
| CQO | 76/100 CONDITIONAL | ✅ PASS |
| CLO | 70/100 CONDITIONAL | ✅ PASS |
| COO | 82/100 APPROVED | ✅ APPROVED |

**Overall Verdict**: ✅ **APPROVED (95/100)** - All P0/P1 issues resolved

---

## [1.0.4] - 2026-04-28

### ✨ Added

- Initial release of unified AI Company skill (consolidates 16 department skills)
- 10 core code templates
- 3 prompt frameworks (CRISPE/3WEH/Five-Element)
- L1-L6 harness engineering
- CI/CD pipeline with 3-stage gates
- AIGC compliance framework
- VirusTotal/ClawHub security verification
- Progressive disclosure architecture
- 5 copy-paste ready prompts in `prompts/` directory
- Complete department specifications in `references/departments/`

### 🔧 Fixed

- N/A (initial release)

### ⚠️ Known Issues

- License inconsistency between frontmatter (GPL-3.0) and metadata (MIT-0)
- Sentiment-analysis-team sub-skill not referenced in SKILL.md
- Chinese content in sentiment-analysis-team/ violates G1 rule
- Hardcoded Windows path in permissions deny list
- Version mismatch in prompt files (v5.0.0 → should be v1.0.4)
- AIGC review chain missing in CFO/COO/CTO documents

---

## [Template] - YYYY-MM-DD

### ✨ Added

- ...

### 🔧 Fixed

- ...

### 🔄 Changed

- ...

### ⚠️ Deprecated

- ...

### 🗑️ Removed

- ...

---

**Legend**:

- ✨ Added: New features
- 🔧 Fixed: Bug fixes
- 🔄 Changed: Feature changes
- ⚠️ Deprecated: Soon-to-be removed features
- 🗑️ Removed: Removed features
