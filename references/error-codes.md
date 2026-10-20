# Error Codes — Large Tier

> Loaded on demand (D2/D3). The root `SKILL.md` frontmatter carries `errors: []` plus a
> prefix list only — inlining this table would consume ~120 lines of the D1 layer on
> every invocation, while most tasks touch one or two codes.
>
> **Format** `<PREFIX>_<NNN>`, numbering **continuous from 001 with no gaps**.
> **Every entry** carries Message / Trigger Condition / Resolution Steps.
> Sub-namespace `<PREFIX>_E<NNN>` is used for model-management codes (see `MDL_` below).

## Prefix Inventory

| Class | Prefixes | Codes |
|---|---|---|
| Department (18) | `CEO_` `COO_` `BRD_` `CFO_` `CRO_` `PRC_` `CTO_` `FW_` `MDL_` `CISO_` `CLO_` `IRP_` `CHO_` `KNM_` `CMO_` `INTEL_` `CQO_` `PMGR_` | 107 |
| Infrastructure (1) | `SCL_` (self-scaling) | 10 |
| **Total** | **19** | **117** |

Per-prefix counts: `CEO_` 8 · `COO_` 6 · `BRD_` 6 · `CFO_` 6 · `CRO_` 6 · `PRC_` 5 ·
`CTO_` 8 · `FW_` 7 · `MDL_` 7 · `CISO_` 6 · `CLO_` 6 · `IRP_` 5 · `CHO_` 5 · `KNM_` 5 ·
`CMO_` 5 · `INTEL_` 6 · `CQO_` 5 · `PMGR_` 5 · `SCL_` 10

* * *

## Domain `governance` — department `executive-strategy` (prefix `CEO_`, 8 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CEO_001 | Decision requires data | A strategic decision is requested with no supporting dataset attached | 1. Identify the missing evidence class 2. Request from `intelligence-sentiment` or `model-data` 3. Re-submit with data reference |
| CEO_002 | Insufficient authority | Requested action exceeds the current role's authorization matrix | 1. Check the authorization matrix in D3 §8 2. Escalate one level via the Board ladder 3. Record the escalation in the audit trail |
| CEO_003 | Cross-agent conflict | Two or more departments returned contradictory recommendations | 1. Freeze both recommendations 2. Route to `operations-coordination` for arbitration 3. Document the arbitration rationale |
| CEO_004 | Orchestration pipeline failed | A multi-department pipeline aborted mid-sequence | 1. Identify the failing stage from the trace ID 2. Re-run only the failed stage (idempotent) 3. If it fails twice, open `PMGR_005` |
| CEO_005 | Crisis protocol activation failed | Crisis trigger fired but the protocol did not start within 60 s | 1. Verify the trigger source is live 2. Start the protocol manually 3. File a post-incident review under `IRP_001` |
| CEO_006 | Strategic alignment check failed | A proposed initiative conflicts with the current OKR set | 1. Diff the initiative against active OKRs 2. Route to `strategy-planning` function block 3. Either amend the initiative or amend the OKR — never bypass |
| CEO_007 | Escalation timeout | An escalated item received no decision within its SLA (24 h default) | 1. Re-escalate to the next ladder rung 2. Notify the item owner 3. Log the timeout against the responsible role |
| CEO_008 | Crisis blacklist violation attempted | An action on the crisis blacklist was requested during an active crisis | 1. Refuse the action outright 2. Record the attempt with trace ID 3. Report to `board-governance` function block |

