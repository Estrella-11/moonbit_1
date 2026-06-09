# MoonDocKit

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

## Current Features

- Safe HTML escaping for generated pages.
- Stable ASCII slug generation for headings and page routes.
- Block-level Markdown AST for headings, paragraphs, lists, block quotes, and
  fenced code blocks.
- Inline Markdown rendering for code spans, strong text, and safe links.
- Paragraph line folding and fenced code language labels.
- HTML rendering from parsed Markdown blocks.
- Heading extraction and automatic on-page table of contents.
- Page-unique heading anchors for duplicate section titles.
- Front matter parsing for page title, order, tags, and custom fields.
- Route planning for multi-page sites using page slug and front matter order.
- Static output manifest generation for rendered HTML files.
- JSON search index generation.
- XML sitemap generation.
- Build report generation for output file counts, file kinds, and byte totals.
- Site summary metadata for demos and validation.
- Site validation diagnostics for empty sites, empty titles, empty source
  pages, and duplicate output routes.
- Theme configuration for generated page colors and layout widths.
- Template options for generated page language, description metadata, and
  footer content.
- Runnable demo that prints generated files and site statistics.
- Site-level rendering with sidebar navigation.
- Runnable demo package at `cmd/main`.
- Blackbox tests for public behavior.

## Quick Start

```bash
moon check
moon test
moon run cmd/main
python tools/verify_project.py
```

The demo prints generated output files, summary metadata, and validation
diagnostics for an in-memory documentation site.

## Reviewer Path

For competition review, start with:

- `docs/final-submission.md`
- `docs/acceptance-guide.md`
- `docs/release.md`
- `dist-example`

## Competition Materials

- One-page project proposal: `docs/MoonDocKit-项目申报书-附录二模板版.pdf`
- Development plan: `docs/competition-plan.md`
- Acceptance checklist: `docs/acceptance-checklist.md`
- Acceptance guide: `docs/acceptance-guide.md`
- Final submission notes: `docs/final-submission.md`
- Release notes: `docs/release.md`
- Mooncakes publishing plan: `docs/mooncakes-publishing.md`
- Development log: `docs/development-log.md`
- Benchmark notes: `docs/benchmark-notes.md`
- Example site sources: `examples/site`
- Generated example site: `dist-example`

## Project Direction

MoonDocKit will grow into a practical documentation toolkit for the MoonBit
ecosystem:

- Expand the block-level AST with inline nodes and source spans.
- Add a CLI writer for static output manifests.
- Generate search indexes.
- Report validation diagnostics before publishing.
- Support front matter for page title, order, tags, and layout.
- Provide templates for package docs, tutorials, examples, and changelogs.
- Expand theme presets for package, tutorial, and API reference sites.
- Publish as a reusable package on mooncakes.io.

## Competition Fit

The competition charter asks for projects that are real, reusable, testable,
maintainable, and valuable to the MoonBit open-source ecosystem. MoonDocKit
targets a common ecosystem gap: package authors need a simple way to turn
MoonBit project documentation into browsable static sites without leaving the
MoonBit toolchain.

## License

Apache-2.0.
