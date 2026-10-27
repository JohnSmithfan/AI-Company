# Contributing

Rules for changing this package. Most of them exist because a predecessor package broke them and
the breakage was invisible until much later.

Read [README.md](README.md) for the package overview and
[references/scaling.md](references/scaling.md) for how tier changes work.

## Ground Rules

| Rule | Detail |
|---|---|
| Verify before you claim | Every count, path and command you state must be checked by running something. A recalled number is a guess |
| One authoritative location | Shared code lives only in `references/method-patterns.md` §3. Everywhere else links |
| Documentation matches disk | The README structure tree is a verification target, not decoration |
| Tests fail loudly | A test that cannot pass yet must FAIL with a clear message, never skip silently |
| No secrets, ever | Configuration holds environment variable **names**. A value in a file is a leak |
| Placeholders, not paths | `{SKILL_DIR}` and `{WORKSPACE_ROOT}` — never an absolute user path |

## Adding a Department

⚠️ **At this tier you normally cannot.** The 18 departments are fixed by the merge tree; adding a
19th is a tier change, which goes through the self-scaling proposal flow, not through a direct edit.

If you genuinely need a new function at the current tier:

1. Check whether it belongs inside an existing department as a **responsibility** (§3.x of its D2
   page) rather than as a department. Most "new department" requests are actually this
2. If it does not fit anywhere, that is evidence the tier is wrong — run
   `pwsh -File scripts/self-scale.ps1 -Action evaluate` and report the result
3. Do not add a department unilaterally. It breaks `department_count`, the function-block
   conservation invariant, the domain department counts and the error-code prefix inventory

## Adding an Error Code

| Rule | Detail |
|---|---|
| Prefix | Must already be declared in `SKILL.md` → `error_code_prefixes` and defined in `references/error-codes.md` |
| Numbering | **Append to the end.** Never insert in the middle, never leave a gap |
| Format | `<PREFIX>_<NNN>`, three digits, zero-padded |
| Sub-namespace | `<PREFIX>_E<NNN>` for runtime-invocation errors; document the namespace |
| Four fields | Message, Trigger Condition, Resolution Steps — all mandatory |

⚠️ **Why numbering gaps are forbidden:** a predecessor package's `CTO_` series jumped from `006` to
`009` when branch codes were added. Nobody could later tell whether `CTO_007` and `CTO_008` were
deprecated or simply forgotten. A gap is an unanswered question you leave for whoever reads next.

Verification after adding:

```powershell
# every prefix must be continuous from 001
python tests\test-method-patterns.py
# look for test_error_code_numbering_has_no_gaps
```

If a prefix is revived after a tier change, it **restarts at `001`** in its new department. It does
not inherit the retired series, because that series covered a different functional scope.

## Adding a Workflow

**Core set (WFT-001~010)** — numbering is fixed.

| Action | Allowed |
|---|---|
| Append a new core workflow | ✅ as WFT-011, WFT-012, … |
| Reorder or renumber an existing one | ❌ never |
| Occupy a free slot inside 001–010 | ❌ never |
| Retire one | Mark deprecated, keep the entry and the number |

**Extension set (`WFT-1xx`)** — for domain-specific workflows.

| Rule | Detail |
|---|---|
| Naming | `WFT-1<domain#><nn>`; domain numbers follow `references/department-index.md`: 1 governance · 2 finance · 3 technology · 4 security · 5 people · 6 growth · 7 delivery |
| Example | `WFT-103` = third extension in the governance domain |
| Budget | This tier: 0–4 total, at most 2 per domain |
| Range | Must never occupy 001–099 |
| Registration | Add the full schema to `references/exec/workflows-schema.md` **and** reference it from the owning department's D2 page under `## Workflows` |

⚠️ An extension workflow that no document references is an orphan and will never be reached.

Every workflow definition needs: `id`, `name`, `trigger`, `mode`, `owner`, `phases` (each with an
entry condition and exit criterion), `sla`, `on_failure` with its error code, and `idempotent`.

**Mode assignment is not a preference.** It follows from reversibility × external visibility.
Nothing irreversible and externally visible may be `Auto`. WFT-010 is `Approve` and can never be
lowered.

## Changing the Frontmatter

