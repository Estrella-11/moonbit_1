# MoonDocKit

[![CI](https://github.com/Estrella-11/moonbit_1/actions/workflows/ci.yml/badge.svg)](https://github.com/Estrella-11/moonbit_1/actions/workflows/ci.yml)
[![Showcase](https://github.com/Estrella-11/moonbit_1/actions/workflows/pages.yml/badge.svg)](https://estrella-11.github.io/moonbit_1/)

MoonDocKit 是一个 MoonBit 原生的文档站点工具包，面向 MoonBit 包作者。
它将包说明、指南和 API 接口文件转换为静态 HTML 文档站点，同时提供 11 个 AI
驱动的文档分析模块。

**在线 Playground** —— 渲染器直接跑在浏览器里，无需安装任何工具链：
<https://estrella-11.github.io/moonbit_1/playground/>

## 一览

| 指标 | 数值 |
|------|------|
| 实现语言 | 全量 MoonBit |
| 非测试 MoonBit 源码 | 6,243 行 / 19 个文件 |
| 测试 | 159 个全部通过（核心 66 + AI 89 + 文档示例 3 + 代理对回归 1） |
| 外部依赖 | 0（仅使用 MoonBit 标准库） |
| 公开 API | 核心 47 个函数 + AI 41 个函数 |
| CLI | 12 个选项 + 11 个标志（含 9 个 `--ai-*`） |
| 单次构建产物 | 13 个文件（8 个 HTML + 搜索索引 / sitemap / manifest / robots / 质量报告） |
| 站点发布门禁 | 质量分 100 / 100 |
| CI | 19 个步骤全部通过 |

每一项都可在本地复测，命令见 [`docs/capability-matrix.md`](docs/capability-matrix.md)。

## 核心功能

- Markdown 块级解析（H1-H3 标题、段落、列表、引用、代码块）
- 行内 Markdown 渲染（代码 span、强调、粗体、安全链接、自动链接、安全图片）
- 安全 HTML 转义和稳定锚点生成
- 多页面站点输出，含导航、目录和搜索
- `.mbti` 接口文件解析和 API 参考页面生成
- 质量评分门控和站点验证
- sitemap.xml 和 robots.txt 生成
- JSON 配置文件支持

## AI 增强文档套件

11 个 AI 模块提供全面的文档分析和生成能力：

| 模块 | 功能 | CLI 标志 |
|------|------|---------|
| `ai_doc_gen` | AI 文档生成（复杂度和使用频率分析） | `--ai-doc` |
| `ai_quality` | AI 质量评估（完整性/可读性/示例/结构评分 + 站点聚合） | `--ai-quality` |
| `ai_summary` | AI 内容摘要（关键词提取/内容类型/受众估计） | `--ai-summary` |
| `ai_xref` | AI 交叉引用检测（关键词重叠/孤立页面/枢纽页面） | `--ai-xref` |
| `ai_coverage` | AI 覆盖率分析（API 符号文档覆盖/按类型分组） | `--ai-coverage` |
| `ai_consistency` | AI 一致性检查（标题风格/层级/代码标签/重复/长度异常） | `--ai-consistency` |
| `ai_seo` | AI SEO 元数据（meta 描述/关键词密度/搜索增强评分） | `--ai-seo` |
| `ai_recommend` | AI 内容推荐（学习路径/下一步建议/相关页面） | `--ai-recommend` |
| `ai_test_gen` | AI 测试生成（从 API 符号生成测试桩） | `--ai-tests` |

### 组合 AI 构建

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --api pkg.generated.mbti \
  --output dist-ai-full \
  --ai-doc --ai-quality --ai-summary --ai-xref \
  --ai-coverage --ai-consistency --ai-seo --ai-recommend \
  --ai-tests \
  --title "MoonDocKit AI"
```

一次性生成 11 个 AI 输出文件。

## 安装

### 前置条件

安装 MoonBit 工具链：

```bash
# Linux / macOS
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

# Windows (PowerShell)
irm https://cli.moonbitlang.com/install/powershell.ps1 | iex
```

### 作为依赖使用

```bash
moon add Estrella-11/moondockit
```

### 从源码构建

```bash
git clone https://github.com/Estrella-11/moonbit_1.git
cd moonbit_1
moon check
moon test
```

## 从模板开始

`templates/quickstart/` 是一份可直接复制的起步包：三篇带 front matter 的页面、
一份 `moondockit.json` 配置，以及一个 GitHub Pages 工作流模板。

```bash
cp -r templates/quickstart my-docs
cd my-docs
moon run --target js cmd/moondockit --config moondockit.json --strict
```

构建产物写入 `dist/`，根目录自带 `index.html`，可直接部署到任意静态托管。
完整步骤见 `templates/quickstart/README.md`，完整采用路径见
`docs/adoption-playbook.md`。

## 快速开始

```bash
# 编译检查
moon check

# 运行测试（159 个测试）
moon test --target wasm-gc

# 构建示例站点
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-cli-example \
  --title "MoonDocKit 示例"
```

## 项目结构

```
moondockit-original/
├── ai/                    # 11 个 AI 模块（2,750 行）
├── cmd/moondockit/        # CLI 入口（590 行）
├── docs/                  # 30+ 文档文件
├── examples/              # 3 个可运行示例
├── tools/                 # 验证和基准测试工具
├── moondockit.mbt         # 核心库（2,475 行）
├── moondockit_test.mbt    # 核心测试（66 个）
├── pkg.generated.mbti     # 自动生成的接口文件
├── moon.mod               # 包配置
├── LICENSE                # Apache-2.0
└── CHANGELOG.md           # 变更日志
```

## 测试

```bash
# 运行全部 159 个测试
moon test --target wasm-gc

# AI 模块测试（89 个）
# 包含在 ai/ai_test.mbt 中，覆盖所有公开函数和边缘情况
```

## 文档示例即测试

MoonBit 工具链不会执行 Markdown 或 `///` 文档注释里的代码块，因此文档示例
可能在无人察觉的情况下失效。MoonDocKit 用自己的提取器补上这个缺口：

- 标记为 `mbt` 或 `moonbit` 的代码块会变成 `test` 用例。
- 标记 `nocheck` 的块保持"仅示意"，会被跳过（沿用 MoonBit 的文档约定）。
- 其他语言一律忽略。

```bash
moon run --target js cmd/moondockit \
  --source examples/doctest \
  --output _doctest_site \
  --doctest-output doctests/doc_examples_test.mbt \
  --doctest-package "Estrella-11/moondockit"
```

MoonBit 只允许在 `moon.pkg` 中声明 import，所以生成的文件把所需 import 写成
头部注释，而不是输出一段无法编译的声明。本仓库用这个功能验证自己：`doctests/`
存放生成的文件，`moon test` 执行它，CI 会重新生成并检查提交的版本是否过期。

## 比赛信息

本项目参加 2026 年 9 月 MoonBit 黑客松大赛，参赛方向为**季度优秀社区项目评选**。

9 月新增贡献：
- 11 个 AI 模块（2,750 行 MoonBit 代码）
- 89 个 AI 测试
- 9 个 CLI AI 标志
- CI 流程覆盖 AI 全功能构建验证
- 发布到 mooncakes.io（版本 0.6.0）

## 许可证

Apache-2.0
