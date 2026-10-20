# Security Policy

## Supported versions

This package follows the ai-company versioning policy: the major version is
the scale-tier ordinal, so **major 4 = tier `large`**. Security fixes are
issued for the 4.x line.

| Version | Supported |
|---|---|
| 4.1.x | Yes — current release line |
| 4.0.x | Critical fixes only |
| 3.x and older | No |

Only the latest patch release of each supported line receives fixes.

## Reporting a vulnerability

Please report vulnerabilities **privately** to
`[SECURITY CONTACT — to be filled by the maintainer]`.
Do not open a public issue for security problems.

Include in your report:

- A description of the issue and its potential impact
- Step-by-step reproduction instructions
- The affected files or code paths
- Any suggested mitigation

You will receive an acknowledgment within 7 days. Please do not disclose the
issue publicly before a fix is coordinated.

## Disclosure timeline

This project follows coordinated disclosure with a **90-day** window:

1. **Day 0** — you report privately to
   `[SECURITY CONTACT — to be filled by the maintainer]`.
2. **Within 7 days** — the maintainers acknowledge and open a tracking item.
3. **Within 90 days** — a fix or mitigation is released (or a deadline
   extension is agreed with you).
4. **After release** — public disclosure is coordinated with you; if no fix is
   available at day 90, details may be published with mitigations.

## Security baseline of this package

Package scope: `ai-company` v4.0.0, scale tier `large` — 18 departments
across 7 domains, 117 error codes across 19 prefixes, 148 package files. The
only defined tier transition is `large` → `group` (36 departments), and it is
propose-only.

- **Capability ceiling.** The maximum capabilities this skill may exercise are
  declared in the `permissions` block of the `SKILL.md` frontmatter: reads
  limited to `{WORKSPACE_ROOT}/**` and `{SKILL_DIR}/**`, writes only to
  `{WORKSPACE_ROOT}/**`, and **no network access and no command execution**.
  No code path, prompt, or script may exceed those declared permissions. Verify
  per the **Compliance Verification** section of
  [`references/method-patterns.md`](references/method-patterns.md).
- **Deny list.** The `deny` entries (`~/.ssh/**`, `~/.aws/**`, `~/.config/**`,
  `/etc/**`, `{WINDOWS_DIR}/**`) are a P0 security boundary and must never be
  trimmed.
- **No self-exemption in upgrades.** Self-upgrade proposals must never modify
  `tests/` or the `permissions` block of `SKILL.md`; this invariant is asserted
  by `tests/test-method-patterns.py`.
- **Human-gated, propose-only tier changes.** `scripts/self-scale.ps1` with
  `-Action evaluate` does not modify skill content. It writes back only its own
  bookkeeping fields (`next_evaluation`, `last_metrics`, `metrics_provenance`,
  `routing_miss_streak`, `validation`) to `.scaling-state.json`; when a scaling
  threshold is hit it additionally writes a pending upgrade package under
  `{WORKSPACE_ROOT}/.skill-upgrade/<timestamp>/` and records it in
  `pending_proposals`. Nothing is ever installed. Gates **G1–G3** (permissions,
  tests, deny-list and gate logic unchanged) are **non-waivable, even with
  human approval** — approval is a control for business scale change, not for a
  security boundary change.
- **Zero dynamic code execution.** No dynamic evaluation of user input and no
  remote-code-fetch construct in any script or prompt
  (`README_FOR_AI.md` §9.4, P25).
- **Zero hardcoded secrets.** Credentials are read exclusively from environment
  variables; configuration records the variable *name*, never the value — not
  even sample keys (`README_FOR_AI.md` §9.4, P20).
- **PII masking.** Personal data must be masked as `[EMAIL]`, `[IP]` and
  `[PHONE]` before it enters any output; a contract branch without its code
  counterpart is a security defect, not a documentation gap.
- **AIGC labeling.** AI-generated content carries the triple labeling required
  by `README_FOR_AI.md` §9.2; a missing label is a compliance defect.
