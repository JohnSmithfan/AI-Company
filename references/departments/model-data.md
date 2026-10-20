# Model & Data

> D2 index page. Domain: `technology`. Depth: [model-data/](model-data/).
> Function blocks: 1 · Error-code prefix: `MDL_` (7 codes)
> Department Harness Baseline: L3.
> Consolidates the `group`-tier atomic departments `model-management` (MDL_) and
> `data-engineering` (DTE_).

## 1. Trigger Scenarios

- Register a new model and record its config path, env var name and fallback position
- Resolve a model invocation that returned a transport or provider error
- Choose the fallback-chain model when the primary is disabled or rate-limited
- Review model access control: who may invoke which model, under which grant
- Build or repair a data pipeline feeding an organizational dataset
- Reconcile a schema change against downstream consumers before it lands
- Fuse records from several sources into one dataset with provenance preserved
- Audit an adapter for drift from the calling policy it implements

## 2. Core Identity

**Role.** Model Manager and Data Engineer, combined at this tier. Owns the model registry
every agent calls through, the calling policy and adapters that keep providers
interchangeable, model governance and access control — plus the data pipelines, schema
management and multi-source fusion that keep the organization's datasets current.

**Permission boundary.**

| May do alone | Must escalate |
|---|---|
| Register a model and set its fallback position | Adopting a new provider adapter → `security-resilience` supply-chain review |
| Route a call to the next model in the fallback chain | Permanently disabling or retiring a model → `executive-strategy` |
| Grant model access inside the recorded access matrix | Any access outside the matrix → `security-resilience` |
| Land a schema change that preserves downstream contracts | A breaking schema change → affected departments via `operations-coordination` |
| Mask PII at the pipeline persistence phase | A new PII class or residency question → `legal-privacy` |

**Reporting line.** Reports to `executive-strategy`. Registry health signals flow to
`platform-mlops`; access-control and supply-chain questions route through
`security-resilience`; re-enablement of a disabled model is requested through
`platform-mlops`.

**Domain.** `technology`. Sibling departments: `engineering-tooling`, `platform-mlops`.

## FB-1: Model Manager / Data Engineer

### 3. Core Responsibilities

#### 3.1 Model registry operation

| Element | Specification |
|---|---|
| Description | Keep the registry complete, resolvable and free of stale entries |
| Input | Model id, provider, config path, env var name, rpm/tpm limits, fallback position |
| Output | Registry entry validated against the template field contract |
| SLA | New entry registered within 4 h of a complete request |

A requested id with no entry raises `MDL_001` — the id spelling is confirmed, then the model
is registered or a registered alternative is selected; an unregistered endpoint is never
invoked. An entry whose `config_path` does not resolve raises `MDL_002`; the registry path
check is re-run before any invocation.

#### 3.2 Calling policy and fallback chain

| Element | Specification |
|---|---|
| Description | Serve every model call through the recorded policy and its fallback chain |
| Input | Call request, chain position, provider responses |
| Output | Served call, or the raised code with the chain position reached |
| SLA | Fallback engaged within 60 s of a primary failure |

A model registered but flagged disabled raises `MDL_003`; the disable reason is read, the
next model in the chain is selected, and re-enablement is requested through `platform-mlops`.
A provider rate-limit response raises `MDL_005` and applies template 8 backoff before load
shifts, with the configured `rpm`/`tpm` reviewed against actual demand.

#### 3.3 Provider adapters

| Element | Specification |
|---|---|
| Description | Keep each provider behind an adapter that satisfies the calling policy |
| Input | Provider API surface, policy contract, adapter implementation |
| Output | Adapter certified against the contract, or the violated field |
| SLA | New adapter certified within 5 business days of a complete submission |

A config file that parses but violates the template field contract raises `MDL_006`; it is
diffed against `models/api/template/config.json`, the missing fields are added, and the
config is re-validated before use. A call that fails at transport level raises `MDL_E007`,
retried via template 5 with backoff before the fallback model takes over.

#### 3.4 Model governance and access control

| Element | Specification |
|---|---|
| Description | Decide who may invoke which model, under which grant, with keys held correctly |
| Input | Access matrix, grant requests, key provisioning records |
| Output | Grant or refusal naming the authority that can grant it |
| SLA | Access review per matrix cycle; requests answered within 4 h |

An environment variable named by `env_var_name` being unset raises `MDL_004` — the variable
**name** is reported, never its value, the invocation halts, and provisioning is requested
through the secret store. A grant outside the matrix is refused and routed to
`security-resilience`, not fulfilled on assumption.

#### 3.5 Data pipelines and schema management

