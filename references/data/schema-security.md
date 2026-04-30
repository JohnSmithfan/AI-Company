## 4. Multi-Source Data Fusion

Multi-source data fusion combines information from multiple providers to produce unified, consistent, and high-quality data outputs. This section details the technical approaches for schema normalization, conflict resolution, and quality scoring across heterogeneous data sources.

### 4.1 Schema Normalization

Schema normalization transforms provider-specific data formats into a unified canonical schema that supports consistent processing across all downstream components.

#### Normalization Pipeline

The normalization pipeline processes incoming data through a sequence of transformation stages:

**Stage 1: Field Mapping**

Field mapping translates provider-specific field names to canonical field names using configurable mapping tables:

```json
{
  "provider": "bloomberg",
  "mapping_version": "1.0.0",
  "field_mappings": {
    "PRIMARY_EXCHANGE": "exchange",
    "TICKER": "symbol",
    "LAST_PRICE": "price",
    "OPEN_PRC": "open",
    "HIGH_1": "high",
    "LOW_1": "low",
    "CLOSE_PRCE": "close",
    "PREVCLS": "previous_close",
    "VOLUME": "volume",
    "MKTCAP": "market_cap",
    "PE_RATIO": "pe_ratio",
    "DVD_YLD_12M": "dividend_yield",
    "ALL_EXCHANGES": "aggregated",
    "NET_CHANGE": "change",
    "PCT_CHANGE": "change_percent"
  }
}
```

**Stage 2: Type Conversion**

Type conversion ensures all fields conform to expected data types:

```javascript
const typeConverters = {
  price: (value) => parseFloat(value).toFixed(2),
  volume: (value) => parseInt(value, 10),
  timestamp: (value) => new Date(value).toISOString(),
  percentage: (value) => parseFloat(value) / 100,
  boolean: (value) => ['true', '1', 'yes', 'on'].includes(String(value).toLowerCase()),
  nullHandling: (value, defaultValue) => value === '' || value === null ? defaultValue : value
};
```

**Stage 3: Value Validation**

Value validation applies business rules to ensure data integrity:

```javascript
const validationRules = {
  price: (value) => value >= 0 && value < 1000000,
  volume: (value) => value >= 0 && value < 1e15,
  percentage: (value) => value >= -100 && value <= 100,
  timestamp: (value) => !isNaN(Date.parse(value)),
  symbol: (value) => /^[A-Z0-9]{1,10}$/.test(value),
  exchange: (value) => ['NYSE', 'NASDAQ', 'LSE', 'TSE', 'HKEX', 'SSE', 'SZSE'].includes(value)
};
```

**Stage 4: Enrichment**

Enrichment adds derived fields and metadata:

```javascript
const enrichmentFunctions = {
  addCalculatedFields: (data) => ({
    ...data,
    mid_price: data.bid && data.ask ? (data.bid + data.ask) / 2 : null,
    spread: data.bid && data.ask ? data.ask - data.bid : null,
    spread_percent: data.bid && data.ask ? ((data.ask - data.bid) / data.mid_price) * 100 : null,
    vwap_proxy: data.price && data.volume ? data.price * data.volume : null
  }),
  
  addTimestampMetadata: (data) => ({
    ...data,
    ingested_at: new Date().toISOString(),
    data_age_seconds: Math.floor((Date.now() - new Date(data.timestamp)) / 1000)
  }),
  
  addProviderMetadata: (data, provider) => ({
    ...data,
    source_provider: provider.name,
    source_quality_score: provider.reliabilityScore,
    source_timestamp: provider.timestamp
  })
};
```

### 4.2 Conflict Resolution

When multiple sources provide different values for the same data point, conflict resolution determines which value to use or how to combine them.

#### Conflict Detection

Conflicts are detected by comparing normalized values across sources:

```javascript
function detectConflict(observations, fieldName, tolerance = 0.001) {
  const values = observations
    .map(obs => obs[fieldName])
    .filter(v => v !== null && v !== undefined);
  
  if (values.length < 2) {
    return { hasConflict: false };
  }
  
  const mean = values.reduce((sum, v) => sum + v, 0) / values.length;
  const maxDeviation = Math.max(...values.map(v => Math.abs(v - mean) / mean));
  
  return {
    hasConflict: maxDeviation > tolerance,
    values,
    mean,
    maxDeviation,
    conflictLevel: maxDeviation > tolerance ? 'significant' : 'minor'
  };
}
```

