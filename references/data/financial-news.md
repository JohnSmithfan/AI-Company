# Data Integration Reference

This document provides comprehensive technical specifications for data integration within the AI-Company unified skill framework. It covers financial data retrieval, news and intelligence gathering, information services integration, multi-source data fusion, and standardized data schemas that ensure consistency across all data operations.

The specifications outlined here are designed to be implementation-agnostic while providing sufficient detail for developers to build robust data integration pipelines. All templates and examples are designed to be VirusTotal-compliant, avoiding dynamic code execution patterns that could trigger security scanning systems.

---

## 1. Financial Data Integration

Financial data forms the backbone of many analytical workflows within the AI-Company framework. This section details the patterns, schemas, and caching strategies required to effectively integrate stock quotes, exchange-traded funds, futures contracts, earnings data, and macroeconomic indicators into a unified data pipeline.

### 1.1 Stock Quotes and Market Data

Stock quote data represents real-time or delayed price information for publicly traded securities. The integration pattern for stock quotes follows a RESTful API architecture that supports both individual security queries and batch retrieval for multiple securities.

#### API Patterns for Stock Data

The primary endpoint pattern for stock quote retrieval follows a consistent structure across most financial data providers:

```
GET /api/v1/quote/{exchange}:{symbol}
GET /api/v1/quotes/batch?symbols={exchange}:{symbol1},{exchange}:{symbol2}
GET /api/v1/historical/{exchange}:{symbol}?period={period}&interval={interval}
```

The REST pattern requires three key parameters: the exchange code identifying the trading venue, the security symbol as listed on that exchange, and optional filters for time range and data granularity. The exchange:symbol format ensures uniqueness across global markets where the same ticker symbol might reference different securities on different exchanges.

Authentication for financial data APIs typically employs API key-based authentication passed via the Authorization header:

```
<!-- TEMPLATE ONLY: {REDACTED} placeholders below — never substitute real credentials -->
Authorization: Bearer {REDACTED}
X-API-Key: {REDACTED}
```

Rate limiting for stock data APIs generally allows between 100 and 1000 requests per minute depending on the subscription tier. Implementations should track request counts and implement exponential backoff when encountering rate limit responses (HTTP 429).

#### Stock Data Schema

The standard schema for stock quote data includes the following fields:

```json
{
  "symbol": "AAPL",
  "exchange": "NASDAQ",
  "exchange_code": "XNAS",
  "name": "Apple Inc.",
  "timestamp": "2026-04-27T15:30:00.000Z",
  "price": 189.45,
  "open": 188.20,
  "high": 190.15,
  "low": 187.80,
  "close": 189.45,
  "previous_close": 188.90,
  "volume": 52341000,
  "market_cap": 2950000000000,
  "pe_ratio": 28.5,
  "dividend_yield": 0.52,
  "52_week_high": 198.23,
  "52_week_low": 164.08,
  "bid": 189.44,
  "ask": 189.46,
  "bid_size": 100,
  "ask_size": 200,
  "data_source": "primary_exchange",
  "data_quality_score": 0.98
}
```

The timestamp field follows ISO-8601 format with UTC timezone designation. Prices are represented as decimal numbers with precision appropriate to the security's price category. High-precision securities like penny stocks may include additional decimal places while large-cap indices typically round to two decimal places.

Historical daily data follows a similar schema but includes additional fields for adjusted prices that account for splits and dividends:

```json
{
  "symbol": "AAPL",
  "exchange": "NASDAQ",
  "date": "2026-04-25",
  "open": 188.20,
  "high": 190.15,
  "low": 187.80,
  "close": 189.45,
  "adjusted_close": 189.45,
  "volume": 52341000,
  "turnover": 9876543210,
  "change": 0.55,
  "change_percent": 0.29
}
```

#### Caching Strategies for Stock Data

Stock data caching requires careful consideration of data freshness requirements versus API rate limits. The recommended caching strategy employs a tiered approach with different TTL (time-to-live) values based on data type.

Real-time quote data should use aggressive caching with short TTL values, typically 15 to 60 seconds for non-professional data feeds. Cache entries should include the retrieval timestamp and be invalidated when the market is closed if the cached data exceeds the trading session's closing time.

Intraday data with minute-level granularity should cache for 5 to 15 minutes, depending on the volatility of the security. High-volatility securities like those involved in earnings announcements or significant news events may require shorter cache durations.

End-of-day historical data can be cached for extended periods, with TTL values of 24 hours for the most recent trading day and indefinite caching for historical data that will not change. Once a trading day closes and the data is confirmed final, that day's data becomes immutable and can be cached permanently.

