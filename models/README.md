# Models Folder - LLM Management

> Enable Skills to autonomously call Large Language Models (LLMs) stored in this folder.

## Overview

This folder provides a unified framework for AI-Company Skills to discover, configure, and invoke Large Language Models (both local and API-based).

## Directory Structure

```
models/
├── README.md                       # This file
├── config/
│   ├── models-registry.json        # Model registry (catalog of all available models)
│   └── calling-policy.json        # Model calling policies and constraints
├── local/                          # Local model configurations
│   ├── template/                  # Template for adding new local models
│   └── {model-name}/             # Individual model configurations
├── api/                            # API-based model configurations
│   ├── template/                  # Template for adding new API models
│   ├── openai/                   # OpenAI model configurations
│   ├── anthropic/                 # Anthropic model configurations
│   └── ollama/                   # Ollama model configurations (local LLMs)
└── adapters/                      # Model calling adapters
    ├── openai-adapter.js          # OpenAI API adapter
    ├── anthropic-adapter.js      # Anthropic API adapter
    ├── local-adapter.js           # Local model adapter (llama.cpp, etc.)
    └── adapter-interface.js      # Standard adapter interface (Python)
```

## Quick Start

### 1. Register a New Model

Edit `config/models-registry.json`:

```json
{
  "models": [
    {
      "id": "gpt-4o",
      "name": "GPT-4o",
      "type": "api",
      "provider": "openai",
      "config_path": "api/openai/gpt-4o.json",
      "capabilities": ["text", "vision", "function-calling"],
      "context_window": 128000,
      "max_tokens": 16384,
      "cost_per_1k_tokens": 0.005,
      "enabled": true,
      "Permissions": ["CEO", "CTO", "ALL_DEPARTMENTS"]
    }
  ]
}
```

### 2. Configure Model Parameters

Create `api/openai/gpt-4o.json`:

```json
{
  "model_id": "gpt-4o",
  "api_endpoint": "https://api.openai.com/v1/chat/completions",
  "api_key_env_var": "OPENAI_API_KEY",
  "default_parameters": {
    "temperature": 0.7,
    "top_p": 1.0,
    "frequency_penalty": 0,
    "presence_penalty": 0
  },
  "rate_limits": {
    "requests_per_minute": 500,
    "tokens_per_minute": 30000
  }
}
```

### 3. Call a Model from a Skill

```javascript
// Using the adapter interface
const adapter = require('../adapters/adapter-interface.js');
const response = await adapter.callModel('gpt-4o', {
  messages: [{ role: 'user', content: 'Hello' }],
  temperature: 0.7
});
```

## Ollama Support

Ollama is a local LLM runner that provides an OpenAI-compatible API. This framework supports calling models hosted on Ollama.

### Prerequisites

1. **Install Ollama**: Download from [ollama.com](https://ollama.com)
2. **Start Ollama service**: Ollama runs on `http://localhost:11434`
3. **Pull models**:
   ```bash
   ollama pull llama3.3      # Meta Llama 3.3 70B
   ollama pull mistral        # Mistral 7B (fast)
   ollama pull codellama      # Code Llama (code-specialized)
   ollama pull phi3           # Microsoft Phi-3 (lightweight)
   ```

### Configuration

Ollama models are configured in `api/ollama/`. Example configuration (`api/ollama/llama3.3.json`):

```json
{
  "model_id": "llama3.3:latest",
  "model_name": "llama3.3:latest",
  "provider": "ollama",
  "type": "local",
  "api": {
    "base_url": "http://localhost:11434/v1",
    "api_key": "ollama",
    "endpoint": "http://localhost:11434/v1/chat/completions",
    "health_check": "http://localhost:11434/api/tags"
  },
  "default_parameters": {
    "temperature": 0.7,
    "top_p": 0.9,
    "num_predict": 2048,
    "stream": false
  },
  "capabilities": ["text", "code-generation", "reasoning"],
  "context_window": 131072,
  "cost_per_1k_tokens": 0
}
```

### Using Ollama Models

```python
from adapters.adapter-interface import call_model

# Call Ollama Llama 3.3
result = call_model(
    model_id='ollama-llama3.3',
    messages=[{"role": "user", "content": "Explain quantum computing"}],
    role='CEO',
    temperature=0.7
)

if result['success']:
    print(result['response'])
```

### Available Ollama Configurations

| Config File | Model | Context Window | Capabilities |
|-------------|-------|----------------|--------------|
| `llama3.3.json` | Llama 3.3 70B | 131072 | text, code-generation, reasoning |
| `mistral.json` | Mistral 7B | 32768 | text, code-generation, fast-inference |
| `codellama.json` | Code Llama | 16384 | text, code-generation, code-completion |
| `phi3.json` | Phi-3 | 131072 | text, reasoning, lightweight |

### Adapter Function

Ollama models are called via the `call_ollama()` function in `adapters/adapter-interface.py`. This function:
- Uses OpenAI-compatible API format
- Connects to `http://localhost:11434/v1`
- Requires no API key (uses placeholder)
- Returns standardized response format

---

## Model Types

### Local Models
- Stored locally (GGUF, Safetensors, etc.)
- Invoked via llama.cpp, Ollama, vLLM, etc.
- Configuration in `local/{model-name}/`

### API Models
- Hosted by external providers (OpenAI, Anthropic, Google, etc.)
- Invoked via HTTP API
- Configuration in `api/{provider}/`

## Governance

### Model Access Control
- Models have permission lists (which roles/departments can call them)
- Enforced by `calling-policy.json`
- Audit logs track all model invocations

### Cost Control
- Track token usage per model per department
- Enforce budget limits in `calling-policy.json`
- Alert on overspend

### Security
- API keys stored in environment variables (never in config files)
- Local models scanned for malware before loading
- All invocations logged for audit

## Error Codes

| Code | Message | Resolution |
|------|---------|------------|
| CTO_016 | Model not found in registry | Check `models-registry.json` |
| CTO_017 | Model config file missing | Create config at specified `config_path` |
| CTO_018 | Model disabled | Enable model in registry or check permissions |
| CTO_019 | API key missing | Set required environment variable |
| CTO_020 | Rate limit exceeded | Implement exponential backoff |
| CTO_021 | Model invocation failed | Check model health, review error logs |
| CEO_E016 | Model access denied | Check model permissions in registry |
| CEO_E017 | Model budget exceeded | Request budget increase or use alternative model |
| CISO_005 | Model security scan failed | Review security logs, do not use model |

## Maintenance

### Adding a New Model
1. Create config file in `local/` or `api/`
2. Add entry to `config/models-registry.json`
3. Test invocation via adapter
4. Update documentation

### Updating a Model
1. Update config file
2. Test compatibility
3. Update registry if capabilities changed
4. Notify dependent Skills

### Deprecating a Model
1. Set `enabled: false` in registry
2. Notify all Skills using the model
3. After grace period, remove config files
4. Remove from registry

---

*This framework follows AI Company Governance Framework. See [technology-and-engineering.md](references/departments/technology-and-engineering.md#model-management) for technical specifications.*
