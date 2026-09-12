# Capability Matrix

A single-page, enumerable inventory of what MoonDocKit does, where each
capability lives, and the command that proves it. Written in the form that
MoonBit competition submissions are judged on: dense, checkable, no prose
standing in for evidence.

Measured on commit `035b3a20`.

## Part 1 — Capabilities

### Parsing

| Capability | Implementation | Verified by |
| --- | --- | --- |
| Front matter (title, order, tags, custom fields) | `moondockit.mbt` `parse_front_matter` | `moondockit_test.mbt` |
| Block AST for H1–H3, paragraphs, lists, block quotes, fenced code | `parse_blocks` (line 677) | `moondockit_test.mbt` |
| Fenced-code language labels | `parse_blocks` | `moondockit_test.mbt` |
| Paragraph line folding | `parse_blocks` | `moondockit_test.mbt` |
| Inline code spans, emphasis, strong, links, autolinks, images | `render_inline` (line 975, character scanner) | `moondockit_test.mbt` |
| Nested inline emphasis (`**bold *italic* bold**`) | `render_inline` recursive descent | `moondockit_test.mbt` |
| `.mbti` interface parsing | `parse_mbti` (line 218) | `moondockit_test.mbt` |
| Heading slugging with duplicate-anchor disambiguation | `slug` / anchor planner | `moondockit_test.mbt` |

### Rendering and safety

| Capability | Implementation | Verified by |
| --- | --- | --- |
| HTML escaping of all generated text and attributes | escape helpers | `docs/security-model.md`, tests |
| Safe link and image URL filtering | `render_inline` | `moondockit_test.mbt` |
| Code-block language labelling | block renderer | tests |
| Table of contents extraction | `render_toc` | tests |
| Duplicate section titles get unique anchors | anchor planner | tests |

### Site assembly

| Capability | Implementation | Verified by |
| --- | --- | --- |
| Multi-page static site output | `build_site` | `tools/verify_project.py` |
| Deterministic route planning | route planner | tests |
| Site manifest (`site-manifest.json`) | output manifest writer | `tools/verify_project.py` |
| Sitemap (`sitemap.xml`) | site assembly | `tools/verify_project.py` |
| `robots.txt` | site assembly | `tools/verify_project.py` |
| Search index (`search-index.json`) | search index builder | `tools/verify_project.py` |
| Client-side search UI | `render_search_script` | `tools/verify_project.py` |
| Light/dark theme with token substitution | `render_theme_style`, `render_theme_bootstrap` | `docs/design-system.md` |
| Three theme presets: `default`, `package`, `api` | `default_theme`, `package_theme`, `api_reference_theme` | `moondockit_test.mbt` |
| Generated API reference page | `mbti_to_page` (line 273) | `dist-cli-example/api-reference.html` |

### Quality gates

| Capability | Implementation | Verified by |
| --- | --- | --- |
| Publish-readiness scoring | quality gate | `dist-cli-example/quality-report.json` (score 100, `passed: true`) |
| Diagnostics with severity levels | `DiagnosticLevel` (`DiagError` / `DiagWarning`) | `moondockit_test.mbt` |
| Strict mode (non-zero exit on diagnostics) | CLI `--strict` | `tools/test_cli.py` |
| Dry-run mode | CLI `--dry-run` | `tools/test_cli.py` |
| CLI integration scenarios | `tools/test_cli.py` | 10 scenarios, run in CI |
| One-shot acceptance verification | `tools/verify_project.py` | CI step |

### AI documentation suite (11 modules)

| Module | Capability |
| --- | --- |
| `ai_core.mbt` | Shared AI configuration and result types |
| `ai_common.mbt` | Shared list/count utilities |
| `ai_prompts.mbt` | Prompt templates with `{{variable}}` substitution |
| `ai_doc_gen.mbt` | Documentation generation with complexity and usage-frequency analysis |
| `ai_quality.mbt` | Rule-based quality assessment, heading hierarchy, site-level aggregation |
| `ai_summary.mbt` | Summarisation, keyword extraction, content-type detection |
| `ai_xref.mbt` | Cross-reference detection, orphan-page identification |
| `ai_coverage.mbt` | Documentation coverage analysis with per-kind breakdown |
| `ai_consistency.mbt` | Heading style, hierarchy, code labels, duplicates, length outliers |
| `ai_seo.mbt` | Meta descriptions, keyword density, search-boost scoring |
| `ai_recommend.mbt` | Learning paths, next steps, related pages, hub identification |