The cache key structure should follow a consistent pattern:

```
stock:quote:{exchange}:{symbol}:{timestamp_bucket}
stock:history:{exchange}:{symbol}:{date_range}
stock:minute:{exchange}:{symbol}:{timestamp}
```

### 1.2 Exchange-Traded Funds (ETF)

Exchange-traded funds represent baskets of securities that trade like individual stocks. ETF data integration presents unique challenges due to the dual-layer structure of ETF pricing: the market price at which shares trade and the net asset value (NAV) that represents the underlying holdings' worth.

#### ETF-Specific API Patterns

ETF data retrieval typically extends standard stock APIs with additional endpoints:

```
GET /api/v1/etf/{exchange}:{symbol}
GET /api/v1/etf/{exchange}:{symbol}/holdings
GET /api/v1/etf/{exchange}:{symbol}/nav
GET /api/v1/etf/{exchange}:{symbol}/tracking
```

The holdings endpoint returns the constituent securities that make up the ETF, which is essential for understanding exposure and calculating theoretical NAV. The tracking endpoint provides performance comparison against benchmark indices.

#### ETF Data Schema

```json
{
  "symbol": "SPY",
  "exchange": "NYSE",
  "exchange_code": "XNYS",
  "name": "SPDR S&P 500 ETF Trust",
  "timestamp": "2026-04-27T15:30:00.000Z",
  "price": 502.35,
  "nav": 501.98,
  "premium_discount": 0.07,
  "premium_discount_percent": 0.014,
  "bid": 502.34,
  "ask": 502.36,
  "volume": 45231000,
  "avg_volume_30d": 52100000,
  "total_assets": 425000000000,
  "nav_per_share": 501.98,
  "dividend_yield": 1.35,
  "expense_ratio": 0.0945,
  "tracking_index": "SPX",
  "tracking_index_name": "S&P 500 Index",
  "tracking_error": 0.02,
  "data_source": "index_provider",
  "data_quality_score": 0.99
}
```

The premium/discount field indicates how the market price compares to the NAV, which is critical for understanding whether an ETF is trading at a premium or discount to its intrinsic value. Large premiums or discounts can indicate market stress or liquidity issues.

### 1.3 Futures Contracts

Futures data integration requires special handling due to the continuous nature of futures pricing across contract months and the roll mechanics required to maintain continuous contract series.

#### Futures API Patterns

```
GET /api/v1/futures/{exchange}:{symbol}
GET /api/v1/futures/{exchange}:{symbol}/contract/{month_code}
GET /api/v1/futures/continuous/{exchange}:{symbol}
GET /api/v1/futures/{exchange}:{symbol}/term_structure
```

The continuous endpoint provides adjusted data that stitches together individual contract months into a continuous series, handling the price adjustments required during contract rolls. The term structure endpoint returns the entire forward curve across available contract months.

#### Futures Data Schema

```json
{
  "symbol": "CL",
  "exchange": "NYMEX",
  "exchange_code": "XNYM",
  "name": "Crude Oil WTI",
  "contract_month": "202606",
  "timestamp": "2026-04-27T15:30:00.000Z",
  "price": 78.45,
  "open": 77.80,
  "high": 79.20,
  "low": 77.50,
  "close": 78.45,
  "settlement": 78.42,
  "volume": 245000,
  "open_interest": 1850000,
  "last_trading_day": "2026-05-19",
  "delivery_date": "2026-05-31",
  "contract_size": 1000,
  "price_increment": 0.01,
  "currency": "USD",
  "data_source": "exchange",
  "data_quality_score": 0.99
}
```

Continuous futures data requires additional fields to handle the roll adjustment:

```json
{
  "symbol": "CL",
  "contract_month": "continuous",
  "timestamp": "2026-04-27T15:30:00.000Z",
  "price": 78.35,
  "source_contract": "CL202606",
  "target_contract": "CL202607",
  "roll_date": "2026-04-25",
  "roll_adjustment": 0.10,
  "roll_complete": true
}
```

### 1.4 Earnings and Financial Statements

Corporate earnings data includes income statements, balance sheets, and cash flow statements that provide fundamental analysis inputs for equity valuation.

#### Earnings API Patterns

```
GET /api/v1/earnings/{exchange}:{symbol}/calendar
GET /api/v1/financials/{exchange}:{symbol}/income
GET /api/v1/financials/{exchange}:{symbol}/balance
GET /api/v1/financials/{exchange}:{symbol}/cashflow
```

