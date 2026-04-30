## 3. Information Services Integration

Information services cover auxiliary data types including weather data, geolocation services, timezone conversions, and other utility services that support financial analysis and operational workflows.

### 3.1 Weather Data Integration

Weather data affects commodity markets, energy demand, agricultural futures, and insurance sectors. Integration patterns must handle multiple data formats and forecast horizons.

#### Weather API Patterns

```
GET /api/v1/weather/current?location={lat},{lon}
GET /api/v1/weather/forecast?location={lat},{lon}&days={count}
GET /api/v1/weather/historical?location={lat},{lon}&from={date}&to={date}
```

#### Weather Data Schema

```json
{
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "city": "New York",
    "region": "New York",
    "country": "US",
    "timezone": "America/New_York"
  },
  "timestamp": "2026-04-27T15:00:00.000Z",
  "current": {
    "temperature": 18.5,
    "temperature_unit": "celsius",
    "feels_like": 17.2,
    "humidity": 65,
    "wind_speed": 12.5,
    "wind_direction": 225,
    "wind_direction_cardinal": "SW",
    "pressure": 1013.25,
    "visibility": 16.0,
    "uv_index": 5,
    "condition": "partly_cloudy",
    "condition_code": 802
  },
  "forecast": [
    {
      "date": "2026-04-28",
      "high": 22.0,
      "low": 14.0,
      "condition": "sunny",
      "precipitation_probability": 10,
      "precipitation_amount": 0.0
    }
  ],
  "alerts": [],
  "data_source": "weather_provider",
  "data_quality_score": 0.95
}
```

### 3.2 Geolocation Services

Geolocation integration supports address parsing, coordinate lookup, and distance calculations that are essential for event correlation and market analysis.

#### Geolocation API Patterns

```
GET /api/v1/geo/lookup?address={address_string}
GET /api/v1/geo/lookup?lat={lat}&lon={lon}
GET /api/v1/geo/distance?from={lat1},{lon1}&to={lat2},{lon2}
```

#### Geolocation Schema

```json
{
  "query": {
    "input": "Wall Street, New York, NY",
    "input_type": "address"
  },
  "results": [
    {
      "formatted_address": "Wall Street, New York, NY 10005, USA",
      "location": {
        "latitude": 40.7074,
        "longitude": -74.0113
      },
      "components": {
        "street_number": null,
        "street": "Wall Street",
        "city": "New York",
        "county": "New York County",
        "state": "NY",
        "postal_code": "10005",
        "country": "US"
      },
      "accuracy": "high",
      "timezone": "America/New_York",
      "match_confidence": 0.95
    }
  ],
  "data_source": "geocoding_provider",
  "data_quality_score": 0.92
}
```

### 3.3 Timezone Conversion Services

Timezone handling is critical for global financial operations where markets in different regions operate on different local times. Incorrect timezone handling can lead to missed data windows, incorrect event attribution, and scheduling failures.

#### Timezone API Patterns

```
GET /api/v1/timezone/convert?time={iso8601}&from={tz_from}&to={tz_to}
GET /api/v1/timezone/now?location={location_code}
GET /api/v1/timezone/markets?date={iso8601}
```

#### Timezone Conversion Schema

```json
{
  "query": {
    "input_time": "2026-04-27T09:30:00",
    "input_timezone": "America/New_York",
    "target_timezone": "Asia/Shanghai",
    "format": "iso8601"
  },
  "result": {
    "converted_time": "2026-04-27T21:30:00+08:00",
    "converted_time_unix": 1745770200,
    "offset_difference_hours": 12,
    "dst_affected": false
  },
  "market_context": {
    "nyse_open": false,
    "nyse_closed": false,
    "shanghai_open": true,
    "time_until_nyse_open": "PT16H"
  }
}
```

#### Market Hours Schema

