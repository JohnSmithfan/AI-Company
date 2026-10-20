# AI Company — Large Tier

[![Version](https://img.shields.io/badge/version-4.0.0-blue)](CHANGELOG.md)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Scale tier](https://img.shields.io/badge/scale_tier-large-teal)](references/scaling.md)

> Unified AI company governance skill. **18 departments across 7 domains**, 117 error codes,
> 10 shared code templates, self-scaling with human-approved upgrades.
> Version **4.0.0** · Scale tier `large` · License GPL-3.0

English | [简体中文](README.zh.md)

> `README.en.md` is an identical English copy of this file, kept so the
> `.en` / `.zh` language suffixes stay symmetric for i18n tooling.

| | |
|---|---|
| Version | **4.0.0** (major 4 = tier ordinal for `large`) |
| Scale tier | `large` — 50–200 agents, multiple product lines |
| Departments | **18**, grouped into **7 domains** |
| Function blocks | **18** |
| Error codes | **117** across 19 prefixes (18 department + `SCL_`) |
| Files | **148** |
| Disclosure layers | D1 frontmatter → D2 department pages → D3 department subdirectories |
| Self-scaling | ✅ propose-only; can propose an upgrade to `group` (36 departments) |

## What This Package Does

It models an all-AI-employee technology company as a governance specification. An incoming task is
matched against triggers, routed through a **domain → department** two-level lookup, and answered
from that department's specification: responsibilities with SLAs, error codes with resolution
steps, constraints, and quantified quality metrics.

Every department draws on the same 10 audited Python templates, whose implementations live in
exactly one place — [references/method-patterns.md](references/method-patterns.md) §3.

## Department Index

| Domain | Departments | Prefixes |
|---|---|---|
| `governance` 治理与战略 | executive-strategy · operations-coordination · board-and-branch | CEO_ COO_ BRD_ |
| `finance` 财务与风险 | finance-treasury · risk-audit · procurement-billing | CFO_ CRO_ PRC_ |
| `technology` 技术与工程 | engineering-tooling · platform-mlops · model-data | CTO_ FW_ MDL_ |
| `security` 安全与合规 | security-resilience · legal-privacy · incident-identity | CISO_ CLO_ IRP_ |
| `people` 人与文化 | lifecycle-training · knowledge-ethics | CHO_ KNM_ |
| `growth` 增长与情报 | marketing-partnerships · intelligence-sentiment | CMO_ INTEL_ |
| `delivery` 交付与质量 | quality-visualization · delivery-scheduling | CQO_ PMGR_ |

Full table with roles, functions and per-department links:
[references/department-index.md](references/department-index.md)

## Project Structure

This tree matches the package file set on disk. 148 files.

```text
ai-company/
├── models/
│   ├── adapters/
│   │   └── adapter_interface.py
│   ├── api/
│   │   ├── anthropic/
│   │   │   └── claude-3-5-sonnet.json
│   │   ├── ollama/
│   │   │   ├── codellama.json
│   │   │   ├── llama3.3.json
│   │   │   ├── mistral.json
│   │   │   └── phi3.json
│   │   ├── openai/
│   │   │   └── gpt-4o.json
│   │   └── template/
│   │       └── config.json
│   ├── config/
│   │   ├── calling-policy.json
│   │   └── models-registry.json
│   ├── local/
│   │   ├── llama-3.3-70b/
│   │   │   └── config.json
│   │   └── template/
│   │       └── config.json
│   └── README.md
├── prompts/
│   ├── 01-implement-method.md
│   ├── 02-robustness-checks.md
│   ├── 03-test-cases.md
│   └── 04-documentation.md
├── references/
│   ├── data/
│   │   ├── financial-news.md
│   │   ├── information-fusion.md
│   │   └── schema-security.md
│   ├── departments/
│   │   ├── board-and-branch/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── delivery-scheduling/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── engineering-tooling/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── executive-strategy/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── finance-treasury/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── incident-identity/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── intelligence-sentiment/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── knowledge-ethics/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── legal-privacy/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── lifecycle-training/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── marketing-partnerships/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── model-data/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── operations-coordination/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── platform-mlops/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── procurement-billing/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── quality-visualization/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── risk-audit/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── security-resilience/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── board-and-branch.md
│   │   ├── delivery-scheduling.md
│   │   ├── engineering-tooling.md
│   │   ├── executive-strategy.md
│   │   ├── finance-treasury.md
│   │   ├── incident-identity.md
│   │   ├── intelligence-sentiment.md
│   │   ├── knowledge-ethics.md
│   │   ├── legal-privacy.md
│   │   ├── lifecycle-training.md
│   │   ├── marketing-partnerships.md
│   │   ├── model-data.md
│   │   ├── operations-coordination.md
│   │   ├── platform-mlops.md
│   │   ├── procurement-billing.md
│   │   ├── quality-visualization.md
│   │   ├── risk-audit.md
│   │   └── security-resilience.md
│   ├── exec/
│   │   ├── command-center.md
│   │   ├── error-recovery.md
│   │   ├── modes-triggers.md
│   │   └── workflows-schema.md
│   ├── mem/
│   │   ├── architecture.md
│   │   └── management-compliance.md
│   ├── viz/
│   │   ├── chart-types.md
│   │   ├── integration-compliance.md
│   │   ├── mermaid-diagrams.md
│   │   └── report-templates.md
│   ├── data-integration.md
│   ├── department-index.md
│   ├── error-codes.md
│   ├── execution.md
│   ├── integrations.md
│   ├── memory.md
│   ├── method-patterns.md
│   ├── scaling.md
│   └── visualization.md
├── scripts/
│   ├── scaling-config.json
│   └── self-scale.ps1
├── tests/
│   └── test-method-patterns.py
├── .editorconfig
├── .gitattributes
├── .gitignore
├── .scaling-state.json
├── AGENTS.md
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README.en.md
├── README.md
├── README.zh.md
├── README_FOR_AI.md
├── SECURITY.md
├── SKILL.md
└── _meta.json
```

## Installation

Copy this directory into your skills folder. No build step, no dependencies beyond Python 3.9+
for the test suite (`jsonschema` is optional and degrades gracefully).

```powershell
# user-level
Copy-Item -Recurse ai-company "$env:USERPROFILE\.agents\skills\"

# project-level
Copy-Item -Recurse ai-company ".\your-project\.agents\skills\"
```

⚠️ The paths above are installation examples for a user's own machine. Nothing inside the package
hardcodes an absolute user path — package files use the `{SKILL_DIR}` and `{WORKSPACE_ROOT}`
placeholders exclusively.

## Verification

Run these after installation. All must pass.

```powershell
cd <your skills folder>\ai-company

# 1. Test suite - must exit 0
$env:SKILL_DIR = (Get-Location).Path
python tests\test-method-patterns.py

# 2. Template code compiles
python -m py_compile models\adapters\adapter_interface.py

# 3. Model registry: all 7 config paths resolve
python models\adapters\adapter_interface.py     # expect "config paths ok : 7/7"

# 4. Self-scaling status
pwsh -File scripts\self-scale.ps1 -Action status

# 5. Upgrade threshold evaluation (read-only, writes nothing)
pwsh -File scripts\self-scale.ps1 -Action evaluate
```

## Usage

### Automatic routing

The skill activates on trigger match and routes by itself:

```text
task: "Review the Q2 budget and assess risk exposure"
  → triggers match (budget overrun review, risk assessment)
  → domain: finance
  → department: finance-treasury (CFO_)
  → answers from references/departments/finance-treasury.md
```

### Explicit routing

```text
department: risk-audit
domain: security            # optional; narrows the search
task: "Run a STRIDE threat model on the authentication service"
```

### Example tasks

| Task | Domain | Department |
|---|---|---|
| Review the Q2 budget and assess risk exposure | finance | `finance-treasury` |
| Run a STRIDE threat model on the authentication service | security | `security-resilience` |
| Create a new agent following Harness L1–L6 constraints | technology | `platform-mlops` |
| Translate the marketing copy to Japanese with cultural adaptation | delivery | `delivery-scheduling` |
| Assess whether this skill should grow to group tier | governance | `platform-mlops` + `board-and-branch` |

### Regenerating this package with an AI

Normal users can skip this — installing the directory is enough. Maintainers and
auditors can hand [README_FOR_AI.md](README_FOR_AI.md) to any LLM agent: it is the
self-contained generation specification for this exact package (large tier, 148
files) and needs no external document. The agent follows the 14-step workflow in
its §4, then must pass the §15 acceptance checklist and the test suite before the
result counts as this package. This is a repository-level rebuild by a
human-directed agent — it is unrelated to the skill's runtime propose-only
self-scaling, and it does not bypass human approval. The specification is
tier-locked to `large`: regenerating another tier requires that tier's own
specification.

## Self-Scaling (propose-only)

This package can detect that it has outgrown its tier and **propose** an upgrade. It never
installs one.

```text
① PROPOSE   the skill: evaluates thresholds → derives the path from the merge tree →
            builds a complete package at {WORKSPACE_ROOT}/.skill-upgrade/<timestamp>/
            ★ reads {SKILL_DIR} only; writes not one byte of itself
② APPROVE   a human: reviews UPGRADE-PROPOSAL.md, the change list, the diff, the gates
③ INSTALL   an external trusted installer: applies the package
```

| Setting | Value |
|---|---|
| Policy | `propose-only` — no `auto-install` value exists |
| Upgrade path | `large` → `group` (18 → 36 departments, 18 → 36 function blocks) |
| Evaluation interval | 30 days, or on demand |
| Triggers | T1 agent count > 200 × headroom (host-supplied) · T2 blocks/department > mean × 1.5 · T3 routing accuracy < 85 % ×3 · T4 error-code reuse > 25 % |
| Gates | G1 permissions · G2 tests · G3 deny + gate logic · G4 conservation · G5 aliases · G6 acceptance |

⚠️ **G1–G3 cannot be waived, not even by human approval.** A human approves a business scale
change; a human is not the right control for a security boundary change. If permission edits were
approvable, one prompt injection would only need a single "agree" click to dissolve every
constraint this package has.

⚠️ A proposal is **not applied**. Until a human approves and an external installer runs, this
package remains at 18 departments.

Full specification: [references/scaling.md](references/scaling.md)

## Constraints

- ❌ Never write inside `{SKILL_DIR}` — the package directory is read-only, including during upgrades
- ❌ Never modify `permissions`, the `deny` list, `tests/**` or the gate logic in `self-scale.ps1`
- ❌ Never inline shared template code outside `references/method-patterns.md`
- ❌ Never hardcode an absolute user path — use `{SKILL_DIR}` / `{WORKSPACE_ROOT}`
- ❌ Never emit a secret value — configuration holds environment variable **names** only
- ❌ Never auto-install an upgrade or auto-execute a downgrade
- ❌ Never render a data gap as zero, or serve stale data as if fresh

## Quality Metrics

| Metric | Threshold | Verified by |
|---|---|---|
| Department count | exactly 18 | test suite + `department-index.md` |
| Function blocks | exactly 18 | `^## FB-\d+:` count |
| File count | exactly 148 | package file set: excludes `.git/` `.github/` `.workbuddy/` `.skill-upgrade/` `__pycache__/` `*.pyc` |
| frontmatter lines | ≤ 150 (actual 149) | delimiter position |
| `description` length | ≤ 1024 chars | frontmatter parse |
| Error-code numbering | no gaps within any prefix | regex sweep |
| Broken relative links | 0 | link resolution sweep |
| Model registry paths | 7/7 resolve | adapter self-check |
| Test suite | exit 0 | `python tests/test-method-patterns.py` |

## Design Notes

Three decisions in this package exist because a predecessor got them wrong:

| Decision | The defect it prevents |
|---|---|
| Template code in exactly one place (`method-patterns.md` §3) | The predecessor shipped two divergent copies and an index line too vague to adjudicate between them |
| Masking covers EMAIL, IP **and** PHONE | The predecessor's authoritative source lacked the PHONE branch while its contract and tests named it; the suite stayed green because it carried an inlined copy |
| Sub-manifests named `department-spec.md`, never `SKILL.md` | The predecessor's 11 sub-manifests carried independent `name` and `triggers` fields and would be registered as 11 separate skills by any recursive loader |

## License

GNU GPL v3 — see [LICENSE](LICENSE).

| | |
|---|---|
| Free to use, modify and distribute | ✅ |
| Derivatives must remain GPL v3 | ✅ (copyleft) |
| Patent grant | ✅ (Section 11) |
| Proprietary relicensing of derivatives | ❌ |

Copyright © 2026 AI Company Team

## Changelog

See [CHANGELOG.md](CHANGELOG.md). Contributing rules — how to add a department, an error code or a
workflow — are in [CONTRIBUTING.md](CONTRIBUTING.md).
