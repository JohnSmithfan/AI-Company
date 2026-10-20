## Change description

<!-- What changed and why. One logical change per branch and per PR (CONTRIBUTING.md). -->

## Test verification

- [ ] `python tests/test-method-patterns.py` passes (state the resulting test count in the PR body)
- [ ] If `scripts/self-scale.ps1` changed: the file parses clean and `-Action evaluate` runs
- [ ] If a package file was added, renamed, or removed: the README trio structure trees and every file-count claim are synced (`README_FOR_AI.md` acceptance checks)

## Impact scope

- [ ] `SKILL.md` `permissions` block untouched (the suite enforces this)
- [ ] `tests/` untouched (the suite enforces this)
- [ ] `CHANGELOG.md` `[Unreleased]` updated
- [ ] No file names containing spaces, and no misspelled variants (P51)

## Breaking changes

<!-- Describe any breaking change, or write "None". A breaking change requires a MAJOR version bump. -->