| Field | Constraint |
|---|---|
| `name` | Single-line quoted scalar. Never a `\|` or `>` block scalar |
| `description` | ≤ **1024 characters** — a hard import-time limit, not a style preference |
| `errors` | Stays `[]`. The full table lives in `references/error-codes.md` |
| `department` enum | **Inlined** (`auto` + the 18 slugs; gate G6 verifies). The authoritative copy with routing detail lives in `references/department-index.md` |
| `permissions` | ⚠️ **Immutable.** See below |
| `metadata` tier triple | `scale_tier`, `department_count`, `function_block_count` must agree with disk and with `.scaling-state.json` |
| Total length | ≤ **150 lines** (currently 143) |

⚠️ Gate G6 requires the department enum inlined at every tier: `auto` plus the
tier's department slugs. The 18 large-tier entries fit inside the 150-line
budget; the predecessor's externalisation rule is superseded.

### The frontmatter fields you may never change

```yaml
permissions:
  files:
    read:  ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
    write: ["{WORKSPACE_ROOT}/**"]
    deny:  ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]
```

| Change | Verdict |
|---|---|
| Add `{SKILL_DIR}/**` to `write` | ❌ Grants self-modification |
| Remove any `deny` entry | ❌ Removes a P0 security boundary |
| Narrow `read` | ⚠️ May break reference loading; justify explicitly |
| Add a `network` entry | ⚠️ Requires a stated need and a review |

These are enforced by upgrade gates G1 and G3 and by the test class D. **They are non-waivable,
including by human approval** — an approval is a control for business scale change, not for a
security boundary change.

## Changing the Self-Scaling Mechanism

| Component | Changeable? |
|---|---|
| Thresholds in `scaling-config.json` | ✅ with a recorded basis |
| Evaluation interval | ✅ |
| The six gate definitions | ⚠️ Only by regenerating the specification plus a human audit |
| `upgrade_policy: propose-only` | ❌ There is no other legal value |
| Adding an `install` action to `self-scale.ps1` | ❌ Never — see `references/scaling.md` §1 |
| `immutable_paths` | ❌ Removing an entry disables a gate |

## Running the Checks

```powershell
cd <package root>
$env:SKILL_DIR = (Get-Location).Path
$env:WORKSPACE_ROOT = (Get-Location).Path

python tests\test-method-patterns.py          # must exit 0
python -m py_compile models\adapters\adapter_interface.py
python models\adapters\adapter_interface.py   # expect "config paths ok : 7/7"
pwsh -File scripts\self-scale.ps1 -Action status
```

The suite has four classes:

| Class | Guards |
|---|---|
| A — behaviour | The 10 templates do what their contracts say |
| B — source integrity | The authoritative files exist and contain what they must |
| C — structural consistency | Tier invariants: counts, conservation, links, file total |
| D — immutable boundary | Nothing can alter `tests/` or `permissions` |

⚠️ **Class B exists because of a real defect.** A predecessor's suite inlined its own copies of the
10 templates and never read the source file it claimed to test. The authoritative source was
missing an entire masking branch and the suite still reported 19/19 green. A test that cannot see
its subject cannot fail.

## What Not To Do

| Mistake | Why it matters |
|---|---|
| Copy a template implementation into a department file | Creates a second authoritative source that will diverge |
| Name a department sub-manifest `SKILL.md` | A recursive loader registers it as an independent skill |
| Use a free-form function-block heading | Breaks mechanical counting, so conservation cannot be verified |
| State a count you did not verify | A predecessor claimed 16 departments in five places while shipping 11; an AI following it invented the missing five |
| Write a forbidden construct's literal name into any file | The security sweep scans documentation too — describe it instead |
| Commit `__pycache__`, `.pyc`, `.skill-upgrade/` or a local review report | All are covered by `.gitignore`; do not force-add them |
| Delete before copying during any rollback | If the copy fails, the data is gone with no recovery path |
| Claim "fixed" or "verified" on an exit code alone | An exit code proves execution, not outcome |
| Build or keep crappy code (oversized monoliths, copy-paste duplication, dead branches, commented-out live blocks, TODO/FIXME/HACK debt) | Adds historical burden; explicit prohibition in `README_FOR_AI.md` §14.5/§14.6 |
| Leave an orphan, near-duplicate, empty, or "kept for history" file in the package | Every file must earn its place; see File Hygiene (§14.6) and P8/P9/P10/P53 |

## License

Contributions are licensed under GNU GPL v3 — see [LICENSE](LICENSE). Derivatives must remain
GPL v3.
