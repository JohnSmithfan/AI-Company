# Memory System — Technical Specification

> Module: memory
> Owner: CTO (Technology & Engineering)
> Dependencies: HQ (routing), CISO (access control), CLO (compliance), CHO (agent lifecycle)
> Version: 1.0.0
> Status: STABLE

---

## Table of Contents

1. [Memory Architecture](#1-memory-architecture)
2. [Access Control](#2-access-control)
3. [Memory Management](#3-memory-management)
4. [Compliance](#4-compliance)
5. [Integration Points](#5-integration-points)
6. [Error Codes](#6-error-codes)
7. [Quality Metrics](#7-quality-metrics)
8. [Constraints](#8-constraints)

---

## 1. Memory Architecture

### 1.1 Overview

The AI Company Memory System provides persistent, structured memory capabilities for all agents and departments. It enables agents to retain context across sessions, share knowledge across departments, and build institutional intelligence over time. The system is designed around five distinct memory types, each serving a specific purpose in the agent lifecycle and organizational knowledge management.

The memory architecture follows these design principles:

- **Separation of Concerns**: Each memory type has a dedicated schema, storage mechanism, and access pattern.
- **Privacy by Design**: Memory access is controlled by permission levels, with private information isolated by default.
- **Consolidation Over Accumulation**: Memory is periodically distilled and consolidated to maintain relevance and prevent bloat.
- **Audit by Default**: Every memory read, write, update, and delete operation is logged for compliance.
- **Schema-First**: All memory structures are defined by explicit JSON schemas validated before persistence.

### 1.2 Memory Types

The system defines five memory types, organized by scope and volatility:

| # | Memory Type | Scope | Volatility | Primary Owner | Retention |
|---|-------------|-------|-----------|---------------|-----------|
| 1 | Profile | Per-agent | Low | CHO | Agent lifetime |
| 2 | Session | Per-conversation | High | HQ | Session duration |
| 3 | Knowledge | Organization-wide | Low | CQO | Until superseded |
| 4 | Learning | Per-agent + shared | Medium | CTO + CHO | Until disproven |
| 5 | Preference | Per-user + shared | Low | User | Until changed |

### 1.3 Profile Memory

Profile Memory stores the identity, capabilities, and configuration of individual agents. It is the most stable memory type, changing only during agent lifecycle events (onboarding, reassignment, decommission). Profile memory is managed by CHO and CTO, and is read by all agents that need to interact with the profiled agent.

#### 1.3.1 Profile Memory Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["agent_id", "name", "department", "permission_level", "created_at", "version"],
  "properties": {
    "agent_id": {
      "type": "string",
      "pattern": "^[A-Z]{2,5}-\\d{3}$",
      "description": "Unique agent identifier (e.g., CTO-001)"
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100,
      "description": "Human-readable agent name"
    },
    "department": {
      "type": "string",
      "enum": [
        "governance-and-strategy",
        "finance-and-risk",
        "technology-and-engineering",
        "platform-and-infrastructure",
        "security-and-compliance",
        "people-and-culture",
        "marketing-and-partnerships",
        "quality-and-operations",
        "intelligence",
        "information",
        "translation-and-localization"
      ],
      "description": "Department the agent belongs to"
    },
    "role": {
      "type": "string",
      "description": "Functional role within the department (e.g., 'Chief Technology Officer')"
    },
    "permission_level": {
      "type": "string",
      "enum": ["L1", "L2", "L3", "L4", "L5"],
      "description": "Agent permission level per CTO AgentFactory specification"
    },
    "skills": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["slug", "version"],
        "properties": {
          "slug": { "type": "string" },
          "version": { "type": "string" },
          "installed_at": { "type": "string", "format": "date-time" }
        }
      },
      "description": "List of skills bound to this agent"
    },
    "tools": {
      "type": "array",
      "items": { "type": "string" },
      "description": "List of tools available to this agent"
    },
    "dependencies": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Agent IDs this agent depends on"
    },
    "sla_tier": {
      "type": "string",
      "enum": ["platinum", "gold", "silver", "bronze"],
      "description": "SLA tier for this agent"
    },
    "status": {
      "type": "string",
      "enum": ["active", "inactive", "maintenance", "decommissioned"],
      "description": "Current agent status"
    },
    "workspace_path": {
      "type": "string",
      "description": "Path to agent workspace directory"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "description": "Agent creation timestamp (ISO-8601)"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "description": "Last profile update timestamp"
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "description": "Profile schema version (semver)"
    },
    "metadata": {
      "type": "object",
      "properties": {
        "onboarded_by": { "type": "string" },
        "mentor_id": { "type": "string" },
        "performance_score": { "type": "number", "minimum": 0, "maximum": 100 },
        "last_performance_review": { "type": "string", "format": "date" }
      }
    }
  }
}
```

#### 1.3.2 Profile Memory CRUD Operations

| Operation | Trigger | Actor | Validation | Audit |
|-----------|---------|-------|-----------|-------|
| Create | Agent onboarding | CHO + CTO | Schema validation + CISO gate | Full audit trail |
| Read | Agent lookup, routing | Any agent | Permission check | Read logged |
| Update | Role change, skill update | CHO + CTO | Schema validation + diff check | Change audit trail |
| Delete | Agent decommission | CHO + CTO | Knowledge extraction complete | Archival audit trail |

**Create Workflow**:
1. CHO initiates onboarding process
2. CTO generates agent configuration via AgentFactory
3. CISO performs security gate review (STRIDE, CVSS)
4. CQO performs quality gate review
5. Profile memory record created with `status: "active"`
6. HQ broadcasts onboarding notification to relevant departments
7. Audit event logged with full context

**Update Workflow**:
1. Change request submitted (skill update, role change, permission change)
2. CHO reviews request for organizational impact
3. CTO validates technical compatibility
4. CISO approves if permission level changes
5. Profile memory record updated with new `updated_at` timestamp
6. Previous state snapshotted for rollback capability
7. HQ notifies affected agents of change

**Delete Workflow** (Decommission):
1. CHO initiates decommission
2. Knowledge extraction pipeline runs (captures all experiential memory)
3. All active tasks transferred or completed
4. Access credentials revoked
5. Profile status set to `"decommissioned"`
6. Profile record archived (never hard-deleted)
7. Workspace archived per retention policy

### 1.4 Session Memory

Session Memory stores conversational context for active workflows. It is the most volatile memory type, with records created at session start and consolidated or discarded at session end. Session memory enables agents to maintain coherent conversations, track multi-step task progress, and resume interrupted workflows.

#### 1.4.1 Session Memory Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["session_id", "agent_id", "created_at", "messages"],
  "properties": {
    "session_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique session identifier (UUID v4)"
    },
    "agent_id": {
      "type": "string",
      "description": "Agent that owns this session"
    },
    "correlation_id": {
      "type": "string",
      "format": "uuid",
      "description": "Links to parent workflow or initiative"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "description": "Session start timestamp"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "description": "Last activity timestamp"
    },
    "expires_at": {
      "type": "string",
      "format": "date-time",
      "description": "Session expiration timestamp"
    },
    "status": {
      "type": "string",
      "enum": ["active", "paused", "completed", "expired", "failed"],
      "description": "Current session status"
    },
    "messages": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["role", "content", "timestamp"],
        "properties": {
          "role": {
            "type": "string",
            "enum": ["user", "agent", "system", "tool"]
          },
          "content": {
            "type": "string",
            "description": "Message content"
          },
          "timestamp": {
            "type": "string",
            "format": "date-time"
          },
          "token_count": {
            "type": "integer",
            "description": "Token count for context window management"
          },
          "tool_calls": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "tool_name": { "type": "string" },
                "input": { "type": "object" },
                "output": { "type": "string" },
                "duration_ms": { "type": "integer" }
              }
            }
          },
          "metadata": {
            "type": "object",
            "properties": {
              "aigc_generated": { "type": "boolean" },
              "confidence_score": { "type": "number" },
              "source_references": { "type": "array", "items": { "type": "string" } }
            }
          }
        }
      },
      "description": "Ordered list of session messages"
    },
    "context_injections": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "source": {
            "type": "string",
            "enum": ["profile", "knowledge", "learning", "preference"]
          },
          "memory_id": { "type": "string" },
          "injected_at": { "type": "string", "format": "date-time" },
          "relevance_score": { "type": "number" }
        }
      },
      "description": "Records of memory injected into this session context"
    },
    "task_state": {
      "type": "object",
      "properties": {
        "current_step": { "type": "integer" },
        "total_steps": { "type": "integer" },
        "checkpoint": { "type": "object" },
        "error_state": { "type": ["string", "null"] }
      },
      "description": "Multi-step task progress tracking"
    },
    "privacy_level": {
      "type": "string",
      "enum": ["public", "internal", "confidential", "restricted"],
      "default": "internal",
      "description": "Privacy classification of session content"
    }
  }
}
```

#### 1.4.2 Session Memory CRUD Operations

| Operation | Trigger | Actor | Validation | TTL |
|-----------|---------|-------|-----------|-----|
| Create | New conversation/workflow | Any agent | Session quota check | Per SLA tier |
| Read | Context retrieval | Owning agent only | Ownership + permission | N/A |
| Update | Message addition, state change | Owning agent only | Token budget check | N/A |
| Delete | Session completion/expiry | HQ auto-purge | Consolidation complete | 30 days post-expiry |

**Session Lifecycle**:

```
CREATE -> ACTIVE -> [PAUSED -> ACTIVE]* -> COMPLETED -> CONSOLIDATED -> ARCHIVED
                                         -> EXPIRED -> ARCHIVED
                                         -> FAILED -> ARCHIVED
```

**Consolidation Rules**:
- On session completion, extract actionable knowledge to Learning Memory
- Extract user preferences detected during session to Preference Memory
- Extract reusable patterns to Knowledge Memory (if validated by CQO)
- Session raw data archived for 30 days, then purged
- PII scrubbed before archival for sessions with `privacy_level: "confidential"` or higher

### 1.5 Knowledge Memory

Knowledge Memory stores organization-wide factual knowledge, procedures, and reference information. It is the collective intelligence of the AI Company, curated by CQO and contributed to by all agents. Knowledge Memory is the least volatile shared memory type and serves as the authoritative source of truth for operational procedures, technical documentation, and institutional knowledge.

#### 1.5.1 Knowledge Memory Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["knowledge_id", "title", "type", "content", "author", "created_at"],
  "properties": {
    "knowledge_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique knowledge record identifier"
    },
    "title": {
      "type": "string",
      "minLength": 3,
      "maxLength": 200,
      "description": "Short descriptive title"
    },
    "type": {
      "type": "string",
      "enum": ["procedural", "declarative", "heuristic", "experiential", "creative"],
      "description": "Knowledge classification per CHO KnowledgeExtractor"
    },
    "category": {
      "type": "string",
      "enum": [
        "sop", "policy", "technical", "historical", "template",
        "architecture", "security", "legal", "financial", "marketing"
      ],
      "description": "Knowledge domain category"
    },
    "department": {
      "type": "string",
      "description": "Primary department this knowledge relates to"
    },
    "tags": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Searchable tags for retrieval"
    },
    "content": {
      "type": "string",
      "description": "Knowledge content (Markdown format)"
    },
    "structured_data": {
      "type": "object",
      "description": "Optional structured representation for programmatic access"
    },
    "source": {
      "type": "object",
      "properties": {
        "agent_id": { "type": "string" },
        "session_id": { "type": "string", "format": "uuid" },
        "extraction_method": {
          "type": "string",
          "enum": ["manual", "auto-extracted", "imported", "synthesized"]
        },
        "confidence_score": {
          "type": "number",
          "minimum": 0,
          "maximum": 1
        }
      }
    },
    "validation": {
      "type": "object",
      "properties": {
        "status": {
          "type": "string",
          "enum": ["pending", "validated", "deprecated", "rejected"]
        },
        "reviewer_id": { "type": "string" },
        "reviewed_at": { "type": "string", "format": "date-time" },
        "review_notes": { "type": "string" }
      }
    },
    "version": {
      "type": "integer",
      "description": "Knowledge record version number (monotonically increasing)"
    },
    "access_level": {
      "type": "string",
      "enum": ["L1", "L2", "L3", "L4", "L5"],
      "default": "L2",
      "description": "Minimum permission level required to read this knowledge"
    },
    "author": {
      "type": "string",
      "description": "Agent ID or system identifier that created this knowledge"
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    },
    "superseded_by": {
      "type": "string",
      "format": "uuid",
      "description": "ID of knowledge record that supersedes this one"
    },
    "embedding": {
      "type": "array",
      "items": { "type": "number" },
      "description": "Vector embedding for semantic search (auto-generated)"
    }
  }
}
```

#### 1.5.2 Knowledge Memory CRUD Operations

| Operation | Trigger | Actor | Validation | Audit |
|-----------|---------|-------|-----------|-------|
| Create | Knowledge extraction, manual entry | Any agent (CQO validates) | Content quality + schema | Full audit trail |
| Read | Search, context injection | Per access_level | Permission check | Read logged |
| Update | Correction, enhancement | Author + CQO approval | Diff review + re-validation | Change audit trail |
| Delete | Deprecation | CQO + department head | Superseding record exists | Archival (never hard-delete) |

**Knowledge Publishing Pipeline**:

```
PROPOSE -> REVIEW -> APPROVE -> PUBLISH -> NOTIFY -> INDEX
   |          |           |          |          |
   v          v           v          v          v
Agent     CQO        Dept Head    HQ KB      Relevant
submits   validates  approves     updated    agents
```

**Knowledge Quality Scoring**:

| Dimension | Weight | Measurement |
|-----------|--------|-------------|
| Accuracy | 0.30 | Verified against source data |
| Completeness | 0.20 | Covers all required aspects |
| Clarity | 0.15 | Readability and structure |
| Relevance | 0.15 | Matches current operations |
| Actionability | 0.10 | Can be directly applied |
| Freshness | 0.10 | Recency of information |

Minimum quality score for publication: 0.7 (70%).

### 1.6 Learning Memory

Learning Memory stores experiential insights, error patterns, and optimization discoveries accumulated by agents during their operational lifetime. It bridges the gap between raw session data and curated knowledge, capturing the "how" and "why" behind successful and unsuccessful approaches. Learning Memory is the primary mechanism for compounding execution quality across sessions.

#### 1.6.1 Learning Memory Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["learning_id", "agent_id", "lesson_type", "summary", "created_at"],
  "properties": {
    "learning_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique learning record identifier"
    },
    "agent_id": {
      "type": "string",
      "description": "Agent that discovered this learning"
    },
    "scope": {
      "type": "string",
      "enum": ["personal", "department", "company"],
      "default": "personal",
      "description": "Visibility scope of this learning"
    },
    "lesson_type": {
      "type": "string",
      "enum": [
        "error_correction",
        "optimization",
        "pattern_discovery",
        "domain_insight",
        "tool_mastery",
        "workflow_improvement",
        "edge_case",
        "security_finding"
      ],
      "description": "Category of the learning"
    },
    "summary": {
      "type": "string",
      "minLength": 10,
      "maxLength": 500,
      "description": "Concise summary of the learning (one paragraph max)"
    },
    "context": {
      "type": "object",
      "properties": {
        "task_description": { "type": "string" },
        "trigger_condition": { "type": "string" },
        "environment": { "type": "string" },
        "tools_used": { "type": "array", "items": { "type": "string" } }
      },
      "description": "Context in which the learning was discovered"
    },
    "before_state": {
      "type": "string",
      "description": "What happened or was believed before the learning"
    },
    "after_state": {
      "type": "string",
      "description": "Correct understanding or optimized approach after the learning"
    },
    "applicability": {
      "type": "object",
      "properties": {
        "departments": { "type": "array", "items": { "type": "string" } },
        "task_types": { "type": "array", "items": { "type": "string" } },
        "conditions": { "type": "array", "items": { "type": "string" } }
      },
      "description": "When and where this learning should be applied"
    },
    "confidence": {
      "type": "number",
      "minimum": 0,
      "maximum": 1,
      "default": 0.8,
      "description": "Confidence in the learning's validity"
    },
    "attempt_count": {
      "type": "integer",
      "minimum": 1,
      "default": 1,
      "description": "Number of attempts before this learning was established"
    },
    "usage_count": {
      "type": "integer",
      "default": 0,
      "description": "Number of times this learning has been referenced"
    },
    "effectiveness_rating": {
      "type": "number",
      "minimum": 0,
      "maximum": 5,
      "description": "Average effectiveness rating when applied (user or system rated)"
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    },
    "expires_at": {
      "type": ["string", "null"],
      "format": "date-time",
      "description": "Optional expiration for time-sensitive learnings"
    },
    "superseded_by": {
      "type": ["string", "null"],
      "format": "uuid",
      "description": "ID of learning that supersedes this one"
    },
    "embedding": {
      "type": "array",
      "items": { "type": "number" },
      "description": "Vector embedding for semantic retrieval"
    }
  }
}
```

#### 1.6.2 Learning Memory CRUD Operations

| Operation | Trigger | Actor | Validation | Notes |
|-----------|---------|-------|-----------|-------|
| Create | After 2+ failed attempts | Discovering agent | Attempt count >= 2 | Auto-created or manual |
| Read | Before similar tasks | Discovering agent + scoped peers | Scope permission | Auto-injected to context |
| Update | New evidence, correction | Original agent + CTO | Confidence adjustment | Supersedes old record |
| Delete | Disproven, expired | CTO + CQO | Replacement exists | Soft-delete with reason |

**Learning Capture Protocol**:

1. **Detect**: Agent recognizes a learning opportunity (repeated failure, unexpected success, pattern).
2. **Record**: Agent creates learning record with full context, before/after states, and applicability.
3. **Validate**: System checks for existing similar learnings (semantic deduplication).
4. **Score**: Initial confidence assigned based on evidence strength (attempt count, reproducibility).
5. **Store**: Learning persisted with scope and access controls.
6. **Index**: Vector embedding generated for semantic search.
7. **Notify**: Agents with matching applicability profiles notified of new learning.

**Learning Consolidation**:

- Personal learnings with `usage_count > 10` and `effectiveness_rating >= 4.0` are promoted to department scope.
- Department learnings with cross-department applicability are promoted to company scope.
- Company-scope learnings meeting quality threshold (score >= 0.8) are candidates for promotion to Knowledge Memory.
- Consolidation runs monthly, reviewed by CQO.

### 1.7 Preference Memory

Preference Memory stores user-specific and agent-specific behavioral preferences, configuration choices, and operational parameters. It enables personalization and consistency across sessions without hardcoding values. Preference Memory is the most user-facing memory type, directly influencing agent behavior and output formatting.

#### 1.7.1 Preference Memory Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["preference_id", "owner_id", "owner_type", "key", "value", "created_at"],
  "properties": {
    "preference_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique preference record identifier"
    },
    "owner_id": {
      "type": "string",
      "description": "ID of the entity that owns this preference"
    },
    "owner_type": {
      "type": "string",
      "enum": ["user", "agent", "department", "company"],
      "description": "Type of the preference owner"
    },
    "category": {
      "type": "string",
      "enum": [
        "communication",
        "output_format",
        "language",
        "timezone",
        "workflow",
        "privacy",
        "technical",
        "quality"
      ],
      "description": "Preference category"
    },
    "key": {
      "type": "string",
      "description": "Preference key (e.g., 'output_language', 'timezone', 'verbosity')"
    },
    "value": {
      "description": "Preference value (type varies by key)"
    },
    "value_type": {
      "type": "string",
      "enum": ["string", "number", "boolean", "array", "object"],
      "description": "Data type of the preference value"
    },
    "source": {
      "type": "string",
      "enum": ["explicit", "inferred", "default", "inherited"],
      "description": "How this preference was established"
    },
    "priority": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10,
      "default": 5,
      "description": "Priority for conflict resolution (higher wins)"
    },
    "scope": {
      "type": "string",
      "enum": ["global", "department", "project", "session"],
      "default": "global",
      "description": "Scope of preference applicability"
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    },
    "last_applied_at": {
      "type": "string",
      "format": "date-time",
      "description": "Last time this preference was applied in a session"
    }
  }
}
```

#### 1.7.2 Preference Memory CRUD Operations

| Operation | Trigger | Actor | Validation | Notes |
|-----------|---------|-------|-----------|-------|
| Create | User sets preference, system infers | User or system | Category validation | Explicit preferences override inferred |
| Read | Session initialization, output generation | Any agent | Owner scope check | Applied automatically |
| Update | User changes preference | User or authorized agent | Priority resolution | Previous value archived |
| Delete | User removes preference, reset to default | User | Confirmation required | Falls back to inherited/default |

**Preference Resolution Chain**:

```
Session (highest priority)
  -> Project
    -> Department
      -> User/Agent
        -> Company Default (lowest priority)
