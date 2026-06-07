# Development Log

## 2026-06-07

Initialized MoonDocKit as a MoonBit package for the 2026 MoonBit open-source
competition.

Completed baseline work:

- Created MoonBit module metadata and Apache-2.0 license.
- Added project README, proposal draft, competition plan, and acceptance
  checklist.
- Implemented core documentation models: `DocPage`, `DocSite`, `RenderedPage`,
  and `TocItem`.
- Implemented safe HTML escaping, slug generation, line-oriented Markdown
  rendering, heading extraction, table-of-contents generation, sidebar
  navigation, and site rendering.
- Added runnable demo under `cmd/main`.
- Added GitHub Actions CI for check, test, and demo run.
- Added blackbox tests for the first public API surface.

Verification:

- `moon check`
- `moon test`
- `moon run cmd/main`

Repository setup:

- Configured GitHub remote: https://github.com/Estrella-11/moonbit_1
- Configured Gitlink remote: https://gitlink.org.cn/Estrella/moonbit
- Pushed the initial `main` branch to Gitlink.
- Merged Gitlink `master` initialization and pushed the full project to
  `gitlink/master`, so the default branch also displays the project.
- Pushed the full project to GitHub `origin/main`.
- Generated a one-page PDF project proposal at
  `docs/MoonDocKit-项目申报书.pdf`.
- Added a block-level Markdown AST with `MarkdownBlock`, `parse_blocks`,
  `blocks_to_toc`, and `render_blocks`, then kept the public
  `render_markdown` API as a compatibility wrapper.
- Improved block parsing so adjacent paragraph lines fold into one paragraph,
  fenced code blocks keep their language label, and HTML rendering emits
  language-specific code classes.
- Added page-unique heading anchor generation so repeated section titles produce
  stable anchors such as `intro`, `intro-2`, and `intro-3`; TOC and HTML
  rendering now share the same heading extraction path.
- Added front matter parsing with `FrontMatter` and `ParsedDocument`, covering
  page title, order, tags, custom fields, and graceful fallback for unclosed
  metadata blocks.
- Added route planning with `RouteEntry` and `plan_routes`, using front matter
  title/order/tags plus page slugs to generate deterministic navigation paths.
- Added `OutputFile` and `build_site_manifest`, producing deterministic static
  HTML output manifests that a CLI can write to disk later.
- Added `SearchEntry`, `collect_search_entries`, and `build_search_index` to
  generate a JSON search index from page blocks, routes, and tags.
- Added `SiteSummary` and `summarize_site` for demo output and validation.
- Upgraded `cmd/main` so `moon run cmd/main` prints generated output files and
  site statistics instead of a raw HTML page.
- Added example documentation sources under `examples/site` and generated a
  static example site under `dist-example`.
- Added benchmark notes and an acceptance guide for reviewer verification.
- Added release notes and mooncakes.io publishing plan for the 0.1.0
  competition baseline.
- Added `tools/verify_project.py` as a one-shot local verification script for
  required files, proposal PDF, example output, and MoonBit commands.

Next engineering target:

- Expand the block-level AST with inline parsing, source spans, a CLI manifest
  writer, templates, and final publishing notes.