## Domain `governance` — department `operations-coordination` (prefix `COO_`, 6 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| COO_001 | SLA breach detected | A committed SLA metric fell below threshold for 2 consecutive measurement windows | 1. Identify the breaching metric 2. Trigger `WFT-003` Alert Response 3. Notify the owning department 4. Record in the SLA register |
| COO_002 | Resource conflict | Two departments claimed the same exclusive resource in the same window | 1. Compare priority classes (P1–P3) 2. Grant to the higher class 3. Re-queue the loser with backoff |
| COO_003 | OKR misalignment | A department's local targets diverge from the organization OKR set | 1. Diff local vs organizational targets 2. Route to `executive-strategy` 3. Realign or formally record the exception |
| COO_004 | Resource allocation failed | Allocation request could not be satisfied within the requested window | 1. Check pool utilization 2. Offer the next available window 3. Escalate to `CEO_002` if the request is P1 |
| COO_005 | Scheduling deadlock | Circular wait detected across ≥2 queued operations | 1. Break the cycle by pre-empting the lowest-priority holder 2. Re-queue pre-empted work 3. Record the deadlock signature to prevent recurrence |
| COO_006 | Cross-department coordination timeout | A coordination request received no acknowledgement within 4 h | 1. Re-send with elevated priority 2. Notify the target department's owner 3. Escalate to `HQ` arbitration if silent past 8 h |

## Domain `governance` — department `board-and-branch` (prefix `BRD_`, 6 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| BRD_001 | Board quorum not met | Fewer than the required number of board roles present for a binding vote | 1. Defer the vote 2. Notify absent members 3. Re-convene within 48 h |
| BRD_002 | Authorization matrix violation | An action was attempted outside the matrix grant for the acting role | 1. Block the action 2. Log with trace ID 3. Route to `CEO_002` if a grant amendment is genuinely needed |
| BRD_003 | Shareholder report overdue | A scheduled report passed its due date without publication | 1. Generate from the last consistent snapshot 2. Mark it as late in the register 3. Record the cause |
| BRD_004 | Escalation ladder exhausted | An item reached the top rung without resolution | 1. Freeze the item 2. Convene an out-of-cycle board review 3. Record the decision, including "no decision" |
| BRD_005 | Branch rollout criteria not met | A branch promotion was requested before its pilot metrics cleared threshold | 1. Report the unmet criteria with measured values 2. Extend the pilot window 3. Re-evaluate at the next gate |
| BRD_006 | Branch autonomy violation | A branch acted outside its scoped operations matrix | 1. Revoke the offending capability 2. Restore the pre-action state 3. Report to `CEO_002` and record in the branch register |

## Domain `finance` — department `finance-treasury` (prefix `CFO_`, 6 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CFO_001 | Budget overrun | Department spend exceeded its quarterly budget by >10 % | 1. Freeze non-essential spend 2. Produce a variance analysis 3. Submit to `CEO_002` for approval |
| CFO_002 | Pricing model invalid | A proposed price failed the margin floor or the elasticity sanity band | 1. Recompute unit economics 2. Compare against the margin floor 3. Revise or reject — do not ship an unpriced offer |
| CFO_003 | Analytics data missing | A financial report was requested but its source dataset is absent or stale >24 h | 1. Identify the missing source 2. Request refresh from `model-data` 3. Publish with an explicit data-freshness caveat if urgency demands |
| CFO_004 | Working capital target breached | DSO exceeded 45 days or DPO fell below 30 days | 1. Age the receivables/payables ledger 2. Escalate the top 5 exposures 3. Adjust collection or payment cadence |
| CFO_005 | Capex approval missing | A capital expenditure was initiated without a recorded approval | 1. Halt the expenditure 2. Retro-file the approval request 3. Record the policy exception |
| CFO_006 | Treasury position inconsistent | Cash position could not be reconciled across sources within tolerance | 1. Re-run reconciliation from source ledgers 2. Quarantine the unreconciled delta 3. Report to `internal-audit` function block |

