# Award Benchmark — What Past MoonBit Winners Do Well

This document records the research behind the September UX and product
revision: which MoonBit competition projects won, what judges explicitly
praised, which of those patterns MoonDocKit already satisfies, and which gaps
are deliberately left open.

It is written so a reviewer can check every claim against a public source or a
command in this repository.

## Method

Sources used:

- 2024 MoonBit Global Programming Innovation Challenge — award announcement and
  open-sourced team repositories.
- MoonBit Large-Scale Software Synthesis Challenge — final-round recap with
  first/second/third prize citations.
- 2026 MoonBit Open Source Competition (Aka MoonBit) — published list of 13
  award-winning projects.
- Public project pages of accepted entrants, used as a reference for how a
  strong submission presents itself (`moon-ray`, `moonbit-log`).

## What Judges Actually Praise

| Project | Event / result | Citation |
| --- | --- | --- |
| 《坦克儿大冒险》 (Tankle Adventure) | 2024 Innovation Challenge, game track, 1st prize | 完成度、可玩性很高; 创新性展现出 MoonBit 编程语言和 WASM4 引擎的优势 |
| MiniMoonbitMachine | 2024 Innovation Challenge, language track, 1st | 编译器在性能测试中一骑绝尘; 代码体积测试中普遍明显好于参考实现 |
| morm | Large-Scale Software Synthesis, 1st prize | 旨在补齐生态中 ORM 方向的能力空白; 保持类型安全与透明性 |
| Kwiver | Large-Scale Software Synthesis, 1st prize | 借助 MoonBit 的类型系统与多后端能力，在可维护性与扩展性方面进行了优化 |
| Moon Lottie, QED | Large-Scale Software Synthesis, 2nd prize | Recognised for system design and engineering depth rather than demo polish |
| MoonCharts, MoonMarkMind, raft-moonbit, linear-algebra, moonsic, … | 2026 Open Source Competition, 3rd prize | 13 winners total; each ships a reusable library, not a one-off demo |

Two accepted entrants are useful because they advertise their submission in a
way that is easy to copy:

- `moon-ray` (2026 competition): 纯 MoonBit 实现 · 内置 13 个演示场景 · 完整
  CI/CD 流水线 · 32 个单元测试全部通过 · 已发布至 mooncakes.io 生态.
- `moonbit-log` (CCF OSC2026): project-status block opening with
  `moon check --deny-warn 通过` / `moon test 163/163 通过` /
  `代码规模: 4,100+ 行` / `零外部依赖，仅使用 MoonBit 标准库`, followed by a
  dense capability matrix (6 log levels, 21 handlers, 14 formatters).

## The Winning Formula

Seven patterns recur across winning and strongly-presented entries:

1. **Completeness you can run.** Every citation mentions 完成度 or a runnable
   artifact. Nothing is judged on intent.
2. **Quantified credibility up front.** Test counts, line counts, dependency
   counts and benchmark multiples appear in the first screen of the README.
3. **A named ecosystem gap.** "补齐生态中 XX 方向的能力空白" is the single most
   repeated justification for a first prize.
4. **Language strengths made explicit.** Winners are praised for *showing what
   MoonBit can do*, not merely for being written in it.
5. **A dense capability matrix.** Long enumerable feature tables read as
   evidence of completeness; prose paragraphs do not.
6. **One-command reproducibility.** CI plus a green test suite lets a judge
   re-derive the claims without trusting the author.
7. **Published.** `moon add` reachability on mooncakes.io is treated as the
   line between a project and a repository.

## MoonDocKit Against The Formula

| Pattern | Status | Evidence |
| --- | --- | --- |
| 1. Completeness | Met | Real CLI, 17 MoonBit source files, 3 generated example sites, quality gate 100/100 |
| 2. Quantified credibility | **Added this round** | `At a Glance` block in `README.md`; every figure re-measurable |
| 3. Named ecosystem gap | Met | `docs/ecosystem-impact.md` — docs surfaces drift apart; MoonDocKit joins them |
| 4. Language strengths | **Added this round** | `docs/why-moonbit.md` |
| 5. Capability matrix | **Added this round** | `docs/capability-matrix.md` |
| 6. Reproducibility | Met | CI = 20/20 steps green; 139 tests; `tools/verify_project.py`; `tools/test_cli.py` |
| 7. Published | Met | `Estrella-11/moondockit` 0.2.0 on mooncakes.io |

