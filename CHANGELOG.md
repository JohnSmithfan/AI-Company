# Changelog

All notable changes to the AI Company skill package are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Major version = tier ordinal.** `micro` = 1, `small` = 2, `medium` = 3, `large` = 4,
`group` = 5. A tier change is a breaking change and always increments the major version.

| Version rule | Increment |
|---|---|
| Tier upgrade or downgrade | major ±1, minor and patch reset to 0 |
| Department content revision, no structural change | minor +1 |
| Typo, threshold tweak, alias append | patch +1 |

This package reached tier `large` through the `ai-company` bloodline
(micro -> small -> medium -> large); the large-tier content was derived from
the standalone `ai-company-large` reference project, whose own release
history is preserved under "Predecessor project history" below.

* * *

## [Unreleased]

- README_FOR_AI.md fully translated to English (§1–§16 + P1–P55): body text is
  English per §6.3, the pre-2026-10-21 Chinese original is preserved
  per-section inside HTML comments for comparison only (hidden at render
  time), and section numbering plus the six immutable identifier classes
  (P48) are unchanged. During translation three stale statements were
  corrected (§1's three-edge claim, §12.1's path derivation, §10.4's
  SCL_002/SCL_008 messages synced with the seven-edge mechanism), and the
  §16 "language exemption" row was replaced by a "language policy and
  translation record" row (the exemption is revoked)
- AGENTS.md: README_FOR_AI.md removed from the source-language exemption list
  (only README.zh.md remains exempt); the upgrade-path statement resynced to
  the seven-edge any-target mechanism
- New test (TestGovernanceLayer): README_FOR_AI.md body contains no CJK after
  stripping HTML comments (suite: 110 tests)
- README (all three siblings): new Usage subsection "Regenerating this package
  with an AI" — hands README_FOR_AI.md to any LLM agent as the self-contained
  generation specification (large tier, 14-step workflow in §4, §15 acceptance
  required). Scoped to maintainers/auditors; explicitly distinct from the
  runtime propose-only self-scaling and tier-locked to `large`
- Upgrade mechanism: `propose` now accepts any selectable target tier via
  `-TargetTier` (default remains the linear adjacent tier from
  `scripts/scaling-config.json` `upgrade_path`). Seven dispatch edges:
  micro->small, small->medium, medium->large, micro->medium (in-place
  two-stage composition), micro->large, small->large, large->group
- large->group ships as a scaffold: verbatim carry-forward, package state
  skeleton (gates_passed = 3), and UPGRADE-WORK-ORDER.txt; G4-G6 fail by
  design and the failure detail is the authoring checklist; exit 0, no
  live-state record, no proposal report
- Target resolution errors re-mapped: SCL_008 (same-tier / downgrade /
  unknown vocabulary / outside selectable_targets), SCL_002 (in-set pair
  without a builder; message lists selectable targets), SCL_009 (already at
  max tier), SCL_007 now also covers config-vs-script dispatch drift
- Fixed a latent defect in the -> large builder: the department_aliases
  frontmatter pointer was appended after the closing delimiter when the
  source package had no inherited pointer (G6 rejection); now inserted
  inside the frontmatter
- New tests (TestScalingMechanism): -TargetTier parameter declared, edge
  table and builder table pair every edge with a builder inside
  selectable_targets, config tier_order matches the script, default target
  is the first selectable, five-tier file counts match config, group
  scaffold declared and state-free (suite: 110 tests)
- references/scaling.md: header resynced to large/4.0.0; Section 2 rules
  rewritten (default edge + any-target selection + scaffold contract);
  Section 4 retitled to the seven-edge dispatch table; Section 7 step 4 and
  Section 10 error-code semantics updated
- Hygiene hardening (tech-debt review 2026-10-27): `README_FOR_AI.md` §14.5
  Engineering Hygiene now carries an explicit "no crappy code, no
  historical burden" clause (engineering level), and a new §14.6 File Hygiene
  section codifies file-level anti-debt rules (no orphans / duplicates / empty /
  "kept-for-history" files, no commented-out live content). The prohibition is
  mirrored in `CONTRIBUTING.md` "What Not To Do" and `AGENTS.md` "Hard rules".
  No package files added or removed — the 148-file invariant and the test suite
  (110 tests) are unchanged

## [4.0.0] - 2026-10-20 - tier upgrade proposal (medium -> large)

- Departments: 9 -> 18 (the 9 medium-tier departments are retired; 18 large-tier departments replace them; 18 function blocks conserved, one per department)
- Error-code prefixes: 10 -> 19 (18 department prefixes + SCL_ infrastructure; 117 codes)
- New D3 layer per department, 7-domain routing, and a department index
- Slug aliases appended to references/scaling.md (Alias Map)
- PROPOSED ONLY - requires human approval and an external installer

* * *

## [3.0.0] - 2026-10-20 - tier upgrade proposal (small -> medium)

- Departments: 5 -> 9 (8 function blocks migrated from 5 existing departments to 4 new departments: legal-and-risk, data-and-analytics, product-and-strategy, customer-and-partnerships; 18 blocks conserved)
- New error-code prefixes: CLR_, CDO_, CPO_, CCO_ (resolved alias table appended to references/error-codes.md)
- New shared modules: references/shared/{glossary, cross-department-handoff, common-patterns}.md
- Slug aliases appended to references/scaling.md (Alias Map)
- Installed 2026-10-20 by an external trusted installer; human-accepted
  2026-10-20 (acceptance_passed=true in .scaling-state.json; the test suite
  re-based to medium: 56 tests OK, 1 skip - test_propose_smoke_on_clean_copy
  skips on non-micro tiers).

* * *

## [2.0.0] - 2026-10-19 - tier upgrade proposal (micro -> small)

- Departments: 2 -> 5 (merge-tree split, function blocks conserved at 18)
- Revived error-code prefixes: CISO_, CHO_, CQO_ (alias-table skeleton appended to references/error-codes.md)
- New agent-invoked prompt: prompts/03-test-cases.md
- Slug aliases appended to references/scaling.md (Alias Map)
- Installed 2026-10-19T13:16:24Z by an external trusted installer; human-accepted
  2026-10-19 (acceptance_passed=true in .scaling-state.json).

### Added

- **GitHub community-health and platform configuration** (2026-10-17 audit):
  `.github/SUPPORT.md`, `.github/PULL_REQUEST_TEMPLATE.md`,
  `.github/CODEOWNERS`, `.github/dependabot.yml` (github-actions, weekly) and
  `.github/workflows/ci.yml` — the latter runs the full test suite on push to
  `main` and on pull requests. `CONTRIBUTING.md` already required a green suite
  before a PR, but no gate enforced it. The three default `.md` issue templates
  (including a boilerplate bug form that still asked reporters for smartphone
  and browser details) were replaced by `.yml` form templates
  (`bug_report.yml`, `feature_request.yml`) plus `config.yml`
  (`blank_issues_enabled: false`). Every addition lives under `.github/`, which
  `README_FOR_AI.md` §3 declares non-package content, so the package file set
  stays at 26 and no tier count changes.
