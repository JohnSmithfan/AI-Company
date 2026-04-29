## SECTION G: SENTIMENT ANALYSIS TEAM

> Added: 2026-04-29 | Per AI Company Governance Framework
> Full specifications in [intelligence/SKILL.md](references/departments/intelligence/SKILL.md) and [intelligence/departments/](references/departments/intelligence/departments/) directory.

### SOP-SENT01: Team Overview

**Sentiment Analysis Team** is a specialized 5-agent unit under Intelligence for public opinion monitoring, multi-platform data collection, multilingual content analysis, and intelligent report generation.

### Agent Index

| Agent | Role (English) | Engine | Description |
|-------|----------------|--------|-------------|
| News Searcher | News Searcher | Tavily API | Broad news & social media data collection |
| Multimodal Analyst | Multimodal Analyst | Bocha API | Text, image, video multimodal analysis |
| Insight Miner | Insight Miner | MediaCrawlerDB | Deep mining from private databases with NLP |
| Report Generator | Report Generator | LLM Templates | HTML/Markdown report generation |
| Forum Moderator | Forum Moderator | Qwen3-235B | Multi-agent collaborative discussion |

### Triggers

| Trigger Keywords | Description |
|------------------|-------------|
| sentiment analysis | General sentiment analysis requests |
| public opinion monitoring | Opinion monitoring |
| brand reputation | Brand reputation tracking |
| hot event tracking | Hot event tracking |
| social media analysis | Social media analysis |
| crisis PR | Crisis PR management |
| word-of-mouth monitoring | Word-of-mouth monitoring |

### Pipeline Architecture

```
User Query → [QueryEngine] → Raw Data ├──→ [MediaEngine] (multimodal analysis)
                                       ├→ [InsightEngine] (database mining)
                                       └→ [ReportEngine] (report generation)
                                             ↓
                                        [ForumEngine] (collaborative discussion)
```

---

### SOP-SENT02: QueryEngine — News Searcher

```
Role: News Searcher
Task: Broad-spectrum news and social media data collection
Context: First stage of sentiment analysis pipeline; feeds raw data to downstream agents
Format: Normalized JSON with source, URL, title, content, timestamp
Constraint: API rate limiting; deduplication required; AIGC disclosure mandatory
```

**Core Responsibilities:**
1. Multi-Source News Search via Tavily API (6 modes: general, news, extract, map, QnA, context)
2. Keyword Optimization with synonym expansion (Chinese + English) and trending term injection
3. Search Result Deduplication using URL hashing and content similarity
4. Data Normalization to unified format

**Output Schema:**
```json
{
  "source": "platform_name",
  "url": "canonical_url",
  "title": "article_title",
  "content": "body_text",
  "published_at": "ISO8601_timestamp",
  "author": "author_name",
  "sentiment_raw": null,
  "relevance_score": 0.95
}
```

**Error Codes:**
| Code | Message | Resolution |
|------|---------|------------|
| QUERY_001 | Search API unavailable | Check TAVILY_API_KEY env var |
| QUERY_002 | No relevant results | Broaden keywords or date range |
| QUERY_003 | Search rate limit exceeded | Backoff and retry after 60s |

---

### SOP-SENT03: MediaEngine — Multimodal Analyst

```
Role: Multimodal Analyst
Task: Multimodal content analysis (text, image, video)
Context: Receives raw data from QueryEngine; extracts sentiment signals
Format: Annotated content with modality-specific metadata
Constraint: Content moderation filtering; PII masking required
```

**Core Responsibilities:**
1. Text Sentiment Analysis via NLP models
2. Image/Video Analysis using Bocha API multimodal capabilities
3. Cross-Platform Consistency Scoring
4. Crisis Signal Detection with severity classification

**Error Codes:**
| Code | Message | Resolution |
|------|---------|------------|
| MEDIA_001 | Multimodal API unavailable | Check BOCHA_API_KEY |
| MEDIA_002 | Content extraction failed | Retry with alternate method |
| MEDIA_003 | Content moderation triggered | Flag for human review |

---

