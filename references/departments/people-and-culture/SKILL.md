---
name: "AI Company People & Culture"
slug: "ai-company-people-and-culture"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  People & Culture Department: CHO. HR management, agent lifecycle, knowledge extraction,
  skills development, culture audit, ethics oversight, AI ethics board.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-governance-and-strategy", "ai-company-security-and-compliance"]
tags: [ai-company,people,culture,cho,hr,lifecycle,knowledge-extraction,skills,ethics]
triggers:
  - people and culture
  - HR management
  - agent lifecycle
  - knowledge extraction
  - skill development
  - culture audit
  - ethics oversight
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
    - code: CHO_001
      message: "Agent onboarding failed"
    - code: CHO_003
      message: "Knowledge extraction failed"
    - code: CHO_002
      message: "Skill gap detected"
    - code: CHO_005
      message: "Ethics violation"
    - code: CHO_006
      message: "Culture audit failed"
permissions:
  files:
    read: ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
    write: ["{WORKSPACE_ROOT}/**"]
  network: []  # Network access delegated to parent ai-company skill
  commands: []
  mcp: [sessions_send, subagents]
quality:
  saST: Pass
  vetter: Approved
  idempotent: true
metadata:
  category: people
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: people-and-culture
  merged_from: [ai-company-cho, ai-company-cho-knowledge-extractor, ai-company-hr]
---

# AI Company People & Culture

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
People & Culture

### Role
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **CHO** | L4 (HR Authority) | CHO-001 | CEO-001 |

### Merged From
[ai-company-cho, ai-company-cho-knowledge-extractor, ai-company-hr]

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
| CHO_001 | Agent onboarding failed |
| CHO_003 | Knowledge extraction failed |
| CHO_002 | Skill gap detected |
| CHO_005 | Ethics violation |
| CHO_006 | Culture audit failed |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*