- `.gitignore` now ignores `.env` / `.env.*` (keeping `!.env.example`
  committable) — defensive hygiene for the environment-variable credential
  model (`README-FOR-AI.md` §9.4).
- `README.md` / `README.en.md` / `README.zh.md` gained a CI status badge and a
  contents directory (the README passed 100 lines, where a table of contents
  becomes worthwhile).

### Changed

- **`tests/test-method-patterns.py` language** (R5): all 332 Chinese
  natural-language lines — the module docstring, comments and assertion
  messages — were translated to English per the maintainer decision, so
  §6.3's "source files are English" now holds everywhere outside the two
  §16 exemptions. Code, identifiers and every assertion expectation are
  byte-identical: a line-by-line audit confirms 332 prose changes and zero
  code-signature changes. Only the two regex character classes that tolerate
  Chinese-style section separators remain, as code rather than prose.
- **Package file set boundary defined** (D-1, `README-FOR-AI.md` §3):
  repository tooling directories (`.git/`, `.github/`, `.workbuddy/`,
  `.skill-upgrade/`) are declared non-package content — never counted and never
  copied into an upgrade package. `AGENTS.md`, `CONTRIBUTING.md`, `README.md`,
  `README.en.md`, `README.zh.md`, `README-FOR-AI.md` §2/§3/§15 and
  `references/scaling.md` §2 adopt the same basis. This closes the P4 violation
  where the three README trees listed 26 files while the repository tracked 29.
- **Version locations reduced from four to three** (D-2 option A):
  `_meta.json` / README badge / `SKILL.md` frontmatter. The former fourth
  location — the `SKILL.md` body title — never existed in any shipped package,
  so gate G6 checked it in vain and every proposal failed for a reason that
  could not be satisfied (`README-FOR-AI.md` §6.1/§15,
  `references/scaling.md` §6/§8).
- **G6 small-tier expected file count corrected 29 → 30** in
  `README-FOR-AI.md` §12.3 and `references/scaling.md` §6, matching
  `$TargetFileCount` and §12.6.