#### Earnings Calendar Schema

```json
{
  "symbol": "AAPL",
  "exchange": "NASDAQ",
  "company_name": "Apple Inc.",
  "fiscal_period": "Q2 2026",
  "fiscal_quarter": 2,
  "fiscal_year": 2026,
  "report_date": "2026-04-28",
  "report_time": "after_market",
  "estimate_eps": 2.45,
  "actual_eps": null,
  "estimate_revenue": 95000000000,
  "actual_revenue": null,
  "conference_call_date": "2026-04-28",
  "conference_call_time": "17:00:00-05:00",
  "data_source": "company_filing",
  "data_quality_score": 0.95
}
```

#### Income Statement Schema

```json
{
  "symbol": "AAPL",
  "company_name": "Apple Inc.",
  "fiscal_period": "Q1 2026",
  "fiscal_quarter": 1,
  "fiscal_year": 2026,
  "currency": "USD",
  "report_date": "2026-01-28",
  "items": {
    "revenue": 124300000000,
    "cost_of_revenue": 73900000000,
    "gross_profit": 50400000000,
    "operating_expenses": {
      "research_and_development": 7800000000,
      "selling_general_admin": 6200000000,
      "total_operating_expenses": 14000000000
    },
    "operating_income": 36400000000,
    "interest_expense": 650000000,
    "other_income_expense": 420000000,
    "income_before_tax": 36220000000,
    "income_tax_expense": 5620000000,
    "net_income": 30600000000,
    "ebitda": 41200000000,
    "eps_basic": 1.95,
    "eps_diluted": 1.93,
    "weighted_avg_shares_basic": 15200000000,
    "weighted_avg_shares_diluted": 15800000000
  },
  "data_source": "sec_filing",
  "data_quality_score": 0.98
}
```

### 1.5 Macroeconomic Indicators

Macroeconomic data integration covers indicators such as GDP, inflation rates, employment figures, and central bank policy decisions that influence market conditions.

#### Macro API Patterns

```
GET /api/v1/macro/{indicator_code}
GET /api/v1/macro/{indicator_code}?country={country_code}&period={range}
GET /api/v1/macro/indicators/calendar
```

#### GDP Data Schema

```json
{
  "indicator": "GDP",
  "indicator_name": "Gross Domestic Product",
  "country": "USA",
  "country_name": "United States",
  "timestamp": "2026-04-27T08:00:00.000Z",
  "period": "2025Q4",
  "period_type": "quarterly",
  "value": 28500000000000,
  "value_raw": 28.5,
  "value_unit": "trillion",
  "currency": "USD",
  "growth_rate": 2.4,
  "growth_rate_yoy": 2.4,
  "growth_rate_qoq": 0.6,
  "previous_value": 28320000000000,
  "release_date": "2026-01-30",
  "next_release_date": "2026-04-30",
  "data_source": "bea",
  "data_quality_score": 0.99
}
```

#### Inflation (CPI) Schema

```json
{
  "indicator": "CPI",
  "indicator_name": "Consumer Price Index",
  "country": "USA",
  "country_name": "United States",
  "timestamp": "2026-04-27T08:00:00.000Z",
  "period": "2026-03",
  "period_type": "monthly",
  "value": 315.5,
  "previous_value": 314.2,
  "change": 1.3,
  "change_percent": 0.41,
  "yoy_change_percent": 2.8,
  "core_change_percent": 3.1,
  "category": "all_items",
  "release_date": "2026-04-10",
  "next_release_date": "2026-05-12",
  "data_source": "bls",
  "data_quality_score": 0.99
}
```

---

## 2. News and Intelligence Integration

News and intelligence data provides context for market movements, sentiment analysis for securities, and early warning indicators for significant market events. This section details the patterns for integrating real-time news feeds, social media sentiment, and intelligence data sources into a cohesive information pipeline.

### 2.1 Real-Time News Feeds

Real-time news integration requires handling high-velocity data streams with appropriate filtering, deduplication, and enrichment pipelines.

#### News API Patterns

```
GET /api/v1/news/latest?limit={count}
GET /api/v1/news/search?q={query}&from={date}&to={date}
GET /api/v1/news/symbol/{exchange}:{symbol}
GET /api/v1/news/category/{category}
```

The symbol-specific endpoint returns news articles specifically related to a given security, while category endpoints filter by broader topics such as markets, technology, politics, or economics.

#### News Data Schema

