---
name: "AI Company Marketing & Partnerships"
slug: "ai-company-marketing-and-partnerships"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Marketing & Partnerships Department: CMO. Brand marketing, GTM strategy, skill discovery,
  partnership management, content creation, product roadmap, dual-line data protection.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-governance-and-strategy", "ai-company-finance-and-risk", "ai-company-security-and-compliance"]
tags: [ai-company,marketing,partnerships,cmo,brand,gtm,skill-discovery,content]
triggers:
  - marketing and partnerships
  - brand marketing
  - GTM strategy
  - skill discovery
  - partnership management
  - content creation
  - product roadmap
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
    - code: CMO_001
      message: "Brand violation"
    - code: CMO_005
      message: "GTM strategy missing"
    - code: CMO_006
      message: "Partnership conflict"
    - code: CMO_004
      message: "Data protection violation"
    - code: CMO_007
      message: "NPS below target"
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
  category: marketing
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: marketing-and-partnerships
  merged_from: [ai-company-cmo, ai-company-cmo-skill-discovery, ai-company-cpo, ai-company-writer]
---

# AI Company Marketing & Partnerships

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Marketing & Partnerships

### Role
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **CMO** | L4 (Marketing Authority) | CMO-001 | CEO-001 |

### Merged From
[ai-company-cmo, ai-company-cmo-skill-discovery, ai-company-cpo, ai-company-writer]

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
| CMO_001 | Brand violation |
| CMO_005 | GTM strategy missing |
| CMO_006 | Partnership conflict |
| CMO_004 | Data protection violation |
| CMO_007 | NPS below target |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*