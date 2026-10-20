---
department: model-data
domain: technology
parent: ai-company
roles: [Model Manager, Data Engineer]
error_code_prefix: MDL_
function_blocks: 1
consolidates_group_tier: [model-management, data-engineering]
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []
---

# Model & Data — Deep Specification

> D3 depth for [../model-data.md](../model-data.md). Read the D2 page first;
> this file extends it with full procedures and the SOP set.
>
> ⚠️ This file is deliberately **not** named `SKILL.md` and carries **no** `name`, `slug`,
> `triggers` or `interface` fields. A recursive skill loader would otherwise register it as an
> independent skill colliding with the parent's triggers.

## 1. Trigger Scenarios (Extended)

Beyond the D2 list, this department is the correct route when:

| Situation | Why here rather than elsewhere |
|---|---|
| A call failed with a transport or provider error | Call-time failures are the `MDL_E` sub-namespace owned here; configuration-time faults are `MDL_001`–`MDL_006` |
| Two departments need the same dataset with different freshness | Pipeline ownership and freshness labelling sit here |
| A schema change would break a downstream consumer | Contract reconciliation is owned here before the change lands |
| An agent needs to call a model it has never used | Registry entry, calling policy and access grant all route here |
| Records from several sources must become one dataset | Multi-source fusion with provenance is owned here |

**Not** this department: pipeline health monitoring (`platform-mlops`), access-matrix
ratification (`board-and-branch`), model deployment gates (`engineering-tooling`), security
gate operation (`security-resilience`).

## 2. Core Identity (Extended)

### Authority model

Authority is **positional and bounded**, not personal. The matrix below is the source of
truth; an action outside it is refused and the response names the rung that holds authority.

| Decision class | Authority | Reversibility | Escalates to |
|---|---|---|---|
| Register a model and set its fallback position | This department | Reversible | — |
| Route a call to the next model in the fallback chain | This department | Reversible | — |
| Grant model access inside the recorded matrix | This department | Reversible | — |
| Permanently disable or retire a model | `executive-strategy` | Reversible with cost | rung 3 |
| Adopt a new provider adapter | This department + `security-resilience` review | Reversible | — |
| Land a breaking schema change | Affected departments via `operations-coordination` | Irreversible for consumers | — |
| Tier upgrade approval | **A human** | — | Never delegated to any department |

⚠️ The last row is absolute. No department, at any tier, approves its own structural change.
See [../../scaling.md](../../scaling.md) §1.

### Reporting and intake

```text
executive-strategy
      ▲  model retirement · policy exceptions
      │
model-data  ◄──── registry health signals ──── platform-mlops
      │  ▲
      │  └── agent capability needs ── engineering-tooling
      │  └── access-control review ──── security-resilience
      │  └── residency questions ───── legal-privacy
      ▼  registered models, fused datasets
  all departments
```

## 3. Core Responsibilities (Full)

The six responsibilities are specified in the D2 page §3.1–§3.6 with their four elements
each. This section adds the procedural detail.

### 3.A Registry entry structure

Every entry is validated against the template field contract before it may serve a call.
An entry missing a required field raises `MDL_006` at registration, not at first call.

| Field | Requirement |
|---|---|
| `model_id` | Unique, immutable once registered; spelling is confirmed on lookup (`MDL_001`) |
| `provider` | The provider the adapter targets |
| `config_path` | Resolves to a file; re-validated with the registry path check (`MDL_002`) |
| `env_var_name` | The variable **name** only — never a value (`MDL_004`) |
| `rpm` / `tpm` | Configured limits, reviewed against actual demand (`MDL_005`) |
| `fallback_position` | Chain position; 1 is the primary |
| `disabled` + `reason` | When set, the model is routed around (`MDL_003`) |
| `access_grants` | The roles permitted to invoke the model |

### 3.B Calling policy and fallback chain

Resolution order is fixed and never reordered by convenience:

```text
1. registered?     no  -> MDL_001
2. config resolves? no -> MDL_002
3. enabled?        no  -> MDL_003, next chain entry
4. key present?    no  -> MDL_004, halt
5. headroom ok?    no  -> MDL_005, backoff, then next chain entry
6. invoke          transport/provider error -> MDL_E007, retry (template 5), then fallback
```

⚠️ Step 4 halts. A missing key is a provisioning problem, not a routing problem — shifting
load does not fix an unset variable, it just moves the failure.

### 3.C Pipeline and fusion discipline

WFT-001 runs five phases in order: source discovery → extraction → validation →
normalization → persistence. Extraction is rate-limited by template 8; validation is
schema-based (template 1); persistence masks PII (template 9) and indexes the record.
Quarantined records are reported, never dropped silently.

Fusion preserves per-record provenance: source id, retrieval timestamp, transform chain.
A record whose provenance was dropped is quarantined, never published. Where sources
disagree, both values are recorded with the disagreement flagged — picking the first value
silently is a data-integrity defect.

Every dataset leaving this department carries a freshness label stating the as-of time of
its oldest contributing record. A consumer that needs a tighter ceiling requests a refresh
(`CFO_003` from `finance-treasury` is the standing example) rather than trusting a stale
label — the label is the contract, and a violated one is a reporting defect, not a rounding
error.

## 4. Error Codes (Full + Resolution Steps)