- Documentation switched to standalone-project wording: `README-FOR-AI.md` is
  now cited as the self-contained, sole authoritative generation & maintenance
  spec of this package, and every former citation of an external or upstream
  specification was replaced with a local section reference
  (`README-FOR-AI.md` §14 for the red lines P1–P55, §15 for the acceptance
  checks, §9.1 / §9.4 for the security invariants, §1 for the scale-tier
  ladder) across `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `README.en.md`,
  `README.zh.md`, and `SECURITY.md`. Red-line numbers (P1–P55) are unchanged.
- `CONTRIBUTING.md`: the micro-tier acceptance table now expects a total file
  count of 26, matching `README-FOR-AI.md` §15 and the Project Structure tree
  in the `README` files.

### Fixed

- **Bare code fences in `references/scaling.md`** (R5): four opening fences
  (the T4 formula, the eight-step execution sequence, the tier-to-major table
  and the installer requirements) carried no language tag, which
  `README-FOR-AI.md` §6.3 / §14.5 forbid. All four now open with a `text`
  language tag, and the new `test_no_bare_code_fences` assertion keeps them
  that way.
- **Recheck R2 (2026-10-14 second review round)** — `scripts/self-scale.ps1` (R2-B1,
  blocker): `Write-HostMetric` copied the existing `host_metrics` with
  `PSObject.Properties`, which on an in-process `[ordered]` dictionary returns
  the .NET members (`Count`/`Keys`/`Values`/…), not the metric entries. The
  **second** write in one run therefore destroyed `host_metrics` — a drop
  directory carrying two files, or one `record-metrics` call carrying both
  `-AgentCount` and `-RoutingAccuracy`, was enough — and T1/T3 then reported
  "never supplied by any host", silently disabling the host-supplied metrics.
  The copy is now key-aware for an `IDictionary` and property-aware for the
  reloaded `PSCustomObject`.
- `scripts/self-scale.ps1` (R2-B2): T3 ignored the usability verdict that
  `Get-HostMetricsFreshness` computes (only T1 consumed it). A stale observation
  or a sample below `min_routing_samples` still advanced
  `routing_miss_streak`, so five samples on three runs generated an upgrade
  proposal — exactly what the two config knobs exist to prevent. T3 now skips
  with an explicit `T3 SKIPPED` line and leaves the streak unchanged.
- `scripts/self-scale.ps1` (R2-B3): the micro→small split rewrote each page's
  preamble with `$preamble.Replace($src, $t.Slug)`, a no-op because the preamble
  carries the department **display name**, not the slug. All five generated D2
  pages inherited the legacy title and the legacy count (`Governance and
  Delivery`/`Function blocks: 8.` twice,
  `Engineering and Safety`/`Function blocks: 10.` three times) instead of
  6/2/3/3/4. The split now writes the target display name and block count, and
  gate G4 reads the mandatory `Function blocks: <N>` field (§10.2) instead of
  counting headings alone, so a mislabelled page fails `SCL_010`.
- `scripts/self-scale.ps1` (R2-B4): the base64-embedded small-tier structure
  tree was rooted `ai-company-governance/`, so every generated README described a
  folder that is not the package; it is now `ai-company/`.
- `scripts/self-scale.ps1` (R2-B5): gate G2 re-implemented the build-residue
  half of the package-file-set boundary inline, contradicting §3's "sole
  implementation" claim; it now calls `Test-PackagePathExcluded`. Two overclaims
  were also reworded — "no `Remove-Item -Recurse -Force` pattern anywhere" (the
  proposal report quotes one as an example) and "T1 and T3 cannot fire" (printed
  even when only one metric was still at its default).
- `references/method-patterns.md` §3.9 (R2-B6, security): the L-2 version-keyword
  exemption leaked real addresses — `release 192.168.1.100`, `build 10.0.0.1`,
  `rev 8.8.4.4` and `v 10.0.0.1` all passed through unmasked, while §9.3 makes IP
  masking mandatory. The exemption is removed: every octet-valid dotted quad is
  masked, and the accepted false positive (a four-part version number becomes
  `[IP]`) is documented instead of leaking.
- `references/method-patterns.md` §3.8 (R2-B7): the `check_rate_limit` docstring
  claimed eviction only touched callers idle for a full window, but the overflow
  path evicted oldest-inserted keys regardless; the docstring now states the
  best-effort guarantee, and expired buckets are actually pruned across all keys
  before eviction (previously only already-empty buckets were).
- `prompts/02-robustness-checks.md` (R2-B9): the H3 self-containment contract asks a
  human-paste prompt to carry the ten canonical template signatures inline; 02
  listed ten robustness dimensions but not one signature, so a reviewer could
  not check a rename or a changed default without the package. The signature
  block is now inlined, and the H1/H2/H3 test asserts it (plus the three PII
  placeholders and the three AIGC layers) for every human-paste prompt. The
  assertion was negative-verified by deleting the block from a throwaway copy.
- `references/method-patterns.md` §3.3 (R2-B10): `_KNOWN_SECRET_NAMES` did not
  cover `NETRC` and `KUBECONFIG`, which name credential *files* and carry no
  KEY/TOKEN/SECRET/SESSION fragment. Both are now listed, consistent with the
  documented over-inclusive policy.
- `tests/test-method-patterns.py` (R2-B8): `test_def_unique_across_package` and
  `test_no_filename_with_space` recursed the whole working tree while skipping
  only `.git`, unlike the package-file-set helper they share a file with. Any
  local copy under `.workbuddy/` — which the repository's own review tooling
  creates — turned the authoritative acceptance command red. Both now iterate
  `package_relative_paths()` (README-FOR-AI.md §3).
- `tests/test-method-patterns.py`: three hollow assertions were made real. The
  out-of-bounds `read_reference_file` probe asserted nothing (its secret
  sentinel came from a file that does not exist), the cwd probe allowed the skill
  directory and the temp directory (so `cwd=None` passed), the human-paste
  denylist checked four strings out of the H1/H2 set, and the L-3/L-6 tests
  `skipTest`-ed instead of failing when the guarded symbol was deleted.
- Documentation resynced with the implementation (P4/P32): `references/scaling.md`
  §7 step 5i said the generated tree is the **29**-file skeleton (it is 30),
  §7 step 3 omitted `validation` from the write-back list, §3's T1 row quoted the
  bare tier cap without `agent_count_headroom`, §6's G4 row did not mention the
  `Function blocks:` check, the T4 denominator is now stated as the union of
  catalog and referenced codes, and §3.1 documents how `{WORKSPACE_ROOT}` is
  derived. The three READMEs, `CONTRIBUTING.md` and `SECURITY.md` now state that
  `-Action evaluate` also generates a pending package on a threshold hit;
  `CONTRIBUTING.md` cites §6.1/§15 (not §8) for the version locations and matches
  the **package file set** (not "the disk"); `SECURITY.md` lists all five
  bookkeeping fields; `README-FOR-AI.md` §11.4's prompt skeleton is English
  (matching §6.3/P47 and the shipped prompts) and §12.6's example records the
  shipped `routing_accuracy` default of `1.0`.
- `scripts/scaling-config.json`: removed the inert `immutable_paths` key. Gates
  G1–G3 enforce those three paths directly (they are named in §9.5); a config key
  that nothing reads advertised an interface that did not exist (P32).

- `scripts/self-scale.ps1` (H-1): the 5h copy walked the skill directory with a
  full recursive `Get-ChildItem`, while the file count excluded `.github/` — and
  in a real checkout also `.git/` and `.workbuddy/`. Measured on the live
  directory the package held 602 files (561 of them `.git/`, including
  `.git/config`) against an expected 30, so `propose` failed G6/`SCL_006` in
  every checkout and quarantined a package containing the repository's own git
  objects. Copy range, every file count, the report's current-file count and
  gate G6 now share the single `Get-PackageRelativePaths` package file set
  (`$ExcludedDirSegments`). Verified: clean copy → G1–G6 all PASSED, exit 0;
  workspace containing `.git`/`.workbuddy`/`.github` → 0 non-package files in
  the package.
- `scripts/self-scale.ps1` (H-2a): `-Action record-metrics` was declared in
  `ValidateSet` but had no `switch` branch — it printed nothing, changed nothing
  and exited 0. Implemented as `Invoke-RecordMetrics` (a validated write to
  `host_metrics`, mirrored to `last_metrics` and appended to `metrics_log`), and
  the `switch` now has a `default` branch that stops with `SCL_007` so a
  declared-but-unimplemented action can never be silent again.
- `scripts/self-scale.ps1` (H-2b): `Receive-HostMetricsDrop` was dead code —
  never called — so `host_metrics.drop_dir` and `log_cap` had no effect. It now
  runs at the start of both `evaluate` and `propose`; accepted drop files are
  validated, applied and **moved** to `processed/` (never deleted).
- `scripts/self-scale.ps1` (H-2c): `Get-CurrentMetrics` was called without its
  `$Config` argument at every call site, so `Get-HostMetricsFreshness` compared
  age against an empty value and logged "past the -day freshness limit".
  T1/T3 therefore skipped even a fresh, over-threshold host metric. `-Config` is
  now passed everywhere; a recorded `agent_count = 9` (cap 3) correctly logs
  `T1 agent capacity: agent_count = 9, threshold > 3` and `TRIGGERED T1`.
- `scripts/self-scale.ps1` (H-2d): the "host metrics are still at their
  defaults" note now prints only for metrics the host has never written;
  previously it appeared on the same screen as a host-written
  `agent_count = 9`.
- `scripts/self-scale.ps1` (M-3 / P1-6): a failed gate's `Detail` is no longer
  discarded. Each failure is written to the log and the full list is stored in
  `last_failure.detail` in `.scaling-state.json` (verified: `G6 detail:
  file_count: expected 30, found 31`).
- `scripts/self-scale.ps1` (M-2): `Read-State` now materialises the top-level
  `validation` block required by `README-FOR-AI.md` §12.6 (`gates_passed: 6`,
  `file_count` = the tier expectation, `acceptance_passed`); it previously
  existed only inside `pending_proposals[]` entries.
- `SKILL.md` (M-1): normalised from CRLF to LF. The 31 pre-existing tests used
  `read_text()`, whose universal-newline handling silently folds CRLF, so they
  could not see it; a raw-byte assertion now guards the whole package.
- `references/scaling.md` §7 step 3 and the three READMEs (L-1): the
  write-back field lists now match the script (`next_evaluation`, `last_metrics`,
  `metrics_provenance`, `routing_miss_streak`, `validation`).
- `prompts/01-implement-method.md` (L-2): the broken sentence "an embedded
  watermark in the content body that does not survive-free under simple
  deletion" is rewritten to the honest tamper-evident wording of
  `README-FOR-AI.md` §9.2, and the PII rule now says "phone numbers in their
  common written forms (country code and separators included)" instead of
  "11-digit phone numbers" (§9.3).
- `references/method-patterns.md` §5.4 (L-3): "the host permission set declared
  in `SKILL.md` §9.1" cited a section that does not exist in `SKILL.md`; it now
  reads "`SKILL.md`'s `permissions` block (specification: `README-FOR-AI.md`
  §9.1)".
- `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `README.en.md`, `README.zh.md`,
  `README-FOR-AI.md` §15 and `references/scaling.md` §11 (P2-12): the
  acceptance commands now show `powershell -ExecutionPolicy Bypass -File ...`,
  because a default Windows execution policy refuses an unsigned `.ps1`.
