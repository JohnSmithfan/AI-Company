# AI-Company Data Integration Module

> **Progressive Disclosure**: This module has been split into focused sub-files for on-demand loading.
> Load only the sub-file you need instead of the entire module.

## Sub-File Index

| File | Content | Size | Load When |
|------|---------|------|-----------|
| [financial-news.md](data/financial-news.md) | Financial Data + News & Intelligence (Sections 1-2) — Market data, financial APIs, news sources | ~22KB | Integrating financial or news data |
| [information-fusion.md](data/information-fusion.md) | Information Services + Multi-Source Fusion (Sections 3-4) — Weather, calendar, location data, fusion algorithms | ~12KB | Integrating info services or fusing data |
| [schema-security.md](data/schema-security.md) | Standardization Schema + Appendices (Sections 5 + Appendices) — Data schemas, testing, security | ~28KB | Schema design or security review |

## Quick Reference

- **Data sources**: 20+ financial, news, and information APIs
- **Fusion algorithms**: 5 multi-source strategies
- **Standardization**: Unified schema with auto-mapping
- **Security**: PII masking, API key sanitization, rate limiting

## Loading Pattern

```python
# Instead of loading the entire 63KB file:
# references/data-integration.md  ← OLD (63KB, ~16K tokens)

# Load only what you need:
# references/data/financial-news.md      ← NEW (~22KB, ~6K tokens)
# references/data/information-fusion.md  ← NEW (~12KB, ~3K tokens)
# references/data/schema-security.md     ← NEW (~28KB, ~7K tokens)
```
