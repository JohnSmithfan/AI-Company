---
name: "AI Company Technology & Engineering"
slug: "ai-company-technology-and-engineering"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Technology & Engineering Department: CTO. Technical architecture, AI infrastructure,
  MLOps, agent factory, skill builder, software engineering, production operations.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-governance-and-strategy", "ai-company-framework"]
tags: [ai-company,technology,engineering,cto,architecture,mlops,agent-factory,skill-builder,remote-communication]
triggers:
  - technology and engineering
  - technical architecture
  - AI infrastructure
  - MLOps
  - agent factory
  - skill builder
  - software engineering
  - production deployment
  - headquarters-branch model
  - branch office rollout
  - branch autonomy
  - remote communication
  - cross-region deployment
  - distributed architecture
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
    - code: CTO_001
      message: "Architecture violation"
    - code: CTO_002
      message: "Agent creation failed"
    - code: CTO_003
      message: "Skill build failed"
    - code: CTO_005
      message: "MLOps pipeline error"
    - code: CTO_006
      message: "Deployment failed"
    - code: CTO_009
      message: "Branch creation failed"
    - code: CTO_010
      message: "Branch permission escalation"
    - code: CTO_011
      message: "Branch-HQ sync failed"
    - code: CTO_012
      message: "Branch autonomy violation"
    - code: CTO_013
      message: "Remote connection failed"
    - code: CTO_014
      message: "Cross-region latency >SLA"
    - code: CTO_015
      message: "Branch communication timeout"
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
  category: technology
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: technology-and-engineering
  merged_from: [ai-company-cto, ai-company-cto-agentfactory, ai-company-cto-skill-builder, ai-company-engr]
---

# AI Company Technology & Engineering

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Technology & Engineering

### Role
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **CTO** | L4 (Technical Authority) | CTO-001 | CEO-001 |

### Merged From
[ai-company-cto, ai-company-cto-agentfactory, ai-company-cto-skill-builder, ai-company-engr]

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
| CTO_001 | Architecture violation |
| CTO_002 | Agent creation failed |
| CTO_003 | Skill build failed |
| CTO_005 | MLOps pipeline error |
| CTO_006 | Deployment failed |
| CTO_009 | Branch creation failed |
| CTO_010 | Branch permission escalation |
| CTO_011 | Branch-HQ sync failed |
| CTO_012 | Branch autonomy violation |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*