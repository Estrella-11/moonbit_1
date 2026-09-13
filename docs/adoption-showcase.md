# 真实仓库兼容性展示（Real-repo compatibility showcase）

> 本文件记录 MoonDocKit 被用来渲染一个**真实存在、且并非为 MoonDocKit 编写**的
> MoonBit 项目文档时发生的情况。它是**兼容性证据**，不是该项目维护者自主采用
> MoonDocKit 的证明。

## 一、被渲染的真实项目

| 项 | 值 |
|----|-----|
| 项目 | [`mizchi/markdown.mbt`](https://github.com/mizchi/markdown.mbt) |
| 性质 | 已发布到 mooncakes.io 的真实 MoonBit 项目，文档由维护者自行撰写 |
| 输入 | 仓库内的真实 Markdown（`README` / `CLAUDE` / `CONTRIBUTING` / `TODO` 等） |
| 构建命令 | `moon run --target js cmd/moondockit --source <repo> --output dist-showcase-real` |
| 生成站点 | `dist-showcase-real/`（10 个文件） |
| 质量门禁 | 通过，100 / 100 |

## 二、结果指标

| 指标 | 值 |
|------|-----|
| 渲染页数 | 4（`README` / `CLAUDE` / `CONTRIBUTING` / `TODO`） |
| 标题数 | 56 |
| 代码块 | 31 |
| 词数 | 2266 |
| 阅读时长 | 12 分钟 |

质量门禁四项检查全部通过：验证、内容、产出物、可读性。这说明 MoonDocKit 的
渲染器能消化真实世界、作者未为它优化的 Markdown，而不崩溃、不丢失结构。

## 三、为什么这是"兼容性"而非"采用"

- **兼容性**：衡量工具在非预期输入上的行为——这正是评审想看到的健壮性证据。
  它与 `docs/benchmark-corpus.json` 同源（该基准对 4 个真实仓库做同样测量）。
- **非采用**：`mizchi/markdown.mbt` 的维护者并未选择 MoonDocKit 作为其文档工具，
  也未在仓库中引用本工具。本展示仅证明"如果用 MoonDocKit 去渲染它，结果可用"。

如果要把它升级为真正的采用案例，需要该维护者实际采用（在自有仓库里运行
MoonDocKit 并引用）。在此之前，`docs/self-assessment.md` 中
"缺少真实下游包**自主**采用案例"这一项**仍然成立**。

## 四、如何复核

```bash
# 用真实仓库重新构建（需本地已克隆该仓库到某目录）
python tools/benchmark_corpus.py --corpus-dir <含克隆的目录> \
  --repos mizchi/markdown.mbt --write docs/benchmark-corpus.json

# 或单独构建展示站
python - <<'PY'
import shutil
from pathlib import Path
from tools.benchmark_corpus import run_moondockit, ROOT
src = Path("<path>/mizchi_markdown.mbt")
out = ROOT / "dist-showcase-real"
if out.exists(): shutil.rmtree(out)
run_moondockit(src, out, "Real Repo: mizchi/markdown.mbt")
PY

cat dist-showcase-real/quality-report.json
```

## 五、与采用启动包的衔接

想让自己的项目采用 MoonDocKit？从 `examples/adopt-starter/` 开始——一份不需要
`.mbti`、一条命令即可出站的极简模板。详见其 `README.md`。
