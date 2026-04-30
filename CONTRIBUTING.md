# Contributing to AI Company Skill

> **License**: GPL-3.0 | **Version**: v1.0.6 | **Maintained by**: AI Company Governance Framework

Welcome! This document explains how to extend and contribute to the AI Company Skill — a multi-department AI agent governance framework with 11 departments and 20+ roles.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [How to Add a New Department](#how-to-add-a-new-department)
3. [How to Extend an Existing Department](#how-to-extend-an-existing-department)
4. [Code Standards](#code-standards)
5. [Testing](#testing)
6. [Pull Request Process](#pull-request-process)
7. [Error Code Registration](#error-code-registration)
8. [Versioning](#versioning)

---

## Architecture Overview

```
ai-company/
├── SKILL.md                   # Root skill index (ClawHub Schema v1.0)
├── CONTRIBUTING.md            # This file
├── CHANGELOG.md               # Single source of truth for version history
├── README.md                  # User-facing overview
├── LICENSE                    # GPL-3.0
├── _meta.json                 # ClawHub metadata
├── .clawhub/origin.json       # Installation metadata
├── prompts/                   # Root prompt templates (01-05)
├── tests/                     # Python test suite
└── references/
    ├── method-patterns.md     # Shared frameworks and patterns
    └── departments/           # 11 department modules
        ├── {dept}/
        │   ├── SKILL.md                    # Department index (ClawHub Schema v1.0)
        │   ├── references/
        │   │   └── method-patterns.md      # Department-specific patterns
        │   └── prompts/
        │       ├── 01-implement-method.md
        │       └── 02-robustness-checks.md
        └── intelligence/
            ├── departments/                # Sub-agent specs (engine files)
            └── prompts/                   # Extended sentiment prompts (s03-s05)
```

### Key Design Principles

| Principle | Description |
|-----------|-------------|
| **Progressive Disclosure** | L1 SKILL.md → L2 index → L3 focused sub-files |
| **English-Only (G1)** | All compiled content must be in English. Test fixtures are exempt with `<!-- TEST FIXTURE -->` annotation |
| **Single Source of Truth** | CHANGELOG.md only; no version numbers in references/ |
| **Role-Based Error Codes** | Prefix = role abbreviation (CEO_, CFO_, CISO_, etc.) |
| **Structured Permissions** | Use `{WORKSPACE_ROOT}/**` scoping — never legacy `[read, write]` format |
| **AIGC Compliance** | All AI-generated output must carry AIGC labeling |

---

## How to Add a New Department

### Step 1: Create directory structure

```bash
mkdir -p references/departments/{your-dept}/references
mkdir -p references/departments/{your-dept}/prompts
```

### Step 2: Create SKILL.md (ClawHub Schema v1.0)

Use the following template:

```yaml
---
name: "AI Company {Department Name}"
slug: "ai-company-{dept-slug}"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  {Department Name} Department: {Roles}. {One-sentence summary}.
license: "GPL-3.0"
agent_created: false
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-framework"]
tags: [ai-company, {dept-slug}, {role-tags}]
triggers:
  - {natural language trigger 1}
  - {natural language trigger 2}
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        role:
          type: string
          enum: [{role1}, {role2}]
          description: Which role to invoke
        task:
          type: string
          description: Task description
      required: [role, task]
  outputs:
    type: object
    schema:
      type: object
      properties:
        result:
          type: string
        status:
          type: string
          enum: [success, partial, failed]
permissions:
  files:
    read: ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
    write: ["{WORKSPACE_ROOT}/**"]
  network: []  # Network access delegated to parent ai-company skill
  commands: []
error_codes:
  - code: "{ROLE}_001"
    message: "{Error description}"
    resolution: "{How to resolve}"
---
```

### Step 3: Create method-patterns.md

Follow the existing pattern in `references/departments/governance-and-strategy/references/method-patterns.md`. Each section should include:
- Role definition
- Responsibilities
- SOPs (Standard Operating Procedures)
- Decision matrices
- AIGC Review Chain

### Step 4: Create prompts/

Create at minimum:
- `01-implement-method.md` — implementation prompt template
- `02-robustness-checks.md` — validation and edge-case checklist

### Step 5: Register in root SKILL.md

Add a row to the Department Index table in `SKILL.md` and add error codes to the Error Codes section.

### Step 6: Add to CHANGELOG.md

```markdown
## v{NEXT_VERSION} — {YYYY-MM-DD}

### Added
- **{Department Name}**: New department with {N} roles (CHO: contribution guidelines)
```

---

## How to Extend an Existing Department

### Adding a new role to a department

1. Add the role enum value to `SKILL.md` > `interface.inputs.schema.properties.role.enum`
2. Add a new section in `references/method-patterns.md` under the appropriate heading
3. Register new error codes following the pattern `{ROLE}_00N`
4. Update `CHANGELOG.md`

### Adding a new prompt

Place in `prompts/` with sequential numbering (`03-`, `04-`, etc.) and follow the existing header format.

### Adding a new reference sub-file

For large additions (> 20KB), use progressive disclosure:
1. Create a subdirectory: `references/{topic}/`
2. Create focused sub-files: `{aspect1}.md`, `{aspect2}.md`
3. Update the parent index page with a Sub-File Index table and Loading Pattern

---

## Code Standards

### Language
- **All compiled content must be in English (G1 rule)**
- Chinese is allowed only in:
  - End-user facing trigger keywords (annotate with `# TRIGGER KEYWORD: G1 exemption`)
  - Test fixtures (annotate with `<!-- TEST FIXTURE: ... -->`)

### File Size
- Keep individual files under 50KB (progressive disclosure threshold)
- Use subdirectory splits for larger content with L2 index pages

### YAML Frontmatter
- `license: "GPL-3.0"` — required
- `agent_created: false` — required (use `true` only for auto-generated skills)
- No version numbers in nested SKILL.md files — version is tracked at root only

### Error Codes
- Format: `{ROLE}_{NNN}` (3-digit zero-padded)
- ROLE must be the role abbreviation (CEO, CFO, CISO, etc.), not department name
- Reserve codes 001-010 for standard use; 011+ for extended/sub-department use

### Permissions
- Always use structured format with `{WORKSPACE_ROOT}` scoping
- Read-only departments (intelligence, information): omit `write` block
- Never use legacy `files: [read, write]` format

---

## Testing

Run the test suite:

```bash
python tests/test-method-patterns.py
```

Tests cover:
- File structure validation (all required files present)
- SKILL.md frontmatter schema validation
- Permission format compliance
- Error code uniqueness and prefix consistency
- Chinese character scan (G1 compliance)

---

## Pull Request Process

1. **Fork** the repository or create a feature branch
2. **Run tests** — all tests must pass
3. **Update CHANGELOG.md** under the next version section
4. **Check G1 compliance** — no Chinese in compiled content (test fixtures exempt)
5. **Check file sizes** — apply progressive disclosure if files exceed 50KB
6. **Submit PR** with description referencing the issue/audit finding (e.g., `Fixes CHO-001`)

### PR Checklist

- [ ] All tests pass
- [ ] No Chinese in compiled content (G1)
- [ ] CHANGELOG.md updated
- [ ] Error codes follow `{ROLE}_NNN` format
- [ ] Permissions use structured format
- [ ] License headers preserved (GPL-3.0)

---

## Error Code Registration

Before submitting a PR that adds error codes:

1. Check `SKILL.md` > Error Codes section for existing codes
2. Claim the next available number for your role prefix
3. Add to both the nested department SKILL.md and the root SKILL.md
4. Document resolution steps in `method-patterns.md`

---

## Versioning

This skill follows [Semantic Versioning](https://semver.org/):

| Change Type | Version Bump |
|-------------|-------------|
| New department | MINOR (e.g., 1.1.0) |
| New role in existing department | MINOR |
| Bug fix / P0/P1 remediation | PATCH (e.g., 1.0.7) |
| P2 improvement | PATCH |
| Breaking change to API | MAJOR |

**Files to update when bumping version:**
- `SKILL.md` frontmatter `version:`
- `_meta.json` `version:`
- `.clawhub/origin.json` `installedVersion:`
- `README.md` version badge
- `CHANGELOG.md` new section

---

*AI Company Skill — GPL-3.0 | [ClawHub](https://clawhub.com/skills/ai-company)*
