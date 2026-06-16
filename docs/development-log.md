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
  `docs/MoonDocKit-项目申报书-附录二模板版.pdf`.
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
- Added site validation diagnostics with machine-readable severity, code,
  message, and optional page metadata; the demo now reports diagnostic counts
  before listing generated files.
- Added `SiteTheme`, `default_theme`, and themed render/manifest APIs so
  generated documentation sites can customize colors, sidebar width, and
  content width without replacing the renderer.
- Added final submission notes and made the one-shot verification script usable
  even when the local Python environment does not have optional PDF tooling.
- After passing declaration review, added inline Markdown rendering for code
  spans, strong text, and safe links, including tests for unsafe link
  sanitization.
- Added `SiteOptions`, `default_site_options`, and template-aware render and
  manifest APIs for generated page language, description metadata, and footer
  content.
- Upgraded the generated example site to demonstrate inline code, strong text,
  safe links, description metadata, and footer output, keeping `dist-example`
  aligned with current renderer capabilities.
- Added XML sitemap generation to the MoonBit manifest and Python example site
  builder, so generated sites now include HTML pages, search index, and
  sitemap output.
- Added build report APIs for generated manifest inspection, including file
  counts, output kind counts, per-file byte counts, and total output bytes.
- Added robots.txt generation to the MoonBit manifest and Python example site
  builder, pairing the generated sitemap with crawler guidance for static docs.
- Added canonical link and Open Graph metadata generation through `SiteOptions`,
  and updated the example site builder to emit the same metadata.
- Added document and site metrics for headings, code blocks, word counts, and
  estimated reading time; the demo now reports content metrics alongside build
  output information.
- Added quality gate evaluation for publish-readiness checks, combining
  validation, content metrics, output manifest shape, and readability scoring.
- Added an end-to-end MoonBit CLI using the JavaScript backend: it reads a
  Markdown directory, runs the quality gate, builds the site manifest, and
  writes the generated static site through a small Node.js filesystem adapter.
- Added JavaScript target and CLI smoke checks to CI and the one-shot
  verification script.
- Measured the post-CLI coverage baseline: `moon coverage analyze` reports 39
  uncovered lines, primarily defensive branches and executable entry points.
- Added a responsive documentation shell with active navigation, mobile
  layout, accessible navigation labels, and reduced-motion support.
- Expanded blackbox coverage from 29 to 37 tests and reduced uncovered lines
  from 39 to 21 by exercising malformed Markdown, front matter, escaping,
  validation, theme fallbacks, and generated navigation.
- Added a generated root `index.html` for static hosting, bringing the suite to
  38 tests and reducing the current uncovered baseline to 20 lines.
- Verified `moon package` produces the 0.1.0 publication archive.
- Added an official GitHub Pages artifact workflow and a 90-second reviewer
  demonstration script.
- Added `.mbti` public-interface parsing and API reference page generation for
  functions, structs, enums, and traits, with optional CLI integration.
- Enabled self-hosting: CI, verification, and the public showcase now generate
  MoonDocKit's own 64-declaration API reference from `pkg.generated.mbti`.
- Hardened showcase deployment with explicit API artifact checks and an Actions
  summary that lists every uploaded site file.
- Confirmed the public GitHub Pages showcase displays the self-generated
  64-declaration MoonBit API reference.
- Added an interactive static search interface backed by the generated search
  index, using safe DOM construction without injecting result HTML.
- Expanded the showcase from three to six source pages with dedicated project
  overview, quality-gate, and deployment documentation.
- Expanded the blackbox suite to 42 tests and kept the measured uncovered
  baseline at 21 lines.
- Exposed language, description, footer, site URL, and `.mbti` inputs through
  the CLI, and added non-zero process exit codes to the compiled Node.js output
  for argument and quality failures.
- Added a cross-platform compiled CLI integration suite covering a real
  two-page build with generated API documentation, invalid arguments, an empty
  site, and a missing source directory.
- Hardened CLI input validation with friendly source, API file, and output path
  diagnostics before filesystem reads and writes.
- Added JSON config-file support for repeatable CLI builds, with command-line
  options overriding config values and integration coverage for both paths.
- Added a configuration guide and JSON schema so package authors can copy the
  example config and understand every supported field.
- Added a deterministic CLI scale benchmark script and adjusted the quality
  gate so large multi-page sites are evaluated by per-page readability instead
  of total site reading time.
- Expanded the blackbox suite to 44 tests and recorded release-build CLI scale
  results for 10, 100, and 500 page synthetic documentation sites.

Next engineering target:

- Publish to mooncakes.io, gather external usage evidence, harden CLI failure
  behavior, and reduce uncovered defensive branches.
