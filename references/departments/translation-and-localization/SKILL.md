---
name: "AI Company Translation & Localization"
slug: "ai-company-translation-and-localization"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Translation & Localization Department: Translator. Multi-language translation (EN/ZH/RU/FR+),
  translation coordination, quality verification, brand voice consistency, AIGC labeling,
  cultural adaptation.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-governance-and-strategy", "ai-company-security-and-compliance"]
tags: [ai-company,translation,localization,i18n,brand-voice,aigc,cultural-adaptation]
triggers:
  - translation
  - localization
  - language routing
  - translation quality
  - brand voice translation
  - AIGC labeling
  - cultural adaptation
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        task:
          type: string
          description: Task description
        context:
          type: object
          description: Optional context information
      required: [task]
  outputs:
    type: object
    schema:
      type: object
      properties:
        result:
          type: string
          description: Operation result
        report:
          type: object
          description: Detailed report data
      required: [result]
  errors:
    - code: TR_001
      message: "Translation quality below threshold"
    - code: TR_005
      message: "Language routing error"
    - code: TR_004
      message: "AIGC translation label missing"
    - code: TR_003
      message: "Cultural adaptation required"
permissions:
  files: [read, write]
  network: [api]
  commands: []
  mcp: [sessions_send, subagents]
quality:
  saST: Pass
  vetter: Approved
  idempotent: true
metadata:
  category: translation
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: translation-and-localization
  merged_from: [ai-company-translator, ai-company-translation-layer, ai-company-translator-en, ai-company-translator-zh, ai-company-translator-ru, ai-company-translator-fr]
---

# AI Company Translation & Localization

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Translation & Localization

### Role
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **Translator** | L3 (Translation Authority) | TRANS-001 | CMO-001 |

### Supported Languages
EN (English), ZH (Chinese), RU (Russian), FR (French), + additional languages

### Merged From
[ai-company-translator, ai-company-translation-layer, ai-company-translator-en, ai-company-translator-zh, ai-company-translator-ru, ai-company-translator-fr]

## Section Index

- [1. Trigger Scenarios](references/method-patterns.md#1-trigger-scenarios)
- [2. Core Identity](references/method-patterns.md#2-core-identity)
- [3. Core Responsibilities](references/method-patterns.md#3-core-responsibilities)
- [4. Constraints](references/method-patterns.md#4-constraints)
- [5. Error Codes](references/method-patterns.md#5-error-codes)

## Dependencies

See frontmatter `dependencies.skills` for complete dependency list.

## Error Codes

| Code | Message |
|------|---------|
| TR_001 | Translation quality below threshold |
| TR_005 | Language routing error |
| TR_004 | AIGC translation label missing |
| TR_003 | Cultural adaptation required |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*