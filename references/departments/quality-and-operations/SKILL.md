---
name: "AI Company Quality & Operations"
slug: "ai-company-quality-and-operations"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Quality & Operations Department: CQO, PMGR. Quality control, DORA metrics, OKR-bound quality gates,
  skill review pipeline, project management, customer service, ticket management, NPS satisfaction.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-governance-and-strategy", "ai-company-technology-and-engineering"]
tags: [ai-company,quality,operations,cqo,pmgr,dora,quality-gates,project-management]
triggers:
  - quality and operations
  - quality control
  - DORA metrics
  - quality gate review
  - skill review
  - project management
  - task decomposition
  - customer service
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        role:
          type: string
          enum: [cqo, pmgr]
          description: Which role to invoke
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
    - code: CQO_001
      message: "Quality gate failed"
    - code: CQO_005
      message: "DORA metric breach"
    - code: PMGR_005
      message: "Task decomposition failed"
    - code: PMGR_006
      message: "NPS threshold breach"
    - code: PMGR_007
      message: "Ticket SLA violation"
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
  category: quality
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: quality-and-operations
  merged_from: [ai-company-cqo, ai-company-cqo-skill-reviewer, ai-company-qeng, ai-company-pmgr, ai-company-cssm]
---

# AI Company Quality & Operations

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Quality & Operations

### Roles
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **CQO** | L4 (Quality Authority) | CQO-001 | CEO-001 |
| **PMGR** | L3 (Project Authority) | PMGR-001 | COO-001 |

### Merged From
[ai-company-cqo, ai-company-cqo-skill-reviewer, ai-company-qeng, ai-company-pmgr, ai-company-cssm]

## Section Index

- [1. Trigger Scenarios](references/method-patterns.md#1-trigger-scenarios)
- [2. Core Identity](references/method-patterns.md#2-core-identity)
- [3. Role Index](references/method-patterns.md#3-role-index)
- [4. CQO: Quality Control](references/method-patterns.md#4-cqo-quality-control)
- [5. PMGR: Project Management](references/method-patterns.md#5-pmgr-project-management)
- [6. Cross-Role Collaboration](references/method-patterns.md#6-cross-role-collaboration)
- [7. Constraints](references/method-patterns.md#7-constraints)
- [8. Error Codes](references/method-patterns.md#8-error-codes)

## Dependencies

See frontmatter `dependencies.skills` for complete dependency list.

## Error Codes

| Code | Message | Role |
|------|---------|------|
| CQO_001 | Quality gate failed | CQO |
| CQO_005 | DORA metric breach | CQO |
| PMGR_005 | Task decomposition failed | PMGR |
| PMGR_006 | NPS threshold breach | PMGR |
| PMGR_007 | Ticket SLA violation | PMGR |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*