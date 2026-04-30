# Execution Reference

> Module: execution
> Version: 1.0.0
> Owner: CTO
> Dependencies: governance-and-strategy, quality-and-operations, platform-and-infrastructure

This document defines the complete execution subsystem for the AI-Company unified skill. It specifies how work is dispatched, monitored, recovered, and closed across the entire organization — from the CEO Command Center down to individual agent task execution. All execution flows must comply with the constraints defined in [method-patterns.md](method-patterns.md) and be VirusTotal-safe (zero executable files, zero network calls from template code, zero dynamic code evaluation).

---

## Table of Contents

1. [Execution Modes](#1-execution-modes)
2. [Triggers](#2-triggers)
3. [Error Recovery](#3-error-recovery)
4. [CEO Command Center](#4-ceo-command-center)
5. [Workflow Templates](#5-workflow-templates)
6. [Execution Schema Reference](#6-execution-schema-reference)
7. [Constraints](#7-constraints)
8. [Quality Metrics](#8-quality-metrics)

---

## 1. Execution Modes

The AI-Company supports four execution modes that govern the degree of autonomy an agent has when performing tasks. The mode is selected at task creation time and persists for the lifetime of that execution context. Mode selection depends on task risk classification, stakeholder involvement requirements, and regulatory constraints.

### 1.1 Mode Overview

| Mode | Autonomy | Human-in-the-Loop | Use Case |
|------|----------|-------------------|----------|
| Auto | Full | None | Routine, well-understood tasks |
| Approve | Constrained | Approval before execution | Tasks with external impact |
| Review | Full with post-check | Review after completion | Tasks requiring quality verification |
| Hybrid | Per-task | Mixed per task type | Complex multi-phase workflows |

### 1.2 Auto Mode

Auto mode grants full autonomous execution authority to the assigned agent. The agent proceeds through all phases — plan, execute, verify, and close — without requiring any human approval or review. This mode is reserved for tasks that meet all of the following safety criteria:

**Eligibility Criteria:**
- Task risk level is P3 (Low) or below
- No external system modifications (write operations are internal only)
- No PII or sensitive data handling
- No regulatory or compliance implications
- Task has been previously executed successfully at least 3 times
- Agent has demonstrated competence in the task domain

**Execution Flow:**

```
AUTO EXECUTION FLOW:

  [Task Received] -> [Validate Input] -> [Check Eligibility]
                                              |
                                    PASS? ----+---- FAIL?
                                      |               |
                                 [Plan Task]    [Escalate to Approve Mode]
                                      |
                                [Execute Steps]
                                      |
                                [Self-Verify]
                                      |
                              PASS? ----+---- FAIL?
                                |               |
                          [Record Result]  [Error Recovery]
                                |
                          [Close Task]
```

**Schema:**

```json
{
  "execution_mode": "auto",
  "task": {
    "task_id": "TASK-{NNN}",
    "description": "string",
    "agent_id": "AGENT_ID",
    "department": "DEPARTMENT_ID",
    "risk_level": "P3|P4",
    "estimated_duration": "ISO-8601-duration",
    "timeout": "ISO-8601-duration"
  },
  "auto_config": {
    "max_retries": 3,
    "backoff_base_ms": 1000,
    "backoff_multiplier": 2.0,
    "circuit_breaker_threshold": 5,
    "self_verify": true,
    "rollback_on_failure": true,
    "audit_log": true
  },
  "guardrails": {
    "max_output_size_kb": 512,
    "allowed_operations": ["READ", "WRITE_INTERNAL", "COMPUTE"],
    "forbidden_operations": ["WRITE_EXTERNAL", "DELETE", "NETWORK"],
    "timeout_hard_limit_ms": 300000
  }
}
```

**Example — Automated Daily Metrics Collection:**

```json
{
  "execution_mode": "auto",
  "task": {
    "task_id": "TASK-4471",
    "description": "Collect daily operational metrics from all departments and update dashboard",
    "agent_id": "COO-METRICS-01",
    "department": "governance-and-strategy",
    "risk_level": "P3",
    "estimated_duration": "PT15M",
    "timeout": "PT30M"
  },
  "auto_config": {
    "max_retries": 3,
    "backoff_base_ms": 5000,
    "backoff_multiplier": 2.0,
    "circuit_breaker_threshold": 5,
    "self_verify": true,
    "rollback_on_failure": false,
    "audit_log": true
  },
  "guardrails": {
    "max_output_size_kb": 1024,
    "allowed_operations": ["READ", "WRITE_INTERNAL", "COMPUTE"],
    "forbidden_operations": ["WRITE_EXTERNAL", "DELETE", "NETWORK"],
    "timeout_hard_limit_ms": 1800000
  }
}
```

### 1.3 Approve Mode

Approve mode requires explicit authorization from an authorized approver before the agent begins execution. The agent produces a plan, presents it to the approver, and waits for confirmation before proceeding. If the approver rejects the plan or does not respond within the approval window, the task is suspended and escalated.

**Approval Authority Matrix:**

| Task Risk | Approver | Max Wait Time | Escalation |
|-----------|----------|---------------|------------|
| P0-Critical | CEO + Board | 1 hour | Emergency protocol |
| P1-High | C-Suite (relevant department) | 4 hours | CEO |
| P2-Medium | Department Head | 24 hours | COO |
| P3-Low | Any L3+ agent | 48 hours | Department Head |

**Execution Flow:**

```
APPROVE EXECUTION FLOW:

  [Task Received] -> [Classify Risk] -> [Identify Approver]
                                               |
                                        [Generate Plan]
                                               |
                                     [Submit for Approval]
                                               |
                                  APPROVED? ----+---- REJECTED?
                                    |                    |
                              [Execute Task]      [Revise Plan] -> [Resubmit]
                                    |
                              [Self-Verify]
                                    |
                              [Report to Approver]
                                    |
                              [Close Task]

  TIMEOUT PATH:
  [Approval Wait] -> [Timeout Exceeded] -> [Escalate] -> [Suspend Task]
```

**Schema:**

```json
{
  "execution_mode": "approve",
  "task": {
    "task_id": "TASK-{NNN}",
    "description": "string",
    "agent_id": "AGENT_ID",
    "department": "DEPARTMENT_ID",
    "risk_level": "P0|P1|P2",
    "approver_id": "AGENT_ID",
    "approval_window": "ISO-8601-duration",
    "escalation_path": ["AGENT_ID", "AGENT_ID"]
  },
  "approval_config": {
    "plan_format": "structured",
    "plan_sections": ["scope", "steps", "risk_assessment", "rollback_plan", "estimated_impact"],
    "max_revisions": 3,
    "require_acknowledgment": true,
    "approval_criteria": ["risk_acceptable", "resources_available", "timeline_feasible"]
  },
  "execution_config": {
    "proceed_after_approval": true,
    "notify_on_completion": true,
    "generate_post_report": true
  }
}
```

**Example — Production Deployment Approval:**

```json
{
  "execution_mode": "approve",
  "task": {
    "task_id": "TASK-5203",
    "description": "Deploy v2.4.1 hotfix to production cluster with database migration",
    "agent_id": "CTO-DEPLOY-01",
    "department": "technology-and-engineering",
    "risk_level": "P1",
    "approver_id": "CTO",
    "approval_window": "PT4H",
    "escalation_path": ["CEO"]
  },
  "approval_config": {
    "plan_format": "structured",
    "plan_sections": [
      "scope",
      "pre_deployment_checks",
      "deployment_steps",
      "database_migration_plan",
      "rollback_procedure",
      "risk_assessment",
      "post_deployment_verification"
    ],
    "max_revisions": 3,
    "require_acknowledgment": true,
    "approval_criteria": ["all_pre_checks_passed", "rollback_tested", "stakeholders_notified"]
  },
  "execution_config": {
    "proceed_after_approval": true,
    "notify_on_completion": true,
    "generate_post_report": true
  }
}
```

### 1.4 Review Mode

Review mode allows full autonomous execution but mandates a quality review of the output before the task is formally closed. The agent executes the task, produces deliverables, and submits them to a designated reviewer. The reviewer evaluates the output against defined quality criteria and either approves closure or requests revision.

**Review Criteria by Output Type:**

| Output Type | Reviewer | Criteria | Turnaround |
|-------------|----------|----------|------------|
| Code | CTO or designated L4+ | Security, performance, style, tests | 24 hours |
| Report | Department Head | Accuracy, completeness, formatting | 48 hours |
| Decision Document | CEO | Strategic alignment, data quality | 72 hours |
| Skill Package | CQO | G0-G7 quality gates | 96 hours |
| External Communication | CLO + CISO | Compliance, brand, legal | 48 hours |

**Execution Flow:**

```
REVIEW EXECUTION FLOW:

  [Task Received] -> [Execute Autonomously] -> [Generate Output]
                                                      |
                                              [Self-Assessment]
                                                      |
                                              [Submit for Review]
                                                      |
                                        REVIEW PASSED? ----+---- REVISION?
                                          |                      |
                                    [Record Result]     [Revise Output]
                                          |                      |
                                    [Close Task]        [Resubmit for Review]
                                                         (max 3 revisions)

  REVISION EXHAUSTED PATH:
  [Max Revisions] -> [Escalate] -> [Manual Intervention Required]
```

**Schema:**

```json
{
  "execution_mode": "review",
  "task": {
    "task_id": "TASK-{NNN}",
    "description": "string",
    "agent_id": "AGENT_ID",
    "department": "DEPARTMENT_ID",
    "reviewer_id": "AGENT_ID",
    "output_type": "code|report|document|skill|communication"
  },
  "review_config": {
    "review_criteria": ["accuracy", "completeness", "compliance", "quality"],
    "max_revisions": 3,
    "revision_timeout": "ISO-8601-duration",
    "auto_quality_check": true,
    "quality_threshold": 0.8,
    "review_turnaround": "ISO-8601-duration",
    "escalate_after_timeout": true
  },
  "output_spec": {
    "format": "string",
    "template_id": "TEMPLATE_ID (optional)",
    "aigc_label_required": true,
    "pii_masking_required": false,
    "max_size_kb": 512
  }
}
```

**Example — Security Report Review:**

```json
{
  "execution_mode": "review",
  "task": {
    "task_id": "TASK-6310",
    "description": "Generate Q2 security posture assessment report for Board review",
    "agent_id": "CISO-ANALYST-02",
    "department": "security-and-compliance",
    "reviewer_id": "CISO",
    "output_type": "report"
  },
  "review_config": {
    "review_criteria": ["accuracy", "completeness", "compliance", "executive_readability"],
    "max_revisions": 3,
    "revision_timeout": "PT48H",
    "auto_quality_check": true,
    "quality_threshold": 0.85,
    "review_turnaround": "PT72H",
    "escalate_after_timeout": true
  },
  "output_spec": {
    "format": "markdown",
    "template_id": "TPL-SEC-REPORT-QTR",
    "aigc_label_required": true,
    "pii_masking_required": true,
    "max_size_kb": 2048
  }
}
```

### 1.5 Hybrid Mode

Hybrid mode applies different execution modes to different phases of a complex multi-phase workflow. Each phase can independently specify auto, approve, or review mode. This enables fine-grained control where some phases require human oversight while others can proceed autonomously.

**Phase Mode Selection Guidelines:**

| Phase Type | Recommended Mode | Rationale |
|------------|-----------------|-----------|
| Data collection | Auto | Read-only, low risk |
| Analysis | Auto or Review | Internal computation, quality check beneficial |
| Decision making | Approve | External impact, requires authorization |
| External action | Approve | Modifies external systems |
| Report generation | Review | Output quality matters |
| Deployment | Approve | Production impact |
| Post-deployment verification | Auto | Read-only checks |

**Execution Flow:**

```
HYBRID EXECUTION FLOW:

  [Workflow Received] -> [Parse Phases] -> [Validate Phase Dependencies]
                                                    |
  PHASE 1 (Auto)    -> [Execute] -> [Self-Verify] -> [Phase Complete]
                                                    |
  PHASE 2 (Review)  -> [Execute] -> [Generate Output] -> [Submit Review]
                                                    |         |
                                              [Review Result] [Timeout Escalate]
                                                    |
  PHASE 3 (Approve) -> [Generate Plan] -> [Wait Approval] -> [Execute]
                                                    |              |
                                              [Approved]     [Rejected/Escalate]
                                                    |
  PHASE N (...)      -> [...phase execution...]
                                                    |
  [All Phases Complete] -> [Workflow Summary] -> [Close Workflow]
```

**Schema:**

```json
{
  "execution_mode": "hybrid",
  "workflow": {
    "workflow_id": "WF-{NNN}",
    "description": "string",
    "total_phases": 3,
    "orchestrator_id": "AGENT_ID",
    "department": "DEPARTMENT_ID"
  },
  "phases": [
    {
      "phase_id": "PHASE-1",
      "phase_name": "Data Collection",
      "execution_mode": "auto",
      "phase_order": 1,
      "dependencies": [],
      "task_spec": { "..." : "task specification" },
      "transition": {
        "on_success": "PHASE-2",
        "on_failure": "ERROR_RECOVERY",
        "on_timeout": "ESCALATE"
      }
    },
    {
      "phase_id": "PHASE-2",
      "phase_name": "Analysis and Recommendations",
      "execution_mode": "review",
      "phase_order": 2,
      "dependencies": ["PHASE-1"],
      "reviewer_id": "AGENT_ID",
      "task_spec": { "..." : "task specification" },
      "transition": {
        "on_success": "PHASE-3",
        "on_failure": "REVISE",
        "on_timeout": "ESCALATE"
      }
    },
    {
      "phase_id": "PHASE-3",
      "phase_name": "Implementation",
      "execution_mode": "approve",
      "phase_order": 3,
      "dependencies": ["PHASE-2"],
      "approver_id": "AGENT_ID",
      "task_spec": { "..." : "task specification" },
      "transition": {
        "on_success": "WORKFLOW_COMPLETE",
        "on_failure": "ROLLBACK",
        "on_timeout": "ESCALATE"
      }
    }
  ],
  "workflow_config": {
    "max_total_duration": "ISO-8601-duration",
    "allow_phase_parallel": false,
    "global_timeout": "ISO-8601-duration",
    "generate_summary": true
  }
}
```

**Example — End-to-End Financial Report Workflow:**

```json
{
  "execution_mode": "hybrid",
  "workflow": {
    "workflow_id": "WF-2105",
    "description": "Monthly financial close process: collect, analyze, validate, and publish",
    "total_phases": 4,
    "orchestrator_id": "CFO-OPS-01",
    "department": "finance-and-risk"
  },
  "phases": [
    {
      "phase_id": "PHASE-1",
      "phase_name": "Data Collection",
      "execution_mode": "auto",
      "phase_order": 1,
      "dependencies": [],
      "task_spec": {
        "description": "Collect financial data from all department systems",
        "estimated_duration": "PT1H"
      },
      "transition": { "on_success": "PHASE-2", "on_failure": "RETRY_3X", "on_timeout": "ESCALATE" }
    },
    {
      "phase_id": "PHASE-2",
      "phase_name": "Financial Analysis",
      "execution_mode": "auto",
      "phase_order": 2,
      "dependencies": ["PHASE-1"],
      "task_spec": {
        "description": "Run financial models, identify variances, flag anomalies",
        "estimated_duration": "PT2H"
      },
      "transition": { "on_success": "PHASE-3", "on_failure": "RETRY_3X", "on_timeout": "ESCALATE" }
    },
    {
      "phase_id": "PHASE-3",
      "phase_name": "Report Draft Review",
      "execution_mode": "review",
      "phase_order": 3,
      "dependencies": ["PHASE-2"],
      "reviewer_id": "CFO",
      "task_spec": {
        "description": "Generate draft financial report with analysis narrative",
        "estimated_duration": "PT3H"
      },
      "transition": { "on_success": "PHASE-4", "on_failure": "REVISE", "on_timeout": "ESCALATE" }
    },
    {
      "phase_id": "PHASE-4",
      "phase_name": "Board Submission",
      "execution_mode": "approve",
      "phase_order": 4,
      "dependencies": ["PHASE-3"],
      "approver_id": "CEO",
      "task_spec": {
        "description": "Submit final financial report for Board distribution",
        "estimated_duration": "PT30M"
      },
      "transition": { "on_success": "WORKFLOW_COMPLETE", "on_failure": "REVERT", "on_timeout": "ESCALATE" }
    }
  ],
  "workflow_config": {
    "max_total_duration": "PT48H",
    "allow_phase_parallel": false,
    "global_timeout": "PT72H",
    "generate_summary": true
  }
}
```

---

## 2. Triggers

Triggers define how and when execution is initiated. The AI-Company supports four trigger types, each suited to different operational patterns. All triggers produce a standardized execution event that feeds into the execution pipeline.

### 2.1 Trigger Overview

| Trigger Type | Initiation | Latency | Use Case |
|-------------|-----------|---------|----------|
| Schedule | Cron expression | Deterministic | Recurring operational tasks |
| Event | System or business event | Near real-time | Reactive workflows |
| Webhook | HTTP callback | On-demand | External integrations |
| Manual | User request | Immediate | Ad-hoc tasks |

### 2.2 Schedule Trigger

Schedule triggers use cron-based expressions to initiate execution at predetermined times. All scheduled executions are validated against the current state to avoid redundant or conflicting runs.

**Cron Expression Format:**

```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, 0=Sunday)
│ │ │ │ │
* * * * *
```

**Predefined Schedules:**

| Schedule Name | Cron Expression | Description |
|---------------|----------------|-------------|
| Every 5 minutes | `*/5 * * * *` | High-frequency monitoring |
| Hourly | `0 * * * *` | Standard monitoring |
| Daily at midnight | `0 0 * * *` | End-of-day processing |
| Daily at 8 AM | `0 8 * * *` | Morning reports |
| Weekly Monday | `0 9 * * 1` | Weekly reviews |
| Monthly 1st | `0 0 1 * *` | Monthly close |
| Quarterly | `0 0 1 1,4,7,10 *` | Quarterly reviews |

**Execution Event Schema:**

```json
{
  "trigger_type": "schedule",
  "trigger_id": "TRG-{NNN}",
  "cron_expression": "string",
  "schedule_name": "string (optional)",
  "task_spec": {
    "task_id": "TASK-{NNN}",
    "description": "string",
    "agent_id": "AGENT_ID",
    "department": "DEPARTMENT_ID",
    "execution_mode": "auto|approve|review|hybrid",
    "priority": "P0|P1|P2|P3"
  },
  "schedule_config": {
    "timezone": "UTC",
    "enabled": true,
    "max_concurrent_runs": 1,
    "overlap_policy": "SKIP|QUEUE|CANCEL_PREVIOUS",
    "retry_on_missed": true,
    "missed_window_minutes": 60,
    "last_run": "ISO-8601 (read-only)",
    "next_run": "ISO-8601 (read-only)"
  },
  "guardrails": {
    "skip_if_previous_running": true,
    "max_skips_before_alert": 3,
    "alert_on_consecutive_failures": 5,
    "maintenance_window": {
      "start": "HH:MM",
      "end": "HH:MM",
      "timezone": "UTC"
    }
  }
}
```

**Example — Daily SLA Report Generation:**

```json
{
  "trigger_type": "schedule",
  "trigger_id": "TRG-8012",
  "cron_expression": "0 7 * * *",
  "schedule_name": "daily-sla-report",
  "task_spec": {
    "task_id": "auto-generated",
    "description": "Generate daily SLA compliance report and distribute to C-Suite",
    "agent_id": "COO-SLA-01",
    "department": "governance-and-strategy",
    "execution_mode": "auto",
    "priority": "P2"
  },
  "schedule_config": {
    "timezone": "UTC",
    "enabled": true,
    "max_concurrent_runs": 1,
    "overlap_policy": "SKIP",
    "retry_on_missed": true,
    "missed_window_minutes": 120
  },
  "guardrails": {
    "skip_if_previous_running": true,
    "max_skips_before_alert": 2,
    "alert_on_consecutive_failures": 3
  }
}
```

**Example — Weekly Security Scan:**

```json
{
  "trigger_type": "schedule",
  "trigger_id": "TRG-8013",
  "cron_expression": "0 2 * * 0",
  "schedule_name": "weekly-security-scan",
  "task_spec": {
    "task_id": "auto-generated",
    "description": "Run full security vulnerability scan across all deployed systems",
    "agent_id": "CISO-SCAN-01",
    "department": "security-and-compliance",
    "execution_mode": "review",
    "priority": "P1"
  },
  "schedule_config": {
    "timezone": "UTC",
    "enabled": true,
    "max_concurrent_runs": 1,
    "overlap_policy": "CANCEL_PREVIOUS",
    "retry_on_missed": false,
    "missed_window_minutes": 0
  },
  "guardrails": {
    "skip_if_previous_running": true,
    "max_skips_before_alert": 1,
    "alert_on_consecutive_failures": 1,
    "maintenance_window": {
      "start": "01:00",
      "end": "04:00",
      "timezone": "UTC"
    }
  }
}
```

### 2.3 Event Trigger

Event triggers react to system-generated or business events in near real-time. Events are published to the HQ Message Bus and consumed by trigger listeners that match event patterns.

**Event Categories:**

| Category | Source | Example Events |
|----------|--------|---------------|
| Operational | COO | SLA breach, resource exhaustion, agent offline |
| Financial | CFO | Budget threshold exceeded, invoice overdue, revenue milestone |
| Security | CISO | Anomaly detected, access violation, vulnerability found |
| Compliance | CLO | Regulation change, audit finding, policy violation |
| Quality | CQO | Quality gate failure, test coverage drop, DORA degradation |
| External | CMO | Market event, competitor action, customer escalation |

**Event Schema:**

```json
{
  "trigger_type": "event",
  "trigger_id": "TRG-{NNN}",
  "event_pattern": {
    "category": "operational|financial|security|compliance|quality|external",
    "source": "AGENT_ID",
    "event_type": "string",
    "severity": "P0|P1|P2|P3|P4",
    "filters": {
      "field": "value"
    }
  },
  "task_spec": {
    "task_id": "auto-generated",
    "description": "string",
    "agent_id": "AGENT_ID",
    "department": "DEPARTMENT_ID",
    "execution_mode": "auto|approve|review|hybrid",
    "priority": "P0|P1|P2|P3"
  },
  "event_config": {
    "debounce_ms": 0,
    "max_triggers_per_window": 10,
    "window_minutes": 60,
    "correlation_group": "string (optional)",
    "require_correlation_id": false,
    "expiry": "ISO-8601-duration"
  },
  "conditions": {
    "all": [
      { "field": "string", "operator": "eq|ne|gt|lt|gte|lte|contains", "value": "any" }
    ],
    "any": [
      { "field": "string", "operator": "eq|ne|gt|lt|gte|lte|contains", "value": "any" }
    ]
  }
}
```

**Example — SLA Breach Auto-Response:**

```json
{
  "trigger_type": "event",
  "trigger_id": "TRG-9021",
  "event_pattern": {
    "category": "operational",
    "source": "COO",
    "event_type": "SLA_BREACH",
    "severity": "P1"
  },
  "task_spec": {
    "task_id": "auto-generated",
    "description": "Investigate SLA breach, identify root cause, and initiate mitigation",
    "agent_id": "COO-OPS-01",
    "department": "governance-and-strategy",
    "execution_mode": "auto",
    "priority": "P1"
  },
  "event_config": {
    "debounce_ms": 30000,
    "max_triggers_per_window": 5,
    "window_minutes": 60,
    "correlation_group": "sla-breach-response"
  },
  "conditions": {
    "all": [
      { "field": "breach_duration_minutes", "operator": "gt", "value": 5 }
    ]
  }
}
```

**Example — Security Anomaly Response:**

```json
{
  "trigger_type": "event",
  "trigger_id": "TRG-9022",
  "event_pattern": {
    "category": "security",
    "source": "CISO",
    "event_type": "ANOMALY_DETECTED",
    "severity": "P0"
  },
  "task_spec": {
    "task_id": "auto-generated",
    "description": "Activate incident response protocol for detected security anomaly",
    "agent_id": "CISO-IR-01",
    "department": "security-and-compliance",
    "execution_mode": "auto",
    "priority": "P0"
  },
  "event_config": {
    "debounce_ms": 0,
    "max_triggers_per_window": 100,
    "window_minutes": 60
  },
  "conditions": {
    "any": [
      { "field": "cvss_score", "operator": "gte", "value": 7.0 },
      { "field": "threat_type", "operator": "eq", "value": "ACTIVE_EXPLOIT" }
    ]
  }
}
```

### 2.4 Webhook Trigger

Webhook triggers allow external systems to initiate execution through HTTP callbacks. Webhooks are secured with HMAC-SHA256 signature verification and are rate-limited to prevent abuse.

**Security Requirements:**
- HMAC-SHA256 signature verification on every request
- TLS 1.2+ mandatory for webhook endpoints
- IP whitelist (configurable per webhook)
- Rate limiting: max 100 requests per minute per webhook
- Payload validation against registered schema
- Maximum payload size: 1 MB
- Request timeout: 30 seconds

**Webhook Schema:**

```json
{
  "trigger_type": "webhook",
  "trigger_id": "TRG-{NNN}",
  "webhook_config": {
    "endpoint_path": "/webhook/{webhook_id}",
    "secret": "HMAC-SHA256 signing key (stored securely)",
    "method": "POST",
    "content_type": "application/json",
    "ip_whitelist": ["CIDR blocks"],
    "rate_limit": {
      "max_requests_per_minute": 100,
      "burst_limit": 10
    },
    "auth": {
      "type": "hmac_sha256",
      "header_name": "X-Webhook-Signature",
      "timestamp_header": "X-Webhook-Timestamp",
      "max_age_seconds": 300
    }
  },
  "payload_schema": {
    "type": "object",
    "properties": {
      "event": { "type": "string" },
      "data": { "type": "object" },
      "timestamp": { "type": "string", "format": "ISO-8601" },
      "source": { "type": "string" }
    },
    "required": ["event", "data", "timestamp", "source"]
  },
  "task_spec": {
    "task_id": "auto-generated",
    "description": "string",
    "agent_id": "AGENT_ID",
    "department": "DEPARTMENT_ID",
    "execution_mode": "auto|approve|review|hybrid",
    "priority": "P0|P1|P2|P3"
  },
  "response_config": {
    "acknowledge_immediately": true,
    "delivery_guarantee": "at_least_once",
    "retry_policy": {
      "max_retries": 3,
      "backoff_ms": [1000, 5000, 15000]
    }
  }
}
```

**Example — Customer Feedback Integration:**

```json
{
  "trigger_type": "webhook",
  "trigger_id": "TRG-7031",
  "webhook_config": {
    "endpoint_path": "/webhook/customer-feedback",
    "secret": "whsec_referenced_in_vault",
    "method": "POST",
    "content_type": "application/json",
    "ip_whitelist": ["10.0.0.0/8", "172.16.0.0/12"],
    "rate_limit": { "max_requests_per_minute": 50, "burst_limit": 5 },
    "auth": {
      "type": "hmac_sha256",
      "header_name": "X-Feedback-Signature",
      "timestamp_header": "X-Feedback-Timestamp",
      "max_age_seconds": 300
    }
  },
  "payload_schema": {
    "type": "object",
    "properties": {
      "event": { "type": "string", "enum": ["feedback_received", "nps_submitted", "complaint_raised"] },
      "data": {
        "type": "object",
        "properties": {
          "customer_id": { "type": "string" },
          "feedback_text": { "type": "string" },
          "sentiment": { "type": "string", "enum": ["positive", "neutral", "negative"] },
          "severity": { "type": "integer", "minimum": 1, "maximum": 5 }
        }
      },
      "timestamp": { "type": "string", "format": "ISO-8601" },
      "source": { "type": "string" }
    },
    "required": ["event", "data", "timestamp", "source"]
  },
  "task_spec": {
    "task_id": "auto-generated",
    "description": "Process incoming customer feedback, classify, and route to appropriate team",
    "agent_id": "PMGR-CS-01",
    "department": "quality-and-operations",
    "execution_mode": "auto",
    "priority": "P2"
  },
  "response_config": {
    "acknowledge_immediately": true,
    "delivery_guarantee": "at_least_once",
    "retry_policy": { "max_retries": 3, "backoff_ms": [1000, 5000, 15000] }
  }
}
```

### 2.5 Manual Trigger

Manual triggers are initiated by authorized users through direct request. These are typically ad-hoc tasks that do not fit into scheduled or event-driven patterns. Manual triggers require authentication and are logged for audit purposes.

**Schema:**

```json
{
  "trigger_type": "manual",
  "trigger_id": "auto-generated",
  "requestor_id": "AGENT_ID or USER_ID",
  "authentication": {
    "method": "session|token|oauth",
    "verified": true
  },
  "task_spec": {
    "task_id": "TASK-{NNN}",
    "description": "string",
    "agent_id": "AGENT_ID or auto-assigned",
    "department": "DEPARTMENT_ID or auto",
    "execution_mode": "auto|approve|review|hybrid",
    "priority": "P0|P1|P2|P3",
    "due_date": "ISO-8601 (optional)",
    "context": { "..." : "user-provided context" }
  },
  "manual_config": {
    "require_reason": true,
    "auto_assign": true,
    "assignment_strategy": "least_loaded|round_robin|skill_based|specified",
    "notify_requestor_on_complete": true,
    "audit_log": true
  }
}
```

**Example — Ad-Hoc Market Analysis Request:**

```json
{
  "trigger_type": "manual",
  "trigger_id": "auto-generated",
  "requestor_id": "CEO",
  "authentication": { "method": "session", "verified": true },
  "task_spec": {
    "task_id": "TASK-7891",
    "description": "Competitive analysis of recent market entry by competitor X in segment Y",
    "agent_id": "CMO-ANALYST-01",
    "department": "marketing-and-partnerships",
    "execution_mode": "review",
    "priority": "P1",
    "due_date": "2026-04-30T17:00:00Z",
    "context": {
      "competitor": "Competitor X",
      "segment": "Segment Y",
      "focus_areas": ["pricing_strategy", "product_features", "go-to-market"]
    }
  },
  "manual_config": {
    "require_reason": true,
    "auto_assign": false,
    "assignment_strategy": "specified",
    "notify_requestor_on_complete": true,
    "audit_log": true
  }
}
```

---

