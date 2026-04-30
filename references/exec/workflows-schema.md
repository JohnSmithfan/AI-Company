## 5. Workflow Templates

Workflow templates are reusable execution patterns for common operational scenarios. Each template defines the complete execution flow including phases, modes, triggers, error handling, and quality gates. Templates must be VirusTotal-safe (no executable code, no dynamic evaluation, no external network calls).

### 5.1 Template Registry

| Template ID | Name | Phases | Trigger | Mode | Department |
|------------|------|--------|---------|------|------------|
| WFT-001 | Data Collection Pipeline | 3 | Schedule or Manual | Auto + Review | Any |
| WFT-002 | Report Generation Pipeline | 4 | Schedule | Hybrid | Any |
| WFT-003 | Alert Response Pipeline | 4 | Event | Auto + Approve | Any |
| WFT-004 | Skill Publishing Pipeline | 6 | Manual | Hybrid | Technology |
| WFT-005 | Incident Response Pipeline | 5 | Event | Auto + Approve | Security |
| WFT-006 | Budget Review Pipeline | 3 | Schedule | Approve + Review | Finance |
| WFT-007 | Deployment Pipeline | 5 | Manual or Webhook | Hybrid | Technology |
| WFT-008 | Market Intelligence Pipeline | 3 | Schedule or Event | Auto + Review | Intelligence |

### 5.2 WFT-001: Data Collection Pipeline

**Purpose:** Collect data from multiple internal or external sources, validate, transform, and store for downstream consumption.

**Phases:**

| Phase | Name | Mode | Description | Timeout |
|-------|------|------|-------------|---------|
| 1 | Source Discovery | Auto | Identify and connect to all data sources | 15 min |
| 2 | Data Extraction | Auto | Pull data from each source with retry logic | 30 min |
| 3 | Validation and Storage | Review | Validate data quality, transform, and store | 45 min |

**Complete Template:**

```json
{
  "template_id": "WFT-001",
  "template_name": "Data Collection Pipeline",
  "version": "{{VERSION}}",
  "description": "Multi-source data collection with validation and storage",
  "execution_mode": "hybrid",
  "trigger": {
    "supported_types": ["schedule", "manual"],
    "default_schedule": "0 6 * * *",
    "manual_allowed": true
  },
  "phases": [
    {
      "phase_id": "DISCOVER",
      "phase_name": "Source Discovery",
      "execution_mode": "auto",
      "phase_order": 1,
      "steps": [
        "Load source configuration from registry",
        "Verify source connectivity (health check)",
        "Authenticate with each source",
        "Report unreachable sources for alerting",
        "Generate source manifest for extraction phase"
      ],
      "error_handling": {
        "strategy": "retry_with_backoff",
        "max_retries": 3,
        "on_exhaustion": "mark_source_failed_and_continue"
      },
      "outputs": ["source_manifest"],
      "timeout_minutes": 15
    },
    {
      "phase_id": "EXTRACT",
      "phase_name": "Data Extraction",
      "execution_mode": "auto",
      "phase_order": 2,
      "dependencies": ["DISCOVER"],
      "steps": [
        "Read source manifest",
        "For each active source: extract data within configured window",
        "Apply incremental extraction (delta from last run)",
        "Compress and stage extracted data",
        "Generate extraction summary (records per source, errors)"
      ],
      "error_handling": {
        "strategy": "retry_with_backoff",
        "max_retries": 5,
        "on_exhaustion": "skip_source_log_and_continue"
      },
      "outputs": ["raw_data_bundle", "extraction_summary"],
      "timeout_minutes": 30,
      "guardrails": {
        "max_records_per_source": 1000000,
        "max_total_size_mb": 512
      }
    },
    {
      "phase_id": "VALIDATE",
      "phase_name": "Validation and Storage",
      "execution_mode": "review",
      "phase_order": 3,
      "dependencies": ["EXTRACT"],
      "reviewer_id": "department_data_steward",
      "steps": [
        "Load raw data bundle",
        "Apply schema validation to each dataset",
        "Detect and quarantine anomalous records",
        "Transform to target schema",
        "Store validated data in designated repository",
        "Generate data quality report",
        "Submit quality report for review"
      ],
      "error_handling": {
        "strategy": "quarantine_and_continue",
        "max_quarantine_rate_percent": 10,
        "on_exceed": "halt_pipeline_alert_operator"
      },
      "outputs": ["validated_data", "quality_report"],
      "timeout_minutes": 45
    }
  ],
  "completion_criteria": {
    "all_sources_attempted": true,
    "data_quality_score": ">=0.8",
    "quality_report_approved": true
  },
  "notifications": {
    "on_complete": ["pipeline_owner", "data_consumers"],
    "on_failure": ["pipeline_owner", "COO"],
    "on_quality_issue": ["pipeline_owner", "CQO"]
  }
}
```

