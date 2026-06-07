# MoonDocKit 项目申报书草稿

## 基本信息

项目名称：MoonDocKit：MoonBit 文档站生成工具链

参赛者：待填写

联系方式：待填写

GitHub 仓库链接：https://github.com/Estrella-11/moonbit_1

Gitlink 仓库链接：https://gitlink.org.cn/Estrella/moonbit

项目方向：MoonBit 应用生态 / 工程基础设施

是否为原创项目：原创项目，参考成熟静态文档站工具的产品形态，但核心实现使用 MoonBit 重新设计。

## 项目简介

MoonDocKit 计划为 MoonBit 生态提供一个轻量、可测试、可发布的文档站生成工具链。项目面向 MoonBit 包作者、示例工程维护者和生态教程作者，帮助他们把 Markdown 风格的项目说明、教程、示例、API 指南和更新日志生成可浏览的静态 HTML 文档站。

项目不是重复实现已有 Markdown parser，而是围绕 MoonBit 包文档发布场景，提供页面模型、路由规划、导航生成、HTML 安全转义、目录提取、模板渲染、搜索索引和可运行示例，最终发布到 mooncakes.io，作为后续 MoonBit 生态项目可复用的基础工具。

## 核心功能范围

- 提供 DocPage、DocSite、RenderedPage 等文档站核心数据模型。
- 支持安全 HTML 转义和稳定 slug 生成。
- 支持 Markdown 子集渲染，包括标题、段落、列表、引用和代码块。
- 支持多页面文档站渲染、侧边栏导航生成和页面内目录生成。
- 支持 front matter，用于标题、排序、标签和布局配置。
- 支持标题提取和 TOC 生成。
- 支持搜索索引生成，便于前端快速检索文档内容。
- 提供 CLI 示例，可从示例文档生成静态站点。
- 提供完整 README、使用示例、测试、CI 和发布说明。

## 计划实现方式

第一阶段完成 MoonBit 模块初始化、README、CI、基础数据模型、渲染函数和可运行示例，满足项目申报和早期展示要求。

第二阶段将行级 Markdown 渲染升级为块级 AST 解析，补充 front matter、路由规划和模板渲染，形成可复用库 API。

第三阶段实现静态站点输出、搜索索引、主题样式、示例站点、benchmark 和 mooncakes.io 发布，准备验收材料与展示脚本。

## 最终交付

- 一个公开可访问的 GitHub 仓库和 Gitlink 同步仓库。
- 一个以 MoonBit 为主要实现语言的文档站生成工具包。
- 可运行示例和测试用例。
- CI 工作流，覆盖 check、test 和 demo run。
- README、开发日志、发布说明和开源许可证。
- 发布到 mooncakes.io 的 MoonBit 包。
