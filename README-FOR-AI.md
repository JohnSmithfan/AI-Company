# README FOR AI — LLM Agent 治理技能包生成指南

> **你的任务**：生成一个**单入口、多部门**的 LLM Agent 治理技能包（SKILL）。
> **不是**复现某个既有项目。本文给你的是设计规格与质量红线，不是抄写清单。
>
> **唯一的人工决策**：公司规模档位（微型 / 小型 / 中型 / 大型 / 集团公司）。
> 档位一旦确定，部门集合、错误码规模、文件结构、功能范围**全部随之确定**，不要自行发挥。
>

---

## 术语约定：两套编号不要混用

本文有两套独立的分级编号，**含义完全不同**：

| 记号 | 名称 | 含义 | 出处 |
|---|---|---|---|
| **D1–D4** | 披露层级（Disclosure） | 加载层级：D1 frontmatter → D2 部门索引 → D3 部门子目录 → D4 引擎子单元 | 第 2、3 节 |
| **L1–L6** | Harness 成熟度 | 能力硬度：Skeleton → Functional → Robust → Resilient → Compliant → Certified | 第 4.4 节 |

⚠️ 凡说「D3 子目录」指披露层级；凡说「按 Harness L3+ 标准撰写」指成熟度。两者无对应关系。

---

## 0. 你要生成什么

一个供 LLM Agent 使用的**企业治理规范包**。Agent 接到任务时：

```
用户任务
  → 根 SKILL.md frontmatter（D1：元数据 + triggers + 域路由）
    → 匹配 triggers 决定「是否激活本技能」
      → 按 domain → department 两级路由决定「任务归哪个部门」（仅 L/G 档）
        → 读 references/departments/<slug>.md（D2：职责/错误码/约束/指标）
          → 需要深度规范时读 <slug>/ 子目录（D3：SOP、完整处置、部门模板）
            → 需要共享代码时读 references/templates.md（10 个 Python 模板）
```

四个机制缺一不可：

| 机制 | 载体 | 作用 |
|---|---|---|
| **技能激活** | frontmatter 的 `triggers` | 判断「这个任务要不要用本技能」，覆盖**用户任务面** |
| **部门路由** | frontmatter 的 `domains` + `references/department-index.md` | 判断「任务归哪个部门」，两级路由见 4.6 |
| **渐进式披露** | D1 → D2 → D3 → D4 | 按需加载，控制 token 消耗 |
| **共享模板** | `references/templates.md`（代码）+ `method-patterns.md`（索引） | 全部门复用同一套安全实现 |

⚠️ **triggers 与 department 是两件事，不要混为一谈。**
triggers 描述用户会说什么（`review the budget`），department 描述内部谁来干（`financial-management`）。
前一版把两者 1:1 绑定，导致 triggers 随部门数线性膨胀——36 部门 × 6 条 = 216 条 triggers，纯属 D1 层冗余。本版已解耦，见 2.1 与 5.4。

**治理的对象**：AI Agent 被建模为公司员工。这套隐喻不是装饰——它定义了**权限边界**（"权限不足"是一个错误码）、**升级路径**（董事会升级阶梯）、**冲突仲裁**（总部调解）。

---

## 1. ⛔ Step 0：向人工询问公司规模（强制，不可跳过）

**在生成任何文件之前**，必须先取得规模决策。这是本文唯一需要人工输入的决策点。

### 1.1 提问方式

用结构化选择题提问，五个选项，**顺序与措辞照抄**：

| 选项 | 标签 | 描述 |
|---|---|---|
| A | 微型 | 1–3 个 Agent，单一用途，个人维护。2 个部门，极简结构，最快落地 |
| B | 小型 | 3–10 个 Agent，单一产品，小团队维护。5 个部门，扁平结构 |
| C | 中型 | 10–50 个 Agent，2–5 条产品线，团队协作。9 个部门，引入财务/人力/情报 |
| D | 大型 | 50–200 个 Agent，多产品线，有专职职能团队。18 个部门，7 域两级路由，完整 D1/D2/D3 |
| E | 集团公司 | 200+ 个 Agent，多法人实体或多区域部署，需董事会级治理。36 个部门 + 总分公司架构 + 跨境合规 + D4 引擎层 |

### 1.2 兜底规则

| 情形 | 处理 |
|---|---|
| 人工明确选择某档 | 采用该档，进入第 2 节 |
| 人工回答"你定"/"随便" | **默认小型（B）**，并在交付说明中明确声明该假设 |
| 人工给出的信息暗示规模（如"我只有 2 个 Agent"） | 按暗示匹配档位，**仍需复述确认**："按你的描述我采用微型档，对吗？" |
| 人工拒绝回答或催促 | 默认小型（B），声明假设后直接生成 |

> 默认档取**小型**：五档体系下它是中位数，且不含 models/scripts 等可选重资产，误判成本最低。

### 1.3 为什么这一步不可跳过

五个档位的产出规模相差 **约 18 倍**（文件数 13 → 238，部门 2 → 36，错误码 20 → 216）。
猜错档位的返工成本远高于问一次。这不是偏好问题，是**决定架构形态**的问题：

| 档位 | 结构形态 |
|---|---|
| 微型 / 小型 / 中型 | **扁平**（仅 D1 + D2，无部门子目录，不分域） |
| 大型 | **三层**（D1 + D2 + D3）+ 7 域两级路由 |
| 集团 | **四层**（+ D4 引擎子单元）+ 总分公司架构 + 跨境合规 |

---

## 2. 五档位规格表（核心参数）

档位确定后，本表即为**权威规格**。生成时逐项对齐，不要跨档混用。

### 2.1 总览

| 参数 | 微型 XS | 小型 S | 中型 M | 大型 L | 集团 G |
|---|---|---|---|---|---|
| Agent 规模 | 1–3 | 3–10 | 10–50 | 50–200 | 200+ |
| `scale_tier` 枚举值 | `micro` | `small` | `medium` | `large` | `group` |
| **域数（一级路由）** | — 不分域 | — 不分域 | — 不分域 | **7** | **7** |
| **部门数** | **2** | **5** | **9** | **18** | **36** |
| **错误码前缀数** | 2 | 5 | 9 | 18 | 36 |
| **职能块总数**（见 2.6.1） | 18 | 18 | 18 | 18 | 36 |
| **错误码总条数** | 20–24 | 35–45 | 54–72 | 90–126 | 144–216 |
| **triggers 条数**（与部门数解耦） | 12–18 | 20–30 | 35–50 | 55–75 | 70–90 |
| **披露层级** | D1+D2 | D1+D2 | D1+D2 | D1+D2+D3 | D1+D2+D3+D4 |
| **frontmatter 行预算** | ≤75 | ≤85 | ≤105 | ≤140 | ≤160 |
| **文件总数** | **13** | **17–19** | **25–34** | **140** | **238** |
| 每部门 D2 字数 | 1200–2000 | 900–1500 | 800–1400 | 700–1200 | 600–1000 |
| WFT 核心集 / 扩展集 | 2 / 0 | 3 / 0 | 5 / 0–2 | 8 / 0–4 | 9 / 4–8 |
| `prompts/` 文件数 | 2 | 3 | 4 | 5 | 5 |

> ⚠️ **每部门字数随档位递减是正常的**：XS 档 1 个部门要承载 8–10 个职能块，G 档 1 个部门只承载 1 个。
> 全档位**职能正文总量大致恒定**（18 个职能块的内容），只是切分粒度不同。不要因字数区间小就砍掉职能。

### 2.2 frontmatter 逐字段行预算（自校验用）

不要只看总预算——**按本表逐字段核算**，超出即需下沉到 D3：

| 字段 | XS | S | M | L | G | 说明 |
|---|---:|---:|---:|---:|---:|---|
| name/slug/version/license/author | 5 | 5 | 5 | 5 | 5 | 固定 |
| `description` | 3 | 3 | 3 | 3 | 3 | ≤1024 字符 |
| `tags` | 1 | 1 | 2 | 2 | 2 | 数组 |
| `dependencies` | 1 | 1 | 1 | 1 | 1 | 恒为 `[]` |
| `triggers` | 16 | 26 | 43 | 66 | 81 | 按 2.1 中值 |
| `interface.inputs` | 17 | 17 | 17 | 20 | 20 | L/G 档多 `domain` 字段 3 行 |
| `interface.outputs` | 6 | 6 | 6 | 6 | 6 | XS 档可精简至 4 |
| `errors` | 1 | 1 | 1 | 1 | 1 | 恒为 `[]` |
| `error_code_prefixes` | 1 | 1 | 1 | 2 | 4 | 前缀清单，按档位换行 |
| `domains` | — | — | — | 8 | 8 | **仅 L/G**，7 域 + 键名 |
| `department_index` 指针 | — | — | — | 1 | 1 | **仅 L/G** |
| `permissions` | 8 | 8 | 8 | 8 | 8 | 照抄 4.1 |
| `quality` | 2 | 2 | 2 | 2 | 2 | 固定 |
| `metadata` | 9 | 9 | 9 | 9 | 9 | 含 `scale_tier` + `department_count` |
| `---` 分隔符 | 2 | 2 | 2 | 2 | 2 | |
| **合计** | **72** | **82** | **100** | **136** | **153** | |
| **预算** | ≤75 | ≤85 | ≤105 | ≤140 | ≤160 | ✅ 均有余量 |

⚠️ **关键前提：`department` 枚举不得内联在 frontmatter。**
L 档 18 项、G 档 36 项若内联，将额外增加 18/36 行，**分别击穿预算至 154 与 189 行**。
全表外置到 `references/department-index.md`（D2 层，按需加载），见 4.6 与 P30。
XS/S/M 档部门数 ≤9，**可以**内联（占用 ≤9 行，已计入 `interface.inputs`）。

### 2.3 文件总数推导表（自校验用）

**按本表逐项相加自行核算**，结果等于目标值即为正确：

| 组成 | XS | S | M | L | G |
|---|---:|---:|---:|---:|---:|
| 根文件（SKILL/_meta/README/LICENSE/.gitignore） | 5 | 5 | 5 | 7 | 7 |
| 根 CHANGELOG.md | — | — | 1 | ✓含上行 | ✓含上行 |
| 根 CONTRIBUTING.md | — | — | — | ✓含上行 | ✓含上行 |
| `prompts/` | 2 | 3 | 4 | 5 | 5 |
| `references/` 顶层（method-patterns + templates + error-codes） | 3 | 3 | 3 | 3 | 3 |
| `references/department-index.md`（域→部门全表） | — | — | — | 1 | 1 |
| `references/` 共享模块（execution/memory/visualization/data-integration/integrations） | — | — | 2 | 5 | 5 |
| `references/exec\|mem\|viz\|data/` 子目录 | — | — | — | 13 | 13 |
| 部门 D2 索引页 | 2 | 5 | 9 | 18 | 36 |
| 部门 D3 子目录（spec 1 + prompts 2 + method-patterns 1 = 4） | — | — | — | **72** | **144** |
| `sentiment-analysis/engines/` D4（5 引擎 + 3 专用 prompts） | — | — | — | — | **8** |
| `models/` | — | — | 0–7 | 12 | 12 |
| `scripts/` | — | 0–2 | 0–2 | 2 | 2 |
| `tests/` | 1 | 1 | 1 | 1 | 1 |
| **合计** | **13** | **17–19** | **25–34** | **140** | **238** |

核算式：
```
XS = 5+2+3+2+1                                    = 13
S  = 5+3+3+5+1                                    = 17  (+scripts 0–2 → 17–19)
M  = 6+4+3+2+9+1                                  = 25  (+models 0–7 +scripts 0–2 → 25–34)
L  = 7+5+3+1+5+13+18+72+12+2+1                    = 140
G  = 7+5+3+1+5+13+36+144+8+12+2+1                 = 238
```