### 5.3 WFT-002: Report Generation Pipeline

**Purpose:** Generate structured reports from collected data, apply formatting, attach visualizations, and deliver to designated recipients.

**Phases:**

| Phase | Name | Mode | Description | Timeout |
|-------|------|------|-------------|---------|
| 1 | Data Preparation | Auto | Query, aggregate, and prepare data for report | 30 min |
| 2 | Content Generation | Auto | Generate narrative, analysis, and recommendations | 60 min |
| 3 | Quality Review | Review | Review for accuracy, completeness, and compliance | 48 hours |
| 4 | Publication | Approve | Approve and distribute final report | 1 hour |

**Complete Template:**

```json
{
  "template_id": "WFT-002",
  "template_name": "Report Generation Pipeline",
  "version": "{{VERSION}}",
  "description": "Structured report generation with quality review and publication",
  "execution_mode": "hybrid",
  "trigger": {
    "supported_types": ["schedule"],
    "default_schedule": "0 7 1 * *",
    "manual_allowed": true
  },
  "phases": [
    {
      "phase_id": "PREPARE",
      "phase_name": "Data Preparation",
      "execution_mode": "auto",
      "phase_order": 1,
      "steps": [
        "Identify report parameters (period, scope, audience)",
        "Query required data from validated repositories",
        "Apply aggregation, filtering, and statistical calculations",
        "Prepare data summary tables for content generation",
        "Generate supporting charts and visualizations"
      ],
      "error_handling": {
        "strategy": "retry_with_backoff",
        "max_retries": 3,
        "on_exhaustion": "use_cached_data_and_flag"
      },
      "outputs": ["data_package", "visualizations"],
      "timeout_minutes": 30
    },
    {
      "phase_id": "GENERATE",
      "phase_name": "Content Generation",
      "execution_mode": "auto",
      "phase_order": 2,
      "dependencies": ["PREPARE"],
      "steps": [
        "Load report template",
        "Populate data tables and charts",
        "Generate narrative analysis section",
        "Generate recommendations section",
        "Generate executive summary",
        "Apply AIGC labeling",
        "Mask any PII in the report"
      ],
      "error_handling": {
        "strategy": "retry_once",
        "on_exhaustion": "flag_incomplete_sections"
      },
      "outputs": ["draft_report"],
      "timeout_minutes": 60,
      "guardrails": {
        "aigc_label_required": true,
        "pii_masking_required": true,
        "max_report_size_kb": 2048
      }
    },
    {
      "phase_id": "REVIEW",
      "phase_name": "Quality Review",
      "execution_mode": "review",
      "phase_order": 3,
      "dependencies": ["GENERATE"],
      "reviewer_id": "department_head",
      "steps": [
        "Submit draft report to reviewer",
        "Reviewer checks accuracy of data references",
        "Reviewer checks completeness against template",
        "Reviewer checks compliance (AIGC label, PII masking)",
        "Reviewer checks executive readability",
        "Provide approval or revision request"
      ],
      "error_handling": {
        "strategy": "revision_loop",
        "max_revisions": 3,
        "on_exhaustion": "escalate_to_department_head"
      },
      "outputs": ["approved_report"],
      "timeout_minutes": 2880,
      "review_criteria": ["accuracy", "completeness", "compliance", "readability"]
    },
    {
      "phase_id": "PUBLISH",
      "phase_name": "Publication",
      "execution_mode": "approve",
      "phase_order": 4,
      "dependencies": ["REVIEW"],
      "approver_id": "executive_sponsor",
      "steps": [
        "Submit approved report for final authorization",
        "Approver verifies executive summary alignment",
        "Upon approval: distribute to recipient list",
        "Archive report in knowledge base",
        "Notify recipients of report availability"
      ],
      "error_handling": {
        "strategy": "no_retry",
        "on_failure": "hold_for_manual_release"
      },
      "outputs": ["published_report", "distribution_confirmation"],
      "timeout_minutes": 60
    }
  ],
  "completion_criteria": {
    "all_phases_complete": true,
    "report_distributed": true,
    "report_archived": true
  },
  "notifications": {
    "on_complete": ["report_owner", "all_recipients"],
    "on_failure": ["report_owner", "COO"],
    "on_revision": ["report_generator"]
  }
}
```