```json
{
  "timestamp": "2026-04-27T15:00:00.000Z",
  "markets": [
    {
      "exchange": "NYSE",
      "code": "XNYS",
      "timezone": "America/New_York",
      "status": "open",
      "current_time": "2026-04-27T11:00:00-04:00",
      "session": {
        "type": "regular",
        "open": "09:30:00-04:00",
        "close": "16:00:00-04:00",
        "trading_hours": "09:30-16:00 ET"
      },
      "next_event": {
        "type": "close",
        "time": "2026-04-27T16:00:00-04:00",
        "time_until": "PT5H"
      }
    },
    {
      "exchange": "SSE",
      "code": "XSHG",
      "timezone": "Asia/Shanghai",
      "status": "closed",
      "current_time": "2026-04-28T00:00:00+08:00",
      "session": {
        "type": "regular",
        "open": "09:30:00+08:00",
        "close": "15:00:00+08:00",
        "trading_hours": "09:30-15:00 CST"
      },
      "next_event": {
        "type": "open",
        "time": "2026-04-28T09:30:00+08:00",
        "time_until": "PT9H30M"
      }
    }
  ],
  "data_source": "market_hours_provider",
  "data_quality_score": 0.98
}
```

### 3.4 Provider Integration Patterns

All external data providers should be integrated using a consistent adapter pattern that abstracts provider-specific implementations behind a common interface.

#### Provider Adapter Interface

```javascript
// Provider adapter interface definition
class DataProviderAdapter {
  constructor(config) {
    this.config = config;
    this.rateLimiter = new RateLimiter(config.rateLimit);
    this.circuitBreaker = new CircuitBreaker(config.circuitBreaker);
    this.cache = new CacheLayer(config.cacheConfig);
  }

  async fetch(endpoint, params) {
    // Rate limiting check
    await this.rateLimiter.acquire();
    
    // Circuit breaker check
    if (this.circuitBreaker.isOpen()) {
      throw new ProviderUnavailableError('Circuit breaker is open');
    }
    
    // Cache check
    const cacheKey = this.buildCacheKey(endpoint, params);
    const cached = await this.cache.get(cacheKey);
    if (cached && !this.isStale(cached)) {
      return cached;
    }
    
    try {
      const response = await this.executeRequest(endpoint, params);
      await this.cache.set(cacheKey, response);
      this.circuitBreaker.recordSuccess();
      return response;
    } catch (error) {
      this.circuitBreaker.recordFailure();
      throw error;
    }
  }

  buildCacheKey(endpoint, params) {
    const normalizedParams = Object.keys(params)
      .sort()
      .reduce((acc, key) => ({ ...acc, [key]: params[key] }), {});
    const paramString = JSON.stringify(normalizedParams);
    return `${this.providerName}:${endpoint}:${hash(paramString)}`;
  }

  normalizeTimestamp(timestamp) {
    return new Date(timestamp).toISOString();
  }

  normalizeSymbol(symbol, exchange) {
    return `${exchange}:${symbol}`;
  }
}
```

### 3.5 Fallback Strategies

Robust data integration requires comprehensive fallback strategies that gracefully degrade when primary data sources become unavailable.

#### Fallback Configuration Schema

```json
{
  "data_type": "stock_quote",
  "primary_provider": "bloomberg",
  "providers": [
    {
      "name": "bloomberg",
      "priority": 1,
      "enabled": true,
      "weight": 0.60,
      "timeout_ms": 5000,
      "retry_config": {
        "max_attempts": 3,
        "backoff_multiplier": 2,
        "initial_delay_ms": 1000
      }
    },
    {
      "name": "refinitiv",
      "priority": 2,
      "enabled": true,
      "weight": 0.30,
      "timeout_ms": 8000,
      "retry_config": {
        "max_attempts": 2,
        "backoff_multiplier": 2,
        "initial_delay_ms": 2000
      }
    },
    {
      "name": "iex_cloud",
      "priority": 3,
      "enabled": true,
      "weight": 0.10,
      "timeout_ms": 10000,
      "retry_config": {
        "max_attempts": 1,
        "backoff_multiplier": 1,
        "initial_delay_ms": 0
      }
    }
  ],
  "aggregation_strategy": "weighted_average",
  "stale_threshold_seconds": 60,
  "fallback_timeout_seconds": 15
}
```