- `AGENTS.md`: the edit-hygiene line claimed "CRLF for `.ps1`", contradicting
  `.editorconfig`, `.gitattributes` and `README-FOR-AI.md` §16; corrected to LF.
- `scripts/self-scale.ps1`: `Save-State` (and the two other JSON writers)
  replaced `ConvertTo-Json` with `ConvertTo-StableJson`, a hand-rolled
  serializer that emits stable 2-space-indented JSON with `[]` for empty
  arrays. Previously every `-Action evaluate` rewrote `.scaling-state.json`
  with PowerShell-flavoured indentation (21/26-space blocks, double space after
  key names), dirtying the working tree and violating `.editorconfig`.
- `README.md`, `README.zh.md`, `README.en.md`, `SECURITY.md`, `AGENTS.md`,
  `CONTRIBUTING.md`, `README-FOR-AI.md` §15: the `-Action evaluate` contract is
  now stated accurately. It was documented as "read-only" in four places while
  it does write back its own bookkeeping fields (`next_evaluation`,
  `last_metrics`, `metrics_provenance`, `routing_miss_streak`, `validation`) to
  `.scaling-state.json` — skill content has always been untouched.
- `README-FOR-AI.md` §7.1: removed the inlined `mask_sensitive_data`
  implementation. It duplicated the authoritative source in
  `references/method-patterns.md` §3.9, violating P10/P44 and failing the
  package's own §7.3 check ("every `def <fn>` must appear exactly once across
  the package"). Replaced with a pointer to the authoritative source.
- `tests/test-method-patterns.py`: added `test_def_unique_across_package`,
  which recurses the whole package and asserts that every `def <fn>` appears
  exactly once and that the ten templates appear only in
  `references/method-patterns.md`. The previous suite only asserted that the
  authoritative source *contains* the ten definitions, so the duplication above
  went undetected. Suite is now 25 tests (was 24).
- `.editorconfig`, `CONTRIBUTING.md`: `[*.ps1]` line endings corrected from
  `crlf` to `lf` to match the file on disk — `scripts/self-scale.ps1` carries
  LF-sensitive here-strings and normalizes everything it writes to LF (E15), so
  the documentation was the wrong side to keep. Recorded in
  `README-FOR-AI.md` §16.
- `.gitignore`: `.workbuddy/` (agent workspace state) is now ignored so local
  tooling data can never enter a release.
- `references/method-patterns.md` §3.3 (H-2, security): `_scrubbed_environment`
  matched credential variables by **prefix** only (`api_`, `token`, `secret`,
  `password`, `key_`). Measured against 17 real-world variable names it blocked
  5 and leaked 12 — including `AWS_SECRET_ACCESS_KEY`, `AWS_ACCESS_KEY_ID`,
  `GITHUB_TOKEN`, `GH_TOKEN`, `OPENAI_APIKEY`, `ANTHROPIC_AUTH_TOKEN`,
  `PRIVATE_KEY`, `SESSION_ID`, `PASSWD`, `NPM_TOKEN`, `HF_TOKEN`. It is the
  package's only defence against credentials reaching a subprocess, and it
  failed on the most common names. Replaced with fragment matching
  (`_is_secret_env_name`: delimiter-split token match plus a known-name list),
  and pinned by a new test that asserts all 12 are covered and 19 harmless
  variables are not.
- `references/method-patterns.md` §3.9 (M-2, security): the phone branch matched
  only "exactly 11 contiguous digits", so `+8613800138000`, `138-0013-8000` and
  `+86 138 0013 8000` — the three most common written forms — passed through
  unmasked, and `0086 13800138000` was only half-masked. The regex now covers
  optional country codes and 3-4-4 grouping with space or dash separators.
- `references/method-patterns.md` §3.9 (L-1): the email TLD class `[A-Z|a-z]{2,}`
  contained a **literal pipe** (a character class, not an alternation), so
  `a|b@x.c|m` was accepted as an address. Corrected to `[A-Za-z]{2,}`.
- `references/method-patterns.md` §3.9 (L-2): the IPv4 branch matched any dotted
  quad, rewriting `version 1.2.3.4 released` to `version [IP] released`. The
  regex is now octet-validated (rejecting `256.1.1.1`, `01.02.03.04`,
  `1.2.3.4.5`) and version-like tokens are excluded from IP masking by a
  documented guard. The residual trade-off — a literal address printed directly
  after a version keyword is not masked — is stated in the docstring.
- `references/method-patterns.md` §3.3 (M-4): `execute_safe_command` used
  `text=True` with no explicit error handler, so a non-UTF-8 byte (GBK output on
  a Chinese Windows host) raised inside subprocess' reader thread and the caller
  received `returncode 0` with `stdout=None` — the output was lost silently.
  Now decodes with `encoding="utf-8", errors="replace"`.
- `references/method-patterns.md` §3.4 (L-4): the `model` field appended
  `/default` unconditionally, turning `openai/gpt-4` into
  `openai/gpt-4/default` and contradicting the documented `<provider/model>`
  contract. The suffix is now added only when the provider carries no model.
- `references/method-patterns.md` §3.8 (L-3): `_rate_buckets` grew without
  bound — 5 000 injected identifiers were all retained, so a long-running
  process leaks memory. Identifier count is now capped
  (`_MAX_RATE_IDENTIFIERS`), evicting expired buckets first.
- `references/method-patterns.md` §3.2 (L-5): `_SHELL_METACHARS` did not strip
  backslash or newline. A trailing backslash is `shlex`'s escape character and
  silently swallows the next delimiter; a newline lets one input become two
  lines downstream. Both are now removed.
- `references/method-patterns.md` §3.6 (L-6): `read_reference_file` resolved
  paths against `os.environ.get("SKILL_DIR", ".")`, so an unset variable
  silently promoted the process working directory to a readable root. It now
  fails closed with `PermissionError`.
- `scripts/self-scale.ps1` (H-1): three of the four scaling metrics were read
  back from `.scaling-state.json` — values the script itself had written on the
  previous run — so `agent_count` stayed `0`, `routing_accuracy` `1.0` and
  `error_code_reuse_ratio` `0.0` forever, and thresholds T1/T3/T4 could never
  fire. `error_code_reuse_ratio` is now measured on every run by
  `Get-ErrorCodeReuseRatio` (verified: 0.0 at baseline, 0.3333 after injecting
  shared codes, which does trigger T4, and back to 0.0 when reverted). T1/T3
  are unobservable from inside the package and are now declared **host-supplied
  by contract**: the script labels every metric `[measured]` or
  `[host-supplied]` on output, records the split in `metrics_provenance`, and
  prints an explicit note that T1/T3 cannot fire until the host writes them.
