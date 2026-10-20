---
name: "ai-company"
slug: "ai-company"
version: 4.0.0
description: "Large-tier (scale_tier: large) unified AI company governance skill for 50-200 agents across multiple product lines. Routes tasks through 7 domains to 18 specialized departments (1 function block each, 18 total), with 117 error codes across 19 prefixes, a D3 specification layer per department, two-level routing, and a department index. Ships audited Python code templates as a single authoritative source, 3 prompt frameworks, and Harness L1-L6 maturity levels with AIGC triple labeling and mandatory PII masking. Supports propose-only self-scaling: the skill detects tier overflow and proposes an upgrade package, which humans approve and an external installer applies. Use when any AI-company governance, finance, engineering, security, or delivery function is needed at multi-product-line scale."
license: "GPL-3.0"
author: "AI Company Team"
tags: [ai-company, governance, finance, technology, security, people, growth, delivery, harness-l1-l6, aigc, self-scaling, two-level-routing, large-tier]
dependencies: []
triggers:
  # ── Domain 1: governance (9) ──
  - strategic decision
  - ceo decision
  - crisis response
  - board escalation
  - okr planning
  - cross-department coordination
  - sla management
  - evaluate scaling threshold
  - propose tier upgrade
  # ── Domain 2: finance (9) ──
  - budget approval
  - budget overrun review
  - pricing model
  - risk assessment
  - fair quantification
  - circuit breaker
  - capex policy
  - procurement decision
  - vendor evaluation
  # ── Domain 3: technology (10) ──
  - technical architecture
  - agent creation
  - skill building
  - production deployment
  - ci/cd pipeline
  - code template
  - adr review
  - harness constraint
  - model registry
  - data pipeline
  # ── Domain 4: security (10) ──
  - stride threat model
  - cvss scoring
  - security gate
  - incident response
  - contract review
  - aigc labeling
  - gdpr compliance
  - pii masking
  - identity access
  - business continuity
  # ── Domain 5: people (9) ──
  - agent lifecycle
  - agent onboarding
  - knowledge extraction
  - ethics review
  - capability training
  - culture audit
  - skill gap analysis
  - memory governance
  - whistleblower channel
  # ── Domain 6: growth (9) ──
  - marketing strategy
  - brand voice
  - gtm plan
  - partnership evaluation
  - nps review
  - intelligence collection
  - sitrep generation
  - sentiment analysis
  - source reliability
  # ── Domain 7: delivery (10) ──
  - quality gate
  - test coverage
  - dora metrics
  - project scheduling
  - resource scheduling
  - sprint commitment
  - ticket sla
  - translation quality
  - cultural adaptation
  - location service
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
enum: [auto, board-and-branch, delivery-scheduling, engineering-tooling, executive-strategy, finance-treasury, incident-identity, intelligence-sentiment, knowledge-ethics, legal-privacy, lifecycle-training, marketing-partnerships, model-data, operations-coordination, platform-mlops, procurement-billing, quality-visualization, risk-audit, security-resilience]
          description: Which department to invoke; omit or "auto" to auto-route
        output_language:
          type: string
          description: Override runtime output language; omit to follow the language decision chain
        context:
          type: object
          description: Optional context information
      required: [task]
  outputs:
    type: object
    schema: { type: object, properties: { result: { type: string, description: Operation result }, report: { type: object, description: Detailed report data } }, required: [result] }
errors: []
error_code_prefixes: [BRD_, CEO_, CFO_, CHO_, CISO_, CLO_, CMO_, COO_, CQO_, CRO_, CTO_, FW_, INTEL_, IRP_, KNM_, MDL_, PMGR_, PRC_, SCL_]
language_policy:
  authoring: en
  encoding: utf-8
  output: user-specified
  fallback: en
  immutable_tokens: [slug, error_code, field_name, enum_value, file_path, function_name]
self_scaling:
  enabled: true
  state_file: .scaling-state.json
  spec: references/scaling.md
  upgrade_policy: propose-only
  max_tier: group
permissions:
  files:
    read:  ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
    write: ["{WORKSPACE_ROOT}/**"]
    deny:  ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]
  network: []
  commands: []
  mcp: [sessions_send, subagents]
quality:
  idempotent: true
metadata:
  category: enterprise
  layer: AGENT
  cluster: governance
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  scale_tier: large
  department_count: 18
  function_block_count: 18
  harness_baseline: L3
department_aliases: references/scaling.md#alias-map
---


# AI Company — Large Tier

Large-tier unified AI company governance skill for 50-200 agents across multiple product
lines: 18 enterprise function blocks across 18 departments in 7 domains, a 117-code error
catalog, audited code templates, 3 prompt frameworks, and propose-only self-scaling.

