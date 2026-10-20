---
department: legal-privacy
domain: security
parent: ai-company
roles: [CLO, Privacy Officer]
error_code_prefix: CLO_
function_blocks: 1
consolidates_group_tier: [legal-compliance, privacy-data-protection]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Legal & Privacy — Deep Specification

> D3 depth for [../legal-privacy.md](../legal-privacy.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A contract, terms change or partnership agreement is ready for signature | Review authority sits here (`CLO_002`); `procurement-billing` handles the commercial arithmetic |
| Generated output is about to be released externally | AIGC identification is a legal obligation, not a formatting preference (`CLO_003`) |
| A takedown notice or an IP suspicion arrives | Determination authority — replace, license or defend — sits here (`CLO_004`) |
| A new flow will collect, process or store personal data | Legal basis and minimization must exist before the flow ships (`CLO_001`) |
| Data is about to move across a region boundary | Residency and transfer-mechanism review sits here (`CLO_006`) |
| An incident raises a notification question | This department owns the obligation; `incident-identity` owns the clock and the run (`IRP_003`) |

**Not** this department: incident execution and forensics (`incident-identity`), threat
modelling and control evidence (`security-resilience`), ethics review outcomes
(`knowledge-ethics`), contract commercial arithmetic (`procurement-billing`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The matrix below is the source of truth;
an action outside it escalates, and the response names the rung that holds the authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Block signature of an unreviewed instrument | This department | Reversible | — |
| Withdraw unlabelled AIGC output | This department | Reversible | — |
| Halt an operation breaching a recorded obligation | This department | Reversible with cost | — |
| Halt an out-of-region transfer | This department | Reversible | — |
| Require a DPIA before a PII flow ships | This department | Reversible | — |
| Accept non-standard liability terms | `board-and-branch` | Irreversible | rung 4 |
| Waive a DPIA requirement | `board-and-branch` | Irreversible | rung 4 |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
board-and-branch
      ▲  confirmed breach, litigation, waived DPIA
      │
executive-strategy
      ▲  compliance positions for external-impact decisions
      │
legal-privacy  ◄──── contract review requests ◄──── marketing-partnerships
      │  ▲            ethics triggers ──► knowledge-ethics
      │  └── notification clocks ◄──── incident-identity
      │  └── AIGC control interpretation ◄──── security-resilience
      ▼  review records, determinations
  signing and publishing departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements each.
This section adds the procedural detail.

### 3.A Contract review record

Every review produces a record. An instrument signed without one was never reviewed.

| Field | Requirement |
|---|---|
| Instrument ID | Trace ID from template 7, prefix `clo` |
| Counterparty | Named entity, not a role |
| Liability terms | Standard / non-standard, with every deviation listed |
| Data terms | PII involved, residency, transfer mechanism |
| Obligations created | Each becomes a recorded obligation future operations must not breach |
| Outcome | Approve / approve-with-changes / reject |
| Reviewer and date | Named — an anonymous review is not a review |

### 3.B AIGC triple-label verification

The label is three layers; one layer is not a label.

| Layer | Check |
|---|---|
| Label | Visible identification attached to the output |
| Metadata | Machine-readable identification embedded with the output |
| Watermark | Robust identification surviving format conversion |

Output failing any layer raises `CLO_003`. The remedy is re-emission through template 4 and
re-verification of all three layers; the unlabelled copy is withdrawn, not patched — a patched
copy keeps its original distribution history.

### 3.C Residency determination

| Step | Requirement |
|---|---|
| Enumerate datasets | Every dataset holding personal data |
| Map locations | Storage region and processing region, separately |
| Cite the mechanism | SCC, standard contract, certification — by name |
| Record the determination | Per dataset, with the as-of date |
| Re-verify | On every region change and on the scheduled cadence |

⚠️ "It is encrypted" is not a transfer mechanism. Encryption protects data in transit; it does
not confer permission to cross a boundary.

## 4. Error Codes (Full + Resolution Steps)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| `CLO_001` | Compliance violation | An operation breached a recorded compliance obligation | 1. Halt the operation 2. Identify the obligation and its source regulation 3. Remediate and record the breach |
| `CLO_002` | Contract review required | A contract or terms change was proposed without review | 1. Route to review before signature 2. Record the reviewer and outcome 3. Never auto-accept terms |
| `CLO_003` | AIGC content non-compliant | Generated output lacked the required AIGC identification | 1. Re-emit through template 4 2. Verify all three layers (label / metadata / watermark) 3. Withdraw the unlabelled copy |
| `CLO_004` | IP protection required | Output may incorporate third-party protected material | 1. Identify the suspected source 2. Replace or license 3. Record the determination |
| `CLO_005` | Ethics review required | A use case matched an ethics-review trigger | 1. Route to `knowledge-ethics` 2. Record the review outcome 3. Do not proceed on a pending review |
| `CLO_006` | Data residency violation | Personal data was processed or stored outside its permitted region | 1. Halt the transfer 2. Delete or repatriate the out-of-region copy 3. Record the incident under `CLO_001` |

⚠️ At `group` tier the privacy findings move to `privacy-data-protection` under prefix `PRV_`.
Here they report under `CLO_`; `PRV_` is retired at this tier and revived on upgrade — see
[../../scaling.md](../../scaling.md) §3.

## 5. Integration Points

Detailed in the D2 page §5. Protocol notes:

| Counterpart | Protocol |
|---|---|
| `security-resilience` | We interpret the AIGC and residency controls; they enforce the control set and hold the evidence. A control we cite as compliance must carry their current evidence |
| `incident-identity` | `IRP_003` hands us the notification clock. We own the obligation and the wording; they own the run. A clock assessment is never performed inside the incident run itself |
| `knowledge-ethics` | `CLO_005` routes the trigger; `KNM_003` holds the pending state. We record the outcome; we do not grade it |
| `marketing-partnerships` | Contract review requests arrive before signature, never after. A partnership conflict (`CMO_003`) gets a determination, not a veto by silence |
| `model-data` | PII handling and residency are enforced on data movement in pipelines; we supply the per-dataset determination |

## 6. Constraints

- ❌ Do not allow signature without a review record (`CLO_002`)
- ❌ Do not release output verified on fewer than all three AIGC layers
- ❌ Do not process PII without a recorded legal basis
- ❌ Do not accept encryption as a cross-border transfer mechanism
- ❌ Do not proceed on a pending ethics review (`CLO_005`)
- ❌ Do not delete a determination from the register — supersede it with a pointer
- ❌ Do not run a notification-clock assessment inside the incident itself
- ❌ Do not approve a tier upgrade — no department may

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Signed instruments with a review record | Signatures with a matching `clo` trace ID ÷ total signatures |
| AIGC three-layer verification | Releases with all three layers verified ÷ total releases |
| PII flows with a legal basis | Flows shipped with a recorded basis ÷ total flows shipped |
| Residency determinations current | Datasets with an in-date determination ÷ datasets holding PII |
| Notice acknowledgement latency | Acknowledgement timestamp minus notice receipt timestamp |
| Ethics routing latency | Routing timestamp minus trigger-match timestamp |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-CLO-01 · Review a contract or terms change

```text
1. Receive the draft instrument with counterparty and data terms.
2. Absent → CLO_002; signature is blocked until review completes.
3. Generate a trace ID (template 7, prefix "clo").
4. Check liability terms against the standard set; list every deviation.
5. Check data terms: PII involved, residency, transfer mechanism (3.C).
6. List the obligations the instrument creates - each becomes a recorded obligation
   that future operations must not breach (CLO_001 watches them).
7. Outcome: approve / approve-with-changes / reject. Record reviewer and date.
8. Non-standard liability terms → escalate to board-and-branch; do not accept locally.
9. Mask the record (template 9) and label it (template 4) before distribution.
```

### SOP-CLO-02 · Verify AIGC identification on output

```text
1. Receive the output and its distribution channel.
2. Re-emit through template 4 if any layer is missing.
3. Verify all three layers (3.B): label, metadata, watermark.
4. Any layer failing → CLO_003; withdraw the unlabelled copy, do not patch it.
5. Record the verification against the output's trace ID.
6. security-resilience enforces the control set; this SOP owns the interpretation.
```

### SOP-CLO-03 · Process a DMCA notice or IP suspicion

```text
1. Acknowledge within 1 business day - silence is not acknowledgement.
2. Identify the suspected source (CLO_004).
3. Determine: replace, license, or defend. Record the determination either way.
4. If replaced → withdraw the incorporating copy and record the replacement.
5. If licensed → record the licence terms and their scope.
6. If defended → record the basis and escalate the posture to board-and-branch.
7. Mask the determination (template 9) before it leaves this department.
```

### SOP-CLO-04 · Assess PII handling and residency

```text
1. Receive the data-flow description with its jurisdiction set.
2. No recorded legal basis → CLO_001; halt until the basis exists.
3. Apply minimization: collect only what the stated purpose needs.
4. Map storage region and processing region separately (3.C).
5. Cite the transfer mechanism by name; encryption alone is not a mechanism.
6. Out-of-region processing or storage → CLO_006:
   halt the transfer, delete or repatriate the copy, record under CLO_001.
7. Record the determination per dataset with an as-of date.
8. Re-verify on every region change and on the scheduled cadence.
```

### SOP-CLO-05 · Route an ethics trigger and keep the register

```text
1. A use case matches an ethics trigger → CLO_005.
2. Route to knowledge-ethics within 4 h with the decision context.
3. Block the dependent action while the review is pending (KNM_003).
4. Record the outcome and any conditions when it returns.
5. Never proceed on a pending review - "pending" is a blocked state, not a maybe.
6. Append the determination to the compliance register with its trace ID.
7. Supersede superseded determinations with a pointer; never delete.
```
