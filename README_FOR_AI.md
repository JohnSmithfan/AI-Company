# README FOR AI — ai-company large-tier generation & maintenance specification (self-contained)

> **Document nature**: this is a **generation specification** written for LLM agents to read — not a project introduction.
> The task of the agent reading this document is: **to generate, regenerate, or extend the large tier of the `ai-company` LLM-agent governance skill package from zero**, and to keep it consistent with this document.
>
> **Self-containment declaration (important)**: this document is the generation & maintenance specification of the `ai-company` skill package **large tier** and is **fully self-contained** — every parameter, contract, red line, and acceptance item needed to generate/maintain this tier is inlined here; it **does not depend on, and does not reference, any external or higher-level specification document**. Every section number (e.g. §9.1) and red-line number (e.g. P21) in this document is a **local definition**; all `(README_FOR_AI.md §x.y)` / `P##` references in other package files point here.
>
> ⚠️ This document does not participate in skill runtime routing. The only runtime entry point is `SKILL.md`; the concise contribution entry point for coding agents that maintain this repository is `AGENTS.md`. The three have mutually exclusive responsibilities and must never restate each other's content (see P55).

---

## 1. The AI-COMPANY Project and This Package's Position

AI-COMPANY is an **enterprise governance specification for LLM agents**: it models AI agents as company employees and governs agent behavior with departments, function blocks, error codes, permission boundaries, and an upgrade path. It is divided into **five tiers** by company size (the ladder is defined locally in §1 of this document; no external document is needed):

| Tier | `scale_tier` | major | Departments | Function blocks | Structure |
|---|---|---|---|---|---|
| Micro XS | `micro` | 1 | 2 | 18 | Flat (D1+D2) |
| Small S | `small` | 2 | 5 | 18 | Flat |
| Medium M | `medium` | 3 | 9 | 18 | Flat + shared modules |
| Large L | `large` | 4 | 18 | 18 | Three layers + domain routing |
| Group G | `group` | 5 | 36 | 36 | Four layers + headquarters/branches |

**This package = the large-tier instance of ai-company** (`scale_tier: large`, v4.0.0; major = tier ordinal = 4). A tier is not a one-way gate: the skill can detect scale overflow at runtime and **propose** an upgrade on its own, but installation requires human approval (§12). The full structure of higher tiers follows the same merge-tree principle (§10.1); `scripts/self-scale.ps1` ships with the base bloodline and implements seven upgrade edges — `micro → small`, `small → medium`, `medium → large`, `micro → medium` (in-place two-stage composition), `micro → large`, `small → large`, and `large → group` (scaffold delivery) — and the target tier is selectable within `selectable_targets` via `-TargetTier` (see the rules in scaling.md §2).

**The only human decision when generating any AI-COMPANY package is the tier** (micro/small/medium/large/group); this package is locked to **large**.

## 2. Locked Parameters (large tier — align item by item at generation; never mix tiers)