## Domain `finance` — department `risk-audit` (prefix `CRO_`, 6 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CRO_001 | Risk threshold exceeded | A FAIR-scored risk crossed its accepted threshold | 1. Re-score with current data 2. Apply the pre-agreed mitigation 3. Notify `executive-strategy` if residual risk stays above threshold |
| CRO_002 | Circuit breaker triggered | Error rate or loss rate crossed the breaker threshold | 1. Confirm the breaker state (OPEN) 2. Stop the offending flow 3. Move to HALF_OPEN after the cool-down and probe |
| CRO_003 | FAIR assessment incomplete | A risk decision was requested without all four FAIR inputs | 1. List the missing inputs 2. Collect or estimate with a stated confidence 3. Re-run the assessment — never decide on partial FAIR |
| CRO_004 | Gate failure | A stage-gate check failed during a gated workflow | 1. Report the failing criterion with measured value 2. Remediate 3. Re-enter the gate — gates are never waived silently |
| CRO_005 | Risk register stale | A register entry passed its review date by >30 days | 1. Re-score the entry 2. Confirm or retire it 3. Update the next review date |
| CRO_006 | Audit evidence insufficient | An audit request could not be satisfied from the retained evidence | 1. Identify the evidence gap 2. Extend retention for the affected class 3. Report the gap to `board-and-branch` |

## Domain `finance` — department `procurement-billing` (prefix `PRC_`, 5 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| PRC_001 | Vendor evaluation incomplete | A procurement decision was requested with fewer than the required evaluation dimensions scored | 1. List the unscored dimensions 2. Collect scores or record a justified waiver 3. Re-run the evaluation |
| PRC_002 | Contract cost mismatch | Invoiced amount diverged from the contracted rate by >2 % | 1. Diff invoice lines against contract schedule 2. Dispute the delta with the vendor 3. Withhold the disputed portion |
| PRC_003 | Procurement approval missing | A purchase was initiated above the self-approval limit | 1. Halt the purchase 2. Route to the correct approval rung 3. Record the policy exception |
| PRC_004 | Billing reconciliation failed | Billed units could not be matched to metered usage within tolerance | 1. Re-meter the period 2. Quarantine unmatched units 3. Issue a credit or a supplemental invoice |
| PRC_005 | Unit economics unavailable | A pricing or investment decision lacked a computable unit-cost basis | 1. Identify the missing cost component 2. Source it from `finance-treasury` 3. Defer the decision if the basis remains unknown |

## Domain `technology` — department `engineering-tooling` (prefix `CTO_`, 8 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CTO_001 | Architecture violation | A proposed design breaks a recorded architectural constraint | 1. Cite the violated constraint and its ADR 2. Redesign or file an ADR supersession 3. Never merge without one of the two |
| CTO_002 | Agent creation failed | An agent scaffold could not be produced from the template | 1. Validate the template inputs 2. Check the target namespace is free 3. Re-run; if it fails twice, open `FW_005` |
| CTO_003 | Skill build failed | A skill package failed its build stage | 1. Read the build log 2. Fix the reported schema or dependency error 3. Rebuild — never skip the failing stage |
| CTO_004 | Production operation denied | A production-scoped operation was attempted without the required grant | 1. Refuse the operation 2. Route to the approval rung for production scope 3. Record the attempt |
| CTO_005 | MLOps pipeline error | A pipeline stage failed or produced no artifact | 1. Identify the failing stage 2. Re-run from the last good checkpoint 3. Escalate to `platform-mlops` if the stage fails twice |
| CTO_006 | Deployment failed | A deployment did not reach healthy state within its window | 1. Trigger the pre-defined rollback 2. Capture the failure evidence 3. Block re-deploy until root cause is recorded |
| CTO_007 | Developer tooling unavailable | An internal tool required by a workflow was unreachable | 1. Check the tool health endpoint 2. Fall back to the documented manual path 3. File an incident if downtime exceeds 30 min |
| CTO_008 | Three-stage deployment gate failed | A deployment failed one of the three gates (canary / staged / full) | 1. Identify the failing gate and metric 2. Halt promotion 3. Roll back to the previous stage and re-enter the gate after remediation |