> Source files are authored in English; runtime output follows the user's language (see
> `language_policy` in the frontmatter). Slugs, error codes, field names, enum values,
> file paths, and function names are never translated.

## Departments

| Domain | Departments | Prefixes |
|---|---|---|
| `governance` | executive-strategy · operations-coordination · board-and-branch | CEO_ COO_ BRD_ |
| `finance` | finance-treasury · risk-audit · procurement-billing | CFO_ CRO_ PRC_ |
| `technology` | engineering-tooling · platform-mlops · model-data | CTO_ FW_ MDL_ |
| `security` | security-resilience · legal-privacy · incident-identity | CISO_ CLO_ IRP_ |
| `people` | lifecycle-training · knowledge-ethics | CHO_ KNM_ |
| `growth` | marketing-partnerships · intelligence-sentiment | CMO_ INTEL_ |
| `delivery` | quality-visualization · delivery-scheduling | CQO_ PMGR_ |

Per-department roles, functions and D2/D3 links:
[references/department-index.md](references/department-index.md). Two-level routing
(domain, then department) is specified in
[references/execution.md](references/execution.md).

## Shared Resources

| Resource | Contents |
|---|---|
| [method-patterns.md](references/method-patterns.md) | Single authoritative source for the ten shared code templates and the CRISPE / 3WEH / Five-Element prompt frameworks |
| [error-codes.md](references/error-codes.md) | Full four-element error-code catalog for all prefixes |
| [scaling.md](references/scaling.md) | Tier thresholds, upgrade gating, alias map, forbidden-self-modification list |
| [execution.md](references/execution.md) | Execution engine: 4 modes x 4 triggers, workflows WFT-001~010, two-level routing |
| [memory.md](references/memory.md) | Memory system: 5 memory types |
| [visualization.md](references/visualization.md) | Charts, Mermaid, report templates |
| [data-integration.md](references/data-integration.md) | Financial news, information fusion, schema security |
| [integrations.md](references/integrations.md) | MCP / Webhook / REST bridge |
| [models/README.md](models/README.md) | Model registry, calling policy, adapter |

## Error Code Prefixes

| Prefix | Department |
|---|---|
| `CEO__` | executive-strategy |
| `COO__` | operations-coordination |
| `BRD__` | board-and-branch |
| `CFO__` | finance-treasury |
| `CRO__` | risk-audit |
| `PRC__` | procurement-billing |
| `CTO__` | engineering-tooling |
| `FW__` | platform-mlops |
| `MDL__` | model-data |
| `CISO__` | security-resilience |
| `CLO__` | legal-privacy |
| `IRP__` | incident-identity |
| `CHO__` | lifecycle-training |
| `KNM__` | knowledge-ethics |
| `CMO__` | marketing-partnerships |
| `INTEL__` | intelligence-sentiment |
| `CQO__` | quality-visualization |
| `PMGR__` | delivery-scheduling |
| `SCL_` | self-scaling infrastructure (fixed across tiers) |

## Prompts

| File | Mode | Purpose |
|---|---|---|
| [01-implement-method.md](prompts/01-implement-method.md) | `human-paste` | Paste into any AI chat window to have that AI implement one method to this standard |
| [02-robustness-checks.md](prompts/02-robustness-checks.md) | `human-paste` | Paste into any AI chat window to have that AI run robustness checks on a method |
| [03-test-cases.md](prompts/03-test-cases.md) | `agent-invoked` | Agent runtime generates a test-case suite for one method and writes it to {WORKSPACE_ROOT}/tests/ |
| [04-documentation.md](prompts/04-documentation.md) | `agent-invoked` | Agent runtime writes documentation for one method |

## Quick Start

1. Invoke the skill with `task` (required) and optionally `department` (`auto` routes
   through the 7 domains automatically); set `output_language` to override the runtime
   output language.
2. For implementation standards, use the shared templates in
   [method-patterns.md](references/method-patterns.md); for failures, look up codes by
   prefix in [error-codes.md](references/error-codes.md).
3. To work outside this skill, open [01-implement-method.md](prompts/01-implement-method.md)
   or [02-robustness-checks.md](prompts/02-robustness-checks.md), fill in the
   `<placeholders>`, and paste the prompt into any AI chat window.
4. When the organization grows, ask the skill to evaluate scaling thresholds or propose a
   tier upgrade; the rules live in [scaling.md](references/scaling.md).

* * *

*Generated from the README_FOR_AI.md specification, large tier (scale_tier: large), v4.0.0.*
*GPL-3.0. See [README.md](README.md) for the human-facing overview and
[CHANGELOG.md](CHANGELOG.md) for history.*
