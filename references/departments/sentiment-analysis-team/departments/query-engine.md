# QueryEngine — News Searcher

> Agent 1/5: News Searcher | Data Collection Specialist
> Engine: Tavily API | Pipeline Stage 1: Data Collection

---

## Role

**QueryEngine** is the data collection backbone of the Sentiment Analysis Team. It performs broad-spectrum news and social media search using the Tavily API, covering both Chinese and international news sources. It feeds raw data to downstream agents (MediaEngine, InsightEngine) for deeper analysis.

## Core Responsibilities

1. **Multi-Source News Search** — Tavily API with 6 search modes:
   - `tavily_search`: General web search
   - `tavily_news_search`: Dedicated news search (domestic + international)
   - `tavily_extract`: Content extraction from URLs
   - `tavily_map_search`: Geographic-context search
   - `tavily_qna_search`: Question-answering search
   - `tavily_context_search`: Context-aware deep search

2. **Keyword Optimization** — Expands user query into optimized search keywords:
   - Synonym expansion (Chinese + English)
   - Trending term injection
   - Platform-specific keyword adaptation

3. **Search Result Deduplication** — Removes duplicate articles using URL hashing and content similarity scoring

4. **Data Normalization** — Standardizes results into unified format

## Pipeline Position

```
User Query → [QueryEngine] → Raw Data ─┬→ [MediaEngine] (multimodal analysis)
                                       └→ [InsightEngine] (database mining)
```

## Output Schema

```json
{
  "source": "platform_name",
  "url": "canonical_url",
  "title": "article_title",
  "content": "body_text",
  "published_at": "ISO8601_timestamp",
  "author": "author_name",
  "sentiment_raw": null,
  "relevance_score": 0.95
}
```

## Configuration

| Parameter | Environment Variable | Default | Description |
|-----------|---------------------|---------|-------------|
| API Key | `TAVILY_API_KEY` | (required) | Tavily search API key |
| Max Results | `QUERY_MAX_RESULTS` | 20 | Max results per search |
| Search Depth | `SEARCH_DEPTH` | `advanced` | basic/advanced |
| Language | `QUERY_LANGUAGE` | `auto` | auto/zh/en |
| Timeout | `QUERY_TIMEOUT` | 30s | API call timeout |

## Error Codes

| Code | Message | Resolution |
|------|---------|------------|
| QUERY_001 | Search API unavailable | Check TAVILY_API_KEY env var |
| QUERY_002 | No relevant results found | Broaden keywords or date range |
| QUERY_003 | Search rate limit exceeded | Backoff and retry after 60s |

## Integration Points

- **Upstream**: Receives query from orchestrator
- **Downstream**: Sends raw data to MediaEngine and InsightEngine
- **Parallel**: Can run concurrently with initial InsightEngine historical lookup

## AIGC Requirements

- All search summaries must include: "AI-assisted data collection via QueryEngine"
- Raw source URLs preserved for human verification
- No fabrication of search results

## Constraints

- No dynamic code execution (eval, exec)
- No unauthorized network calls
- All API credentials in environment variables
- Rate limiting on all API calls
- PII masking before output

---

*QueryEngine | Sentiment Analysis Team | Intelligence Department | AI Company v1.0.4*