## Domain `technology` — department `platform-mlops` (prefix `FW_`, 7 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| FW_001 | Schema validation failed | A manifest or payload failed its declared schema | 1. Report the offending field and expected type 2. Correct the producer 3. Re-validate before proceeding |
| FW_002 | Modularization violation | A module took a dependency that breaks the layering rule | 1. Cite the violated layering rule 2. Invert or extract the dependency 3. Re-run the dependency check |
| FW_003 | Registry lookup failed | A requested registry entry was absent or ambiguous | 1. Confirm the lookup key 2. Register the missing entry or disambiguate 3. Never fall back to a default entry silently |
| FW_004 | Learning pipeline error | The knowledge-distillation pipeline failed or produced an empty batch | 1. Check source availability 2. Re-run the batch 3. Retain the previous distilled state if the re-run fails |
| FW_005 | Scaffolding generation failed | A scaffold could not be generated for the requested archetype | 1. Validate the archetype name against the registry 2. Check template availability 3. Fall back to the nearest lower archetype |
| FW_006 | Harness constraint violation | A capability was declared at a Harness level it does not satisfy | 1. Report the unmet constraint for the claimed level 2. Either implement the constraint or declare the lower level 3. Never over-declare |
| FW_007 | CI/CD pipeline failed | A pipeline run ended in failure | 1. Read the failing job log 2. Fix or revert the offending change 3. Re-run the pipeline from the start |

## Domain `technology` — department `model-data` (prefix `MDL_`, 7 codes)

Sub-namespace: `MDL_E<NNN>` denotes model-invocation errors raised at call time rather than at configuration time.

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| MDL_001 | Model not found in registry | A requested model id has no registry entry | 1. Confirm the id spelling 2. Register the model or select a registered alternative 3. Never invoke an unregistered endpoint |
| MDL_002 | Model config file missing | A registry entry's `config_path` does not resolve to a file | 1. Run the registry path check 2. Create the missing config or remove the entry 3. Re-validate all 7 paths before any invocation |
| MDL_003 | Model disabled | The requested model is registered but flagged disabled | 1. Read the disable reason 2. Select the next model in the fallback chain 3. Request re-enablement through `platform-mlops` |
| MDL_004 | API key missing | The environment variable named by `env_var_name` is unset | 1. Report the variable **name** only — never its value 2. Halt the invocation 3. Request provisioning through the secret store |
| MDL_005 | Rate limit exceeded | A model provider returned a rate-limit response | 1. Apply template 8 backoff 2. Shift load to the fallback model 3. Review the configured `rpm`/`tpm` against actual demand |
| MDL_006 | Model config invalid | A config file parsed but violated the template field contract | 1. Diff against `models/api/template/config.json` 2. Add the missing fields 3. Re-validate before use |
| MDL_E007 | Model invocation failed | A call returned a transport or provider error | 1. Retry via template 5 with backoff 2. On exhaustion, move to the fallback model 3. Record the provider error class for trend analysis |

## Domain `security` — department `security-resilience` (prefix `CISO_`, 6 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CISO_001 | Security gate blocked | A gate check failed on a change destined for production | 1. Report the failing control 2. Remediate or record an accepted-risk exception with an expiry 3. Re-enter the gate |
| CISO_002 | CVSS score critical | A scored vulnerability reached CVSS ≥ 9.0 | 1. Open `IRP_001` immediately 2. Apply the mitigation or compensating control within 24 h 3. Report to `board-and-branch` |
| CISO_003 | STRIDE threat detected | A threat-model pass identified an unmitigated threat | 1. Classify the STRIDE category 2. Assign a control 3. Re-run the model to confirm closure |
| CISO_004 | Incident response required | A condition met the incident-declaration criteria | 1. Declare the incident 2. Start `WFT-005` 3. Preserve evidence before any remediation that could alter it |
| CISO_005 | Business continuity threshold breached | RTO or RPO exceeded its committed value in a recovery test | 1. Report the measured vs committed value 2. Identify the bottleneck stage 3. Re-test after remediation |
| CISO_006 | Control evidence expired | A control's supporting evidence passed its validity window | 1. Re-collect the evidence 2. Update the control record 3. Flag the control as unproven until refreshed |

