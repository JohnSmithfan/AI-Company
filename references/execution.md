# AI-Company Execution Module

> **Progressive Disclosure**: This module has been split into focused sub-files for on-demand loading.
> Load only the sub-file you need instead of the entire module.

## Sub-File Index

| File | Content | Size | Load When |
|------|---------|------|-----------|
| [modes-triggers.md](exec/modes-triggers.md) | Execution Modes + Triggers (Sections 1-2) — Craft/Plan/Ask modes, trigger patterns | ~31KB | Setting up execution flows |
| [error-recovery.md](exec/error-recovery.md) | Error Recovery (Section 3) — Retry patterns, circuit breakers, fallback strategies | ~12KB | Handling errors |
| [command-center.md](exec/command-center.md) | CEO Command Center (Section 4) — Dashboard, controls, monitoring | ~13KB | CEO operations |
| [workflows-schema.md](exec/workflows-schema.md) | Workflow Templates + Schema + Constraints + Metrics (Sections 5-8) | ~22KB | Building workflows |

## Quick Reference

- **Execution modes**: Craft / Plan / Ask
- **Trigger types**: Event, Schedule, Manual, Dependency
- **Error recovery**: 12 patterns with circuit breaker support
- **Workflow templates**: 10+ pre-built templates

## Loading Pattern

```python
# Instead of loading the entire 79KB file:
# references/execution.md  ← OLD (79KB, ~20K tokens)

# Load only what you need:
# references/exec/modes-triggers.md    ← NEW (~31KB, ~8K tokens)
# references/exec/error-recovery.md    ← NEW (~12KB, ~3K tokens)
# references/exec/command-center.md    ← NEW (~13KB, ~3K tokens)
# references/exec/workflows-schema.md  ← NEW (~22KB, ~6K tokens)
```
