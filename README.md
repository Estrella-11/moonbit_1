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
- Paragraph line folding and fenced code language labels.
- HTML rendering from parsed Markdown blocks.
- Heading extraction and automatic on-page table of contents.
- Page-unique heading anchors for duplicate section titles.
- Front matter parsing for page title, order, tags, and custom fields.
- Site-level rendering with sidebar navigation.
- Runnable demo package at `cmd/main`.
- Blackbox tests for public behavior.

## Quick Start

```bash
moon check
moon test
moon run cmd/main
```

The demo prints a complete HTML page generated from an in-memory documentation
site.

## Competition Materials

- One-page project proposal: `docs/MoonDocKit-项目申报书.pdf`
- Development plan: `docs/competition-plan.md`
- Acceptance checklist: `docs/acceptance-checklist.md`
- Development log: `docs/development-log.md`

## Project Direction

MoonDocKit will grow into a practical documentation toolkit for the MoonBit
ecosystem:

- Expand the block-level AST with inline nodes and source spans.
- Render multi-page static documentation sites.
- Generate search indexes.
- Support front matter for page title, order, tags, and layout.
- Provide templates for package docs, tutorials, examples, and changelogs.
- Publish as a reusable package on mooncakes.io.

## Competition Fit

The competition charter asks for projects that are real, reusable, testable,
maintainable, and valuable to the MoonBit open-source ecosystem. MoonDocKit
targets a common ecosystem gap: package authors need a simple way to turn
MoonBit project documentation into browsable static sites without leaving the
MoonBit toolchain.

## License

Apache-2.0.