## Domain `security` — department `legal-privacy` (prefix `CLO_`, 6 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CLO_001 | Compliance violation | An operation breached a recorded compliance obligation | 1. Halt the operation 2. Identify the obligation and its source regulation 3. Remediate and record the breach |
| CLO_002 | Contract review required | A contract or terms change was proposed without review | 1. Route to review before signature 2. Record the reviewer and outcome 3. Never auto-accept terms |
| CLO_003 | AIGC content non-compliant | Generated output lacked the required AIGC identification | 1. Re-emit through template 4 2. Verify all three layers (label / metadata / watermark) 3. Withdraw the unlabelled copy |
| CLO_004 | IP protection required | Output may incorporate third-party protected material | 1. Identify the suspected source 2. Replace or license 3. Record the determination |
| CLO_005 | Ethics review required | A use case matched an ethics-review trigger | 1. Route to `knowledge-ethics` 2. Record the review outcome 3. Do not proceed on a pending review |
| CLO_006 | Data residency violation | Personal data was processed or stored outside its permitted region | 1. Halt the transfer 2. Delete or repatriate the out-of-region copy 3. Record the incident under `CLO_001` |

## Domain `security` — department `incident-identity` (prefix `IRP_`, 5 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| IRP_001 | Incident declared | A security event met the declaration criteria | 1. Assign an incident commander 2. Start `WFT-005` 3. Open the evidence log before remediation |
| IRP_002 | Forensic evidence incomplete | Evidence required for analysis was unavailable or altered | 1. Record what is missing and why 2. Preserve remaining evidence read-only 3. Note the limitation in the final report |
| IRP_003 | Notification deadline at risk | A regulatory notification window will not be met | 1. Escalate to `legal-privacy` immediately 2. Prepare a provisional notification 3. Record the timeline |
| IRP_004 | Credential compromise suspected | An indicator suggested a credential may be exposed | 1. Revoke the credential 2. Rotate downstream dependencies 3. Audit usage for the exposure window |
| IRP_005 | Access review overdue | A periodic access review passed its due date | 1. Run the review immediately 2. Revoke unreviewed grants by default 3. Record the lapse |

## Domain `people` — department `lifecycle-training` (prefix `CHO_`, 5 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CHO_001 | Agent onboarding failed | An agent could not complete its onboarding checklist | 1. Report the unmet checklist item 2. Remediate the gap 3. Re-run onboarding — never mark complete with gaps |
| CHO_002 | Skill gap detected | A required capability has no assigned competent agent | 1. Record the gap against the capability matrix 2. Route to training or recruitment 3. Mark affected tasks as blocked until filled |
| CHO_003 | Lifecycle violation | An agent acted outside its lifecycle stage permissions | 1. Suspend the agent 2. Identify the stage mismatch 3. Re-enter at the correct stage |
| CHO_004 | Training completion unverified | A certification was claimed without verifiable evidence | 1. Request the evidence artifact 2. Revoke the claim until produced 3. Record the verification method |
| CHO_005 | Headcount plan inconsistent | Declared establishment diverged from the active roster | 1. Reconcile roster against plan 2. Correct the plan or the roster 3. Record which was authoritative |

## Domain `people` — department `knowledge-ethics` (prefix `KNM_`, 5 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| KNM_001 | Knowledge extraction failed | A distillation run produced no usable knowledge item | 1. Check source availability and permissions 2. Re-run with a narrower scope 3. Retain the prior knowledge state |
| KNM_002 | Memory consolidation overdue | A memory class passed its consolidation interval | 1. Run consolidation for the class 2. Verify no item was dropped without supersession 3. Reset the interval timer |
| KNM_003 | Ethics review pending | A decision awaits an ethics outcome | 1. Block the dependent action 2. Route to review with the decision context 3. Record the outcome and any conditions |
| KNM_004 | Ethics violation confirmed | A reviewed item was found to breach the ethics baseline | 1. Halt the activity 2. Remediate or withdraw 3. Report to `board-and-branch` and record in the culture audit |
| KNM_005 | Knowledge supersession missing | A knowledge item was retired without a replacement reference | 1. Identify dependents of the retired item 2. Provide a replacement or an explicit deprecation notice 3. Update all references |