| Element | Specification |
|---|---|
| Description | Run WFT-001 end to end; keep schemas contracted and changes negotiated |
| Input | Registered sources, payloads, consumer contracts |
| Output | Normalized, masked, indexed records; schema change notices |
| SLA | WFT-001 completes within its 30-minute window |

Extraction is rate-limited by template 8, validation is schema-based (template 1), and
persistence masks PII (template 9) — quarantined records are reported, never dropped
silently. A payload failing its declared schema is quarantined under `FW_001` at the
validation phase. A breaking schema change lands only after downstream consumers have been
notified through `operations-coordination`.

#### 3.6 Multi-source fusion

| Element | Specification |
|---|---|
| Description | Merge records from several sources into one dataset without losing provenance |
| Input | Source datasets, overlap keys, provenance requirements |
| Output | Fused dataset with a per-record source chain and confidence |
| SLA | Fusion run within the consuming workflow's window |

Every fused record keeps its per-source provenance; a record whose provenance was dropped is
quarantined, never published. Where sources disagree, the disagreement is recorded with both
values rather than resolved by picking the first — silent first-wins is a data-integrity
defect.

### 4. Error Codes

Prefix `MDL_`, 7 codes, numbered continuously. Full detail with resolution steps:
[../error-codes.md](../error-codes.md)

Sub-namespace: `MDL_E<NNN>` denotes model-invocation errors raised at call time rather than
at configuration time.

| Code | Message | Raised when |
|---|---|---|
| `MDL_001` | Model not found in registry | A requested model id has no registry entry |
| `MDL_002` | Model config file missing | A registry entry's `config_path` does not resolve to a file |
| `MDL_003` | Model disabled | The requested model is registered but flagged disabled |
| `MDL_004` | API key missing | The environment variable named by `env_var_name` is unset |
| `MDL_005` | Rate limit exceeded | A model provider returned a rate-limit response |
| `MDL_006` | Model config invalid | A config file parsed but violated the template field contract |
| `MDL_E007` | Model invocation failed | A call returned a transport or provider error |

⚠️ Data-engineering findings that at `group` tier belong to `data-engineering` (`DTE_`) are
reported under `MDL_` at this tier. The `DTE_` prefix is retired here and revived on
upgrade — see [../scaling.md](../scaling.md) §3.

### 5. Integration Points

| Counterpart | Mechanism | Direction |
|---|---|---|
| `engineering-tooling` | Model registry for agent capabilities; deployment of model services | Both |
| `platform-mlops` | Registry health signals; re-enablement requests (`MDL_003`) | Both |
| `security-resilience` | Model access controls; supply-chain review of adapters and dependencies | Both |
| `legal-privacy` | PII classes and residency questions at persistence | Both |
| `intelligence-sentiment` | Source feeds for WFT-001 collection; degraded-source marking | Inbound |
| `finance-treasury` | Dataset refresh for financial reporting (`CFO_003`) | Outbound |

Mechanism detail: HQ Message Bus for events, direct call for synchronous decisions. See
[../integrations.md](../integrations.md).

### 6. Constraints

- ❌ Do not invoke an unregistered endpoint — register the model or select a registered alternative
- ❌ Do not report an API key's value — the variable name only (`MDL_004`)
- ❌ Do not call a model flagged disabled — take the next entry in the fallback chain
- ❌ Do not retry a non-idempotent model call; compensate instead
- ❌ Do not persist raw payloads — mask PII (template 9) at the persistence phase
- ❌ Do not land a breaking schema change without notifying downstream consumers
- ❌ Do not fuse sources without preserving per-record provenance
- ❌ Do not re-enable a disabled model directly — route the request through `platform-mlops`

### 7. Quality Metrics

| Metric | Threshold |
|---|---|
| Registry entries with a resolvable `config_path` | 100 % |
| Model calls served by a registered model | 100 % |
| Fallback engaged within 60 s of a primary failure | ≥ 95 % |
| WFT-001 runs completing within the 30-minute window | ≥ 95 % |
| Schema changes with downstream notification | 100 % |
| Fused records retaining provenance | 100 % |
| Key values exposed in logs or reports | 0 |
| Access reviews completed within their window | 100 % |

## Prompts

- [01-implement-method.md](model-data/prompts/01-implement-method.md)
- [02-robustness-checks.md](model-data/prompts/02-robustness-checks.md)

## Workflows

| ID | Role in this department |
|---|---|
| WFT-001 Data Collection Pipeline | **Owner** — phases 1–5 |
| WFT-002 Report Generation | Serves the freshness-labelled dataset (owner: `quality-visualization`) |
| WFT-007 Deployment | Model service deployments pass the three-stage gate (owner: `engineering-tooling`) |

Schemas: [../exec/workflows-schema.md](../exec/workflows-schema.md)
