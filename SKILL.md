---
name: "ai-company-unified"
slug: "ai-company-unified"
version: "1.0.6"
description: |
  Unified AI Company skill consolidating 16 department skills into one. Provides complete
  governance, finance, technology, security, legal, people, marketing, quality, intelligence
  (including Sentiment Analysis Team), information, and translation capabilities for all-AI-employee
  technology companies. Includes 10 core code templates, 3 prompt frameworks (CRISPE/3WEH/Five-Element),
  L1-L6 harness engineering, CI/CD pipeline, ADR process, AIGC compliance, VirusTotal/ClawHub security
  verification, progressive disclosure architecture, headquarters-branch distributed deployment,
  and remote communication architecture. Use when any AI-Company department
  function is needed — this skill contains all of them.
license: "GPL-3.0"
author: "AI Company Team"
tags: [ai-company,governance,finance,technology,security,legal,people,marketing,quality,intelligence,information,translation,framework,L1-L6,compliance,headquarters-branch,remote-communication]
dependencies: []
triggers:
  - AI company management
  - company strategy
  - CEO decision
  - strategic approval
  - crisis response
  - cross-department coordination
  - daily operations
  - process optimization
  - resource scheduling
  - SLA management
  - financial management
  - budget approval
  - pricing model
  - risk assessment
  - circuit breaker
  - technical architecture
  - agent creation
  - skill building
  - production deployment
  - schema compliance
  - skill standardization
  - L1-L6 constraints
  - CI/CD pipeline
  - code template
  - prompt template
  - CRISPE framework
  - robustness check
  - AIGC labeling
  - security gate
  - STRIDE threat model
  - legal compliance
  - contract review
  - agent lifecycle
  - knowledge extraction
  - marketing strategy
  - skill discovery
  - quality gate
  - project management
  - intelligence operations
  - intelligence collection
  - intelligence library
  - location service
  - weather forecast
  - translation
  - headquarters-branch model
  - branch office rollout
  - branch autonomy
  - HQ-branch architecture
  - remote communication
  - cross-region deployment
  - distributed architecture
  - remote governance
  - cross-border compliance
  - branch remote connection
  - model management
  - LLM integration
  - model calling
  - model registry
  - model governance
  - model access control
  - ollama
  - ollama model
  - local LLM
  - ollama inference
  - run ollama
  - ollama integration
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        task:
          type: string
          description: Task description
        department:
          type: string
          enum: [governance-and-strategy, finance-and-risk, technology-and-engineering, platform-and-infrastructure, security-and-compliance, people-and-culture, marketing-and-partnerships, quality-and-operations, intelligence, information, translation-and-localization, auto]
          description: Which department to invoke
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
    - code: CEO_001
      message: "Decision requires data"
    - code: CEO_002
      message: "Insufficient authority"
    - code: CEO_003
      message: "Cross-agent conflict"
    - code: CEO_004
      message: "Orchestration pipeline failed"
    - code: CEO_005
      message: "Crisis protocol activation failed"
    - code: CEO_006
      message: "Strategic alignment check failed"
    - code: CEO_007
      message: "Escalation timeout"
    - code: CEO_008
      message: "Crisis blacklist violation attempted"
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
    - code: CEO_E016
      message: "Model access denied"
    - code: CEO_E017
      message: "Model budget exceeded"
    - code: CEO_E018
      message: "Model security scan failed"
    - code: CEO_E019
      message: "Cross-border model transfer violation"
    - code: CEO_E020
      message: "Model lifecycle review overdue"
    - code: COO_001
      message: "SLA breach detected"
    - code: COO_002
      message: "Resource conflict"
    - code: COO_003
      message: "OKR misalignment"
    - code: COO_004
      message: "Resource allocation failed"
    - code: HQ_001
      message: "Agent conflict unresolved"
    - code: HQ_002
      message: "Knowledge base sync failed"
    - code: HQ_003
      message: "Audit trail broken"
    - code: HQ_004
      message: "Scheduling deadlock"
    - code: HQ_005
      message: "Cross-agent routing failed"
    - code: CFO_001
      message: "Budget overrun"
    - code: CFO_002
      message: "Pricing model invalid"
    - code: CFO_003
      message: "Analytics data missing"
    - code: CRO_001
      message: "Risk threshold exceeded"
    - code: CRO_002
      message: "Circuit breaker triggered"
    - code: CRO_003
      message: "FAIR assessment incomplete"
    - code: CRO_004
      message: "Gate failure"
    - code: CTO_001
      message: "Architecture violation"
    - code: CTO_002
      message: "Agent creation failed"
    - code: CTO_003
      message: "Skill build failed"
    - code: CTO_004
      message: "Production operation denied"
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
    - code: CTO_016
      message: "Model not found in registry"
    - code: CTO_017
      message: "Model config file missing"
    - code: CTO_018
      message: "Model disabled"
    - code: CTO_019
      message: "API key missing"
    - code: CTO_020
      message: "Rate limit exceeded"
    - code: CTO_021
      message: "Model invocation failed"
    - code: CTO_022
      message: "Model permission denied"
    - code: CTO_023
      message: "Model health check failed"
    - code: CTO_024
      message: "Invalid model response"
    - code: CTO_025
      message: "Model config invalid"
    - code: FW_001
      message: "Schema validation failed"
    - code: FW_002
      message: "Modularization violation"
    - code: FW_003
      message: "Registry lookup failed"
    - code: FW_004
      message: "Learning pipeline error"
    - code: FW_005
      message: "Scaffolding generation failed"
    - code: FW_006
      message: "Harness constraint violation"
    - code: FW_007
      message: "CI/CD pipeline failed"
    - code: FW_008
      message: "ADR compliance rejected"
    - code: FW_009
      message: "Security compliance violation"
    - code: FW_010
      message: "AIGC labeling missing"
    - code: CISO_001
      message: "Security gate blocked"
    - code: CISO_002
      message: "CVSS score critical"
    - code: CISO_003
      message: "STRIDE threat detected"
    - code: CISO_004
      message: "Incident response required"
    - code: CISO_005
      message: "Model security scan failed"
    - code: CLO_001
      message: "Compliance violation"
    - code: CLO_002
      message: "Contract review required"
    - code: CLO_003
      message: "AIGC content non-compliant"
    - code: CLO_004
      message: "IP protection required"
    - code: CLO_005
      message: "Ethics review required"
    - code: CLO_006
      message: "AIGC review failed"
    - code: CHO_001
      message: "Agent onboarding failed"
    - code: CHO_002
      message: "Skill gap detected"
    - code: CHO_003
      message: "Knowledge extraction failed"
    - code: CHO_004
      message: "Lifecycle violation"
    - code: CHO_005
      message: "Ethics violation"
    - code: CHO_006
      message: "Culture audit failed"
    - code: CMO_001
      message: "Brand violation"
    - code: CMO_002
      message: "Market data unavailable"
    - code: CMO_003
      message: "Discovery pipeline failed"
    - code: CMO_004
      message: "Data protection violation"
    - code: CMO_005
      message: "GTM strategy missing"
    - code: CMO_006
      message: "Partnership conflict"
    - code: CMO_007
      message: "NPS below target"
    - code: CQO_001
      message: "Quality gate failed"
    - code: CQO_002
      message: "Idempotency violation"
    - code: CQO_003
      message: "Review rejected"
    - code: CQO_004
      message: "Documentation incomplete"
    - code: CQO_005
      message: "DORA metric breach"
    - code: PMGR_001
      message: "Project deadline missed"
    - code: PMGR_002
      message: "OKR unlinked"
    - code: PMGR_003
      message: "Customer escalation"
    - code: PMGR_004
      message: "Sprint commitment failed"
    - code: PMGR_005
      message: "Task decomposition failed"
    - code: PMGR_006
      message: "NPS threshold breach"
    - code: PMGR_007
      message: "Ticket SLA violation"
    - code: INTEL_001
      message: "Intelligence collection failed"
    - code: INTEL_002
      message: "Analysis confidence low"
    - code: INTEL_003
      message: "Source verification failed"
    - code: INTEL_004
      message: "Classification violation"
    - code: INTEL_005
      message: "Operational security breach"
    - code: INTEL_006
      message: "Library structure creation failed"
    - code: INTEL_007
      message: "Source registry corrupted"
    - code: INTEL_008
      message: "Collection plan missing REQUIREMENTS"
    - code: INTEL_009
      message: "Product confidence LOW (<40%)"
    - code: INTEL_010
      message: "SITREP generation failed"
    - code: INTEL_011
      message: "Component degraded"
    - code: INTEL_012
      message: "Security violation"
    - code: INTEL_013
      message: "Source compromised"
    - code: INTEL_014
      message: "Classification breach"
    - code: INFO_001
      message: "Location unavailable"
    - code: INFO_002
      message: "Weather data unavailable"
    - code: INFO_003
      message: "Time sync failed"
    - code: INFO_004
      message: "Multi-source fusion failed"
    - code: INFO_005
      message: "API rate limit exceeded"
    - code: INFO_006
      message: "No location source available"
    - code: INFO_007
      message: "Weather API request failed"
    - code: INFO_008
      message: "Time source unavailable"
    - code: INFO_009
      message: "Required API credentials missing"
    - code: INFO_010
      message: "Invalid coordinates format"
    - code: TR_001
      message: "Translation quality below threshold"
    - code: TR_002
      message: "Language not supported"
    - code: TR_003
      message: "Cultural adaptation required"
    - code: TR_004
      message: "AIGC translation label missing"
    - code: TR_005
      message: "Language routing error"
