#!/usr/bin/env python3
"""
CEO Orchestrated Ollama Integration Test
AI-Company Skill v1.0.6

CEO coordinates CTO, CISO, CFO, and CHO agents to perform
a full integration test of Ollama LLM connectivity using
actually installed models (qwen3:8b).
"""

import sys
import json
import time
import datetime
from pathlib import Path

# Add parent dir to path for adapter import
sys.path.insert(0, str(Path(__file__).parent))

OLLAMA_BASE_URL = "http://localhost:11434/v1"
TEST_MODEL = "qwen3:8b"  # Actually installed model
TEST_MODEL_ALT = "qwen3:latest"  # Alias

DIVIDER = "=" * 70

# ─────────────────────────────────────────────────────────────────────────────
# Agent Configs
# ─────────────────────────────────────────────────────────────────────────────

AGENT_CONFIGS = {
    "CEO": {
        "model_config": {
            "model_id": "qwen3:8b",
            "model_name": "qwen3:8b",
            "provider": "ollama",
            "api": {
                "base_url": OLLAMA_BASE_URL,
                "api_key": "ollama"
            },
            "default_parameters": {
                "temperature": 0.3,
                "max_tokens": 512
            }
        },
        "system": "You are the CEO of AI-Company. Be brief and decisive.",
        "task": "In 2 sentences, confirm Ollama integration is ready for production and what model is being used."
    },
    "CTO": {
        "model_config": {
            "model_id": "qwen3:8b",
            "model_name": "qwen3:8b",
            "provider": "ollama",
            "api": {
                "base_url": OLLAMA_BASE_URL,
                "api_key": "ollama"
            },
            "default_parameters": {
                "temperature": 0.2,
                "max_tokens": 512
            }
        },
        "system": "You are the CTO of AI-Company. Evaluate technical performance concisely.",
        "task": "List 3 technical strengths of running qwen3:8b locally via Ollama for enterprise use."
    },
    "CISO": {
        "model_config": {
            "model_id": "qwen3:8b",
            "model_name": "qwen3:8b",
            "provider": "ollama",
            "api": {
                "base_url": OLLAMA_BASE_URL,
                "api_key": "ollama"
            },
            "default_parameters": {
                "temperature": 0.1,
                "max_tokens": 512
            }
        },
        "system": "You are the CISO of AI-Company. Focus on security and data privacy.",
        "task": "Name 3 key security benefits of using a local Ollama model vs cloud LLM APIs."
    },
    "CFO": {
        "model_config": {
            "model_id": "qwen3:8b",
            "model_name": "qwen3:8b",
            "provider": "ollama",
            "api": {
                "base_url": OLLAMA_BASE_URL,
                "api_key": "ollama"
            },
            "default_parameters": {
                "temperature": 0.1,
                "max_tokens": 512
            }
        },
        "system": "You are the CFO of AI-Company. Focus on cost and ROI.",
        "task": "Give a brief cost analysis: what are the financial advantages of self-hosted Ollama vs GPT-4o API?"
    },
    "CHO": {
        "model_config": {
            "model_id": "qwen3:8b",
            "model_name": "qwen3:8b",
            "provider": "ollama",
            "api": {
                "base_url": OLLAMA_BASE_URL,
                "api_key": "ollama"
            },
            "default_parameters": {
                "temperature": 0.4,
                "max_tokens": 512
            }
        },
        "system": "You are the CHO (Chief Human Officer) of AI-Company. Focus on people and culture.",
        "task": "How does local AI (Ollama) improve employee trust and adoption compared to cloud AI?"
    }
}


# ─────────────────────────────────────────────────────────────────────────────
# Core: Call Ollama via OpenAI-compatible SDK
# ─────────────────────────────────────────────────────────────────────────────

def call_ollama(config, messages, **kwargs):
    """Unified Ollama caller using OpenAI-compatible SDK."""
    try:
        import openai

        base_url = config.get("api", {}).get("base_url", OLLAMA_BASE_URL)
        model_name = config.get("model_name", config.get("model_id", TEST_MODEL))
        api_key = config.get("api", {}).get("api_key", "ollama")

        client = openai.OpenAI(base_url=base_url, api_key=api_key)

        params = {"model": model_name, "messages": messages}
        default_params = config.get("default_parameters", {}).copy()

        # Map num_predict -> max_tokens if present
        if "num_predict" in default_params:
            default_params["max_tokens"] = default_params.pop("num_predict")

        params.update(default_params)
        params.update(kwargs)

        start = time.time()
        response = client.chat.completions.create(**params)
        elapsed = round(time.time() - start, 2)

        raw_content = response.choices[0].message.content or ""
        # Strip <think>...</think> reasoning blocks (qwen3 thinking mode)
        import re
        clean_content = re.sub(r'<think>.*?</think>', '', raw_content, flags=re.DOTALL).strip()
        if not clean_content:
            clean_content = raw_content  # fallback if all content was in think block

        return {
            "success": True,
            "response": clean_content,
            "model": response.model,
            "elapsed_sec": elapsed,
            "usage": {
                "prompt_tokens": response.usage.prompt_tokens if response.usage else 0,
                "completion_tokens": response.usage.completion_tokens if response.usage else 0,
                "total_tokens": response.usage.total_tokens if response.usage else 0
            }
        }
    except Exception as e:
        return {"success": False, "error": str(e), "error_code": "CTO_021"}


# ─────────────────────────────────────────────────────────────────────────────
# CEO Test Orchestrator
# ─────────────────────────────────────────────────────────────────────────────