#### Conflict Resolution Strategies

The framework supports multiple resolution strategies configured per data type:

```json
{
  "conflict_resolution": {
    "stock_quote": {
      "strategy": "weighted_quality_score",
      "fields": {
        "price": {
          "strategy": "weighted_average",
          "weights": ["provider_quality_score", "recency_score"],
          "tolerance": 0.001
        },
        "volume": {
          "strategy": "max",
          "tolerance": 0.05
        }
      }
    },
    "news_sentiment": {
      "strategy": "tiered_priority",
      "tiers": [
        { "tier": 1, "weight": 0.5 },
        { "tier": 2, "weight": 0.3 },
        { "tier": 3, "weight": 0.15 },
        { "tier": 4, "weight": 0.05 }
      ]
    },
    "earnings_estimate": {
      "strategy": "consensus",
      "exclude_outliers": true,
      "outlier_std_multiplier": 2
    }
  }
}
```

#### Resolution Strategy Implementations

**Weighted Average Strategy**: Combines values proportionally to their source quality scores:

```javascript
function resolveWeightedAverage(observations, fieldName, weights) {
  let weightedSum = 0;
  let totalWeight = 0;
  
  for (const obs of observations) {
    const value = obs[fieldName];
    const weight = calculateCompositeWeight(obs, weights);
    
    if (value !== null && value !== undefined && !isNaN(value)) {
      weightedSum += value * weight;
      totalWeight += weight;
    }
  }
  
  return totalWeight > 0 ? weightedSum / totalWeight : null;
}
```

**Consensus Strategy**: Uses median or trimmed mean to exclude outlier estimates:

```javascript
function resolveConsensus(observations, fieldName, excludeOutliers = true, stdMultiplier = 2) {
  const values = observations
    .map(obs => obs[fieldName])
    .filter(v => v !== null && v !== undefined && !isNaN(v))
    .sort((a, b) => a - b);
  
  if (values.length === 0) return null;
  
  if (!excludeOutliers || values.length < 4) {
    return values[Math.floor(values.length / 2)];
  }
  
  const median = values[Math.floor(values.length / 2)];
  const mean = values.reduce((sum, v) => sum + v, 0) / values.length;
  const variance = values.reduce((sum, v) => sum + Math.pow(v - mean, 2), 0) / values.length;
  const stdDev = Math.sqrt(variance);
  
  const lowerBound = median - (stdMultiplier * stdDev);
  const upperBound = median + (stdMultiplier * stdDev);
  
  const filteredValues = values.filter(v => v >= lowerBound && v <= upperBound);
  
  if (filteredValues.length === 0) return median;
  
  return filteredValues[Math.floor(filteredValues.length / 2)];
}
```

**Tiered Priority Strategy**: Selects the highest-quality source's value:

```javascript
function resolveTieredPriority(observations, fieldName, tiers) {
  const sorted = [...observations].sort((a, b) => {
    const tierA = tiers.findIndex(t => t.tier === a.sourceTier);
    const tierB = tiers.findIndex(t => t.tier === b.sourceTier);
    return tierA - tierB;
  });
  
  return sorted[0]?.[fieldName] ?? null;
}
```

### 4.3 Quality Scoring

Quality scoring provides a unified metric for data reliability that accounts for source reliability, data freshness, completeness, and consistency.

#### Quality Score Components

```javascript
const qualityComponents = {
  sourceReliability: (observation) => {
    const scores = {
      'bloomberg': 0.98,
      'refinitiv': 0.96,
      'factset': 0.94,
      'iex': 0.85,
      'yahoo': 0.80
    };
    return scores[observation.source] ?? 0.70;
  },
  
  freshness: (observation, maxAgeSeconds = 300) => {
    const ageSeconds = (Date.now() - new Date(observation.timestamp)) / 1000;
    return Math.max(0, 1 - (ageSeconds / maxAgeSeconds));
  },
  
  completeness: (observation, requiredFields) => {
    const filledFields = requiredFields.filter(f => 
      observation[f] !== null && 
      observation[f] !== undefined && 
      observation[f] !== ''
    );
    return filledFields.length / requiredFields.length;
  },
  
  consistency: (observations, fieldName) => {
    const values = observations
      .map(obs => obs[fieldName])
      .filter(v => v !== null && v !== undefined);
    
    if (values.length < 2) return 1.0;
    
    const mean = values.reduce((sum, v) => sum + v, 0) / values.length;
    const maxDeviation = Math.max(...values.map(v => Math.abs(v - mean) / mean));
    
    return Math.max(0, 1 - maxDeviation * 10);
  }
};
```

