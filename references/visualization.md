# AI-Company Visualization Module

> **Progressive Disclosure**: This module has been split into focused sub-files for on-demand loading.
> Load only the sub-file you need instead of the entire module.

## Sub-File Index

| File | Content | Size | Load When |
|------|---------|------|-----------|
| [chart-types.md](viz/chart-types.md) | Chart Types (Section 1) — All chart configurations, data formats, styling | ~44KB | Building visualizations |
| [report-templates.md](viz/report-templates.md) | Report Templates (Section 2) — Dashboard layouts, report formats | ~40KB | Generating reports |
| [mermaid-diagrams.md](viz/mermaid-diagrams.md) | Mermaid Diagrams (Section 3) — Flowcharts, sequence diagrams, Gantt | ~19KB | Creating diagrams |
| [integration-compliance.md](viz/integration-compliance.md) | Integration + Compliance (Sections 4-5 + Appendices) — CEO Command Center integration, constraints, appendices | ~11KB | Integration or compliance checks |

## Quick Reference

- **Total charts**: 50+ Chart.js configurations
- **Report templates**: 15+ dashboard/report formats
- **Mermaid templates**: 20+ diagram types
- **Compliance**: AIGC labeling, PII masking, accessibility

## Loading Pattern

```python
# Instead of loading the entire 117KB file:
# references/visualization.md  ← OLD (117KB, ~29K tokens)

# Load only what you need:
# references/viz/chart-types.md       ← NEW (~44KB, ~11K tokens)
# references/viz/report-templates.md  ← NEW (~40KB, ~10K tokens)
# references/viz/mermaid-diagrams.md  ← NEW (~19KB, ~5K tokens)
# references/viz/integration-compliance.md ← NEW (~11KB, ~3K tokens)
```
