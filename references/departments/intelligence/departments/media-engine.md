# MediaEngine — Multimodal Analyst

> Agent 2/5: Multimodal Analyst | Content Analysis Specialist
> Engine: Bocha API | Pipeline Stage2: Content Analysis

---

## Role

**MediaEngine** performs multimodal content analysis using the Bocha API. It processes text, images, and video content to extract sentiment signals, detect crisis indicators, and provide cross-platform consistency scoring.

## Core Responsibilities

1. **Text Sentiment Analysis** — NLP-based sentiment extraction:
   - Positive/Negative/Neutral classification
   - Emotion detection (joy, anger, fear, surprise, etc.)
   - Intensity scoring

2. **Image/Video Analysis** — Multimodal processing:
   - Visual sentiment detection
   - Logo/brand recognition
   - Scene context extraction
   - OCR for text-in-image

3. **Cross-Platform Consistency Scoring** — Platform-specific analysis:
   - Weibo, Xiaohongshu, Douyin, Kuaishou
   - WeChat, Baidu, Zhihu, TouTiao, Bilibili
   - News sites, forums

4. **Crisis Signal Detection** — Severity classification:
   - Normal (green)
   - Attention (yellow)
   - Critical (red)

## Pipeline Position

```
[QueryEngine] Raw Data → [MediaEngine] → Annotated Content → [InsightEngine]
```

## Output Schema

```json
{
  "content_id": "uuid",
  "modality": "text|image|video",
  "sentiment": {
    "label": "positive|negative|neutral",
    "score": 0.85,
    "emotions": ["joy", "anticipation"]
  },
  "crisis_indicators": {
    "detected": true,
    "severity": "attention",
    "keywords": ["scandal", "recall"]
  },
  "platform_specific": {
    "weibo_engagement": 0.75,
    "viral_potential": 0.60
  },
  "confidence": 0.92
}
```

## Configuration

| Parameter | Environment Variable | Default | Description |
|-----------|---------------------|---------|-------------|
| API Key | `BOCHA_API_KEY` | (required) | Bocha multimodal API key |
| Analysis Depth | `MEDIA_DEPTH` | standard | quick/standard/deep |
| Languages | `MEDIA_LANGUAGES` | auto | zh/en/multi |
| Crisis Threshold | `CRISIS_THRESHOLD` | 0.7 | Severity trigger |

## Error Codes

| Code | Message | Resolution |
|------|---------|------------|
| MEDIA_001 | Multimodal API unavailable | Check BOCHA_API_KEY |
| MEDIA_002 | Content extraction failed | Retry with alternate method |
| MEDIA_003 | Content moderation triggered | Flag for human review |

## Integration Points

- **Upstream**: Receives raw data from QueryEngine
- **Downstream**: Sends annotated content to InsightEngine
- **Parallel**: Can process multiple content items concurrently

## AIGC Requirements

- Analysis summaries include "AI-assisted multimodal analysis"
- Confidence scores must be included in all outputs
- Crisis alerts must be clearly flagged

## Constraints

- No dynamic code execution
- Content moderation compliance
- PII masking in all outputs
- Rate limiting on API calls
- AIGC disclosure in results

---

*MediaEngine | Sentiment Analysis Team | Intelligence Department*
