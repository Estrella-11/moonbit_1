# MoonDocKit 项目申报书

## 基本信息

- 项目名称：MoonDocKit：MoonBit 文档站生成工具链
- 参赛者：Estrella
- 联系方式：以赛事报名表填写信息为准
- GitHub 仓库链接：https://github.com/Estrella-11/moonbit_1
- Gitlink 仓库链接：https://gitlink.org.cn/Estrella/moonbit
- 项目方向：MoonBit 应用生态 / 工程基础设施 / Markdown to HTML 工具
- 是否为移植项目：否，原创项目

## 项目简介

MoonDocKit 计划为 MoonBit 生态提供一个轻量、可测试、可发布的文档站生成工具链。项目面向 MoonBit 包作者、示例工程维护者、教程作者和生态项目开发者，帮助他们将 README、教程、API 文档、示例说明和更新日志生成可浏览的静态 HTML 文档站。

本项目不是单纯重复实现通用 Markdown parser，而是围绕 MoonBit 包文档发布场景，提供页面模型、Front Matter 元数据、路由规划、侧边栏导航、页面目录、搜索索引、站点校验、主题配置、示例站点和验收脚本。目标是在 MoonBit 生态中沉淀一个真实可用、可测试、可维护、可发布到 mooncakes.io 的基础工具包。

## 核心功能范围

- 提供 `DocPage`、`DocSite`、`RenderedPage`、`OutputFile` 等文档站核心数据模型；
- 支持安全 HTML 转义和稳定 slug 生成，避免生成页面中的基础安全和链接问题；
- 提供块级 Markdown AST，支持标题、段落、无序列表、引用块和 fenced code block；
- 支持 Front Matter 解析，用于页面标题、排序、标签和自定义字段；
- 支持多页面路由规划，生成稳定的 HTML 输出路径和侧边栏导航；
- 支持页面内目录提取和重复标题 anchor 去重；
- 支持静态输出 manifest，便于 CLI 或外部脚本将结果写入目录；
- 支持 JSON 搜索索引生成，便于后续接入前端搜索体验；
- 支持站点摘要和站点校验诊断，发现空站点、空标题、重复路由、空正文等问题；
- 支持主题配置，允许调整页面颜色、侧栏宽度和正文宽度；
- 提供可运行 demo、示例文档站、验收脚本、CI、测试、开发日志和发布说明。

## 原创及参考说明

- 本项目为原创项目，不是对某个已有开源仓库的直接移植。
- 项目产品形态参考了成熟静态文档站工具的常见能力，例如页面路由、目录、搜索索引、主题配置和静态输出，但核心模型、API、解析逻辑、渲染逻辑和测试均使用 MoonBit 重新设计实现。
- 项目采用 Apache-2.0 开源许可证。
- 仓库不包含未经授权的私有代码、闭源代码或商业代码；示例文档和测试数据均为项目自建内容。

## 实施计划

- 立项阶段：完成 MoonBit 模块初始化、Apache-2.0 许可证、README、CI、基础数据模型、可运行 demo、项目申报书和双仓库同步。
- 开发阶段：持续完善块级 Markdown AST、Front Matter、路由规划、TOC、搜索索引、站点校验、主题配置、示例站点、测试和验收文档。
- 验收阶段：保持 GitHub 与 Gitlink 仓库公开可访问，确保 `moon check`、`moon test`、`moon run cmd/main` 和 `python tools/verify_project.py` 可复现；补充 mooncakes.io 发布。
- 展示阶段：围绕 MoonBit 生态文档发布痛点，展示从 Markdown 源文件到静态文档站、搜索索引、校验诊断和主题配置的完整流程。

## 最终交付

- 一个以 MoonBit 为主要实现语言的可复用文档站生成工具包；
- GitHub 与 Gitlink 双公开仓库，保留连续、清晰、可追踪的提交历史；
- README、开发日志、验收指南、最终提交说明、release notes 和 mooncakes.io 发布计划；
- 可运行 demo、示例文档站、生成结果和一键验证脚本；
- 覆盖核心功能路径的 MoonBit 测试；
- 后续发布到 mooncakes.io 的 MoonBit 生态包。