#### Combined Quality Score

```javascript
function calculateQualityScore(observation, relatedObservations = [], context = {}) {
  const weights = context.weights || {
    sourceReliability: 0.40,
    freshness: 0.25,
    completeness: 0.20,
    consistency: 0.15
  };
  
  const componentScores = {
    sourceReliability: qualityComponents.sourceReliability(observation),
    freshness: qualityComponents.freshness(observation, context.maxAgeSeconds),
    completeness: qualityComponents.completeness(observation, context.requiredFields || []),
    consistency: relatedObservations.length > 0 
      ? qualityComponents.consistency(relatedObservations, context.fieldName)
      : 1.0
  };
  
  const overallScore = Object.keys(weights).reduce((sum, key) => {
    return sum + (componentScores[key] * weights[key]);
  }, 0);
  
  return {
    overall: Math.round(overallScore * 100) / 100,
    components: componentScores,
    confidence: calculateConfidence(componentScores),
    grade: scoreToGrade(overallScore)
  };
}

function scoreToGrade(score) {
  if (score >= 0.95) return 'A+';
  if (score >= 0.90) return 'A';
  if (score >= 0.85) return 'B+';
  if (score >= 0.80) return 'B';
  if (score >= 0.70) return 'C';
  if (score >= 0.60) return 'D';
  return 'F';
}

function calculateConfidence(components) {
  const variances = Object.values(components).map(s => Math.pow(1 - s, 2));
  const avgVariance = variances.reduce((sum, v) => sum + v, 0) / variances.length;
  return 1 - Math.sqrt(avgVariance);
}
```

#### Quality Score Schema

```json
{
  "data_point_id": "quote_AAPL_XNAS_20260427T1530",
  "timestamp": "2026-04-27T15:30:00.000Z",
  "quality_score": {
    "overall": 0.92,
    "grade": "A",
    "confidence": 0.85,
    "components": {
      "source_reliability": 0.96,
      "freshness": 0.95,
      "completeness": 0.88,
      "consistency": 0.89
    },
    "component_weights": {
      "source_reliability": 0.40,
      "freshness": 0.25,
      "completeness": 0.20,
      "consistency": 0.15
    },
    "flags": [],
    "warnings": ["Minor inconsistency in bid/ask spread"],
    "recommendations": []
  },
  "source_breakdown": [
    {
      "source": "bloomberg",
      "value": 189.45,
      "quality_contribution": 0.38
    },
    {
      "source": "refinitiv",
      "value": 189.44,
      "quality_contribution": 0.36
    },
    {
      "source": "iex",
      "value": 189.50,
      "quality_contribution": 0.18
    }
  ]
}
```

---

## 5. Standardization Schema

Standardization ensures consistent data formats, conventions, and response structures across all components of the data integration framework. This section defines the canonical schemas, conventions, and error handling patterns that all data operations must follow.

### 5.1 Timestamp Conventions

All timestamps within the framework follow ISO-8601 format with explicit timezone designation. This ensures unambiguous temporal ordering and correct time-based operations across global deployments.

#### Timestamp Format Standards

**Primary Format (Full Precision)**

```
YYYY-MM-DDTHH:mm:ss.SSSZ
Example: 2026-04-27T15:30:00.000Z
```

The `Z` suffix indicates UTC timezone. For local times with explicit offsets:

```
YYYY-MM-DDTHH:mm:ss.SSS±HH:mm
Example: 2026-04-27T11:30:00.000-04:00
```

**Compact Format (Historical Data)**

```
YYYY-MM-DD
Example: 2026-04-27
```

**Unix Timestamp (Internal Processing)**

```
Seconds since epoch (1970-01-01T00:00:00Z)
Example: 1745765400
```

#### Timestamp Validation Rules

