# 下游采用案例研究

> 本文件记录 MoonDocKit 被一个真实的下游包结构使用时发生了什么：输入是
> 什么、命令是什么、产出了什么、如何复核。

## 一、案例摘要

| 项 | 值 |
|----|-----|
| 被记录的包 | `example/sample-statkit`（一个统计工具包） |
| 源文档 | 3 篇 Markdown（`overview` / `quick-start` / `changelog`） |
| 接口文件 | `examples/adoption-package/pkg.generated.mbti` |
| 配置文件 | `examples/adoption-package/moondockit.json` |
| 构建命令 | 见下节，一条命令 |
| 生成站点 | `dist-adoption-example/`（9 个文件） |
| 质量门禁 | 通过，100 / 100 |
| 站点指标 | 4 页、22 个标题、8 个代码块、265 词、约 2 分钟阅读 |

## 二、被记录的包

接口文件声明了 4 个公开函数、1 个结构体和 1 个枚举：

```moonbit
pub fn mean(Array[Double]) -> Double
pub fn median(Array[Double]) -> Double
pub fn percentile(Array[Double], Double) -> Double
pub fn summarize(Array[Double]) -> Summary

pub(all) struct Summary { count : Int, mean : Double, median : Double, min : Double, max : Double }
pub(all) enum SampleError { EmptySample, InvalidPercentile }
```

这个规模是有意选择的：它小到评审可以在两分钟内读完，又大到足以暴露真实
问题——API 符号是否被文档覆盖、代码块是否标注语言、页面之间是否互相引用。

## 三、采用前的问题

| 问题 | 表现 |
|------|------|
| 三份文档表面彼此脱节 | README、手写指南、`moon info` 生成的接口各写各的 |
| 没有可浏览的 API 参考 | 用户必须打开 `.mbti` 源文件才能知道有哪些函数 |
| 没有搜索 | 包一旦超过几页，读者只能靠浏览器 `Ctrl+F` |
| 没有发布门禁 | 空页面、重复路由、缺失标题只能靠人工评审发现 |

## 四、采用步骤

一条命令即可复现：

```bash
moon run --target js cmd/moondockit \
  --config examples/adoption-package/moondockit.json --strict
```

配置内容（所有字段都写在文件里，因此构建可重复）：

```json
{
  "source": "examples/adoption-package/site",
  "output": "dist-adoption-example",
  "api": "examples/adoption-package/pkg.generated.mbti",
  "title": "SampleStatKit Docs",
  "site_url": "https://example.com/sample-statkit",
  "language": "en",
  "theme": "api",
  "description": "Adoption example for a small MoonBit statistics package",
  "footer": "Adoption example built with `MoonDocKit`"
}
```

`--strict` 意味着验证告警会中断构建：空页面、空标题、重复路由、质量门禁不
通过都会在写出任何文件之前失败。

## 五、产出物

| 文件 | 大小 | 作用 |
|------|------|------|
| `index.html` | 311 B | 静态托管根入口 |
| `overview.html` | 30.6 KB | 指南首页 |
| `quick-start.html` | 30.6 KB | 上手页 |
| `changelog.html` | 30.0 KB | 变更记录 |
| `api-reference.html` | 32.7 KB | 由 `.mbti` 生成的 API 参考 |
| `search-index.json` | 2.8 KB | 交互式搜索数据源 |
| `sitemap.xml` | 271 B | 搜索引擎索引 |
| `robots.txt` | 44 B | 抓取策略 |
| `quality-report.json` | 595 B | 机器可读的发布门禁结果 |

质量门禁结果：

```json
{
  "site_title": "SampleStatKit Docs",
  "passed": true,
  "score": 100,
  "metrics": {"page_count": 4, "heading_count": 22, "code_block_count": 8, "word_count": 265, "reading_minutes": 2}
}
```

四项检查全部通过：验证、内容、产出物、可读性。

## 六、采用前后对比

| 维度 | 采用前 | 采用后 |
|------|--------|--------|
| API 可发现性 | 需要读 `.mbti` 源文件 | `api-reference.html` 带符号锚点与分组索引 |
| 搜索 | 无 | `search-index.json` + 页面内交互搜索 |
| 文档一致性 | 手写维护 | 指南与 `.mbti` 在同一次构建中合并 |
| 发布前检查 | 人工 | `quality-report.json`（可机器断言） |
| 可部署性 | 需自行拼装 | 根目录 `index.html`，任意静态托管直接可用 |
| 构建可重复性 | 依赖临场命令 | 配置文件 + 一条命令 |

## 七、如何复核

```bash
# 重新构建并覆盖产物
moon run --target js cmd/moondockit \
  --config examples/adoption-package/moondockit.json --strict

# 检查质量门禁
cat dist-adoption-example/quality-report.json

# 确认 API 参考确实包含接口符号
grep -q "summarize" dist-adoption-example/api-reference.html
grep -q "SampleError" dist-adoption-example/api-reference.html
grep -q "example/sample-statkit" dist-adoption-example/api-reference.html
```

这些断言也是 `tools/verify_project.py` 在 CI 中执行的内容，因此该案例不是
一次性的手工演示，而是被自动化反复验证的。

## 八、局限性与下一步

**诚实说明**：本案例使用的是仓库内置的下游包夹具
（`examples/adoption-package`），用于让评审无需创建第二个仓库即可检查完整
的采用路径。它**不是**第三方维护者自主采用 MoonDocKit 的证据。

要把它升级为真实案例，需要完成：

1. 选定一个真实存在的 MoonBit 生态包（最好是已发布到 mooncakes.io 的）。
2. 用同一份配置文件为其生成文档，保留 before / after 两份产物。
3. 记录维护者遇到的实际问题与 MoonDocKit 的修复，形成可引用的反馈闭环。

在此之前，`docs/self-assessment.md` 中"缺少真实下游包采用案例"这一不足
**仍然成立**，未因本文档而关闭。