> **最易整块遗漏项**：D3 子目录 = 部门数 × 4（L 档 72、G 档 144）。若核算偏离，先检查这一项。

### 2.4 七个域（仅 L/G 档启用一级路由）

| # | 域 slug | 域名 | G 档原子部门数 | L 档合并部门数 |
|---|---|---|---:|---:|
| 1 | `governance` | 治理与战略 | 6 | 3 |
| 2 | `finance` | 财务与风险 | 6 | 3 |
| 3 | `technology` | 技术与工程 | 6 | 3 |
| 4 | `security` | 安全与合规 | 6 | 3 |
| 5 | `people` | 人与文化 | 4 | 2 |
| 6 | `growth` | 增长与情报 | 4 | 2 |
| 7 | `delivery` | 交付与质量 | 4 | 2 |
| | **合计** | | **36** | **18** |

校验：6+6+6+6+4+4+4 = 36 ✓｜3+3+3+3+2+2+2 = 18 ✓
M/S/XS 档**不分域**，直接扁平路由到部门。

### 2.5 三十六个原子部门（G 档全集）

slug 命名规则见 5.5.1。前缀列即该部门的错误码前缀。

**域 1 `governance`（6）**
| # | slug | 前缀 | 职能 |
|---|---|---|---|
| 1 | `executive-office` | `CEO_` | 战略决策、愿景、危机管理、高管沟通 |
| 2 | `operations-command` | `COO_` | SLA、资源调度、PDCA、跨部门协调 |
| 3 | `hq-coordination` | `HQ_` | 跨 Agent 路由、消息总线、知识同步、排程、审计追踪 |
| 4 | `board-governance` | `BRD_` | 董事会升级阶梯、授权矩阵、股东报告 |
| 5 | `branch-management` | `BRN_` | 总分公司、分支生命周期、远程通信、跨境部署 |
| 6 | `strategy-planning` | `STP_` | OKR、路线图、战略对齐、市场进入 |

**域 2 `finance`（6）**
| # | slug | 前缀 | 职能 |
|---|---|---|---|
| 7 | `financial-management` | `CFO_` | 预算、定价、财务分析 |
| 8 | `risk-management` | `CRO_` | FAIR 评估、熔断、风险阈值、门控 |
| 9 | `procurement-vendor` | `PRC_` | 采购、供应商评估、合同成本 |
| 10 | `billing-unit-economics` | `BIL_` | 计费、成本分摊、单位经济 |
| 11 | `internal-audit` | `AUD_` | 内部审计、财务合规、证据链 |
| 12 | `treasury-budget` | `TRS_` | 资金、现金流、DSO/DPO、资本支出 |

**域 3 `technology`（6）**
| # | slug | 前缀 | 职能 |
|---|---|---|---|
| 13 | `engineering-architecture` | `CTO_` | 架构、Agent 创建、部署门 |
| 14 | `platform-framework` | `FW_` | 框架标准、CI/CD、Harness、ADR、脚手架 |
| 15 | `model-management` | `MDL_` | 模型注册表、调用策略、适配器、模型治理 |
| 16 | `data-engineering` | `DTE_` | 数据管道、schema、多源融合 |
| 17 | `mlops-observability` | `MLO_` | MLOps、模型健康、监控、A/B 测试 |
| 18 | `developer-tooling` | `DXT_` | 内部工具、SDK、开发者体验、模板库 |

**域 4 `security`（6）**
| # | slug | 前缀 | 职能 |
|---|---|---|---|
| 19 | `security-operations` | `CISO_` | STRIDE、CVSS、安全门、渗透测试 |
| 20 | `legal-compliance` | `CLO_` | 法律、AIGC 合规、DMCA、知识产权 |
| 21 | `privacy-data-protection` | `PRV_` | PII、GDPR/PIPL/CCPA、数据驻留 |
| 22 | `incident-response` | `IRP_` | 安全事件生命周期、取证、通报 |
| 23 | `identity-access` | `IAM_` | 认证、授权、凭据、mTLS、最小权限 |
| 24 | `resilience-continuity` | `RSC_` | 业务连续性、灾备、RTO/RPO |

**域 5 `people`（4）**
| # | slug | 前缀 | 职能 |
|---|---|---|---|
| 25 | `agent-lifecycle` | `CHO_` | Agent 入职/离职、编制、技能差距 |
| 26 | `knowledge-management` | `KNM_` | 知识提取、学习管道、记忆治理 |
| 27 | `ethics-culture` | `ETH_` | 伦理审查、文化审计、举报机制 |
| 28 | `capability-training` | `TRN_` | 培训、认证、能力矩阵 |

**域 6 `growth`（4）**
| # | slug | 前缀 | 职能 |
|---|---|---|---|
| 29 | `marketing-brand` | `CMO_` | 品牌、GTM、NPS、内容 |
| 30 | `partnerships-ecosystem` | `PTN_` | 合作、生态、渠道、联盟 |
| 31 | `competitive-intelligence` | `INTEL_` | 情报循环、SITREP、情报库、来源可靠性 |
| 32 | `sentiment-analysis` | `SNT_` | 情感分析（含 5 个 D4 引擎子单元） |

**域 7 `delivery`（4）**
| # | slug | 前缀 | 职能 |
|---|---|---|---|
| 33 | `quality-assurance` | `CQO_` | 质量门、测试、DORA、幂等、文档完整性 |
| 34 | `project-management` | `PMGR_` | 项目排期、冲刺承诺、工单 SLA、客户升级 |
| 35 | `localization-translation` | `TR_` | 翻译、文化适配、语言路由 |
| 36 | `information-services` | `INFO_` | 位置、天气、时间、多源融合服务 |

> **可视化职能归属**：图表/Mermaid/报告模板并入 `quality-assurance`（DORA 与文档完整性同源），不单设部门——避免 G 档出现第 37 个部门。`references/viz/` 作为共享模块存在（见 2.3），由 `quality-assurance` 引用。

### 2.6 部门合并树（严格包含关系）

**核心不变量**：大档任一部门 = 小档某部门拆出的**若干原子部门之并**；反向即小档部门 = 大档若干部门的**合并**。
不存在跨档交叉——这保证 Agent 在不同档位间迁移时职能不丢失、不重叠。

```
G 36 原子部门
  └─ 域内 2:1 合并 → L 18 部门
       └─ 按职能簇合并 → M 9 部门
            └─ 2:1 / 3:1 合并 → S 5 部门
                 └─ 2:1 / 3:1 合并 → XS 2 部门
```

#### L 档 18 部门（← G 档原子部门编号）

| L slug | 前缀 | 域 | ← G 原子 |
|---|---|---|---|
| `executive-strategy` | `CEO_` | governance | 1 + 6 |
| `operations-coordination` | `COO_` | governance | 2 + 3 |
| `board-and-branch` | `BRD_` | governance | 4 + 5 |
| `finance-treasury` | `CFO_` | finance | 7 + 12 |
| `risk-audit` | `CRO_` | finance | 8 + 11 |
| `procurement-billing` | `PRC_` | finance | 9 + 10 |
| `engineering-tooling` | `CTO_` | technology | 13 + 18 |
| `platform-mlops` | `FW_` | technology | 14 + 17 |
| `model-data` | `MDL_` | technology | 15 + 16 |
| `security-resilience` | `CISO_` | security | 19 + 24 |
| `legal-privacy` | `CLO_` | security | 20 + 21 |
| `incident-identity` | `IRP_` | security | 22 + 23 |
| `lifecycle-training` | `CHO_` | people | 25 + 28 |
| `knowledge-ethics` | `KNM_` | people | 26 + 27 |
| `marketing-partnerships` | `CMO_` | growth | 29 + 30 |
| `intelligence-sentiment` | `INTEL_` | growth | 31 + 32 |
| `quality-visualization` | `CQO_` | delivery | 33 + 36 |
| `delivery-scheduling` | `PMGR_` | delivery | 34 + 35 |

校验：18 个部门 × 2 原子 = 36 ✓｜每域 3+3+3+3+2+2+2 = 18 ✓

#### M 档 9 部门（← L 档）

| M slug | 前缀 | ← L 部门（数量） |
|---|---|---|
| `governance-and-strategy` | `CEO_` | executive-strategy + operations-coordination + board-and-branch（3） |
| `finance-and-risk` | `CFO_` | finance-treasury + risk-audit + procurement-billing（3） |
| `technology-and-engineering` | `CTO_` | engineering-tooling + platform-mlops（2） |
| `model-and-data` | `MDL_` | model-data（1） |
| `security-and-compliance` | `CISO_` | security-resilience + legal-privacy + incident-identity（3） |
| `people-and-culture` | `CHO_` | lifecycle-training + knowledge-ethics（2） |
| `growth-and-intelligence` | `CMO_` | marketing-partnerships + intelligence-sentiment（2） |
| `quality-and-operations` | `CQO_` | quality-visualization（1） |
| `information-and-localization` | `INFO_` | delivery-scheduling（1） |

校验：吸收 L 部门 3+3+2+1+3+2+2+1+1 = **18** ✓｜M 档部门数 = **9** ✓

#### S 档 5 部门（← M 档）

| S slug | 前缀 | ← M 部门（数量） |
|---|---|---|
| `governance-and-operations` | `CEO_` | governance-and-strategy + finance-and-risk（2） |
| `technology-and-platform` | `CTO_` | technology-and-engineering + model-and-data（2） |
| `security-and-compliance` | `CISO_` | security-and-compliance（1） |
| `people-and-growth` | `CHO_` | people-and-culture + growth-and-intelligence（2） |
| `quality-and-delivery` | `CQO_` | quality-and-operations + information-and-localization（2） |

校验：吸收 M 部门 2+2+1+2+2 = **9** ✓｜S 档部门数 = **5** ✓

#### XS 档 2 部门（← S 档）

| XS slug | 前缀 | ← S 部门（数量） |
|---|---|---|
| `governance-and-delivery` | `CEO_` | governance-and-operations + quality-and-delivery（2） |
| `engineering-and-safety` | `CTO_` | technology-and-platform + security-and-compliance + people-and-growth（3） |

校验：吸收 S 部门 2+3 = **5** ✓｜XS 档部门数 = **2** ✓

#### 2.6.1 职能块守恒（关键验收指标）

**职能块**（function block）= D2 索引页中一个带完整 3–7 节的角色/职能小节。

| 档位 | 部门数 | 职能块总数 | 各部门职能块数 |
|---|---:|---:|---|
| XS | 2 | **18** | governance-and-delivery = 8；engineering-and-safety = 10 |
| S | 5 | **18** | 6 / 3 / 3 / 4 / 2 |
| M | 9 | **18** | 3 / 3 / 2 / 1 / 3 / 2 / 2 / 1 / 1 |
| L | 18 | **18** | 各 1 |
| G | 36 | **36** | 各 1 |

**这个不变量的用途**：XS/S/M/L 四档的职能块总数**恒为 18**，等于 L 档部门数。
→ 生成任一合并档位后，数一遍 D2 页里的职能块总数，**必须等于 18**（G 档为 36）。
不等于 18 就说明**合并时丢了职能**（对应红线 P6）。这是比"逐个比对职能清单"快得多的自检方法。

