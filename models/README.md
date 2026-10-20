# Model Management

> Owning department: `model-data` (prefix `MDL_`). Policy owner: `platform-mlops`.
> Error codes: [../references/error-codes.md](../references/error-codes.md) ·
> Calling policy: [config/calling-policy.json](config/calling-policy.json)

Model registry, calling policy and a single unified adapter. Seven models are registered across
three providers; five form the fallback chain.

## File Inventory

This directory contains exactly **13 files**. There is **one** adapter, not several.

```text
models/
├── README.md                              this file
├── config/
│   ├── models-registry.json               7 model entries + fallback chain
│   └── calling-policy.json                cost, rate limits, permissions, audit
├── adapters/
│   └── adapter_interface.py               ★ the only adapter
├── api/
│   ├── template/config.json               field contract for API models
│   ├── openai/gpt-4o.json
│   ├── anthropic/claude-3-5-sonnet.json
│   └── ollama/
│       ├── llama3.3.json
│       ├── mistral.json
│       ├── codellama.json
│       └── phi3.json
└── local/
    ├── template/config.json               field contract for local models
    └── llama-3.3-70b/config.json
```

⚠️ The adapter filename uses an **underscore** (`adapter_interface.py`) so it is importable as a
Python module. A hyphenated variant cannot be imported at all — a predecessor package shipped both
spellings with different contents, and only one of them could ever be loaded.

## Registry

`config/models-registry.json` declares seven models. Each entry's `config_path` is resolved
relative to `models/`:

```python
MODELS_DIR = Path(__file__).parent.parent     # models/
full_path  = MODELS_DIR / entry["config_path"]
```

| id | provider | type | tier | config_path |
|---|---|---|---|---|
| `gpt-4o` | openai | api | primary | `api/openai/gpt-4o.json` |
| `claude-3-5-sonnet` | anthropic | api | primary | `api/anthropic/claude-3-5-sonnet.json` |
| `ollama-llama3.3` | ollama | local | fallback | `api/ollama/llama3.3.json` |
| `ollama-mistral` | ollama | local | fallback | `api/ollama/mistral.json` |
| `ollama-codellama` | ollama | local | specialized | `api/ollama/codellama.json` |
| `ollama-phi3` | ollama | local | lightweight | `api/ollama/phi3.json` |
| `llama-3.3-70b` | local | local | fallback | `local/llama-3.3-70b/config.json` |

**Fallback chain** (5 entries): `gpt-4o` → `claude-3-5-sonnet` → `ollama-llama3.3` →
`ollama-mistral` → `llama-3.3-70b`.
`ollama-codellama` and `ollama-phi3` are not in the chain — they are selected explicitly for code
and lightweight work respectively.

### Path integrity is a hard requirement

⚠️ **Every `config_path` must resolve to a real file.** A single missing file does not degrade
gracefully — it breaks the whole chain, because the adapter aborts the fallback walk on a registry
defect rather than masking it (`MDL_002`). A predecessor package shipped exactly this: one of seven
paths pointed at a nonexistent file, and the fallback chain was dead on arrival.

Verify after any change:

```powershell
python models/adapters/adapter_interface.py
# registry models : 7
# config paths ok : 7/7
# OK
```

Or in PowerShell:

```powershell
$j = Get-Content models\config\models-registry.json -Raw | ConvertFrom-Json
foreach ($m in $j.models) {
  "{0} : {1}" -f $m.config_path, (Test-Path (Join-Path 'models' $m.config_path))
}
```

## Config Field Contract

Every model config carries **all nine** fields declared by `api/template/config.json`. A config
missing any of them raises `MDL_006`.

| Field | Type | Rule |
|---|---|---|
| `id` | string | Must equal the registry entry's id |
| `provider` | string | `openai` \| `anthropic` \| `ollama` \| `local` |
| `type` | string | `api` \| `local` |
| `endpoint` | string | Declared explicitly — never inferred from a default |
| `env_var_name` | string | **Name** of the environment variable holding the key. Empty for no-auth local engines |
| `context_window` | int | Tokens |
| `max_output_tokens` | int | Tokens |
| `pii_filtering` | bool | Always `true` in this package |
| `rate_limits` | object | `rpm`, `tpm`, `daily` |

