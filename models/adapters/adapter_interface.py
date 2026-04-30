#!/usr/bin/env python3
"""
Model Adapter Interface - Unified interface for calling LLMs
"""
import json
import os
import sys
from pathlib import Path

MODELS_DIR = Path(__file__).parent.parent
CONFIG_DIR = MODELS_DIR / "config"

def load_registry():
    """Load models registry"""
    registry_path = CONFIG_DIR / "models-registry.json"
    with open(registry_path, 'r') as f:
        return json.load(f)

def load_calling_policy():
    """Load calling policy"""
    policy_path = CONFIG_DIR / "calling-policy.json"
    with open(policy_path, 'r') as f:
        return json.load(f)

def get_model_config(model_id):
    """Get model configuration by ID"""
    registry = load_registry()

    # Find model in registry
    model = None
    for m in registry.get('models', []):
        if m['id'] == model_id:
            model = m
            break

    if not model:
        raise ValueError(f"Model {model_id} not found in registry")

    if not model.get('enabled', False):
        raise PermissionError(f"Model {model_id} is disabled")

    # Load model-specific config
    config_path = MODELS_DIR / model['config_path']
    with open(config_path, 'r') as f:
        model_config = json.load(f)

    return model, model_config

def check_permissions(model, role):
    """Check if role has permission to use model"""
    permissions = model.get('permissions', [])

    # Superuser roles
    policy = load_calling_policy()
    superuser_roles = policy.get('permissions', {}).get('superuser_roles', [])

    if role in superuser_roles:
        return True

    # Check if role in permissions
    if 'ALL_DEPARTMENTS' in permissions:
        return True

    return role in permissions

def call_model(model_id, messages, role="CEO", **kwargs):
    """
    Call a model with unified interface

    Args:
        model_id: Model ID from registry
        messages: List of message dicts [{"role": "user", "content": "..."}]
        role: Role calling the model (for permission check)
        **kwargs: Additional parameters (temperature, max_tokens, etc.)

    Returns:
        dict: {"success": True, "response": "...", "usage": {...}}
    """
    # Get model config
    model, model_config = get_model_config(model_id)

    # Check permissions
    if not check_permissions(model, role):
        return {
            "success": False,
            "error": f"Permission denied: {role} cannot access {model_id}",
            "error_code": "CEO_E016"
        }

    # Route to appropriate adapter
    model_type = model['type']
    provider = model['provider']

    if provider == 'openai':
        return call_openai(model_config, messages, **kwargs)
    elif provider == 'anthropic':
        return call_anthropic(model_config, messages, **kwargs)
    elif provider == 'meta' or provider == 'ollama':
        return call_ollama(model_config, messages, **kwargs)
    else:
        return {
            "success": False,
            "error": f"Unknown provider: {provider}",
            "error_code": "CTO_016"
        }

def call_openai(config, messages, **kwargs):
    """Call OpenAI API"""
    try:
        import openai

        # Get API key from environment
        api_key_env = config.get('authentication', {}).get('env_var_name', 'OPENAI_API_KEY')
        api_key = os.getenv(api_key_env)

        if not api_key:
            return {
                "success": False,
                "error": f"API key not found in environment variable {api_key_env}",
                "error_code": "CTO_019"
            }

        # Initialize client
        client = openai.OpenAI(api_key=api_key)

        # Prepare parameters
        params = {
            "model": config['model_id'],
            "messages": messages,
            **config.get('default_parameters', {}),
            **kwargs
        }

        # Call API
        response = client.chat.completions.create(**params)

        return {
            "success": True,
            "response": response.choices[0].message.content,
            "model": response.model,
            "usage": {
                "prompt_tokens": response.usage.prompt_tokens,
                "completion_tokens": response.usage.completion_tokens,
                "total_tokens": response.usage.total_tokens
            }
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "error_code": "CTO_021"
        }

