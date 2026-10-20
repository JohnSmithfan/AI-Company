# AI Company — Large Tier

[![Version](https://img.shields.io/badge/version-4.0.0-blue)](CHANGELOG.md)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Scale tier](https://img.shields.io/badge/scale_tier-large-teal)](references/scaling.md)

> 统一的 AI 公司治理技能。**7 个领域下的 18 个部门**、117 个错误码、
> 10 个共享代码模板、由人工批准的自扩展。
> 版本 **4.0.0** · 规模档位 `large` · 许可证 GPL-3.0

[English](README.md) | 简体中文

> `README.en.md` 是 `README.md` 的同内容英文副本，保留它是为了让 `.en` /
> `.zh` 语言后缀保持对称，便于 i18n 工具识别。

| | |
|---|---|
| 版本 | **4.0.0**（major 4 = `large` 档位序数） |
| 规模档位 | `large` —— 50–200 个 Agent，多条产品线 |
| 部门数 | **18**，归入 **7 个领域** |
| 职能块 | **18** |
| 错误码 | **117** 个，19 个前缀（18 个部门前缀 + `SCL_`） |
| 文件数 | **148** |
| 披露层级 | D1 frontmatter → D2 部门页 → D3 部门子目录 |
| 自扩展 | ✅ 仅提议；可提议升级到 `group`（36 个部门） |

## 目录

- [包的作用](#包的作用)
- [部门索引](#部门索引)
- [项目结构（Project Structure）](#项目结构project-structure)
- [安装](#安装)
- [验证](#验证)
- [使用](#使用)
- [自扩展（仅提议）](#自扩展仅提议)
- [约束](#约束)
- [质量指标](#质量指标)
- [设计说明](#设计说明)
- [许可证](#许可证)
- [更新日志](#更新日志)

## 包的作用

它把一个全员 AI 员工的技术公司建模为一份治理规范。进入的任务先与触发器匹配，经过
**领域 → 部门** 两级查找路由，然后由该部门的规范作答：职责与 SLA、带解决步骤的
错误码、约束条件以及可量化的质量指标。

每个部门都共用同一套 10 个经过审计的 Python 模板，其实现只存在于一个地方 ——
[references/method-patterns.md](references/method-patterns.md) §3。

## 部门索引

| 领域 | 部门 | 前缀 |
|---|---|---|
| `governance` 治理与战略 | executive-strategy · operations-coordination · board-and-branch | CEO_ COO_ BRD_ |
| `finance` 财务与风险 | finance-treasury · risk-audit · procurement-billing | CFO_ CRO_ PRC_ |
| `technology` 技术与工程 | engineering-tooling · platform-mlops · model-data | CTO_ FW_ MDL_ |
| `security` 安全与合规 | security-resilience · legal-privacy · incident-identity | CISO_ CLO_ IRP_ |
| `people` 人与文化 | lifecycle-training · knowledge-ethics | CHO_ KNM_ |
| `growth` 增长与情报 | marketing-partnerships · intelligence-sentiment | CMO_ INTEL_ |
| `delivery` 交付与质量 | quality-visualization · delivery-scheduling | CQO_ PMGR_ |

含角色、职能与逐部门链接的完整表格：
[references/department-index.md](references/department-index.md)

## 项目结构（Project Structure）

本结构树与磁盘上的包文件集一致，共 148 个文件。

```text
ai-company/
├── models/
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
│   ├── local/
│   │   ├── llama-3.3-70b/
│   │   │   └── config.json
│   │   └── template/
│   │       └── config.json
│   └── README.md
├── prompts/
│   ├── 01-implement-method.md
│   ├── 02-robustness-checks.md
│   ├── 03-test-cases.md
│   └── 04-documentation.md
├── references/
│   ├── data/
│   │   ├── financial-news.md
│   │   ├── information-fusion.md
│   │   └── schema-security.md
│   ├── departments/
│   │   ├── board-and-branch/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── delivery-scheduling/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── engineering-tooling/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── executive-strategy/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── finance-treasury/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── incident-identity/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── intelligence-sentiment/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── knowledge-ethics/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── legal-privacy/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── lifecycle-training/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── marketing-partnerships/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── model-data/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── operations-coordination/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── platform-mlops/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── procurement-billing/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── quality-visualization/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── risk-audit/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── security-resilience/
│   │   │   ├── prompts/
│   │   │   │   ├── 01-implement-method.md
│   │   │   │   └── 02-robustness-checks.md
│   │   │   ├── references/
│   │   │   │   └── method-patterns.md
│   │   │   └── department-spec.md
│   │   ├── board-and-branch.md
│   │   ├── delivery-scheduling.md
│   │   ├── engineering-tooling.md
│   │   ├── executive-strategy.md
│   │   ├── finance-treasury.md
│   │   ├── incident-identity.md
│   │   ├── intelligence-sentiment.md
│   │   ├── knowledge-ethics.md
│   │   ├── legal-privacy.md
│   │   ├── lifecycle-training.md
│   │   ├── marketing-partnerships.md
│   │   ├── model-data.md
│   │   ├── operations-coordination.md
│   │   ├── platform-mlops.md
│   │   ├── procurement-billing.md
│   │   ├── quality-visualization.md
│   │   ├── risk-audit.md
│   │   └── security-resilience.md
│   ├── exec/
│   │   ├── command-center.md
│   │   ├── error-recovery.md
│   │   ├── modes-triggers.md
│   │   └── workflows-schema.md
│   ├── mem/
│   │   ├── architecture.md
│   │   └── management-compliance.md
│   ├── viz/
│   │   ├── chart-types.md
│   │   ├── integration-compliance.md
│   │   ├── mermaid-diagrams.md
│   │   └── report-templates.md
│   ├── data-integration.md
│   ├── department-index.md
│   ├── error-codes.md
│   ├── execution.md
│   ├── integrations.md
│   ├── memory.md
│   ├── method-patterns.md
│   ├── scaling.md
│   └── visualization.md
├── scripts/
│   ├── scaling-config.json
│   └── self-scale.ps1
├── tests/
│   └── test-method-patterns.py
├── .editorconfig
├── .gitattributes
├── .gitignore
├── .scaling-state.json
├── AGENTS.md
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README.en.md
├── README.md
├── README.zh.md
├── README_FOR_AI.md
├── SECURITY.md
├── SKILL.md
└── _meta.json
```

## 安装

把本目录复制到你的技能文件夹。无需构建步骤；除测试套件所需的 Python 3.9+ 外无其他
依赖（`jsonschema` 为可选，缺失时可优雅降级）。

```powershell
# user-level
Copy-Item -Recurse ai-company "$env:USERPROFILE\.agents\skills\"

# project-level
Copy-Item -Recurse ai-company ".\your-project\.agents\skills\"
```

⚠️ 上面的路径是安装在用户自己机器上的示例。包内没有任何文件硬编码绝对用户路径 ——
包文件只使用 `{SKILL_DIR}` 和 `{WORKSPACE_ROOT}` 占位符。

## 验证

安装后运行以下命令，全部必须通过。

```powershell
cd <your skills folder>\ai-company

# 1. Test suite - must exit 0
$env:SKILL_DIR = (Get-Location).Path
python tests\test-method-patterns.py

# 2. Template code compiles
python -m py_compile models\adapters\adapter_interface.py

# 3. Model registry: all 7 config paths resolve
python models\adapters\adapter_interface.py     # expect "config paths ok : 7/7"

# 4. Self-scaling status
pwsh -File scripts\self-scale.ps1 -Action status

# 5. Upgrade threshold evaluation (read-only, writes nothing)
pwsh -File scripts\self-scale.ps1 -Action evaluate
```

## 使用

### 自动路由

技能在触发器匹配时自动激活并自行路由：

```text
task: "Review the Q2 budget and assess risk exposure"
  → triggers match (budget overrun review, risk assessment)
  → domain: finance
  → department: finance-treasury (CFO_)
  → answers from references/departments/finance-treasury.md
```

### 显式路由

```text
department: risk-audit
domain: security            # optional; narrows the search
task: "Run a STRIDE threat model on the authentication service"
```

### 示例任务

| 任务 | 领域 | 部门 |
|---|---|---|
| 审查 Q2 预算并评估风险敞口 | finance | `finance-treasury` |
| 对认证服务运行 STRIDE 威胁建模 | security | `security-resilience` |
| 按照 Harness L1–L6 约束创建新 Agent | technology | `platform-mlops` |
| 将营销文案翻译为日语并做文化适配 | delivery | `delivery-scheduling` |
| 评估本技能是否应成长到 group 档 | governance | `platform-mlops` + `board-and-branch` |

### 用 AI 再生本包

普通用户可跳过本节——安装目录即用。维护者与审计者可将
[README_FOR_AI.md](README_FOR_AI.md) 直接交给任一 LLM Agent：它是本包
（大型档，148 文件）的自包含生成规格，不依赖任何外部文档。Agent 按其中
§4 的 14 步工作流执行，生成物还须通过 §15 验收清单与测试套件，才算数是
本包。这是由人类指挥的 Agent 进行的仓库级重建，与技能运行期的 propose-only
自扩展无关，也不绕过人工批准。该规格锁定 `large` 档：再生其他档位需要对应
档位自己的规格。

## 自扩展（仅提议）

本包能够检测出自身已超出当前档位并**提议**升级，但绝不自行安装。

```text
① 提议（PROPOSE）   技能：评估阈值 → 从合并树推导升级路径 →
                    在 {WORKSPACE_ROOT}/.skill-upgrade/<时间戳>/ 构建完整升级包
                    ★ 只读取 {SKILL_DIR}；不向自身写入一个字节
② 批准（APPROVE）   人工：审查 UPGRADE-PROPOSAL.md、变更清单、diff 与各道门禁
③ 安装（INSTALL）   外部可信安装器：应用该升级包
```

| 设置 | 值 |
|---|---|
| 策略 | `propose-only` —— 不存在 `auto-install` 取值 |
| 升级路径 | `large` → `group`（部门 18 → 36，职能块 18 → 36） |
| 评估间隔 | 30 天，或按需 |
| 触发器 | T1 Agent 数 > 200 × 余量（宿主提供） · T2 部门职能块数 > 均值 × 1.5 · T3 路由准确率 < 85 % ×3 · T4 错误码复用率 > 25 % |
| 门禁 | G1 权限 · G2 测试 · G3 拒绝清单 + 门禁逻辑 · G4 守恒 · G5 别名 · G6 验收 |

⚠️ **G1–G3 不可豁免，人工批准也不例外。** 人工批准是业务规模变更的控制手段，不是安全
边界变更的控制手段。如果权限编辑可以被批准，一次提示词注入就只需要一次“同意”点击，
就能消解本包的全部约束。

⚠️ 提议**不会被执行**。在人工批准且外部安装器运行之前，本包保持 18 个部门不变。

完整规范：[references/scaling.md](references/scaling.md)

## 约束

- ❌ 永远不在 `{SKILL_DIR}` 内写入 —— 包目录只读，升级期间也不例外
- ❌ 永不修改 `permissions`、`deny` 清单、`tests/**` 或 `self-scale.ps1` 中的门禁逻辑
- ❌ 永远不在 `references/method-patterns.md` 之外内联共享模板代码
- ❌ 永不硬编码绝对用户路径 —— 使用 `{SKILL_DIR}` / `{WORKSPACE_ROOT}`
- ❌ 永不输出密钥值 —— 配置只保存环境变量**名称**
- ❌ 永不自动安装升级或自动执行降级
- ❌ 永不把数据缺口渲染为零，或把过期数据当作新鲜数据提供

## 质量指标

| 指标 | 阈值 | 验证方式 |
|---|---|---|
| 部门数 | 恰为 18 | 测试套件 + `department-index.md` |
| 职能块数 | 恰为 18 | `^## FB-\d+:` 计数 |
| 文件数 | 恰为 148 | 包文件集：排除 `.git/` `.github/` `.workbuddy/` `.skill-upgrade/` `__pycache__/` `*.pyc` |
| frontmatter 行数 | ≤ 150（实际 149） | 分隔符位置 |
| `description` 长度 | ≤ 1024 字符 | frontmatter 解析 |
| 错误码编号 | 每个前缀内无断档 | 正则扫描 |
| 断链 | 0 | 链接解析扫描 |
| 模型注册表路径 | 7/7 可解析 | 适配器自检 |
| 测试套件 | 退出码 0 | `python tests/test-method-patterns.py` |

## 设计说明

本包中有三个设计决策的存在，是因为前代包把它们做错了：

| 决策 | 它防止的缺陷 |
|---|---|
| 模板代码只存在于一个地方（`method-patterns.md` §3） | 前代包发布了两份分叉的副本，外加一行含糊到无法在两者间裁决的索引 |
| 脱敏覆盖 EMAIL、IP **和** PHONE | 前代包的权威源缺少 PHONE 分支，而其契约与测试都点名了它；套件却一直绿灯，因为它自带一份内联副本 |
| 子清单命名为 `department-spec.md`，绝不叫 `SKILL.md` | 前代包的 11 个子清单带有独立的 `name` 和 `triggers` 字段，任何递归加载器都会把它们注册为 11 个独立技能 |

## 许可证

GNU GPL v3 —— 见 [LICENSE](LICENSE)。

| | |
|---|---|
| 可自由使用、修改和分发 | ✅ |
| 衍生作品必须保持 GPL v3 | ✅（Copyleft） |
| 专利授予 | ✅（第 11 节） |
| 专有再许可衍生作品 | ❌ |

版权所有 © 2026 AI Company Team

## 更新日志

见 [CHANGELOG.md](CHANGELOG.md)。贡献规则 —— 如何添加部门、错误码或工作流 —— 见
[CONTRIBUTING.md](CONTRIBUTING.md)。
