#!/usr/bin/env python3
"""
Test script for Ollama adapter
Tests connection to Ollama and model invocation
"""

import sys
import os

# Add models/adapters to path
MODELS_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(MODELS_DIR, 'adapters'))

from adapter_interface import call_model, load_registry

def test_ollama_connection():
    """Test if Ollama is running"""
    import requests

    print("Testing Ollama connection...")
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json().get('models', [])
            print(f"✓ Ollama is running")
            print(f"  Available models: {[m.get('name') for m in models]}")
            return True
        else:
            print(f"✗ Ollama health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Ollama is not running: {e}")
        print("  Please start Ollama with: ollama serve")
        return False

def test_call_ollama_model(model_id):
    """Test calling an Ollama model"""
    print(f"\nTesting model: {model_id}")

    try:
        messages = [{"role": "user", "content": "Say 'test passed' in Chinese"}]

        result = call_model(
            model_id=model_id,
            messages=messages,
            role="CEO",
            temperature=0.7
        )

        if result.get('success'):
            print(f"✓ Model call successful")
            print(f"  Response: {result.get('response')[:100]}...")
            print(f"  Model: {result.get('model')}")
            print(f"  Usage: {result.get('usage')}")
            return True
        else:
            print(f"✗ Model call failed: {result.get('error')}")
            print(f"  Error code: {result.get('error_code')}")
            return False

    except Exception as e:
        print(f"✗ Exception: {e}")
        return False

def main():
    print("=" * 60)
    print("Ollama Adapter Test")
    print("=" * 60)

    # Test 1: Check Ollama connection
    if not test_ollama_connection():
        print("\n⚠ Ollama is not running. Please start Ollama first.")
        print("  Command: ollama serve")
        sys.exit(1)

    # Test 2: Load registry and test Ollama models
    print("\nLoading model registry...")
    registry = load_registry()

    ollama_models = [
        m for m in registry.get('models', [])
        if m.get('provider') == 'ollama' and m.get('enabled')
    ]

    print(f"Found {len(ollama_models)} enabled Ollama model(s)")

    # Test 3: Test each Ollama model
    results = []
    for model in ollama_models:
        model_id = model.get('id')
        result = test_call_ollama_model(model_id)
        results.append((model_id, result))

    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)

    for model_id, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{status}: {model_id}")

    # Exit code
    all_passed = all(r[1] for r in results)
    sys.exit(0 if all_passed else 1)

if __name__ == "__main__":
    main()
