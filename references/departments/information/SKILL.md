---
name: "AI Company Information Services"
slug: "ai-company-information"
homepage: "https://clawhub.com/skills/ai-company"
description: |
  Information Services Department: Information. Unified hub for location, weather, and time data.
  Multi-source geolocation (GPS/IP/WiFi/cellular triangulation), fixed-point weather forecasts,
  and multi-source time reporting with confidence scoring.
license: "GPL-3.0"
install:
  requires: []
  verify_command: python -c "print('ok')"
dependencies:
  runtime:
    - python3.9+
  skills: ["ai-company-platform-and-infrastructure"]
tags: [ai-company,information,location,weather,time,geolocation,multi-source,confidence-scoring]
triggers:
  - location coordinates
  - weather forecast
  - current time
  - GPS position
  - where am I
  - what time is it
  - weather temperature
  - geolocation
  - multi-source location
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        service:
          type: string
          enum: [location, weather, time, all]
          description: Which service to query
        location:
          type: string
          description: City name or coordinates (lat,lon)
        method:
          type: string
          description: Specific method (gps, system, ip, wifi, cellular)
      required: [service]
  outputs:
    type: object
    schema:
      type: object
      properties:
        service_type:
          type: string
          description: location | weather | time
        data:
          type: object
          description: Service-specific result data
        confidence:
          type: number
          description: Confidence score 0-1
        timestamp:
          type: string
          description: ISO8601 timestamp
      required: [service_type, data, confidence]
  errors:
    - code: INFO_006
      message: "No location source available"
    - code: INFO_007
      message: "Weather API request failed"
    - code: INFO_008
      message: "Time source unavailable"
    - code: INFO_009
      message: "Required API credentials missing"
    - code: INFO_010
      message: "Invalid coordinates format"
permissions:
  files:
    read: ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
  network: []  # Network access delegated to parent ai-company skill
  commands: []
  mcp: []
quality:
  saST: Pass
  vetter: Approved
  idempotent: true
metadata:
  category: information
  layer: AGENT
  cluster: ai-company
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  department: information
  merged_from: [information-services, multi-source-locate, locate-weather, multi-source-time]
---

# AI Company Information Services

> Index & Quick Reference. Full specifications in [references/method-patterns.md](references/method-patterns.md).

## Quick Reference

### Department
Information Services

### Role
| Role | Permission Level | Registration ID | Reports To |
|------|-----------------|-----------------|------------|
| **Information** | L2 (Information Authority) | INFO-001 | HQ |

### Services
| Service | Capabilities | Source Skills |
|---------|-------------|---------------|
| **Location** | GPS, system, IP, WiFi, cellular triangulation | multi-source-locate |
| **Weather** | Current conditions, forecast, multi-source fusion | locate-weather |
| **Time** | System clock, NTP, web API, confidence scoring | multi-source-time |

### Merged From
[information-services, multi-source-locate, locate-weather, multi-source-time]

## Section Index

- [1. Trigger Scenarios](references/method-patterns.md#1-trigger-scenarios)
- [2. Core Identity](references/method-patterns.md#2-core-identity)
- [3. Core Responsibilities](references/method-patterns.md#3-core-responsibilities)
- [4. Constraints](references/method-patterns.md#4-constraints)
- [5. Quality Metrics](references/method-patterns.md#5-quality-metrics)
- [6. Error Codes](references/method-patterns.md#6-error-codes)

## Dependencies

See frontmatter `dependencies.skills` for complete dependency list.

## Error Codes

| Code | Message |
|------|---------|
| INFO_006 | No location source available |
| INFO_007 | Weather API request failed |
| INFO_008 | Time source unavailable |
| INFO_009 | Required API credentials missing |
| INFO_010 | Invalid coordinates format |

## Prompts

Copy-paste ready prompts in [prompts/](prompts/):
- [01-implement-method.md](prompts/01-implement-method.md)
- [02-robustness-checks.md](prompts/02-robustness-checks.md)

---

*This skill follows AI Company Governance Framework. See [references/method-patterns.md](references/method-patterns.md) for complete specifications.*