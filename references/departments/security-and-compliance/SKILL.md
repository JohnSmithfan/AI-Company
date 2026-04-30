---
name: "AI Company Security & Compliance"
slug: "ai-company-security-and-compliance"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Security & Compliance Department: CISO, CLO. Security architecture, STRIDE threat modeling,
  CVSS scoring, incident response, legal compliance, AIGC review, IP protection, ethics governance.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-governance-and-strategy", "ai-company-platform-and-infrastructure"]
tags: [ai-company,security,compliance,ciso,clo,stride,cvss,incident,aigc,legal]
triggers:
  - security and compliance
  - security review
  - STRIDE assessment
  - CVSS scoring
  - incident response
  - legal compliance
  - AIGC review
  - ethics governance
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        role:
          type: string
          enum: [ciso, clo]
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
    - code: CISO_001
      message: "Security gate blocked"
    - code: CISO_002
      message: "CVSS score critical"
    - code: CISO_003
      message: "STRIDE threat detected"
    - code: CISO_004
      message: "Incident response required"
    - code: CLO_001
      message: "Compliance violation"
    - code: CLO_006
      message: "AIGC review failed"
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
  category: security
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: security-and-compliance
  merged_from: [ai-company-ciso, ai-company-ciso-security-gate, ai-company-clo, ai-company-clo-compliance-checker, ai-company-legal]
---

# AI Company Security & Compliance

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Security & Compliance

### Roles
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **CISO** | L5 (Security Authority) | CISO-001 | CEO-001 |
| **CLO** | L4 (Legal Authority) | CLO-001 | CEO-001 |

### Merged From
[ai-company-ciso, ai-company-ciso-security-gate, ai-company-clo, ai-company-clo-compliance-checker, ai-company-legal]

## Section Index

- [1. Trigger Scenarios](references/method-patterns.md#1-trigger-scenarios)
- [2. Core Identity](references/method-patterns.md#2-core-identity)
- [3. Role Index](references/method-patterns.md#3-role-index)
- [4. CISO: Security Operations](references/method-patterns.md#4-ciso-security-operations)
- [5. CLO: Legal Compliance](references/method-patterns.md#5-clo-legal-compliance)
- [6. Cross-Role Collaboration](references/method-patterns.md#6-cross-role-collaboration)
- [7. Constraints](references/method-patterns.md#7-constraints)
- [8. Error Codes](references/method-patterns.md#8-error-codes)

## Dependencies

See frontmatter `dependencies.skills` for complete dependency list.

## Error Codes

| Code | Message | Role |
|------|---------|------|
| CISO_001 | Security gate blocked | CISO |
| CISO_002 | CVSS score critical | CISO |
| CISO_003 | STRIDE threat detected | CISO |
| CISO_004 | Incident response required | CISO |
| CLO_001 | Compliance violation | CLO |
| CLO_006 | AIGC review failed | CLO |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*