Plus `ai_test_gen.mbt` (test-stub generation from API symbols) and
`ai_test.mbt` (the AI test suite).

Every AI function takes an `AiConfig` parameter for a future LLM provider. The
current baseline is rule-based and needs no API key, so the whole suite is
reproducible offline and in CI.

### CLI

| Surface | Count | Detail |
| --- | --- | --- |
| Options | 10 | `config`, `source`, `output`, `title`, `site-url`, `api`, `language`, `description`, `footer`, `theme` |
| Flags | 11 | `dry-run`, `strict`, and 9 `--ai-*` switches |
| AI switches | 9 | `--ai-doc`, `--ai-quality`, `--ai-summary`, `--ai-xref`, `--ai-coverage`, `--ai-consistency`, `--ai-seo`, `--ai-recommend`, `--ai-tests` |
| JSON config | 1 schema | `examples/moondockit.schema.json` |

## Part 2 — MoonBit Capabilities The Design Depends On

Competition citations repeatedly reward projects for *showing what MoonBit
does well*. These are the specific language and toolchain capabilities this
design leans on, rather than merely being written in MoonBit.

| MoonBit capability | Where it is load-bearing |
| --- | --- |
| Algebraic data types with typed payloads | `MarkdownBlock` (line 202) carries `Heading(Int, String)`, `Paragraph(String)`, `UnorderedList(Array[String])`, `BlockQuote(String)`, `CodeBlock(String, String)`. The parser produces variants; the renderer consumes them. There is no stringly-typed intermediate representation. |
| Exhaustive pattern matching | 28 `match` expressions over the block AST, diagnostic levels and parsed fields. Adding a block variant makes the compiler point at every renderer site that must handle it — the safety property a generic Markdown pipeline cannot offer. |
| Option types in public data | `FrontMatter` (line 170) models absent metadata as `String?` / `Int?` rather than sentinel strings (31 `Some(`, 33 `None` uses). "Missing title" and "title is the empty string" stay distinguishable. |
| Tagged enums for severity | `DiagnosticLevel` (line 138) = `DiagError` \| `DiagWarning` drives both exit codes and rendered output. |
| Cross-package references | 19 `@lib.` references from the CLI into the library package, so the CLI stays a thin adapter over a reusable, independently testable core. |
| Standard library only | `moon.mod` declares no `import` block. The CLI uses `@argparse` from the standard library; everything else is handwritten. Zero external dependencies means zero supply-chain surface and a build that cannot break from an upstream release. |
| JavaScript FFI | 9 `extern "js"` declarations in `cmd/moondockit/fs_js.mbt` isolate all filesystem and process access behind one file, keeping the core platform-independent. |
| Multi-target builds | The library is checked against both the default (wasm-gc) target and the JS target in CI, and ships a runnable in-memory demo plus a real filesystem CLI from the same core. |
| `.mbti` interface introspection | `parse_mbti` and `mbti_to_page` read MoonBit's own generated interface files to produce an API reference. This is the one capability that is *specific to the MoonBit ecosystem*: no generic documentation generator can read `.mbti`. |

## Part 3 — Reproducing This Page

```bash
moon check                                  # 0 errors
moon test                                   # 139 / 139 passing
moon check --target js                      # JS target
moon run cmd/main                           # in-memory demo
python tools/test_cli.py                    # 10 CLI scenarios
python tools/verify_project.py              # one-shot acceptance
cat dist-cli-example/quality-report.json     # release gate
```

Non-test MoonBit source: 5,945 lines across 17 files. Public API: 43 core
functions + 41 AI functions. External dependencies: 0.