permissions:
  files:
    read: ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
    write: ["{WORKSPACE_ROOT}/**"]
    deny: ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]
  network: []  # Sub-skills declare their own network needs
  commands: []
  mcp: [sessions_send, subagents]
quality:
  idempotent: true
metadata:
  category: enterprise
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: enterprise-all
  consolidated_from:
    - ai-company-ceo-3.0.0
    - ai-company-coo-3.0.0
    - ai-company-hq-3.0.0
    - ai-company-cfo-3.0.0
    - ai-company-cro-3.0.0
    - ai-company-cto-3.0.0
    - ai-company-framework-4.0.0
    - ai-company-ciso-3.0.0
    - ai-company-clo-3.0.0
    - ai-company-cho-3.0.0
    - ai-company-cmo-3.0.0
    - ai-company-cqo-3.0.0
    - ai-company-pmgr-3.0.0
    - ai-company-intel-4.1.0
    - ai-company-information-2.0.0
    - ai-company-translator-3.0.0
---

# AI Company v1.0.7

> Unified AI Company Skill — 16 departments consolidated into one.
> Full specifications in [references/method-patterns.md](references/method-patterns.md) and [references/departments/](references/departments/).

## Quick Reference

### What This Skill Does
Complete AI company operations: governance, finance, technology, security, legal, people, marketing, quality, intelligence, information, translation, and platform infrastructure. Use for any AI-Company function.

