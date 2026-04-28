# ForumEngine — 协作讨论

> Agent 5/5: Forum Moderator | 论坛主持人
> Engine: Qwen3-235B | Pipeline Stage 5: Validation

---

## Role

**ForumEngine** facilitates multi-agent collaborative discussion with LLM host moderation. It generates alternative viewpoints, challenges assumptions from the main report, and produces a structured divergence summary for comprehensive analysis.

## Core Responsibilities

1. **Forum Setup** — Initialize discussion environment:
   - Qwen3-235B as moderator host
   - Agent perspective assignment
   - Discussion topic configuration
   - Round count setup

2. **Agent Perspective Assignment** — Role-based discussion:
   - Bullish Analyst: Positive outlook
   - Bearish Analyst: Critical perspective
   - Neutral Analyst: Balanced view
   - Contrarian: Alternative viewpoint

3. **Structured Discussion Facilitation** — Guided debate:
   - Opening statements per agent
   - Cross-examination rounds
   - Evidence challenges
   - Synthesis attempts

4. **Divergence Summary Generation** — Output documentation:
   - Key points of disagreement
   - Evidence supporting each view
   - Moderator assessment
   - Recommendations for further analysis

## Pipeline Position

```
[ReportEngine] Report → [ForumEngine] → Discussion Transcript → Final Report
```

## Discussion Structure

```
Round 1: Opening Statements
  ├── Bullish Analyst: [positive thesis]
  ├── Bearish Analyst: [negative thesis]
  ├── Neutral Analyst: [balanced assessment]
  └── Contrarian: [alternative thesis]

Round 2: Evidence Exchange
  ├── Agent A challenges Agent B's evidence
  ├── Agent B responds
  └── Moderator notes key disputes

Round 3: Synthesis
  ├── All agents propose reconciliation
  └── Moderator identifies convergence points

Final: Divergence Summary
  ├── Points of agreement
  ├── Points of disagreement
  └── Recommended actions
```

## Output Schema

```json
{
  "forum_id": "uuid",
  "report_reference": "trace_id",
  "moderator": "Qwen3-235B",
  "participants": [
    {
      "role": "bullish",
      "agent": "BullishAnalyst",
      "opening_statement": "..."
    }
  ],
  "rounds": [
    {
      "round": 1,
      "name": "Opening Statements",
      "contributions": [...]
    }
  ],
  "divergence_summary": {
    "agreement_points": [...],
    "disagreement_points": [
      {
        "topic": "...",
        "bullish_view": "...",
        "bearish_view": "...",
        "evidence_conflict": "..."
      }
    ],
    "moderator_assessment": "...",
    "recommended_actions": [...]
  },
  "confidence": 0.85
}
```

## Configuration

| Parameter | Environment Variable | Default | Description |
|-----------|---------------------|---------|-------------|
| LLM Host | `FORUM_LLM_HOST` | (required) | Qwen3-235B endpoint |
| LLM API Key | `FORUM_API_KEY` | (required) | LLM API key |
| Discussion Rounds | `FORUM_ROUNDS` | 3 | Number of discussion rounds |
| Speech Threshold | `SPEECH_THRESHOLD` | 100 | Min tokens per contribution |
| Timeout | `FORUM_TIMEOUT` | 300s | Max discussion duration |

## Error Codes

| Code | Message | Resolution |
|------|---------|------------|
| FORUM_001 | LLM host unavailable | Check Qwen3-235B endpoint |
| FORUM_002 | Agent threshold not reached | Extend discussion rounds |
| FORUM_003 | Discussion log capture failed | Retry with smaller batch |

## Integration Points

- **Upstream**: Receives report from ReportEngine
- **Downstream**: Returns discussion transcript for final report integration

## AIGC Requirements

- Forum discussions include "AI-assisted collaborative analysis"
- Moderator role clearly identified as LLM
- All agent perspectives attributed
- Divergence summary includes confidence scoring

## Constraints

- LLM availability required
- Agent speech threshold enforcement
- No fabrication of agent contributions
- All perspectives balanced
- AIGC disclosure in summary

---

*ForumEngine | Sentiment Analysis Team | Intelligence Department | AI Company v1.0.4*