XS 档展开明细（供核对）：
```
governance-and-delivery  (8)
  ← governance-and-operations (6) ← governance-and-strategy(3) + finance-and-risk(3)
  ← quality-and-delivery      (2) ← quality-and-operations(1) + information-and-localization(1)
engineering-and-safety   (10)
  ← technology-and-platform   (3) ← technology-and-engineering(2) + model-and-data(1)
  ← security-and-compliance   (3) ← security-and-compliance(3)
  ← people-and-growth         (4) ← people-and-culture(2) + growth-and-intelligence(2)
合计 8 + 10 = 18 ✓
```

**前缀继承规则**：合并后采用**上位部门的前缀**，被合并部门的前缀在该档位**退役**。
例如 M 档 `finance-and-risk` 用 `CFO_`，则 `CRO_`/`PRC_` 在 M 档不存在（其职能作为职能块保留，但错误码统一用 `CFO_`）。
`references/error-codes.md` 每档**只列该档启用的前缀**。

### 2.7 功能范围（按档位启用）

| 功能模块 | XS | S | M | L | G | 说明 |
|---|:--:|:--:|:--:|:--:|:--:|---|
| 10 个共享代码模板 | ✅ | ✅ | ✅ | ✅ | ✅ | **安全底线，任何档位不得裁剪** |
| 3 个提示词框架 | ✅ | ✅ | ✅ | ✅ | ✅ | 同上 |
| Harness L1–L6 分级 | ✅ | ✅ | ✅ | ✅ | ✅ | 同上 |
| AIGC 三重标识 | ✅ | ✅ | ✅ | ✅ | ✅ | 同上 |
| PII 脱敏强制（三类齐全） | ✅ | ✅ | ✅ | ✅ | ✅ | 同上 |
| 权限 deny 列表 | ✅ | ✅ | ✅ | ✅ | ✅ | 同上 |
| 错误码体系 | ✅ | ✅ | ✅ | ✅ | ✅ | 规模随档位 |
| 执行引擎（4 模式 × 4 触发器） | 2 触发器 | 3 触发器 | ✅ | ✅ | ✅ | XS 仅 Manual+Schedule；S 加 Event |
| 记忆系统（5 类型） | — | — | ✅ | ✅ | ✅ | XS/S 不引入 |
| 工作流模板 WFT | 见 2.8 | 见 2.8 | 见 2.8 | 见 2.8 | 见 2.8 | |
| 熔断/回滚/升级阶梯 | — | — | ✅ | ✅ | ✅ | |
| 域→部门两级路由 | — | — | — | ✅ | ✅ | L+ 专属 |
| 模型管理架构 | — | — | 可选 | ✅ | ✅ | |
| 自动更新 + 安全门 | — | 可选 | 可选 | ✅ | ✅ | |
| 可视化模块 | — | — | — | ✅ | ✅ | |
| 数据集成模块 | — | — | — | ✅ | ✅ | |
| **总分公司架构**（3 层 HQ-Branch-Local） | — | — | — | — | ✅ | G 专属 |
| **远程通信架构**（gRPC/WS/QUIC + mTLS） | — | — | — | — | ✅ | G 专属 |
| **跨境合规**（GDPR SCC / PIPL / CCPA） | — | — | — | 简版 GDPR | ✅ 全量 | |
| **董事会升级阶梯** | — | — | — | 简版 | ✅ | |
| **D4 引擎子单元**（情感分析 5 引擎） | — | — | — | — | ✅ | G 专属 |

⚠️ **不得跨档混用**：给微型档加总分公司架构，或给集团档砍掉 PII 脱敏，都是错误。

### 2.8 工作流模板 WFT（核心集 + 扩展集）

**核心集 WFT-001~009：编号与名称固定，不得重排或重新编号。**

| ID | 名称 | 触发器 | XS | S | M | L | G |
|---|---|---|:--:|:--:|:--:|:--:|:--:|
| WFT-001 | Data Collection Pipeline | Schedule/Manual | ✅ | ✅ | ✅ | ✅ | ✅ |
| WFT-002 | Report Generation | Schedule | ✅ | ✅ | ✅ | ✅ | ✅ |
| WFT-003 | Alert Response | Event | — | ✅ | ✅ | ✅ | ✅ |
| WFT-004 | Skill Publishing | Manual | — | ✅ | ✅ | ✅ | ✅ |
| WFT-005 | Incident Response | Event | — | — | ✅ | ✅ | ✅ |
| WFT-006 | Budget Review | Schedule | — | — | ✅ | ✅ | ✅ |
| WFT-007 | Deployment | Manual/Webhook | — | — | ✅ | ✅ | ✅ |
| WFT-008 | Market Intelligence | Schedule/Event | — | — | ✅ | ✅ | ✅ |
| WFT-009 | Branch Rollout | Manual | — | — | — | — | ✅ |

**扩展集 WFT-1xx：可增，规则如下。**
核心集 9 个模板在 18/36 部门规模下覆盖不足，L/G 档按域扩展：

| 规则 | 内容 |
|---|---|
| 命名 | `WFT-1<域序号><两位序号>`，域序号 1–7 对应 2.4 表顺序 |
| 示例 | `WFT-101` = governance 域第 1 个扩展工作流；`WFT-403` = security 域第 3 个 |
| 数量 | L 档 0–4 个，G 档 4–8 个（每域至多 1–2 个） |
| 约束 | **只能新增，不得占用 001–099 区间**；每个扩展工作流必须在所属域的 D2 索引页被引用 |

---

## 3. 目录结构（按档位）

⚠️ 每档给**完整目录树**，不用「在上一档基础上增量」的表述——差分表述在部门数变化时极易算错。

### 3.1 微型 XS（13 文件，扁平）

```
<skill-name>/
├── SKILL.md                  # 唯一入口，frontmatter ≤75 行
├── _meta.json
├── README.md
├── LICENSE
├── .gitignore
├── prompts/                  # 2 个
│   ├── 01-implement-method.md
│   └── 02-robustness-checks.md
├── references/
│   ├── method-patterns.md    # 10 模板索引表 + 3 提示词框架（不含代码）
│   ├── templates.md          # ★ 10 个模板完整代码（唯一权威位置）
│   ├── error-codes.md        # 20–24 条，2 个前缀
│   └── departments/          # 2 个，无子目录
│       ├── governance-and-delivery.md      # 8 个职能块
│       └── engineering-and-safety.md       # 10 个职能块
└── tests/
    └── test-method-patterns.py
```

### 3.2 小型 S（17–19 文件，扁平）

```
<skill-name>/
├── SKILL.md  _meta.json  README.md  LICENSE  .gitignore
├── prompts/                          # 3 个（+ 03-test-cases.md）
├── references/
│   ├── method-patterns.md
│   ├── templates.md                  # ★
│   ├── error-codes.md                # 35–45 条，5 个前缀
│   └── departments/                  # 5 个，无子目录
│       ├── governance-and-operations.md      # 6 职能块
│       ├── technology-and-platform.md        # 3 职能块
│       ├── security-and-compliance.md        # 3 职能块
│       ├── people-and-growth.md              # 4 职能块
│       └── quality-and-delivery.md           # 2 职能块
├── scripts/                          # 可选（决定文件数 17 或 19）
│   ├── auto-update.ps1
│   └── update-config.json
└── tests/
    └── test-method-patterns.py
```

### 3.3 中型 M（25–34 文件，扁平 + 共享模块）

```
<skill-name>/
├── SKILL.md  _meta.json  README.md  CHANGELOG.md  LICENSE  .gitignore
├── prompts/                          # 4 个（+ 04-documentation.md）
├── references/
│   ├── method-patterns.md
│   ├── templates.md                  # ★
│   ├── error-codes.md                # 54–72 条，9 个前缀
│   ├── execution.md                  # 共享模块
│   ├── memory.md                     # 共享模块
│   └── departments/                  # 9 个，无子目录
│       ├── governance-and-strategy.md          # 3 职能块
│       ├── finance-and-risk.md                 # 3 职能块
│       ├── technology-and-engineering.md       # 2 职能块
│       ├── model-and-data.md                   # 1 职能块
│       ├── security-and-compliance.md          # 3 职能块
│       ├── people-and-culture.md               # 2 职能块
│       ├── growth-and-intelligence.md          # 2 职能块
│       ├── quality-and-operations.md           # 1 职能块
│       └── information-and-localization.md     # 1 职能块
├── models/                           # 可选（0–7 文件）
│   ├── config/  models-registry.json  calling-policy.json
│   ├── adapters/ adapter_interface.py
│   └── api/     template/config.json + <provider>/<model>.json
├── scripts/                          # 可选（0–2 文件）
└── tests/
    └── test-method-patterns.py
```

### 3.4 大型 L（140 文件，三层 + 域路由）

```
<skill-name>/
├── SKILL.md  _meta.json  README.md  CHANGELOG.md  CONTRIBUTING.md  LICENSE  .gitignore
├── prompts/                          # 5 个（+ 05-workflow-execution.md）
├── references/
│   ├── method-patterns.md            # 索引层
│   ├── templates.md                  # ★ 10 模板代码（唯一权威位置）
│   ├── error-codes.md                # 90–126 条，18 个前缀
│   ├── department-index.md           # ★ 域→部门全表（7 域 + 18 部门）
│   ├── execution.md      → exec/     # 4 文件：modes-triggers / command-center / error-recovery / workflows-schema
│   ├── memory.md         → mem/      # 2 文件：architecture / management-compliance
│   ├── visualization.md  → viz/      # 4 文件：chart-types / mermaid-diagrams / report-templates / integration-compliance
│   ├── data-integration.md → data/   # 3 文件：financial-news / information-fusion / schema-security
│   ├── integrations.md               # 无子目录
│   └── departments/                  # 18 个部门
│       ├── <slug>.md                 # D2 索引页 × 18（各 1 职能块）
│       └── <slug>/                   # D3 深度目录 × 18 = 72 文件
│           ├── department-spec.md    # ⚠️ 不叫 SKILL.md，见 P1
│           ├── prompts/              # 01-implement-method.md + 02-robustness-checks.md
│           └── references/
│               └── method-patterns.md  # 部门专属模板（禁止复制 10 个共享模板）
├── models/                           # 12 文件
│   ├── README.md
│   ├── config/  models-registry.json  calling-policy.json
│   ├── adapters/ adapter_interface.py    # ⚠️ 只 1 个，见 P9
│   ├── api/     template/config.json + openai/ + anthropic/ + ollama/(4)
│   └── local/   template/config.json + <model>/config.json
├── scripts/  auto-update.ps1  update-config.json
└── tests/    test-method-patterns.py
```

### 3.5 集团 G（238 文件，四层）

在 L 的基础上：
- `references/departments/` 增至 **36 个** D2 索引页 + **36 个** D3 子目录（144 文件）
- `references/department-index.md` 收录 7 域 + 36 部门
- `references/error-codes.md` 增至 144–216 条、36 个前缀
- **新增 D4 层**（仅 `sentiment-analysis` 部门有，8 文件）：

```
references/departments/sentiment-analysis/
├── department-spec.md
├── engines/                      # ★ D4：5 个引擎子单元
│   ├── query-engine.md
│   ├── media-engine.md
│   ├── insight-engine.md
│   ├── report-engine.md
│   └── forum-engine.md
├── prompts/                      # 通用 2 个 + 情感分析专用 3 个 = 5 个
│   ├── 01-implement-method.md
│   ├── 02-robustness-checks.md
│   ├── s03-test-cases-sentiment.md
│   ├── s04-documentation-sentiment.md
│   └── s05-workflow-execution-sentiment.md
└── references/method-patterns.md
```

