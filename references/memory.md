# AI-Company Memory Module

> **Progressive Disclosure**: This module has been split into focused sub-files for on-demand loading.
> Load only the sub-file you need instead of the entire module.

## Sub-File Index

| File | Content | Size | Load When |
|------|---------|------|-----------|
| [architecture.md](mem/architecture.md) | Memory Architecture + Access Control (Sections 1-2) — Memory tiers, access patterns, security model | ~34KB | Designing memory systems |
| [management-compliance.md](mem/management-compliance.md) | Memory Management + Compliance + Integration + Errors + Metrics + Constraints (Sections 3-8) | ~34KB | Operating or auditing memory |

## Quick Reference

- **Memory tiers**: L0 (hot) / L1 (warm) / L2 (cold) / L3 (archive)
- **Access control**: RBAC with department-scoped permissions
- **Compliance**: GDPR, PII masking, retention policies
- **Error codes**: MEM_001-010

## Loading Pattern

```python
# Instead of loading the entire 70KB file:
# references/memory.md  ← OLD (70KB, ~17K tokens)

# Load only what you need:
# references/mem/architecture.md           ← NEW (~34KB, ~9K tokens)
# references/mem/management-compliance.md  ← NEW (~34KB, ~9K tokens)
```