Sub-namespace: `MDL_E<NNN>` denotes model-invocation errors raised at call time rather than
at configuration time.

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| MDL_001 | Model not found in registry | A requested model id has no registry entry | 1. Confirm the id spelling 2. Register the model or select a registered alternative 3. Never invoke an unregistered endpoint |
| MDL_002 | Model config file missing | A registry entry's `config_path` does not resolve to a file | 1. Run the registry path check 2. Create the missing config or remove the entry 3. Re-validate all 7 paths before any invocation |
| MDL_003 | Model disabled | The requested model is registered but flagged disabled | 1. Read the disable reason 2. Select the next model in the fallback chain 3. Request re-enablement through `platform-mlops` |
| MDL_004 | API key missing | The environment variable named by `env_var_name` is unset | 1. Report the variable **name** only — never its value 2. Halt the invocation 3. Request provisioning through the secret store |
| MDL_005 | Rate limit exceeded | A model provider returned a rate-limit response | 1. Apply template 8 backoff 2. Shift load to the fallback model 3. Review the configured `rpm`/`tpm` against actual demand |
| MDL_006 | Model config invalid | A config file parsed but violated the template field contract | 1. Diff against `models/api/template/config.json` 2. Add the missing fields 3. Re-validate before use |
| MDL_E007 | Model invocation failed | A call returned a transport or provider error | 1. Retry via template 5 with backoff 2. On exhaustion, move to the fallback model 3. Record the provider error class for trend analysis |

## 5. Integration Points

Detailed in the D2 page §5. Additional protocol notes:

| Counterpart | Protocol |
|---|---|
| `platform-mlops` | Registry health events feed monitoring; re-enablement of a disabled model is requested here, never performed locally |
| `engineering-tooling` | The registry serves agent capabilities; a scaffold declaring a model dependency validates the id at generation time |
| `security-resilience` | Access-control review against the matrix; supply-chain review before a new adapter is adopted |
| `legal-privacy` | PII class and residency questions route here before a pipeline persists |

## 6. Constraints

- ❌ Do not invoke an unregistered endpoint (`MDL_001`)
- ❌ Do not report a key's value — the variable name only (`MDL_004`)
- ❌ Do not call a model flagged disabled; take the next chain entry (`MDL_003`)
- ❌ Do not retry a non-idempotent model call; compensate instead
- ❌ Do not persist raw payloads — mask PII (template 9) at the persistence phase
- ❌ Do not land a breaking schema change without notifying downstream consumers
- ❌ Do not fuse sources without preserving per-record provenance
- ❌ Do not re-enable a disabled model directly — route the request through `platform-mlops`

## 7. Quality Metrics

Full table in the D2 page §7. Measurement notes:

| Metric | How measured |
|---|---|
| Registry resolvability | Path-check pass rate across all registered entries |
| Fallback engagement latency | Primary-failure-to-fallback-served timestamp delta |
| WFT-001 window compliance | Run start-to-persistence delta against the 30-minute window |
| Schema change notification | Breaking changes with a recorded consumer notice ÷ total |
| Provenance retention | Fused records with a complete source chain ÷ total |
| Key exposure count | Secret-pattern hits in logs and reports — target zero |

⚠️ None of these may be measured by self-report. Each has an external timestamp source.

## 8. SOPs / Operational Procedures

### SOP-MDL-01 · Register a model

```text
1. Receive the registration request: id, provider, config path, env var name, rpm/tpm,
   fallback position, access grants.
2. Confirm the id is not already registered; a collision is a registration error, not an update.
3. Diff the config against models/api/template/config.json.
   Contract breach → MDL_006: list the missing fields; return to the requester.
4. Run the registry path check on config_path.
   Unresolvable → MDL_002: create the config or withdraw the entry.
5. Confirm env_var_name is set (name only - never read or log the value).
   Unset → MDL_004: halt; request provisioning through the secret store.
6. Record the entry with a trace ID (template 7, prefix "mdl").
```

### SOP-MDL-02 · Serve a model call through the fallback chain

```text
1. Look up the model id. Absent → MDL_001: confirm spelling, register or select an alternative.
2. Resolve config_path. Absent → MDL_002: run the path check before any invocation.
3. Check the disabled flag. Set → MDL_003: read the reason, take the next chain entry.
4. Check the key variable. Unset → MDL_004: halt - do not shift load.
5. Check rate headroom (template 8). Exhausted → MDL_005: backoff, then shift load.
6. Invoke. Transport or provider error → MDL_E007: retry via template 5 with backoff;
   on exhaustion move to the fallback model and record the provider error class.
7. Record the served call with its chain position and trace ID.
```

### SOP-MDL-03 · Run a data pipeline (WFT-001)

```text
1. Discover sources from the reliability register; freeze the source set for the run.
2. Extract with template 8 rate limiting; stage raw payloads with trace IDs.
3. Validate each payload against its declared schema (template 1).
   Failure → quarantine and report; never drop silently.
4. Normalize: units, timezone (UTC), encoding unified.
5. Persist with PII masked (template 9); index the records.
6. A source failing twice is marked degraded and reported, not retried forever.
```

### SOP-MDL-04 · Land a schema change

```text
1. Diff the proposed schema against the current contract.
2. Classify: additive (non-breaking) or breaking.
3. Additive → land, then notify consumers through operations-coordination.
4. Breaking → notify every downstream consumer first; land only after acknowledgement.
5. Record the change with the consumer list and the notice timestamps.
6. Re-run the structure-vs-disk consistency check after the change lands.
```

### SOP-MDL-05 · Fuse multi-source records

```text
1. Load the source datasets with their provenance metadata.
2. Resolve overlap keys; unresolved keys stay as separate records.
3. Where sources disagree, keep both values and flag the disagreement.
4. Stamp every fused record: source chain, retrieval timestamps, transform chain.
5. Quarantine any record whose provenance was dropped - never publish it.
6. Publish the fused dataset with its provenance summary attached.
```