### SOP-SENT04: InsightEngine — Insight Miner

```
Role: Insight Miner
Task: Deep mining from private databases with NLP sentiment analysis
Context: Historical data correlation; trend identification
Format: Structured insights with confidence scores
Constraint: Database connection security; no direct credential exposure
```

**Core Responsibilities:**
1. Historical Data Correlation with real-time findings
2. Trend Identification across time series
3. Entity Extraction (brands, products, persons)
4. Sentiment Model Inference with confidence scoring

**Error Codes:**
| Code | Message | Resolution |
|------|---------|------------|
| INSIGHT_001 | Database connection failed | Check MediaCrawlerDB config |
| INSIGHT_002 | No historical data found | Expand date range |
| INSIGHT_003 | Sentiment inference timeout | Reduce dataset size |

---

### SOP-SENT05: ReportEngine — Report Generator

```
Role: Report Generator
Task: Intelligent template selection and HTML/Markdown report generation
Context: Final output stage; receives structured insights from InsightEngine
Format: Publication-ready HTML/Markdown reports with AIGC disclosure
Constraint: All reports MUST include AIGC labeling; PII masking mandatory
```

**Report Structure:**
1. Executive Summary Dashboard
2. Sentiment Trend Charts (time-series line charts)
3. Platform Breakdown Visualizations (bar/pie charts)
4. Word Cloud of Top Keywords
5. Hot Topic Cards with Sentiment Badges
6. Risk Alert Panel (color-coded severity)
7. Detailed Findings per Platform
8. Methodology and Data Sourcing Appendix

**AIGC Requirements:**
- Header: "Generated by AI (Sentiment Analysis)"
- Footer: "This report was generated by AI. Verify critical findings before action."
- Metadata: ai_generated, timestamp, model_version, trace_id

**Error Codes:**
| Code | Message | Resolution |
|------|---------|------------|
| REPORT_001 | Template selection failed | Check available templates |
| REPORT_002 | HTML generation error | Validate template structure |
| REPORT_003 | Write permission denied | Check OUTPUT_DIR permissions |

---

### SOP-SENT06: ForumEngine — Forum Moderator

```
Role: Forum Moderator
Task: Multi-agent collaborative discussion with LLM host moderation
Context: Post-report validation; alternative viewpoints generation
Format: Discussion transcript with moderator summary
Constraint: LLM availability; agent speech threshold enforcement
```

**Core Responsibilities:**
1. Forum Setup with Qwen3-235B as moderator
2. Agent Perspective Assignment (bullish, bearish, neutral, contrarian)
3. Structured Discussion Facilitation
4. Divergence Summary Generation

**Error Codes:**
| Code | Message | Resolution |
|------|---------|------------|
| FORUM_001 | LLM host unavailable | Check Qwen3-235B endpoint |
| FORUM_002 | Agent threshold not reached | Extend discussion rounds |
| FORUM_003 | Discussion log capture failed | Retry with smaller batch |

---

### SOP-SENT07: Integration with 6-Phase Intelligence Cycle

```
Role: Intelligence Director
Task: Orchestrate sentiment analysis within standard intelligence workflow
Trigger: Any sentiment analysis request
Integration Points:
  Phase 2 (COLLECTION): QueryEngine + MediaEngine
  Phase 3 (PROCESSING): InsightEngine normalization
  Phase 4 (ANALYSIS): Sentiment scoring and trend analysis
  Phase 5 (DISSEMINATION): ReportEngine output + ForumEngine validation
```

**Configuration Parameters:**
| Parameter | Env Variable | Default | Description |
|-----------|-------------|---------|-------------|
| API Key | TAVILY_API_KEY | (required) | Tavily search API |
| Bocha Key | BOCHA_API_KEY | (required) | Bocha multimodal API |
| LLM Model | REPORT_MODEL | qwen-plus | Report generation model |
| DB Host | DB_HOST | localhost | MediaCrawlerDB host |
| Max Results | QUERY_MAX_RESULTS | 20 | Max search results |
| Analysis Depth | DEPTH | standard | quick/standard/deep |

---