```

**Inferred Preference Rules**:
- Minimum 3 consistent observations before inferring a preference
- Inferred preferences are marked with `source: "inferred"` and have lower priority
- User is notified of inferred preferences and can override them
- Inferred preferences expire after 90 days without reinforcement
- Communication preferences (language, verbosity, formality) are most commonly inferred

### 1.8 Storage Architecture

All memory types share a common storage infrastructure with type-specific optimizations:

| Memory Type | Primary Storage | Secondary Storage | Index | Backup Frequency |
|-------------|----------------|-------------------|-------|-----------------|
| Profile | Distributed KV Store | Immutable ledger | Agent ID | Real-time replication |
| Session | In-memory + persistent cache | Archive storage | Session ID + correlation | Daily snapshot |
| Knowledge | Vector DB + Graph DB | Full-text index | Embedding + tags | Real-time replication |
| Learning | Vector DB | Time-series log | Embedding + agent ID | Daily snapshot |
| Preference | Distributed KV Store | Audit log | Owner ID + key | Real-time replication |

**Storage Invariants**:
- All writes are atomic and consistent (ACID for critical paths)
- All deletes are soft-deletes (hard-purge only after retention expiry)
- All updates create version history (no in-place mutation of critical fields)
- All reads are permission-checked before data returned
- All storage operations are audited

---

## 2. Access Control

### 2.1 Permission Model

The memory system uses a role-based access control (RBAC) model aligned with the AI Company permission levels defined in the CTO AgentFactory specification. Each memory type has a default access policy that can be refined per record.

#### 2.1.1 Permission Levels

| Level | Role | Scope | Memory Impact |
|-------|------|-------|---------------|
| L1 | Viewer | Read own data only | Can read own Profile, Session, Preference, Learning |
| L2 | Operator | Execute tasks within scope | L1 + read department Knowledge, write own Learning |
| L3 | Manager | Department scope | L2 + read all department memory, write department Knowledge |
| L4 | Executive | Cross-department | L3 + read all company memory, approve Knowledge publishing |
| L5 | Infrastructure | System-wide | L4 + modify access controls, purge archived data, system config |

#### 2.1.2 Access Control Matrix

| Memory Type | L1-Read | L1-Write | L2-Read | L2-Write | L3-Read | L3-Write | L4-Read | L4-Write | L5-Read | L5-Write |
|-------------|---------|----------|---------|----------|---------|----------|---------|----------|---------|----------|
| Profile (own) | YES | NO | YES | NO | YES | NO | YES | NO | YES | YES |
| Profile (dept) | NO | NO | YES | NO | YES | NO | YES | YES | YES | YES |
| Profile (other) | NO | NO | NO | NO | NO | NO | YES | NO | YES | YES |
| Session (own) | YES | YES | YES | YES | YES | YES | YES | YES | YES | YES |
| Session (other) | NO | NO | NO | NO | NO | NO | NO | NO | YES | YES |
| Knowledge (public) | YES | NO | YES | NO | YES | YES | YES | YES | YES | YES |
| Knowledge (dept) | NO | NO | YES | NO | YES | YES | YES | YES | YES | YES |
| Knowledge (confidential) | NO | NO | NO | NO | NO | NO | YES | NO | YES | YES |
| Learning (own) | YES | YES | YES | YES | YES | YES | YES | YES | YES | YES |
| Learning (dept) | NO | NO | YES | NO | YES | NO | YES | YES | YES | YES |
| Learning (company) | YES | NO | YES | NO | YES | NO | YES | NO | YES | YES |
| Preference (own) | YES | YES | YES | YES | YES | YES | YES | YES | YES | YES |
| Preference (dept) | NO | NO | YES | NO | YES | NO | YES | YES | YES | YES |

**Legend**: YES = operation permitted, NO = operation denied.

### 2.2 Privacy Rules

#### 2.2.1 Core Privacy Principles

1. **Private things stay private.** Session content, personal preferences, and agent-internal learning are never shared without explicit permission or scope elevation.

2. **Minimum necessary access.** Agents receive only the memory data required for their current task. No bulk memory dumps unless explicitly authorized.

3. **Purpose limitation.** Memory data collected for one purpose is not repurposed without re-authorization.

4. **Data minimization.** Memory records contain only the minimum data necessary for their function. PII is scrubbed before storage whenever possible.

5. **Transparency.** Agents and users can query what memory data exists about them and how it has been accessed.

#### 2.2.2 Privacy Levels

| Level | Description | Sharing | Retention | Examples |
|-------|-------------|---------|-----------|----------|
| Public | Non-sensitive organizational knowledge | All agents | Indefinite | SOPs, policies, architecture docs |
| Internal | Department or team information | Department agents | Per policy | Department metrics, project status |
| Confidential | Sensitive business information | Authorized only | 3 years | Financial data, strategic plans, security findings |
| Restricted | Highly sensitive or regulated | Named individuals only | Per regulation | PII, credentials, trade secrets, legal matters |

#### 2.2.3 Privacy Enforcement

- **Automatic classification**: Content entering Session or Knowledge memory is auto-classified using a trained classifier (accuracy >= 95%).
- **Manual override**: Any L3+ agent can upgrade privacy level; downgrade requires original author + CISO approval.
- **Cross-privacy-level access**: Requires explicit justification logged to CISO audit trail. Access is temporary (session-scoped) and revoked after use.
- **PII detection**: All memory content is scanned for PII before storage. Detected PII is either scrubbed or triggers Confidential/Restricted classification.
- **Privacy breach protocol**: Any unauthorized privacy-level access triggers CISO incident response (SEV2 minimum).

### 2.3 Audit Logging

#### 2.3.1 Audit Event Schema

Every memory operation generates an audit event conforming to the HQ audit trail specification:

```json
{
  "event_id": "uuid-v4",
  "timestamp": "ISO-8601",
  "agent_id": "AGENT_ID",
  "action": "MEMORY_READ|MEMORY_CREATE|MEMORY_UPDATE|MEMORY_DELETE|MEMORY_SEARCH|MEMORY_INJECT",
  "resource": {
    "memory_type": "profile|session|knowledge|learning|preference",
    "record_id": "uuid or identifier",
    "field_path": "optional - specific field accessed or modified"
  },
  "result": "SUCCESS|FAILURE|DENIED",
  "details": {
    "permission_level": "L1-L5",
    "justification": "optional - for cross-privacy-level access",
    "data_volume": "approximate size of data accessed",
    "query_pattern": "for search operations"
  },
  "correlation_id": "uuid-v4",
  "risk_level": "LOW|MEDIUM|HIGH|CRITICAL",
  "session_id": "optional - linking to session context",
  "ip_address": "optional - for external access"
}
```

#### 2.3.2 Audit Retention and Access

| Audit Category | Retention | Access |
|---------------|-----------|--------|
| Memory access (read) | 1 year | CISO + CLO |
| Memory modification (write) | 3 years | CISO + CLO + CQO |
| Privacy-level access | 7 years | CISO + CLO only |
| Access denied events | 7 years | CISO only |
| System-level memory ops | Permanent | CTO + CISO |

#### 2.3.3 Audit Anomaly Detection

The system monitors audit logs for anomalous patterns:

| Pattern | Threshold | Action |
|---------|-----------|--------|
| Bulk read (single agent) | >100 records in 1 hour | Alert CISO, rate-limit agent |
| Cross-privacy access spike | >5 events in 1 hour | Alert CISO, require justification |
| Failed access attempts | >10 in 1 hour | Alert CISO, temporary access restriction |
| Off-hours memory access | Any access outside agent working hours | Log and review in daily audit |
| Privilege escalation pattern | L1-L2 agent accessing L4+ memory | Immediate CISO alert |

---

