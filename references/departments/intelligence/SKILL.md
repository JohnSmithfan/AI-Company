---
name: "AI Company Intelligence"
slug: "ai-company-intelligence"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Intelligence Department: Intel. Strategic intelligence, threat assessment, OSINT/HUMINT/SIGINT
  collection, records management, STRIDE-based information security. Includes Sentiment Analysis Team
  with 5 specialized agents for social media monitoring.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-governance-and-strategy", "ai-company-platform-and-infrastructure"]
tags: [ai-company,intelligence,analysis,OSINT,HUMINT,SIGINT,threat-assessment,sentiment]
triggers:
  - intelligence operations
  - strategic intelligence
  - threat assessment
  - OSINT
  - HUMINT
  - SIGINT
  - sentiment analysis
  - intel department
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        component:
          type: string
          enum: [director, analysis, collection, operations, security, sentiment]
          description: Which Intel component to invoke
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
    - code: INTEL_011
      message: "Component degraded"
    - code: INTEL_012
      message: "Security violation"
    - code: INTEL_013
      message: "Source compromised"
    - code: INTEL_014
      message: "Classification breach"
permissions:
  files:
    read: ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
  network: []  # Network access delegated to parent ai-company skill
  commands: []
  mcp: [sessions_send, subagents]
quality:
  saST: Pass
  vetter: Approved
  idempotent: true
metadata:
  category: intelligence
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: intelligence
  merged_from: [ai-company-intel, ai-company-intel-director, ai-company-intel-analysis, ai-company-intel-collection, ai-company-intel-operations, ai-company-intel-security, ai-company-sentiment-analysis-team]
---

# AI Company Intelligence

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Intelligence

### Components
| Component | Trigger Keywords | Clearance | Reports To |
|-----------|-----------------|-----------|------------|
| **Director** | strategic planning, resource allocation, HQ reporting | TOP SECRET | HQ |
| **Analysis** | threat assessment, ACH, forecasting, synthesis | SECRET to UNCLASSIFIED | Director |
| **Collection** | OSINT, HUMINT, SIGINT, source management | SECRET to UNCLASSIFIED | Director |
| **Operations** | records, archival, sysadmin, training, onboarding | SECRET | Director |
| **Security** | STRIDE, RBAC, classification, incident response | TOP SECRET to CONFIDENTIAL | Director |
| **Sentiment** | social media monitoring, sentiment analysis | UNCLASSIFIED | Director |

### Merged From
[ai-company-intel, ai-company-intel-director, ai-company-intel-analysis, ai-company-intel-collection, ai-company-intel-operations, ai-company-intel-security, ai-company-sentiment-analysis-team]

## Section Index

- [1. Trigger Scenarios](references/method-patterns.md#1-trigger-scenarios)
- [2. Core Identity](references/method-patterns.md#2-core-identity)
- [3. Component Index](references/method-patterns.md#3-component-index)
- [4. Director: Strategic Leadership](references/method-patterns.md#4-director-strategic-leadership)
- [5. Analysis: Threat Assessment](references/method-patterns.md#5-analysis-threat-assessment)
- [6. Collection: OSINT/HUMINT/SIGINT](references/method-patterns.md#6-collection-osint-humint-sigint)
- [7. Operations: Records Management](references/method-patterns.md#7-operations-records-management)
- [8. Security: Information Security](references/method-patterns.md#8-security-information-security)
- [9. Sentiment Analysis Team](references/method-patterns.md#9-sentiment-analysis-team)
- [10. Constraints](references/method-patterns.md#10-constraints)
- [11. Error Codes](references/method-patterns.md#11-error-codes)

## Dependencies

See frontmatter `dependencies.skills` for complete dependency list.

## Error Codes

| Code | Message |
|------|---------|
| INTEL_011 | Component degraded |
| INTEL_012 | Security violation |
| INTEL_013 | Source compromised |
| INTEL_014 | Classification breach |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)
- [s03-test-cases-sentiment.md](prompts/s03-test-cases-sentiment.md)
- [s04-documentation-sentiment.md](prompts/s04-documentation-sentiment.md)
- [s05-workflow-execution-sentiment.md](prompts/s05-workflow-execution-sentiment.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*