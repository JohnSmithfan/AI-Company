# Memory Management and Compliance

> L3 depth file for [../memory.md](../memory.md). Owning department: `knowledge-ethics`,
> with `legal-privacy` owning the regulatory mapping.

## 1. Regulatory Mapping

| Memory type | GDPR | PIPL | CCPA |
|---|---|---|---|
| Profile | Personal data — lawful basis required | Personal information — consent or necessity | Personal information — notice at collection |
| Session | Ephemeral; no persistence means no storage obligation | Same | Same |
| Knowledge | Distilled, de-identified where possible | Same | Same |
| Learning | Outcome data; de-identify before promotion | Same | Same |
| Preference | Explicit consent required; **never inferred** | Separate consent | Opt-out honoured |

| Right | Applies to | Implementation | SLA |
|---|---|---|---|
| Access | Profile, Preference | Export all items for the subject | 30 days |
| Erasure | Profile, Preference | Delete plus delete derived Learning items | 30 days |
| Rectification | Profile, Preference | Correct and re-distill dependents | 30 days |
| Objection | Preference | Stop using; retain the objection record | Immediate |
| Portability | Profile | Structured, machine-readable export | 30 days |

⚠️ **Erasure must cascade.** Deleting a Profile while Learning items derived from it survive is
not erasure — it is partial erasure with a residual. `CLO_001` on failure.

## 2. Retention Schedule

| Memory type | Retention | Disposal |
|---|---|---|
| Profile | Agent lifetime + 90 days | Anonymize, do not hard-delete, while audit entries reference it |
| Session | Session end | Dropped automatically; audit entries survive separately |
| Knowledge | Until superseded + 180 days | Archive with successor pointer |
| Learning | Until disproven + 365 days | Archive |
| Preference | Until changed + 90 days | Delete on erasure request |
| Audit entries | ≥ 365 days | Immutable; never disposed early |

An item past its retention date without review raises `KNM_002`.

## 3. Masking Requirements

Template 9 is applied **before** persistence, on every memory type. All three classes:

| Class | Placeholder | Note |
|---|---|---|
| Email | `[EMAIL]` | Includes addresses inside free-text notes |
| IPv4 | `[IP]` | Includes addresses in log excerpts stored as memory |
| Phone | `[PHONE]` | CN mobile numbers: optional `+86` / `0086` / `86` country code; 11 digits contiguous or in 3-4-4 groups joined by a space or a dash |

⚠️ The PHONE branch is mandatory. A masking function that handles only email and IP while its
contract promises three classes is a contract/implementation divergence — the exact defect class
that stayed invisible in a predecessor package because its test suite carried an inlined copy
rather than reading the authoritative source. See [../method-patterns.md](../method-patterns.md) §3.9.

## 4. Consent and Preference Handling

| Rule | Requirement |
|---|---|
| Explicit only | A Preference is written solely from a stated user instruction |
| No inference | Behavioural inference is never stored as a Preference |
| Granular | Per-purpose consent, not blanket |
| Revocable | Withdrawal takes effect immediately and cascades to dependents |
| Recorded | The consent event itself is stored in the audit trail with timestamp |

Inferring a preference and acting on it is how a system begins making decisions nobody authorized.

## 5. Cross-Border Rules

| Tier | Requirement |
|---|---|
| `large` (this package) | GDPR applies where an EU data subject is involved; SCC clauses referenced |
| `group` | Full regime: GDPR (SCC) + PIPL (CAC approval for outbound transfer) + CCPA + data residency |

At `large` tier, cross-border transfer of Profile or Preference memory requires a recorded lawful
basis. At `group` tier the `privacy-data-protection` department owns this end to end; a residency
violation raises `CLO_006`.

## 6. Audit and Tamper Evidence

| Control | Requirement |
|---|---|
| Append-only | No update or delete operation on audit entries |
| Hash chaining | Each entry references the previous entry's hash |
| Trace linkage | Template 7 trace ID on every entry |
| Actor attribution | Department, and actor for manual operations |
| Tamper detection | Chain break raises `IRP_002` |
| Read access | `risk-audit` read-only; no other department |

## 7. Distillation Compliance

| Rule | Requirement |
|---|---|
| No silent drops | Every item removed during distillation has a successor pointer or an explicit deprecation |
| Provenance preserved | A distilled item records which source items it derived from |
| Reversibility window | Source items retained 30 days after distillation to allow rollback |
| Human review | Distillation output affecting Knowledge is reviewed before publication |

`KNM_005` on a supersession without a successor pointer.

## 8. Constraints

- ❌ Do not persist unmasked PII in any memory type
- ❌ Do not infer a Preference
- ❌ Do not perform partial erasure — cascade to derived items
- ❌ Do not dispose of audit entries before their retention floor
- ❌ Do not distill without preserving provenance
- ❌ Do not transfer Profile or Preference memory cross-border without a recorded basis
- ❌ Do not grant another department read access to Session memory
