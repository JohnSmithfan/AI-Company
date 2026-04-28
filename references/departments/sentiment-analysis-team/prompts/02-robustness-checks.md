# Robustness Checks — Sentiment Analysis Team

> Security validation, input boundary testing, and error handling.

---

## Security Check Matrix

| Risk Category | Prohibited Behavior | Safe Alternative | Validation |
|---------------|-------------------|------------------|------------|
| Permission Abuse | Reading ~/.ssh, ~/.aws, system paths | Workspace-scoped only | Path whitelist check |
| Remote Execution | curl/wget to unknown URLs | Whitelisted APIs only | Domain validation |
| Dynamic Eval | eval(), exec(), subprocess shell=True | Pre-defined functions | Code pattern scan |
| Data Exfiltration | External unencrypted | Encrypted API channels | TLS verification |
| Obfuscation | Minified/encoded | Clear readable source | No encoded strings |

---

## Input Boundary Testing

### QueryEngine

| Test Case | Input | Expected | Validation |
|-----------|-------|----------|-----------|
| Empty query | "" | QUERY_001 | Error raised |
| Min length | "a" | QUERY_001 | Error raised |
| Valid query | "品牌声誉" | Success | >=5 results |
| Max length | 500 chars | Success | Truncated if needed |
| Special chars | "<script>" | Sanitized | No injection |
| SQL injection | "' OR '1'='1" | Sanitized | No injection |

### MediaEngine

| Test Case | Input | Expected | Validation |
|-----------|-------|----------|-----------|
| Empty content | "" | MEDIA_002 | Error raised |
| Max size | 10MB image | Success | Processed |
| Invalid format | .exe file | MEDIA_003 | Moderation triggered |
| Non-image | text only | Success | Text analysis |
| Chinese text | "舆情监控" | Success | Encoding correct |

### ReportEngine

| Test Case | Input | Expected | Validation |
|-----------|-------|----------|-----------|
| Empty insights | {} | REPORT_001 | Template fail |
| Valid insights | full | Success | HTML generated |
| Max size | 1MB data | Success | Report generated |
| Invalid format | html disabled | REPORT_004 | Format error |
| PII present | "张三 138xxxx" | Masked | PII replaced |

---

## API Safety Testing

### Rate Limiting

| API | Limit | Window | Behavior |
|-----|-------|--------|----------|
| Tavily | 100 | 1 min | QUERY_003 on exceed |
| Bocha | 50 | 1 min | MEDIA_001 on exceed |
| Qwen3 | 30 | 1 min | FORUM_001 on exceed |

### Timeout Handling

| API | Timeout | Retry | Backoff |
|-----|---------|-------|---------|
| Tavily | 30s | 3 | 60s |
| Bocha | 30s | 3 | 60s |
| Qwen3 | 300s | 2 | 120s |
| Database | 10s | 3 | 5s |

---

## Data Privacy Compliance

### PII Detection Patterns

| Pattern | Example | Masking |
|---------|---------|---------|
| Phone | 13812345678 | 138****5678 |
| Email | user@domain.com | u***@domain.com |
| ID | 110101199001011234 | 110101********1234 |
| Name | 张三 | 张* |
| Address | 北京朝阳区xxx | 北京*** |

### GDPR-Aligned Handling

- PII detection before any storage
- Masking before any output
- Audit log for PII access
- Retention policy enforcement

---

## Error Recovery Procedures

### QUERY_001 Recovery
```
1. Check TAVILY_API_KEY environment variable
2. Verify API key validity at Tavily dashboard
3. Check network connectivity to api.tavily.com
4. Retry with exponential backoff
5. If persistent, switch to fallback search provider
```

### MEDIA_001 Recovery
```
1. Check BOCHA_API_KEY environment variable
2. Verify API key validity at Bocha dashboard
3. Check network connectivity to api.bocha.com
4. Retry with exponential backoff
5. If persistent, use text-only analysis mode
```

### INSIGHT_001 Recovery
```
1. Check database connection parameters
2. Verify MediaCrawlerDB is running
3. Check network connectivity to DB host
4. Verify credentials have SELECT permission
5. If persistent, use cache mode fallback
```

### FORUM_001 Recovery
```
1. Check Qwen3-235B endpoint availability
2. Verify FORUM_API_KEY validity
3. Check network connectivity to LLM host
4. Retry with extended timeout
5. If persistent, skip ForumEngine, finalize report
```

---

## Health Check Endpoints

### QueryEngine Health
```
GET /health/query
Response: { "status": "ok", "api_key_valid": true, "rate_limit_remaining": 95 }
```

### MediaEngine Health
```
GET /health/media
Response: { "status": "ok", "api_key_valid": true, "rate_limit_remaining": 45 }
```

### InsightEngine Health
```
GET /health/insight
Response: { "status": "ok", "db_connected": true, "query_time_ms": 45 }
```

### ReportEngine Health
```
GET /health/report
Response: { "status": "ok", "storage_writable": true, "templates_available": 12 }
```

### ForumEngine Health
```
GET /health/forum
Response: { "status": "ok", "llm_available": true, "rate_limit_remaining": 28 }
```

---

*Robustness Checks | Sentiment Analysis Team | Intelligence Department | AI Company v1.0.4*
