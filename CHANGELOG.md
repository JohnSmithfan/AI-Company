# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

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
  `last_metrics`, `routing_miss_streak`) to `.scaling-state.json` — skill
  content has always been untouched.
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