Two of the seven were the actual gaps, and both were presentation gaps rather
than capability gaps: the project could already do the work but did not make a
reviewer able to *verify it in one screen*.

## Changes Driven By This Research

- **`README.md` `At a Glance`** — puts the quantified signals first, before any
  prose, following the `moonbit-log` / `moon-ray` convention.
- **`docs/capability-matrix.md`** — one document covering both remaining gaps:
  Part 1 converts the previous prose feature list into an enumerable matrix,
  Part 2 states which MoonBit capabilities the design actually leans on.
- **Stale-claim correction** — the README, `README_CN.md` and four `docs/`
  files still advertised pre-refactor metrics (118 tests, 84 AI tests, 3,836 AI
  lines, 2,090 core lines). All were re-measured and corrected. This follows the
  project's own rule in `docs/award-sprint.md`: *a stale artifact is more
  damaging than a missing stretch feature.*
- **`docs/self-assessment.md`** — removed the "September code not yet committed
  to git" risk note, which became false once the work landed.

## Deliberate Non-Changes

| Considered | Decision | Reason |
| --- | --- | --- |
| Turn `index.html` into a branded landing page | No | `build_index_page` emits `content="0"`, an instant redirect — visitors never see it. Visual value ≈ 0, regression risk > 0. `docs/` defines it as a hosting entry point, not a showcase. |
| Replace the hardcoded `--gold` accent (`#b08948` / `#d8b871`) with a themed token | No, deferred | Used only by the reading-progress gradient and the block-quote rule. Verified by render that `package_theme` and `api_reference_theme` still look coherent, so the mismatch is not user-visible. |
| Re-colour `package_theme` / `api_reference_theme` to the new palette | No | `moondockit_test.mbt` pins `background:#f8faf7`, `color:#2f7d57`, `color:#5b5f97`. Changing them is an intentional API-contract change, not a cleanup, and must be done as its own reviewed change. |

## Deferred: Four JavaScript-FFI Deprecation Warnings

`moon check --target js` reports 4 warnings, all the same class:

```text
Warning: [0020] Using `Array` in JavaScript FFI is deprecated. Use `FixedArray` instead.
```

Locations — all in `cmd/moondockit/fs_js.mbt`:

| Line | Declaration |
| --- | --- |
| 3 | `extern "js" fn cli_arguments() -> Array[String]` |
| 77 | `extern "js" fn read_markdown_directory(path : String) -> Array[String]` |
| 105 | `write_output_directory(..., paths : Array[String], ...)` |
| 106 | `write_output_directory(..., contents : Array[String], ...)` |

Not converted in this round, deliberately:

- The change is not local. `cli_arguments()` feeds `@argparse.Command::parse`,
  which expects `Array[String]`, and `write_output_directory` is called with
  arrays built by `paths.push(...)` — `FixedArray` has no `push`. Both call
  sites in `cmd/moondockit/main_js.mbt` (lines 97 and 211) need a conversion or
  a construction rewrite, on the CLI's main entry path.
- The warnings are deprecation notices, not errors; `moon check` on the root
  target is already warning-free, and CI is green.
- `ci.yml` already probes `--deny-warn` for `moon fmt` and `moon info` and
  falls back with an explicit message, so the maintainers have already reasoned
  about this class of gap.

The correct time to land it is together with a toolchain pin, so the fix can be
verified locally against the same compiler CI uses. Tracked here rather than
silently dropped.

## Re-Measuring Every Figure

Run from the repository root:

```bash
# Non-test MoonBit source size
find . -name '*.mbt' -not -path './_build/*' -not -name '*test*' | xargs wc -l

# Test counts and pass/fail
moon test

# External dependencies (expect: no import block in moon.mod)
grep -c '^import' moon.mod

# Public API surface
grep -c '^pub fn' moondockit.mbt
cat ai/*.mbt | grep -c '^pub fn'

# CLI arguments
grep -c '@argparse.OptionArg(' cmd/moondockit/main_js.mbt
grep -c '@argparse.FlagArg(' cmd/moondockit/main_js.mbt

# Generated artifact set and release gate
python tools/verify_project.py
cat dist-cli-example/quality-report.json
```

Measured on commit `035b3a20`: 5,945 non-test source lines across 17 files;
139 tests passing; 0 external dependencies; 43 core + 41 AI public functions;
10 options + 11 flags; 13 generated files; quality score 100.