## Domain `growth` — department `marketing-partnerships` (prefix `CMO_`, 5 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CMO_001 | Brand violation | Output diverged from the recorded brand voice or identity rules | 1. Identify the divergent element 2. Re-generate within brand rules 3. Withdraw the non-conforming copy |
| CMO_002 | Market data unavailable | A GTM decision lacked its required market dataset | 1. Request from `intelligence-sentiment` 2. Proceed with an explicit uncertainty caveat only if time-critical 3. Re-decide once data arrives |
| CMO_003 | Partnership conflict | A proposed partnership conflicts with an existing commitment | 1. Identify the conflicting clause 2. Route to `legal-privacy` for a determination 3. Do not sign while unresolved |
| CMO_004 | NPS below target | Measured NPS fell below the committed threshold | 1. Segment the detractor responses 2. Route the top drivers to the owning departments 3. Re-measure after remediation |
| CMO_005 | GTM plan incomplete | A launch was requested without all required GTM components | 1. List the missing components 2. Complete or record a justified deferral 3. Re-check before launch |

## Domain `growth` — department `intelligence-sentiment` (prefix `INTEL_`, 6 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| INTEL_001 | Intelligence collection failed | A collection run returned no usable items | 1. Verify source availability and credentials 2. Re-run with a broader window 3. Record the source as degraded if it fails twice |
| INTEL_002 | Analysis confidence low | A product's confidence score fell below 40 % | 1. Identify the weakest evidence link 2. Collect corroborating sources 3. Publish with the confidence score stated, never omit it |
| INTEL_003 | Source verification failed | A source could not be verified against the reliability register | 1. Downgrade the source rating 2. Exclude it from products until re-verified 3. Record the verification attempt |
| INTEL_004 | Classification violation | Material was handled at a classification below its required level | 1. Re-classify immediately 2. Restrict distribution to the corrected level 3. Record the exposure window |
| INTEL_005 | SITREP generation failed | A situation report could not be produced on schedule | 1. Identify the missing input 2. Issue a partial SITREP with gaps marked 3. Re-issue in full once inputs arrive |
| INTEL_006 | Source registry corrupted | The reliability register failed its integrity check | 1. Restore from the last consistent snapshot 2. Re-verify entries touched since that snapshot 3. Record the corruption cause |

## Domain `delivery` — department `quality-visualization` (prefix `CQO_`, 5 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CQO_001 | Quality gate failed | A gate check failed during `WFT-004` or `WFT-007` | 1. Report the failing criterion with measured value 2. Remediate 3. Re-enter the gate — never bypass |
| CQO_002 | Idempotency violation | A repeated operation produced divergent side effects | 1. Identify the non-idempotent step 2. Add the missing guard or make the step retry-safe 3. Re-test with a double invocation |
| CQO_003 | Test coverage below threshold | Coverage fell below the 85 % acceptance threshold | 1. Report the uncovered paths 2. Add tests for the highest-risk gaps first 3. Re-measure before release |
| CQO_004 | Documentation incomplete | A required document section was missing or stale | 1. List the missing sections 2. Complete them 3. Re-run the structure-vs-disk consistency check |
| CQO_005 | DORA metric breach | A DORA metric crossed its committed threshold | 1. Identify the breaching metric 2. Route to the owning department 3. Track recovery over the next four deployments |