```javascript
const timestampValidation = {
  isValidISO8601: (value) => {
    const regex = /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}(\.\d{3})?(Z|[+-]\d{2}:\d{2})?)?$/;
    if (!regex.test(value)) return false;
    const date = new Date(value);
    return !isNaN(date.getTime());
  },
  
  isValidUnixTimestamp: (value) => {
    const num = parseInt(value, 10);
    return !isNaN(num) && num > 0 && num < 1e12;
  },
  
  normalizeToISO: (value) => {
    if (timestampValidation.isValidISO8601(value)) {
      return new Date(value).toISOString();
    }
    if (timestampValidation.isValidUnixTimestamp(value)) {
      return new Date(parseInt(value, 10) * 1000).toISOString();
    }
    throw new InvalidTimestampError(`Cannot parse timestamp: ${value}`);
  },
  
  normalizeToUnix: (value) => {
    const iso = timestampValidation.normalizeToISO(value);
    return Math.floor(new Date(iso).getTime() / 1000);
  }
};
```

### 5.2 Symbol Conventions

Financial symbols follow a standardized format that ensures uniqueness across global markets.

#### Symbol Format Standard

The canonical symbol format is `{exchange}:{symbol}` where:

- **Exchange**: ISO 10383 market identifier code (MIC) in uppercase
- **Symbol**: Exchange-specific security identifier

```
Examples:
NYSE:AAPL      - Apple on NYSE
XNAS:MSFT      - Microsoft on NASDAQ
XLON:HSBA      - HSBC on London Stock Exchange
XHKG:0700      - Tencent on HKEX
XSHG:600519    - Kweichow Moutai on Shanghai
XSHE:000858    - Wuliangye on Shenzhen
```

#### Symbol Validation Rules

```javascript
const symbolValidation = {
  MIC_CODES: new Set([
    'XNAS', 'XNYS', 'XASE', 'ARCX', 'XOTO',
    'XLON', 'XPAR', 'XFRA', 'XSWX', 'XMIL',
    'XHKG', 'XSHG', 'XSHE', 'XTKS', 'XJPX',
    'KSC', 'XKRX', 'ASX', 'XNZE', 'XBOM',
    'SGX', 'XIDX', 'XBKK', 'XKLS'
  ]),
  
  isValidMIC: (mic) => {
    return symbolValidation.MIC_CODES.has(mic.toUpperCase());
  },
  
  isValidSymbol: (symbol) => {
    // Symbol should be 1-10 alphanumeric characters
    return /^[A-Z0-9]{1,10}$/i.test(symbol);
  },
  
  isValidCanonicalSymbol: (canonical) => {
    const parts = canonical.split(':');
    if (parts.length !== 2) return false;
    const [exchange, symbol] = parts;
    return symbolValidation.isValidMIC(exchange) && symbolValidation.isValidSymbol(symbol);
  },
  
  normalizeSymbol: (input) => {
    const parts = input.split(':');
    if (parts.length === 2) {
      return `${parts[0].toUpperCase()}:${parts[1].toUpperCase()}`;
    }
    // Assume NASDAQ for US symbols without exchange
    if (/^[A-Z]{1,4}$/i.test(input)) {
      return `XNAS:${input.toUpperCase()}`;
    }
    throw new InvalidSymbolError(`Invalid symbol format: ${input}`);
  },
  
  parseSymbol: (canonical) => {
    const parts = canonical.split(':');
    if (parts.length !== 2) {
      throw new InvalidSymbolError(`Invalid canonical symbol: ${canonical}`);
    }
    return {
      exchange: parts[0].toUpperCase(),
      symbol: parts[1].toUpperCase(),
      mic: parts[0].toUpperCase()
    };
  }
};
```

### 5.3 Error Response Schema

All API errors follow a consistent schema that enables reliable error handling across the framework.