### SOP-SENT08: Quality Metrics (Sentiment Analysis Team)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Query success rate | >=95% | Successful API calls / Total |
| Media analysis coverage | >=90% | Analyzed content / Raw data |
| Insight correlation accuracy | >=85% | Correlated findings / Total |
| Report generation success | >=98% | Successful reports / Requests |
| Forum discussion completion | >=90% | Complete discussions / Total |
| AIGC disclosure compliance | 100% | Reports with disclosure / Total |
| PII masking compliance | 100% | Masked items / Detected PII |

---

### SOP-SENT09: Security & Compliance (Sentiment Analysis Team)

**Permission Boundaries:**
- Files: Read `{WORKSPACE_ROOT}/**`, `{SKILL_DIR}/**`
- Files: Write `{WORKSPACE_ROOT}/**`
- Deny: `~/.ssh/**`, `~/.aws/**`, `~/.config/**`, `/etc/**`, `{WINDOWS_DIR}/**`
- Network: API calls to whitelisted domains only (Tavily, Bocha, LLM endpoints)
- Commands: No shell commands; all operations via API/MCP

**Prohibited Patterns:**
| Risk | Prohibited | Safe Alternative |
|------|------------|------------------|
| Permission Abuse | ~/.ssh, ~/.aws access | Workspace-scoped only |
| Remote Execution | curl/wget unknown URLs | Whitelisted APIs only |
| Dynamic Eval | eval(), exec() | Pre-defined functions |
| Data Exfiltration | External unencrypted | Encrypted channels |
| Obfuscation | Minified/encoded | Clear readable code |

**AIGC Labeling:**
- Every output MUST include: "AI-generated content (Sentiment Analysis)"
- Metadata block: `ai_generated: true`, timestamp, trace_id

---

### Error Codes Summary (Sentiment Analysis Team)

| Code | Source | Message |
|------|--------|---------|
| QUERY_001 | QueryEngine | Search API unavailable |
| QUERY_002 | QueryEngine | No relevant results found |
| QUERY_003 | QueryEngine | Search rate limit exceeded |
| MEDIA_001 | MediaEngine | Multimodal API unavailable |
| MEDIA_002 | MediaEngine | Content extraction failed |
| MEDIA_003 | MediaEngine | Content moderation triggered |
| INSIGHT_001 | InsightEngine | Database connection failed |
| INSIGHT_002 | InsightEngine | No historical data found |
| INSIGHT_003 | InsightEngine | Sentiment inference timeout |
| REPORT_001 | ReportEngine | Template selection failed |
| REPORT_002 | ReportEngine | HTML generation error |
| REPORT_003 | ReportEngine | Write permission denied |
| FORUM_001 | ForumEngine | LLM host unavailable |
| FORUM_002 | ForumEngine | Agent threshold not reached |
| FORUM_003 | ForumEngine | Discussion log capture failed |
| SYS_001 | System | Invalid input (query empty) |
| SYS_002 | System | Platform not supported |
| SYS_003 | System | Orchestration pipeline failed |
| SYS_004 | System | Output format conversion failed |

---

### Constraints (Sentiment Analysis Team)

1. **Progressive Disclosure**: L1 metadata <100 words, L2 body <5000 words
2. **Pipeline Order**: QueryEngine → MediaEngine → InsightEngine → ReportEngine → ForumEngine
3. **AIGC Labeling**: All AI-generated output MUST include disclosure markers
4. **Rate Limiting**: Per-platform throttling on all external API calls
5. **PII Masking**: All user-facing content MUST have PII masked
6. **Environment Variables**: All API credentials in env vars (no hardcoded keys)
7. **No Dynamic Code**: No eval(), exec(), or shell string execution
8. **Source Preservation**: All source URLs must be preserved for verification

---

## Core Responsibilities Summary

