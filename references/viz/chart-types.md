# Chart Types

> L3 depth file for [../visualization.md](../visualization.md). Owning department: `quality-visualization`.

## 1. Selection Rule

Choose the chart by the question, then check the data shape supports it.

| Question | Chart | Minimum data shape |
|---|---|---|
| Trend over time | Line | ≥ 3 time points, single unit |
| Category comparison | Bar | ≥ 2 categories |
| Composition of a whole | Pie / donut | 2–5 parts summing to 100 % |
| Correlation | Scatter | ≥ 10 paired observations |
| Multi-axis profile | Radar | 3–8 axes, normalized scale |
| Density / intensity | Heatmap | ≥ 2 dimensions, binned values |
| Flow between stages | Sankey | ≥ 2 stages, conserved totals |
| Schedule and dependency | Gantt | Start and end per task |
| Distribution | Histogram / box | ≥ 20 observations for a histogram |
| Ranking | Horizontal bar | ≥ 6 labels, else vertical bar |

## 2. Hard Rules

| Rule | Reason |
|---|---|
| **A gap is never rendered as zero** | Plotting missing data as 0 fabricates a decline that did not occur |
| No 3-D effects on any chart | Perspective distorts proportion judgement |
| Y-axis starts at zero for bars | A truncated bar axis exaggerates differences |
| Y-axis may be truncated for lines | Only with the break marked explicitly |
| ≤ 7 series per chart | Beyond that, colour and legend cease to disambiguate |
| ≤ 5 slices per pie | More slices are unreadable; use a bar chart |
| Never encode meaning by colour alone | Colour-blind accessibility; add a shape or label |
| Minimum contrast 4.5:1 | Text and axis legibility |

## 3. Labelling Requirements

Every chart carries:

| Element | Requirement |
|---|---|
| Title | States the finding, not just the metric — "Error rate rose 3 pp in Q2" over "Error rate" |
| Axis labels | Name **and** unit |
| Data source | Named, with collection timestamp |
| As-of date | Mandatory for any financial or metric value |
| Sample size | Stated when n < 30 |
| Confidence interval | Shown where the underlying estimate carries one |
| AIGC label | Template 4 envelope on the generated artifact |

## 4. Colour Palette

| Role | Specification |
|---|---|
| Primary series | Single hue, saturated |
| Comparison series | Same hue, reduced saturation |
| Alert / breach | Warm hue, used only for threshold violations |
| Neutral / baseline | Grey |
| Categorical (> 3) | Colour-blind-safe qualitative palette |

⚠️ Red and green are never the sole differentiators between two series in the same chart.

## 5. Threshold Display

When a metric has a committed threshold (every department's D2 §7 defines them):

| Element | Rendering |
|---|---|
| Threshold line | Dashed, labelled with the value |
| Breach region | Shaded, not just coloured |
| Breach points | Marked individually so a single spike is visible |
| Trend vs threshold | Both shown; a metric improving but still breaching must not look compliant |

## 6. Output Formats

| Format | Use | Constraint |
|---|---|---|
| SVG | Reports, scalable print | Preferred default |
| PNG | Chat and slide embedding | ≥ 2× device pixel ratio |
| HTML | Interactive dashboards | Self-contained, no external script fetch |
| Mermaid | Diagrams | See [mermaid-diagrams.md](mermaid-diagrams.md) |

An HTML chart must not fetch remote scripts or stylesheets — a self-contained file is both a
security requirement and a reproducibility one.

## 7. Constraints

- ❌ Do not render a gap as zero
- ❌ Do not use a pie chart for a time series or for > 5 parts
- ❌ Do not truncate a bar chart's Y-axis
- ❌ Do not exceed 7 series or rely on colour alone
- ❌ Do not omit units, source or as-of date
- ❌ Do not claim a trend from fewer than 3 points
- ❌ Do not fetch remote resources into an HTML chart
