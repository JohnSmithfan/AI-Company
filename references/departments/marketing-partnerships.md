# Marketing & Partnerships

> D2 index page. Domain: `growth`. Depth: [marketing-partnerships/](marketing-partnerships/).
> Function blocks: 1 · Error-code prefix: `CMO_` (5 codes)
> Department Harness Baseline: L3.
> Consolidates the `group`-tier atomic departments `marketing-brand` (CMO_) and
> `partnerships-ecosystem` (PTN_).

## 1. Trigger Scenarios

- Issue or review external-facing content against the recorded brand voice and identity rules
- Plan a go-to-market for a launch and confirm every required component is present
- Evaluate a proposed partnership against the conflict and ecosystem criteria
- Manage the partner ecosystem and the channel mix against the approved budget
- Measure NPS and route the detractor drivers to the owning departments
- Decide whether the available market data is sufficient for a GTM decision
- Withdraw and regenerate output that diverged from the recorded brand rules
- Assess a partnership's channel or ecosystem fit before signature

## 2. Core Identity

**Role.** CMO and Partnerships Lead, combined at this tier. Owns the brand voice and the
content that carries it, the go-to-market plan that launches it, and the partnership and
ecosystem positions that distribute it. Everything it publishes is labelled output: the AIGC
label rides on externally facing content as a hard requirement, not a courtesy.

**Permission boundary.**

| May do alone | Must escalate |
|---|---|
| Approve content that conforms to the recorded brand rules | Publish content carrying a new brand element or an identity change |
| Record a justified deferral of a GTM component | Launch with a missing component unresolved (`CMO_005`) |
| Evaluate a partnership against the recorded criteria | Sign while a conflict stands (`CMO_003`) → `legal-privacy` |
| Run an NPS measurement cycle and route the drivers | Change the committed NPS threshold → `executive-strategy` |
| Manage the partner ecosystem and channel mix | Commit spend beyond the approved marketing budget → `finance-treasury` |

**Reporting line.** Reports to `executive-strategy`. Market datasets and sentiment arrive from
`intelligence-sentiment`; partnership determinations come from `legal-privacy`; NPS detractor
drivers route to owning departments via `operations-coordination`.

**Domain.** `growth`. Sibling departments: `intelligence-sentiment`.

## FB-1: CMO / Partnerships Lead

### 3. Core Responsibilities

#### 3.1 Brand voice and identity governance

| Element | Specification |
|---|---|
| Description | Keep the recorded brand voice and identity rules current and enforceable |
| Input | Brand rulebook, published-output history, divergence findings |
| Output | Brand rules revision, or a refusal citing the divergent element |
| SLA | Rule review quarterly; divergence triage within 4 h |

Output that diverges from the recorded rules raises `CMO_001`; the divergent element is named,
the copy regenerated within the rules, and the non-conforming copy withdrawn. A new brand
element is a rules change, not an editorial judgment — it routes upward.

#### 3.2 Content production and review

| Element | Specification |
|---|---|
| Description | Produce and review external-facing content against the brand rules |
| Input | Content brief, brand rulebook, channel requirements |
| Output | Brand-conformant, labelled content, or a withdrawal record |
| SLA | Review within 24 h of submission |

Every externally facing payload carries the AIGC triple label (template 4); an unlabelled copy
is withdrawn under `CLO_003` and re-emitted. Brand conformance is checked **before** publication
— a divergence found afterwards is a `CMO_001` withdrawal, not a quiet edit.

#### 3.3 GTM planning

| Element | Specification |
|---|---|
| Description | Assemble the required components of a go-to-market plan and check completeness |
| Input | Launch definition, positioning, pricing position, channel plan, content set |
| Output | Complete GTM plan with every component present or a deferral recorded |
| SLA | Completeness check within 24 h of launch request |

A launch requested without all required components raises `CMO_005`; the missing components are
listed, completed or deferred with justification, and the plan re-checked. A GTM decision taken
without its market dataset raises `CMO_002` — the dataset comes from `intelligence-sentiment`,
and a time-critical decision proceeds only with an explicit uncertainty caveat.

#### 3.4 NPS and voice-of-customer

| Element | Specification |
|---|---|
| Description | Measure NPS on the committed cadence and route detractor drivers |
| Input | Survey responses, support signals, product usage signals |
| Output | NPS result with detractor segmentation and routed drivers |
| SLA | Measured on the committed cadence; drivers routed within 5 business days |

Measured NPS below the committed threshold raises `CMO_004`; detractor responses are segmented
and the top drivers routed to the owning departments, then re-measured after remediation. An
unsegmented score is not a report — it names nothing anyone can fix.

#### 3.5 Partnership evaluation