⚠️ **引擎不是部门**：5 个引擎是 `sentiment-analysis` 部门的 **D4 子单元**，共用 `SNT_` 前缀，
**不得**出现在 `department-index.md` 的部门列或 frontmatter 的 `department` 枚举中。
（注：`sentiment-analysis` **本身是** G 档 36 个原子部门之一，有独立前缀 `SNT_`；其下的 5 个引擎才是子单元。）

并启用总分公司架构、远程通信、跨境合规三套规范（写入 `branch-management` 与 `board-governance` 的 D2/D3）。

---

## 4. 跨档位不变量（任何规模都不得裁剪）

以下内容与公司规模**无关**，属安全与工程底线。

### 4.1 权限声明（逐字符照抄）

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

- 写权限**严格限于** `{WORKSPACE_ROOT}`；技能目录自身**只读**
- `deny` 列表**不得删减任何一项**（P0 级安全边界，微型档也不例外）
- 一律使用 `{WORKSPACE_ROOT}` / `{SKILL_DIR}` / `{WINDOWS_DIR}` 占位符，**禁止硬编码绝对路径**

### 4.2 十个共享模板（函数签名固定）

签名中的**参数名与默认值不得改动**——测试断言依赖它们。

| # | 签名 | 用途 | 安全约束 |
|---|---|---|---|
| 1 | `validate_input_schema(data, schema)` | Schema 校验 | 无外部 I/O |
| 2 | `sanitize_user_query(query)` | 输入净化 | 无动态代码执行 |
| 3 | `execute_safe_command(cmd, timeout=30)` | 沙箱执行 | 超时 + 受限 cwd |
| 4 | `format_output_json(content, provider)` | 标准 JSON + AIGC 标签 | 内嵌 AI 水印 |
| 5 | `retry_with_backoff(func, max_retries=3)` | 指数退避 | 容错 |
| 6 | `read_reference_file(filepath)` | 安全读文件 | 路径校验，越界拒绝 |
| 7 | `generate_trace_id(prefix="trace")` | 审计追踪 ID | 无状态 |
| 8 | `check_rate_limit(identifier, limit=10, window=60)` | 限流 | 仅内存，不落盘 |
| 9 | `mask_sensitive_data(text)` | PII 脱敏 | 不记录原始数据 |
| 10 | `build_prompt_from_template(template, **kwargs)` | 提示词生成 | 输入先净化 |

**⚠️ 模板 9 的完整实现（三类脱敏，缺一不可）**

行为契约：脱敏占位符固定为 `[EMAIL]` / `[IP]` / `[PHONE]`，**三类都必须实现**。

```python
def mask_sensitive_data(text):
    """Mask sensitive information in output (emails, IPs, phone numbers)."""
    # Mask email addresses
    text = re.sub(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', '[EMAIL]', text)
    # Mask IP addresses
    text = re.sub(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b', '[IP]', text)
    # Mask phone numbers (11-digit)
    text = re.sub(r'\b[0-9]{11}\b', '[PHONE]', text)
    return text
```

> **为什么必须包含 PHONE 分支**（实测教训，本文前一版的严重缺陷）：
> 被审核的原包在此处存在**三重自相矛盾**——
> ① 权威源 `.md` 中的实现只有 EMAIL 与 IP，docstring 也只写 "(emails, IPs)"；
> ② 该包的测试 `test_phone_masking` 却断言 `[PHONE]` 必须出现；
> ③ 测试之所以仍然 19/19 全绿，是因为它把**另一份含 PHONE 的实现内联复制进了测试文件**（`re.sub(r'\b[0-9]{11}\b', '[PHONE]', text)`），与被测源文件不是同一份代码。
> 全量 93 个 `.md` 搜索 `[PHONE]` **零命中**——即权威源缺失 PHONE 这件事，测试永远发现不了。
> **本文前一版直接抄了缺 PHONE 的版本，同时又在契约里声明 `[PHONE]`、在测试要求里写"phone 三类均脱敏"——照抄即测试必然失败。务必按上方完整实现生成。**

**⚠️ 代码存放的唯一权威位置：`references/templates.md`**

无论哪个档位，10 个模板的**完整代码只存在于这一个文件**。
- `references/method-patterns.md` 只放**索引表**（编号/函数名/用途/安全属性），并链接到 `templates.md`
- 各部门的 `references/method-patterns.md` 只放**该部门专属**模板，**禁止复制**这 10 个共享模板
- 任何部门 D2/D3 文件需要引用模板时，**只写链接，不内联代码**

> 实测教训：原包把模板代码同时放进「部门 D2 索引页（847 行）」和「部门 D3 子目录（959 行）」，两份哈希不同、章节组织不同，而索引文件只用一句模糊的 "Full code in Platform & Infrastructure department file" 指向它们——无人能判断哪份是权威。单一存放位置从根上消除歧义。

### 4.3 三个提示词框架（逐字符照抄）

```
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

### 4.4 Harness L1–L6 分级（不得改级定义）

| 级 | 名称 | 约束 | 适用场景 |
|---|---|---|---|
| L1 | Skeleton | 基础 schema、frontmatter | 原型 |
| L2 | Functional | 输入校验、输出格式化 | 内部工具 |
| L3 | Robust | 错误处理、重试、幂等 | 部门工具 |
| L4 | Resilient | 熔断、限流、监控 | 生产服务 |
| L5 | Compliant | AIGC 标签、PII 脱敏、审计追踪 | 面向客户 |
| L6 | Certified | STRIDE 模型、CVSS 评分、CISO 签核 | 关键基础设施 |

**档位与 Harness 的关系**：档位决定「有多少部门、切多细」，Harness 决定「每个能力做到多硬」。
**任何档位的部门都应按 Harness L3+ 标准撰写规范**——微型档的 2 个部门同样如此，不要因为规模小就降低单点质量。
（注意：此处 L3 指 Harness 成熟度，与披露层级 D3 无关。）

### 4.5 安全底线（不可协商）

- 零动态代码执行（无 `eval` / `exec` 处理用户输入）
- 零硬编码密钥（一律走环境变量，配置文件只写**变量名**不写值）
- 零敏感路径访问
- `mask_sensitive_data`（模板 9）在所有输出管道中**强制启用**，且 EMAIL/IP/PHONE 三类齐全
- 所有 AIGC 输出带**三重标识**：显式标签 + 隐式元数据 + 内嵌水印
- 所有操作**幂等**，可安全重试

### 4.6 两级路由设计（仅 L/G 档）

18/36 个部门平铺在一张枚举里，Agent 做 `department: auto` 路由时需在数十个选项中一次选中，准确率显著低于分层选择。因此 L/G 档采用**域 → 部门**两级路由：

**frontmatter 只放域表**（7 项，约 8 行）：
```yaml
domains:
  - { slug: governance, name: 治理与战略, departments: 6 }
  - { slug: finance,    name: 财务与风险, departments: 6 }
  - { slug: technology, name: 技术与工程, departments: 6 }
  - { slug: security,   name: 安全与合规, departments: 6 }
  - { slug: people,     name: 人与文化,   departments: 4 }
  - { slug: growth,     name: 增长与情报, departments: 4 }
  - { slug: delivery,   name: 交付与质量, departments: 4 }
department_index: references/department-index.md   # ★ 部门全表外置
```
（`departments` 值：G 档按原子数，L 档按合并数——见 2.4）

**路由算法**（写入 `references/execution.md`）：
```
1. 任务文本 → 匹配 triggers → 激活技能
2. 若显式指定 department → 直接用（须在 department-index.md 中存在）
3. 否则 department: auto：
   a. 先匹配 domain（7 选 1，靠域名 + 域级关键词）
   b. 再在域内匹配 department（≤6 选 1，靠各 D2 的 Trigger Scenarios）
4. 读该部门 D2；需要深度时读 D3；G 档情感分析再下探 D4
```

⚠️ **M/S/XS 档不分域**：`domains` 与 `department_index` 字段省略，`department` 枚举直接内联（≤9 项）。

---

## 5. 文件骨架

### 5.1 `_meta.json`

```json
{
  "ownerId": "<自定>",
  "slug": "<skill-slug>",
  "version": "1.0.0",
  "license": "GPL-3.0",
  "publishedAt": <epoch_ms>
}
```
新技能包从 `1.0.0` 起版，**不要继承被审核原包的版本号**。

### 5.2 根 `SKILL.md` frontmatter

```yaml
---
name: "<skill-slug>"              # ⚠️ 单行引号标量。禁止用 | 或 > 块标量
slug: "<skill-slug>"
version: "1.0.0"
description: "<一段话：档位、部门数、覆盖职能、共享资产、何时使用。700–900 字符>"
license: "GPL-3.0"
author: "<自定>"
tags: [<8–16 个标签>]
dependencies: []                  # ⚠️ 恒为空数组，无外部依赖
triggers:                         # 条数按 2.1（与部门数解耦）
  - ...
domains: [...]                    # ★ 仅 L/G 档，照抄 4.6
department_index: references/department-index.md   # ★ 仅 L/G 档
interface:
  inputs:
    type: object
    schema:
      type: object
      properties:
        task:
          type: string
          description: Task description
        domain:                   # ★ 仅 L/G 档
          type: string
          enum: [governance, finance, technology, security, people, growth, delivery]
          description: Which domain to route to
        department:
          type: string
          description: Which department to invoke; omit or "auto" to auto-route
          # ⚠️ XS/S/M 档：内联 enum（≤9 项 + auto）
          # ⚠️ L/G 档：不写 enum，见 department_index 指针
        context:
          type: object
          description: Optional context information
      required: [task]
  outputs:
    type: object
    schema:
      type: object
      properties:
        result: { type: string, description: Operation result }
        report: { type: object, description: Detailed report data }
      required: [result]
  errors: []                      # ⚠️ 全表放 references/error-codes.md，此处留空
error_code_prefixes: [<该档位前缀清单>]   # 只列前缀，不列具体码
permissions: { ... }              # 照抄 4.1
quality:
  idempotent: true
metadata:
  category: enterprise
  layer: AGENT
  cluster: <cluster-name>
  maturity: <STABLE|BETA>
  license: GPL-3.0
  standardized: true
  scale_tier: <micro|small|medium|large|group>   # ★ 档位决策留痕
  department_count: <2|5|9|18|36>                # ★ 须与 scale_tier 对应
  function_block_count: <18|18|18|18|36>         # ★ 职能块守恒，见 2.6.1