### Department Index

| Department | Roles | Details |
|-----------|--------|---------|
| Governance & Strategy | CEO, COO, HQ | [governance-and-strategy.md](references/departments/governance-and-strategy.md) |
| Finance & Risk | CFO, CRO | [finance-and-risk.md](references/departments/finance-and-risk.md) |
| Technology & Engineering | CTO | [technology-and-engineering.md](references/departments/technology-and-engineering.md) |
| Platform & Infrastructure | Framework | [platform-and-infrastructure.md](references/departments/platform-and-infrastructure.md) |
| Security & Compliance | CISO, CLO | [security-and-compliance.md](references/departments/security-and-compliance.md) |
| People & Culture | CHO | [people-and-culture.md](references/departments/people-and-culture.md) |
| Marketing & Partnerships | CMO | [marketing-and-partnerships.md](references/departments/marketing-and-partnerships.md) |
| Quality & Operations | CQO, PMGR | [quality-and-operations.md](references/departments/quality-and-operations.md) |
| Intelligence | Intel | [intelligence.md](references/departments/intelligence.md) |
| Information Services | Information | [information.md](references/departments/information.md) |
| Translation & Localization | Translator | [translation-and-localization.md](references/departments/translation-and-localization.md) |
| Sentiment Analysis Team | QueryEngine, MediaEngine, InsightEngine, ReportEngine, ForumEngine | [intelligence/method-patterns.md](references/departments/intelligence/references/method-patterns.md) |