| Parameter | Value |
|---|---|
| `scale_tier` | `large` (major = 4, current version `4.0.0`) |
| Departments | **18**, across **7 domains**: governance 3 / finance 3 / technology 3 / security 3 / people 2 / growth 2 / delivery 2 (roster in §10.2) |
| Total function blocks | **18** (conservation invariant; the 18 D2 pages' `^## FB-\d+:` headings total 18, exactly one per department; the target value on upgrade to group is 36 — the only upgrade in the whole ladder that changes the block total; gate G4 judges by **target tier**, see §10.1) |
| Error codes | **117** = 18 department prefixes **107** + `SCL_` **10** (`SCL_` is the infrastructure prefix, ten fixed codes, see §10.4) |
| triggers | **66**, in 7 groups (grouped by domain); including the fixed 2 upgrade triggers (`evaluate scaling threshold`, `propose tier upgrade`); all lowercase task-semantic phrases |
| frontmatter | ≤ **150** lines; the `permissions` block is copied character-for-character from §9.1 and **must never be modified under any circumstance** |
| SKILL.md body | ≤ **120** lines, containing only the 8 whitelisted categories of §6.2 |
| Governance & community files | **13** (including `AGENTS.md`), uniform across all tiers, never trimmed |
| prompts | **4**: `01-implement-method.md` / `02-robustness-checks.md` are `human-paste`, `03-test-cases.md` / `04-documentation.md` are `agent-invoked` |
| Execution engine | 4 execution modes (Auto/Approve/Review/Hybrid) × 4 trigger classes; core set WFT-001~010, **9** enabled at this tier (WFT-009 is group-tier only) |
| Routing | Two levels: domain (choose 1 of 7) → department (choose ≤1 of 3); the `department` enum is **inlined** in the frontmatter (auto + 18 items, P30); the authoritative copy is in `references/department-index.md` |
| D3 layer | **Enabled**: 4 files per department (`department-spec.md` + `prompts/`×2 + `references/method-patterns.md`); the D4 engine layer is introduced only at group tier |
| Shared modules | `references/exec` (4) / `mem` (2) / `viz` (4) / `data` (3) + `models/` (13) — enabled at tier L |
| Memory system / circuit breaker / board ladder / model management / visualization / data integration | **Enabled** at large tier (the full headquarters/branch form of the board ladder is at group tier) |
| Total files | **148** (package file set, see §3; repository tooling directories are not counted) |
| `description` | ≤ **1024** characters (SkillImport hard validation, P16) |

<!-- 中文原文（2026-10-21 英译前版本，仅供对照；§1 中"三条相邻边 / large→group 边尚未实现（SCL_002）"为过时陈述，译文已按 2026-10-20 升级机制修改后的现行事实修正为七对边 + 脚手架，与 §16 表一致）：
# README FOR AI — ai-company 大型档生成与维护规格（自包含版）

> **文档性质**：这是给 LLM Agent 阅读的**生成规格**，不是项目介绍。
> 读本文的 Agent 的任务是：**从零生成、再生或扩展 `ai-company` 这个 LLM Agent 治理技能包的大型档（large tier）**，并保持其与本文一致。
>
> **自包含声明（重要）**：本文是 `ai-company` 技能包**大型档**的生成与维护规格，**完全自包含**——生成/维护本档所需的全部参数、契约、红线、验收项都已内联在本文，**不依赖、不引用任何外部或上层规格文档**。本文任何章节号（如 §9.1）与红线号（如 P21）都是**本地定义**，包内其他文件的 `(README_FOR_AI.md §x.y)` / `P##` 引用一律指向本文。
>
> ⚠️ 本文不参与技能运行时路由。运行时唯一入口是 `SKILL.md`；面向维护仓库的编码 Agent 的简明贡献入口是 `AGENTS.md`。三者职责互斥，不得互相复述内容（见 P55）。

---

## 1. AI-COMPANY 项目与本包定位

AI-COMPANY 是一套**供 LLM Agent 使用的企业治理规范**：把 AI Agent 建模为公司员工，用部门、职能块、错误码、权限边界与升级路径来治理 Agent 行为。它按公司规模分**五档**（该阶梯由本文 §1 本地定义，无需任何外部文档）：

| 档位 | `scale_tier` | major | 部门数 | 职能块 | 结构 |
|---|---|---|---|---|---|
| 微型 XS | `micro` | 1 | 2 | 18 | 扁平（D1+D2） |
| 小型 S | `small` | 2 | 5 | 18 | 扁平 |
| 中型 M | `medium` | 3 | 9 | 18 | 扁平 + 共享模块 |
| 大型 L | `large` | 4 | 18 | 18 | 三层 + 域路由 |
| 集团 G | `group` | 5 | 36 | 36 | 四层 + 总分公司 |

**本包 = ai-company 的大型档实例**（`scale_tier: large`，v4.0.0；major = 档位序号 = 4）。档位不是单向门：技能可在运行中检测规模溢出、**自主提案**升档，但安装须人工批准（§12）。更高档位的完整结构遵循同一套合并树原则（§10.1）；`scripts/self-scale.ps1` 随基础血统实现 `micro → small`、`small → medium`、`medium → large` 三条相邻升级边，`large → group` 边尚未实现（在 large 档提案返回 `SCL_002`）。

**生成任何 AI-COMPANY 包的唯一人工决策是档位**（微型/小型/中型/大型/集团）；本包已锁定**大型**。

-->
<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 2. 锁定参数（large 档，生成时逐项对齐，勿跨档混用）

| 参数 | 值 |
|---|---|
| `scale_tier` | `large`（major = 4，当前版本 `4.0.0`） |
| 部门 | **18**，跨 **7 域**：governance 3 / finance 3 / technology 3 / security 3 / people 2 / growth 2 / delivery 2（名册见 §10.2） |
| 职能块总数 | **18**（守恒不变量；18 个 D2 页 `^## FB-\d+:` 合计 = 18，每部门恰 1 个；升 group 时目标值为 36——全阶梯唯一改变块总数的升级，门 G4 按**目标档**判，见 §10.1） |
| 错误码 | **117** = 18 个部门前缀 **107** + `SCL_` **10**（`SCL_` 为基础设施前缀，十条固定，见 §10.4） |
| triggers | **66** 条，7 组（按域分组）；含固定 2 条升级（`evaluate scaling threshold`、`propose tier upgrade`）；全小写任务语义短语 |
| frontmatter | ≤ **150** 行；`permissions` 块逐字符照抄 §9.1，**任何情形不得改动** |
| SKILL.md 正文 | ≤ **120** 行，只含 §6.2 白名单 8 类内容 |
| 治理与社区文件 | **13** 个（含 `AGENTS.md`），全档位统一不裁剪 |
| prompts | **4** 个：`01-implement-method.md` / `02-robustness-checks.md` 为 `human-paste`，`03-test-cases.md` / `04-documentation.md` 为 `agent-invoked` |
| 执行引擎 | 4 种执行模式（Auto/Approve/Review/Hybrid）× 4 类触发器；核心集 WFT-001~010，本档启用 **9** 个（WFT-009 为 group 档专属） |
| 路由 | 两级：域（7 选 1）→ 部门（≤3 选 1）；`department` 枚举**内联** frontmatter（auto + 18 项，P30），权威副本在 `references/department-index.md` |
| D3 层 | **启用**：每部门 4 文件（`department-spec.md` + `prompts/`×2 + `references/method-patterns.md`）；D4 引擎层 group 档才引入 |
| 共享模块 | `references/exec`（4）/ `mem`（2）/ `viz`（4）/ `data`（3）+ `models/`（13）——L 档启用 |
| 记忆系统 / 熔断 / 董事会阶梯 / 模型管理 / 可视化 / 数据集成 | large 档**启用**（董事会阶梯的完整总分公司形态在 group 档） |
| 文件总数 | **148**（包文件集，见 §3；仓库工具目录不计） |
| `description` | ≤ **1024** 字符（SkillImport 硬校验，P16） |
-->

## 3. File Tree (148-file package file set; the structure must always match the package file set)

```text
ai-company/
├── .editorconfig              # unified editor behavior (LF, UTF-8, indent)
├── .gitattributes             # line-ending policy pinned (* eol=lf); neutralizes local core.autocrlf drift
├── .gitignore                 # wildcard exclusions (REVIEW-*.md, __pycache__/, .skill-upgrade/…, .workbuddy/)
├── .scaling-state.json        # upgrade state (tier_history append-only; ★ package metadata, not ignored)
├── AGENTS.md                  # coding-agent contribution entry (≤150 lines, zero content copying, P55)
├── CHANGELOG.md               # Keep a Changelog format
├── CODE_OF_CONDUCT.md         # Contributor Covenant 2.1
├── CONTRIBUTING.md            # branch / commit / test / acceptance rules
├── LICENSE                    # full GPL-3.0 text (license identical in four places)
├── README_FOR_AI.md           # ★ this document: ai-company large-tier generation & maintenance spec (self-contained)
├── README.en.md               # identical English copy of README.md (language-suffix symmetry)
├── README.md                  # human main entry (structure tree matches disk item by item)
├── README.zh.md               # Chinese version (the six identifier classes are never translated, see §6.3)
├── SECURITY.md                # supported versions / reporting channel / disclosure window / security floor
├── SKILL.md                   # ★ the skill's only runtime entry (frontmatter ≤150 lines + ≤120-line body)
├── _meta.json                 # installer metadata (major = tier ordinal = 4)
├── prompts/
│   ├── 01-implement-method.md     # human-paste (self-contained, H1–H7)
│   ├── 02-robustness-checks.md    # human-paste (self-contained, H1–H7)
│   ├── 03-test-cases.md           # agent-invoked (A1–A5)
│   └── 04-documentation.md        # agent-invoked (A1–A5)
├── references/
│   ├── method-patterns.md     # ★ sole code authority: 10 templates' full code (§3) + 3 frameworks + compliance section
│   ├── error-codes.md         # full four-element table of 117 codes (19 prefixes)
│   ├── scaling.md             # upgrade spec: five-tier ladder merge tree / thresholds / six gates / aliases / downgrade
│   ├── department-index.md    # ★ authoritative 18-department enum (7-domain routing + function-block conservation)
│   ├── execution.md           # execution engine: 4 modes × 4 trigger classes + WFT-001~010 + two-level routing
│   ├── memory.md              # memory system (5 memory classes)
│   ├── visualization.md       # visualization (charts / Mermaid / report templates)
│   ├── data-integration.md    # data integration (financial news / fusion / schema security)
│   ├── integrations.md        # external integrations (MCP / Webhook / REST)
│   ├── departments/           # 90 files = 18 D2 pages + 18 D3 directories × 4 files
│   │   ├── executive-strategy.md      # D2 index page (exactly one ## FB-1:)
│   │   ├── executive-strategy/        # D3 depth layer
│   │   │   ├── department-spec.md     #   SOP / permission boundaries / workflow depth
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   └── references/
│   │   │       └── method-patterns.md #   department-level patterns (copying the ten templates is forbidden)
│   │   ├── operations-coordination.md / operations-coordination/   # same structure as above
│   │   └── …                          # the remaining 16 departments are all the same structure (roster in §10.2)
│   ├── exec/                  # command-center.md · error-recovery.md · modes-triggers.md · workflows-schema.md
│   ├── mem/                   # architecture.md · management-compliance.md
│   ├── viz/                   # chart-types.md · integration-compliance.md · mermaid-diagrams.md · report-templates.md
│   └── data/                  # financial-news.md · information-fusion.md · schema-security.md
├── models/                    # 13 files: registry + calling policy + adapter + API configs + local configs
│   ├── README.md
│   ├── adapters/
│   │   └── adapter_interface.py
│   ├── api/
│   │   ├── anthropic/
│   │   │   └── claude-3-5-sonnet.json
│   │   ├── ollama/
│   │   │   ├── codellama.json
│   │   │   ├── llama3.3.json
│   │   │   ├── mistral.json
│   │   │   └── phi3.json
│   │   ├── openai/
│   │   │   └── gpt-4o.json
│   │   └── template/
│   │       └── config.json
│   ├── config/
│   │   ├── calling-policy.json
│   │   └── models-registry.json
│   └── local/
│       ├── llama-3.3-70b/
│       │   └── config.json
│       └── template/
│           └── config.json
├── scripts/
│   ├── self-scale.ps1         # self-upgrade script (propose-only, six gates, record-metrics host channel)
│   └── scaling-config.json    # upgrade config (thresholds / host metrics / output directory)
└── tests/
    └── test-method-patterns.py  # four assertion classes A/B/C/D + multiple regression groups (§13)
```

> 148 = governance layer 13 + `.gitattributes` 1 + `.scaling-state.json` 1 + `README_FOR_AI.md` (this document) 1 + prompts 4 + references top level 9 + departments 90 + exec 4 + mem 2 + viz 4 + data 3 + models 13 + scripts 2 + tests 1.
> Equivalent arithmetic: root 16 + prompts 4 + refs-top 9 + departments 90 + exec 4 + mem 2 + viz 4 + data 3 + models 13 + scripts 2 + tests 1 = **148** ✓ (root 16 = governance layer 13 + `.gitattributes` + `.scaling-state.json` + this document).
>
> **There is no `references/templates.md`** (forbidden by P44; the sole code authority is `method-patterns.md` §3, see §7.3).
>
> **Package file set boundary (D-1 decision, 2026-10-14)**: **package file set = repository-tracked files − repository tooling directories**. The repository tooling directories are fixed at four kinds: `.git/`, `.github/`, `.workbuddy/`, `.skill-upgrade/` — they are respectively version-control objects, repository collaboration templates, agent workspace state, and local build products; they are **never counted in the file total, never enter the structure tree, and never enter upgrade packages**. `scripts/self-scale.ps1`'s `$ExcludedDirSegments` and `Get-PackageRelativePaths` are the **single implementation point** of this constraint (copy scope and counting basis share it, preventing the two from diverging again). `AGENTS.md`'s "tree matches disk item by item" means "tree matches the **package file set** item by item"; the `README.md` / `README.en.md` / `README.zh.md` sibling trees list only the package file set, and the three must be character-identical.
>
> The 13 governance-layer files (`.editorconfig`, `.gitignore`, `AGENTS.md`, `CHANGELOG.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `LICENSE`, `README.en.md`, `README.md`, `README.zh.md`, `SECURITY.md`, `SKILL.md`, `_meta.json`) are uniform across all tiers and never trimmed (P50).

<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 3. 文件树（148 文件包文件集，结构须与包文件集始终一致）

```text
ai-company/
├── .editorconfig              # 编辑器统一行为（LF、UTF-8、缩进）
├── .gitattributes             # 行尾策略钉死（* eol=lf），抵消本机 core.autocrlf 漂移
├── .gitignore                 # 通配排除（REVIEW-*.md、__pycache__/、.skill-upgrade/…、.workbuddy/）
├── .scaling-state.json        # 升级状态（tier_history 只追加；★ 包元数据，不 ignore）
├── AGENTS.md                  # 编码 Agent 贡献入口（≤150 行，零内容复制，P55）
├── CHANGELOG.md               # Keep a Changelog 格式
├── CODE_OF_CONDUCT.md         # Contributor Covenant 2.1
├── CONTRIBUTING.md            # 分支/提交/测试/验收规则
├── LICENSE                    # GPL-3.0 全文（四处许可同值）
├── README_FOR_AI.md           # ★ 本文：ai-company 大型档生成与维护规格（自包含）
├── README.en.md               # 与 README.md 相同的英文副本（语言后缀对称）
├── README.md                  # 人类主入口（结构树与磁盘逐项一致）
├── README.zh.md               # 中文版（标识符六类不译，见 §6.3）
├── SECURITY.md                # 版本范围/上报渠道/披露时限/安全底线
├── SKILL.md                   # ★ 技能运行时唯一入口（frontmatter ≤150 行 + ≤120 行正文）
├── _meta.json                 # 安装器元数据（major = 档位序号 = 4）
├── prompts/
│   ├── 01-implement-method.md     # human-paste（自包含，H1–H7）
│   ├── 02-robustness-checks.md    # human-paste（自包含，H1–H7）
│   ├── 03-test-cases.md           # agent-invoked（A1–A5）
│   └── 04-documentation.md        # agent-invoked（A1–A5）
├── references/
│   ├── method-patterns.md     # ★ 代码唯一权威源：10 模板完整代码（§3）+ 3 框架 + 合规段
│   ├── error-codes.md         # 117 条四要素全表（19 前缀）
│   ├── scaling.md             # 升级规格：五档阶梯合并树/阈值/六门/别名/降级
│   ├── department-index.md    # ★ 18 部门枚举权威（7 域路由 + 职能块守恒）
│   ├── execution.md           # 执行引擎：4 模式 × 4 触发器 + WFT-001~010 + 两级路由
│   ├── memory.md              # 记忆系统（5 类记忆）
│   ├── visualization.md       # 可视化（图表/Mermaid/报告模板）
│   ├── data-integration.md    # 数据集成（金融新闻/融合/schema 安全）
│   ├── integrations.md        # 外部集成（MCP / Webhook / REST）
│   ├── departments/           # 90 文件 = 18 个 D2 页 + 18 个 D3 目录 × 4 文件
│   │   ├── executive-strategy.md      # D2 索引页（恰 1 个 ## FB-1:）
│   │   ├── executive-strategy/        # D3 深度层
│   │   │   ├── department-spec.md     #   SOP / 权限边界 / 工作流深度
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   └── references/
│   │   │       └── method-patterns.md #   部门级模式（禁复制十模板）
│   │   ├── operations-coordination.md / operations-coordination/   # 同上同构
│   │   └── …                          # 其余 16 个部门全部同构（名册见 §10.2）
│   ├── exec/                  # command-center.md · error-recovery.md · modes-triggers.md · workflows-schema.md
│   ├── mem/                   # architecture.md · management-compliance.md
│   ├── viz/                   # chart-types.md · integration-compliance.md · mermaid-diagrams.md · report-templates.md
│   └── data/                  # financial-news.md · information-fusion.md · schema-security.md
├── models/                    # 13 文件：注册表 + 调用策略 + 适配器 + API 配置 + 本地配置
│   ├── README.md
│   ├── adapters/
│   │   └── adapter_interface.py
│   ├── api/
│   │   ├── anthropic/
│   │   │   └── claude-3-5-sonnet.json
│   │   ├── ollama/
│   │   │   ├── codellama.json
│   │   │   ├── llama3.3.json
│   │   │   ├── mistral.json
│   │   │   └── phi3.json
│   │   ├── openai/
│   │   │   └── gpt-4o.json
│   │   └── template/
│   │       └── config.json
│   ├── config/
│   │   ├── calling-policy.json
│   │   └── models-registry.json
│   └── local/
│       ├── llama-3.3-70b/
│       │   └── config.json
│       └── template/
│           └── config.json
├── scripts/
│   ├── self-scale.ps1         # 自我升级脚本（propose-only，六道门，record-metrics 宿主通道）
│   └── scaling-config.json    # 升级配置（阈值/宿主指标/输出目录）
└── tests/
    └── test-method-patterns.py  # 四类断言 A/B/C/D + 多轮回归组（§13）
```

> 148 = 治理层 13 + `.gitattributes` 1 + `.scaling-state.json` 1 + `README_FOR_AI.md`（本文）1 + prompts 4 + references 顶层 9 + 部门 90 + exec 4 + mem 2 + viz 4 + data 3 + models 13 + scripts 2 + tests 1。
> 等价算术：root 16 + prompts 4 + refs-top 9 + departments 90 + exec 4 + mem 2 + viz 4 + data 3 + models 13 + scripts 2 + tests 1 = **148** ✓（root 16 = 治理层 13 + `.gitattributes` + `.scaling-state.json` + 本文）。
>
> **无 `references/templates.md`**（P44 禁止；模板代码唯一权威源是 `method-patterns.md` §3，见 §7.3）。
>
> **包文件集边界（D-1 决策，2026-10-14）**：**包文件集 = 仓库跟踪文件 − 仓库工具目录**。仓库工具目录固定四类：`.git/`、`.github/`、`.workbuddy/`、`.skill-upgrade/`——它们分别是版本库对象、仓库协作模板、Agent 工作区状态与本地产物，**不计入文件总数、不进结构树、不进升级包**。`scripts/self-scale.ps1` 的 `$ExcludedDirSegments` 与 `Get-PackageRelativePaths` 是本约束的**唯一实现处**（拷贝范围与计数基准共用它，防止二者再次分歧）。`AGENTS.md` 的"树与磁盘逐项一致"即指"树与**包文件集**逐项一致"；`README.md` / `README.en.md` / `README.zh.md` 三兄弟结构树只列包文件集，且三者必须逐字符相同。
>
> 治理层 13 个文件（`.editorconfig`、`.gitignore`、`AGENTS.md`、`CHANGELOG.md`、`CODE_OF_CONDUCT.md`、`CONTRIBUTING.md`、`LICENSE`、`README.en.md`、`README.md`、`README.zh.md`、`SECURITY.md`、`SKILL.md`、`_meta.json`）全档位统一、不裁剪（P50）。
-->

## 4. Regeneration Workflow for This Package from Zero (content dependency order)

| Step | Output | Key constraints (all section numbers refer to this document) |
|---|---|---|
| 0 | Lock the tier | Large (already locked for this package; ask the human first for a new package) |
| 1 | Lock parameters | Copy the §2 table + §10.1 merge tree + §10.2 roster verbatim; never invent departments/slugs/prefixes |
| 2 | Create directories + `.scaling-state.json` | Create directories first; state file spec in §12.6 |
| 3 | `references/method-patterns.md` | The 10 template signatures copied character-for-character from §7.1, full code in §3; `mask_sensitive_data` must cover EMAIL/IP/PHONE; 7-section structure (§7.3) |
| 4 | `references/error-codes.md` | 117 codes numbered continuously with no gaps; the 10 `SCL_` Messages character-identical to §10.4; four-element table |
| 5 | 18 department D2 + D3 | Roster mechanically expanded from `department-index.md` per §10.2; 5 files per department (1 D2 + 4 D3); skeleton per §10.3; 3–7 sections per FB; four-element responsibility entries; no function lost (check against the §10.1 lineage) |
| 6 | 4 `prompts/` files | First-screen skeleton per §11.4; 01/02 satisfy H1–H7, 03/04 satisfy A1–A5 |
| 7 | Shared modules | `references/exec` 4 + `mem` 2 + `viz` 4 + `data` 3 + `models/` 13 |
| 8 | Upgrade four-piece set | `scaling.md` + `self-scale.ps1` + `scaling-config.json` + state file; propose-only; six gates (§12) |
| 9 | `tests/` | Four assertion classes per §13 |
| 10 | `SKILL.md` + `_meta.json` | frontmatter field-by-field per §6.1 (≤150 lines); body ≤120 lines of whitelisted content |
| 11 | 13 governance files | In file-tree ASCII order (`.editorconfig` → ... → `_meta.json`); `AGENTS.md` first-screen responsibility declaration + ≤150 lines |
| 12 | This document `README_FOR_AI.md` | The generation specification of the ai-company large tier |
| 13 | Self-check | Run the §15 acceptance checklist; complete only when everything passes (P39) |

## 5. Hard Rules at a Glance (full list: P1–P55 in §14)

| Rule | Red line | One-liner |
|---|---|---|
| Code stored in exactly one place | P10/P44 | Template code lives only in `method-patterns.md` §3; no file may inline-copy it |
| No SKILL.md in department subdirectories | P1 | Prevents misregistration as an independent skill by loaders |
| Function-block conservation | P6/P33 | After any modification the 18 D2 pages' `## FB-N:` headings must still total 18 |
| SKILL.md is index-only | P43 | No code / full error-code tables / SOP |
| department enum inlined in frontmatter | P30 | The base-bloodline gate G6 requires inlining (auto + tier department count); 18 items still fit within ≤150 frontmatter lines; the authoritative copy is in `department-index.md` |
| Permissions block unmodifiable | P21/P22 | `permissions` stays character-identical, even across upgrades/human approval |
| Upgrades propose only, never self-install | P34–P36 | `self-scale.ps1` has no install/apply/commit value |
| human-paste self-contained | P46 | No internal paths/identifiers referenced |
| Language separation | P47/P48 | Source files English; output follows the user; the six identifier classes are never translated |
| Governance files never trimmed | P50/P53 | All 13 present at every tier; no empty placeholders |
| AGENTS.md never restates | P55 | One-way references, zero content copying, never a second entry point |
| No hardcoded paths | P18 | Always `{SKILL_DIR}`/`{WORKSPACE_ROOT}` placeholders or relative derivation |
| Count claims match disk | P4 | "18 departments / 10 templates / 148 files" must be measured to match |

<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 4. 从零再生本包的工作流（内容依赖顺序）

| Step | 产出 | 关键约束（章节均指本文） |
|---|---|---|
| 0 | 锁定档位 | 大型（本包已锁；新建包时先问人工） |
| 1 | 锁定参数 | 照抄 §2 表 + §10.1 合并树 + §10.2 名册，不得自创部门/slug/前缀 |
| 2 | 建目录 + `.scaling-state.json` | 先建目录；状态文件规格见 §12.6 |
| 3 | `references/method-patterns.md` | 10 模板签名逐字符照抄 §7.1，完整代码入 §3；`mask_sensitive_data` 必含 EMAIL/IP/PHONE 三类；7 章节结构（§7.3） |
| 4 | `references/error-codes.md` | 117 条编号连续无空洞；`SCL_` 十条 Message 与 §10.4 逐字符一致；四要素表 |
| 5 | 18 个部门 D2 + D3 | 名册照 §10.2 从 `department-index.md` 机械展开；每部门 5 文件（1 D2 + 4 D3）；骨架照 §10.3；每 FB 含 3–7 节；职责条目四要素；职能不丢失（对照 §10.1 血统） |
| 6 | `prompts/` 4 个 | 首屏骨架照 §11.4；01/02 满足 H1–H7，03/04 满足 A1–A5 |
| 7 | 共享模块 | `references/exec` 4 + `mem` 2 + `viz` 4 + `data` 3 + `models/` 13 |
| 8 | 升级四件套 | `scaling.md` + `self-scale.ps1` + `scaling-config.json` + 状态文件；propose-only；六道门（§12） |
| 9 | `tests/` | 四类断言照 §13 |
| 10 | `SKILL.md` + `_meta.json` | frontmatter 逐字段照 §6.1（≤150 行）；正文 ≤120 行白名单内容 |
| 11 | 13 个治理文件 | 按文件树 ASCII 顺序（`.editorconfig` → … → `_meta.json`）；`AGENTS.md` 首屏职责声明 + ≤150 行 |
| 12 | 本文 `README_FOR_AI.md` | ai-company 大型档的生成规格 |
| 13 | 自检 | 跑 §15 验收清单，全部通过才算完成（P39） |

-->
<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 5. 硬规则速览（完整清单见 §14 的 P1–P55）

| 规则 | 红线 | 一句话 |
|---|---|---|
| 代码只存一处 | P10/P44 | 模板代码只在 `method-patterns.md` §3；任何文件不得内联复制 |
| 部门子目录不放 SKILL.md | P1 | 防被加载器误注册为独立技能 |
| 职能块守恒 | P6/P33 | 修改后 18 个 D2 页 `## FB-N:` 合计必须仍 = 18 |
| SKILL.md 只做索引 | P43 | 不放代码/完整错误码表/SOP |
| department 枚举内联 frontmatter | P30 | 基础血统门 G6 要求内联（auto + 档位部门数）；18 项计入后 frontmatter 仍 ≤150 行；权威副本在 `department-index.md` |
| 权限块不可改 | P21/P22 | `permissions` 逐字符不变，即使升级/人工批准 |
| 升级只提案不自装 | P34–P36 | `self-scale.ps1` 无 install/apply/commit 取值 |
| human-paste 自包含 | P46 | 不得引用内部路径/标识符 |
| 语言分离 | P47/P48 | 源文件英语；输出跟随用户；标识符六类永不译 |
| 治理文件不裁剪 | P50/P53 | 13 个全档位齐备；不建空占位 |
| AGENTS.md 不复述 | P55 | 单向引用零内容复制，不成为第二入口 |
| 无硬编码路径 | P18 | 一律 `{SKILL_DIR}`/`{WORKSPACE_ROOT}` 占位符或相对推导 |
| 数量宣称与磁盘一致 | P4 | "18 个部门/10 个模板/148 个文件" 必须实测相符 |
-->

---

## 6. SKILL.md Specification

### 6.1 frontmatter (field by field; ≤150 lines total)

```yaml
---
name: "ai-company"   # single-line quoted scalar; block scalars | or > are forbidden (P15)
slug: "ai-company"
version: "4.0.0"                  # major = tier ordinal (large = 4)
description: "<one 700-900-character English paragraph: tier / 7 domains 18 departments / 18 function blocks / shared assets / dual-mode prompts / language policy / self-upgrade / when to use>" (SkillImport hard cap 1024, P16)
license: "GPL-3.0"
author: "AI Company Team"
tags: [<8-16 tags>]
dependencies: []                  # always an empty array
triggers:                         # 66 entries, 7 groups (grouped by domain); see §2
  - ...
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        task:
          type: string
          description: Task description
        department:
          type: string
enum: [auto, <18 department slugs>]     # ★ inlined legal enum (P30; gate G6 validates auto + 18); the authoritative copy is in references/department-index.md
          description: Which department to invoke; omit or "auto" to auto-route
        output_language:
          type: string
          description: Override runtime output language; omit to follow the language decision chain
        context:
          type: object
          description: Optional context information
      required: [task]
  outputs:
    type: object
    schema: { type: object, properties: { result: { type: string, description: Operation result }, report: { type: object, description: Detailed report data } }, required: [result] }
errors: []                      # the full table is in references/error-codes.md, left empty here (P17)
error_code_prefixes: [BRD_, CEO_, CFO_, CHO_, CISO_, CLO_, CMO_, COO_, CQO_, CRO_, CTO_, FW_, INTEL_, IRP_,
  KNM_, MDL_, PMGR_, PRC_, SCL_]   # 19 prefixes; list prefixes only, not individual codes
language_policy:                # required block in the base bloodline (asserted present by R3-4); the four fields agree with the §6.3 source-file standard
  authoring: en
  encoding: utf-8
  output: user-specified
  fallback: en
  immutable_tokens: [slug, error_code, field_name, enum_value, file_path, function_name]
self_scaling:
  enabled: true
  state_file: .scaling-state.json
  spec: references/scaling.md
  upgrade_policy: propose-only    # must be propose-only (P36)
  max_tier: group
permissions:                      # ★ copy character-for-character from §9.1; never changes
  files:
    read:  ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
    write: ["{WORKSPACE_ROOT}/**"]
    deny:  ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]
  network: []
  commands: []
  mcp: [sessions_send, subagents]
quality:
  idempotent: true
metadata:
  category: enterprise
  layer: AGENT
  cluster: governance
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  scale_tier: large               # tier decision recorded (P31)
  department_count: 18
  function_block_count: 18
  harness_baseline: L3
department_aliases: references/scaling.md#alias-map
---
```

> Domain routing (7 domains) and the two-level routing algorithm deliberately have **no** frontmatter fields: the authority is [references/department-index.md](references/department-index.md) (7-domain roster + 18-department enum) and [references/execution.md](references/execution.md) (two-level routing algorithm). The frontmatter `interface` is structurally identical across all base-bloodline tiers (task / department / output_language / context).

`_meta.json`: `{ "ownerId": "ai-company-team", "slug": "ai-company", "version": "4.0.0", "license": "GPL-3.0", "publishedAt": <epoch_ms> }`. The **three** version locations (`_meta.json` / README badge / `SKILL.md` frontmatter) and the **four** license locations (LICENSE / frontmatter / `_meta.json` / metadata) must carry identical values (P11). The former fourth location "`SKILL.md` body title" never existed in any released package and has been removed from this section, §15, `scaling.md`, and gate G6 per decision D-2. This tier's frontmatter **does** set the `language_policy` block (four fields) — consistent with the §6.3 source-file standard; base-bloodline test R3-4 asserts its presence (document what is implemented, P24).

### 6.2 Body Whitelist (≤120 lines; any blacklisted content makes the body non-conforming, P43)

**Only 8 categories are allowed**: ① one-sentence positioning (≤3 lines) ② domain index (1 line per each of the 7 domains) ③ department index table (18 departments, grouped by domain: slug / prefix / one-sentence function / D2 link) ④ shared-resource quick reference (link table pointing to method-patterns / error-codes / scaling / execution, etc.) ⑤ error-code **prefix** list (prefixes and meanings only, no individual codes) ⑥ prompts index (4: file name / mode / one-sentence purpose) ⑦ 3–5 quick-start steps ⑧ frontmatter.

**Blacklist** (belongs in the corresponding file): any code implementation → method-patterns.md §3; full four-element error-code table → error-codes.md; SOP/handling steps → department D3 `department-spec.md`; department responsibility prose (beyond one sentence) → D2; upgrade thresholds/gates/alias tables → scaling.md; full prompt-framework text → method-patterns.md §4; count claims that disagree with reality (P4).

**Index hard requirements**: zero orphans (every .md under references and prompts is referenced at least once, P8); zero broken links (relative link targets really exist); count claims match disk (P4).

### 6.3 Language Policy and Source-File Standard

- **Authoring language (source files) = the computer's standard language**: English; standard grammar; UTF-8 without BOM; code blocks use language-tagged fences (```` ```python ````, bare fences are forbidden); ISO 8601 with timezone; SPDX license identifiers. Mixed Chinese-English wording is limited to pre-existing terminology annotations.
- **Output language = the user-specified language**: determined by the runtime decision chain (explicit user > task context > `fallback: en`); **source files must never hardcode the output language** (P47).
- **The six identifier classes are never translated** (P48): slug / error code / field name / enum value / file path / function name. `README.zh.md` is especially prone to violating this.

<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 6. SKILL.md 规格

### 6.1 frontmatter（逐字段；总行数 ≤150）

```yaml
---
name: "ai-company"   # 单行引号标量，禁用 | 或 > 块标量（P15）
slug: "ai-company"
version: "4.0.0"                  # major = 档位序号（large = 4）
description: "<700-900 字符英文一段话：档位/7 域 18 部门/18 职能块/共享资产/双模式 prompts/语言策略/自我升级/何时使用>"（SkillImport 硬上限 1024，P16）
license: "GPL-3.0"
author: "AI Company Team"
tags: [<8-16 个标签>]
dependencies: []                  # 恒为空数组
triggers:                         # 66 条，7 组（按域分组）；见 §2
  - ...
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        task:
          type: string
          description: Task description
        department:
          type: string
enum: [auto, <18 个部门 slug>]     # ★ 内联合法枚举（P30；门 G6 校验 auto + 18）；权威副本在 references/department-index.md
          description: Which department to invoke; omit or "auto" to auto-route
        output_language:
          type: string
          description: Override runtime output language; omit to follow the language decision chain
        context:
          type: object
          description: Optional context information
      required: [task]
  outputs:
    type: object
    schema: { type: object, properties: { result: { type: string, description: Operation result }, report: { type: object, description: Detailed report data } }, required: [result] }
errors: []                      # 全表在 references/error-codes.md，此处留空（P17）
error_code_prefixes: [BRD_, CEO_, CFO_, CHO_, CISO_, CLO_, CMO_, COO_, CQO_, CRO_, CTO_, FW_, INTEL_, IRP_,
  KNM_, MDL_, PMGR_, PRC_, SCL_]   # 19 个前缀，只列前缀不列具体码
language_policy:                # 基础血统必需块（R3-4 断言其存在）；四字段与 §6.3 源文件标准一致
  authoring: en
  encoding: utf-8
  output: user-specified
  fallback: en
  immutable_tokens: [slug, error_code, field_name, enum_value, file_path, function_name]
self_scaling:
  enabled: true
  state_file: .scaling-state.json
  spec: references/scaling.md
  upgrade_policy: propose-only    # 只能是 propose-only（P36）
  max_tier: group
permissions:                      # ★ 逐字符照抄 §9.1，永不变
  files:
    read:  ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
    write: ["{WORKSPACE_ROOT}/**"]
    deny:  ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]
  network: []
  commands: []
  mcp: [sessions_send, subagents]
quality:
  idempotent: true
metadata:
  category: enterprise
  layer: AGENT
  cluster: governance
  maturity: STABLE
  license: GPL-3.0
  standardized: true
  scale_tier: large               # 档位决策留痕（P31）
  department_count: 18
  function_block_count: 18
  harness_baseline: L3
department_aliases: references/scaling.md#alias-map
---
```

> 域路由（7 域）与两级路由算法**不设** frontmatter 字段：权威在
> [references/department-index.md](references/department-index.md)（7 域名册 + 18 部门枚举）与
> [references/execution.md](references/execution.md)（两级路由算法）。frontmatter 的
> `interface` 与基础血统各档同构（task / department / output_language / context）。

`_meta.json`：`{ "ownerId": "ai-company-team", "slug": "ai-company", "version": "4.0.0", "license": "GPL-3.0", "publishedAt": <epoch_ms> }`。**三处**版本号（`_meta.json` / README badge / `SKILL.md` frontmatter）与四处许可（LICENSE / frontmatter / `_meta.json` / metadata）必须同值（P11）。原第四条"`SKILL.md` 正文标题"从未存在于任何发布包，已按 D-2 决策 A 从本节、§15、`scaling.md` 与门 G6 中移除。本档 frontmatter **设** `language_policy` 块（四字段）——与 §6.3 的源文件标准一致，基础血统测试 R3-4 断言其存在（实现什么写什么，P24）。

### 6.2 正文白名单（≤120 行；出现黑名单内容即不合格，P43）

**只允许 8 类**：① 一句话定位（≤3 行）② 域索引（7 域各 1 行）③ 部门索引表（18 部门，按域分组：slug / 前缀 / 一句话职能 / D2 链接）④ 共享资源速查（指向 method-patterns / error-codes / scaling / execution 等的链接表）⑤ 错误码**前缀**清单（只列前缀与含义，不列具体码）⑥ prompts 索引（4 个：文件名 / mode / 一句话用途）⑦ 快速上手 3–5 步 ⑧ frontmatter。

**黑名单**（应移至对应文件）：任何代码实现 → method-patterns.md §3；完整四要素错误码表 → error-codes.md；SOP/处置步骤 → 部门 D3 `department-spec.md`；部门职责正文（超一句话）→ D2；升级阈值/门控/别名表 → scaling.md；提示词框架全文 → method-patterns.md §4；与实际不符的数量宣称（P4）。

**索引硬要求**：零孤儿（references 与 prompts 下每个 .md 被引用至少一次，P8）；零断链（相对链接目标真实存在）；数量宣称与磁盘一致（P4）。

### 6.3 语言策略与源文件标准

- **编译语言（源文件）= 计算机标准语言**：英语；标准语法；UTF-8 无 BOM；代码块用带语言标识的围栏（```` ```python ````，禁裸围栏）；ISO 8601 带时区；SPDX 许可标识。中英混排仅限既有术语注释。
- **输出语言 = 用户指定语言**：由运行期判定链决定（用户显式 > 任务上下文 > `fallback: en`）；**源文件不得写死输出语言**（P47）。
- **六类标识符永不翻译**（P48）：slug / 错误码 / 字段名 / 枚举值 / 文件路径 / 函数名。`README.zh.md` 尤其易犯。
-->

---

## 7. Code Templates and Prompt Frameworks (sole authority = `references/method-patterns.md`)

### 7.1 Ten Shared Templates (signatures fixed character-for-character; parameter names and default values must not change)

| # | Signature | Purpose | Safety constraint | Harness |
|---|---|---|---|---|
| 1 | `validate_input_schema(data, schema)` | Schema validation | No external I/O | L2 |
| 2 | `sanitize_user_query(query)` | Input sanitization | No dynamic code execution | L3 |
| 3 | `execute_safe_command(cmd, timeout=30)` | Sandboxed execution | Timeout + restricted cwd | L4 |
| 4 | `format_output_json(content, provider)` | Standard JSON + AIGC label | Embedded AI watermark | L5 |
| 5 | `retry_with_backoff(func, max_retries=3)` | Exponential backoff | Fault tolerance | L3 |
| 6 | `read_reference_file(filepath)` | Safe file read | Path validation, traversal rejected | L3 |
| 7 | `generate_trace_id(prefix="trace")` | Audit trace ID | Stateless | L5 |
| 8 | `check_rate_limit(identifier, limit=10, window=60)` | Rate limiting | Memory only, never persisted | L4 |
| 9 | `mask_sensitive_data(text)` | PII masking | Never logs raw data | L5 |
| 10 | `build_prompt_from_template(template, **kwargs)` | Prompt generation | Input sanitized first | L3 |

**Template 9 (three masking classes, none may be missing; P32 lesson)** — the placeholders are fixed as `[EMAIL]`/`[IP]`/`[PHONE]`; missing any of the three is a defect. Its full implementation exists **only** in `references/method-patterns.md` §3.9 (the sole authority for template code). This document **copies no template code**: every `def <fn>` in the package must hit **exactly one** location (§7.3 acceptance; a recurrence signal for P10/P44).

### 7.2 Three Prompt Frameworks (copied character-for-character)

```text
CRISPE (complex tasks, 6 segments):
[Role] {role_description}
[Result] {desired_output}
[Input] {input_data}
[Steps] {step_by_step}
[Parameters] {constraints}
[Example] {example}

3WEH (clear delegation, 4 segments):
Who: {role}
What: {task}
Why: {purpose}
How: {format_constraints}

Five-Element (enterprise compliance, 5 segments):
Role: {role}
Task: {task}
Context: {context}
Format: {output_format}
Constraint: {constraints}
```

The field-by-field expansion of the frameworks exists **only** in section 4 of `method-patterns.md`; `SKILL.md` writes only the framework name + link.

### 7.3 method-patterns.md Structure and Single-Authority Acceptance

Seven sections: `## 1. Template Index` / `## 2. Prompt Framework Index` / `## 3. Shared Code Templates` (full code of the 10 templates, §3.1–§3.10) / `## 4. Prompt Frameworks (Full)` / `## 5. Compliance Verification` / `## 6. Constraints` / `## 7. Department-Specific Patterns` (large tier: indexes each department's D3 `references/method-patterns.md` department-level patterns; the latter must not copy these ten templates).

Acceptance: all 10 `def <fn>` present; contains `[PHONE]`; `references/templates.md` does **not** exist (P44); every `def <fn>` in the package hits **exactly one** location (P10/P44 recurrence signal); all code blocks use ```` ```python ```` fences.

<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 7. 代码模板与提示词框架（唯一权威源 = `references/method-patterns.md`）

### 7.1 十个共享模板（签名逐字符固定；参数名与默认值不得改）

| # | 签名 | 用途 | 安全约束 | Harness |
|---|---|---|---|---|
| 1 | `validate_input_schema(data, schema)` | Schema 校验 | 无外部 I/O | L2 |
| 2 | `sanitize_user_query(query)` | 输入净化 | 无动态代码执行 | L3 |
| 3 | `execute_safe_command(cmd, timeout=30)` | 沙箱执行 | 超时 + 受限 cwd | L4 |
| 4 | `format_output_json(content, provider)` | 标准 JSON + AIGC 标签 | 内嵌 AI 水印 | L5 |
| 5 | `retry_with_backoff(func, max_retries=3)` | 指数退避 | 容错 | L3 |
| 6 | `read_reference_file(filepath)` | 安全读文件 | 路径校验，越界拒绝 | L3 |
| 7 | `generate_trace_id(prefix="trace")` | 审计追踪 ID | 无状态 | L5 |
| 8 | `check_rate_limit(identifier, limit=10, window=60)` | 限流 | 仅内存，不落盘 | L4 |
| 9 | `mask_sensitive_data(text)` | PII 脱敏 | 不记录原始数据 | L5 |
| 10 | `build_prompt_from_template(template, **kwargs)` | 提示词生成 | 输入先净化 | L3 |

**模板 9（三类脱敏，缺一不可；P32 教训）**——占位符固定 `[EMAIL]`/`[IP]`/`[PHONE]`，三者缺一即判缺陷。其完整实现**只存在于** `references/method-patterns.md` §3.9（模板代码的唯一权威源）。本文件**不复制任何模板代码**：全包每个 `def <fn>` 必须**恰 1 处**命中（§7.3 验收，P10/P44 复发信号）。

### 7.2 三个提示词框架（逐字符照抄）

```text
CRISPE（复杂任务，6 段）:
[Role] {role_description}
[Result] {desired_output}
[Input] {input_data}
[Steps] {step_by_step}
[Parameters] {constraints}
[Example] {example}

3WEH（清晰委派，4 段）:
Who: {role}
What: {task}
Why: {purpose}
How: {format_constraints}

Five-Element（企业合规，5 段）:
Role: {role}
Task: {task}
Context: {context}
Format: {output_format}
Constraint: {constraints}
```

框架的逐字段展开**只存在于** `method-patterns.md` 第 4 节；`SKILL.md` 只写框架名 + 链接。

### 7.3 method-patterns.md 结构与单一权威源验收

七章节：`## 1. Template Index` / `## 2. Prompt Framework Index` / `## 3. Shared Code Templates`（10 模板完整代码，§3.1–§3.10）/ `## 4. Prompt Frameworks (Full)` / `## 5. Compliance Verification` / `## 6. Constraints` / `## 7. Department-Specific Patterns`（large 档：索引各部门 D3 `references/method-patterns.md` 的部门级模式，后者禁复制这十个模板）。

验收：10 个 `def <fn>` 齐全；含 `[PHONE]`；`references/templates.md` **不存在**（P44）；全包每个 `def <fn>` **恰 1 处**命中（P10/P44 复发信号）；代码块全 ```` ```python ````。
-->

---

## 8. Harness Maturity

### 8.1 L1–L6 Levels (level definitions must not change; `T<n>` = §7.1 template number)

| Level | Name | Required components (cumulative) | Deliverable |
|---|---|---|---|
| L1 | Skeleton | frontmatter conformance + schema declaration | No |
| L2 | Functional | + input validation (T1) + output formatting (T4) | No |
| **L3** | Robust | + error handling + retry (T5) + **idempotency** | **Yes (delivery floor)** |
| L4 | Resilient | + rate limiting (T8) + circuit breaker + timeout + monitoring | Yes |
| L5 | Compliant | + AIGC triple labeling (T4) + PII masking (T9) + audit trace (T7) | Yes |
| L6 | Certified | + STRIDE + CVSS + CISO sign-off | Yes |

### 8.2 Delivery Floor and Declaration Locations

- **Cumulative**: L4 must include all L3 components; **skipping levels in declarations is forbidden** (claiming L5 without an idempotency implementation counts as L2 and is recorded as a defect).
- **Delivery floor L3**: no capability unit that writes a deliverable may fall below L3; customer-facing output (leaving this organization) may not fall below L5.
- **Declaration locations**: each department's D2 preamble block declares `Department Harness Baseline: L3`; each function block's `### 7. Quality Metrics` first line declares `Harness Level: L<n>` (n≥3). Declaring a level higher than the checkable evidence violates P49/P24.
- Three-layer error recovery (required at L4): operation-level exponential backoff → transaction-level rollback (delete-then-restore is forbidden, P23) → service-level circuit breaker (CLOSED→OPEN→HALF_OPEN).

### 8.3 Idempotency

All operations are safely retryable (`quality.idempotent: true`); non-idempotent operations must not be retried automatically.

---

## 9. Security and Compliance Invariants (never trimmed at any tier)

### 9.1 Permission Declaration (copied character-for-character; ⚠️ not modifiable even by self-upgrade)

```yaml
permissions:
  files:
    read:  ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
    write: ["{WORKSPACE_ROOT}/**"]
    deny:  ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]
  network: []
  commands: []
  mcp: [sessions_send, subagents]
```

- Write permission is **strictly limited** to `{WORKSPACE_ROOT}`; the skill directory `{SKILL_DIR}` itself is **read-only** (P21).
- No item of the `deny` 5 may be removed (P22, a P0-level security boundary, large tier included).
- Always use the `{WORKSPACE_ROOT}`/`{SKILL_DIR}`/`{WINDOWS_DIR}` placeholders; **hardcoded absolute paths are forbidden** (P18).
- `network`/`commands` are always empty in the root manifest; if a sub-skill needs network capability it declares it in its own D2/D3, without changing the root manifest.
- ⚠️ **Self-upgrade is not a reason to relax this clause**: the three-stage architecture of §12 is designed to enable upgrades while keeping this clause unchanged.

### 9.2 AIGC Triple Labeling (missing any one is non-compliant)

| # | Layer | Carrier | Form |
|---|---|---|---|
| 1 | Explicit label | Visible with the content | `> AI-Generated Content` or an equivalent statement |
| 2 | Implicit metadata | Structured output | `"ai_generated": true`, `"generated_at": "<ISO8601>"`, `"model": "<provider/model>"` |
| 3 | Embedded watermark | The content itself | Injected by `format_output_json`(T4), bound to provider + timestamp + content digest |

> **Layer 3's strength must be described honestly (P24)**: it is a **tamper-evident** disclosure marker, not a cryptographic watermark. The watermark is derived with the content digest participating, so editing the body invalidates it and it survives copy-paste; but the trailing disclosure line can still be deleted in one pass. **It must no longer be written as "cannot be simply deleted"** — that claim has been empirically falsified (`out.split("\n\n> Warning:")[0]` strips it in one line with the body intact). When a non-strippable marker is needed, use an external signature outside this envelope; this envelope does not provide that capability.

### 9.3 PII Masking Mandatory

`mask_sensitive_data`(T9) is enforced in **all output pipelines**; **all three classes EMAIL/IP/PHONE must be present** (missing any one is a defect, P32); masking happens **before** any persistence/logging/external transmission; raw data must never be logged.

The three placeholders `[EMAIL]`/`[IP]`/`[PHONE]` are all **contractual**; no class branch may be deleted when fixing them. The phone branch must cover international prefixes and separator spellings (`+86` / `0086` / `138-0013-8000` / `138 0013 8000`); matching only "11 consecutive digits" would miss the three most common written forms (already listed as regression cases in §7.1).

### 9.4 Security Floor (non-negotiable)

- **Zero dynamic code execution**: no `eval`/`exec` on user input; none of the three cmdlet classes for dynamic expression evaluation / string download / web requests (P25; these tokens are written assembled-at-runtime everywhere in this package and their literal appearance is forbidden — the Registry Safety Posture section of `method-patterns.md` therefore only describes them, never spells them).
- **Zero hardcoded secrets**: always via environment variables; configuration holds variable names only, never values — not even "example secrets" (P20). Subprocess environment scrubbing matches on **variable-name fragments** (`_is_secret_env_name`) and must cover real names such as `AWS_SECRET_ACCESS_KEY`, `GITHUB_TOKEN`, `OPENAI_APIKEY`; **prefix-only matching (`api_`/`token`/`secret`/`password`/`key_`) is a verified leak** and must not be reverted to.
- **The command blacklist is a best-effort first line of defense, not a sandbox boundary**: it matches only the invoked program name, and any permitted interpreter can still accomplish deletion (`python -c "os.remove(...)"`, `git clean -fd`, `find . -delete`). The real boundary is the host permission set declared in §9.1.
- **Zero sensitive-path access**: the `deny` 5 items exclude proactively; `read_reference_file`(T6) must **fail closed** and refuse to read when `{SKILL_DIR}` is not configured, never falling back to the current working directory.
- **Zero self-rewriting**: the skill must not write to `{SKILL_DIR}` (P21/P36), see §9.5.
- **Idempotency**: all operations are safely retryable (§8.3).
- **Rollback must never delete-then-restore**: `Copy-Item` to a temporary directory → verify → atomic replace → delete the old only after success is confirmed (P23).

### 9.5 ⚠️ Three Things That Can Never Be Self-Modified (not waivable even by human approval)

| # | Immutable item | Consequence if modified | Gate | Error code |
|---|---|---|---|---|
| 1 | The `permissions` block (including write scope and the deny 5) | Self-escalation: can grant itself `{SKILL_DIR}` write access and delete deny items | G1/G3 | `SCL_004` |
| 2 | All files under `tests/**` | Self-exemption: can change acceptance expectations to hide defects | G2 | `SCL_005` |
| 3 | The gate logic in `scripts/self-scale.ps1` | Can switch off its own safety gates | G3 | `SCL_004` |

What human approval applies to is a **business-scale change**, never a **security-boundary change**; security-boundary changes must go through regenerating this specification plus a human audit.

<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 8. Harness 成熟度

### 8.1 L1–L6 分级（不得改级定义；`T<n>` = §7.1 模板编号）

| 级 | 名称 | 必备构件（累加） | 可交付 |
|---|---|---|---|
| L1 | Skeleton | frontmatter 合规 + schema 声明 | 否 |
| L2 | Functional | + 输入校验(T1) + 输出格式化(T4) | 否 |
| **L3** | Robust | + 错误处理 + 重试(T5) + **幂等** | **是（交付下限）** |
| L4 | Resilient | + 限流(T8) + 熔断 + 超时 + 监控 | 是 |
| L5 | Compliant | + AIGC 三重标识(T4) + PII 脱敏(T9) + 审计追踪(T7) | 是 |
| L6 | Certified | + STRIDE + CVSS + CISO 签核 | 是 |

### 8.2 交付下限与声明位置

- **累加性**：L4 必含 L3 全部构件；**不得跳级声明**（声称 L5 却无幂等实现按 L2 计并记缺陷）。
- **交付下限 L3**：任何写入交付物的能力单元不得低于 L3；面向客户（产出离开本组织）不得低于 L5。
- **声明位置**：每个部门 D2 引言块声明 `Department Harness Baseline: L3`；每个职能块 `### 7. Quality Metrics` 首行声明 `Harness Level: L<n>`（n≥3）。声明级别高于可查证据即违反 P49/P24。
- 三层错误恢复（L4 必备）：操作级指数退避 → 事务级回滚（禁先删后恢复，P23）→ 服务级熔断（CLOSED→OPEN→HALF_OPEN）。

### 8.3 幂等

所有操作可安全重试（`quality.idempotent: true`）；非幂等操作不得自动重试。

---

-->
<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 9. 安全与合规不变量（任何档位不得裁剪）

### 9.1 权限声明（逐字符照抄；⚠️ 自我升级也不得改动）

```yaml
permissions:
  files:
    read:  ["{WORKSPACE_ROOT}/**", "{SKILL_DIR}/**"]
    write: ["{WORKSPACE_ROOT}/**"]
    deny:  ["~/.ssh/**", "~/.aws/**", "~/.config/**", "/etc/**", "{WINDOWS_DIR}/**"]
  network: []
  commands: []
  mcp: [sessions_send, subagents]
```

- 写权限**严格限于** `{WORKSPACE_ROOT}`；技能目录 `{SKILL_DIR}` 自身**只读**（P21）。
- `deny` 5 项**不得删减任何一项**（P22，P0 级安全边界，大型档也不例外）。
- 一律用 `{WORKSPACE_ROOT}`/`{SKILL_DIR}`/`{WINDOWS_DIR}` 占位符，**禁硬编码绝对路径**（P18）。
- `network`/`commands` 在根清单恒空；子技能如需网络能力在自己的 D2/D3 声明，不改根清单。
- ⚠️ **自我升级不构成放宽本条的理由**：§12 的三段式架构正是为在保持本条不变的前提下实现升级而设计。

### 9.2 AIGC 三重标识（缺一即不合规）

| # | 层 | 载体 | 形态 |
|---|---|---|---|
| 1 | 显式标签 | 内容可见处 | `> AI-Generated Content` 或等价声明 |
| 2 | 隐式元数据 | 结构化输出 | `"ai_generated": true`、`"generated_at": "<ISO8601>"`、`"model": "<provider/model>"` |
| 3 | 内嵌水印 | 内容本体 | 由 `format_output_json`(T4) 注入，绑定 provider + 时间戳 + 内容摘要 |

> **第 3 层的强度必须诚实描述（P24）**：它是**防篡改可发现**（tamper-evident）的披露标记，不是密码学水印。水印由内容摘要参与派生，改动正文即失效，可复制粘贴存活；但末尾那行披露声明仍可被一次性删掉。**不得再写成"不可被简单删除"**——该表述已被实测证伪（`out.split("\n\n> Warning:")[0]` 一行即可剥离且正文完好）。需要不可剥离标记时，应在信封之外做外部签名，本信封不提供该能力。

### 9.3 PII 脱敏强制

`mask_sensitive_data`(T9) 在**所有输出管道**强制启用；**EMAIL/IP/PHONE 三类齐全**（缺一即缺陷，P32）；脱敏**先于**任何落盘/日志/外发；原始数据不得记入日志。

三类占位符 `[EMAIL]`/`[IP]`/`[PHONE]` 均为**契约性**存在，改正则时不得删除任何一类分支。手机号分支须覆盖国际码与分隔符写法（`+86` / `0086` / `138-0013-8000` / `138 0013 8000`），只匹配"连续 11 位"会漏掉最常见的三种书写形式（§7.1 已列为回归用例）。

### 9.4 安全底线（不可协商）

- **零动态代码执行**：无 `eval`/`exec` 处理用户输入；无动态表达式求值 / 字符串下载 / 网页请求三类 cmdlet（P25；这些令牌在本包任何文件中都按运行时拼装书写，禁字面出现——`method-patterns.md` 的 Registry Safety Posture 段即因此只描述不拼写）。
- **零硬编码密钥**：一律走环境变量，配置只写变量名不写值——连"示例密钥"也不行（P20）。子进程环境擦除按**变量名片段**匹配（`_is_secret_env_name`），须覆盖 `AWS_SECRET_ACCESS_KEY`、`GITHUB_TOKEN`、`OPENAI_APIKEY` 等真实命名；**仅按前缀匹配（`api_`/`token`/`secret`/`password`/`key_`）属已验证的泄漏**，不得回退。
- **命令黑名单是尽力而为的第一道防线，不是沙箱边界**：只匹配被调用程序名，任何允许的解释器仍可完成删除（`python -c "os.remove(...)"`、`git clean -fd`、`find . -delete`）。真正的边界是 §9.1 声明的宿主权限集。
- **零敏感路径访问**：`deny` 5 项主动排除；`read_reference_file`(T6) 在 `{SKILL_DIR}` 未配置时须 **fail-closed** 拒绝读取，不得退回当前工作目录。
- **零自我改写**：技能不得写入 `{SKILL_DIR}`（P21/P36），见 §9.5。
- **幂等**：所有操作可安全重试（§8.3）。
- **回滚不得先删后恢复**：`Copy-Item` 到临时目录 → 校验 → 原子替换 → 确认成功后才删旧（P23）。

### 9.5 ⚠️ 三件绝不可自我修改的东西（即使人工批准也不得放行）

| # | 不可修改项 | 后果 | 门 | 错误码 |
|---|---|---|---|---|
| 1 | `permissions` 块（含 write 范围与 deny 5 项） | 自我提权：可给自己加 `{SKILL_DIR}` 写权限、删 deny 项 | G1/G3 | `SCL_004` |
| 2 | `tests/**` 全部文件 | 自我豁免：可改验收期望值掩盖缺陷 | G2 | `SCL_005` |
| 3 | `scripts/self-scale.ps1` 门控逻辑 | 可关闭自己的安全门 | G3 | `SCL_004` |

人工批准的对象是**业务规模变更**，不是**安全边界变更**；安全边界变更须通过重新生成本规格 + 人工审计。
-->

---

## 10. Departments and Error Codes

### 10.1 Merge Tree and the large → group Split

**Core invariant**: any large-tier department = the union of several atomic departments split out of a small-tier department; upgrades split **mechanically** along the merge tree, with no improvisation. Function-block conservation: tiers XS/S/M/L are always **18**, tier G is **36** (`large → group` is the **only** upgrade in the whole ladder that changes the block total; gate G4 judges by the **target tier**'s expected value, not the source tier).

Each of the 18 large-tier departments splits into exactly **2** `group` atomic departments (`references/scaling.md` §3 is the sole authority for this table; this is a summary):

| # | large department | → group atomic departments | Domain |
|---|---|---|---|
| 1 | `executive-strategy` | `executive-office` (CEO_) + `strategy-planning` (STP_) | governance |
| 2 | `operations-coordination` | `operations-command` (COO_) + `hq-coordination` (HQ_) | governance |
| 3 | `board-and-branch` | `board-governance` (BRD_) + `branch-management` (BRN_) | governance |
| 4 | `finance-treasury` | `financial-management` (CFO_) + `treasury-budget` (TRS_) | finance |
| 5 | `risk-audit` | `risk-management` (CRO_) + `internal-audit` (AUD_) | finance |
| 6 | `procurement-billing` | `procurement-vendor` (PRC_) + `billing-unit-economics` (BIL_) | finance |
| 7 | `engineering-tooling` | `engineering-architecture` (CTO_) + `developer-tooling` (DXT_) | technology |
| 8 | `platform-mlops` | `platform-framework` (FW_) + `mlops-observability` (MLO_) | technology |
| 9 | `model-data` | `model-management` (MDL_) + `data-engineering` (DTE_) | technology |
| 10 | `security-resilience` | `security-operations` (CISO_) + `resilience-continuity` (RSC_) | security |
| 11 | `legal-privacy` | `legal-compliance` (CLO_) + `privacy-data-protection` (PRV_) | security |
| 12 | `incident-identity` | `incident-response` (IRP_) + `identity-access` (IAM_) | security |
| 13 | `lifecycle-training` | `agent-lifecycle` (CHO_) + `capability-training` (TRN_) | people |
| 14 | `knowledge-ethics` | `knowledge-management` (KNM_) + `ethics-culture` (ETH_) | people |
| 15 | `marketing-partnerships` | `marketing-brand` (CMO_) + `partnerships-ecosystem` (PTN_) | growth |
| 16 | `intelligence-sentiment` | `competitive-intelligence` (INTEL_) + `sentiment-analysis` (SNT_) | growth |
| 17 | `quality-visualization` | `quality-assurance` (CQO_) + `information-services` (INFO_) | delivery |
| 18 | `delivery-scheduling` | `project-management` (PMGR_) + `localization-translation` (TR_) | delivery |

Count: 18 rows × 2 = **36** ✓ — every split is exactly 2-for-2; no row contributes 1 or 3; any deviation means the merge tree is broken (red line P28).

**Function-block arithmetic**: each `large` department has exactly 1 function block (internally covering the scope of the two merged functions, e.g. the single FB of `executive-strategy` covers both `executive-office` and `strategy-planning` functions); each `group` atomic department has 1 = 36. The upgrade **splits each existing block in two**; it invents no new function.

**Visualization attribution note**: chart / Mermaid / report-template work stays inside `quality-visualization` at large tier (same department as the quality function); on upgrade to group, half splits out into `information-services`, and quality and visualization stay together (`quality-assurance`, not a 37th department).

**Prefix inheritance**: on upgrade, the 18 prefixes retired at large tier (`HQ_` `BRN_` `STP_` / `BIL_` `AUD_` `TRS_` / `DTE_` `MLO_` `DXT_` / `PRV_` `IAM_` `RSC_` / `ETH_` `TRN_` / `PTN_` `SNT_` / `INFO_` `TR_`) revive, renumbered from `001`, never inheriting the retired numbering ranges (those ranges covered different function scopes); 18 revived + 18 retained = the group tier's 36 department prefixes. Codes whose function moved go into the Deprecated Code Aliases table in `error-codes.md`.

### 10.2 Roster of the 18 Departments (large tier)

The roster's **authoritative source** is [references/department-index.md](references/department-index.md) (with each department's role, full function text, D2/D3 links, and domain keywords); this is the locked summary:

| Domain | Department slug | Prefix | Role | Core functions |
|---|---|---|---|---|
| governance | [executive-strategy](references/departments/executive-strategy.md) | CEO_ | CEO, Chief Strategy Officer | Strategic decisions, vision, crisis management, executive communication, OKR, roadmap, strategic alignment, market entry |
| governance | [operations-coordination](references/departments/operations-coordination.md) | COO_ | COO, HQ Coordinator | SLA management, resource scheduling, PDCA, cross-department coordination, agent routing, message bus, knowledge sync, audit tracing |
| governance | [board-and-branch](references/departments/board-and-branch.md) | BRD_ | Board Secretary, Branch Manager | Board escalation ladder, authorization matrix, shareholder reports, headquarters/branch model, branch lifecycle, remote communication, cross-border deployment |
| finance | [finance-treasury](references/departments/finance-treasury.md) | CFO_ | CFO, Treasurer | Budget approval and variance, pricing models, financial analysis, cash position, DSO/DPO, capex policy |
| finance | [risk-audit](references/departments/risk-audit.md) | CRO_ | CRO, Chief Auditor | FAIR quantification, circuit breakers, risk thresholds, stage gates, internal audit, financial compliance, evidence retention |
| finance | [procurement-billing](references/departments/procurement-billing.md) | PRC_ | Procurement Lead, Billing Lead | Vendor evaluation, contract cost control, procurement approval, metered billing, cost allocation, unit economics |
| technology | [engineering-tooling](references/departments/engineering-tooling.md) | CTO_ | CTO, Developer Tooling Lead | Architecture decisions, agent creation, three-stage deployment gates, internal tooling, SDK, developer experience, template library |
| technology | [platform-mlops](references/departments/platform-mlops.md) | FW_ | Framework Steward, MLOps Lead | Framework standards, CI/CD, Harness L1–L6, ADR, scaffolding, model health monitoring, A/B testing, observability |
| technology | [model-data](references/departments/model-data.md) | MDL_ | Model Manager, Data Engineer | Model registry, calling policy, adapters, model governance and access control, data pipelines, schema management, multi-source fusion |
| security | [security-resilience](references/departments/security-resilience.md) | CISO_ | CISO, Resilience Lead | STRIDE threat modeling, CVSS scoring, security gates, penetration testing, business continuity, disaster recovery, RTO/RPO |
| security | [legal-privacy](references/departments/legal-privacy.md) | CLO_ | CLO, Privacy Officer | Legal review, AIGC compliance, DMCA, intellectual property, PII handling, GDPR/PIPL/CCPA, data residency |
| security | [incident-identity](references/departments/incident-identity.md) | IRP_ | Incident Commander, IAM Lead | Security incident lifecycle, forensics, regulatory notification, authentication, authorization, credential management, mTLS, least privilege |
| people | [lifecycle-training](references/departments/lifecycle-training.md) | CHO_ | CHO, Training Lead | Agent onboarding/offboarding, headcount planning, skill-gap analysis, capability matrix, certification |
| people | [knowledge-ethics](references/departments/knowledge-ethics.md) | KNM_ | Knowledge Steward, Ethics Reviewer | Knowledge extraction, learning pipelines, memory governance and consolidation, ethics review, culture audit, whistleblower channel |
| growth | [marketing-partnerships](references/departments/marketing-partnerships.md) | CMO_ | CMO, Partnerships Lead | Brand tone, GTM planning, NPS, content, partnership evaluation, ecosystem and channel management |
| growth | [intelligence-sentiment](references/departments/intelligence-sentiment.md) | INTEL_ | Intelligence Officer, Sentiment Analyst | Six-stage intelligence cycle, intelligence library SOP-L01~L06, SITREP, source-reliability scoring, sentiment collection and analysis |
| delivery | [quality-visualization](references/departments/quality-visualization.md) | CQO_ | CQO, Information Services Lead | Quality gates, test coverage, DORA, idempotency verification, documentation completeness, chart and Mermaid generation, report templates, location/weather/time services, multi-source fusion |
| delivery | [delivery-scheduling](references/departments/delivery-scheduling.md) | PMGR_ | Programme Manager, Localization Lead | Project scheduling, sprint commitments, ticket SLA, customer escalation, task decomposition, translation quality, cultural adaptation, language routing |

### 10.3 Department D2 Index Page Skeleton (uniform across all departments; the variant count must = 1)

```markdown
# <Department Display Name>

> D2 index page. Domain: `<domain>`. Depth: [<slug>/](<slug>/).
> Function blocks: **1**                ← for the conservation check
> Department Harness Baseline: L3.      ← required (§8.2)
> Consolidates the `group`-tier atomic departments `<a>` (<PRE_>) and
> `<b>` (<PRE_>).

## 1. Trigger Scenarios        ← 5–10 natural-language task descriptions
## 2. Core Identity            ← role positioning, permission boundaries, reporting lines, domain

## FB-1: <ROLE>                ← exactly 1 function block per department at large tier
### 3. Core Responsibilities   ← each entry has the four elements [responsibility + input + output + SLA]
### 4. Error Codes             ← this department's four-element error-code table (same code, same wording as error-codes.md)
### 5. Integration Points      ← which departments to collaborate with, through what mechanism
### 6. Constraints             ← list of prohibited items
### 7. Quality Metrics         ← first line Harness Level: L<n> (n≥3), then quantifiable metrics + thresholds

## Prompts                     ← L/G-tier-only section: points to this department's D3 prompts/
## Workflows                   ← L/G-tier-only section: the WFT numbers this department carries
```

Section numbering starts at 1 with no gaps (P5); function-block titles are strictly `## FB-1: <ROLE>` (P40); depth content always sinks to D3, and D2 is index-only (progressive disclosure).

### 10.4 Error-Code Rules

- Naming `<PREFIX>_<NNN>`, three digits zero-padded, starting from `001`, **continuous with no gaps** (P14); new codes append at the end, never inserted in the middle. `MDL_` additionally has the `MDL_E<NNN>` sub-namespace for call-time (rather than configuration-time) errors.
- The large tier has **117** = 18 department prefixes **107** + `SCL_` **10**. Per-prefix counts: `CEO_` 8 · `COO_` 6 · `BRD_` 6 · `CFO_` 6 · `CRO_` 6 · `PRC_` 5 · `CTO_` 8 · `FW_` 7 · `MDL_` 7 · `CISO_` 6 · `CLO_` 6 · `IRP_` 5 · `CHO_` 5 · `KNM_` 5 · `CMO_` 5 · `INTEL_` 6 · `CQO_` 5 · `PMGR_` 5 · `SCL_` 10.
- Each entry has **four elements**: `| Code | Message | Trigger Condition | Resolution Steps |`. The four-element table exists only in `error-codes.md` and the department D2 pages; `SKILL.md` lists prefixes only.
- Each D2 FB's `### 4` and the full table in `error-codes.md` are **same code, same wording**; each department's codes belong to exactly one department.

**The ten `SCL_` codes (fixed across all tiers; Message copied character-for-character)**:

```text
SCL_001 Upgrade threshold not met
SCL_002 Requested upgrade has no builder
SCL_003 Alias collision detected
SCL_004 Permission self-modification attempted
SCL_005 Test self-modification attempted
SCL_006 Upgrade package validation failed
SCL_007 Scaling state file corrupted
SCL_008 Target resolution rejected
SCL_009 Tier already at maximum
SCL_010 Function block conservation violated
```

### 10.5 Department Slug Naming Rules

All-lowercase ASCII + hyphens, no spaces/underscores/dots; ≤40 characters; starts and ends with a letter; the abbreviation whitelist is only `hq mlops aigc iam viz dx gdpr`, everything else is spelled out; unique across the package; no domain prefix; always English, never translated (P27/P48); this package's 18 published slugs are permanently retained as aliases (§12.4).

<!-- 中文原文（2026-10-21 英译前版本，仅供对照；§10.4 的 SCL_002/SCL_008 Message 已按 2026-10-20 七对边升级机制修改后的现行实现同步（与 error-codes.md 一致），中文注释保留过时文本）：
## 10. 部门与错误码

### 10.1 合并树与 large → group 拆分

**核心不变量**：大档任一部门 = 小档某部门拆出的若干原子部门之并；升级时按合并树**机械拆分**，不需自由发挥。职能块守恒：XS/S/M/L 档恒 = **18**，G 档 = **36**（`large → group` 是全阶梯**唯一**改变块总数的升级；门 G4 按**目标档**期望值判定，不按来源档）。

`large` 档 18 个部门各拆成恰好 **2** 个 `group` 原子部门（`references/scaling.md` §3 是该表的唯一权威处，此处为摘要）：

| # | large 部门 | → group 原子部门 | 域 |
|---|---|---|---|
| 1 | `executive-strategy` | `executive-office` (CEO_) + `strategy-planning` (STP_) | governance |
| 2 | `operations-coordination` | `operations-command` (COO_) + `hq-coordination` (HQ_) | governance |
| 3 | `board-and-branch` | `board-governance` (BRD_) + `branch-management` (BRN_) | governance |
| 4 | `finance-treasury` | `financial-management` (CFO_) + `treasury-budget` (TRS_) | finance |
| 5 | `risk-audit` | `risk-management` (CRO_) + `internal-audit` (AUD_) | finance |
| 6 | `procurement-billing` | `procurement-vendor` (PRC_) + `billing-unit-economics` (BIL_) | finance |
| 7 | `engineering-tooling` | `engineering-architecture` (CTO_) + `developer-tooling` (DXT_) | technology |
| 8 | `platform-mlops` | `platform-framework` (FW_) + `mlops-observability` (MLO_) | technology |
| 9 | `model-data` | `model-management` (MDL_) + `data-engineering` (DTE_) | technology |
| 10 | `security-resilience` | `security-operations` (CISO_) + `resilience-continuity` (RSC_) | security |
| 11 | `legal-privacy` | `legal-compliance` (CLO_) + `privacy-data-protection` (PRV_) | security |
| 12 | `incident-identity` | `incident-response` (IRP_) + `identity-access` (IAM_) | security |
| 13 | `lifecycle-training` | `agent-lifecycle` (CHO_) + `capability-training` (TRN_) | people |
| 14 | `knowledge-ethics` | `knowledge-management` (KNM_) + `ethics-culture` (ETH_) | people |
| 15 | `marketing-partnerships` | `marketing-brand` (CMO_) + `partnerships-ecosystem` (PTN_) | growth |
| 16 | `intelligence-sentiment` | `competitive-intelligence` (INTEL_) + `sentiment-analysis` (SNT_) | growth |
| 17 | `quality-visualization` | `quality-assurance` (CQO_) + `information-services` (INFO_) | delivery |
| 18 | `delivery-scheduling` | `project-management` (PMGR_) + `localization-translation` (TR_) | delivery |

计数：18 行 × 2 = **36** ✓——拆分一律 2 对 2，无任何一行贡献 1 或 3；出现偏差即合并树被破坏（红线 P28）。

**职能块算术**：`large` 每部门恰 1 个职能块（内部覆盖两个被合并职能的范围，如 `executive-strategy` 的单个 FB 同时覆盖 `executive-office` 与 `strategy-planning` 的职能）；`group` 每原子部门 1 个 = 36。升级把每个现有块**拆成两个**，不发明新职能。

**可视化归属说明**：图表 / Mermaid / 报告模板类工作在大档留在 `quality-visualization` 内（与质量职能同部门）；升 group 时 `information-services` 一半拆出，质量与可视化仍留在一起（`quality-assurance`，不是第 37 个部门）。

**前缀继承**：升级时 18 个在大档退役的前缀（`HQ_` `BRN_` `STP_` / `BIL_` `AUD_` `TRS_` / `DTE_` `MLO_` `DXT_` / `PRV_` `IAM_` `RSC_` / `ETH_` `TRN_` / `PTN_` `SNT_` / `INFO_` `TR_`）复活，从 `001` 重新起编，不继承退役编号段（该编号段覆盖的是不同职能范围）；18 复活 + 18 保留 = group 档 36 个部门前缀。职能发生移动的旧码进 `error-codes.md` 的 Deprecated Code Aliases 表。

### 10.2 18 部门花名册（large 档）

名册以 [references/department-index.md](references/department-index.md) 为**权威源**（含每部门角色、职能全文、D2/D3 链接与域关键词），此处为锁定摘要：

| 域 | 部门 slug | 前缀 | 角色 | 核心职能 |
|---|---|---|---|---|
| governance | [executive-strategy](references/departments/executive-strategy.md) | CEO_ | CEO, Chief Strategy Officer | 战略决策、愿景、危机管理、高管沟通、OKR、路线图、战略对齐、市场进入 |
| governance | [operations-coordination](references/departments/operations-coordination.md) | COO_ | COO, HQ Coordinator | SLA 管理、资源调度、PDCA、跨部门协调、Agent 路由、message bus、知识同步、审计追踪 |
| governance | [board-and-branch](references/departments/board-and-branch.md) | BRD_ | Board Secretary, Branch Manager | 董事会升级阶梯、授权矩阵、股东报告、总分公司模型、分支生命周期、远程通信、跨境部署 |
| finance | [finance-treasury](references/departments/finance-treasury.md) | CFO_ | CFO, Treasurer | 预算审批与差异、定价模型、财务分析、现金头寸、DSO/DPO、资本支出政策 |
| finance | [risk-audit](references/departments/risk-audit.md) | CRO_ | CRO, Chief Auditor | FAIR 量化、熔断、风险阈值、阶段门、内部审计、财务合规、证据留存 |
| finance | [procurement-billing](references/departments/procurement-billing.md) | PRC_ | Procurement Lead, Billing Lead | 供应商评估、合同成本控制、采购审批、计量计费、成本分摊、单位经济 |
| technology | [engineering-tooling](references/departments/engineering-tooling.md) | CTO_ | CTO, Developer Tooling Lead | 架构决策、Agent 创建、三阶段部署门、内部工具、SDK、开发者体验、模板库 |
| technology | [platform-mlops](references/departments/platform-mlops.md) | FW_ | Framework Steward, MLOps Lead | 框架标准、CI/CD、Harness L1–L6、ADR、脚手架、模型健康监控、A/B 测试、可观测性 |
| technology | [model-data](references/departments/model-data.md) | MDL_ | Model Manager, Data Engineer | 模型注册表、调用策略、适配器、模型治理与访问控制、数据管道、schema 管理、多源融合 |
| security | [security-resilience](references/departments/security-resilience.md) | CISO_ | CISO, Resilience Lead | STRIDE 威胁建模、CVSS 评分、安全门、渗透测试、业务连续性、灾备、RTO/RPO |
| security | [legal-privacy](references/departments/legal-privacy.md) | CLO_ | CLO, Privacy Officer | 法律审查、AIGC 合规、DMCA、知识产权、PII 处理、GDPR/PIPL/CCPA、数据驻留 |
| security | [incident-identity](references/departments/incident-identity.md) | IRP_ | Incident Commander, IAM Lead | 安全事件生命周期、取证、监管通报、认证、授权、凭据管理、mTLS、最小权限 |
| people | [lifecycle-training](references/departments/lifecycle-training.md) | CHO_ | CHO, Training Lead | Agent 入职离职、编制规划、技能差距分析、能力矩阵、认证 |
| people | [knowledge-ethics](references/departments/knowledge-ethics.md) | KNM_ | Knowledge Steward, Ethics Reviewer | 知识提取、学习管道、记忆治理与整合、伦理审查、文化审计、举报通道 |
| growth | [marketing-partnerships](references/departments/marketing-partnerships.md) | CMO_ | CMO, Partnerships Lead | 品牌调性、GTM 规划、NPS、内容、合作评估、生态与渠道管理 |
| growth | [intelligence-sentiment](references/departments/intelligence-sentiment.md) | INTEL_ | Intelligence Officer, Sentiment Analyst | 六阶段情报循环、情报库 SOP-L01~L06、SITREP、来源可靠性评分、舆情收集与分析 |
| delivery | [quality-visualization](references/departments/quality-visualization.md) | CQO_ | CQO, Information Services Lead | 质量门、测试覆盖率、DORA、幂等验证、文档完整性、图表与 Mermaid 生成、报告模板、位置/天气/时间服务、多源融合 |
| delivery | [delivery-scheduling](references/departments/delivery-scheduling.md) | PMGR_ | Programme Manager, Localization Lead | 项目排期、冲刺承诺、工单 SLA、客户升级、任务分解、翻译质量、文化适配、语言路由 |

### 10.3 部门 D2 索引页骨架（所有部门统一；变体数必须 = 1）

```markdown
# <Department Display Name>

> D2 index page. Domain: `<domain>`. Depth: [<slug>/](<slug>/).
> Function blocks: **1**                ← 守恒校验用
> Department Harness Baseline: L3.      ← 必填（§8.2）
> Consolidates the `group`-tier atomic departments `<a>` (<PRE_>) and
> `<b>` (<PRE_>).

## 1. Trigger Scenarios        ← 5–10 条自然语言任务描述
## 2. Core Identity            ← 角色定位、权限边界、汇报关系、所属域

## FB-1: <ROLE>                ← large 档每部门恰 1 个职能块
### 3. Core Responsibilities   ← 每条含【职责描述 + 输入 + 输出 + SLA】四要素
### 4. Error Codes             ← 该部门错误码四要素表（与 error-codes.md 同码同文）
### 5. Integration Points      ← 与哪些部门协作、通过什么机制
### 6. Constraints             ← 禁止事项列表
### 7. Quality Metrics         ← 首行 Harness Level: L<n>（n≥3），其后可量化指标 + 阈值

## Prompts                     ← L/G 档特有段：指向该部门 D3 prompts/
## Workflows                   ← L/G 档特有段：该部门承接的 WFT 编号
```

章节编号从 1 起不跳号（P5）；职能块标题严格 `## FB-1: <ROLE>`（P40）；深度内容一律下沉 D3，D2 只做索引（渐进式披露）。

### 10.4 错误码规则

- 命名 `<PREFIX>_<NNN>`，三位零填充，从 `001` 起，**连续无空洞**（P14）；新增追加末尾不插中间。`MDL_` 另有 `MDL_E<NNN>` 子命名空间，表示调用期（而非配置期）错误。
- large 档 **117** 条 = 18 个部门前缀 **107** + `SCL_` **10**。每前缀计数：`CEO_` 8 · `COO_` 6 · `BRD_` 6 · `CFO_` 6 · `CRO_` 6 · `PRC_` 5 · `CTO_` 8 · `FW_` 7 · `MDL_` 7 · `CISO_` 6 · `CLO_` 6 · `IRP_` 5 · `CHO_` 5 · `KNM_` 5 · `CMO_` 5 · `INTEL_` 6 · `CQO_` 5 · `PMGR_` 5 · `SCL_` 10。
- 每条**四要素**：`| Code | Message | Trigger Condition | Resolution Steps |`。四要素表只存在于 `error-codes.md` 与部门 D2；`SKILL.md` 只列前缀。
- D2 各 FB 的 `### 4` 与 `error-codes.md` 全表**同码同文**；每个部门码恰归属一个部门。

**`SCL_` 十条（全档位固定，Message 逐字符照抄）**：

```text
SCL_001 Upgrade threshold not met
SCL_002 Upgrade path undefined in merge tree
SCL_003 Alias collision detected
SCL_004 Permission self-modification attempted
SCL_005 Test self-modification attempted
SCL_006 Upgrade package validation failed
SCL_007 Scaling state file corrupted
SCL_008 Downgrade requires manual approval
SCL_009 Tier already at maximum (group)
SCL_010 Function block conservation violated
```

### 10.5 部门 slug 命名规范

全小写 ASCII + 连字符，无空格/下划线/点号；≤40 字符；首尾为字母；缩写白名单仅 `hq mlops aigc iam viz dx gdpr`，其余全拼；全包唯一；不加域前缀；永为英语不翻译（P27/P48）；本包 18 个已发布 slug 永久保留为别名（§12.4）。
-->

---

## 11. Prompts: Dual Mode

### 11.1 The Two Modes and Their Symmetry

| Mode | Identifier | Consumer | Core requirement |
|---|---|---|---|
| Human paste | `mode: human-paste` | Human → any AI chat window | **Self-contained**: references none of this skill's internal paths/file names/slugs |
| Agent invocation | `mode: agent-invoked` | Auto-loaded by an agent inside this skill | May use `{SKILL_DIR}` placeholder paths, anchors, error codes, tool declarations |

The large tier has 4 prompts: `01-implement-method.md` and `02-robustness-checks.md` are `human-paste`; `03-test-cases.md` and `04-documentation.md` are `agent-invoked`. Naming is `<two-digit ordinal>-<kebab-case>.md`, with ordinals uniform across tiers and never renumbered by trimming. Zero orphans: every prompt is listed in `SKILL.md`'s Prompts index (with a mode column).

### 11.2 human-paste: Seven Mandatory Constraints (H1–H7)

H1 zero internal paths (no `references/`, `prompts/`, `scripts/`, `{SKILL_DIR}`, `SKILL.md`, `method-patterns`); H2 zero internal identifiers (no department slugs, error codes, `FB-N`, `WFT-NNN`); H3 background inlined (carries a sufficient spec summary, e.g. the 10 template signature list + the three masking placeholders + the AIGC triple-labeling requirement); H4 fill-in slots use `<angle brackets>` with a "fill in before use" list at the top; H5 output contract explicit; H6 language-neutral (includes "respond in the language you are currently using in this conversation"; **must not** hardcode English); H7 platform-neutral (names no agent product).

### 11.3 agent-invoked: Five Mandatory Constraints (A1–A5)

A1 paths use placeholders (`{SKILL_DIR}`/`{WORKSPACE_ROOT}`, hardcoding forbidden); A2 declares the expected artifacts (which files are produced, written where); A3 declares the failure error codes; A4 declares the Harness level (≥L3); A5 references rather than copies (templates are written as anchors such as `method-patterns.md#3-9-mask_sensitive_data`, inlining code is forbidden).

### 11.4 Prompt First-Screen Skeleton (copied character-for-character)

```markdown
---
mode: human-paste            # or agent-invoked
id: 01-implement-method      # matches the file-name stem
title: Implement Method      # English
output_language: user-specified
harness_level: L3
---

> **Mode**: human-paste (paste into any AI chat window)
> **Purpose**: Copy this prompt into any AI chat window and have that AI
> implement one method to the standard below.
> **This file is not invoked automatically by an agent.**
>
> **Fill in before use**:
> - `<METHOD_NAME>` - name of the method to implement
> - `<LANGUAGE>` - target programming language
> - `<CONSTRAINTS>` - project-specific constraints
>
> **Output language**: follow the language you are currently using in this
> conversation.

## Prompt

(The block below is copied as a whole)

## Expected Output

## Self-Check Checklist
```

`agent-invoked` differences: a different `mode` value; drop "fill in before use" and "this file is not invoked automatically by an agent"; add the three items "expected artifact paths", "failure error codes", and "referenced template anchors".

The skeleton is **English**: source files are always English (§6.3); what is copied character-for-character is the **structure** (the five frontmatter keys, the four header lines, the three body headings), not the wording of some language; the four files under `prompts/` are English instances of this skeleton.

<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 11. prompts 双模式

### 11.1 两种模式与对称性

| 模式 | 标识 | 消费者 | 核心要求 |
|---|---|---|---|
| 人工粘贴 | `mode: human-paste` | 人类 → 任意 AI 对话窗口 | **自包含**：不引用本技能任何内部路径/文件名/slug |
| Agent 调用 | `mode: agent-invoked` | 本技能内 Agent 自动加载 | 可用 `{SKILL_DIR}` 占位路径、锚点、错误码、工具声明 |

large 档 4 个 prompt：`01-implement-method.md` 与 `02-robustness-checks.md` 为 `human-paste`；`03-test-cases.md` 与 `04-documentation.md` 为 `agent-invoked`。命名 `<两位序号>-<kebab-case>.md`，序号全档位一致不因裁剪重编号。零孤儿：每个 prompt 被 `SKILL.md` 的 Prompts 索引列出（含 mode 列）。

### 11.2 human-paste 七条强制约束（H1–H7）

H1 零内部路径（不出现 `references/`、`prompts/`、`scripts/`、`{SKILL_DIR}`、`SKILL.md`、`method-patterns`）；H2 零内部标识符（不出现部门 slug、错误码、`FB-N`、`WFT-NNN`）；H3 背景内联（自带足够规范摘要，如 10 模板签名清单 + 三类脱敏占位符 + AIGC 三重标识要求）；H4 填空位用 `<尖括号>` 且顶部列"使用前需填写"清单；H5 输出契约明确；H6 语言中立（含"以你当前对话所用语言输出"，**不得**写死 English）；H7 平台中立（不提任何 Agent 产品名）。

### 11.3 agent-invoked 五条强制约束（A1–A5）

A1 路径用占位符（`{SKILL_DIR}`/`{WORKSPACE_ROOT}`，禁硬编码）；A2 声明期望产物（产出哪些文件、写入哪）；A3 声明失败错误码；A4 声明 Harness 级别（≥L3）；A5 引用而非复制（模板写锚点 `method-patterns.md#3-9-mask_sensitive_data`，禁内联代码）。

### 11.4 prompt 首屏骨架（逐字符照抄）

```markdown
---
mode: human-paste            # or agent-invoked
id: 01-implement-method      # matches the file-name stem
title: Implement Method      # English
output_language: user-specified
harness_level: L3
---

> **Mode**: human-paste (paste into any AI chat window)
> **Purpose**: Copy this prompt into any AI chat window and have that AI
> implement one method to the standard below.
> **This file is not invoked automatically by an agent.**
>
> **Fill in before use**:
> - `<METHOD_NAME>` - name of the method to implement
> - `<LANGUAGE>` - target programming language
> - `<CONSTRAINTS>` - project-specific constraints
>
> **Output language**: follow the language you are currently using in this
> conversation.

## Prompt

(The block below is copied as a whole)

## Expected Output

## Self-Check Checklist
```

`agent-invoked` 差异：`mode` 值不同；去掉"使用前需填写"与"本文件不由 Agent 自动调用"；增加"期望产物路径""失败错误码""引用的模板锚点"三项。

骨架为**英语**：源文件一律英语（§6.3），逐字符照抄的是**结构**（frontmatter 五个键、四行抬头、三个正文标题），不是某种语言的措辞；`prompts/` 下的四个文件即此骨架的英语实例。
-->

---

## 12. Self-Upgrade Mechanism

### 12.1 Three-Stage Architecture (the skill only proposes; it never self-installs)

```text
1 Propose   done by the skill itself: detect thresholds -> resolve the target tier
            (default: the linear adjacent tier; or any selectable target via
            -TargetTier) -> dispatch the edge -> generate the upgrade package at
            {WORKSPACE_ROOT}/.skill-upgrade/<ts>/ -> run the six gates -> emit the
            report -> stop
2 Approve   a human reviews the report and approves (the only human gate)
3 Install   executed by an external trusted installer (the skill never installs, P36)
```

`self-scale.ps1`'s `-Action` accepts only `evaluate`/`propose`/`report`/`status`/`record-metrics` — **there is no install/apply/commit value**. `record-metrics` is only a channel for the host to write T1/T3 metrics (§12.2), not a tier-change action.

### 12.2 Four Trigger Thresholds (large-tier values) and the Host Write-Back Interface

| Trigger | Quantified condition (large) | Provenance | Data source |
|---|---|---|---|
| T1 agent scale overflow | Actual agent count > tier ceiling **200** (`scaling-config.json` → `thresholds.agent_count_ceiling`) | **host-supplied** | `.scaling-state.json` `last_metrics.agent_count`, written by the host runtime |
| T2 function-block overload | Function blocks in any department > mean × 1.5; mean = 18 ÷ 18 = **1.0**, threshold **1.5** → **any department with ≥2 function blocks overflows** | **measured** | `^## FB-\d+:` count across the 18 D2 pages |
| T3 routing accuracy drop | `department: auto` hit rate < **0.85** on **3** consecutive evaluations | **host-supplied** | `last_metrics.routing_accuracy`; the consecutive-miss counter is maintained by the script (`routing_miss_streak`) |
| T4 error-code reuse excess | Share of codes referenced by ≥2 function blocks within a single prefix > **0.25** | **measured** | Live scan of `error-codes.md` + each D2's `### 4` error-code table |

Any hit → autonomously generate a proposal (never auto-install); none hit → update `next_evaluation` (default +30 days), `last_metrics`, and `metrics_provenance`. Thresholds must be quantifiable ("evaluate as needed" is forbidden).

**Reading notes**:

- **T2 at large tier is a deliberate hair trigger**: each department should have exactly 1 block; the moment a 2nd appears, a finer decomposition is needed — precisely the signal that the group tier is due.
- When **T3/T4 hit but T1 does not**, the proposal report must explicitly state "scale has not overflowed but the structure no longer fits"; both causes are legitimate.
- With **`-Force` and nothing triggered**, a proposal is still produced, but the report opens with the `SCL_001` warning; forced runs are never silent.

> **Metric provenance must be distinguished (P24/P32)**: T2/T4 are collected live by the script on every run and **never read back from the state file**; what T1/T3 measure (live agent count, `department: auto` hit rate) cannot be observed by the skill itself and is **host-supplied** — the script only reads host-written values and must label them `[host-supplied]` in `status`/`evaluate` output. **Before the host writes them, T1/T3 cannot fire**, and the output must explicitly state "this is a host-supplied metric still at its default".
> Historical defect (must not recur): T4 once read back `last_metrics.error_code_reuse_ratio` — a value the script itself had written the previous run, forming a closed loop that was always 0.0, so the threshold never fired. **A metric that reads its own previous output is not a metric.**

> **Host write-back interface (full contract in [references/scaling.md](references/scaling.md) §3.1)**: T1/T3 are written by the host through two channels — `-Action record-metrics` (parameters `-AgentCount` / `-RoutingAccuracy` / `-SampleSize` / `-ObservedAt` / `-Source`) and the drop directory (`scaling-config.json` → `host_metrics.drop_dir`, default `{WORKSPACE_ROOT}/.skill-metrics`); the latter is collected at the start of every `evaluate`/`propose`, and accepted files are moved into `processed/` (moved only, never deleted, P23). Drop file shape:
> ```json
> {"metric":"agent_count","value":7,"observed_at":"2026-10-19T00:00:00Z","source":"host-runtime","sample_size":120}
> ```
> Both channels share the same validation (metric names accept only `agent_count`/`routing_accuracy`; the former must be an integer ≥0 and ≤1000000, beyond which it is rejected as a host bug; the latter must be in [0,1]), timestamp (`observed_at` required and parseable), freshness (`host_metrics.max_age_days`, default 45), routing sample threshold (`host_metrics.min_routing_samples`, default 20), and audit path: valid writes land in `host_metrics.<name>` (with `observed_at`/`source`/`sample_size`) and mirror to `last_metrics.<name>`, while appending to `metrics_log` (capped at `host_metrics.log_cap`, default 20). If `record-metrics` records no metric at all, it stops with `SCL_007` — never a silent no-op.
>
> **T1/T3 skip conditions** (metric unavailable → the corresponding threshold is skipped, never fires): ① the host has never written it (no `host_metrics` entry); ② still at factory defaults (`agent_count = 0` / `routing_accuracy = 1.0` — "no samples yet" must not be misread as passing); ③ `observed_at` missing or unparseable; ④ timestamp beyond clock-drift tolerance (more than 1 day in the future); ⑤ observation older than `max_age_days`; ⑥ `routing_accuracy`'s `sample_size` below `min_routing_samples` — in this case T3 is skipped and the consecutive-miss counter does **not** accumulate. T1 fires only when an available `agent_count > 200`; T3 fires only when an available `routing_accuracy < 0.85` and the consecutive counter reaches 3.

### 12.3 Six Upgrade Safety Gates (document what is implemented, P24)

| # | Gate | Check | Failure error code |
|---|---|---|---|
| G1 | Permissions unchanged | Zero change to the upgrade package's `permissions` block (normalized-text hash comparison against the factory baseline; hashes are computed live from the current file and the package file at gate execution time) | `SCL_004` |
| G2 | Tests unchanged | The upgrade package's `tests/**` is byte-identical to the current file (a missing or unexpected file fails; spec step 5h requires a byte-identical copy, so byte-identity is the only passing form) | `SCL_005` |
| G3 | Deny and gate logic unchanged | deny 5 items intact; `self-scale.ps1` hash unchanged (computed live, same as G1) | `SCL_004` |
| G4 | Function-block conservation | Post-upgrade function-block total = the **target tier**'s expected value (36 for large→group) | `SCL_010` |
| G5 | Alias completeness | Every legacy slug has an alias mapping; no one-to-many conflicts | `SCL_003` |
| G6 | Acceptance passed | The machine-checkable subset (file_count=148, frontmatter triple, three-location version consistency, 18 D2 pages, 19-item prefix list, `department` enum not in frontmatter, 03/04 prompts present and agent-invoked ≥L3, no templates.md); failure detail is written to the log and to the state file's `last_failure.detail`; the full §15 acceptance is a manual step | `SCL_006` |

G1–G3 cannot be bypassed (even by human approval). The upgrade package **excludes** repository tooling directories (`.git/`/`.github/`/`.workbuddy/`/`.skill-upgrade/`, §3) and `__pycache__`/`*.pyc`. Each gate has **its own code branch and its own log line**; merging several gates into one `if`, or documenting a gate the code does not implement, is exactly the defect the predecessor package delivered.

### 12.4 Slug Alias Mechanism (backward compatibility)

After an upgrade, all legacy slugs are retained as aliases (written into `scaling.md`'s Alias Map and the frontmatter `department_aliases` pointer). large→group: each of the 18 legacy slugs resolves to **2** successor departments (one-to-many fan-out), e.g. `executive-strategy` → {`executive-office`, `strategy-planning`}. A one-to-many resolution with no `domain`/task hint **must ask**, never guess; unresolvable → `SCL_003`. The alias table is append-only, never deleted; retired slugs must not be reused; a new slug colliding with any historical alias → `SCL_003`, and the upgrade is refused. The frontmatter pointer has the form `department_aliases: references/scaling.md#alias-map` (1 line, counted in the line budget).

### 12.5 Downgrade Policy (automatic downgrade forbidden)

Downgrades are lossy (error codes need remapping, function blocks 36→18, content merging) and **require human approval** (written rationale recorded in `tier_history`); they are never executed automatically (P38); `self-scale.ps1` has no downgrade channel — downgrades follow the manual process, and `SCL_008` semantics are carried by the external installer. Only one tier down is allowed. Downgrades are more dangerous than upgrades: an upgrade only adds files, a downgrade **deletes files and merges content**, and a bad merge permanently loses specification detail — so a downgrade proposal must additionally carry a **destination table for all deleted content** (where every section of every deleted D3/D4 file was merged into).

### 12.6 `.scaling-state.json` (required at every tier)

```json
{
  "schema_version": 1,
  "current_tier": "large",
  "tier_history": [],
  "next_evaluation": "<ISO8601, default +30 days>",
  "last_metrics": { "agent_count": 0, "routing_accuracy": 1.0, "max_blocks_per_department": 1, "error_code_reuse_ratio": 0.0 },
  "routing_miss_streak": 0,
  "metrics_provenance": { "agent_count": "host-supplied", "routing_accuracy": "host-supplied" },
  "host_metrics": {},
  "metrics_log": [],
  "pending_proposals": [],
  "validation": { "gates_passed": 6, "file_count": 148, "acceptance_passed": false }
}
```

Constraints: `current_tier` must agree with the frontmatter `scale_tier` (P41); `tier_history` is **append-only**, never edited or deleted (audit); the **top-level** `validation.gates_passed` must = 6; `validation.file_count` uses this tier's expected value (large **148**); on first generation `tier_history` and `pending_proposals` are empty. The factory defaults for host-supplied metrics are `agent_count = 0` / `routing_accuracy = 1.0` ("no samples yet" must not be misread as failing accuracy). The script also maintains `routing_miss_streak` (the T3 consecutive-miss counter) and `metrics_provenance` (metric provenance labels), and writes `last_failure` (with `code`/`gates_failed`/`detail`/`package_path`) on gate failure. `record-metrics` and the drop directory additionally write `host_metrics` and `metrics_log`. This file is package metadata and is **not** in `.gitignore` (§14.5).

<!-- 中文原文（2026-10-21 英译前版本，仅供对照；§12.1 中"查合并树推导路径"已按 2026-10-20 七对边升级机制修改后的现行实现改写为"解析目标档位（默认线性/`-TargetTier` 任选）→ 分派边"）：
## 12. 自我升级机制

### 12.1 三段式架构（技能只提案，不自装）

```text
① 提案 Propose   技能自己完成：检测阈值 → 查合并树推导路径 → 生成升级包到 {WORKSPACE_ROOT}/.skill-upgrade/<ts>/ → 跑六道门 → 出报告 → 停止
② 批准 Approve   人工审阅报告后批准（唯一人工门）
③ 安装 Install   外部受信任安装器执行（技能永不安装，P36）
```

`self-scale.ps1` 的 `-Action` 只有 `evaluate`/`propose`/`report`/`status`/`record-metrics`——**无 install/apply/commit 取值**。`record-metrics` 只是宿主写入 T1/T3 指标的通道（§12.2），不是档位变更动作。

### 12.2 四类触发阈值（large 档值）与宿主写回接口

| 触发器 | 量化条件（large） | 来源性质 | 数据来源 |
|---|---|---|---|
| T1 Agent 规模溢出 | 实际 Agent 数 > 档位上限 **200**（`scaling-config.json` → `thresholds.agent_count_ceiling`） | **宿主供给** | `.scaling-state.json` `last_metrics.agent_count`，由宿主运行时写入 |
| T2 职能块过载 | 任部门职能块数 > 均值 × 1.5；均值 = 18 ÷ 18 = **1.0**，阈值 **1.5** → **任何部门出现 ≥2 个职能块即溢出** | **实测** | 18 个 D2 页 `^## FB-\d+:` 计数 |
| T3 路由准确率下降 | `department: auto` 命中率 < **0.85**，连续 **3** 次 | **宿主供给** | `last_metrics.routing_accuracy`；连续未命中计数由脚本维护（`routing_miss_streak`） |
| T4 错误码复用率过高 | 单前缀下被 ≥2 个职能块引用的码占比 > **0.25** | **实测** | `error-codes.md` + 各 D2 `### 4` 错误码表实时扫描 |

任一命中 → 自主生成提案（不自动安装）；全部未命中 → 更新 `next_evaluation`（默认 +30 天）、`last_metrics` 与 `metrics_provenance`。阈值必须可量化（禁"视情况评估"）。

**解读要点**：

- **T2 在大档是故意的发丝级触发器**：每部门本应恰 1 个块，第 2 个块出现即说明已需要更细分解——这正是 group 档当用的信号。
- **T3/T4 命中而 T1 未命中**时，提案报告须显式写明"规模未溢出但结构已不合身"；两种成因都正当。
- **`-Force` 且无事触发**时仍产出提案，但报告以 `SCL_001` 警告开头；强制作业永不静默。

> **指标来源必须区分（P24/P32）**：T2/T4 由脚本每次运行实时采集，**绝不回读状态文件**；T1/T3 的被测量（存活 Agent 数、`department: auto` 命中率）技能自身观察不到，属**宿主供给**——脚本只读宿主写入的值，且必须在 `status`/`evaluate` 输出中标注 `[host-supplied]`。**在宿主写入之前，T1/T3 不会触发**，此时输出须显式说明"此为宿主供给指标，尚处默认值"。
> 历史缺陷（不得复发）：T4 曾回读 `last_metrics.error_code_reuse_ratio`——而该值正是脚本自己上次写回的，构成闭环，恒为 0.0，阈值永不触发。**读自己上一次输出值的指标不是指标。**

> **宿主写回接口（完整契约见 [references/scaling.md](references/scaling.md) §3.1）**：T1/T3 由宿主经两条通道写入——`-Action record-metrics`（参数 `-AgentCount` / `-RoutingAccuracy` / `-SampleSize` / `-ObservedAt` / `-Source`）与 drop 目录（`scaling-config.json` → `host_metrics.drop_dir`，默认 `{WORKSPACE_ROOT}/.skill-metrics`）；后者在每次 `evaluate`/`propose` 开始时收集，受理后的文件移入 `processed/`（只移不删，P23）。drop 文件形状：
> ```json
> {"metric":"agent_count","value":7,"observed_at":"2026-10-19T00:00:00Z","source":"host-runtime","sample_size":120}
> ```
> 两条通道共用同一校验（指标名只接受 `agent_count`/`routing_accuracy`；前者须为 ≥0 的整数且 ≤1000000，超出按宿主 bug 拒绝；后者须在 [0,1]）、时间戳（`observed_at` 必填且可解析）、新鲜度（`host_metrics.max_age_days`，默认 45）、路由样本门槛（`host_metrics.min_routing_samples`，默认 20）与审计路径：合法写入落 `host_metrics.<name>`（含 `observed_at`/`source`/`sample_size`）并镜像到 `last_metrics.<name>`，同时追加 `metrics_log`（上限 `host_metrics.log_cap`，默认 20）。`record-metrics` 若未记录任何指标则以 `SCL_007` 停止，绝不静默空转。
>
> **T1/T3 的跳过条件**（指标不可用 → 对应阈值跳过，绝不触发）：① 宿主从未写入（`host_metrics` 无该条目）；② 仍为出厂默认值（`agent_count = 0` / `routing_accuracy = 1.0`，"尚无样本"不得被误判为达标）；③ `observed_at` 缺失或不可解析；④ 时间戳超出时钟漂移容忍（未来超过 1 天）；⑤ 观测时间超过 `max_age_days`；⑥ `routing_accuracy` 的 `sample_size` 低于 `min_routing_samples`——此时 T3 跳过且**不累加**连续未命中计数。T1 仅在可用的 `agent_count > 200` 时触发；T3 仅在可用的 `routing_accuracy < 0.85` 且连续计数达到 3 时触发。

### 12.3 六道升级安全门（实现什么写什么，P24）

| # | 门 | 检查 | 失败错误码 |
|---|---|---|---|
| G1 | 权限不变 | 升级包 `permissions` 块零变更（与出厂基线做归一化文本哈希比对；哈希在门禁执行时从现行文件与包内文件实时计算） | `SCL_004` |
| G2 | 测试不变 | 升级包 `tests/**` 与现行文件逐字节一致（缺失或意外文件即失败；规格步骤 5h 要求字节一致拷贝，故字节一致是唯一可通过形态） | `SCL_005` |
| G3 | deny 与门控不变 | deny 5 项完整；`self-scale.ps1` 哈希未变（同 G1 实时计算） | `SCL_004` |
| G4 | 职能块守恒 | 升级后职能块总数 = **目标档**期望值（large→group 为 36） | `SCL_010` |
| G5 | 别名完整 | 所有旧 slug 有别名映射，无一对多冲突 | `SCL_003` |
| G6 | 验收通过 | 机器可查子集（file_count=148、frontmatter 三元组、三处版本一致、18 个 D2、前缀清单 19、`department` 枚举不在 frontmatter、03/04 prompt 存在且 agent-invoked≥L3、无 templates.md）；失败明细写入日志与状态文件 `last_failure.detail`；完整 §15 验收为人工步骤 | `SCL_006` |

G1–G3 不可绕过（即使人工批准）。升级包**排除**仓库工具目录（`.git/`/`.github/`/`.workbuddy/`/`.skill-upgrade/`，§3）与 `__pycache__`/`*.pyc`。每道门有**自己的代码分支与自己的日志行**；把多道门合并成一个 `if`、或文档写了代码没实现的门，正是前代包交付过的缺陷。

### 12.4 slug 别名机制（向后兼容）

升级后旧 slug 全部保留为别名（写入 `scaling.md` 的 Alias Map 与 frontmatter `department_aliases` 指针）。large→group：18 个旧 slug 各解析到 **2 个**后继部门（一对多扇出），如 `executive-strategy` → {`executive-office`, `strategy-planning`}。一对多且无 `domain`/任务提示时**必须询问**，不得猜测；无法解析 → `SCL_003`。别名表只追加不删除；退役 slug 不得复用；新 slug 与任一历史别名冲突 → `SCL_003`，升级拒绝。frontmatter 指针形如 `department_aliases: references/scaling.md#alias-map`（1 行，计入行预算）。

### 12.5 降级策略（禁自动）

降级有损（错误码需重映射、职能块数 36→18、内容合并），**必须人工批准**（书面理由记入 `tier_history`），不自动执行（P38）；`self-scale.ps1` 无降级通道，降级按人工流程，`SCL_008` 语义由外部安装器承载。只允许降一档。降级比升级更危险：升级只加文件，降级**删文件并合并内容**，坏合并会永久丢失规格细节——故降级提案必须额外附**被删内容的目的地表**（每个被删 D3/D4 文件的每个小节合并去了哪里）。

### 12.6 `.scaling-state.json`（全档位必备）

```json
{
  "schema_version": 1,
  "current_tier": "large",
  "tier_history": [],
  "next_evaluation": "<ISO8601，默认 +30 天>",
  "last_metrics": { "agent_count": 0, "routing_accuracy": 1.0, "max_blocks_per_department": 1, "error_code_reuse_ratio": 0.0 },
  "routing_miss_streak": 0,
  "metrics_provenance": { "agent_count": "host-supplied", "routing_accuracy": "host-supplied" },
  "host_metrics": {},
  "metrics_log": [],
  "pending_proposals": [],
  "validation": { "gates_passed": 6, "file_count": 148, "acceptance_passed": false }
}
```

约束：`current_tier` 与 frontmatter `scale_tier` 一致（P41）；`tier_history` **只追加**不得改删（审计）；**顶层**`validation.gates_passed` 必须 = 6；`validation.file_count` 用本档期望值（large **148**）；初次生成时 `tier_history` 与 `pending_proposals` 为空。宿主供给指标的出厂默认值为 `agent_count = 0` / `routing_accuracy = 1.0`（"尚无样本"不得被误判为精度不达标）。脚本另维护 `routing_miss_streak`（T3 连续未命中计数）与 `metrics_provenance`（指标来源标注），并在门失败时写 `last_failure`（含 `code`/`gates_failed`/`detail`/`package_path`）。`record-metrics` 与 drop 目录另写 `host_metrics` 与 `metrics_log`。本文件是包元数据，**不**进 `.gitignore`（§14.5）。
-->

---

## 13. Tests (`tests/test-method-patterns.py`, four assertion classes)

- **A — behavior tests**: ≥1 case per template (normal + boundary), one test class per template. Template code lives in the ```` ```python ```` blocks of [method-patterns.md](references/method-patterns.md) §3 — extracted by regex and `exec`'d into an isolated namespace for invocation (**tests the source file, not an inlined copy**). `mask_sensitive_data` must assert that all three classes email/IP/phone are masked (including multiple phone spellings and international prefixes).
- **B — source-file integrity**: the authoritative source exists + all 10 `def` present; `[PHONE]` in the source; `templates.md` does not exist (P44); a package-wide recursive scan hits exactly 1 location for every `def <fn>` (guarding P10/P44; this check previously relied on manual grep and the hole was never machine-caught); no deprecated `utcnow`.
- **C — structural consistency and the upgrade mechanism**: department count matches disk (18), function-block conservation (large=18), declared counts match disk, department subdirectory naming, `department-index.md` matches disk, error codes agree with the prefix declaration with no numbering gaps, no broken links, zero orphan prompts, file count matches the spec (148); the four-piece set complete + propose-only, `immutable_paths` declared, no install action, never writes `{SKILL_DIR}`, each of the six gates implemented separately, no remote download, no hardcoded user paths, cross-platform backup directories, state file consistent with the frontmatter and schema-complete; **any-target selection** (the `-TargetTier` parameter is declared, the seven upgrade edges pair one-to-one with builders and every pair belongs to the config `selectable_targets`, the config `tier_order` matches the script's tier table, the default target is the first selectable, the script's five-tier file counts match the config expectations, the group scaffold is declared and its generation records no live state); **specification language conformance** (after stripping HTML comments, `README_FOR_AI.md` contains no CJK characters — the machine enforcement of "source files = English").
- **D — acceptance invariants**: upgrade packages contain no `tests/` or permissions changes (scans `{WORKSPACE_ROOT}/.skill-upgrade/`, skips when the directory does not exist); write permission limited to `{WORKSPACE_ROOT}`; the deny 5 intact. Security sweep classes: no hardcoded user paths, no remote-execution patterns, no embedded secrets, no compiled artifacts, `description` under 1024, frontmatter ≤150 lines, version major = 4, three-location version consistency, `errors` empty, the large-tier `department` enum inlined in the frontmatter (auto + 18, P30), `.scaling-state.json` not ignored.
- **Regression groups**: first review / second review / final review / gate-fix (the 2026-10-19 G1/G3 baseline-hash scope defect and the G2 tests contradiction fix) regression groups, covering repeated host-metric writes, T3 low-sample skipping, IP masking with no version-keyword escape, credential scrubbing against real names, and layer-by-layer AIGC assertions. **New assertions must be reverse-verified**: inject the defect back into a temporary copy and the assertion must fail; otherwise it is an empty assertion that always passes.

Engineering requirements: `unittest` style, run directly with `python tests/test-method-patterns.py`; `SKILL_DIR` derived relatively via `Path(__file__).resolve().parent.parent` (hardcoding forbidden); time via `datetime.now(timezone.utc)` (deprecated `utcnow` forbidden); standard library only; UTF-8 without BOM. Run tests with `PYTHONDONTWRITEBYTECODE=1` and leave no `__pycache__` behind — the suite asserts the total file count (148), and bytecode artifacts would break both the count and the "no compiled artifacts" sweep.

---

## 14. Red Lines (P1–P55, fully inlined; the sole authority in this package)

> This section is the **local definition site** for every `P##` reference in this package. Check the relevant rows before generating or modifying any file.

### 14.1 Structure and Naming

| # | Forbidden | Reason |
|---|---|---|
| P1 | `SKILL.md` in department subdirectories | Misregistered by loaders as an independent skill; triggers conflict |
| P2 | Sub-manifest `dependencies.skills` filled with package-internal department names/legacy names | Dependency resolution fails; contradicts the root `dependencies: []` |
| P3 | Departments using different section skeletons | Cannot be parsed programmatically (the source package had 11 departments in 5 variants) |
| P4 | Count claims that disagree with reality | AI hunts files by the wrong number and hallucinates fillers when it finds none |
| P5 | Skipped section numbers | Agents are forced down to D3, violating progressive disclosure |
| P6 | Merged tiers losing the function blocks of merged functions | Self-check via function-block conservation (large = 18; on upgrade to group G4 judges by the target tier's 36) |
| P7 | Listing the D4 engine as a department | Disagrees with the department enum |
| P8 | Leaving orphan files | Unreferenced by any document means unreachable |
| P9 | Two similarly named files for the same module | The hyphenated version cannot be imported |
| P10 | Storing shared code twice | Cannot tell which is authoritative (authority per P44) |
| P27 | Department slugs not conforming to the §10.5 rules | Inconsistent naming in output |
| P28 | Breaking the §10.1 merge tree's strict containment | The upgrade path can no longer be derived mechanically |
| P29 | Renumbering existing WFT numbers / using 001–099 for extensions | The core set's numbering is fixed; extensions go to WFT-1xx |
| P33 | Merged tiers writing only department-level sections and omitting function blocks | Equivalent to discarding the merged departments' functions |
| P40 | Free-format function-block titles | Cannot be counted programmatically (must be `## FB-<N>: <ROLE>`) |

### 14.2 Version and Metadata

| # | Forbidden | Reason |
|---|---|---|
| P11 | Version numbers written independently in several places | The source package had 5 places with 2 values |
| P12 | The same version number appearing twice in the Changelog, or inverted dates | Audit confusion |
| P13 | A roadmap-claimed version with no Changelog entry | A false promise |
| P14 | Gaps in error-code numbering | Cannot tell deprecated from forgotten |
| P15 | `name` using a YAML block scalar (`|`/`>`) | Escaping risk; use single-line quotes |
| P16 | `description` exceeding 1024 characters | SkillImport hard validation fails |
| P17 | Inlining the full error-code table in the frontmatter | D1 layer over budget; every load swallows the full table |
| P30 | Any tier's department enum not inlined in the frontmatter | Gate G6 enforces inlining (auto + tier department count); not inlining is a defect. The authoritative copy is in `references/department-index.md`; what is inlined is the legal-value list (this package's large-tier 18 items still fit within ≤150 frontmatter lines) |
| P31 | Missing or contradictory `scale_tier`/`department_count`/`function_block_count` | The tier must leave a trace and be self-consistent |
| P41 | `.scaling-state.json` `current_tier` disagreeing with the frontmatter | The upgrade starting point cannot be determined |
| P42 | major version number not matching the tier ordinal | Breaks upgrade traceability |

### 14.3 Security

| # | Forbidden | Reason |
|---|---|---|
| P18 | Hardcoded absolute user paths | Guaranteed to fail on another machine |
| P19 | Referencing a non-existent script/file path | Broken link |
| P20 | Writing any real or "example" secret | Only environment variable names are written |
| P21 | Widening `permissions.files.write` to `{SKILL_DIR}` | The skill directory must be read-only; an upgrade is not a reason to relax |
| P22 | Removing any item of `permissions.files.deny` | A P0-level security boundary |
| P23 | Rollback logic that deletes before restoring | A Copy failure permanently loses the whole package |
| P24 | Security-gate/Harness documentation describing unimplemented content | A false security promise |
| P25 | Using remote-download-and-execute class cmdlets (dynamic expression evaluation / string download / web request; these tokens are always written assembled-at-runtime in this package, their literal appearance forbidden) | The primary signature of malicious behavior |
| P26 | Half-done platform adaptation | Fails off Windows |
| P32 | Contract declarations disagreeing with the code implementation | E.g. the mask contract requires [PHONE] but the code lacks it |
| P34 | An upgrade containing `tests/**` changes | A self-exemption hole |
| P35 | An upgrade containing permissions/deny/gate-logic changes | A self-escalation hole; not waivable even by human approval |
| P36 | The skill installing an upgrade package itself (writing `{SKILL_DIR}`) | Violates P21; propose-only is the only option |
| P37 | An upgrade generating no slug alias mapping | Breaks backward compatibility |
| P38 | Automatically executing a downgrade | Downgrades are lossy and require human approval |
| P39 | Artifacts not passing the acceptance script their own documentation specifies | Custom acceptance must be run after generation |

### 14.4 Content Specifications (mapped to this document's sections)

| # | Forbidden | Maps to |
|---|---|---|
| P43 | `SKILL.md` body exceeding 120 lines or containing code/full error-code tables/SOP | §6.2 |
| P44 | Generating `references/templates.md` or any file inline-copying templates | §7.3 |
| P45 | A prompt not declaring mode, or 01/02 labeled agent-invoked | §11.1 |
| P46 | A human-paste prompt referencing internal paths/identifiers or missing fill-in slots | §11.2 |
| P47 | Source files hardcoding the output language (e.g. `All content in English`) | §6.3 |
| P48 | Translating the six immutable identifier classes | §6.3 |
| P49 | Delivering below Harness L3, or declaring a level higher than the checkable evidence | §8.2 |
| P50 | Trimming governance and community files by tier | §3 (all 13 present at every tier) |
| P51 | Wrong file names (`.gitingnore`/`changelog.md`/`CODE OF CONDUCT.md`) or file names containing spaces | §3 |
| P52 | A main module over 300 lines / a sub-module linking back / one subdirectory pointed to by two main modules | Clustering |
| P53 | Creating empty files or placeholder content for generic files | §4 Step 11 |
| P54 | Governance files not generated in file-tree order during implementation | §4 Step 11 |
| P55 | `AGENTS.md` restating `SKILL.md` content, becoming a second entry point, or missing its first-screen responsibility declaration/exceeding 150 lines | §6.2 / AGENTS.md |

### 14.5 Engineering Hygiene

Never commit `__pycache__`/`.pyc`; never omit `.gitignore` or use exact names instead of wildcards (P39); never commit installer artifacts/local review reports (`REVIEW-*.md`)/`.skill-upgrade/` proposal packages; **never ignore `.scaling-state.json`** (it is package metadata); never let tests carry a self-contained copy instead of validating the real source file; never let README's Project Structure disagree with disk; never use bare code fences; never use non-UTF-8 or BOM-prefixed source files.

**No crappy code, no historical burden (engineering level).** A change must never build or accept:
- monolithic modules that blow the size/maintainability budget without a documented reason (P52: a main module over 300 lines is a clustering smell);
- copy-paste or near-duplicate logic instead of linking the single authoritative source (P9/P10);
- "temporary" workarounds, dead branches, or feature flags left in place "for later" — ship the cleanup or delete the dead path in the same change;
- TODO/FIXME/HACK debt that silently accumulates — an unresolved item must be an open ticket, never a comment in shipped code;
- commented-out live code/spec blocks kept "just in case" — delete them; history lives in version control, not in the source tree.

### 14.6 File Hygiene

Every file in the package file set must earn its place. Specifically:
- **No orphan files** — every file is referenced by at least one other package file or by `SKILL.md`/`README*`; an unreferenced file is unreachable and must be removed (P8).
- **No duplicate or near-duplicate files** — do not keep two files with similar names or content; keep one authoritative copy and link to it (P9/P10).
- **No empty or placeholder files** — a generic file with no real content is forbidden (P53).
- **No "kept for history" files** — if a file's only purpose is a historical record, either delete it (and note it in `CHANGELOG.md`) or keep it only as an explicitly deprecated, numbered entry; never leave a file whose sole value is "we might need it someday".
- **No commented-out live content** — commented-out code/spec blocks in shipped files are historical burden; remove them. The Chinese-origin `<!-- 中文原文 -->` blocks in this file are the sole sanctioned exception (translation对照, per §16) and must stay.

**No crappy code, no historical burden (file level).** A change must not grow the package file count with cruft, nor leave behind dead or superseded files. When content is superseded, mark it deprecated and point to the successor (never silently delete a referenced artifact); when it is truly dead, delete it and record the removal in `CHANGELOG.md`. Accumulating files "to be cleaned up later" is itself the historical burden this package forbids.

<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 13. 测试（`tests/test-method-patterns.py`，四类断言）

- **A 行为测试**：10 模板各 ≥1 条（正常 + 边界），每模板一个测试类。模板代码在 [method-patterns.md](references/method-patterns.md) §3 的 ```` ```python ```` 块内——用正则提取后 `exec` 到独立命名空间调用（**测源文件，非内联副本**）。`mask_sensitive_data` 必须断言 email/IP/phone 三类均脱敏（含手机号多写法与国际码）。
- **B 源文件完整性**：权威源存在 + 10 个 `def` 齐全；`[PHONE]` 在源中；`templates.md` 不存在（P44）；全包递归扫描每个 `def <fn>` 恰 1 处（守住 P10/P44；此前该检查只靠人工 grep，漏洞未被机器捕获）；无已弃用 `utcnow`。
- **C 结构一致性与升级机制**：部门数与磁盘一致（18）、职能块守恒（large=18）、声明计数与磁盘一致、部门子目录命名、`department-index.md` 与磁盘一致、错误码与前缀声明一致且编号无空洞、无断链、prompts 零孤儿、文件数与规格一致（148）；四件套齐全 + propose-only、`immutable_paths` 声明、无 install 动作、不写 `{SKILL_DIR}`、六道门各自实现、无远程下载、无硬编码用户路径、备份目录跨平台、状态文件与 frontmatter 一致且 schema 完整；**任意目标选择**（`-TargetTier` 参数已声明、七对升级边与构建器一一配对且每对都属于 config `selectable_targets`、config `tier_order` 与脚本档位表一致、默认目标为可选集首项、脚本五档文件计数与 config 期望一致、group 脚手架已声明且生成过程不记 live state）。
- **D 验收不变量**：升级包不含 `tests/` 与 permissions 变更（扫描 `{WORKSPACE_ROOT}/.skill-upgrade/`，目录不存在时 skip）；写权限仅 `{WORKSPACE_ROOT}`；deny 5 项完整。安全清查类：无硬编码用户路径、无远程执行模式、无内嵌密钥、无编译产物、`description` 不超 1024、frontmatter ≤150 行、version major = 4、三处版本一致、`errors` 为空、large 档 `department` 枚举内联 frontmatter（auto + 18，P30）、`.scaling-state.json` 不被 ignore。
- **回归组**：初审 / 复审 / 终审 / 门禁修复（2026-10-19 G1/G3 基线哈希作用域缺陷与 G2 tests 矛盾修复）多组回归，覆盖宿主指标多次写入、T3 低样本跳过、IP 脱敏无版本关键词逃逸、凭证擦除真实命名、AIGC 三层逐层断言等。**新增断言必须做反向验证**：把缺陷注回临时副本，断言必须失败；否则是永远通过、形同虚设的空断言。

工程要求：`unittest` 风格，`python tests/test-method-patterns.py` 直跑；`SKILL_DIR` 用 `Path(__file__).resolve().parent.parent` 相对推导（禁硬编码）；时间用 `datetime.now(timezone.utc)`（禁已弃用 `utcnow`）；仅标准库；UTF-8 无 BOM。跑测试设 `PYTHONDONTWRITEBYTECODE=1` 且不得留下 `__pycache__`——套件断言文件总数（148），字节码产物会同时破坏计数与"无编译产物"清查。

---

-->
<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 14. 红线清单（P1–P55，完整内联；本包唯一权威）

> 本节是本包所有 `P##` 引用的**本地定义处**。生成或修改任何文件前，先核对相关行。

### 14.1 结构与命名

| # | 禁止 | 理由 |
|---|---|---|
| P1 | 部门子目录放 `SKILL.md` | 被加载器误注册为独立技能，triggers 冲突 |
| P2 | 子清单 `dependencies.skills` 填包内部门名/legacy 名 | 依赖解析失败；与根 `dependencies: []` 矛盾 |
| P3 | 各部门用不同章节骨架 | 无法程序化解析（源包 11 部门 5 种变体） |
| P4 | 写下与实际不符的数量宣称 | AI 照错误数字找文件，找不到即幻觉补全 |
| P5 | 章节编号跳号 | Agent 被迫下沉 D3，违背渐进式披露 |
| P6 | 合并档位丢失被合并职能的职能块 | 用职能块守恒自检（large = 18；升 group 时 G4 按目标档 36 判） |
| P7 | 把 D4 引擎列为部门 | 与 department 枚举不符 |
| P8 | 留下孤儿文件 | 无文档引用即不可达 |
| P9 | 同一模块留两份命名相近文件 | 连字符版无法 import |
| P10 | 共享代码存两份 | 无法判断权威源（权威源见 P44） |
| P27 | 部门 slug 不符 §10.5 规范 | 产出不一致命名 |
| P28 | 破坏 §10.1 合并树严格包含关系 | 升级路径无法机械推导 |
| P29 | 重排既有 WFT 编号 / 用 001–099 放扩展 | 核心集编号固定，扩展走 WFT-1xx |
| P33 | 合并档位只写部门级章节、省略职能块 | 等于丢掉被合并部门职能 |
| P40 | 职能块标题用自由格式 | 无法程序化统计（须 `## FB-<N>: <ROLE>`） |

### 14.2 版本与元数据

| # | 禁止 | 理由 |
|---|---|---|
| P11 | 版本号多处各写各的 | 源包 5 处 2 值 |
| P12 | Changelog 同版本号出现两次或日期倒挂 | 审计混乱 |
| P13 | 路线图宣称的版本在 Changelog 无条目 | 虚假承诺 |
| P14 | 错误码编号留空洞 | 无法判断废弃还是漏写 |
| P15 | `name` 用 YAML 块标量(`\|`/`>`) | 转义风险；用单行引号 |
| P16 | `description` 超 1024 字符 | SkillImport 硬校验失败 |
| P17 | 错误码全表内联 frontmatter | D1 层超标，每次加载全量吞入 |
| P30 | 任一档位 department 枚举未内联 frontmatter | 门 G6 强制内联（auto + 档位部门数）；不内联即缺陷。权威副本在 `references/department-index.md`，内联的是合法值清单（本包 large 档 18 项计入后 frontmatter 仍 ≤150 行） |
| P31 | `scale_tier`/`department_count`/`function_block_count` 缺失或矛盾 | 档位须留痕且自洽 |
| P41 | `.scaling-state.json` `current_tier` 与 frontmatter 不一致 | 升级起点无法判断 |
| P42 | major 版本号与档位序号不对应 | 破坏升级可追溯性 |

### 14.3 安全

| # | 禁止 | 理由 |
|---|---|---|
| P18 | 硬编码绝对用户路径 | 换机必然失败 |
| P19 | 引用不存在的脚本/文件路径 | 断链 |
| P20 | 写任何真实或"示例"密钥 | 只写环境变量名 |
| P21 | 扩大 `permissions.files.write` 到 `{SKILL_DIR}` | 技能目录必须只读；升级不构成放宽理由 |
| P22 | 删减 `permissions.files.deny` 任何一项 | P0 级安全边界 |
| P23 | 回滚逻辑先删后恢复 | Copy 失败即永久丢失整包 |
| P24 | 安全门/Harness 文档写未实现的内容 | 虚假安全承诺 |
| P25 | 使用远程下载即执行类 cmdlet（动态表达式求值 / 字符串下载 / 网页请求；令牌本包一律按运行时拼装，禁字面出现） | 恶意行为首要特征 |
| P26 | 平台适配只做一半 | 非 Windows 下失效 |
| P32 | 契约声明与代码实现不一致 | 如 mask 契约要 [PHONE] 而代码缺 |
| P34 | 升级包含 `tests/**` 变更 | 自我豁免漏洞 |
| P35 | 升级包含 permissions/deny/门控变更 | 自我提权漏洞；人工批准也不放行 |
| P36 | 技能自行安装升级包（写 `{SKILL_DIR}`） | 违反 P21；只能 propose-only |
| P37 | 升级时未生成 slug 别名映射 | 破坏向后兼容 |
| P38 | 自动执行降级 | 降级有损，须人工批准 |
| P39 | 产物未通过自己文档写的验收脚本 | 生成后必须跑自定义验收 |

### 14.4 内容规格（对应本文各章）

| # | 禁止 | 对应 |
|---|---|---|
| P43 | `SKILL.md` 正文超 120 行或含代码/完整错误码表/SOP | §6.2 |
| P44 | 生成 `references/templates.md` 或任何文件内联复制模板 | §7.3 |
| P45 | prompt 未声明 mode，或 01/02 标为 agent-invoked | §11.1 |
| P46 | human-paste prompt 引用内部路径/标识符或缺填空位 | §11.2 |
| P47 | 源文件写死输出语言（如 `All content in English`） | §6.3 |
| P48 | 翻译六类不可变标识符 | §6.3 |
| P49 | Harness < L3 交付，或声明级别高于可查证据 | §8.2 |
| P50 | 按档位裁剪治理与社区文件 | §3（13 个全档齐备） |
| P51 | 错误文件名（`.gitingnore`/`changelog.md`/`CODE OF CONDUCT.md`）或含空格文件名 | §3 |
| P52 | 主模块超 300 行 / 子模块反向链接 / 一子目录被两主模块指向 | 集群化 |
| P53 | 为通用文件创建空文件或占位内容 | §4 Step 11 |
| P54 | 实现阶段治理文件未按文件树顺序生成 | §4 Step 11 |
| P55 | `AGENTS.md` 复述 `SKILL.md` 内容、成为第二入口，或缺首屏职责声明/超 150 行 | §6.2 / AGENTS.md |

### 14.5 工程卫生

不提交 `__pycache__`/`.pyc`；不缺 `.gitignore` 或用精确名而非通配（P39）；不提交安装器产物/本地审核报告(`REVIEW-*.md`)/`.skill-upgrade/` 提案包；**不 ignore `.scaling-state.json`**（它是包元数据）；不让测试自包含副本而不校验真实源文件；不让 README 的 Project Structure 与磁盘不符；代码块不用裸围栏；源文件不用非 UTF-8 或带 BOM。

**禁止搭建屎山代码、禁止给项目增加历史负担（工程级）。** 任何改动不得建造或纵容：超出体量/可维护预算却无文档说明的单体模块（P52：主模块超 300 行为集群化异味）；不链接唯一权威源而复制粘贴或近似复制的逻辑（P9/P10）；"临时"绕过、死分支、为"以后"保留的特性开关——同一改动内要么清理要么删除死路径；悄然累积的 TODO/FIXME/HACK 债——未决项必须是已开工单，而非发布代码里的注释；为"以防万一"保留的注释掉活代码块——删除它们，历史在版本库，不在源码树。

### 14.6 文件卫生

包文件集内每个文件都必须有其存在价值。具体而言：
- **无孤儿文件**——每个文件都被至少一个其他包文件或 `SKILL.md`/`README*` 引用；不可达文件必须删除（P8）。
- **无重复或近似重复文件**——不得保留同名或同内容的两份文件；保留唯一权威副本并链接（P9/P10）。
- **无空文件或占位文件**——无实质内容的通用文件一律禁止（P53）。
- **无"留作历史"的文件**——若文件唯一用途是历史记录，要么删除（并在 `CHANGELOG.md` 注明），要么仅作为显式弃用、带编号的条目保留；绝不留"也许以后用得上"的文件。
- **无注释掉的活内容**——发布文件中的注释掉代码/规格块即历史负担，应删除。本文件的中文原文 `<!-- 中文原文 -->` 块是唯一特许例外（翻译对照，见 §16），必须保留。

**禁止搭建屎山代码、禁止给项目增加历史负担（文件级）。** 任何改动不得以垃圾膨胀包文件数，也不得留下死亡或已被取代的文件。内容被取代时标记弃用并指向继承者（绝不静默删除被引用产物）；确属死代码则删除并在 `CHANGELOG.md` 记录移除。"留待以后清理"而堆积文件，正是本包禁止的历史负担本身。
-->

---

## 15. Acceptance Checklist (must be executed after every generation/modification)

```powershell
# Windows' default execution policy (Restricted / RemoteSigned) rejects unsigned
# .ps1 files; every powershell command below therefore passes
# -ExecutionPolicy Bypass explicitly (a downloaded script may first be
# Unblock-File'd).
# 1. Test suite (set PYTHONDONTWRITEBYTECODE=1: the suite asserts the total file
#    count; bytecode artifacts are forbidden)
$env:PYTHONDONTWRITEBYTECODE = "1"; python tests/test-method-patterns.py

# 2. Upgrade readiness check (does not touch skill content). When no threshold
#    is hit, only its own bookkeeping fields are written back to
#    .scaling-state.json; when any threshold is hit, an upgrade proposal
#    package is additionally generated under {WORKSPACE_ROOT}/.skill-upgrade/<ts>/
#    and pending_proposals are recorded -- still no install, no change to skill
#    content, no permission request
powershell -ExecutionPolicy Bypass -File scripts/self-scale.ps1 -Action evaluate

# 3. Host metrics channel end to end (T1 cap 200; -AgentCount 250 must actually
#    trigger it; afterwards restore 0 and run evaluate again)
powershell -ExecutionPolicy Bypass -File scripts/self-scale.ps1 -Action record-metrics -AgentCount 250
powershell -ExecutionPolicy Bypass -File scripts/self-scale.ps1 -Action evaluate

# 4. propose smoke test on a pristine copy (expect exit 0 and G1-G6 all PASSED;
#    run only on a tempfile pristine copy, never install)
```

**Counts and consistency spot checks**: total files **148** (package file set; repository tool directories excluded); governance files **13/13**; departments **18/18** (7 domains 3/3/3/3/2/2/2); function blocks **18** (exactly one `## FB-1:` per D2); error codes **117** (107 across 18 prefixes + 10 SCL, no numbering gaps); prefix list **19**; frontmatter ≤150 lines; SKILL body ≤120 lines; AGENTS.md ≤150 lines; triggers 66 entries; `description` ≤1024 characters; prompts **4** with correct modes (01/02 `human-paste`, 03/04 `agent-invoked`), zero orphans.

**Character-for-character / consistency**: `permissions` matches §9.1 character-for-character; the frontmatter triple `scale_tier: large` / `department_count: 18` / `function_block_count: 18`; the version number has the **same value in three** places (`4.0.0`: `_meta.json` / README badge (of the form `version-4.0.0-blue`) / `SKILL.md` frontmatter); the license has the same value in four places (GPL-3.0); each D2's `### 4` FB matches error-codes.md in code and text; the README triple structure trees match the **package file set** of 148 files item by item (D-2); README.en.md and README.md agree in content; **no BOM, no CRLF (checked against the original bytes; do not use `read_text()`'s universal newlines)**; no hardcoded user paths (zero hits scanning absolute-path patterns in the package); no `templates.md` (P44); exactly one occurrence of each `def <fn>`; `[PHONE]` present in the authoritative source; no broken links (each relative link verified); no `__pycache__` residue; the quantity claims in README / SKILL.md / `_meta.json` / CHANGELOG agree with disk (P4/P11).

<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 15. 验收清单（每次生成/修改后必须执行）

```powershell
# Windows 默认执行策略（Restricted / RemoteSigned）会拒绝未签名的 .ps1；
# 下面每条 powershell 命令都显式加 -ExecutionPolicy Bypass（下载得到的脚本
# 也可先 Unblock-File）。
# 1. 测试套件（设 PYTHONDONTWRITEBYTECODE=1：套件断言文件总数，禁字节码产物）
$env:PYTHONDONTWRITEBYTECODE = "1"; python tests/test-method-patterns.py

# 2. 升级就绪检查（不改动技能内容）。未命中阈值时仅回写自身记录字段到
#    .scaling-state.json；任一阈值命中时会额外生成升级提案包到
#    {WORKSPACE_ROOT}/.skill-upgrade/<ts>/ 并记录 pending_proposals —— 仍不安装、
#    不改技能内容、不请求权限
powershell -ExecutionPolicy Bypass -File scripts/self-scale.ps1 -Action evaluate

# 3. 宿主指标通道端到端（T1 上限 200，-AgentCount 250 必须能真的触发；验证后请还原为 0 并重新 evaluate）
powershell -ExecutionPolicy Bypass -File scripts/self-scale.ps1 -Action record-metrics -AgentCount 250
powershell -ExecutionPolicy Bypass -File scripts/self-scale.ps1 -Action evaluate

# 4. 纯净副本 propose 冒烟（期望 exit 0 且 G1-G6 全 PASSED；只在 tempfile 纯净副本上跑，永不安装）
```

**计数与一致性抽查**：文件总数 **148**（包文件集；仓库工具目录不计）；治理文件 **13/13**；部门 **18/18**（7 域 3/3/3/3/2/2/2）；职能块 **18**（每 D2 恰 1 个 `## FB-1:`）；错误码 **117**（18 前缀 107 + SCL 10，编号无空洞）；前缀清单 **19**；frontmatter ≤150 行；SKILL 正文 ≤120 行；AGENTS.md ≤150 行；triggers 66 条；`description` ≤1024 字符；prompts **4** 个且 mode 正确（01/02 `human-paste`，03/04 `agent-invoked`），零孤儿。

**逐字符/一致性**：`permissions` 与 §9.1 逐字符一致；frontmatter 三元组 `scale_tier: large` / `department_count: 18` / `function_block_count: 18`；版本号**三处**同值（`4.0.0`：`_meta.json` / README badge（形如 `version-4.0.0-blue`）/ `SKILL.md` frontmatter）；许可四处同值（GPL-3.0）；D2 各 FB `### 4` 与 error-codes.md 同码同文；README 三兄弟结构树与**包文件集** 148 文件逐项一致（D-2）；README.en.md 与 README.md 内容一致；**无 BOM、无 CRLF（按原始字节检查，不得用 `read_text()` 的通用换行）**；无硬编码用户路径（包内扫描绝对路径模式零命中）；无 `templates.md`（P44）；每个 `def <fn>` 恰 1 处；`[PHONE]` 在权威源中；无断链（相对链接逐一验证）；无 `__pycache__` 残留；README / SKILL.md / `_meta.json` / CHANGELOG 中的数量宣称与磁盘相符（P4/P11）。
-->

## 16. Modification Protocol and Recorded Items

**Modification protocol**: ① read `AGENTS.md` and this document's §5 before changing anything; ② structural changes (adding/removing files/departments/FBs/error codes) must be synced to the README triple structure trees, the SKILL.md index, error-codes.md, the `_meta.json` version, and CHANGELOG; ③ **untouchable** — the `permissions` block, `tests/` expectations, and the `self-scale.ps1` gate logic — which may not be changed even through the upgrade channel with human approval (§9.5); ④ after changing anything, run the full §15 acceptance (P39).

**Recorded items**:

| Item | Notes |
|---|---|
| File count 148 | This file (`README_FOR_AI.md`) and `.gitattributes` are part of the ai-company skill package's large tier, not deviations |
| Core Identity includes "Domain" | The large tier enables domain routing (the micro tier has no domain concept); D2 intro blocks must carry `Domain:` |
| Board ladder / circuit breaker / memory / model management / visualization / data integration | **Enabled** at the large tier; the full head-office-and-branch form of the board ladder arrives at the group tier |
| G6 is a machine-checkable subset | The `self-scale.ps1` G6 implementation covers the automatable subset; the full §15 acceptance is a manual step (declared truthfully, not a P24) |
| Higher tiers | The group tier's full department set follows the same merge-tree principle as §10.1; `scripts/self-scale.ps1` now implements seven upgrade edges (micro→small, small→medium, medium→large, micro→medium as a two-hop composition, micro→large, small→large, large→group), with the target tier freely chosen via `-TargetTier` within the config `selectable_targets` set (scaling.md §2 rules); large→group is a scaffold delivery (copy-forward + work order + state skeleton; G4–G6 fail by design), and the group tier's 36-department content itself is not yet written |
| Language policy and translation record | The body text is English (compliant with the §6.3 standard as of 2026-10-21; the full Chinese text from before 2026-10-21 is preserved per-section in HTML comments for comparison only, hidden at render time). The former carve-out "this document is written for Chinese maintainers and is separately exempt from the §6.3 'source files = English' standard" (listed alongside `README.zh.md`) is revoked as of the translation date, and `README_FOR_AI.md` is removed from the language-exemption list (AGENTS.md). The old rule limiting the exemption to natural-language prose is likewise void; the six identifier classes remain never-translated (P48), code blocks remain English, and this document still may not inline-copy template code (§7.1) |
| Line-ending policy | The whole package uses **LF** uniformly (including `.ps1`). `.editorconfig` matches measured file contents; `self-scale.ps1` contains LF-sensitive here-strings and its normalization logic forces artifacts to LF, so the risk of editing files outweighs that of editing documentation. `.gitattributes` (`* text=auto eol=lf`) pins line endings at the repository layer, absorbing the "LF will be replaced by CRLF" drift caused by a local `core.autocrlf=true` |
| Package file-set boundary (decision D-1, 2026-10-14) | The package file set = repository-tracked files − repository tool directories (`.git/`/`.github/`/`.workbuddy/`/`.skill-upgrade/`). The four are excluded from the total file count, the structure tree, and upgrade packages. `$ExcludedDirSegments` / `Get-PackageRelativePaths` in `self-scale.ps1` are the single implementation; the copy scope and the counting basis share it |
| Version location count (decision D-2, 2026-10-14) | The version number appears in exactly **three** places with the same value: `_meta.json` / README badge / `SKILL.md` frontmatter. The former "`SKILL.md` body title" never existed in any released package and has been removed from this section, §6.1, §15, `scaling.md`, and gate G6; otherwise G6 could never pass and the propose channel would be effectively dead. The README.md / README.en.md / README.zh.md structure trees are character-for-character identical |
| Host write-back interface (2026-10-14) | The full contracts of the `record-metrics` and drop-directory channels are in [references/scaling.md](references/scaling.md) §3.1, summarized in §12.2. The script previously claimed this interface existed without any implementation or documentation; the two now agree; the six skip conditions for T1/T3 are listed one by one per the implementation |
| Migration record (2026-10-19, route B; history of the predecessor project `ai-company-large`) | This tier's content was migrated from the 2026-09-10 old spec (v4.0.0) to the then-current spec (v4.1.0). Decisions: the template authority moved from `references/templates.md` into `references/method-patterns.md` §3, and all fixes from the 2026-09-28 substantive template review were adopted (credential scrubbing changed to variable-name fragment matching, multi-form phone-number coverage, no loss on non-UTF-8 subprocess output, `format_output_json` model field, rate limiting made bounded, `read_reference_file` fail-closed, watermark bound to a content digest with strength wording toned down, command blacklist demoted to a best-effort line of defense); prompts gained mode declarations, and `05-workflow-execution.md` was deleted to align with the current tier ladder's 4-prompt count; the governance layer was completed to 13 files; the host metrics write-back channel landed (`record-metrics` + drop directory); the two gate defects found in the 2026-10-19 smoke test were fixed (G1/G3 baseline hashes assigned inside function scope, thus always compared against `$null`; G2 contradicting spec step 5h's byte-identical copy of tests), changed to follow the current implementation (hashes computed live at gate time; tests compared byte by byte); the file count was re-audited from 142 to **148**. That predecessor project was merged into the `ai-company` base lineage as the large tier on 2026-10-20, with the tier version number taken as the tier ordinal **4.0.0**. This document is one of the deliverables of that migration |

<!-- 中文原文（2026-10-21 英译前版本，仅供对照）：
## 16. 修改协议与已记录事项

**修改协议**：① 改前读 `AGENTS.md` 与本文 §5；② 结构性修改（增删文件/部门/FB/错误码）必须同步 README 三兄弟结构树、SKILL.md 索引、error-codes.md、`_meta.json` 版本、CHANGELOG；③ **不可触碰** `permissions` 块、`tests/` 期望值、`self-scale.ps1` 门控逻辑——即使人工批准也不得通过升级通道变更（§9.5）；④ 改完跑 §15 全部验收（P39）。

**已记录事项**：

| 项 | 说明 |
|---|---|
| 文件数 148 | 本文（`README_FOR_AI.md`）与 `.gitattributes` 均为 ai-company 技能包大型档的组成部分，非偏离项 |
| Core Identity 含「所属域」 | large 档启用域路由（微型档无域概念）；D2 引言块须标注 `Domain:` |
| 董事会阶梯 / 熔断 / 记忆 / 模型管理 / 可视化 / 数据集成 | large 档**启用**；董事会阶梯的完整总分公司形态在 group 档 |
| G6 为机器可查子集 | `self-scale.ps1` 的 G6 实现可自动化子集，完整 §15 验收为人工步骤（已如实声明，非 P24） |
| 更高档位 | group 的部门全集遵循 §10.1 同一合并树原则；`scripts/self-scale.ps1` 现实现七对升级边（micro→small、small→medium、medium→large、micro→medium 两段组合、micro→large、small→large、large→group），目标档位由 `-TargetTier` 在 config `selectable_targets` 集合内任选（scaling.md §2 规则）；large→group 为脚手架交付（拷前 + 工单 + state 骨架，G4–G6 按设计失败），group 档 36 部门内容本身尚未撰写 |
| 本文语言豁免 | 本文面向中文维护者撰写，**单独豁免**于 §6.3「源文件 = 英语」标准（与 `README.zh.md` 同列豁免）。豁免**仅限自然语言行文**：标识符六类仍永不翻译（P48），代码块仍为英语，本文仍不得内联复制模板代码（§7.1） |
| 行尾策略 | 全包统一 **LF**（含 `.ps1`）。`.editorconfig` 与文件实测保持一致；`self-scale.ps1` 含 LF 敏感 here-string，且其规范化逻辑强制产物为 LF，改文件风险高于改文档。`.gitattributes`（`* text=auto eol=lf`）把行尾钉死在仓库层，抵消本机 `core.autocrlf=true` 造成的 "LF will be replaced by CRLF" 漂移 |
| 包文件集边界（D-1 决策，2026-10-14） | 包文件集 = 仓库跟踪文件 − 仓库工具目录（`.git/`/`.github/`/`.workbuddy/`/`.skill-upgrade/`）。四者不计入文件总数、不进结构树、不进升级包。`self-scale.ps1` 的 `$ExcludedDirSegments` / `Get-PackageRelativePaths` 是唯一实现处，拷贝范围与计数基准共用它 |
| 版本位数量（D-2 决策，2026-10-14） | 版本号**三处同值**：`_meta.json` / README badge / `SKILL.md` frontmatter。原"`SKILL.md` 正文标题"从未存在于任何发布包，已从本节、§6.1、§15、`scaling.md` 与门 G6 移除；否则 G6 恒不可通过，propose 通道等同死亡。README.md / README.en.md / README.zh.md 三兄弟结构树逐字符相同 |
| 宿主写回接口（2026-10-14） | `record-metrics` 与 drop 目录两条通道的完整契约见 [references/scaling.md](references/scaling.md) §3.1，摘要见 §12.2。此前脚本自称该接口存在却无任何实现与文档，现二者一致；T1/T3 的六类跳过条件按实现逐条列出 |
| 迁移记录（2026-10-19，路线 B；前身项目 `ai-company-large` 的历史） | 本档内容由 2026-09-10 旧规格（v4.0.0）迁移到当时规格（v4.1.0）。决策：模板权威源从 `references/templates.md` 移入 `references/method-patterns.md` §3，并采纳 2026-09-28 模板实质审查的全部修复（凭证擦除改变量名片段匹配、手机号多写法覆盖、子进程非 UTF-8 输出不丢失、`format_output_json` model 字段、限流有界、`read_reference_file` fail-closed、水印绑定内容摘要并下调强度表述、命令黑名单降格为尽力而为防线）；prompts 增加 mode 声明，并删除 `05-workflow-execution.md` 以对齐当前档位阶梯的 4 prompt 计数；治理层补齐为 13 个文件；宿主指标写回通道落地（`record-metrics` + drop 目录）；修复 2026-10-19 冒烟测试发现的两处门禁缺陷（G1/G3 基线哈希在函数作用域内赋值导致恒与 `$null` 比对、G2 与规格步骤 5h 的 tests 字节一致拷贝自相矛盾），改按现行实现（门禁时实时计算哈希、tests 逐字节比对）；文件数由 142 重校为 **148**。该前身项目于 2026-10-20 并入 `ai-company` 基础血统成为 large 档，档位版本号取档位序号 **4.0.0**。本文即为该迁移的交付物之一 |

---

*本文为 `ai-company` 技能包**大型档**的生成与维护规格（自包含），GPL-3.0。修改本文本身也须遵守 §16 协议。*
-->

---

*This document is the self-contained generation and maintenance specification for the `ai-company` skill package's **large tier**, GPL-3.0. Modifying this document itself must also follow the §16 protocol.*