def call_anthropic(config, messages, **kwargs):
    """Call Anthropic API"""
    try:
        import anthropic

        # Get API key from environment
        api_key_env = config.get('authentication', {}).get('env_var_name', 'ANTHROPIC_API_KEY')
        api_key = os.getenv(api_key_env)

        if not api_key:
            return {
                "success": False,
                "error": f"API key not found in environment variable {api_key_env}",
                "error_code": "CTO_019"
            }

        # Initialize client
        client = anthropic.Anthropic(api_key=api_key)

        # Convert messages format
        # Anthropic uses different format
        anthropic_messages = []
        for msg in messages:
            anthropic_messages.append({
                "role": msg['role'],
                "content": msg['content']
            })

        # Prepare parameters
        params = {
            "model": config['model_id'],
            "messages": anthropic_messages,
            **config.get('default_parameters', {}),
            **kwargs
        }

        # Call API
        response = client.messages.create(**params)

        return {
            "success": True,
            "response": response.content[0].text,
            "model": response.model,
            "usage": {
                "input_tokens": response.usage.input_tokens,
                "output_tokens": response.usage.output_tokens
            }
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "error_code": "CTO_021"
        }

def call_ollama(config, messages, **kwargs):
    """Call Ollama API (OpenAI-compatible format)"""
    try:
        import openai

        # Ollama runs locally, use base URL
        base_url = config.get('api', {}).get('base_url', 'http://localhost:11434/v1')
        model_name = config.get('model_name', config.get('model_id', 'llama3.3'))

        # Ollama doesn't require API key, but openai client needs a value
        api_key = config.get('api', {}).get('api_key', 'ollama')

        # Initialize client with custom base URL
        client = openai.OpenAI(
            base_url=base_url,
            api_key=api_key
        )

        # Prepare parameters
        params = {
            "model": model_name,
            "messages": messages,
        }

        # Handle default_parameters (map Ollama params to OpenAI params)
        default_params = config.get('default_parameters', {})

        # Map num_predict to max_tokens (Ollama uses num_predict, OpenAI uses max_tokens)
        if 'num_predict' in default_params:
            params['max_tokens'] = default_params.pop('num_predict')

        # Add remaining parameters
        for key, value in default_params.items():
            if key not in ['num_predict']:  # Already handled
                params[key] = value

        # Override with kwargs
        params.update(kwargs)

        # Call API
        response = client.chat.completions.create(**params)

        return {
            "success": True,
            "response": response.choices[0].message.content,
            "model": response.model,
            "usage": {
                "prompt_tokens": response.usage.prompt_tokens if response.usage else 0,
                "completion_tokens": response.usage.completion_tokens if response.usage else 0,
                "total_tokens": response.usage.total_tokens if response.usage else 0
            }
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "error_code": "CTO_021"
        }

def call_local(config, messages, **kwargs):
    """Call local model (via llama.cpp server, etc.) - Legacy/Generic format"""
    try:
        import requests

        # Get endpoint from config
        endpoint = config.get('api', {}).get('endpoint', 'http://localhost:8080/completion')
        health_endpoint = config.get('api', {}).get('health_check', 'http://localhost:8080/health')

        # Check health
        try:
            health_resp = requests.get(health_endpoint, timeout=5)
            if health_resp.status_code != 200:
                return {
                    "success": False,
                    "error": f"Local model health check failed: {health_resp.status_code}",
                    "error_code": "CTO_021"
                }
        except:
            return {
                "success": False,
                "error": "Local model is not running",
                "error_code": "CTO_021"
            }

        # Prepare request
        # Convert messages to prompt (model-specific)
        prompt = ""
        for msg in messages:
            role = msg['role']
            content = msg['content']
            if role == 'system':
                prompt += f"System: {content}\n"
            elif role == 'user':
                prompt += f"User: {content}\n"
            elif role == 'assistant':
                prompt += f"Assistant: {content}\n"

        payload = {
            "prompt": prompt,
            "temperature": kwargs.get('temperature', config.get('parameters', {}).get('temperature', 0.7)),
            "max_tokens": kwargs.get('max_tokens', config.get('parameters', {}).get('num_predict', 2048)),
            "stream": False
        }

        # Call API
        response = requests.post(endpoint, json=payload, timeout=60)
        response.raise_for_status()

        result = response.json()

        return {
            "success": True,
            "response": result.get('content', ''),
            "model": config['model_id'],
            "usage": result.get('timings', {})
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "error_code": "CTO_021"
        }

if __name__ == "__main__":
    # CLI interface
    if len(sys.argv) < 3:
        print("Usage: python adapter-interface.py <model_id> <message> [role]")
        sys.exit(1)

    model_id = sys.argv[1]
    message = sys.argv[2]
    role = sys.argv[3] if len(sys.argv) > 3 else "CEO"

    messages = [{"role": "user", "content": message}]
    result = call_model(model_id, messages, role)

    print(json.dumps(result, indent=2))