#### Error Response Format

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "API rate limit exceeded. Please retry after 5000 milliseconds.",
    "details": {
      "provider": "bloomberg",
      "retry_after_ms": 5000,
      "limit_type": "requests_per_minute",
      "current_usage": 100,
      "limit": 100
    },
    "timestamp": "2026-04-27T15:30:00.000Z",
    "request_id": "req_abc123xyz",
    "documentation_url": "https://docs.example.com/errors/RATE_LIMIT_EXCEEDED"
  }
}
```

#### Standard Error Codes

| Code | HTTP Status | Description | Retryable |
|------|-------------|-------------|-----------|
| `INVALID_REQUEST` | 400 | Malformed request or invalid parameters | No |
| `MISSING_REQUIRED_FIELD` | 400 | Required field not provided | No |
| `INVALID_SYMBOL` | 400 | Symbol format invalid or not found | No |
| `INVALID_TIMESTAMP` | 400 | Timestamp format invalid | No |
| `UNAUTHORIZED` | 401 | Invalid or missing authentication | No |
| `FORBIDDEN` | 403 | Insufficient permissions | No |
| `NOT_FOUND` | 404 | Resource not found | No |
| `METHOD_NOT_ALLOWED` | 405 | HTTP method not supported | No |
| `RATE_LIMIT_EXCEEDED` | 429 | API rate limit hit | Yes |
| `QUOTA_EXCEEDED` | 429 | Monthly quota exhausted | Yes |
| `PROVIDER_UNAVAILABLE` | 503 | External provider is down | Yes |
| `SERVICE_UNAVAILABLE` | 503 | Internal service unavailable | Yes |
| `TIMEOUT` | 504 | Request timed out | Yes |
| `INTERNAL_ERROR` | 500 | Unexpected server error | Yes |

#### Error Handler Implementation

```javascript
class ErrorHandler {
  constructor(config) {
    this.errorLog = new ErrorLogger(config.logging);
    this.alertSystem = new AlertSystem(config.alerts);
  }

  handleError(error, context = {}) {
    const errorResponse = this.formatError(error, context);
    this.errorLog.log(errorResponse);
    
    if (this.shouldAlert(error)) {
      this.alertSystem.send(errorResponse);
    }
    
    return errorResponse;
  }

  formatError(error, context) {
    const code = this.mapErrorToCode(error);
    const httpStatus = this.codeToHTTPStatus(code);
    
    return {
      error: {
        code,
        message: error.message || this.getDefaultMessage(code),
        details: this.extractDetails(error),
        timestamp: new Date().toISOString(),
        request_id: context.requestId || this.generateRequestId(),
        documentation_url: this.getDocumentationURL(code)
      },
      httpStatus
    };
  }

  mapErrorToCode(error) {
    const errorMap = {
      'ValidationError': 'INVALID_REQUEST',
      'SymbolNotFoundError': 'NOT_FOUND',
      'RateLimitError': 'RATE_LIMIT_EXCEEDED',
      'ProviderTimeoutError': 'TIMEOUT',
      'AuthenticationError': 'UNAUTHORIZED',
      'AuthorizationError': 'FORBIDDEN'
    };
    return errorMap[error.name] || 'INTERNAL_ERROR';
  }

  extractDetails(error) {
    if (error.details) return error.details;
    if (error.provider) return { provider: error.provider };
    return {};
  }

  shouldAlert(error) {
    const alertConditions = [
      error.name === 'ProviderUnavailableError',
      error.name === 'ServiceUnavailableError',
      error.message?.includes('circuit breaker'),
      error.retryCount > 3
    ];
    return alertConditions.some(Boolean);
  }

  generateRequestId() {
    return `req_${Date.now().toString(36)}_${Math.random().toString(36).substr(2, 9)}`;
  }

  codeToHTTPStatus(code) {
    const statusMap = {
      'INVALID_REQUEST': 400,
      'MISSING_REQUIRED_FIELD': 400,
      'INVALID_SYMBOL': 400,
      'INVALID_TIMESTAMP': 400,
      'UNAUTHORIZED': 401,
      'FORBIDDEN': 403,
      'NOT_FOUND': 404,
      'METHOD_NOT_ALLOWED': 405,
      'RATE_LIMIT_EXCEEDED': 429,
      'QUOTA_EXCEEDED': 429,
      'PROVIDER_UNAVAILABLE': 503,
      'SERVICE_UNAVAILABLE': 503,
      'TIMEOUT': 504,
      'INTERNAL_ERROR': 500
    };
    return statusMap[code] || 500;
  }

  getDocumentationURL(code) {
    return `https://docs.ai-company.dev/errors/${code}`;
  }

