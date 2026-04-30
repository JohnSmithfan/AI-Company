---
name: "AI Company Governance & Strategy"
slug: "ai-company-governance-and-strategy"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Governance & Strategy Department: CEO, COO, HQ. Strategic direction, operational execution,
  cross-agent coordination, crisis management, board governance, SLA management, resource scheduling.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-framework"]
tags: [ai-company,governance,strategy,ceo,coo,hq,crisis,orchestration,sla,remote-governance]
triggers:
  - governance and strategy
  - strategic planning
  - CEO decision
  - COO operations
  - cross-agent coordination
  - crisis management
  - board governance
  - SLA management
  - resource scheduling
  - branch office rollout
  - branch autonomy decision
  - remote governance
  - remote decision-making
  - cross-border compliance
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        role:
          type: string
          enum: [ceo, coo, hq]
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
    - code: CEO_006
      message: "Strategic alignment check failed"
    - code: CEO_007
      message: "Escalation timeout"
    - code: CEO_009
      message: "Branch rollout criteria not met"
    - code: CEO_010
      message: "Branch autonomy violation detected"
    - code: CEO_011
      message: "Remote decision quorum not met"
    - code: CEO_012
      message: "Cross-border data transfer violation"
    - code: CEO_013
      message: "Remote audit evidence insufficient"
    - code: CEO_014
      message: "Branch emergency remote authority abused"
    - code: CEO_015
      message: "Video conference recording failed"
    - code: COO_001
      message: "SLA breach detected"
    - code: HQ_001
      message: "Agent conflict unresolved"
    - code: HQ_002
      message: "Knowledge base sync failed"
    - code: HQ_005
      message: "Cross-agent routing failed"
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
  category: governance
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: governance-and-strategy
  merged_from: [ai-company-ceo, ai-company-coo, ai-company-hq]
---

# AI Company Governance & Strategy

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Governance & Strategy

### Roles
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **CEO** | L5 (Executive Authority) | CEO-001 | Board of Directors |
| **COO** | L4 (Closed-Loop Execute) | COO-001 | CEO-001 |
| **HQ** | L5 (Infrastructure Authority) | HQ-000 | CEO-001 |

### Merged From
[ai-company-ceo, ai-company-coo, ai-company-hq]

## Section Index

- [1. Trigger Scenarios](references/method-patterns.md#1-trigger-scenarios)
- [2. Core Identity](references/method-patterns.md#2-core-identity)
- [3. Role Index](references/method-patterns.md#3-role-index)
- [4. CEO: Strategic Planning](references/method-patterns.md#4-ceo-strategic-planning)
- [5. COO: Operational Management](references/method-patterns.md#5-coo-operational-management)
- [6. HQ: Infrastructure Hub](references/method-patterns.md#6-hq-infrastructure-hub)
- [7. Cross-Role Collaboration](references/method-patterns.md#7-cross-role-collaboration)
- [8. Constraints](references/method-patterns.md#8-constraints)
- [9. Error Codes](references/method-patterns.md#9-error-codes)

## Dependencies

See frontmatter `dependencies.skills` for complete dependency list.

## Error Codes

| Code | Message | Role |
|------|---------|------|
| CEO_006 | Strategic alignment check failed | CEO |
| CEO_007 | Escalation timeout | CEO |
| CEO_009 | Branch rollout criteria not met | CEO |
| CEO_010 | Branch autonomy violation detected | CEO |
| COO_001 | SLA breach detected | COO |
| HQ_001 | Agent conflict unresolved | HQ |
| HQ_002 | Knowledge base sync failed | HQ |
| HQ_005 | Cross-agent routing failed | HQ |
| CEO_005 | Crisis protocol activation failed | CEO |
| COO_004 | Resource allocation failed | COO |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*