#### Circuit Breaker Implementation

```javascript
class CircuitBreaker {
  constructor(config) {
    this.failureThreshold = config.failureThreshold || 5;
    this.successThreshold = config.successThreshold || 3;
    this.timeout = config.timeout || 60000;
    this.state = 'CLOSED';
    this.failures = 0;
    this.successes = 0;
    this.lastFailureTime = null;
  }

  recordSuccess() {
    this.failures = 0;
    if (this.state === 'HALF_OPEN') {
      this.successes++;
      if (this.successes >= this.successThreshold) {
        this.state = 'CLOSED';
        this.successes = 0;
      }
    }
  }

  recordFailure() {
    this.failures++;
    this.lastFailureTime = Date.now();
    if (this.state === 'HALF_OPEN') {
      this.state = 'OPEN';
    } else if (this.failures >= this.failureThreshold) {
      this.state = 'OPEN';
    }
  }

  isOpen() {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailureTime >= this.timeout) {
        this.state = 'HALF_OPEN';
        return false;
      }
      return true;
    }
    return false;
  }

  getState() {
    return {
      state: this.state,
      failures: this.failures,
      successes: this.successes,
      lastFailureTime: this.lastFailureTime
    };
  }
}
```

### 3.6 Rate Limiting

Rate limiting controls API consumption to stay within provider-imposed quotas. The implementation should support multiple strategies including fixed window, sliding window, and token bucket algorithms.

#### Rate Limiter Implementation

```javascript
class RateLimiter {
  constructor(config) {
    this.maxRequests = config.maxRequests || 100;
    this.windowMs = config.windowMs || 60000;
    this.strategy = config.strategy || 'sliding_window';
    this.requests = [];
  }

  async acquire(weight = 1) {
    if (this.strategy === 'token_bucket') {
      return this.acquireTokenBucket(weight);
    }
    return this.acquireSlidingWindow(weight);
  }

  async acquireSlidingWindow(weight) {
    const now = Date.now();
    const windowStart = now - this.windowMs;
    
    // Remove expired requests
    this.requests = this.requests.filter(ts => ts > windowStart);
    
    const currentCount = this.requests.reduce((sum, _) => sum + 1, 0);
    
    if (currentCount + weight > this.maxRequests) {
      const waitTime = this.windowMs - (now - this.requests[0]);
      throw new RateLimitError(`Rate limit exceeded. Retry after ${waitTime}ms`, waitTime);
    }
    
    for (let i = 0; i < weight; i++) {
      this.requests.push(now);
    }
    
    return true;
  }

  async acquireTokenBucket(weight) {
    if (!this.tokens) {
      this.tokens = this.maxRequests;
      this.lastRefill = Date.now();
    }
    
    const now = Date.now();
    const elapsed = now - this.lastRefill;
    const refillAmount = Math.floor((elapsed / this.windowMs) * this.maxRequests);
    this.tokens = Math.min(this.maxRequests, this.tokens + refillAmount);
    this.lastRefill = now;
    
    if (this.tokens < weight) {
      const waitTime = Math.ceil((weight - this.tokens) / (this.maxRequests / this.windowMs));
      throw new RateLimitError(`Rate limit exceeded. Retry after ${waitTime}ms`, waitTime);
    }
    
    this.tokens -= weight;
    return true;
  }

  getStatus() {
    const now = Date.now();
    const windowStart = now - this.windowMs;
    const activeRequests = this.requests.filter(ts => ts > windowStart).length;
    
    return {
      strategy: this.strategy,
      currentRequests: activeRequests,
      maxRequests: this.maxRequests,
      remainingRequests: Math.max(0, this.maxRequests - activeRequests),
      resetAt: new Date(now + this.windowMs).toISOString()
    };
  }
}
```

---

