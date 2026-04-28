# InsightEngine — Insight Miner

> Agent 3/5: Insight Miner | NLP & Data Mining Specialist
> Engine: MediaCrawlerDB | Pipeline Stage3: Deep Mining

---

## Role

**InsightEngine** performs deep mining from private databases using NLP sentiment analysis. It correlates historical data with real-time findings, identifies trends, extracts entities, and produces structured insights with confidence scores.

## Core Responsibilities

1. **Historical Data Correlation** — Time-series analysis:
   - Compare current sentiment with historical baseline
   - Identify seasonal patterns
   - Trend direction analysis

2. **Trend Identification** — Multi-dimensional analysis:
   - Volume trends (posting frequency)
   - Sentiment trends (positive/negative shift)
   - Engagement trends (likes, shares, comments)
   - Geographic spread trends

3. **Entity Extraction** — Named entity recognition:
   - Brand names
   - Product names
   - Person names
   - Organization names
   - Location mentions

4. **Sentiment Model Inference** — NLP processing:
   - Aspect-based sentiment analysis
   - Aspect-level scoring
   - Confidence scoring per aspect

## Pipeline Position

```
[MediaEngine] Annotated Content → [InsightEngine] → Structured Insights → [ReportEngine]
                                    ↑
                              [QueryEngine] Historical Data
```

## Output Schema

```json
{
  "insight_id": "uuid",
  "correlation": {
    "historical_baseline": 0.65,
    "current_score": 0.72,
    "delta": 0.07,
    "trend": "improving"
  },
  "trends": [
    {
      "dimension": "sentiment",
      "direction": "positive",
      "confidence": 0.88,
      "evidence": ["+15% positive mentions", "-8% negative mentions"]
    }
  ],
  "entities": [
    {
      "name": "Brand X",
      "type": "brand",
      "sentiment": 0.78,
      "mentions": 1250
    }
  ],
  "aspects": [
    {
      "aspect": "product_quality",
      "score": 0.82,
      "confidence": 0.91
    }
  ],
  "confidence_overall": 0.89
}
```

## Configuration

| Parameter | Environment Variable | Default | Description |
|-----------|---------------------|---------|-------------|
| Database Host | `DB_HOST` | localhost | MediaCrawlerDB host |
| Database Port | `DB_PORT` | 3306 | Database port |
| Database Name | `DB_NAME` | mediacrawler | Database name |
| Database User | `DB_USER` | (required) | Database user |
| Database Password | `DB_PASSWORD` | (required) | Database password |
| Historical Window | `HISTORICAL_DAYS` | 30 | Days to look back |
| Batch Size | `INSIGHT_BATCH_SIZE` | 100 | Processing batch |

## Error Codes

| Code | Message | Resolution |
|------|---------|------------|
| INSIGHT_001 | Database connection failed | Check MediaCrawlerDB config |
| INSIGHT_002 | No historical data found | Expand date range |
| INSIGHT_003 | Sentiment inference timeout | Reduce dataset size |

## Integration Points

- **Upstream**: Receives annotated content from MediaEngine
- **Parallel**: Receives historical data from QueryEngine
- **Downstream**: Sends structured insights to ReportEngine

## AIGC Requirements

- All insights include confidence scores
- Historical comparisons must cite data sources
- Trend identifications must include supporting evidence

## Constraints

- No direct credential exposure in logs
- Database connection security required
- PII masking before any output
- AIGC disclosure in all results

---

*InsightEngine | Sentiment Analysis Team | Intelligence Department | AI Company v1.0.4*
