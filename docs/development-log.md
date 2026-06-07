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

Next engineering target:

- Replace the line-oriented renderer with a block-level AST so later features
  such as front matter, duplicate heading anchors, route planning, search index
  generation, and templates can be built on a cleaner core.
