---
department: marketing-partnerships
domain: growth
parent: ai-company
roles: [CMO, Partnerships Lead]
error_code_prefix: CMO_
function_blocks: 1
consolidates_group_tier: [marketing-brand, partnerships-ecosystem]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Marketing & Partnerships — Deep Specification

> D3 depth for [../marketing-partnerships.md](../marketing-partnerships.md). Read the D2 page
> first; this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| Content is ready to publish and its brand conformance is unverified | Brand review is here; an ungraded divergence is `CMO_001` waiting to ship |
| A launch is proposed and its GTM completeness is unknown | The component checklist is here; a launch without it is `CMO_005` |
| A partnership term sheet arrived before signature | Evaluation and the conflict check are here; signing while unresolved is refused |
| NPS came in below the committed threshold | Segmentation and driver routing are here (`CMO_004`) |
| A channel or ecosystem commitment needs an exit assessment | The commitment is evaluated here; the exit terms are a `legal-privacy` determination |

**Not** this department: market datasets and sentiment (`intelligence-sentiment`), contract
legality (`legal-privacy`), budget arithmetic (`finance-treasury`), launch schedule commitments
(`delivery-scheduling`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The table below is the source of truth;
an action outside it is refused and the response names the rung that holds authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Approve content within the recorded brand rules | This department | Reversible | — |
| Record a justified GTM component deferral (`CMO_005`) | This department | Reversible | — |
| Run an NPS cycle and route the drivers (`CMO_004`) | This department | Reversible | — |
| Sign a partnership cleared by `legal-privacy` | This department + `legal-privacy` | Reversible with cost | — |
| Change the committed NPS threshold | `executive-strategy` | — | rung 3 |
| Commit spend beyond the marketing budget | `finance-treasury` | — | rung 3 |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
executive-strategy
      ▲  brand posture, GTM outcomes, NPS trend
      │
marketing-partnerships  ◄──── market datasets (CMO_002) ◄──── intelligence-sentiment
      │  ▲
      │  └── detractor drivers ──── operations-coordination → owning departments
      │  └── conflict rulings ───── legal-privacy
      ▼  content, launches, partnership terms
  customers and partners
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Brand conformance review

Conformance is checked **before** publication, against the recorded rules — never against taste.

```text
1. Load the recorded brand rules and the channel requirements for the payload.
2. Check voice, identity elements and channel fit against the rules, item by item.
3. Conformant → label (template 4) and release.
4. Divergent → CMO_001. Name the divergent element. Regenerate within the rules.
5. A divergence found after publication is a withdrawal, not a quiet edit.
6. A new brand element is a rules change: route to executive-strategy, do not legislate
   it inside a content review.
```

### 3.B GTM completeness check

The required components, all of them:

| Component | Requirement |
|---|---|
| Positioning | One sentence a customer could repeat |
| Pricing position | Confirmed with `finance-treasury` against the margin floor (`CFO_002` scope) |
| Channel plan | Named channels with owners |
| Content set | Brand-conformant and labelled |
| Launch date | Checked against committed schedules with `delivery-scheduling` |
| Market dataset | Present, or an uncertainty caveat recorded under `CMO_002` |
| Support readiness | A named owner for launch-week issues |

A missing component raises `CMO_005`. The two legal outcomes are complete it, or record a
justified deferral — re-check before launch either way.

### 3.C Partnership evaluation

| Criterion | Evidence required |
|---|---|
| Strategic fit | Which line of the OKR set the partnership serves |
| Conflict check | Cleared against the existing commitment register (`CMO_003` on hit) |
| Channel economics | Volume and margin position, refreshed with `finance-treasury` |
| Exit terms | Confirmed by `legal-privacy` — a commitment without exit terms is not evaluated |
| Ecosystem effect | What the partnership forecloses in the channel mix |

A conflict routes to `legal-privacy` for a determination; no signature while it stands. An
evaluation that skips a criterion is re-run — the skipped criterion is the one that was
uncomfortable.

The channel classes the ecosystem is managed against:

| Channel class | Commitment rule |
|---|---|
| Direct | Reversible within the quarter; budget headroom required before the commitment |
| Partner | Exit terms confirmed by `legal-privacy` before the commitment scores final |
| Ecosystem | Any conflict with an existing commitment routes through `CMO_003` |

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `CMO_001` | Brand violation | Output diverged from the recorded brand voice or identity rules | 1. Identify the divergent element 2. Re-generate within brand rules 3. Withdraw the non-conforming copy |
| `CMO_002` | Market data unavailable | A GTM decision lacked its required market dataset | 1. Request from `intelligence-sentiment` 2. Proceed with an explicit uncertainty caveat only if time-critical 3. Re-decide once data arrives |
| `CMO_003` | Partnership conflict | A proposed partnership conflicts with an existing commitment | 1. Identify the conflicting clause 2. Route to `legal-privacy` for a determination 3. Do not sign while unresolved |
| `CMO_004` | NPS below target | Measured NPS fell below the committed threshold | 1. Segment the detractor responses 2. Route the top drivers to the owning departments 3. Re-measure after remediation |
| `CMO_005` | GTM plan incomplete | A launch was requested without all required GTM components | 1. List the missing components 2. Complete or record a justified deferral 3. Re-check before launch |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `intelligence-sentiment` | Dataset requests name the decision they serve; a dataset arrives with its collection window and its as-of timestamp |
| `legal-privacy` | Conflict determinations (`CMO_003`) arrive before signature, never after; contract review is the `CLO_002` route |
| `finance-treasury` | Budget position is refreshed before a launch commitment, not at invoice time |
| `operations-coordination` | NPS detractor drivers route to the owning department with the segment evidence attached |

## 6. Constraints

- ❌ Do not publish content that diverges from the recorded brand rules (`CMO_001`)
- ❌ Do not quietly edit a post-publication divergence — withdraw it
- ❌ Do not decide a GTM question without its dataset unless time-critical, and then only with a caveat (`CMO_002`)
- ❌ Do not sign while a partnership conflict stands unresolved (`CMO_003`)
- ❌ Do not report an unsegmented NPS score as a report (`CMO_004`)
- ❌ Do not launch with a missing component and no recorded deferral (`CMO_005`)
- ❌ Do not change the committed NPS threshold locally
- ❌ Do not let an ecosystem commitment bypass the exit-terms check

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Brand conformance | Published payloads passing the §3.A check before release ÷ total published |
| Post-publication withdrawals | `CMO_001` withdrawals ÷ total published payloads |
| GTM completeness | Launches with all components present or deferred-with-justification at launch time |
| Data-backed decisions | GTM decisions with their dataset attached ÷ total GTM decisions |
| NPS recovery | Detractor drivers routed within 5 business days ÷ total drivers |
| Conflict resolution before signature | Conflicts resolved pre-signature ÷ total conflicts raised |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-CMO-01 · Review content against the brand rules

```text
1. Load the recorded brand rules and the channel requirements.
2. Check voice, identity elements and channel fit, item by item.
3. Conformant → label (template 4) and release.
4. Divergent → CMO_001. Name the divergent element; regenerate within the rules.
5. Post-publication divergence → withdraw the copy; record the withdrawal.
6. A new brand element routes to executive-strategy as a rules change.
```

### SOP-CMO-02 · Assemble and check a GTM plan

```text
1. List the §3.B components against the launch definition.
2. Missing component → CMO_005.
3. Complete it, or record a justified deferral naming the risk accepted.
4. Confirm the pricing position with finance-treasury before the launch commitment.
5. Check the launch date with delivery-scheduling against committed schedules.
6. Confirm the market dataset, or record the CMO_002 caveat for a time-critical launch.
7. Re-check completeness. Launch only on a complete plan or a plan with recorded deferrals.
```

### SOP-CMO-03 · Evaluate a partnership

```text
1. Receive the term sheet and the partner profile.
2. Score the §3.C criteria. A skipped criterion re-runs the evaluation.
3. Conflict with an existing commitment → CMO_003. Identify the conflicting clause.
4. Route the conflict to legal-privacy for a determination. No signature while it stands.
5. Confirm the exit terms with legal-privacy before the commitment is scored final.
6. Record the evaluation with the criteria, the scores and the determination reference.
7. Sign only on a completed evaluation with no standing conflict.
```

### SOP-CMO-04 · Run an NPS cycle and route the drivers

```text
1. Collect the survey responses on the committed cadence.
2. Segment promoters, passives and detractors. An unsegmented total is not a result.
3. Below the committed threshold → CMO_004.
4. Rank the detractor drivers by frequency and severity.
5. Route the top drivers to the owning departments with the segment evidence attached.
6. Re-measure after remediation and compare against the prior cycle.
7. A threshold change escalates to executive-strategy; it is never adjusted locally.
```

### SOP-CMO-05 · Manage a channel or ecosystem change

```text
1. Request the market dataset from intelligence-sentiment, naming the decision it serves.
2. Absent dataset → CMO_002; proceed only with a caveat, and re-decide when it arrives.
3. Score the change against budget, channel performance and the ecosystem effect.
4. Conflict with an existing commitment → CMO_003 path, never a local judgment.
5. Refresh the budget position with finance-treasury before committing.
6. Record the change with its dataset reference, its budget position and its review date.
```

⚠️ SOP-CMO-03 step 4 is the discipline: an unsigned conflict is a delay, a signed one is a
breach. The evaluation exists so the delay happens before signature, not after.