## Shared Resources

- [Code Templates & Prompt Frameworks](references/method-patterns.md#shared-code-templates)
- [Compliance Verification](references/method-patterns.md#compliance-verification)
- [Constraints](references/method-patterns.md#constraints)

## Error Codes

All error codes use role-based prefix (e.g., CEO_001, CFO_001, CISO_001). See individual department files for complete error code reference and resolution steps.

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)
- [03-test-cases.md](prompts/03-test-cases.md)
- [04-documentation.md](prompts/04-documentation.md)
- [05-workflow-execution.md](prompts/05-workflow-execution.md)

## Auto-Update

This skill supports 4 update modes with 5-layer security gates.

### Update Modes

| Mode | Description | Behavior |
|------|-------------|----------|
| `auto` | Auto Update | Automatically download and install updates |
| `auto-download` | Auto Download + Notify | Download updates automatically, notify user to install |
| `notify` | Notify Only | Check for updates and notify user (no download) |
| `none` | No Auto-Update *(default)* | Only check when run manually |

### Configuration

Default mode is `none` (no auto-update). Change it via:

```powershell
# Set persistent update mode
pwsh -File scripts/auto-update.ps1 -SetMode auto          # Auto update
pwsh -File scripts/auto-update.ps1 -SetMode auto-download # Download + notify
pwsh -File scripts/auto-update.ps1 -SetMode notify        # Notify only
pwsh -File scripts/auto-update.ps1 -SetMode none          # No auto-update (default)

# Override mode for one run
pwsh -File scripts/auto-update.ps1 -Mode auto             # This run only

# View current config
pwsh -File scripts/auto-update.ps1 -ShowConfig

# Force reinstall same version
pwsh -File scripts/auto-update.ps1 -Force
```

Config file: `{SKILL_DIR}/scripts/update-config.json`

### Schedule & Backup

| Setting | Value |
|---------|-------|
| Schedule | Weekly Sunday 02:00 UTC |
| RRule | `FREQ=WEEKLY;BYDAY=SU;BYHOUR=2;BYMINUTE=0` |
| Backup Retention | 1 version |

**Security Gates**: Version Check | Backup Gate | Download Gate | Frontmatter Gate | Danger Pattern Gate

### Notifications

When an update is available, a notification file is created at `{SKILL_DIR}/.update-notification.md`. The notification includes:
- Current and available versions
- Configured update mode
- Recommended action

### Manual Update

> The update script is bundled with the skill at `{SKILL_DIR}/scripts/auto-update.ps1`.

```powershell
# Windows (PowerShell)
pwsh -File "$env:USERPROFILE\.agents\skills\ai-company\scripts\auto-update.ps1"
```

```bash
# macOS / Linux
pwsh -File "$HOME/.agents/skills/ai-company/scripts/auto-update.ps1"
```

**Logs**: `{SKILL_DIR}/.logs/auto-update-log.md`

## Changelog

[Changelog](CHANGELOG.md)

---

*This skill follows AI Company Governance Framework. See [references/](references/) for complete specifications.*