- `references/method-patterns.md` §3.4 docstring, §5.1 and `README-FOR-AI.md`
  §9.2 (M-1, P24): layer 3 of the AIGC labeling was documented as a watermark
  that "cannot be removed without removing the payload text". Measured: the
  disclosure is one trailing line and `out.split("\n\n> Warning:")[0]` strips it
  with the body intact. The marker is now bound to a digest of the content, and
  every description states its real strength — tamper-evident disclosure, not a
  cryptographic watermark.
- `references/method-patterns.md` §3.3 docstring, §5.4 and `README-FOR-AI.md`
  §9.4 (M-3, P24): the executable blocklist was documented as rejecting
  dangerous operations "before launch". It matches program names only, so
  `python -c "os.remove(...)"`, `git clean -fd` and `find . -delete` all pass.
  Now described accurately as a best-effort first line of defence, with the host
  permission set named as the real boundary.
- `references/scaling.md` §3 and `README-FOR-AI.md` §12.2 (L-7): T1 was
  documented as "agent count > tier cap" while the implementation compares
  against `cap × agent_count_headroom`. The headroom parameter is now named and
  its shipped default (`1.0`) recorded.
- `references/scaling.md` §2: the upgrade matrix mixed total-package-file and
  spec-file counting bases in one column; a "Counting basis" footnote now states
  which basis each row uses.

### Added

- `tests/test-method-patterns.py`: the 2026-10-16 terminal-review coverage
  group (`TerminalReview20261016Tests`, 12 assertions) now machine-enforces the
  `README-FOR-AI.md` §6.1 / §15 invariants that previously had no assertion —
  the SKILL.md frontmatter line budget (<= 85), the description (700–900 chars),
  the tag budget (8–16), exactly 15 unique lowercase triggers, the byte-exact
  `permissions` block, empty `dependencies` and `errors`, the three error-code
  prefixes, `harness_baseline: L3`, the AGENTS.md line budget (<= 150), the three
  agreeing version locations, the four agreeing GPL-3.0 license declarations,
  error-code catalog integrity (34 codes, continuous numbering, D2 tables
  identical to the catalog, fixed `SCL_` messages) and the no-bare-fence rule.
  **Every new assertion was negative-verified**: the defect was re-injected into
  a throwaway copy and the assertion was confirmed to fail. Suite is now 56
  tests (was 44).
- `tests/test-method-patterns.py`: five regression assertions for the 2026-10-14
  re-review (`Recheck20261014Tests`) — host metrics survive a two-metric write,
  T3 skips below `min_routing_samples`, IP masking has no version-keyword
  escape, `_scrubbed_environment()` really removes credentials while keeping
  benign variables, and all three AIGC layers are asserted (including that the
  embedded marker is digest-bound). The propose smoke test now also asserts each
  split page's own title and `Function blocks:` figure and that the generated
  tree is rooted `ai-company/`. **Every new assertion was negative-verified**:
  the defect was re-injected into a throwaway copy and the assertion was
  confirmed to fail. Suite is now 44 tests (was 39).
- `tests/test-method-patterns.py` (added earlier in this round): the required
  discipline is unchanged — a new regression assertion is only accepted after it
  fails on the re-injected defect.
- `references/scaling.md` §3.1: the host metric write-back contract the script
  already referenced from four places but no document defined — the two
  channels, the drop-file shape, validation, freshness, the routing-sample
  minimum, the audit log and the exact conditions under which T1/T3 skip.
  `README-FOR-AI.md` §12.1/§12.2/§12.6 summarise it.
- `tests/test-method-patterns.py`: eight regression assertions for the
  2026-10-14 initial review — package file set vs declared count, upgrade
  package excludes repository tooling, a propose smoke test on a clean copy, the
  state-file schema (including `validation`), a package-wide raw-byte CRLF/BOM
  check, `scaling.md` / `README-FOR-AI.md` section-anchor existence,
  `record-metrics` implementation (`ValidateSet` vs `switch` plus `default`),
  and host-metric freshness honouring the configured limit. Each was
  **negative-verified** by re-injecting the defect into a throwaway copy and
  confirming the assertion fails. Suite is now 39 tests (was 31).
- `README-FOR-AI.md` §16: three recorded decisions — the package file set
  boundary (D-1), the three-location version policy (D-2) and the host
  write-back interface.
