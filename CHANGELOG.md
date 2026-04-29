# Changelog

All notable changes to the AI Company Unified skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
