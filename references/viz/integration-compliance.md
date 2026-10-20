# Visualization Integration and Compliance

> L3 depth file for [../visualization.md](../visualization.md). Owning department: `quality-visualization`,
> with `legal-privacy` owning the AIGC compliance mapping.

## 1. AIGC Compliance

Every generated visual is AI-generated content and carries all three identification layers.

| Layer | Carrier | Value |
|---|---|---|
| Explicit label | Visible disclosure line appended to the content body | `> Warning: AI-Generated Content [aigc:<watermark>]` |
| Implicit metadata | Envelope payload fields | `ai_generated` (true), `generated_at` (ISO-8601 UTC), `model` (`<provider/model>`) |
| Embedded watermark | SHA-256 marker inside the content body | Bound to provider + generation timestamp + a digest of the content itself; tamper-evident, not tamper-proof |

Produced by template 4 — see [../method-patterns.md](../method-patterns.md). A visual missing any layer raises
`CLO_003`.

| Output form | How the label travels |
|---|---|
| HTML / SVG | Metadata element embedded in the document |
| PNG | Label rendered visibly in a corner **and** stored in image metadata |
| Markdown report | Front-matter block plus a visible footer line |
| Chat reply | Visible statement that the artifact is AI-generated |

⚠️ For raster output the visible label is not optional. Metadata is stripped by most image
pipelines, so a watermark in metadata alone does not survive redistribution.

## 2. PII Handling

Template 9 is applied **before** any value reaches a label, tooltip, axis tick or legend.

| Location | Risk |
|---|---|
| Axis tick label | An email address used as a category label |
| Tooltip | A phone number in a detail popup |
| Legend | A user identifier as a series name |
| Annotation | An IP address in a callout |
| Exported filename | A subject's name in the file title |

All three masking classes apply — `[EMAIL]`, `[IP]`, `[PHONE]`. A masking function that covers only
email and IP is a contract/implementation divergence; see the note in
[../method-patterns.md](../method-patterns.md) §3.9.

## 3. Accessibility

| Requirement | Threshold |
|---|---|
| Text contrast | ≥ 4.5:1 against its background |
| Graphic element contrast | ≥ 3:1 |
| Colour as sole differentiator | Never — pair with shape, pattern or a direct label |
| Red/green pairing | Not used as the only distinction |
| Text in images | Minimum 12 px equivalent at export resolution |
| Data table alternative | Provided for every chart |
| Reading order | Logical in the exported HTML |

The data-table alternative is a compliance requirement, not a convenience: it is what makes the
underlying values inspectable and reproducible.

## 4. Reproducibility

| Requirement | Detail |
|---|---|
| Source recorded | Every series names its query or file |
| Parameters recorded | Filters, aggregation and binning stated |
| Version recorded | Chart definition versioned with the report |
| Deterministic | The same inputs and definition produce the same output |
| No remote fetch | An HTML visual loads no external script or stylesheet |

⚠️ A self-contained HTML visual is both a security requirement and a reproducibility one. A
remote-fetching visual can render differently depending on network state, and can be altered by
whoever controls the remote resource.

## 5. Integration Points

| Consumer | Contract |
|---|---|
| WFT-002 Report Generation | Chart definitions plus data tables, AIGC-labelled |
| WFT-006 Budget Review | Variance charts with threshold lines and breach shading |
| WFT-008 Market Intelligence | Trend charts carrying the confidence score |
| WFT-005 Incident Response | Timeline visualization, evidence-linked |
| Department D2 §7 | Quality-metric charts against committed thresholds |

Mechanism: in-process function call, no external service. Visual generation is a local
transformation of data the package already holds — it is never a reason to open a network
pathway.

## 6. Retention and Disposal

| Artifact | Retention | Disposal |
|---|---|---|
| Report with embedded visual | Per the report's own schedule | Archive, do not hard-delete while audit references it |
| Standalone chart export | 90 days | Delete |
| Intermediate dataset | 30 days | Delete after the report is published |
| Definition and parameters | Same as the report | Archive with it |

## 7. Constraints

- ❌ Do not publish a visual without all three AIGC layers
- ❌ Do not omit the visible label on raster output
- ❌ Do not render unmasked PII in any label, tooltip, legend or filename
- ❌ Do not rely on colour alone to distinguish series
- ❌ Do not fetch remote resources into an HTML visual
- ❌ Do not publish a chart without its data-table alternative
- ❌ Do not retain an intermediate dataset past 30 days
