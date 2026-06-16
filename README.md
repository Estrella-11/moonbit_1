# MoonDocKit

[![CI](https://github.com/Estrella-11/moonbit_1/actions/workflows/ci.yml/badge.svg)](https://github.com/Estrella-11/moonbit_1/actions/workflows/ci.yml)
[![Showcase](https://github.com/Estrella-11/moonbit_1/actions/workflows/pages.yml/badge.svg)](https://estrella-11.github.io/moonbit_1/)

MoonDocKit is a MoonBit-first documentation site toolkit for package authors.
It turns package notes and guides into small static HTML documentation sites
with safe HTML escaping, stable anchors, navigation, and testable rendering
logic.

This repository is being developed for the 2026 MoonBit 国产基础软件开源大赛.
The project is intentionally scoped as an ecosystem tool rather than another
standalone Markdown parser: the long-term goal is to help MoonBit package
authors publish clear docs, examples, API guides, and release notes with a
simple MoonBit workflow.

Repository mirrors:

- GitHub: <https://github.com/Estrella-11/moonbit_1>
- Gitlink: <https://gitlink.org.cn/Estrella/moonbit>

Public showcase: <https://estrella-11.github.io/moonbit_1/>

Generated MoonBit API:

- Public showcase: <https://estrella-11.github.io/moonbit_1/api-reference.html>
- Repository artifact: `dist-cli-example/api-reference.html`

## Current Features

- Safe HTML escaping for generated pages.
- Stable ASCII slug generation for headings and page routes.
- Block-level Markdown AST for H1-H3 headings, paragraphs, lists, block quotes, and
  fenced code blocks.
- Inline Markdown rendering for code spans, strong text, and safe links.
- Paragraph line folding and fenced code language labels.
- HTML rendering from parsed Markdown blocks.
- Heading extraction and automatic on-page table of contents.
- Page-unique heading anchors for duplicate section titles.
- Front matter parsing for page title, order, tags, and custom fields.
- MoonBit `.mbti` public API extraction and reference-page generation.
- API reference summaries with declaration counts, function arity, and return
  type extraction from MoonBit signatures.
- Per-symbol API anchors so generated reference pages can deep-link directly to
  individual functions, structs, enums, and traits.
- Grouped API symbol index links for fast navigation across large generated
  reference pages.
- Route planning for multi-page sites using page slug and front matter order.
- Static output manifest generation for rendered HTML files.
- JSON search index generation with a built-in interactive search interface.
- XML sitemap generation.
- robots.txt generation for generated static sites.
- Machine-readable `site-manifest.json` generation for deploy and acceptance
  checks.
- Build report generation for output file counts, file kinds, and byte totals.
- Document and site metrics for headings, code blocks, word counts, and
  estimated reading time.
- Quality gate evaluation for publish-readiness checks and scoring.
- MoonBit CLI for reading a Markdown directory and writing a complete static
  documentation site.
- Responsive documentation layout with active navigation and mobile support.
- Root `index.html` generation for direct static-host deployment.
- Site summary metadata for demos and validation.
- Site validation diagnostics for empty sites, empty titles, empty source
  pages, and duplicate output routes.
- Theme configuration for generated page colors and layout widths.
- Template options for generated page language, description metadata, and
  footer content.
- Canonical links and Open Graph metadata for generated pages.
- Runnable demo that prints generated files and site statistics.
- Seven-scenario compiled CLI integration suite covering real builds, generated
  API output, invalid arguments, empty sites, missing source directories, and
  output path conflicts, plus config-file builds and CLI overrides.
- Site-level rendering with sidebar navigation.
- Runnable demo package at `cmd/main`.
- Blackbox tests for public behavior.

## Quick Start

```bash
moon check
moon test
python tools/test_cli.py
python tools/benchmark_cli.py --pages 10,100 --rounds 2
moon run cmd/main
python tools/verify_project.py
```

The demo prints generated output files, summary metadata, and validation
diagnostics for an in-memory documentation site.

Build the included Markdown example with the MoonBit CLI:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-cli-example \
  --title "MoonDocKit CLI Example" \
  --site-url https://example.com/moondockit-cli \
  --language en \
  --description "MoonDocKit CLI documentation" \
  --footer "Built with `MoonDocKit`"
```

The CLI reads every `.md` file, evaluates the quality gate, and writes a root
`index.html`, documentation pages, an interactive search experience backed by
`search-index.json`, plus `sitemap.xml`, `robots.txt`, and
`site-manifest.json`.

For repeatable project builds, put the same fields in JSON and pass `--config`:

```bash
moon run --target js cmd/moondockit --config examples/moondockit.json
```

The example configuration is documented in `docs/configuration.md`, and
`examples/moondockit.schema.json` describes the supported fields for editor
hints and review.

The CLI exposes source, output, language, description, footer, canonical URL,
and optional `.mbti` API inputs. Command-line options override config-file
values. The compiled Node.js CLI returns non-zero process exit codes for
invalid arguments and failed quality gates.

Include generated MoonBit package API documentation:

```bash
moon info
moon run --target js cmd/moondockit \
  --source examples/site \
  --api pkg.generated.mbti \
  --output dist-api \
  --title "MoonDocKit"
```

The `.mbti` parser extracts public functions, structs, enums, and traits into a
searchable API reference page. It also derives a compact API summary, function
parameter counts, return types, per-symbol anchors, and a grouped symbol index
from signatures so the generated reference is useful during review instead of
being only a raw declaration dump. This keeps the generated documentation
aligned with the package interface produced by the MoonBit toolchain.

## Reviewer Path

For competition review, start with:

- `docs/final-submission.md`
- `docs/acceptance-guide.md`
- `docs/release.md`
- `dist-example`
- `dist-cli-example/overview.html`
- `dist-cli-example/api-reference.html`

## Competition Materials

- One-page project proposal: `docs/MoonDocKit-项目申报书-附录二模板版.pdf`
- Development plan: `docs/competition-plan.md`
- Acceptance checklist: `docs/acceptance-checklist.md`
- Acceptance guide: `docs/acceptance-guide.md`
- Final submission notes: `docs/final-submission.md`
- Release notes: `docs/release.md`
- Architecture and design decisions: `docs/architecture.md`
- 90-second reviewer demo: `docs/demo-script.md`
- Deployment and release runbook: `docs/deployment-runbook.md`
- Configuration guide: `docs/configuration.md`
- Mooncakes publishing plan: `docs/mooncakes-publishing.md`
- Development log: `docs/development-log.md`
- Benchmark notes: `docs/benchmark-notes.md`
- Example site sources: `examples/site`
- Generated example site: `dist-example`
- MoonBit CLI generated site: `dist-cli-example`

## Project Direction

MoonDocKit is now an end-to-end documentation toolkit for the MoonBit
ecosystem. The next milestones focus on adoption and release quality:

- Add source spans and richer inline nodes to the Markdown AST.
- Add more theme presets for package, tutorial, and API reference sites.
- Improve filesystem diagnostics and add more real-package adoption examples.
- Publish the reusable package on mooncakes.io.

## Competition Fit

The competition charter asks for projects that are real, reusable, testable,
maintainable, and valuable to the MoonBit open-source ecosystem. MoonDocKit
targets a common ecosystem gap: package authors need a simple way to turn
MoonBit project documentation into browsable static sites without leaving the
MoonBit toolchain.

## License

Apache-2.0.
