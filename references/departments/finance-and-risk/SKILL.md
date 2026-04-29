---
name: "AI Company Finance & Risk"
slug: "ai-company-finance-and-risk"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Finance & Risk Department: CFO, CRO. Financial management, budget approval, pricing models,
  risk assessment, circuit breaker, FAIR quantitative analysis, milestone risk gates.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-governance-and-strategy", "ai-company-framework"]
tags: [ai-company,finance,risk,cfo,cro,budget,pricing,fair,circuit-breaker]
triggers:
  - finance and risk
  - financial management
  - budget approval
  - pricing model
  - risk assessment
  - circuit breaker
  - FAIR analysis
  - milestone gate
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        role:
          type: string
          enum: [cfo, cro]
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
    - code: CFO_001
      message: "Budget overrun"
    - code: CFO_002
      message: "Pricing model invalid"
    - code: CRO_001
      message: "Risk threshold exceeded"
    - code: CRO_002
      message: "Circuit breaker triggered"
    - code: CRO_003
      message: "FAIR assessment incomplete"
    - code: CRO_004
      message: "Gate failure"
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
  category: finance
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: finance-and-risk
  merged_from: [ai-company-cfo, ai-company-cro]
---

# AI Company Finance & Risk

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Finance & Risk

### Roles
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **CFO** | L4 (Financial Authority) | CFO-001 | CEO-001 |
| **CRO** | L4 (Risk Authority) | CRO-001 | CEO-001 |

### Merged From
[ai-company-cfo, ai-company-cro]

## Section Index

- [1. Trigger Scenarios](references/method-patterns.md#1-trigger-scenarios)
- [2. Core Identity](references/method-patterns.md#2-core-identity)
- [3. Role Index](references/method-patterns.md#3-role-index)
- [4. CFO: Financial Management](references/method-patterns.md#4-cfo-financial-management)
- [5. CRO: Risk Management](references/method-patterns.md#5-cro-risk-management)
- [6. Cross-Role Collaboration](references/method-patterns.md#6-cross-role-collaboration)
- [7. Constraints](references/method-patterns.md#7-constraints)
- [8. Error Codes](references/method-patterns.md#8-error-codes)

## Dependencies

See frontmatter `dependencies.skills` for complete dependency list.

## Error Codes

| Code | Message | Role |
|------|---------|------|
| CFO_001 | Budget overrun | CFO |
| CFO_002 | Pricing model invalid | CFO |
| CRO_001 | Risk threshold exceeded | CRO |
| CRO_002 | Circuit breaker triggered | CRO |
| CRO_003 | FAIR assessment incomplete | CRO |
| CRO_004 | Gate failure | CRO |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*