- `README-FOR-AI.md` §16: two deviation records — the Chinese-language
  exemption for this spec document (versus §6.3's English source-file standard)
  and the line-ending policy decision. `AGENTS.md` updated to list
  `README-FOR-AI.md` alongside `README.zh.md` as exempted.
- `.gitattributes`: pins line endings at the repository level
  (`* text=auto eol=lf`, `*.ps1 text eol=lf`) so a contributor's local
  `core.autocrlf` setting can no longer silently rewrite them — without it a
  Windows checkout emits "LF will be replaced by CRLF" and dirties the tree.
  Because the file exists at every tier, every file-count claim was resynced
  in the same change: micro 25 → 26, small 29 → 30, medium 36–44 → 37–45,
  large 147 → 148, group 245 → 246. This includes `$TargetFileCount` and the
  base64-encoded small-tier structure tree embedded in
  `scripts/self-scale.ps1`, plus the counting-basis footnote in
  `references/scaling.md` §2.
- `tests/test-method-patterns.py`: six regression tests for the defects found by
  the 2026-09-28 substantive review — credential-name scrubbing, phone-number
  variants, non-UTF-8 stdout, the `model` field, rate-limiter memory bounds, and
  fail-closed reference reads. Each was **negative-verified**: the defect was
  re-injected into a throwaway copy and the assertion was confirmed to fail.
  Two of them (non-UTF-8 stdout and fail-closed) were empty assertions on first
  write and were only caught by that check — the non-UTF-8 probe used ASCII text
  that never triggers a decode error, and the fail-closed probe set a flag the
  guard did not read. Suite is now 31 tests (was 25).
- `README-FOR-AI.md` §13, §16 and `CONTRIBUTING.md`: the practice that a new
  regression assertion must be proven to fail when the defect is re-injected, so
  the suite cannot accumulate assertions that always pass.

### Installed & Accepted (2026-10-19, human acceptance of micro -> small)

The package install (external trusted installer, backup + overwrite + retire
two D2 pages + state write-back) landed `current_tier=small` with
`acceptance_passed=false` — the 13 failing tests were the proposal's explicitly
deferred **human-acceptance** items. Acceptance was executed and the suite is
now green: **56 tests OK, 3 skipped** (all skips legitimate: two
immutable-boundary tests skip when no proposal package is present, and
`test_propose_smoke_on_clean_copy` skips on non-micro tiers because
`small -> medium` is undefined and would trip `SCL_002`).

- **`tests/test-method-patterns.py` re-based to small** (was asserting micro
  values): `SCALE_TIER="small"`, `SKILL_VERSION="2.0.0"`;
  `EXPECTED_DEPARTMENT_BLOCKS` = `{governance-and-operations.md:6,
  quality-and-delivery.md:2, technology-and-platform.md:3,
  security-and-compliance.md:3, people-and-growth.md:4}`; new
  `EXPECTED_CODES_BY_PREFIX = {CEO_:9, CTO_:4, CISO_:4, CHO_:4, CQO_:3,
  SCL_:10}`; declared `file_count` 26 -> 30; `error_code_prefixes` now expects
  the six prefixes `CEO_ CTO_ CISO_ CHO_ CQO_ SCL_`; `_EC_ROW_RE` extended to
  also parse `CISO_/CHO_/CQO_` (the catalog had only 23 of 34 codes without it).
- **Behaviour tests de-micro'd**: `test_propose_smoke_on_clean_copy` skips when
  `SCALE_TIER != "micro"`; `test_host_metric_freshness_uses_config` drives
  `record-metrics -AgentCount 15` (above both the small cap 10 and micro cap 3)
  and asserts on the threshold prefix rather than a hard-coded number;
  `test_upgrade_package_excludes_immutable` now asserts **byte-equality** between
  the package's `tests/` and the skill's `tests/` (the package carries `tests/`
  verbatim per G2, so "directory absent" can no longer be the check);
  `test_harness_baseline_declared` and `test_error_code_catalog_integrity`
  iterate all five D2 pages and validate per-prefix code continuity against
  `EXPECTED_CODES_BY_PREFIX`.
- **`references/error-codes.md` rewritten**: header states `34 codes in 6
  prefixes`; six prefix partition tables (CEO_001-009, CTO_001-004,
  CISO_001-004, CHO_001-004, CQO_001-003, SCL_001-010); the 24-line "requires
  human review" placeholder alias table removed and replaced by a resolved
  "Alias history (micro -> small)" table (e.g. CEO_010 -> CQO_001).
- **Five D2 department pages corrected**: error-code renames applied
  (CEO_010-012 -> CQO_001-003, CTO_005-008 -> CISO_001-004,
  CTO_009-012 -> CHO_001-004); Core Identity prose rewritten to drop micro-tier
  wording; stale `governance-and-delivery` references fixed to
  `governance-and-operations` and `engineering-and-safety` to
  `technology-and-platform` (the latter two departments were retired at install
  and their names had leaked into the five surviving pages).
- **`SKILL.md` narrative re-based**: `description` normalised to 834 chars
  (700-900 band); `tags` `micro-tier` -> `small-tier`; body intro now reads
  "Small-tier (S) LLM agent governance skill for growing organizations of 3-10
  agents"; Departments table expanded 2 -> 5 rows; Error Code Prefixes table
  expanded 3 -> 6 prefixes (adds CISO_/CHO_/CQO_).
- **Stale proposal package removed** from the correct path
  `{WORKSPACE_ROOT}/.skill-upgrade` (the package lives in the
  skill's *parent* directory, not inside the package — an earlier mis-deletion
  targeted the wrong location and left a stale package that broke the
  immutable-boundary byte-equality test).
- **`.scaling-state.json` acceptance closed out**: `acceptance_passed` set to
  `true` in the top-level `validation`, `tier_history[0].validation` and
  `pending_proposals[0].validation` (written LF, no CRLF).

* * *

## [1.0.0] - 2026-09-21

### Added

- Initial micro-tier (XS) release of the `ai-company` skill package:
  2 departments, 18 function blocks, 25 files (including the self-contained
  generation spec `README-FOR-AI.md`, an integral part of this project).
- `README-FOR-AI.md`: the self-contained generation & maintenance spec for
  this standalone package, and its sole authority — parameters, contracts,
  red lines (**§14**, P1–P55) and acceptance checks (**§15**) are all defined
  locally, with no external document required.
- `SKILL.md` as the single runtime entry point (frontmatter within the 85-line
  budget, body within the 120-line budget).
- Two department specifications under `references/departments/`:
  `governance-and-delivery.md` (8 function blocks) and
  `engineering-and-safety.md` (10 function blocks).
- `references/method-patterns.md` as the single authoritative source for code
  templates (index first, code after) and prompt frameworks.
- `references/error-codes.md` with the full four-element error-code table
  (two department prefixes plus the `SCL_` prefix, numbering gapless within
  each prefix).
- `references/scaling.md` defining tier upgrade thresholds, paths, aliases, and
  the list of forbidden privilege escalations.
- `prompts/01-implement-method.md` and `prompts/02-robustness-checks.md`, both
  `human-paste` mode with no references to internal paths.
- `scripts/self-scale.ps1` and `scripts/scaling-config.json` for tier
  evaluation and human-approved upgrades; `.scaling-state.json` recording the
  tier history (current tier: `micro`).
- `tests/test-method-patterns.py` validating the real authoritative sources
  (no inline copies) and guarding upgrade proposals against changes to
  `tests/` or the `permissions` block.
- All 13 governance and community files required at every scale tier
  (`.editorconfig` through `_meta.json`), including this changelog.
- Bilingual documentation: `README.md` and `README.en.md` (English) plus
  `README.zh.md` (Chinese), with identifiers kept untranslated.

* * *

## Bloodline maintenance - 2026-10-20 (post-3.0.0)

- The self-contained spec file was standardised from `README-FOR-AI.md` to
  `README_FOR_AI.md`, and every reference across the package was corrected -
  the test suite and the base-framework gates hard-code the underscore name.
  Historical entries below that cite `README-FOR-AI.md` quote the name as it
  was at the time.

* * *

## Predecessor project history (ai-company-large reference implementation)

The large-tier content of this package - the 18 department D2/D3 pages, the
117-code error catalog, the models layer, the prompts and the governance files
- was derived from the standalone `ai-company-large` reference project. That
project was generated directly at tier `large` and versioned independently;
its own release history is preserved here for provenance and is **not** part of
this package's version lineage. Its final state (v4.1.0, 2026-10-19) is the
content basis of the [4.0.0] entry above.

### Predecessor 4.1.0 - 2026-10-19

This release contains the department-layer completion and the ledger
corrections listed under the pre-4.1.0 ledger below, plus the migration to
the current specification described here. No department, error code or
function block changed — the migration surface is the code authority, the
prompt layer, the governance layer, the host-metric channel, and the two
gate defects the 2026-10-19 smoke test exposed.

### Changed

- **Code authority moved.** `references/templates.md` is deleted; the 10 shared
  templates now live in `references/method-patterns.md` §3, adopted
  byte-identical to the current specification — the 2026-09-28 review fixes
  included (credential-name environment scrubbing in template 3, CN
  phone-number variants in template 9, bounded rate-limit memory in template 8,
  fail-closed reference reads in template 6). The file keeps its seven-section
  shape and remains the only place template code exists (P44).
- **Prompts reduced 5 → 4 with mode declarations.**
  `prompts/05-workflow-execution.md` is removed (its function is covered by
  `references/exec/`); 01/02 are `mode: human-paste` (self-contained, H1–H7),
  03/04 are `mode: agent-invoked` (`{SKILL_DIR}` placeholders, declared
  artifacts / error codes / harness, A1–A5).
- **Governance layer completed to 13 files** (P50): added `README_FOR_AI.md`,
  `README.en.md`, `README.zh.md`, `AGENTS.md`, `CODE_OF_CONDUCT.md`,
  `SECURITY.md`, `.editorconfig` and `.gitattributes`. Package file count
  **142 → 148**; every count claim in `README.md`, `SKILL.md`, `AGENTS.md` and
  the test suite resynced.
- **Version 4.0.0 → 4.1.0** (minor; major 4 still equals the `large` tier
  ordinal). Version locations are the specification's three (D-2):
  `_meta.json`, the README badge and the `SKILL.md` frontmatter — the
  body-title location is removed.

### Added

- **Host-metric write-back channel** for the two host-supplied triggers:
  `scripts/self-scale.ps1 -Action record-metrics` plus a drop directory
  (`{WORKSPACE_ROOT}/.skill-metrics`, ingested at the next `evaluate` /
  `propose`), with domain validation, UTC normalisation, freshness gating
  (`host_metrics.max_age_days`) and routing-sample minimums
  (`host_metrics.min_routing_samples`). Accepted values are mirrored into
  `last_metrics` and audited in `metrics_log`; the state file records
  `metrics_provenance`, `routing_miss_streak` and `host_metrics`. Until a host
  writes them, T1/T3 cannot fire — a declared limitation, not a latent bug.
- `references/scaling.md` §4.1 documents the channel contract; §4 records
  metric provenance (host-supplied vs measured) and the T4 formula as
  implemented by `Get-ErrorCodeReuseRatio`.

### Fixed

- **G1/G3 baseline-hash scoping defect** (smoke-test finding 1): the baseline
  hashes were assigned inside `Initialize-Baseline`, so the script-scope
  variables stayed `$null` and both gates compared every proposal against
  `$null` — byte-identical packages were always reported as tampered. Both
  gates now compare the live current-vs-package hashes at gate time.
- **G2 self-contradiction** (smoke-test finding 2): G2 flagged *any* path under
  `tests/` while spec step 5h copies `tests/` forward byte-identical and G6
  requires the suite inside the package, so a script-generated proposal could
  never pass. G2 is now a bidirectional `tests/**` hash-map comparison
  (missing / differs / unexpected all flagged; build residues excluded).
- **Proposal package assembly omitted existing root files.** `New-ProposalPackage`
  carried forward only a subset of root files, dropping `SKILL.md`,
  `README.en.md`, `README.zh.md`, `README_FOR_AI.md`, `AGENTS.md`,
  `CODE_OF_CONDUCT.md`, `SECURITY.md`, `.gitattributes`, `.editorconfig` and
  `.scaling-state.json`. A fresh `large → group` proposal therefore failed G1/G3
  ("package has no SKILL.md") and G6's required-file checks before any authored
  content was considered, and the work order's "permissions copied verbatim" had
  no source file to copy from. All ten existing root files are now carried
  forward; the only authored delta remains the `SKILL.md` frontmatter rebuild and
  the installer's `pending_proposals` merge into `.scaling-state.json`.
- **`propose` run aborted before writing its report.** G6 invoked the package
  test suite with `& python …`; the suite writes progress to stderr (unittest
  default), which under the script's `$ErrorActionPreference = 'Stop'` raised a
  `NativeCommandError` and terminated the whole `propose` run before
  `Write-ProposalReport` / `Write-StateDelta` executed — so `UPGRADE-PROPOSAL.md`
  and `scaling-state-delta.json` were never produced. The invocation now
  redirects stderr, lowers EAP for the call, and wraps it in try/catch, so the
  run always completes and the test-failure detail is captured as a clean G6
  problem instead of aborting. A fresh proposal now evaluates **4 of 6 gates**
  (G1/G2/G3/G5 pass; G4 and G6 fail by design — the scaffold has no 18 new
  departments and is still at tier `large` / v4.1.0).

### Predecessor pre-4.1.0 ledger (the predecessor's [Unreleased])

### Added

- **Department layer completed (15 departments, 75 files).** The 2026-09-10 initial generation
  stopped after 3 of 18 departments while its documentation claimed all 18. Built to the three
  existing pages as reference samples: `operations-coordination`, `board-and-branch`,
  `finance-treasury`, `risk-audit`, `procurement-billing`, `platform-mlops`, `model-data`,
  `legal-privacy`, `incident-identity`, `lifecycle-training`, `knowledge-ethics`,
  `marketing-partnerships`, `intelligence-sentiment`, `quality-visualization`,
  `delivery-scheduling` — each with a D2 page (one `## FB-1:` block) and a 4-file D3 directory
  (department-spec + 2 prompts + department method-patterns). Every D2 §4 message column is
  byte-identical to `references/error-codes.md`; every department code appears in exactly one
  department table. All 18 D2 preambles now carry `Department Harness Baseline: L3`.
- Disk now matches every published claim: **18 departments / 18 function blocks / 142 files /
  117 error codes**, test suite **88/88 exit 0**. The mid-generation status banner that this
  changelog section replaced has been removed from README and SKILL.md.

### Fixed

- `tests/test-method-patterns.py::test_error_codes_match_prefix_declaration` parsed the
  `error_code_prefixes:` declaration by splitting on a blank line. The declaration is a
  wrapped YAML flow list, so the segment ran past the frontmatter into the permissions block,
  where `{SKILL_DIR}` was read as a phantom `SKILL` prefix and the test failed against a
  defect that did not exist. The test now extracts the frontmatter segment (between the first
  two `---` fences) and parses the flow list up to its closing `]`. Reverse-verified: the old
  parsing logic fails on the current package.
- `.scaling-state.json`: `next_evaluation` was `2026-10-10` (overdue); rolled forward 30 days.
  `routing_accuracy` was `null`; set to the initial default `1.0` — the same default the
  specification states for host-supplied metrics before any host runtime has written one.
  Both metrics remain **defaults, not measurements**: no host has recorded `agent_count` or
  `routing_accuracy`, so T1 and T3 cannot fire (declared limitation, not a latent bug).

### Known issues (found by the 2026-10-19 upgrade-path smoke test — pending human decision)

The `large` → `group` proposal smoke test (run on a disposable copy, nothing installed)
exposed two defects in the Sep-10 gate implementation. Both make gates **fail closed** —
they over-reject, never under-reject — but a gate that cannot pass is a gate that cannot
gate. Fixing either means editing `scripts/self-scale.ps1` gate logic, which requires human
audit under §9.5; no fix was applied unilaterally.

| # | Defect | Effect | Correct behaviour (already implemented in the current `ai-company` micro package) |
|---|---|---|---|
| 1 | `$BaselinePermissionsHash` / `$BaselineScriptHash` are assigned inside `Initialize-Baseline`, which creates function-local copies; the script-scope variables stay `$null` | G1 and G3 compare every proposal against `$null` and **always** report tampering, even for byte-identical files (verified: SHA-256 of the copied script matches the original exactly) | Compute both hashes at gate time from the live current-vs-package files (micro G3) |
| 2 | G2 flags **any** path under `tests/` in a proposal, while spec step 5h copies `tests/` forward byte-identical and G6 requires `tests/test-method-patterns.py` inside the package to run acceptance | A script-generated proposal can never pass G2; the two spec artifacts contradict each other | Hash-map comparison of `tests/**` (micro G2): byte-identical required, missing or unexpected files flagged |

Also observed in the smoke test and consistent with design: G4 correctly rejected the
incomplete proposal (0 blocks vs the 36 required at `group`), G5 passed, G6 failed on the
missing `SKILL.md`/state file, and the run ended with "the package is NOT installable in this
state" — propose-only held, the skill directory was left untouched.

**Resolved in 4.1.0.** The 2026-10-19 migration to the current specification
fixed both defects; see the predecessor 4.1.0 entry above. G1/G3 now
compare live
current-vs-package hashes, and G2 is a byte-identical `tests/**` hash map.
Two further `propose`-side defects found while re-running the smoke test are
also resolved: `New-ProposalPackage` now carries the ten existing root files
forward (so G1/G3/G6 can evaluate them instead of reporting "package has no
SKILL.md"), and the `propose` run no longer aborts on the test suite's stderr
before writing `UPGRADE-PROPOSAL.md` / `scaling-state-delta.json`. A fresh
proposal now evaluates **4 of 6 gates** (G4/G6 still fail by design on the
incomplete scaffold).

### Predecessor 4.0.0 - 2026-09-10

Initial generation at scale tier `large`.

### Added

**Structure**
- Root `SKILL.md` with a 149-line frontmatter (budget ≤ 150): 66 triggers grouped by the 7
  domains, `errors: []` with the full table externalised, 19 declared error-code prefixes,
  a `self_scaling` block, and the `metadata` tier triple (`scale_tier` / `department_count` /
  `function_block_count`)
- Two-level routing: `domains` in the frontmatter plus an externalised
  `references/department-index.md` holding the authoritative 18-department enum
- 18 department D2 pages, one `## FB-1:` function block each — 18 function blocks total
- 18 department D3 subdirectories (72 files): `department-spec.md` + 2 prompts +
  department-specific `method-patterns.md`
- Shared reference modules: `execution.md` → `exec/` (4), `memory.md` → `mem/` (2),
  `visualization.md` → `viz/` (4), `data-integration.md` → `data/` (3), plus `integrations.md`
- 5 copy-paste prompts in `prompts/`
- Model management: registry with 7 models, calling policy, one adapter, 6 API configs,
  1 local config, 2 field-contract templates
- Test suite with four assertion classes (A behaviour · B source integrity · C structural
  consistency · D immutable boundary)

**Error codes**
- 117 codes across 19 prefixes — 18 department prefixes (107 codes) plus the infrastructure
  prefix `SCL_` (10 codes)
- Every code carries Message, Trigger Condition and Resolution Steps
- Numbering is continuous from `001` within each prefix, with no gaps

**Self-scaling (propose-only)**
- `references/scaling.md`: the three-stage model (propose → approve → install), the
  `large` → `group` upgrade path derived from the merge tree, four quantitative triggers
  (T1–T4), six gates (G1–G6), the slug alias mechanism, version strategy and downgrade policy
- `.scaling-state.json`: tier history, metrics and pending proposals — package metadata,
  deliberately tracked rather than ignored
- `scripts/self-scale.ps1`: four actions (`evaluate` / `propose` / `report` / `status`),
  six independently-logged gates, cross-platform backup directory resolution
- `scripts/scaling-config.json`: thresholds, the immutable-path list and the non-waivable gate set
- Workflow **WFT-010 Tier Upgrade Proposal**, execution mode fixed to `Approve`

**Workflows**
- Core set WFT-001~008 enabled at this tier; WFT-009 defined but reserved for `group`;
  WFT-010 enabled
- No extension workflows (`WFT-1xx`) defined — the nine enabled core workflows cover this tier's
  operational surface

### Design decisions

| Decision | Rationale |
|---|---|
| Template implementations live only in `references/templates.md` | Two divergent copies with a vague index line make the authoritative source undeterminable |
| `mask_sensitive_data` covers EMAIL, IP **and** PHONE | A predecessor's source lacked the PHONE branch while its contract and tests named it; the gap stayed invisible because its suite carried an inlined copy |
| Department sub-manifests are `department-spec.md`, never `SKILL.md` | A recursive loader would register each as an independent skill, colliding with the parent's triggers |
| The upgrade script has no `install` / `apply` / `commit` action | Self-installation would require write access to `{SKILL_DIR}`, which is the boundary gates G1–G3 exist to protect |
| Gates G1–G3 are non-waivable even by human approval | An approval is a control for business scale change, not for security boundary change |
| `errors: []` in the frontmatter | Inlining 117 codes would consume roughly 120 lines of the D1 layer on every invocation |
| `department` enum externalised at this tier | Inlining 18 entries would push the frontmatter past its 150-line budget (superseded before the re-derivation: the base-framework gate G6 requires the department enum inlined at every tier - see `README_FOR_AI.md` sec 6.1; the 18 entries fit inside the 150-line budget) |

### Known limitations

| Limitation | Note |
|---|---|
| The adapter's transport is a stub | No network I/O is performed; a deployment injects a real transport. Resolution, validation, key handling and rate limiting are the parts under test |
| Calling-policy numbers are documented defaults | `calling-policy.json` carries `values_are_examples: true`; derive real ceilings from observed unit economics |
| `agent_count` starts at 0 | Trigger T1 cannot fire until real metrics are recorded in `.scaling-state.json` |
| Tier upgrade requires human approval and an external installer | By design — see `references/scaling.md` §1 |

* * *

## Version history

| Version | Date | Tier | Departments | Note |
|---|---|---|---|---|
| 1.0.0 | 2026-09-21 | `micro` | 2 | bloodline initial release |
| 2.0.0 | 2026-10-19 | `small` | 5 | bloodline micro -> small (installed) |
| 3.0.0 | 2026-10-20 | `medium` | 9 | bloodline small -> medium (installed) |
| 4.0.0 | 2026-10-20 | `large` | 18 | bloodline medium -> large (this package; entry inserted by the upgrade generator at propose time) |

The predecessor project's own releases (4.0.0 on 2026-09-10 and 4.1.0 on
2026-10-19, both at tier `large`) are recorded under "Predecessor project
history" above; they are not part of this package's version lineage.

This package reached tier `large` through the bloodline, so `tier_history` in
`.scaling-state.json` records the micro -> small -> medium -> large upgrades,
and the Alias Map in `references/scaling.md` carries the corresponding
medium -> large rows.