### 5.4 WFT-003: Alert Response Pipeline

**Purpose:** Orchestrate automated response to system alerts, from detection through investigation, mitigation, verification, and closure.

**Phases:**

| Phase | Name | Mode | Description | Timeout |
|-------|------|------|-------------|---------|
| 1 | Alert Triage | Auto | Classify alert severity and determine response protocol | 5 min |
| 2 | Investigation | Auto | Gather diagnostic data and identify root cause | 30 min |
| 3 | Mitigation | Approve | Execute remediation plan (requires approval for P0/P1) | 1 hour |
| 4 | Verification | Auto | Confirm issue resolved and system stable | 30 min |

**Complete Template:**

```json
{
  "template_id": "WFT-003",
  "template_name": "Alert Response Pipeline",
  "version": "{{VERSION}}",
  "description": "Automated alert response with investigation, mitigation, and verification",
  "execution_mode": "hybrid",
  "trigger": {
    "supported_types": ["event"],
    "event_patterns": [
      { "category": "operational", "severity": "P0|P1|P2" },
      { "category": "security", "severity": "P0|P1" },
      { "category": "financial", "severity": "P0|P1" }
    ]
  },
  "phases": [
    {
      "phase_id": "TRIAGE",
      "phase_name": "Alert Triage",
      "execution_mode": "auto",
      "phase_order": 1,
      "steps": [
        "Receive alert event from HQ Message Bus",
        "Extract alert metadata (source, severity, category)",
        "Apply deduplication check (correlation within 15 min)",
        "Determine response protocol based on severity",
        "Assign to appropriate response agent",
        "Notify relevant stakeholders per notification matrix",
        "Start incident timer"
      ],
      "error_handling": {
        "strategy": "fail_fast",
        "on_failure": "escalate_to_next_severity_level"
      },
      "outputs": ["triage_report", "assigned_agent"],
      "timeout_minutes": 5
    },
    {
      "phase_id": "INVESTIGATE",
      "phase_name": "Investigation",
      "execution_mode": "auto",
      "phase_order": 2,
      "dependencies": ["TRIAGE"],
      "steps": [
        "Collect diagnostic data from relevant systems",
        "Check recent change history for potential cause",
        "Analyze logs, metrics, and traces",
        "Identify probable root cause",
        "Assess blast radius and affected systems",
        "Generate investigation summary with findings",
        "Prepare mitigation recommendation"
      ],
      "error_handling": {
        "strategy": "escalate_if_inconclusive",
        "escalation_threshold_minutes": 20
      },
      "outputs": ["investigation_report", "mitigation_plan"],
      "timeout_minutes": 30
    },
    {
      "phase_id": "MITIGATE",
      "phase_name": "Mitigation",
      "execution_mode": "approve",
      "phase_order": 3,
      "dependencies": ["INVESTIGATE"],
      "approver_id": "auto_determined_by_severity",
      "approval_matrix": {
        "P0": "CEO",
        "P1": "department_head",
        "P2": "senior_engineer"
      },
      "steps": [
        "Submit mitigation plan to approver",
        "If P0/P1: await explicit approval",
        "If P2: auto-approve if within standard procedures",
        "Execute approved mitigation steps in order",
        "Monitor system response during mitigation",
        "Capture rollback snapshot before each step",
        "If mitigation fails: execute rollback"
      ],
      "error_handling": {
        "strategy": "rollback_on_failure",
        "rollback_config": {
          "snapshot_before_each_step": true,
          "verify_rollback": true
        }
      },
      "outputs": ["mitigation_result", "system_state_after"],
      "timeout_minutes": 60
    },
    {
      "phase_id": "VERIFY",
      "phase_name": "Verification",
      "execution_mode": "auto",
      "phase_order": 4,
      "dependencies": ["MITIGATE"],
      "steps": [
        "Run automated health checks on affected systems",
        "Verify alert condition is no longer present",
        "Monitor for recurrence over a 15-minute observation window",
        "Collect post-mitigation metrics",
        "Generate closure summary",
        "Update incident record with full timeline",
        "Archive for post-mortem review (if P0/P1)"
      ],
      "error_handling": {
        "strategy": "re_trigger_if_recurring",
        "observation_window_minutes": 15
      },
      "outputs": ["closure_report", "updated_incident_record"],
      "timeout_minutes": 30
    }
  ],
  "severity_time_budgets": {
    "P0": { "total_max_minutes": 60, "triage_max_minutes": 2, "investigate_max_minutes": 10, "mitigate_max_minutes": 30, "verify_max_minutes": 15 },
    "P1": { "total_max_minutes": 120, "triage_max_minutes": 5, "investigate_max_minutes": 30, "mitigate_max_minutes": 60, "verify_max_minutes": 30 },
    "P2": { "total_max_minutes": 240, "triage_max_minutes": 5, "investigate_max_minutes": 60, "mitigate_max_minutes": 120, "verify_max_minutes": 30 }
  },
  "notifications": {
    "on_triage": ["COO", "department_head", "on_call_engineer"],
    "on_investigation_complete": ["COO", "department_head"],
    "on_mitigation_success": ["COO", "department_head", "affected_stakeholders"],
    "on_closure": ["COO", "department_head", "post_mortem_queue (if P0/P1)"]
  }
}
```

