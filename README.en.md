# ai-company

[![Version](https://img.shields.io/badge/version-2.0.0-blue)](CHANGELOG.md)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Scale tier](https://img.shields.io/badge/scale_tier-small-teal)](references/scaling.md)
[![CI](https://github.com/JohnSmithfan/AI-Company/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/JohnSmithfan/AI-Company/actions/workflows/ci.yml)

**An LLM Agent governance skill — small tier: 5 departments, 18 function
blocks, one installable skill package.**

English | [简体中文](README.zh.md)

> `README.en.md` is an identical English copy of this file, kept so the
> `.en` / `.zh` language suffixes stay symmetric for i18n tooling.

## Contents

- [Quick Start](#quick-start)
- [Package at a glance](#package-at-a-glance)
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [Upgrading](#upgrading)
- [License](#license)

## Quick Start

1. **Install** — copy the `ai-company/` folder into your agent's
   skills workspace.
2. **Activate** — the skill registers through its single runtime entry point,
   `SKILL.md`; no other file participates in routing or activation.
3. **Use** — ask your agent a governance or delivery question; it routes via
   `SKILL.md` to the relevant department specification under
   `references/departments/`.
4. **Human mode** — copy a ready-made prompt from
   `prompts/01-implement-method.md` or `prompts/02-robustness-checks.md` into
   any AI chat window. Both files are `human-paste` mode and reference no
   internal paths.
5. **Verify** — run `python tests/test-method-patterns.py`, and check tier
   readiness with `powershell -ExecutionPolicy Bypass -File
   scripts/self-scale.ps1 -Action evaluate` (a default Windows execution policy
   refuses unsigned `.ps1` files).

## Package at a glance

| Item | Value |
|---|---|
| Skill name | `ai-company` |
| Version | 2.0.0 |
| Scale tier | `small` (S) |
| Departments | 5 (`governance-and-operations`, `quality-and-delivery`, `technology-and-platform`, `security-and-compliance`, `people-and-growth`) |
| Function blocks | 18 (6 + 2 + 3 + 3 + 4) |
| Total files | 30 |
| License | GPL-3.0 |

## Project Structure

```text
ai-company/
├── .editorconfig
├── .gitattributes
├── .gitignore
├── .scaling-state.json
├── AGENTS.md
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README-FOR-AI.md
├── README.en.md
├── README.md
├── README.zh.md
├── SECURITY.md
├── SKILL.md
├── _meta.json
├── prompts/
│   ├── 01-implement-method.md
│   ├── 02-robustness-checks.md
│   └── 03-test-cases.md
├── references/
│   ├── method-patterns.md
│   ├── error-codes.md
│   ├── scaling.md
│   └── departments/
│       ├── governance-and-operations.md
│       ├── quality-and-delivery.md
│       ├── technology-and-platform.md
│       ├── security-and-compliance.md
│       └── people-and-growth.md
├── scripts/
│   ├── self-scale.ps1
│   └── scaling-config.json
└── tests/
    └── test-method-patterns.py

```

> Structure tree rewritten to the 30-file small-tier skeleton by the upgrade generator - requires human review before installation.

The tree lists the **package file set**: repository tooling directories
(`.git/`, `.github/`, `.workbuddy/`, `.skill-upgrade/`) are not package content
and are excluded from the count (`README-FOR-AI.md` §3).

## Documentation

- [CONTRIBUTING.md](CONTRIBUTING.md) — branch, commit, test, and PR rules
- [SECURITY.md](SECURITY.md) — supported versions and vulnerability reporting
- [CHANGELOG.md](CHANGELOG.md) — release history
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — community standards
- `AGENTS.md` — entry point for coding agents maintaining this repository
  (does not participate in skill routing)
- `README-FOR-AI.md` — generation & maintenance spec for LLM Agents
  (self-contained and authoritative for this standalone project; no external
  spec is required)

## Upgrading

This package is designed to grow. `scripts/self-scale.ps1 -Action evaluate`
checks tier readiness against `scripts/scaling-config.json`. With no threshold
hit it writes back only its own bookkeeping fields to `.scaling-state.json`
(`next_evaluation`, `last_metrics`, `metrics_provenance`,
`routing_miss_streak`, `validation`). When a threshold *does* hit it also
generates a pending upgrade package under
`{WORKSPACE_ROOT}/.skill-upgrade/<timestamp>/` and records it in
`pending_proposals` — it still never installs anything and never modifies skill
content. The
actual upgrade always requires human approval and is recorded in
`.scaling-state.json`. Thresholds, paths, and aliases are specified in
[references/scaling.md](references/scaling.md); the scale-tier ladder itself is
defined locally in `README-FOR-AI.md` §1.

## License

Copyright (c) 2026. Licensed under the
[GNU General Public License v3.0](LICENSE).