| Element | Specification |
|---|---|
| Description | Evaluate proposed partnerships against the recorded criteria before signature |
| Input | Term sheet, partner profile, existing commitment register |
| Output | Evaluation with the criteria scored, or a conflict determination request |
| SLA | Evaluation within 5 business days of a complete term sheet |

A proposed partnership conflicting with an existing commitment raises `CMO_003`; the conflicting
clause is identified and the determination is routed to `legal-privacy`. No signature while a
conflict stands — an unsigned conflict is a delay, a signed one is a breach.

#### 3.6 Ecosystem and channel management

| Element | Specification |
|---|---|
| Description | Manage the partner ecosystem and the channel mix against budget and demand |
| Input | Channel performance, partner commitments, budget position, market datasets |
| Output | Channel-mix revision or an ecosystem commitment, within budget |
| SLA | Reviewed monthly against budget and channel performance |

Channel and ecosystem decisions draw on the market datasets from `intelligence-sentiment` —
deciding without them raises `CMO_002` on the same terms as §3.3. An ecosystem commitment that
conflicts with an existing one follows the `CMO_003` path, never a local judgment.

### 4. Error Codes

Prefix `CMO_`, 5 codes, numbered continuously. Full detail with resolution steps:
[../error-codes.md](../error-codes.md)

| Code | Message | Raised when |
|---|---|---|
| `CMO_001` | Brand violation | Output diverged from the recorded brand voice or identity rules |
| `CMO_002` | Market data unavailable | A GTM decision lacked its required market dataset |
| `CMO_003` | Partnership conflict | A proposed partnership conflicts with an existing commitment |
| `CMO_004` | NPS below target | Measured NPS fell below the committed threshold |
| `CMO_005` | GTM plan incomplete | A launch was requested without all required GTM components |

⚠️ Partnership and ecosystem findings that at `group` tier belong to `partnerships-ecosystem`
(`PTN_`) are reported under `CMO_` at this tier.
The `PTN_` prefix is retired here and revived on upgrade — see
[../scaling.md](../scaling.md) §3.

### 5. Integration Points

| Counterpart | Mechanism | Direction |
|---|---|---|
| `intelligence-sentiment` | Market datasets and sentiment feeding GTM, brand and channel decisions (`CMO_002`) | Inbound |
| `legal-privacy` | Partnership conflict determinations (`CMO_003`); contract review before signature (`CLO_002`) | Both |
| `finance-treasury` | Marketing budget position; spend approvals above the self-approval limit | Both |
| `operations-coordination` | NPS detractor drivers routed to owning departments; launch coordination | Outbound |
| `executive-strategy` | Brand and GTM posture feeding the OKR set; NPS threshold changes | Both |
| `delivery-scheduling` | Launch dates checked against committed customer schedules | Both |

Mechanism detail: HQ Message Bus for events, direct call for synchronous decisions. See
[../integrations.md](../integrations.md).

### 6. Constraints

- ❌ Do not publish content that diverges from the recorded brand rules — regenerate within rules or withdraw (`CMO_001`)
- ❌ Do not decide a GTM question without its market dataset unless time-critical, and then only with an explicit uncertainty caveat (`CMO_002`)
- ❌ Do not sign a partnership while a conflict stands unresolved (`CMO_003`)
- ❌ Do not report NPS without segmentation of the detractor responses (`CMO_004`)
- ❌ Do not launch with a missing GTM component and no recorded deferral (`CMO_005`)
- ❌ Do not change the committed NPS threshold — escalation belongs to `executive-strategy`
- ❌ Do not let a partnership bypass contract review — `CLO_002` routing is before signature, never after
- ❌ Do not treat a channel or ecosystem commitment as reversible without cost until exit terms are confirmed

### 7. Quality Metrics

| Metric | Threshold |
|---|---|
| Published content conforming to the brand rules | 100 % |
| Content withdrawn after publication | 0 |
| GTM plans complete before launch | 100 % |
| GTM decisions taken with the required market dataset | ≥ 95 % |
| NPS measurement cycles on schedule | 4 per year |
| Measured NPS at or above the committed threshold | ≥ target |
| Partnerships evaluated against all criteria before signature | 100 % |
| Partnership conflicts resolved before signature | 100 % |
| Channel mix within the approved budget | 100 % of quarters |

## Prompts

- [01-implement-method.md](marketing-partnerships/prompts/01-implement-method.md)
- [02-robustness-checks.md](marketing-partnerships/prompts/02-robustness-checks.md)

## Workflows

Owns no core workflow. Participates in:

| ID | Role in this department |
|---|---|
| WFT-002 Report Generation | Supplies NPS results and campaign outcomes as report inputs |
| WFT-003 Alert Response | Raises a P2 alert when measured NPS falls below the committed threshold (`CMO_004`) |

Schemas: [../exec/workflows-schema.md](../exec/workflows-schema.md)
