---
name: "AI Company Platform & Infrastructure"
slug: "ai-company-platform-and-infrastructure"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Platform & Infrastructure Department: Framework. Unified engineering framework combining
  standards, modularization, generalization, ecosystem, registry, learning, CI/CD, ADR,
  10 core code templates, and 3 prompt frameworks (CRISPE/3WEH/Five-Element).
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-governance-and-strategy"]
tags: [ai-company,platform,infrastructure,framework,standards,modular,harness,ci-cd,registry]
triggers:
  - platform and infrastructure
  - framework standards
  - schema compliance
  - modularization
  - harness engineering
  - CI/CD pipeline
  - code templates
  - prompt frameworks
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        module:
          type: string
          enum: [standards, modular, general, ecosystem, registry, learning, starter, harness, adr, cicd, ops, templates, prompts, compliance, auto]
          description: Which framework module to invoke
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
    - code: FW_001
      message: "Schema validation failed"
    - code: FW_002
      message: "Modularization violation"
    - code: FW_003
      message: "Registry lookup failed"
    - code: FW_006
      message: "Harness constraint violation"
    - code: FW_007
      message: "CI/CD pipeline failed"
    - code: FW_009
      message: "Security compliance violation"
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
  category: infrastructure
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: platform-and-infrastructure
  merged_from: [ai-company-framework, ai-company-harness, ai-company-standardization, ai-company-modularization, ai-company-generalization, ai-company-ecosystem, ai-company-registry, ai-company-skill-learner, ai-company-starter, ai-company-harness-ops, ai-company-harness-strategist]
---

# AI Company Platform & Infrastructure

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Platform & Infrastructure

### Role
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **Framework** | L5 (Infrastructure Authority) | FW-000 | CTO-001 |

### Merged From
[ai-company-framework, ai-company-harness, ai-company-standardization, ai-company-modularization, ai-company-generalization, ai-company-ecosystem, ai-company-registry, ai-company-skill-learner, ai-company-starter, ai-company-harness-ops, ai-company-harness-strategist]

## Module Index

| Module | Description | Key Features |
|--------|-------------|--------------|
| **Standards** | Schema compliance, naming conventions | ClawHub Schema v1.0, semver, English-only |
| **Modular** | Single responsibility, interface segregation | Max 5 dependencies, no circular deps |
| **General** | Reusability levels L1-L4 | Target: L3+ for all skills |
| **Ecosystem** | Interoperability, health metrics | 100% dependency resolution |
| **Registry** | Agent and skill discovery | Registration, versioning, deprecation |
| **Learning** | Skill acquisition pipeline | 8-step process from gap to activation |
| **Starter** | Quick-start templates | <30min setup for new company |
| **Harness** | L1-L6 engineering compliance | Full coverage verification |
| **ADR** | Architecture decision records | Template, process, compliance |
| **CI/CD** | Deployment pipeline | Canary, rollback, monitoring |
| **Ops** | Runbooks, procedures | Standard template, escalation |
| **Templates** | 10 core code templates | validate, sanitize, execute, etc. |
| **Prompts** | 3 prompt frameworks | CRISPE, 3WEH, Five-Element |
| **Compliance** | Security verification | VirusTotal, AIGC labeling, robustness |

## Section Index

- [1. Trigger Scenarios](references/method-patterns.md#1-trigger-scenarios)
- [2. Core Identity](references/method-patterns.md#2-core-identity)
- [3. Core Responsibilities](references/method-patterns.md#3-core-responsibilities)
- [4. Core Code Templates](references/method-patterns.md#4-core-code-templates)
- [5. Prompt Frameworks](references/method-patterns.md#5-prompt-frameworks)
- [6. Compliance Verification](references/method-patterns.md#6-compliance-verification)
- [7. Constraints](references/method-patterns.md#7-constraints)
- [8. Error Codes](references/method-patterns.md#8-error-codes)

## Dependencies

See frontmatter `dependencies.skills` for complete dependency list.

## Error Codes

| Code | Message |
|------|---------|
| FW_001 | Schema validation failed |
| FW_002 | Modularization violation |
| FW_003 | Registry lookup failed |
| FW_006 | Harness constraint violation |
| FW_007 | CI/CD pipeline failed |
| FW_009 | Security compliance violation |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*