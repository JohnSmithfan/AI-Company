# Documentation — Sentiment Analysis Team

> Agent specifications, API references, and deployment guides.

---

## Agent Specifications Summary

### QueryEngine

| Property | Value |
|----------|-------|
| Role | News Searcher |
| Role (Chinese) | News Searcher |
| Engine | Tavily API |
| Pipeline Stage | 1 - Data Collection |
| API Endpoint | api.tavily.com |
| Max Results | 20 (default) |
| Timeout | 30s |

### MediaEngine

| Property | Value |
|----------|-------|
| Role | Multimodal Analyst |
| Role (Chinese) | Multimodal Analyst |
| Engine | Bocha API |
| Pipeline Stage | 2 - Content Analysis |
| API Endpoint | api.bocha.com |
| Supported Modalities | text, image, video |
| Crisis Detection | Yes |

### InsightEngine

| Property | Value |
|----------|-------|
| Role | Insight Miner |
| Role (Chinese) | Insight Miner |
| Engine | MediaCrawlerDB |
| Pipeline Stage | 3 - Deep Mining |
| Database | MySQL (MediaCrawlerDB) |
| Historical Window | 30 days (default) |
| Entity Types | brand, product, person, org, location |

### ReportEngine

| Property | Value |
|----------|-------|
| Role | Report Generator |
| Role (Chinese) | Report Generator |
| Engine | LLM Templates |
| Pipeline Stage | 4 - Output |
| Output Formats | HTML, Markdown, JSON |
| LLM Model | qwen-plus (default) |
| AIGC Labeling | Mandatory |

### ForumEngine

| Property | Value |
|----------|-------|
| Role | Forum Moderator |
| Role (Chinese) | Forum Moderator |
| Engine | Qwen3-235B |
| Pipeline Stage | 5 - Validation |
| Discussion Rounds | 3 (default) |
| Participants | 4 (Bullish, Bearish, Neutral, Contrarian) |
| Moderator | Qwen3-235B |

---

## API Reference

### Tavily API (QueryEngine)

```
Endpoint: https://api.tavily.com/search
Method: POST
Headers:
  Content-Type: application/json
  X-API-Key: ${TAVILY_API_KEY}

Request Body:
  {
    "query": "search keyword",
    "search_depth": "advanced",
    "max_results": 20,
    "include_domains": [],
    "exclude_domains": []
  }

Response:
  {
    "results": [
      {
        "title": "...",
        "url": "...",
        "content": "...",
        "score": 0.95
      }
    ]
  }
```

### Bocha API (MediaEngine)

```
Endpoint: https://api.bocha.com/v1/analyze
Method: POST
Headers:
  Content-Type: application/json
  Authorization: Bearer ${BOCHA_API_KEY}

Request Body:
  {
    "content": "text/image/video url",
    "modality": "text|image|video",
    "analysis_depth": "standard",
    "detect_crisis": true
  }

Response:
  {
    "sentiment": {"label": "positive", "score": 0.85},
    "crisis_indicators": {"detected": false},
    "confidence": 0.92
  }
```

### MediaCrawlerDB (InsightEngine)

```
Connection Config:
  Host: ${DB_HOST}
  Port: ${DB_PORT}
  Database: ${DB_NAME}
  User: ${DB_USER}
  Password: ${DB_PASSWORD}

Query Example:
  SELECT entity_name, COUNT(*) as mentions, AVG(sentiment_score) as avg_sentiment
  FROM sentiment_data
  WHERE date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
  GROUP BY entity_name
  ORDER BY mentions DESC
  LIMIT 100;
```

---

## Deployment Guide

### Prerequisites

1. API Keys:
   - `TAVILY_API_KEY` - Tavily search API
   - `BOCHA_API_KEY` - Bocha multimodal API
   - `REPORT_API_KEY` - LLM API for report generation
   - `FORUM_API_KEY` - Qwen3-235B API for forum moderation

2. Database:
   - MySQL 8.0+ instance
   - Database: `mediacrawler`
   - User with read/write permissions

3. Environment Variables:
   ```
   cp .env.example .env
   # Edit .env with your actual API keys and DB config
   ```

### Deploy to ClawHub

```bash
# 1. Validate skill schema
clawhub validate --skill-dir ./

# 2. Run quality gates (G0-G7)
clawhub test --skill-dir ./

# 3. Package skill
clawhub package --skill-dir ./ --output ai-company-sentiment.zip

# 4. Upload to ClawHub
clawhub publish --file ai-company-sentiment.zip
```

### Integration with AI Company

Add to `SKILL.md` triggers:
```yaml
triggers:
  - sentiment analysis
  - public opinion monitoring
  - 舆情分析
  - sentiment trend report
```

---

*Documentation | Sentiment Analysis Team | Intelligence Department*
