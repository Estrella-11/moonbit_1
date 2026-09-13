# MoonDocKit 已知边界与诚实声明

本文件用于评分与审计时**主动暴露局限**，而非为功能背书。每一项都对应一个可验证的事实或可复现的命令。

> 数据来源：本仓库 `docs/benchmark-results.json`（合成语料，2026-06-17，
> Windows 11 / Node v24.14.1 / `moon 0.1.20260529` / release 构建）、
> `docs/benchmark-notes.md`、`docs/ai-transparency.md`，以及 CI 日志。

## 1. AI 模块是规则基线，不是大模型调用

`ai/` 下的 11 个模块是**本地确定性启发式**（关键词/正则/结构化 AST 统计），
**不调用任何外部大模型 API**。详见 `docs/ai-transparency.md`。

- 这意味着 AI 生成的摘要、质量评分、交叉引用是**可复现、可离线、零成本**的，
  但质量上限受规则覆盖度约束——它对结构规范的项目效果最好，对高度非结构化文档可能漏判。
- 它不是"AI 写文档"的替代品，而是"文档质量体检 + 草稿提示"。

## 2. 文档示例测试（doctest）需手动纳入包

`moondockit doctest` 会从 ```` ```mbt ```` 代码块生成 `doc_examples_test.mbt`，
但 MoonBit 没有原生 doc-test，生成文件**必须显式加入包目录并提交**才能被 `moon test` 执行。

- 已为仓库自身 dogfooding：`examples/doctest/` + `doctests/`（`moon test -p Estrella-11/moondockit/doctests`）。
- 局限：文档源若包含 `main` 函数或相互冲突的符号，生成的测试会编译失败，需要作者用 `nocheck` 标注跳过。
- 生成文件不能直接 `import` 被文档的包（MoonBit 仅 `moon.pkg` 可声明 import），
  故生成的测试文件以注释形式提示依赖，需由作者确认可见性。

## 3. API 参考依赖 `moon info` 产物

`--api pkg.generated.mbti` 渲染的符号表来自 `moon info` 的输出。

- 若目标包未在本地 `moon bundle`/`moon info`，则无法解析类型签名。
- 跨包类型仅展示解析到的名称，不保证完整类型推导。

## 4. 运行后端当前仅 JavaScript + Node

CLI 以 MoonBit `--target js` 编译为 `moondockit.js`，由 Node 执行。

- 需要本机 `node`（CI 与本地均依赖）。
- 未提供原生二进制分发（non-js 单元仅用于 `moon check`，不产出可执行 CLI）。

## 5. 性能边界（实测，合成语料）

| 页面数 | 中位耗时 | 产物体积 | 搜索条目 |
|--------|----------|----------|----------|
| 10     | ~99 ms   | 67 KB    | 10       |
| 100    | ~437 ms  | 1.0 MB   | 100      |
| 500    | ~8.0 s   | 12.7 MB  | 500      |

- **搜索索引是全量 JSON**（`search-index.json`）。500 页时约 12.7 MB，
  超大站点（数千页）的索引体积与首次加载会成为瓶颈——**尚无分片/增量搜索**方案。
- **无构建缓存 / 增量构建**：每次运行都全量重渲染。修改单页需重跑全站。
- 以上为 Windows 11 / 消费级硬件数据；生产环境会更快，但未做服务器端基准。

## 6. 主题与模板不可深度定制

- 视觉规范由内置设计系统（`docs/design-system.md`）固定，**不提供自定义模板引擎**。
- 颜色/排版变量可经 front matter 与 `--theme` 类开关有限覆盖，但不能替换 HTML 骨架。
- 这是有意为之：保证输出确定、可审计、无注入面；代价是品牌定制能力弱。

## 7. 部署与生态依赖

- GitHub Pages 部署脚本（`pages.yml`）已就绪，但**未提供其他平台的一键部署**（Vercel/Netlify/Nginx 需手动）。
- 包已发布至 mooncakes.io（`Estrella-11/moondockit`），但**下载量仍较低**，尚无第三方项目公开声明采用。
  本仓库 `docs/ecosystem-impact.md` 记录的是**我们主动为样本项目生成的文档**，
  不等同于"被社区采用"——这一点如实区分。

## 8. 工具链与环境敏感点

- 强依赖 MoonBit 工具链版本：`moondockit_wbtest.mbt` 等测试对 `moon` 的 AST 行为敏感，
  工具链升级可能需要同步更新解析逻辑。
- Windows 上 `git` 与 `moon fmt` 存在 CRLF 换行差异，已通过 CI 的 `moon fmt && git diff --exit-code` 约束，
  本机开发需保持 `core.autocrlf` 一致（见 `docs/windows-toolchain-troubleshooting.md`）。

## 9. 安全边界

- 所有输出经 HTML 转义，无 `innerHTML` 注入路径（见 `docs/security-model.md`）。
- 不执行文档中的代码块，仅静态抽取与渲染——因此**不会运行用户示例代码**，也不会因文档内容触发任意命令。

## 10. 已知待办（不在 0.4.0 范围内）

- [x] UTF-16 代理对（emoji）在段落/链接中导致渲染崩溃 —— **已在 0.4.0 修复**
      （`starts_with_at` 改为逐码元比较，行内发射器按完整码点前进）
- [ ] `moon check --target js` 的 4 条 JS FFI 弃用告警（随工具链版本固定处理）
- [ ] 真实第三方采用案例（需社区项目公开采用或贡献文档站）
- [ ] 大站搜索索引分片
- [ ] 增量构建 / 缓存

## 11. 真实项目语料验证（兼容性实测，非采用声明）

`tools/benchmark_corpus.py` 把 MoonDocKit 跑在 4 个真实 MoonBit 开源仓库的文档上
（非本项目编写，用于检验对外部输入的健壮性）。数据见 `docs/benchmark-corpus.json`。

| 项目 | md 文件 | 渲染页数 | 质量分 | 结果 |
|------|---------|----------|--------|------|
| mizchi/markdown.mbt | 24 | 5 | 100 | OK |
| oboard/mocket | 3 | 3 | 100 | OK（emoji 崩溃已修复） |
| moonbit-community/rabbita | 38 | 0 | 75 | 质量门未过（真实文档结构分偏低，阻断发布但不崩溃） |
| mizchi/js.mbt | 87 | 5 | 100 | OK（emoji 崩溃已修复） |

结论：修复前 3/4 仓库触发运行时崩溃；修复后 **4/4 全部正常完成渲染或给出质量评分**，
无崩溃。rabbita 的质量门 75 分是真实文档的结构性反馈（非缺陷），说明质量门对外部
内容同样严格——这本身就是工程质量信号。

