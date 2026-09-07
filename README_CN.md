# MoonDocKit

[![CI](https://github.com/Estrella-11/moonbit_1/actions/workflows/ci.yml/badge.svg)](https://github.com/Estrella-11/moonbit_1/actions/workflows/ci.yml)
[![Showcase](https://github.com/Estrella-11/moonbit_1/actions/workflows/pages.yml/badge.svg)](https://estrella-11.github.io/moonbit_1/)

MoonDocKit 是一个 MoonBit 原生的文档站点工具包，面向 MoonBit 包作者。
它将包说明、指南和 API 接口文件转换为静态 HTML 文档站点，同时提供 11 个 AI
驱动的文档分析模块。

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

## 快速开始

```bash
# 编译检查
moon check

# 运行测试（118 个测试）
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
├── ai/                    # 11 个 AI 模块（3,836 行）
├── cmd/moondockit/        # CLI 入口（453 行）
├── docs/                  # 30+ 文档文件
├── examples/              # 3 个可运行示例
├── tools/                 # 验证和基准测试工具
├── moondockit.mbt         # 核心库（2,090 行）
├── moondockit_test.mbt    # 核心测试（34 个）
├── pkg.generated.mbti     # 自动生成的接口文件
├── moon.mod               # 包配置
├── LICENSE                # Apache-2.0
└── CHANGELOG.md           # 变更日志
```

## 测试

```bash
# 运行全部 118 个测试
moon test --target wasm-gc

# AI 模块测试（84 个）
# 包含在 ai/ai_test.mbt 中，覆盖所有公开函数和边缘情况
```

## 比赛信息

本项目参加 2026 年 9 月 MoonBit 黑客松大赛，参赛方向为**季度优秀社区项目评选**。

9 月新增贡献：
- 11 个 AI 模块（3,836 行 MoonBit 代码）
- 84 个 AI 测试
- 9 个 CLI AI 标志
- CI 流程覆盖 AI 全功能构建验证
- 发布到 mooncakes.io（版本 0.2.0）

## 许可证

Apache-2.0
