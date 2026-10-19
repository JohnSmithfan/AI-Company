# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
  `README-FOR-AI.md` §3 declares non-package content, so the package file set
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
  `C:\Users\Admin\.agents\skills\.skill-upgrade` (the package lives in the
  skill's *parent* directory, not inside the package — an earlier mis-deletion
  targeted the wrong location and left a stale package that broke the
  immutable-boundary byte-equality test).
- **`.scaling-state.json` acceptance closed out**: `acceptance_passed` set to
  `true` in the top-level `validation`, `tier_history[0].validation` and
  `pending_proposals[0].validation` (written LF, no CRLF).

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