---
```

**三条硬约束**：
1. **`errors: []`** —— 原包把 134 条错误码内联 frontmatter，占 269 行 = 64%，导致 D1 层超标 3.5 倍。每次加载全量吞入，而绝大多数任务只用 1–2 条。frontmatter 只保留**前缀清单**。
2. **L/G 档 `department` 不写 enum** —— 18/36 项内联会额外增加同等行数，击穿 2.2 预算（L 达 154、G 达 189）。全表外置到 `department-index.md`。
3. **`description` ≤ 1024 字符**（SkillImport 硬校验上限），目标 700–900。

### 5.3 错误码设计规则

**命名格式**：`<PREFIX>_<NNN>`
- `PREFIX` = 该档位部门的错误码前缀（见 2.5 / 2.6 各档表格的前缀列）
- `NNN` = 三位零填充序号，从 `001` 起
- 子系统专属码可用 `<PREFIX>_E<NNN>`（如 `CEO_E016`），须在 `error-codes.md` 说明该子命名空间

**⚠️ 编号必须连续，禁止空洞。**
原包 `CTO_` 系列缺 `CTO_007`、`CTO_008`（新增分支错误码时从 009 起跳），维护者无法判断是「已废弃」还是「漏写」。
新增错误码时**追加到末尾**，不要插入中间。

**每条错误码必须含四要素**（原包多数只有前两项）：
```markdown
| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CFO_001 | Budget overrun | 部门支出超出季度预算 >10% | 1. 冻结非必要支出 2. 生成差异分析 3. 上报 CEO 审批 |
```

**条数分配**（按 2.1 总条数均摊到各前缀）：
| 档位 | 前缀数 | 每前缀基准 | 可上浮的前缀 |
|---|---|---|---|
| XS | 2 | 10–12 条 | 两部门均承载 8–10 个职能块，取上限 |
| S | 5 | 7–9 条 | `CEO_`（6 职能块）、`CHO_`（4 职能块） |
| M | 9 | 6–8 条 | `CEO_`、`CFO_`、`CISO_`（各 3 职能块） |
| L | 18 | 5–7 条 | `CEO_`、`CTO_`、`MDL_`、`FW_` |
| G | 36 | 4–6 条 | 同上 + `BRN_`（分支/远程/跨境）、`SNT_` |

> **每前缀条数随档位递减是正常的**：档位越低，单个前缀需覆盖的职能面越宽（XS 档 2 个前缀要覆盖 18 个职能块）。

### 5.4 triggers 设计规则（与部门数解耦）

**triggers 覆盖的是「用户任务面」，不是「内部部门划分」。**
用户不会因为你的内部部门从 18 拆到 36 就多说出 2 倍的话。

| 档位 | 条数 | 分组方式 |
|---|---|---|
| XS | 12–18 | 3 组（治理/工程/交付），每组 4–6 条 |
| S | 20–30 | 5 组（对应 5 部门），每组 4–6 条 |
| M | 35–50 | 6–7 组（按职能簇，非严格 1:1），每组 5–7 条 |
| L | 55–75 | **7 组（对应 7 域）**，每组 8–11 条 |
| G | 70–90 | **7 组（对应 7 域）**，每组 10–13 条 |

⚠️ **L/G 档按域分组，不按部门分组**——36 组 × 6 条 = 216 条是纯粹的 D1 层冗余，且会击穿 frontmatter 预算。

**质量要求**：
- 用**任务语义短语**，不用单词堆砌（`review quarterly budget` 优于 `budget`）
- 覆盖该职能的**典型任务动词**（review / create / run / assess / translate / approve / audit）
- 组内不重复，组间不冲突（避免两个域抢同一 trigger）
- 全部小写，除公认缩写（STRIDE、AIGC、CRISPE、CI/CD、OKR、SLA、GDPR、PIPL、SITREP）

### 5.5 部门 D2 索引页骨架（统一，所有部门一致）

⚠️ **所有部门必须用同一套章节骨架**。原包 11 个部门存在 **5 种互不兼容的变体**——错误码表在有的部门是第 4 节、有的是第 7 节、有的完全无编号，导致 Agent 无法用统一规则解析。

```markdown
# <Department Display Name>

> D2 索引页。所属域：<domain>。深度规范见 [<slug>/](<slug>/)。   ← 前半句仅 L/G；后半句仅 L/G
> 职能块数：<N>                                                 ← ★ 合并档位必填，用于守恒校验

## 1. Trigger Scenarios        ← 必须有。5–10 条自然语言任务描述
## 2. Core Identity            ← 必须有。角色定位、权限边界、汇报关系

## <FUNCTION BLOCK 1: ROLE>    ← 每个职能块重复以下 5 节
### 3. Core Responsibilities
#### 3.1 <职责名>              ← 每条含【职责描述 + 输入 + 输出 + SLA】四要素
#### 3.2 ...
### 4. Error Codes             ← 必须有。该前缀全部错误码 + Resolution Steps
### 5. Integration Points      ← 与哪些部门协作、通过什么机制
### 6. Constraints             ← 禁止事项，用 ❌ 列表
### 7. Quality Metrics         ← 可量化指标 + 阈值

## <FUNCTION BLOCK 2: ROLE2>   ← 下一个职能块，重复 3–7 节
...

## Prompts                     ← 仅 L/G 档。避免孤儿文件，见 P8
- [01-implement-method.md](<slug>/prompts/01-implement-method.md)
- [02-robustness-checks.md](<slug>/prompts/02-robustness-checks.md)