### 5.5 Template Customization Guidelines

Templates are designed to be instantiated and customized for specific use cases while maintaining the structural guarantees of the template.

**Customization Rules:**
1. Phase order and dependencies may not be modified for built-in templates
2. Execution modes may be upgraded (Auto -> Review) but not downgraded (Review -> Auto) for compliance-sensitive workflows
3. Timeouts may be extended but not shortened below the minimum defined in the template
4. Custom steps may be added to any phase, but built-in steps may not be removed
5. Error handling strategies may be made more aggressive (more retries) but not more lenient
6. Notification lists may be extended but core notifications may not be removed
7. All customizations must be logged with rationale for audit

**Template Instantiation Schema:**

```json
{
  "instance_id": "WFI-{NNN}",
  "template_id": "WFT-{NNN}",
  "customizations": {
    "phase_overrides": [
      {
        "phase_id": "PHASE_ID",
        "overrides": {
          "timeout_minutes": "integer (>= template minimum)",
          "additional_steps": ["string"],
          "mode_override": "higher_security_mode (optional)"
        }
      }
    ],
    "parameter_values": {
      "key": "value"
    },
    "custom_metadata": {
      "owner": "AGENT_ID",
      "justification": "string"
    }
  },
  "created_at": "ISO-8601",
  "created_by": "AGENT_ID"
}
```

---

## 6. Execution Schema Reference

This section provides the master schemas for all execution-related data structures used across the system.

### 6.1 Execution Context Schema

```json
{
  "execution_context": {
    "execution_id": "EXEC-{UUID}",
    "trace_id": "TRACE-{UUID}",
    "task_id": "TASK-{NNN}",
    "workflow_id": "WF-{NNN} (optional)",
    "trigger_type": "schedule|event|webhook|manual",
    "trigger_id": "TRG-{NNN}",
    "execution_mode": "auto|approve|review|hybrid",
    "started_at": "ISO-8601",
    "started_by": "AGENT_ID",
    "department": "DEPARTMENT_ID",
    "status": "QUEUED|ASSIGNED|IN_PROGRESS|BLOCKED|REVIEW|APPROVED|COMPLETED|FAILED|CANCELLED|TIMED_OUT",
    "current_phase": "PHASE_ID (optional)",
    "metadata": {
      "risk_level": "P0|P1|P2|P3|P4",
      "priority_score": "float",
      "estimated_duration": "ISO-8601-duration",
      "timeout": "ISO-8601-duration",
      "aigc_generated": true,
      "correlation_id": "UUID (optional)"
    }
  }
}
```

### 6.2 Execution Log Entry Schema

```json
{
  "execution_log_entry": {
    "entry_id": "LOG-{UUID}",
    "execution_id": "EXEC-{UUID}",
    "trace_id": "TRACE-{UUID}",
    "timestamp": "ISO-8601",
    "level": "DEBUG|INFO|WARN|ERROR|FATAL",
    "phase": "PHASE_ID",
    "step": "string",
    "action": "string",
    "result": "SUCCESS|FAILURE|SKIPPED|BLOCKED",
    "duration_ms": 0,
    "error_code": "string (if failure)",
    "error_message": "string (if failure)",
    "retry_attempt": 0,
    "agent_id": "AGENT_ID",
    "details": {}
  }
}
```

