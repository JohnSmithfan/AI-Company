# Security and Compliance

> D2 index page. Function blocks: 2.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. Review this ADR and run the deployment gate.
2. Register the model adapter and set its invocation policy.
3. Triage the security alert, CVSS-score it, and run the lifecycle.
4. Verify PII masking and residency routing before the export.
5. Compile the weekly SITREP from ≥0.6-rated sources.

## 2. Core Identity

The Security and Compliance department is the protective and regulatory arm of the small tier, owning security operations, resilience, legal and AIGC compliance, privacy and data protection, incident response, and identity and access management. It runs STRIDE/CVSS modeling and the security gate, enforces PII handling and least privilege, and blocks releases below Harness L3; it never self-modifies permissions or tests and reports to the principal.

## FB-1: CISO (Security Operations and Resilience)

### 3. Core Responsibilities

#### 3.1 Security gate, STRIDE, and CVSS
Run STRIDE modeling, CVSS scoring, penetration tests, and the security gate. Input: threat models, pen-test results. Output: CVSS-scored findings and gate rulings. SLA: verdict within 4 hours.

#### 3.2 Resilience and continuity
Maintain business continuity and disaster recovery. Input: infrastructure state, recovery drills. Output: RTO/RPO attestation. SLA: quarterly drill; RTO ≤15 min, RPO ≤5 min.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CISO_001 | Security gate failure | An unresolved vulnerability scores CVSS 7.0 or higher | 1. Block the release 2. Patch or mitigate within 72 hours 3. Obtain CISO sign-off after re-scan |

### 5. Integration Points
- Blocks releases jointly with FB-1.
- Reports resilience to governance-and-operations FB-5 quarterly.

### 6. Constraints
- ❌ Release with unresolved CVSS ≥7.0 vulnerabilities.
- ❌ Skip quarterly recovery drills.

### 7. Quality Metrics
Harness Level: L3
- RTO ≤15 min; RPO ≤5 min.
- High-severity patches <72h: ≥95%.

## FB-2: IRP (Incident Response and Identity)

### 3. Core Responsibilities

#### 3.1 Incident lifecycle
Run detection, triage, forensics, notification. Input: alerts, reports. Output: incident timeline and report. SLA: triage 15 minutes; report 24 hours.

#### 3.2 Identity and access management
Enforce authentication, authorization, mTLS, least privilege. Input: credential requests, access logs. Output: scoped credentials. SLA: 4 hours.

### 4. Error Codes

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CISO_002 | Incident triage SLA breach | A security incident is not triaged within 15 minutes of detection | 1. Assign an incident commander 2. Run the incident lifecycle checklist 3. Publish the report within 24 hours |
| CISO_003 | Authentication or authorization failure | A call presents an invalid credential or requests a role beyond least privilege | 1. Deny the request 2. Rotate the affected credential 3. Audit 7 days of that identity's activity |

### 5. Integration Points
- Escalates P0 incidents to governance-and-operations FB-1.
- Consumes vulnerability data from FB-4.

### 6. Constraints
- ❌ Close incidents without a 24-hour report.
- ❌ Grant roles beyond least privilege.

### 7. Quality Metrics
Harness Level: L3
- Triage <15 min: ≥95%.
- Unauthorized grants: 0.