## Workflows                   ← 仅 L/G 档且有扩展集时
- [WFT-1xx](../../execution.md#wft-1xx)
```

**章节编号从 1 开始，不得跳号。**
原包所有 11 个部门 D2 都从 `## 3.` 起跳（缺 1 和 2），说明合并时删掉了 Trigger Scenarios 与 Core Identity 却未重编号。后果是 Agent 在 D2 层拿不到触发场景与角色身份，被迫下沉 D3，**直接违背渐进式披露省 token 的目的**。

**合并档位的职能块要求**（关键，XS/S/M 档）：
一个部门由多个原子部门合并而来时，**每个被合并的职能都要有自己的职能块**（含完整 3–7 节）。
例如 M 档 `finance-and-risk` 需 3 个职能块（财务/风险/采购计费），XS 档 `engineering-and-safety` 需 **10 个**职能块。
可合并相近职能的**描述**，但 3–7 节的**结构不得省略**，职能不得丢失。

> 原包 `security-and-compliance` 的 CISO 段缺第 4 节错误码表，但 frontmatter 定义了 CISO_001~005，D2 与清单脱节——**不得重犯**。
> **自检捷径**：数 D2 页职能块总数，XS/S/M/L 档必须 = **18**，G 档 = **36**（见 2.6.1）。

#### 5.5.1 部门 slug 命名规范

36 个部门无法靠枚举照抄，必须定规则，否则生成者会产出不一致的命名：

| 规则 | 内容 |
|---|---|
| 字符集 | 全小写 ASCII + 连字符，无空格、无下划线、无点号 |
| 结构 | `<职能>[-<限定>]` 或 `<职能>-and-<职能>`（合并档） |
| 长度 | ≤ 40 字符 |
| 首尾字符 | 必须是字母，不得以数字或连字符开头/结尾 |
| 缩写 | 仅允许公认缩写：`hq` `mlops` `aigc` `iam` `viz` `dx` `gdpr`。其余一律全拼（`information-services` 而非 `info-services`） |
| 唯一性 | 全包内 slug 唯一 |
| 域前缀 | **不加**域前缀（`governance-executive-office` ❌），域归属由 `department-index.md` 表达 |
| 来源 | L/G 档从 2.5 / 2.6 表格**照抄**，不得自创；XS/S/M 档同理照抄对应表 |

### 5.6 部门 D3 `department-spec.md` 骨架（仅 L/G 档）

⚠️ **文件名不得为 `SKILL.md`，且不得包含 `name` / `slug` / `triggers` / `interface` 字段。**

```yaml
---
department: <slug>              # 用 department 键，不用 name
domain: <domain-slug>           # ★ 仅 L/G 档
parent: <skill-slug>
roles: [<ROLE>, <ROLE2>]
error_code_prefix: <PREFIX_>
license: "GPL-3.0"
dependencies:
  runtime: [python3.9+]
  skills: []                    # ⚠️ 恒为空。不要填本包内部的部门名
---
```
```markdown
# <Department Display Name> — Deep Specification

## 1. Trigger Scenarios (Extended)
## 2. Core Identity (Extended)
## 3. Core Responsibilities (Full)
## 4. Error Codes (Full + Resolution Steps)
## 5. Integration Points
## 6. Constraints
## 7. Quality Metrics
## 8. SOPs / Operational Procedures
```

**两条理由**（均来自实测）：
1. **文件名**：原包 11 个 `references/departments/*/SKILL.md` 都带完整 frontmatter 和独立 `name` 字段。技能加载器若递归扫描子目录，会把它们注册成 **11 个独立技能**，其 triggers 与父技能大面积重叠冲突，路由不确定。**G 档 36 个子目录会把这个问题放大 3 倍**。
2. **`dependencies.skills`**：原包填了 `["ai-company-governance-and-strategy", ...]`——这些是**合并前的 legacy 独立技能名，在统一包里已不存在**。依赖解析器找不到 → 安装失败或告警；且与根 `dependencies: []` 自相矛盾。部门间协作应写在 D2 的 `Integration Points`。

### 5.7 `references/department-index.md`（仅 L/G 档）

承载 frontmatter 外置的部门全表，是两级路由的第二级数据源：

```markdown
# Department Index

> 由根 SKILL.md 的 `department_index` 指针引用。D2 层，按需加载。

## Domain: governance（治理与战略）
| Department slug | Prefix | Roles | Functions | D2 | D3 |
|---|---|---|---|---|---|
| executive-office | CEO_ | CEO | 战略决策、愿景、危机管理 | [→](departments/executive-office.md) | [→](departments/executive-office/) |
| operations-command | COO_ | COO | SLA、资源调度、PDCA | [→](departments/operations-command.md) | [→](departments/operations-command/) |
| ... |

## Domain: finance（财务与风险）
...

## Routing Rules
<4.6 节的路由算法，含域级关键词表>
```

⚠️ 表内每个 `[→]` 链接目标**必须真实存在**，生成后用第 9 节断链脚本校验。

### 5.8 模型管理配置（L/G 档，M 档可选）

**`models/config/models-registry.json`**：每个注册项的 `config_path` **必须指向真实存在的文件**。
`config_path` 相对于 `models/` 解析（适配器实现：`MODELS_DIR = Path(__file__).parent.parent`，再 `MODELS_DIR / config_path`）。

⚠️ 原包 7 个 `config_path` 中有 1 个（`local/llama-3.3-70b/config.json`）指向不存在的文件，适配器 `open()` 直接抛 `FileNotFoundError`，**整条 fallback 降级链断裂**。生成后必须逐个 `Test-Path` 校验。

**`models/api/template/config.json`**：模板必须**覆盖实际模型配置的全部字段**：

```json
{
  "id": "{{MODEL_ID}}",
  "provider": "{{PROVIDER}}",
  "type": "{{api|local}}",
  "endpoint": "{{ENDPOINT}}",
  "env_var_name": "{{API_KEY_ENV_VAR}}",
  "context_window": 0,
  "max_output_tokens": 0,
  "pii_filtering": true,
  "rate_limits": { "rpm": 0, "tpm": 0, "daily": 0 }
}
```
⚠️ **只写环境变量名（`env_var_name`），绝不写密钥值**——连"示例密钥"也不行。
原包模板只有 3 个占位符，而实际配置含 `context_window`、`max_output_tokens`、`pii_filtering` 等模板未定义字段 → 模板失去参考价值。

**适配器文件**：只生成 **1 个**，命名 `adapter_interface.py`（下划线）。
原包同时存在 `adapter-interface.py`（10164 B）与 `adapter_interface.py`（10677 B），哈希不同、内容不同，仅分隔符差异——而**连字符版根本无法作为 Python 模块被 import**。

### 5.9 自动更新脚本（L/G 档，S/M 档可选）

**回滚逻辑必须「先复制后删除」**：
```
Copy-Item 到临时目录 → 校验完整性 → 原子替换 → 确认成功后才删旧目录
```
⚠️ **禁止**先 `Remove-Item -Path $SKILL_DIR -Recurse -Force` 再恢复。原包正是这样写的：若 `Copy-Item` 阶段因磁盘满/权限不足/进程被杀而失败，**整个技能包已被递归强制删除且无自动恢复路径**。G 档 238 个文件，损失更大。

**备份目录必须跨平台**：`$env:USERPROFILE` 为空时回退到 `$HOME`。
原包硬编码 `$env:USERPROFILE`，注释却宣称支持 macOS——在 macOS/Linux 下该变量为空，路径退化为 `\.agents\skills\backups`，备份失败，进而**加重回滚风险**。

**安全门的文档与实现必须完全一致。**
原包宣称 5 层门（`Version Check → Backup Gate → Download Gate → Frontmatter Gate → Danger Pattern Gate`），实际实现的是 **6 个命名完全不同的检查**：
```
1. SKILL.md 存在且可读   2. Publisher 校验    3. License 校验
4. Slug 校验             5. 危险模式扫描      6. 文件数 ≥ 阈值
```
宣称的 **Download Gate 与 Frontmatter Gate 完全未实现**。这是**对外作出的虚假安全承诺**。
→ **实现什么就写什么，一个名字都不要多写。** 文件数阈值按档位设定（XS ≥13 / S ≥17 / M ≥25 / L ≥140 / G ≥238）。

**更新命令的文档写法**：一律用占位符
```powershell
pwsh -File "{SKILL_DIR}/scripts/auto-update.ps1"
```
⚠️ 禁止硬编码绝对用户路径。原包 README 写的是 `C:\Users\Admin\WorkBuddy\Claw\.workbuddy\scripts\ai-company-auto-update.ps1`——**该文件不存在**（真名 `auto-update.ps1`），路径属于另一台机器，且与它自己 SKILL.md 里的正确写法自相矛盾。

### 5.10 测试文件

必须包含**三类**断言：

**A. 行为测试**（每个模板至少 1 条，覆盖正常路径 + 边界）
```
validate_input_schema      : 合法输入通过 / 非法输入拒绝
sanitize_user_query        : 普通查询不变 / 含 shell 元字符被净化
execute_safe_command       : 超时生效 / cwd 受限
format_output_json         : 含 AIGC 标签与时间戳
retry_with_backoff         : 首次失败后重试成功 / 达上限后抛出
read_reference_file        : 允许路径可读 / 越界路径拒绝
generate_trace_id          : 默认前缀 / 自定义前缀 / 唯一性
check_rate_limit           : 窗口内通过 / 超限拒绝
mask_sensitive_data        : email / IP / phone 三类均脱敏  ← 三类都要断言
build_prompt_from_template : 模板填充 / 输入被净化
```

**B. ⚠️ 源文件完整性测试（关键，原包缺失）**
```python
def test_templates_source_exists(self):
    """断言权威模板文件存在且含全部 10 个函数定义"""
    src = SKILL_DIR / "references" / "templates.md"
    self.assertTrue(src.exists(), f"模板权威源缺失: {src}")
    content = src.read_text(encoding="utf-8")
    for fn in TEN_TEMPLATE_NAMES:
        self.assertIn(f"def {fn}", content, f"模板 {fn} 在权威源中缺失")

def test_phone_masking_in_source(self):
    """断言权威源含 PHONE 实现——防止契约/代码/测试三者脱节"""
    content = (SKILL_DIR / "references" / "templates.md").read_text(encoding="utf-8")
    self.assertIn("[PHONE]", content, "权威源缺失 PHONE 脱敏实现")
```

**C. ⚠️ 结构一致性测试（合并档位必加）**
```python
def test_function_block_conservation(self):
    """断言职能块总数守恒：XS/S/M/L=18，G=36"""
    # 遍历 references/departments/*.md，统计每页的职能块小节数
    # 与 metadata.function_block_count 比对
    EXPECT = {"micro":18, "small":18, "medium":18, "large":18, "group":36}
    self.assertEqual(total_blocks, EXPECT[tier], "合并档位丢失职能")

def test_department_index_matches_disk(self):
    """仅 L/G 档：断言索引列出的部门与磁盘目录一一对应"""
    # 双向校验：索引有而磁盘无 = 断链；磁盘有而索引无 = 孤儿
```

**为什么 B/C 类必不可少**：原包测试把 10 个模板实现**内联复制进测试文件**（`import` 只有 `unittest/json/time/re/datetime/collections`，从不读任何 `.md`），却宣称 "Tests all 10 method patterns defined in references/method-patterns.md"。后果是——**源文件被篡改或删除，测试仍 19/19 全绿**。
本文前一版的 S3 缺陷（PHONE 缺失）正是该问题的直接产物：测试内联的实现有 PHONE，权威源没有，测试永远发现不了。

**附带**：用 `datetime.now(timezone.utc)` 而非 `datetime.utcnow()`（后者已弃用，原包测试运行时有 `DeprecationWarning`）。

### 5.11 `.gitignore`（必生成）

```
# ── 本地审查/审核报告（工作产物，不进分发包）──
REVIEW-*.md
AUDIT-*.md

# ── Python 编译产物 ──
__pycache__/
*.pyc
*.pyo

# ── 运行时产物 ──
.logs/
.update-notification.md
*.bak

# ── 安装器本机元数据 ──
.clawhub/
```

**每条的理由**：
- `REVIEW-*.md` / `AUDIT-*.md`：审查报告是**工作产物**，记录的是本包特定版本的缺陷，随代码演进即过期，不应进分发包
- `__pycache__/` / `*.pyc`：原包缺失 `.gitignore`，且 `adapter_interface.cpython-314.pyc` **已被 git 追踪**——`.pyc` 与 CPython 版本强绑定，无价值且造成 diff 噪音，还可能携带过期字节码
- `.clawhub/`：安装器写入的本机安装元数据（registry / slug / installedVersion / installedAt），属机器本地状态

⚠️ **`.gitignore` 不会自动取消已追踪文件**。若 `.pyc` 或 `.clawhub/` 已入库，须额外执行 `git rm --cached <path>`——该操作修改 git 索引，**需人工确认后执行**。

---

## 6. 生成顺序

| Step | 产出 | 依赖 | 关键约束 |
|---|---|---|---|
| **0** | ⛔ **向人工询问档位（5 选 1）** | — | 见第 1 节。未获答复前不得生成任何文件 |
| **1** | 从 2.6 合并树**锁定该档位的部门清单、前缀、职能块数** | Step 0 | 严格照 2.6 对应表格，不得自创部门 |
| **2** | 目录树 + `_meta.json` + `LICENSE` + `.gitignore` | Step 1 | 先建全部空目录，避免后续写入失败 |
| **3** | 根 `SKILL.md` | Step 1 | frontmatter 按 2.2 逐字段核算；`errors: []`；L/G 档不内联 department 枚举 |
| **4** | `references/error-codes.md` | Step 1, 3 | 条数按 2.1；编号连续无空洞；每条含四要素 |
| **5** | `references/templates.md` | Step 2 | ★ 10 模板完整代码，**含 PHONE 分支**，唯一权威位置 |
| **6** | `references/method-patterns.md`（索引表 + 3 框架） | Step 5 | **只放索引表**，代码指向 `templates.md` |
| **7** | `references/department-index.md` | Step 1 | **仅 L/G 档**。7 域→部门全表 + 路由算法 |
| **8** | `references/` 共享模块 | Step 6 | XS/S 跳过；M 档 execution+memory；L/G 全量 + 4 个子目录 |
| **9** | 各部门 D2 `<slug>.md` | Step 4, 7, 8 | 骨架统一（5.5）；**职能块数按 2.6.1**；章节从 1 开始不跳号 |
| **10** | 各部门 D3 子目录 | Step 9 | **仅 L/G 档**。文件名 `department-spec.md`，不含 `name`/`triggers` |
| **11** | `sentiment-analysis/engines/` D4 | Step 10 | **仅 G 档**。5 引擎 + 3 专用 prompts |
| **12** | `prompts/` | Step 9 | 正文写**实际部门数**，不写继承来的数字（见 P4） |
| **13** | `models/` + `scripts/` + `tests/` | Step 5 | registry 路径全通；只 1 个适配器；测试含 B/C 类断言 |
| **14** | `README.md` + `CHANGELOG.md` + `CONTRIBUTING.md` | 全部 | 结构树与磁盘一致；版本号全局单一值 |

**Step 9→10 的顺序理由**：D2 先写是因为它要引用 D3 路径；但 D2 里的链接目标必须在 D3 写完后**回头逐个校验存在**，避免断链。

---

## 7. 内容撰写指引

本文给你结构与规格，**具体职责正文需你撰写**。以下是质量标准。

### 7.1 每部门 D2 必含内容

| 章节 | 要求 |
|---|---|
| **1. Trigger Scenarios** | 5–10 条**具体任务描述**，自然语言（`Review the Q2 budget and assess risk exposure`），**不要关键词堆砌** |
| **2. Core Identity** | 角色定位、权限边界（什么能做/什么必须上报）、汇报关系、所属域 |
| **3. Core Responsibilities** | 每个 `#### 3.x` 含【职责描述 + 输入 + 输出 + SLA】**四要素**，缺一不可 |
| **4. Error Codes** | 该前缀全部错误码 + **每条附 Resolution Steps** |
| **5. Integration Points** | 与哪些部门协作、通过什么机制（HQ Message Bus / MCP / Webhook / 直接调用） |
| **6. Constraints** | 禁止事项，❌ 列表 |
| **7. Quality Metrics** | **可量化指标 + 数值阈值**（如「测试覆盖率 ≥85%」「OHS ≥70」「DSO ≤45 天」「RTO ≤15 分钟」） |

### 7.2 语言与风格

- 正文用**英文**（技能规范的通用做法，也便于跨语言 Agent 消费）
- 中英混排仅用于既有术语注释（如 `Headquarters-Branch Architecture (总分公司模式)`）
- **表格优先于长段落**
- 每条规范给出**可验证的数值阈值**，避免「应该」「尽量」「适当」等无法判定的表述
- 篇幅按 2.1 区间控制。**同档位内各部门篇幅应大致均衡**——原包部门篇幅最大 6083 词、最小 849 词，相差 **7.2 倍**，一个部门极详、另一个只有骨架，会导致路由后体验断裂
- **合并档位（XS/S/M）靠职能块数量承载规模，不靠注水**：XS 档单部门 1200–2000 词写 8–10 个职能块，每块约 150–200 词即可，**宁可精炼不要注水**
- G 档 36 个部门总篇幅可观，但同样**不得靠稀释内容凑数**

### 7.3 可复用的既有框架（不要另创）

**5 种记忆类型**（M+ 档启用）
| 类型 | 范围 | 易变性 | 归属（G 档部门） | 保留期 |
|---|---|---|---|---|
| Profile | 单 Agent | 低 | `agent-lifecycle` | Agent 生命周期 |
| Session | 单会话 | 高 | `hq-coordination` | 会话期间 |
| Knowledge | 全组织 | 低 | `quality-assurance` | 直到被取代 |
| Learning | 单 Agent + 共享 | 中 | `engineering-architecture` + `knowledge-management` | 直到被证伪 |
| Preference | 单用户 + 共享 | 低 | 用户 | 直到变更 |

原则：**consolidation over accumulation**（定期蒸馏合并防膨胀，而非无限累积）。

**执行引擎 4 模式 × 4 触发器**
- 模式：`Auto`（低风险全自动）/ `Approve`（有外部影响，事前授权）/ `Review`（质量敏感，事后门）/ `Hybrid`（分阶段混用）
- 触发器：`Schedule`（cron）/ `Event`（消息总线）/ `Webhook`（HMAC-SHA256 验签）/ `Manual`（带审计）
- 错误恢复三层：操作级指数退避 → 事务级回滚 → 服务级熔断（`CLOSED → OPEN → HALF_OPEN`）
- 档位裁剪：XS 仅 `Manual` + `Schedule`；S 加 `Event`；M+ 全量

**三条集成通路**（L+ 档启用）：MCP Servers / Webhooks（HMAC-SHA256）/ REST API Bridge
共同原则：**zero secrets in code**、**idempotent operations**、**audit-by-default**

**总分公司架构**（仅 G 档，归属 `branch-management`）
- 3 层：L1-HQ 总公司 / L2-Branch 分公司 / L3-Local Agent 本地代理
- 4 种分支类型：Regional（区域）/ Departmental（部门）/ Functional（职能）/ Hybrid（混合）
- 8 阶段生命周期：PROPOSE → EVALUATE → APPROVE → CREATE → PILOT → PROMOTE → MONITOR → RETIRE
- 5 阶段 CEO 门控上线：PROPOSE → PILOT → STAGED → FULL → DELEGATE
- 自动回滚触发：错误率 >5% / SLA 违约 / 安全事件 / OHS <70

**远程通信架构**（仅 G 档，归属 `branch-management` + `identity-access`）
- 拓扑：Hub-Spoke / Full Mesh / Hybrid / CDN-Assisted
- 协议：gRPC (HTTP/2) / WebSocket / MQ (Kafka/Pulsar) / HTTP-REST / QUIC (HTTP/3)
- 安全：mTLS 双向认证
- 数据同步：Synchronous (2PC) / Asynchronous (Eventually consistent) / Hybrid (Quorum)

**跨境合规**（L 档简版仅 GDPR；G 档全量，归属 `privacy-data-protection`）
GDPR (SCC) / PIPL (CAC 审批) / CCPA / 数据驻留要求

**情感分析 5 引擎**（仅 G 档，`sentiment-analysis` 部门的 **D4 子单元**，共用 `SNT_` 前缀）
```
QueryEngine → MediaEngine → InsightEngine → ReportEngine → ForumEngine
```
⚠️ **引擎不是部门**：不得出现在 `department-index.md` 的部门列，也不得进 frontmatter 的 `department` 枚举。

**情报循环**（`competitive-intelligence` 部门）：6 阶段 collection → processing → analysis → production → dissemination → feedback；情报库 SOP-L01~L06；SITREP 自动生成；来源可靠性评分。

---

## 8. 禁止事项（红线清单）

### 结构与命名
| # | 禁止 | 理由（实测后果） |
|---|---|---|
| **P1** | 在部门子目录放 `SKILL.md` | 原包 11 个子 SKILL.md 带独立 `name`/`triggers`，被加载器**误注册为 11 个独立技能**，与父技能 triggers 大面积冲突。G 档 36 个子目录会放大 3 倍 |
| **P2** | 子清单 `dependencies.skills` 填包内部门名或 legacy 技能名 | 依赖解析器找不到 → 安装失败；且与根 `dependencies: []` 自相矛盾 |
| **P3** | 各部门用不同章节骨架 | 原包 11 个部门有 **5 种互不兼容变体**，错误码表位置各不相同，无法程序化解析 |
| **P4** | 写下与实际部门数不符的数量宣称 | 原包 5 处宣称 "16 departments"（含**给 AI 的提示词正文**），实际只有 11 个——AI 会照此寻找 16 个文件，找不到就幻觉补全 |
| **P5** | 章节编号跳号 | 原包 11/11 部门 D2 都从 `## 3.` 起跳，缺 Trigger Scenarios 与 Core Identity，Agent 被迫下沉 D3 |
| **P6** | 合并档位丢失被合并职能的职能块 | 原包 CISO 段缺错误码表，但 frontmatter 定义了 CISO_001~005，D2 与清单脱节。**用 2.6.1 职能块守恒（=18）自检** |
| **P7** | 把 D4 引擎列为部门 | 原包把 Sentiment Analysis Team 列进 Department Index 当第 12 个部门，与 `department` 枚举的 11 个 slug 不符 |
| **P8** | 留下孤儿文件 | 原包 22 个部门 prompts 文件**无任何文档引用**，仅靠目录约定被发现，实际不可达 |
| **P9** | 同一模块留两份命名相近的文件 | 原包 `adapter-interface.py` 与 `adapter_interface.py` 内容不同，连字符版**无法被 import** |
| **P10** | 共享代码存两份 | 原包 10 个模板同时存在于两个 Platform 文件（847 行 vs 959 行，哈希不同），索引只用一句模糊话指向，无法判断权威源 |
| **P27** | 部门 slug 不符 5.5.1 命名规范 | 36 个部门若不定规则，会产出 `info-services` 与 `information-services` 并存的不一致命名 |
| **P28** | 破坏 2.6 合并树的严格包含关系 | 若 M 档某部门不是 L 档部门的并集，跨档迁移时职能会丢失或重叠 |
| **P29** | 占用 WFT-001~099 区间放扩展工作流 | 核心集编号固定，扩展须走 `WFT-1xx`，否则升级档位时编号冲突 |
| **P33** | 合并档位只写部门级章节、省略职能块 | XS 档 2 部门须承载 18 个职能块；若只写 2 套 3–7 节，等于丢掉 16 个部门的职能 |

### 版本与元数据
| # | 禁止 | 理由 |
|---|---|---|
| **P11** | 版本号在多处各写各的 | 原包 5 处版本号有 2 个值（`1.0.6` ×3、`1.0.7` ×2），另有安装元数据第 6 处佐证 |
| **P12** | Changelog 同一版本号出现两次或日期倒挂 | 原包 `[1.0.6]` 出现两次配两个日期；`1.1.0` 的日期早于 `1.0.6` |
| **P13** | 路线图宣称的版本在 Changelog 中无条目 | 原包 `v1.0.7` 在 CHANGELOG 中完全不存在 |
| **P14** | 错误码编号留空洞 | 原包 `CTO_007`/`CTO_008` 缺失，维护者无法判断是废弃还是漏写 |
| **P15** | `name` 字段用 YAML 块标量（`\|` 或 `>`） | 增加转义风险；用单行引号字符串 |
| **P16** | `description` 超 1024 字符 | SkillImport 硬校验上限，超出直接安装失败 |
| **P17** | 错误码全表内联 frontmatter | 原包 134 条占 frontmatter 269 行（64%），D1 层超标 3.5 倍，每次加载全量吞入 |
| **P30** | L/G 档把 `department` 枚举内联 frontmatter | 18/36 项会击穿 2.2 行预算（L 达 154、G 达 189），必须外置到 `department-index.md` |
| **P31** | `scale_tier` / `department_count` / `function_block_count` 缺失或互相矛盾 | 档位是本包核心决策，须留痕且与实际部门数、职能块数一致 |

### 安全
| # | 禁止 | 理由 |
|---|---|---|
| **P18** | 硬编码绝对用户路径 | 原包 README 的更新命令写死 `C:\Users\Admin\WorkBuddy\Claw\...`，在任何其他机器必然失败 |
| **P19** | 引用不存在的脚本/文件路径 | 原包 README 指向 `ai-company-auto-update.ps1`，真实文件名是 `auto-update.ps1` |
| **P20** | 写任何真实或"示例"密钥 | 一律只写环境变量名。原包此项合规（全部走 `env_var_name`），保持 |
| **P21** | 扩大 `permissions.files.write` 到 `{SKILL_DIR}` | 技能目录必须只读 |
| **P22** | 删减 `permissions.files.deny` 任何一项 | P0 级安全边界，微型档也不例外 |
| **P23** | 回滚逻辑先删后恢复 | 原包 `Remove-Item -Recurse -Force` 先执行，Copy 阶段失败即**永久丢失整个技能包** |
| **P24** | 安全门文档写未实现的门 | 原包宣称 5 门，实现 6 门且**命名 0 匹配**，其中 2 门完全未实现——虚假安全承诺 |
| **P25** | 使用 `Invoke-Expression` / `iex` / `DownloadString` | 远程下载执行是技能包恶意行为的首要特征 |
| **P26** | 平台适配只做一半 | 原包注释宣称支持 macOS，代码只用 `$env:USERPROFILE`，非 Windows 下备份目录失效 |
| **P32** | 契约声明与代码实现不一致 | 原包 `mask_sensitive_data` 契约要求 `[PHONE]`、代码只实现 EMAIL/IP、测试用内联副本蒙混过关——照抄即测试失败（见 4.2） |

### 工程卫生
- ❌ 提交 `__pycache__/` 或任何 `.pyc`（原包 `.pyc` 已被 git 追踪）
- ❌ 缺 `.gitignore`
- ❌ 提交安装器产物（`.clawhub/origin.json` 这类本机安装元数据）
- ❌ 提交本地审查/审核报告（属工作产物，随版本演进即过期）
- ❌ 测试自包含副本而不校验真实源文件（原包测试 19/19 全绿但源文件可被任意篡改）
- ❌ README 的 "Project Structure" 与磁盘实际不符（原包结构树漏掉 **13 类**真实存在的文件：`models/`、`scripts/`、`tests/`、`CHANGELOG.md`、`CONTRIBUTING.md`、`references/viz|exec|mem|data`、各部门子目录等）
- ❌ 模板配置文件字段少于实际配置文件（原包模板缺 `context_window`、`max_output_tokens`、`pii_filtering`）
- ❌ 文档宣称存在的文件实际不存在（原包 `models/README.md` 宣称 3 个 `.js` 适配器，**均不存在**）

---

## 9. 验收清单

生成完成后逐条执行。**按档位选择对应的期望值**。

### 9.1 通用验收（所有档位）

| # | 检查 | 期望 |
|---|---|---|
| 1 | `python tests/test-method-patterns.py` | `OK` / **exit 0** |
| 2 | 测试含 B 类源文件断言 | `Select-String tests\*.py -Pattern 'templates.md'` **有命中** |
| 3 | 测试含 PHONE 源文件断言 | `Select-String tests\*.py -Pattern '\[PHONE\]'` **有命中**（防 S3 复发） |
| 4 | `templates.md` 含 PHONE 实现 | `Select-String references\templates.md -Pattern '\[PHONE\]'` **有命中** |
| 5 | `python -m py_compile models/adapters/adapter_interface.py`（若有 models） | exit 0 |
| 6 | 根 `SKILL.md` frontmatter 可 YAML 解析 | 无解析错误 |
| 7 | `Select-String -Path SKILL.md -Pattern '^---$'` | 命中 **2 处** |
| 8 | frontmatter 行数 | ≤ 档位预算（XS:75 / S:85 / M:105 / L:140 / G:160） |
| 9 | `description` 字符数 | ≤ **1024** |
| 10 | `errors:` 字段 | 为 `[]`（全表在 `references/error-codes.md`） |
| 11 | `scale_tier` / `department_count` / `function_block_count` 三者自洽 | 见 2.1 + 2.6.1 |
| 12 | 版本号一致性 | `_meta.json` / README badge / SKILL frontmatter / SKILL 正文标题 **全部同值** |
| 13 | `permissions.files.deny` | 5 项齐全，无删减 |
| 14 | 硬编码路径扫描 `Select-String -Recurse -Pattern 'C:\\Users\\'` | **0 命中** |
| 15 | 危险模式扫描 `Invoke-Expression\|iex \|DownloadString\|eval(\|exec(` | **0 命中** |
| 16 | 密钥扫描 `sk-[A-Za-z0-9]{20}\|Bearer [A-Za-z0-9]` | **0 命中** |
| 17 | `__pycache__` / `.pyc` | **不存在** |
| 18 | `.gitignore` | **存在**且含 `__pycache__/` 与 `REVIEW-*.md` |
| 19 | 孤儿文件 | 所有 `prompts/*.md` 被至少一个上层文档引用 |
| 20 | 断链 | 所有 `.md` 中的相对链接目标**真实存在** |
| 21 | README 结构树 vs 磁盘 | **完全一致** |
| 22 | 文件总数 | 等于 2.3 推导值（13 / 17–19 / 25–34 / 140 / 238） |
| 23 | 职能块守恒 | XS/S/M/L = **18**，G = **36** |

### 9.2 档位专属验收

| 档位 | 检查 | 期望 |
|---|---|---|
| **全部** | `references/templates.md` 含 10 个 `def <fn>` | **10/10** |
| **全部** | 部门 D2 章节骨架变体数 | **1 种**（不得有变体） |
| **全部** | 部门 D2 含 `## 1. Trigger Scenarios` 与 `## 2. Core Identity` | **全部部门命中** |
| **全部** | 部门数 | 等于档位值（2 / 5 / 9 / 18 / 36） |
| **全部** | 部门 slug 来自 2.5/2.6 表格且符合 5.5.1 规范 | **0 自创、0 违规** |
| **全部** | 错误码编号连续性 | 每个前缀内 `001..NNN` **无空洞** |
| **全部** | 错误码含 Resolution Steps | **每条都有** |
| **全部** | 错误码前缀数 | 等于档位部门数（2 / 5 / 9 / 18 / 36） |
| **XS/S/M** | `references/departments/*/SKILL.md` | **0 个**（扁平档无 D3） |
| **XS/S/M** | frontmatter 无 `domains` / `department_index` 字段 | **0 命中** |
| **XS/S/M** | `department` 枚举内联 | **有**，项数 = 部门数 + 1（含 auto） |
| **L/G** | `references/departments/*/SKILL.md` | **0 个**（必须叫 `department-spec.md`） |
| **L/G** | `references/departments/*/department-spec.md` | = 部门数（18 或 36） |
| **L/G** | 子清单含 `name:` 字段 | **0 命中** |
| **L/G** | `references/department-index.md` 存在 | **是** |
| **L/G** | frontmatter 未内联 `department` 枚举 | **0 命中**（须外置） |
| **L/G** | 域数 | **7**，且各域部门数合计 = 部门总数 |
| **L/G** | `models-registry.json` 路径遍历 | **全部 EXISTS=True** |
| **L/G** | `models/adapters/*.py` 文件数 | **1** |
| **G** | `sentiment-analysis/engines/` 引擎文件 | **5 个** |
| **G** | 5 引擎出现在部门列或 `department` 枚举 | **0 命中**（须为 D4 子单元） |
| **G** | 总分公司 / 远程通信 / 跨境合规规范 | 三套均存在 |
| **G** | WFT 扩展集编号 | 均在 `WFT-1xx` 区间，**未占用 001–099** |

**部门数 / 前缀数 / 档位一致性校验脚本**：
```powershell
$expect = @{ micro=2; small=5; medium=9; large=18; group=36 }
$tier = (Select-String -Path SKILL.md -Pattern 'scale_tier:\s*(\w+)').Matches[0].Groups[1].Value
$n = (Get-ChildItem references\departments\*.md).Count
$declared = [int](Select-String -Path SKILL.md -Pattern 'department_count:\s*(\d+)').Matches[0].Groups[1].Value
Write-Output "tier=$tier expected=$($expect[$tier]) onDisk=$n declared=$declared"
Write-Output "MATCH=$(($n -eq $expect[$tier]) -and ($declared -eq $n))"
```

**职能块守恒校验脚本**（防 P6/P33）：
```powershell
$blocks = 0
Get-ChildItem references\departments\*.md | ForEach-Object {
  $c = (Select-String -Path $_.FullName -Pattern '^## <FUNCTION BLOCK|^## .*\(v\d' -AllMatches).Count
  # 按实际职能块标题模式调整上方正则
  $blocks += $c
}
Write-Output "function blocks total = $blocks (expect 18, or 36 for group tier)"
```

**registry 路径校验脚本**：
```powershell
$j = Get-Content models\config\models-registry.json -Raw | ConvertFrom-Json
$ok = 0
foreach ($m in $j.models) {
  $e = Test-Path (Join-Path 'models' $m.config_path)
  if ($e) { $ok++ } else { Write-Output "❌ BROKEN: $($m.config_path)" }
}
Write-Output "PASS=$ok/$($j.models.Count)"
```

**断链扫描脚本**：
```powershell
Get-ChildItem -Recurse -Filter *.md | ForEach-Object {
  $dir = $_.DirectoryName
  Select-String -Path $_.FullName -Pattern '\]\(([^)#]+?\.md)' -AllMatches | ForEach-Object {
    foreach ($m in $_.Matches) {
      $t = Join-Path $dir $m.Groups[1].Value
      if (-not (Test-Path $t)) { Write-Output "❌ $($_.Path) -> $($m.Groups[1].Value)" }
    }
  }
}
```

**frontmatter 行预算检查**：
```powershell
$l = Get-Content SKILL.md
$close = ($l | Select-String '^---$' | Select-Object -Skip 1 -First 1).LineNumber
Write-Output "frontmatter lines = $($close - 1)"
```

---

## 10. 缺陷溯源

本文红线来自两份实测报告：

| 报告 | 路径 | 对象 | 缺陷数 |
|---|---|---|---|
| 源包审核 | `.git/AUDIT-REPORT-ai-company.md` | 既有同类技能包（116 文件） | 26 项（5 严重 S1–S5 / 10 中等 M1–M10 / 8 轻微 L1–L8 / 3 结构歧义 5.1–5.3） |
| 本文审查 | `REVIEW-README-FOR-AI.md`（已 gitignore） | 本文前一版（950 行 4 档版） | 17 项（5 严重 S1–S5 / 7 中等 M1–M7 / 5 轻微 L1–L5） |

**审查报告 → 本文的对应关系**：

| 审查编号 | 问题 | 本文修复位置 |
|---|---|---|
| S1 | 4 档不满足 5 档需求 | 第 1、2 节整体重构 |
| S2 | 部门数硬编码 `11`，无支撑 18/36 的分类体系 | 2.4–2.6（7 域 + 36 原子部门 + 合并树） |
| S3 | ⚠️ `mask_sensitive_data` 缺 PHONE，照抄即测试失败 | 4.2（补齐实现）+ 5.10 B 类断言 + 9.1 #3 #4 + P32 |
| S4 | G 档 frontmatter 必然超标，缺两级路由 | 2.2（逐字段预算）+ 4.6（域→部门路由）+ P30 |
| S5 | triggers 与部门数 1:1 绑定在 36 部门下失效 | 5.4（解耦，L/G 档按域分组） |
| M1 | 假警报计数自相矛盾（称 12 列 8） | 本节改为双报告索引 + 补齐 12 项 |
| M2 | `scale_tier` 缺微型档 | 5.2（5 值枚举）+ P31 |
| M3 | "四档"表述散落 | 全文改五档 |
| M4 | 验收缺微型档标签 | 9.2（XS/S/M 组） |
| M5 | WFT 仅 9 个且禁止扩展 | 2.8（核心集 + `WFT-1xx` 扩展集）+ P29 |
| M6 | 情感分析定位与 36 部门体系冲突 | 2.5 #32（升格为原子部门 `SNT_`）+ 3.5 / 7.3（5 引擎降为 D4） |
| M7 | 中型档用增量表述易算错 | 第 3 节全部改完整树 |
| L1 | WFT 表行序错乱 | 2.8 按 ID 升序 |
| L2 | 未定义 slug 命名规范 | 5.5.1 + P27 |
| L3 | `.gitignore` 未含审查报告 | 5.11（`REVIEW-*.md` / `AUDIT-*.md`） |
| L4 | 部门数硬编码 + 两套 L 编号同名歧义 | 术语约定节（D1–D4 vs L1–L6）+ 4.4 显式标注 |
| L5 | "约 7 倍"等数字需重算 | 1.3（约 18 倍，13→238） |

**新增红线**（审查与本次重构中新识别，原 26 条之外）：
P27（slug 命名规范）、P28（合并树包含关系）、P29（WFT 编号区间）、P30（枚举外置）、P31（档位元数据留痕）、P32（契约与实现一致）、P33（合并档位职能块不得省略）。

**已排除的假警报**（12 项，不要"修复"这些不存在的问题）：
| 疑似 | 实测结论 |
|---|---|
| `.md` 中文编码损坏（`锛?`） | 假象。全量 93 个 md 扫描无命中，是 PowerShell `Compare-Object` 的输出渲染问题 |
| `.bat` 文件编码损坏 | 假象。`✓`/`✗` 为有效 UTF-8，仅 cmd 代码页显示问题 |
| 硬编码 API key | 未发现。全部走环境变量；`"api_key": "ollama"` 是本地服务占位值 |
| 远程下载执行（`iex`/`DownloadString`） | 未发现。更新通过官方 CLI 完成 |
| 访问 `~/.ssh` / `.env` | 未发现。`deny` 列表主动排除 |
| 部门模板是批量复制的冗余 | 非冗余。12 个 `method-patterns.md` 哈希各不相同，确有差异化内容 |
| 适配器 Python 语法错误 | 无。两个 `.py` 均 `py_compile` exit 0 |
| `auto-update.ps1` 语法错误 | 无。685 行符合 PowerShell 5.1+ 语法 |
| `description` 超 1024 上限 | 未超。原包实测 718 字符 |
| `name` 用块标量导致解析失败 | 未用。原包为单行标量 |
| D2 正文超 5000 词预算 | 未超。原包实测约 1800 词 |
| `test_ollama.bat` 的 `✓`/`✗` 需替换 | 非必须。文件本身编码正确，仅显示层问题 |

---

## 11. 一页速查

```
Step 0  ⛔ 问人工：微型 / 小型 / 中型 / 大型 / 集团公司？
          └ 无答复 → 默认小型，声明假设

Step 1  查 2.6 合并树 → 锁定部门清单、前缀、职能块数（照抄，不得自创）
Step 2  查 2.1 + 2.2 → 锁定规模参数与 frontmatter 行预算
Step 3  查第 3 节 → 建对应档位的完整目录树
Step 4  查第 4 节 → 照抄不变量（权限块 / 10 模板含 PHONE / 3 框架 / Harness L1-L6 / 两级路由）
Step 5  查第 5 节 → 按骨架生成各文件（注意 5.5.1 slug 命名规范）
Step 6  查 2.3 → 核算文件总数，对齐目标值
Step 7  查第 7 节 → 撰写职能块正文（数值阈值，不写模糊表述，合并不丢职能）
Step 8  查第 8 节 → 逐条自查 33 条红线
Step 9  查第 9 节 → 跑通用 23 条 + 档位专属验收
```

**五条档位速记**：
| | XS 微型 | S 小型 | M 中型 | L 大型 | G 集团 |
|---|---|---|---|---|---|
| 部门 | 2 | 5 | 9 | 18 | 36 |
| 职能块 | 18 | 18 | 18 | 18 | 36 |
| 文件 | 13 | 17–19 | 25–34 | 140 | 238 |
| 层级 | D1+D2 | D1+D2 | D1+D2 | +D3 | +D4 |
| 分域 | 否 | 否 | 否 | **是（7 域）** | **是（7 域）** |

**五条最容易犯的错**（若只记五件事）：
1. **共享代码只放一处** —— `references/templates.md`，其他文件只链接不内联（P10）
2. **`mask_sensitive_data` 必须含 PHONE 分支** —— 否则测试必然失败（P32）
3. **部门子目录不叫 `SKILL.md`** —— 否则被加载器误注册为独立技能（P1）
4. **合并档位职能块总数必须 = 18** —— 否则说明合并时丢了职能（P6/P33）
5. **L/G 档部门枚举外置** —— 内联 18/36 项会击穿 frontmatter 行预算（P30）

---

*本指南为生成规格，GPL-3.0 许可。*