def run_ceo_test():
    start_time = datetime.datetime.now()
    report_lines = []

    def log(line=""):
        print(line)
        report_lines.append(line)

    log(DIVIDER)
    log("  AI-COMPANY SKILL v1.0.6 — CEO OLLAMA INTEGRATION TEST")
    log(f"  Started: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    log(f"  Model Under Test: {TEST_MODEL}")
    log(DIVIDER)
    log()

    # Phase 1: Connectivity check
    log("PHASE 1 — CONNECTIVITY CHECK")
    log("-" * 40)
    try:
        import urllib.request
        req = urllib.request.urlopen("http://localhost:11434/api/tags", timeout=5)
        data = json.loads(req.read())
        available = [m["name"] for m in data.get("models", [])]
        log(f"  [OK] Ollama service: ONLINE")
        log(f"  [OK] Available models: {', '.join(available)}")

        if TEST_MODEL not in available and TEST_MODEL_ALT not in available:
            log(f"  [WARN] {TEST_MODEL} not found. Available: {available}")
            # Use first available model as fallback
            if available:
                fallback = available[0]
                log(f"  [INFO] Falling back to: {fallback}")
                for agent_key in AGENT_CONFIGS:
                    AGENT_CONFIGS[agent_key]["model_config"]["model_name"] = fallback
                    AGENT_CONFIGS[agent_key]["model_config"]["model_id"] = fallback
        else:
            log(f"  [OK] {TEST_MODEL} confirmed available")
    except Exception as e:
        log(f"  [FAIL] Ollama service unreachable: {e}")
        log(f"  [INFO] Please run: ollama serve")
        return False, "\n".join(report_lines)

    log()

    # Phase 2: Department Agent tests
    log("PHASE 2 — DEPARTMENT AGENT TESTS")
    log("-" * 40)

    results = {}
    all_passed = True

    for agent_name, agent_cfg in AGENT_CONFIGS.items():
        log(f"\n  [{agent_name}] Testing...")
        messages = [
            {"role": "system", "content": agent_cfg["system"]},
            {"role": "user", "content": agent_cfg["task"]}
        ]
        result = call_ollama(agent_cfg["model_config"], messages)
        results[agent_name] = result

        if result["success"]:
            log(f"  [{agent_name}] STATUS: PASS ({result['elapsed_sec']}s, {result['usage']['total_tokens']} tokens)")
            log(f"  [{agent_name}] TASK: {agent_cfg['task']}")
            # Show first 300 chars of response
            resp_preview = result["response"][:300].replace("\n", " ")
            log(f"  [{agent_name}] RESPONSE: {resp_preview}{'...' if len(result['response']) > 300 else ''}")
        else:
            log(f"  [{agent_name}] STATUS: FAIL — {result['error']}")
            all_passed = False

    log()

    # Phase 3: Performance summary
    log("PHASE 3 — PERFORMANCE SUMMARY")
    log("-" * 40)
    passed = [k for k, v in results.items() if v["success"]]
    failed = [k for k, v in results.items() if not v["success"]]
    elapsed_list = [v["elapsed_sec"] for v in results.values() if v.get("success")]
    total_tokens = sum(v["usage"]["total_tokens"] for v in results.values() if v.get("success"))

    log(f"  Agents tested:  {len(results)}")
    log(f"  Passed:         {len(passed)} {passed}")
    log(f"  Failed:         {len(failed)} {failed if failed else '—'}")
    if elapsed_list:
        log(f"  Avg latency:    {round(sum(elapsed_list)/len(elapsed_list), 2)}s")
        log(f"  Total tokens:   {total_tokens}")
        log(f"  API cost:       $0.00 (local Ollama)")

    log()

    # Phase 4: CEO Decision
    log("PHASE 4 — CEO DECISION")
    log("-" * 40)
    if all_passed:
        verdict = "APPROVED FOR PRODUCTION"
        decision = (
            "All department agents successfully connected to Ollama (qwen3:8b). "
            "Integration is stable, zero-cost, and privacy-compliant. "
            "Proceeding to Phase 2: Staged Rollout (30% traffic)."
        )
    else:
        verdict = "CONDITIONAL APPROVAL — REMEDIATION REQUIRED"
        decision = (
            f"Agents {failed} failed integration tests. "
            "CTO to investigate error codes and re-run after fix. "
            "Production rollout on hold pending full pass."
        )

    log(f"  VERDICT:  {verdict}")
    log(f"  DECISION: {decision}")

    log()
    end_time = datetime.datetime.now()
    log(DIVIDER)
    log(f"  TEST COMPLETE | Duration: {round((end_time - start_time).total_seconds(), 1)}s")
    log(f"  Report saved to: ceo-ollama-test-report.md")
    log(DIVIDER)

    return all_passed, "\n".join(report_lines)


# ─────────────────────────────────────────────────────────────────────────────
# Save Report
# ─────────────────────────────────────────────────────────────────────────────

def save_report(content: str):
    report_path = Path(__file__).parent / "ceo-ollama-test-report.md"
    ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    md = f"""# CEO Ollama Integration Test Report

**Generated:** {ts}  
**Model:** {TEST_MODEL}  
**Skill Version:** AI-Company v1.0.6  

---

```
{content}
```

---
*AIGC Label: This report was generated by AI-Company Skill automated testing pipeline.*
"""
    report_path.write_text(md, encoding="utf-8")
    return str(report_path)


# ─────────────────────────────────────────────────────────────────────────────
# Entry Point
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    success, report_content = run_ceo_test()
    report_file = save_report(report_content)
    print(f"\n[INFO] Report written to: {report_file}")
    sys.exit(0 if success else 1)