```json
{
  "article_id": "news_abc123xyz",
  "title": "Federal Reserve Signals Potential Rate Cut in Q3 2026",
  "summary": "Federal Reserve officials indicated on Wednesday that they may consider cutting interest rates in the third quarter of 2026 if inflation continues to moderate toward the 2% target.",
  "content": "Full article content would appear here with complete text...",
  "source": {
    "name": "Financial Times",
    "code": "FT",
    "reliability_score": 0.95,
    "tier": 1
  },
  "url": "https://www.ft.com/fed-rate-cut-q3",
  "published_at": "2026-04-27T14:30:00.000Z",
  "retrieved_at": "2026-04-27T14:31:15.000Z",
  "entities": [
    {
      "type": "organization",
      "name": "Federal Reserve",
      "ticker": null,
      "confidence": 0.99
    },
    {
      "type": "person",
      "name": "Jerome Powell",
      "role": "Federal Reserve Chair",
      "confidence": 0.97
    },
    {
      "type": "geographic",
      "name": "United States",
      "confidence": 0.98
    }
  ],
  "topics": ["monetary_policy", "interest_rates", "federal_reserve"],
  "sentiment": {
    "overall": "positive",
    "score": 0.65,
    "confidence": 0.82
  },
  "related_symbols": [],
  "impact_assessment": {
    "market_impact": "medium",
    "sectors_affected": ["banking", "real_estate", "utilities"],
    "expected_volatility": "moderate"
  },
  "data_source": "news_aggregator",
  "data_quality_score": 0.88
}
```

#### News Deduplication Strategy

News deduplication requires similarity detection across article content. The recommended approach combines multiple signals:

First, calculate a content hash (SHA-256) of normalized article text after removing whitespace normalization, HTML stripping, and lowercasing. Exact duplicates will share identical hashes.

Second, implement fuzzy matching using n-gram analysis for near-duplicate detection. Articles sharing more than 85% of 5-gram sequences should be considered duplicates, with the higher-quality source (based on reliability_score and content completeness) retained.

Third, use semantic embedding similarity for story-level deduplication. Multiple articles covering the same event from different sources should be grouped into a single story cluster, with a representative article selected for the primary story view.

### 2.2 Social Sentiment Analysis

Social sentiment integration captures market mood from platforms such as Twitter/X, Reddit, stock forums, and financial social networks. This data requires careful handling due to noise, manipulation attempts, and the need for attribution verification.

#### Social API Patterns

```
GET /api/v1/social/sentiment/{exchange}:{symbol}
GET /api/v1/social/trending?category={category}
GET /api/v1/social/mentions/{exchange}:{symbol}?from={date}&to={date}
```

#### Social Sentiment Schema

```json
{
  "symbol": "GME",
  "exchange": "NYSE",
  "timestamp": "2026-04-27T15:00:00.000Z",
  "time_bucket": "15min",
  "metrics": {
    "total_mentions": 45230,
    "unique_authors": 12850,
    "bullish_count": 28450,
    "bearish_count": 8920,
    "neutral_count": 7860,
    "weighted_sentiment_score": 0.42,
    "sentiment_trend": "increasing"
  },
  "platform_breakdown": [
    {
      "platform": "twitter",
      "mentions": 18500,
      "avg_sentiment": 0.38,
      "influence_score": 0.65
    },
    {
      "platform": "reddit",
      "mentions": 15200,
      "avg_sentiment": 0.52,
      "influence_score": 0.45
    },
    {
      "platform": "stocktwits",
      "mentions": 9500,
      "avg_sentiment": 0.35,
      "influence_score": 0.55
    }
  ],
  "influencer_impact": {
    "top_influencers": [
      {
        "handle": "DeepFuckingValue",
        "followers": 2500000,
        "sentiment": "bullish",
        "impact_score": 0.85
      }
    ],
    "aggregate_influencer_sentiment": 0.72
  },
  "manipulation_indicators": {
    "bot_probability": 0.15,
    "coordinated_activity": false,
    "suspicious_patterns": []
  },
  "data_source": "social_analytics",
  "data_quality_score": 0.72
}
```

### 2.3 Source Classification

News and intelligence sources require classification by reliability, expertise domain, and publication tier to weight their influence appropriately in downstream analysis.

#### Source Classification Schema

