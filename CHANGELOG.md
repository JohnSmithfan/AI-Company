# Changelog

All notable changes to the AI Company Unified skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
