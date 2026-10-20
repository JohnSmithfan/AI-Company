# AGENTS.md

> **Scope of this file**: This file is for coding agents that *maintain this
> repository*. The runtime entry point of the skill is `SKILL.md`; this file
> does not participate in skill routing or activation.

## What this repository is

`ai-company` is a self-contained, large-tier LLM Agent governance skill
package (version 4.0.0; major 4 is the tier ordinal for `large`): 18
departments across 7 domains, 18 function blocks, 117 error codes across 19
prefixes, and 148 package files, including its own self-contained generation
spec `README_FOR_AI.md`. The 7 domain slugs are `governance`, `finance`,
`technology`, `security`, `people`, `growth`, `delivery`. For a human
overview, read `README.md`. For skill runtime behavior, the *only* entry point
is `SKILL.md` — never duplicate or paraphrase its content in any other file.

## Before you change anything

1. Read `CONTRIBUTING.md` for branch, commit, test, and PR rules.
2. `README_FOR_AI.md` (at the package root) is this package's self-contained
   generation & maintenance spec — its **§14** lists the red lines **P1–P55**;
   **§15** lists the acceptance checks. This package is a large-tier instance
   of the `ai-company` bloodline (micro → small → medium → large); the spec is
   embedded and self-sufficient, so no external document is required. Check
   the relevant red-line rows before writing code or content.
3. The Project Structure tree in `README.md` must match the **package file
   set** exactly. Repository tooling directories (`.git/`, `.github/`,
   `.workbuddy/`, `.skill-upgrade/`) are not package content and are never
   counted (`README_FOR_AI.md` §3). If you add, rename, or remove a package
   file, update that tree (and the file-count claims) in `README.md`,
   `README.en.md`, and `README.zh.md` in the same change.

## Commands to run

Run from the package root:

| Purpose | Command |
|---|---|
| Unit tests (authoritative-source validation) | `PYTHONDONTWRITEBYTECODE=1 python tests/test-method-patterns.py` |
| Tier evaluation (readiness check; writes back its own bookkeeping fields to `.scaling-state.json`, never skill content) | `powershell -ExecutionPolicy Bypass -File scripts/self-scale.ps1 -Action evaluate` |
| Key acceptance counts | See `README_FOR_AI.md` §15 |

The suite asserts the package file total (148), so never run it in a way that
leaves `__pycache__/` or `.pyc` files behind: set `PYTHONDONTWRITEBYTECODE=1`
(or run `python -B`) and check the tree is clean afterwards.

All tests must pass before you commit. Any tier action beyond `evaluate`
(upgrade/downgrade) is lossy and requires explicit human approval — never run
it on your own.

## Invariants — where to check them, not what they say

This section deliberately contains no content copied from `SKILL.md`. Each row
points to the single authoritative location.

| Invariant | Authoritative source |
|---|---|
| Skill routing, department index, error-code prefixes | `SKILL.md` (sole runtime entry) |
| Code templates and prompt frameworks | `references/method-patterns.md` (sole code authority; no file may inline-copy them — P10/P44) |
| Department enum (18 departments, 7 domains) | `references/department-index.md` |
| Error codes (four-element table) | `references/error-codes.md` |
| Upgrade thresholds, gating, aliases | `references/scaling.md` |
| Self-upgrade safety (no changes to `tests/`, the `permissions` block, or the gate logic in proposals) | `tests/test-method-patterns.py`; `README_FOR_AI.md` §9.5 / §12.3 |

## Hard rules for edits

- **Link, never inline.** Code templates live only in
  `references/method-patterns.md`; nothing may inline-copy them. (P10, P44)
- **Never modify `tests/`, the `permissions` block of `SKILL.md`, or the gate
  logic in `scripts/self-scale.ps1` as part of an upgrade proposal.** The test
  suite asserts this and will fail. These three are non-waivable, including by
  human approval (gates G1–G3).
- **Propose-only upgrade discipline.** The skill can detect that it has
  outgrown its tier and write a complete upgrade proposal, but it never
  installs one: a proposal needs human approval and is applied by an external
  installer. Seven upgrade edges are implemented and the target tier is freely
  chosen via `-TargetTier` within the config `selectable_targets` set
  (`references/scaling.md` §2); the only edge from this package's `large`
  tier is `large` → `group` (18 → 36 departments), delivered as a scaffold
  (G4–G6 fail by design; the group tier's content is not yet written).
- **Never write inside `{SKILL_DIR}`** — the package directory is read-only,
  including during upgrades.
- **Never ignore `.scaling-state.json`** — it is package metadata and must be
  tracked. (See the note in `.gitignore`.)
- **No file names containing spaces**, and no misspelled variants such as
  `.gitingnore` or `changelog.md`. (P51)
- **Never tier-trim the governance files** — all 13 exist at every scale tier.
  (P50)
- **Never translate identifiers** (slugs, error codes, field names, enum
  values, file paths, function names), including in `README.zh.md`. (P48)
- Source files are English (except `README.zh.md`, which is explicitly
  exempted for natural-language prose — see `README_FOR_AI.md` §16); output
  language follows the user. (P47)
- **Never hardcode an absolute user path** — use the `{SKILL_DIR}` /
  `{WORKSPACE_ROOT}` placeholders.
- UTF-8 without BOM, LF line endings including `.ps1` (pinned by
  `.gitattributes`), 2-space indent (4 for Python) — see `.editorconfig`.
- `.gitignore` uses wildcard patterns (`REVIEW-*.md`, `AUDIT-*.md`), never
  exact report file names. (P39)
- After generating or changing content, run the acceptance checks that the
  content claims to satisfy. (P39)

## When you are unsure

- Red lines: `README_FOR_AI.md` §14 (P1–P55).
- Acceptance: `README_FOR_AI.md` §15.
- Process and PR rules: `CONTRIBUTING.md`.

This file stays under 150 lines and never becomes a second skill entry point
(P55).