```json
{
  "source_id": "reuters",
  "name": "Reuters",
  "display_name": "Reuters News Agency",
  "tier": 1,
  "reliability_score": 0.95,
  "domains": ["general_news", "financial_news", "global_coverage"],
  "regions": ["global"],
  "languages": ["en", "zh", "ja", "de", "fr", "es"],
  "contact_info": {
    "headquarters": "London, UK",
    "established": 1851
  },
  "verification_practices": [
    "multiple_source_confirmation",
    "on_record_sources_only",
    "editorial_review_process"
  ],
  "classification_date": "2026-01-15",
  "last_verified": "2026-04-20"
}
```

Source tier classifications follow this standard:

- **Tier 1**: Established wire services and major financial news organizations with rigorous editorial standards and multi-source verification practices (Reuters, Bloomberg, Associated Press)
- **Tier 2**: Major newspapers, financial publications, and recognized industry outlets with editorial oversight (Wall Street Journal, Financial Times, Barron's)
- **Tier 3**: Recognized industry blogs, specialized publications, and regional news outlets with some editorial oversight
- **Tier 4**: Independent contributors, user-generated content platforms, and social media sources requiring additional verification

### 2.4 Sentiment Analysis Integration

Sentiment analysis converts qualitative text content into quantitative sentiment scores that can be used in quantitative trading models and qualitative analysis workflows.

#### Sentiment Analysis API Patterns

```
POST /api/v1/sentiment/analyze
Content-Type: application/json

{
  "text": "The company's earnings beat expectations by 15% with strong revenue growth across all segments.",
  "domain": "financial",
  "model_version": "finance-sentiment-v2.1"
}
```

#### Sentiment Response Schema

```json
{
  "request_id": "sentiment_req_456xyz",
  "timestamp": "2026-04-27T15:30:00.000Z",
  "input_text": "The company's earnings beat expectations by 15%...",
  "domain": "financial",
  "model_version": "finance-sentiment-v2.1",
  "results": {
    "overall_sentiment": "bullish",
    "polarity_score": 0.78,
    "polarity_label": "strongly_bullish",
    "confidence": 0.89,
    "emotions": {
      "joy": 0.45,
      "confidence": 0.35,
      "anticipation": 0.25,
      "fear": 0.05,
      "anger": 0.02,
      "sadness": 0.01
    },
    "key_phrases": [
      "beat expectations",
      "strong revenue growth",
      "all segments"
    ],
    "entities_with_sentiment": [
      {
        "entity": "earnings",
        "sentiment": "bullish",
        "score": 0.85,
        "context": "beat expectations by 15%"
      }
    ]
  },
  "processing_time_ms": 45
}
```

#### Sentiment Score Ranges

Polarity scores follow a standardized range from -1.0 (extremely bearish) to +1.0 (extremely bullish):

- **Strongly Bullish**: 0.6 to 1.0
- **Moderately Bullish**: 0.2 to 0.6
- **Neutral**: -0.2 to 0.2
- **Moderately Bearish**: -0.6 to -0.2
- **Strongly Bearish**: -1.0 to -0.6

### 2.5 Confidence Scoring

Confidence scoring provides a quantitative measure of reliability for aggregated sentiment data, accounting for source quality, sample size, and measurement consistency.

#### Confidence Scoring Formula

The overall confidence score combines multiple factors:

```
Confidence = BaseScore * sqrt(SampleWeight) * SourceQualityFactor * ConsistencyFactor

Where:
- BaseScore = 0.5 (minimum baseline)
- SampleWeight = min(mention_count / 1000, 1.0)
- SourceQualityFactor = weighted_average(source_reliability_scores)
- ConsistencyFactor = 1.0 - (standard_deviation_of_sentiment / max_possible_deviation)
```

#### Confidence Schema

```json
{
  "symbol": "TSLA",
  "exchange": "NASDAQ",
  "timestamp": "2026-04-27T15:00:00.000Z",
  "confidence_metrics": {
    "overall_confidence": 0.82,
    "components": {
      "sample_size": {
        "value": 0.75,
        "mention_count": 85420,
        "threshold_met": true
      },
      "source_quality": {
        "value": 0.88,
        "weighted_avg_reliability": 0.72,
        "tier1_percentage": 0.35
      },
      "consistency": {
        "value": 0.94,
        "sentiment_std_deviation": 0.12,
        "score_range": 0.65
      },
      "recency": {
        "value": 0.98,
        "data_age_minutes": 15,
        "freshness_threshold_minutes": 60
      }
    },
    "confidence_band": {
      "lower": 0.75,
      "upper": 0.89,
      "interpretation": "high_confidence"
    }
  },
  "data_source": "sentiment_aggregator",
  "data_quality_score": 0.82
}
```

---

