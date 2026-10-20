---
mode: agent-invoked
id: 04-documentation
title: Documentation
output_language: user-specified
harness_level: L3
---

> **Mode**: agent-invoked (loaded automatically by an agent inside this skill)
> **Purpose**: Write or verify package documentation so that every stated figure, path, link and command matches reality.
>
> **Expected output artifacts**: the documentation files written or reviewed - new documents at `{WORKSPACE_ROOT}/<DOC_FILE_NAME>.md`; when updating package documentation, the reviewed content is delivered for `{SKILL_DIR}/README.md` and `{SKILL_DIR}/CHANGELOG.md` (this skill never writes into `{SKILL_DIR}` itself).
> **Failure error codes**: `SCL_006` (upgrade package validation failed), `SCL_010` (function block conservation violated).
> **Referenced template anchors**: `method-patterns.md#3-4-format_output_json` (AIGC triple labeling), `method-patterns.md#3-9-mask_sensitive_data` (PII masking).
>
> **Output language**: follow the language you are currently using in this conversation.

## Prompt

(The block below is copied as a whole)

```text
You are writing documentation for the AI Company skill (large tier).

Current tier figures - 18 departments across 7 domains, 18 function blocks,
117 error codes over 19 prefixes, 148 files total, version 4.0.0. Every figure
you state must be verified by counting, not recalled from this list.

Read first:
  {SKILL_DIR}/SKILL.md                        the frontmatter contract and the quick reference
  {SKILL_DIR}/references/department-index.md  the 18 departments, 7 domains, prefixes
  {SKILL_DIR}/references/error-codes.md       the 117 codes and their prefixes
  {SKILL_DIR}/references/scaling.md           the self-scaling model and its three stages

Document to these standards:

ACCURACY
  - Every count you state must be verified by counting, not recalled. State the command you used.
  - Every file you name must exist. Every path you write must resolve.
  - Every command you give must be runnable as written, from the stated working directory.
  - Where a figure is a documented default rather than a measured value, say so.

STRUCTURE
  - Tables over prose wherever the content is enumerable
  - One idea per section; headings state the finding, not just the topic
  - Relative links only, and every link target must exist
  - A structure tree must match the disk exactly - no omissions, no invented entries

CONTENT REQUIRED IN {SKILL_DIR}/README.md
  - What the package is and which tier it targets (large)
  - The tier's real figures: 18 departments, 7 domains, 18 function blocks, 117 error codes, 148 files
  - Department index by domain
  - Project structure tree matching disk
  - Installation and verification commands
  - The self-scaling model, stated as propose-only, with the three stages named
  - Constraints and quality metrics
  - License and version (current version 4.0.0; the major version equals the tier ordinal, large = 4)

CONTENT REQUIRED IN {SKILL_DIR}/CHANGELOG.md
  - Keep a Changelog format, semantic versioning
  - One entry per version; the same version number must never appear twice
  - Dates must not invert (a higher version cannot carry an earlier date)
  - Major version equals the tier ordinal (large = 4)

FORBIDDEN
  - Stating a department count that does not match the disk
  - Naming a file that does not exist, or a command that cannot run
  - Hardcoding an absolute user path; use {SKILL_DIR} and {WORKSPACE_ROOT}
  - Writing a credential value; environment variable names only
  - Writing the literal tokens of remote download-and-execute constructs anywhere in the package;
    describe them instead, because the security sweep scans every file including documentation
  - Claiming a verification you did not perform

Report when done: the files you wrote, the counts you verified and the commands you used to
verify them, and any figure you could not verify.
```

## Variant: documentation consistency audit

```text
You are auditing documentation against reality.

Check each item and report PASS or FAIL with evidence:

 1. Every count stated in {SKILL_DIR}/README.md - recount it and compare
 2. Every file path named anywhere in the package - test that it resolves
 3. Every relative markdown link - resolve it from the linking file's directory
 4. The README structure tree - diff it against the actual directory listing
 5. Every command block - check the file it references exists and the flags are real
 6. Version numbers - collect every occurrence and confirm a single value (4.0.0)
 7. Changelog - confirm no duplicate version heading and no date inversion
 8. Department names - confirm every slug used in prose appears in {SKILL_DIR}/references/department-index.md
 9. Error codes - confirm every code cited in prose exists in {SKILL_DIR}/references/error-codes.md
10. Tier figures - confirm department count, function blocks and prefixes all agree

For each FAIL, give the file, the line, what it claims and what is actually true.

Do not fix anything. Report only. A documentation audit that also edits cannot report honestly
what it found.
```

## Notes

- **"Every count must be verified by counting"** is the rule that catches the most common documentation defect. A predecessor package claimed 16 departments in five places, including in a prompt intended for an AI to follow, while shipping 11. An AI that trusted the claim looked for 16 files, found 11, and filled the gap with invented content.
- **The structure tree must match disk exactly.** The same predecessor's README tree omitted whole categories of files that actually existed - the models, scripts, tests and memory directories, the changelog, four reference subdirectories and every department subdirectory. A reader following that tree would not know three fifths of the package existed.
- **Documentation is scanned by the security sweep too.** Writing a forbidden construct's literal name into a markdown file, even to prohibit it, makes the package fail its own check. Describe such constructs instead; the test suite assembles the tokens at runtime for the same reason.

## Expected Output

The AI should return, in the language of the current conversation: (1) the written or reviewed documentation at the declared artifact paths; (2) every figure stated alongside the counting command used to verify it; (3) in audit mode, each item as PASS or FAIL with evidence - file, line, claimed value, actual value - and no edits. Any figure that cannot be verified is reported as unverified, never assumed. The work runs at Harness L3 minimum.

## Self-Check Checklist

After the run, verify each item:

- [ ] Every count stated matches a recount, and the verification command is stated alongside it.
- [ ] Tier figures agree everywhere: 18 departments, 7 domains, 18 function blocks, 117 error codes over 19 prefixes, 148 files.
- [ ] Every named file exists and every written path resolves.
- [ ] Every relative markdown link target exists.
- [ ] The structure tree matches the disk exactly - no omissions, no invented entries.
- [ ] The version is a single value (4.0.0) across all locations; the changelog has no duplicate version and no date inversion.
- [ ] No absolute user path is hardcoded; `{SKILL_DIR}` and `{WORKSPACE_ROOT}` placeholders are used instead.
- [ ] No credential value appears; only environment variable names.
- [ ] No forbidden construct token is written literally anywhere, including inside prohibition text.
- [ ] No verification is claimed that was not performed.
- [ ] Documentation artifacts were written under `{WORKSPACE_ROOT}`, never into `{SKILL_DIR}`.