## Domain `delivery` — department `delivery-scheduling` (prefix `PMGR_`, 5 codes)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| PMGR_001 | Project deadline missed | A committed deadline passed with work outstanding | 1. Report the remaining scope 2. Re-baseline with the stakeholder 3. Record the cause for trend analysis |
| PMGR_002 | OKR unlinked | A work item has no traceable link to an active OKR | 1. Link the item or mark it as discretionary 2. Route discretionary work to `COO_003` 3. Never leave an item unlinked silently |
| PMGR_003 | Customer escalation | A customer issue met the escalation criteria | 1. Assign an owner within 1 h 2. Open the escalation record 3. Report status at the committed cadence until closed |
| PMGR_004 | Sprint commitment failed | Committed sprint scope was not delivered | 1. Report delivered vs committed 2. Adjust the next commitment using the measured velocity 3. Record the cause |
| PMGR_005 | Task decomposition failed | A task could not be decomposed into assignable units | 1. Identify the ambiguity blocking decomposition 2. Route to the requester for clarification 3. Re-decompose — do not assign an undecomposed task |

## Infrastructure — self-scaling (prefix `SCL_`, 10 codes)

Fixed at 10 codes across **all** tiers. `SCL_` is not a department prefix and does not count
toward `department_count`.

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| SCL_001 | Upgrade threshold not met | `-Force` was used while no T1–T4 threshold was crossed | 1. Record the measured values against all four thresholds 2. Proceed only if the operator accepts the flagged proposal 3. Update `next_evaluation` |
| SCL_002 | Requested upgrade has no builder | The requested target tier is not selectable from the current tier per `scaling-config.json`, no default target is defined for the current tier, or no builder is registered for the pair in this build | 1. Read the selectable targets for the current tier from the error message 2. Choose a target that has a builder, or pass `-TargetTier` explicitly 3. Do not invent a target tier |
| SCL_003 | Alias collision detected | A new department slug equals an existing historical alias | 1. Report the colliding slug and its legacy tier 2. Choose a different slug per the alias rules in scaling.md §5 3. Never reuse a retired slug |
| SCL_004 | Permission self-modification attempted | A proposal package changed `permissions`, `write` scope, `deny`, or the gate logic | 1. **Reject and delete the package** — this gate cannot be waived by human approval 2. Record the attempt with a diff 3. Report to the operator as a security event |
| SCL_005 | Test self-modification attempted | A proposal package's `tests/**` differs from the current package (added, removed or modified file) | 1. **Reject and delete the package** — cannot be waived 2. Record the attempted change 3. Report as a security event |
| SCL_006 | Upgrade package validation failed | The package failed any item of the README_FOR_AI.md §15 acceptance suite | 1. Report every failing item with its expected value 2. Regenerate the package 3. Never install a package that failed acceptance |
| SCL_007 | Scaling state file corrupted | `.scaling-state.json` failed schema or integrity validation | 1. Halt all scaling activity 2. Restore from the last valid state or re-initialize with the tier read from frontmatter 3. Record the corruption cause |
| SCL_008 | Target resolution rejected | The requested target tier is the same tier, a downgrade, outside the current tier's `selectable_targets`, or outside the tier vocabulary; a downgrade additionally requires written human approval | 1. Read the tier vocabulary and the selectable targets from the error message 2. For a downgrade: refuse automatic execution, require a written human justification, and produce a proposal with the deleted-content destination table 3. Re-run with a valid selectable target |
| SCL_009 | Tier already at maximum | An upgrade was requested while `current_tier` is `group` | 1. Report that `group` is the maximum tier 2. Suggest domain-level extension (`WFT-1xx`) instead 3. Take no action |
| SCL_010 | Function block conservation violated | Post-upgrade function-block total did not equal the target tier's expected value | 1. Report the expected vs actual count 2. Identify the lost or duplicated function blocks 3. Regenerate — never install a lossy upgrade |

* * *

## Deprecated Code Aliases

Populated only **after** an upgrade or a downgrade remaps a prefix. Empty at initial generation.

| Legacy code | Resolves to | Since | Reason |
|---|---|---|---|
| *(none)* | — | — | Initial generation at tier `large`; no prefix has been retired or revived |

Rules for this table:
- Entries are **append-only**; never delete a historical alias
- A legacy code must resolve to exactly one current code, or be marked `withdrawn` with a date
- Prefixes revived by an upgrade restart numbering at `001` in their new department — they do not
  inherit the retired numbering, because the retired series belonged to a different functional scope