| Section | Role | Key Responsibilities |
|---------|------|----------------------|
| Director | Strategic Leadership | Planning cycle, resource allocation, HQ reports, escalation, STRIDE assessment |
| Analysis | Intelligence Assessment | Core assessment, ACH, Red Team, threat forecasting, bias checklist, reporting |
| Collection | OSINT/HUMINT/SIGINT | Source validation, collection tasking, OSINT channels, source lifecycle, quality scoring |
| Operations | Records & Infrastructure | Records lifecycle, system health, patch priority, backup, onboarding, competency |
| Security | Access & Incidents | Access provisioning, incident response, STRIDE modeling, classification, audit |
| **Sentiment Analysis** | **Sentiment Analysis Team** | **Public opinion monitoring, multi-platform data collection, sentiment analysis, intelligent reporting** |

---

## Error Codes (Full)

| Code | Meaning | Resolution |
|------|---------|------------|
| INTEL_001 | Intelligence collection failed | Check source availability, retry with alternate source |
| INTEL_002 | Analysis confidence low | Gather additional sources, apply ACH, seek second opinion |
| INTEL_003 | Source verification failed | Re-validate source tier, suspend source pending review |
| INTEL_004 | Classification violation | Re-classify per decision tree, notify security lead |
| INTEL_005 | Operational security breach | Activate incident response SOP-S02, notify HQ immediately |
| INTEL_006 | Library structure creation failed | Check WORKSPACE_ROOT permissions |
| INTEL_007 | Source registry corrupted | Restore from backup; re-validate |
| INTEL_008 | Collection plan missing REQUIREMENTS | Return to Phase1 |
| INTEL_009 | Product confidence LOW (<40%) | Suspend; re-collect |
| INTEL_010 | SITREP generation failed | Check intelligence/reports/ exists |
| QUERY_001 | Search API unavailable | Check TAVILY_API_KEY |
| QUERY_002 | No relevant results | Broaden keywords |
| QUERY_003 | Search rate limit | Backoff and retry |
| MEDIA_001 | Multimodal API unavailable | Check BOCHA_API_KEY |
| MEDIA_002 | Content extraction failed | Retry with alternate method |
| MEDIA_003 | Content moderation triggered | Flag for human review |
| INSIGHT_001 | Database connection failed | Check MediaCrawlerDB config |
| INSIGHT_002 | No historical data | Expand date range |
| INSIGHT_003 | Sentiment inference timeout | Reduce dataset size |
| REPORT_001 | Template selection failed | Check templates |
| REPORT_002 | HTML generation error | Validate structure |
| REPORT_003 | Write permission denied | Check permissions |
| FORUM_001 | LLM unavailable | Check Qwen3 endpoint |
| FORUM_002 | Threshold not reached | Extend rounds |
| FORUM_003 | Log capture failed | Retry smaller batch |

---

## Constraints (Full)

- All intelligence products require confidence level annotation (High/Medium/Low)
- All sources must be validated per SOP-C01 before use
- Classification decisions follow SOP-S04 decision tree
- STRIDE assessments required for all new systems and processes
- Incident reports filed within 24h of detection
- Monthly security audit per SOP-S05
- All file paths MUST be under WORKSPACE_ROOT
- All sources MUST be rated A/B/C before operational use
- All products MUST have confidence annotation
- All 6-phase cycles MUST end with memory update
- No eval()/exec() in collection scripts
- All OSINT sources MUST be from whitelisted domains
- Progressive disclosure mandatory: L1 <100 words, L2 <5000 words
- AIGC labeling on all AI-generated output
- PII masking for all user-facing content

---

## Quality Metrics (Full)

| Metric | Target |
|--------|--------|
| Source validation rate | 100% |
| Assessment accuracy (6-month review) | >=80% |
| Collection task completion rate | >=90% |
| Incident response time | <4h |
| Classification accuracy | >=95% |
| Audit completion rate | 100% |
| Query success rate (Sentiment) | >=95% |
| Media analysis coverage | >=90% |
| Insight correlation accuracy | >=85% |
| Report generation success | >=98% |
| AIGC disclosure compliance | 100% |
| PII masking compliance | 100% |

---

*Sentiment Analysis Team added: 2026-04-29 | Integrated with 6-Phase Intelligence Cycle*
*AI Company | Intelligence Department | AI Company Governance Framework*
