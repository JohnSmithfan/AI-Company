# Visualization

> L2 shared module. Depth files: [viz/chart-types.md](viz/chart-types.md) ·
> [viz/mermaid-diagrams.md](viz/mermaid-diagrams.md) ·
> [viz/report-templates.md](viz/report-templates.md) ·
> [viz/integration-compliance.md](viz/integration-compliance.md)
>
> Owning department: `quality-visualization` (prefix `CQO_`). At `group` tier the visualization
> function stays inside `quality-assurance` — it is never a separate department.

Turns department output into charts, diagrams and reports. Every visual is generated content and
therefore carries AIGC identification like any other output.

## 1. Chart Type Selection

Choose by the question being answered, not by what looks good:

| Question | Chart | Avoid |
|---|---|---|
| How does a metric move over time? | Line | Pie |
| How do discrete categories compare? | Bar (horizontal if > 6 labels) | 3-D bar |
| What is the composition of a whole? | Pie, only for ≤ 5 parts summing to 100 % | Pie for time series |
| How do two variables relate? | Scatter | Line |
| How does a profile compare across axes? | Radar, only for 3–8 axes | Radar for time series |
| Where is intensity concentrated? | Heatmap | Stacked bar |
| How does volume flow between stages? | Sankey | Bar |
| What is the schedule and dependency structure? | Gantt | Line |

Detail and axis/label rules: [viz/chart-types.md](viz/chart-types.md)

## 2. Diagram Standards

| Diagram | Use | Engine |
|---|---|---|
| Flowchart | Process and decision logic | Mermaid |
| Sequence | Inter-department hand-offs, webhook flows | Mermaid |
| Class / ER | Schema and data model | Mermaid |
| State | Circuit breaker, branch lifecycle, incident states | Mermaid |
| Gantt | Rollout schedules | Mermaid |
| Architecture | System topology (dark theme, standalone HTML) | SVG |

**Mermaid robustness rules** — these prevent the two most common render failures:

| Rule | Reason |
|---|---|
| Quote every node label containing `(`, `)`, `:`, `#`, or a comma | Unquoted parentheses break the parser |
| Use `ELK` layout for graphs wider than 8 nodes | Default layout produces overlapping edges |
| Never use a reserved word (`end`, `graph`, `subgraph`) as a node id | Silent parse failure |
| Declare direction explicitly (`flowchart TD` / `LR`) | Ambiguous default |

Detail: [viz/mermaid-diagrams.md](viz/mermaid-diagrams.md)

## 3. Report Templates

| Template | Used by workflow | Sections |
|---|---|---|
| Operational daily | WFT-002 | Headline metrics · exceptions · actions due |
| Weekly department | WFT-002 | Quality metrics vs threshold · trend · risks |
| Incident post-mortem | WFT-005 | Timeline · root cause · containment · actions · evidence |
| Budget variance | WFT-006 | Budget vs actual · variance drivers · forecast |
| Market intelligence | WFT-008 | Sources · findings · confidence · recommended action |
| Upgrade proposal | WFT-010 | Triggers · change list · gate results · install steps |

Every report carries: generation timestamp (TZ-aware UTC), the trace ID from template 7, the
AIGC triple label from template 4, and a data-freshness statement naming each source's age.

Detail: [viz/report-templates.md](viz/report-templates.md)

## 4. Data Contracts

A visual is only as trustworthy as its input. Before rendering:

| Check | Failure action |
|---|---|
| Source declared and reachable | Omit the series and state the omission on the chart |
| Timestamps TZ-aware and comparable | Normalize to UTC or refuse to plot the series together |
| No gaps presented as zero | Render gaps as breaks, never as 0 |
| Units consistent across series | Convert or split into separate charts |
| Sample size ≥ 3 for any trend claim | Report the value without a trend line |

⚠️ **A gap is not a zero.** Rendering missing data as 0 fabricates a decline that never happened.

## 5. Compliance

| Requirement | Implementation |
|---|---|
| AIGC identification | Template 4 envelope on every generated artifact |
| PII masking | Template 9 applied before any label, tooltip or axis value is rendered |
| Source attribution | Each data series names its source and collection time |
| Accessibility | Minimum 4.5:1 contrast; never colour as the sole differentiator |
| Reproducibility | Every chart records the query or file it was generated from |

Detail: [viz/integration-compliance.md](viz/integration-compliance.md)

## 6. Constraints

- ❌ Do not render a gap as zero
- ❌ Do not use a pie chart for more than 5 parts or for a time series
- ❌ Do not put unmasked PII in any label, tooltip or axis value
- ❌ Do not publish a visual without the AIGC triple label
- ❌ Do not claim a trend from fewer than 3 data points
- ❌ Do not leave a Mermaid node label unquoted when it contains parentheses or colons

## 7. Quality Metrics

| Metric | Threshold |
|---|---|
| Charts rendered without error | ≥ 99 % |
| Visuals missing AIGC labeling | 0 (`CLO_003`) |
| Visuals containing unmasked PII | 0 |
| Reports delivered within SLA | ≥ 95 % |
| Data-freshness statement present | 100 % of reports |
| Charts with undeclared source | 0 |