  getDefaultMessage(code) {
    const messages = {
      'INVALID_REQUEST': 'The request could not be processed due to invalid parameters.',
      'NOT_FOUND': 'The requested resource was not found.',
      'RATE_LIMIT_EXCEEDED': 'API rate limit exceeded. Please retry after the specified delay.',
      'TIMEOUT': 'The request timed out. Please retry.',
      'INTERNAL_ERROR': 'An unexpected error occurred. Please try again later.'
    };
    return messages[code] || 'An error occurred.';
  }
}
```

### 5.4 Success Response Schema

Successful responses follow a consistent envelope format that includes metadata alongside the requested data.

#### Success Response Format

```json
{
  "success": true,
  "data": {
    /* Response data */
  },
  "metadata": {
    "request_id": "req_abc123xyz",
    "timestamp": "2026-04-27T15:30:00.000Z",
    "data_source": "primary_provider",
    "data_age_seconds": 15,
    "quality_score": 0.92,
    "pagination": {
      "page": 1,
      "page_size": 100,
      "total_pages": 5,
      "total_records": 450
    }
  }
}
```

#### Batch Response Format

```json
{
  "success": true,
  "data": [
    { "symbol": "AAPL", "price": 189.45, "status": "success" },
    { "symbol": "INVALID", "error": "Symbol not found", "status": "error" },
    { "symbol": "MSFT", "price": 415.20, "status": "success" }
  ],
  "metadata": {
    "request_id": "req_batch_456xyz",
    "timestamp": "2026-04-27T15:30:00.000Z",
    "total_requested": 3,
    "total_successful": 2,
    "total_failed": 1,
    "partial_success": true
  }
}
```

### 5.5 Pagination Schema

List endpoints support pagination with consistent parameter and response formats.

#### Pagination Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number (1-indexed) |
| `page_size` | integer | 100 | Records per page (max 1000) |
| `offset` | integer | 0 | Alternative to page for offset-based pagination |
| `limit` | integer | 100 | Maximum records to return |
| `cursor` | string | null | Cursor for cursor-based pagination |

#### Pagination Response

```json
{
  "success": true,
  "data": [ /* Array of records */ ],
  "metadata": {
    "pagination": {
      "page": 1,
      "page_size": 100,
      "total_records": 1523,
      "total_pages": 16,
      "has_next": true,
      "has_previous": false,
      "next_cursor": "eyJsYXN0IjogIjE2MDAifQ==",
      "previous_cursor": null
    },
    "request_id": "req_paginated_789xyz",
    "timestamp": "2026-04-27T15:30:00.000Z"
  }
}
```

### 5.6 Data Freshness Indicators

All time-sensitive data includes freshness metadata to enable informed consumption decisions.

#### Freshness Schema

```json
{
  "data_point": {
    "value": 189.45,
    "timestamp": "2026-04-27T15:30:00.000Z",
    "freshness": {
      "age_seconds": 15,
      "age_formatted": "15 seconds",
      "is_fresh": true,
      "fresh_threshold_seconds": 300,
      "market_open_fresh_threshold_seconds": 60,
      "market_closed_fresh_threshold_seconds": 3600
    },
    "data_delay": {
      "is_delayed": false,
      "delay_seconds": 0,
      "delay_category": "real_time",
      "provider_delay_info": null
    }
  }
}
```

#### Freshness Thresholds by Data Type

| Data Type | Market Open Threshold | Market Closed Threshold |
|-----------|----------------------|------------------------|
| Stock Quote | 60 seconds | 1 hour |
| Intraday OHLCV | 5 minutes | 1 hour |
| Daily OHLCV | 1 day | None (EOD) |
| News Article | 5 minutes | 5 minutes |
| Earnings | 1 hour | 1 hour |
| Macro Indicator | 1 hour | 1 hour |

---

## Appendix A: Complete Data Schema Reference

This appendix provides a consolidated reference of all schema types used throughout the data integration framework.

### Common Fields

All data objects include these standard fields:

```json
{
  "id": "unique_identifier",
  "created_at": "2026-04-27T15:30:00.000Z",
  "updated_at": "2026-04-27T15:30:00.000Z",
  "version": 1,
  "source": "provider_name",
  "quality_score": 0.92,
  "metadata": {}
}
```

### Geographic Coordinate Schema

```json
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "altitude": null,
  "precision": "high",
  "datum": "WGS84"
}
```

### Currency Amount Schema

```json
{
  "value": 189450000,
  "display_value": "$1,894.50",
  "currency": "USD",
  "currency_code": "840",
  "amount_type": "per_share",
  "converted_values": {
    "EUR": 175.20,
    "GBP": 151.30,
    "JPY": 28450.00,
    "CNY": 1375.80
  }
}
```

### Percentage Schema

```json
{
  "value": 2.45,
  "display_value": "2.45%",
  "direction": "positive",
  "basis_points": 245,
  "change_from": 185.20,
  "change_to": 189.45
}
```

---

## Appendix B: Integration Testing Patterns

### Unit Test Template

```javascript
describe('DataProvider Integration', () => {
  let provider;
  
  beforeEach(() => {
    provider = new DataProviderAdapter({
      name: 'test_provider',
      baseUrl: 'https://api.test-provider.com',
      apiKey: process.env.TEST_API_KEY, // TEMPLATE: env var reference only — no real key
      rateLimit: { maxRequests: 10, windowMs: 1000 },
      cacheConfig: { enabled: true, ttlSeconds: 60 }
    });
  });
  
  describe('fetchQuote', () => {
    it('should return normalized quote data', async () => {
      const result = await provider.fetchQuote('XNAS:AAPL');
      
      expect(result).to.have.property('symbol').equal('AAPL');
      expect(result).to.have.property('exchange').equal('XNAS');
      expect(result).to.have.property('price').that.is.a('number');
      expect(result).to.have.property('timestamp').that.matches(/^\d{4}-\d{2}-\d{2}T/);
      expect(result.quality_score).to.be.at.least(0.7);
    });
    
    it('should throw InvalidSymbolError for invalid symbols', async () => {
      await expect(provider.fetchQuote('INVALID'))
        .to.be.rejectedWith('InvalidSymbolError');
    });
    
    it('should handle rate limiting gracefully', async () => {
      const requests = Array(15).fill().map(() => provider.fetchQuote('XNAS:AAPL'));
      const results = await Promise.allSettled(requests);
      
      const failures = results.filter(r => r.status === 'rejected');
      expect(failures.length).to.be.greaterThan(0);
      expect(failures[0].reason).to.be.instanceOf(RateLimitError);
    });
  });
});
```

### Integration Test Template

```javascript
describe('Multi-Source Fusion Integration', () => {
  const fusionEngine = new FusionEngine({
    providers: [
      { name: 'bloomberg', weight: 0.5 },
      { name: 'refinitiv', weight: 0.3 },
      { name: 'iex', weight: 0.2 }
    ],
    conflictResolution: {
      strategy: 'weighted_average',
      tolerance: 0.001
    }
  });
  
  it('should fuse data from multiple providers', async () => {
    const observations = [
      { source: 'bloomberg', price: 189.45, quality: 0.98 },
      { source: 'refinitiv', price: 189.44, quality: 0.96 },
      { source: 'iex', price: 189.50, quality: 0.85 }
    ];
    
    const result = fusionEngine.fuse(observations, 'price');
    
    expect(result.value).to.be.closeTo(189.46, 0.01);
    expect(result.confidence).to.be.at.least(0.8);
    expect(result.sources).to.have.lengthOf(3);
  });
  
  it('should detect and flag conflicts', async () => {
    const observations = [
      { source: 'bloomberg', price: 189.45 },
      { source: 'refinitiv', price: 195.00 }
    ];
    
    const result = fusionEngine.fuse(observations, 'price');
    
    expect(result.flags).to.include('conflict_detected');
    expect(result.conflict_resolution).to.equal('manual_review_required');
  });
});
```

---

## Appendix C: Security Considerations

### API Key Management

API keys should never be hardcoded or logged. Use environment variables or secrets management systems:

```javascript
// CORRECT: Environment variable
const apiKey = process.env.PROVIDER_API_KEY;

// INCORRECT: Hardcoded key (REDACTED — never embed real credentials)
const apiKey = 'REDACTED_EXAMPLE';
```

### Input Sanitization

All external inputs must be sanitized before use in API calls:

```javascript
function sanitizeSymbol(input) {
  // Remove any characters except alphanumeric and colon
  const sanitized = input.replace(/[^A-Za-z0-9:]/g, '');
  // Validate length
  if (sanitized.length > 15) {
    throw new ValidationError('Symbol too long');
  }
  return sanitized;
}

function sanitizeQuery(input) {
  // Remove potential injection characters
  const sanitized = input
    .replace(/[<>]/g, '')
    .replace(/['"]/g, '')
    .trim();
  // Limit length
  return sanitized.substring(0, 500);
}
```

### Certificate Validation

All HTTPS connections must validate certificates:

```javascript
const https = require('https');

const agent = new https.Agent({
  rejectUnauthorized: true,
  cert: fs.readFileSync('./certs/client.crt'),
  key: fs.readFileSync('./certs/client.key')
});
```

---

*Document Version: 1.0.0*
*Last Updated: 2026-04-27*
*Maintainer: CTO-data Team*