`local/template/config.json` adds a `runtime` block (`engine`, `model_path`, `gpu_layers`,
`requires_auth`) for engines that need it.

⚠️ A template that declares fewer fields than the real configs is worse than no template — it
invites authors to omit fields the runtime expects.

## Credentials

**No credential value appears anywhere in this directory.** Configs declare `env_var_name`; the
adapter reads the value with `os.getenv` at call time.

| Model class | `env_var_name` | Runtime behaviour |
|---|---|---|
| `gpt-4o` | `OPENAI_API_KEY` | Missing → `MDL_004`, reporting the variable **name** only |
| `claude-3-5-sonnet` | `ANTHROPIC_API_KEY` | Same |
| ollama models | *(empty)* | No authentication; adapter passes the conventional local placeholder |
| `llama-3.3-70b` | *(empty)* | Same |

The literal string `ollama` used for local engines is a protocol placeholder required by the
Ollama client library, **not a credential**. It grants no access to anything.

## Adapter Interface

`adapters/adapter_interface.py` — standard library only, Python 3.9+, importable offline.

| Function | Purpose | Raises |
|---|---|---|
| `load_registry()` | Load and structurally validate the registry | `MDL_002`, `MDL_006` |
| `load_policy()` | Load the calling policy | `MDL_006` |
| `resolve_model(registry, id)` | Find a registry entry | `MDL_001` |
| `load_model_config(entry)` | Resolve path, check enabled, validate fields | `MDL_002`, `MDL_003`, `MDL_006` |
| `resolve_api_key(config)` | Read the key from the environment by name | `MDL_004` |
| `_apply_rate_limit(policy, id, limiter)` | Apply the injected limiter (template 8) with configured limits | `MDL_005` |
| `call_model(id, messages, …)` | Full path: resolve → validate → auth → limit → call | any of the above, `MDL_E007` |
| `call_with_fallback(messages, …)` | Walk the chain until one model succeeds | `MDL_E007` on exhaustion |
| `validate_registry_paths()` | Existence-check every `config_path` | — |

### Transport is a seam

The shipped `_default_transport` performs **no network I/O** — it returns a structured stub marked
`"stub": true`. This is deliberate:

| Benefit | Detail |
|---|---|
| Offline testability | The suite imports and exercises the adapter with no connectivity |
| Safety | No accidental outbound call carrying data during a test run |
| Separation of concerns | What is under test is resolution, validation, key handling and limiting — not HTTP |

A deployment injects a real transport via the `transport=` parameter. The validation logic is
unchanged either way.

### Fallback semantics

| Failure class | Codes | Chain behaviour |
|---|---|---|
| Transient | `MDL_005`, `MDL_E007` | Advance to the next model |
| Registry / config defect | `MDL_002`, `MDL_006` | **Abort immediately** |
| Disabled model | `MDL_003` | Skip |
| Missing key | `MDL_004` | Advance (a local model may still succeed) |

⚠️ Aborting on a registry defect is intentional. Falling through would hide a broken registry
behind a successful call to some other model, and the defect would surface much later in a
different context.

## Calling Policy

`config/calling-policy.json` covers six areas: cost control, rate limits, permissions, security,
fallback, audit.

| Area | Key settings |
|---|---|
| Cost | Daily / monthly / per-call ceilings; breach actions `degrade-to-local` and `halt-and-notify` |
| Rate limits | Per-model `rpm` / `tpm` / `daily`, enforced through template 8 |
| Permissions | Department → model access matrix; `*` means any department |
| Security | PII filtering on, masking via template 9, sanitization via template 2, validation via template 1 |
| Fallback | The 5-model chain and its trigger conditions |
| Audit | Logged fields exclude prompt and completion content by default |

⚠️ **All numeric values in the policy are documented defaults, not measured figures.** The file
carries `"values_are_examples": true`. Derive real ceilings from observed unit economics through
`procurement-billing` and record the basis for any change.

Model output is **untrusted text**: validate before use, never evaluate it.

## Constraints

- ❌ Do not add a second adapter file
- ❌ Do not write a credential value into any config — only the variable name
- ❌ Do not register a model whose `config_path` does not resolve
- ❌ Do not let the fallback chain paper over a registry defect
- ❌ Do not perform real network I/O in the reference transport
- ❌ Do not log prompt or completion content by default
- ❌ Do not treat the policy's example numbers as production limits