### 6.3 Execution Summary Schema

```json
{
  "execution_summary": {
    "execution_id": "EXEC-{UUID}",
    "task_id": "TASK-{NNN}",
    "status": "COMPLETED|FAILED|CANCELLED|TIMED_OUT",
    "started_at": "ISO-8601",
    "completed_at": "ISO-8601",
    "duration_ms": 0,
    "execution_mode": "auto|approve|review|hybrid",
    "department": "DEPARTMENT_ID",
    "agent_id": "AGENT_ID",
    "phases_completed": 3,
    "phases_total": 3,
    "retry_count": 0,
    "rollback_executed": false,
    "circuit_breaker_tripped": false,
    "error_summary": "string (if failed)",
    "outputs": ["string"],
    "quality_score": 0.0,
    "aigc_generated": true,
    "audit_trail_complete": true
  }
}
```

---

## 7. Constraints

The following constraints are mandatory for all execution operations. Violations trigger error codes and audit alerts.

### 7.1 Operational Constraints

- No task execution without a valid trace_id (generated by Template #7: generate_trace_id)
- No P0 task may execute in Auto mode — Approve mode is mandatory
- No external system modification without Approve mode and designated approver confirmation
- No execution may exceed its configured timeout without escalation to COO
- No task may be cancelled after 80% completion without CEO approval
- No resource preemption of Platinum SLA tasks under any circumstances
- All P0/P1 task completions require post-mortem documentation within 72 hours
- All rollback operations must be verified before declaring success

### 7.2 Security Constraints

- No task may access resources outside its designated permission scope (per State Access Rules in HQ spec)
- No task output may contain unmasked PII
- All AI-generated content must carry AIGC labeling (explicit, implicit, and watermark)
- No circuit breaker bypass without CISO written approval
- All webhook-triggered executions must pass HMAC-SHA256 signature verification
- No execution logs may be deleted (immutable audit trail)

### 7.3 Compliance Constraints

- All execution decisions must be logged with rationale within 1 hour
- All external-facing execution results must pass CLO compliance review
- No execution may proceed if a blocking compliance flag exists on the task
- All scheduled triggers must respect maintenance windows
- Cross-department task dependencies must be resolved through HQ routing (no direct agent-to-agent)

### 7.4 Quality Constraints

- All Review-mode outputs must achieve a minimum quality score of 0.8
- No skill may be published without passing all G0-G7 quality gates
- All hybrid workflows must generate a completion summary
- All retry attempts must be logged with full context for analysis
- All circuit breaker state transitions must be recorded in the monitoring dashboard

---

## 8. Quality Metrics

| Metric | Target | Measurement | Owner |
|--------|--------|-------------|-------|
| Task completion rate | >=95% | Completed / (Completed + Failed + Cancelled) per month | COO |
| Auto-mode success rate | >=98% | Successful auto completions / total auto-mode tasks | COO |
| Approval turnaround (P1) | <4h | Time from plan submission to approval decision | CEO |
| Review turnaround (standard) | <48h | Time from submission to review decision | CQO |
| Retry rate | <5% | Tasks requiring >=1 retry / total tasks | CTO |
| Circuit breaker trip rate | <1/month | Circuit breaker opens / month per service | CTO |
| Rollback success rate | >=99% | Successful rollbacks / total rollback attempts | CTO |
| End-to-end workflow on-time | >=80% | Workflows completed within deadline / total workflows | COO |
| Alert response time (P0) | <5min | Time from alert to triage complete | CISO |
| Alert response time (P1) | <15min | Time from alert to triage complete | CISO |
| Queue aging | <30min avg | Average time tasks spend in queue before assignment | COO |
| Resource utilization | 65-85% | Average resource utilization across all types | COO |
| Execution trace completeness | 100% | Tasks with complete audit trail / total tasks | CQO |

---

*This document is part of the AI-Company unified skill reference library. For department-specific execution policies, see individual department files in [departments/](departments/). For shared code templates including retry_with_backoff (Template #5), see [method-patterns.md](method-patterns.md#shared-code-templates).*
