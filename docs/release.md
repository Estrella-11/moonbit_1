# Release Notes

## 0.1.0 Competition Baseline

MoonDocKit 0.1.0 is the first competition baseline release.

### Highlights

- Block-level Markdown AST for headings, paragraphs, lists, block quotes and
  fenced code blocks.
- Front matter parsing for title, order, tags and custom fields.
- Page-unique heading anchors and TOC generation.
- Multi-page route planning.
- Static output manifest generation.
- Machine-readable `site-manifest.json` output for generated file metadata.
- JSON search index generation and built-in interactive static search.
- Site summary metadata for demo and validation.
- Site validation diagnostics with severity, code, message, and optional page
  metadata.
- Theme configuration APIs for generated page colors and layout widths.
- End-to-end MoonBit CLI for Markdown directory input and static site output.
- CLI options for page language, metadata description, footer content, public
  site URL, and generated `.mbti` API input.
- JSON config-file support with a documented example and schema.
- Non-zero compiled Node.js CLI exit status for invalid arguments and failed
  quality gates.
- CLI validation diagnostics are printed on warning-level successful builds,
  while `--strict` fails on warnings before writing output.
- `--dry-run` CLI mode reports planned output files and byte counts without
  writing an output directory.
- Responsive generated pages with active and accessible navigation.
- Root `index.html` entry point for static hosting.
- `.mbti` public API extraction for functions, structs, enums, and traits.
- API reference summaries with declaration counts, function arity, and return
  type extraction from MoonBit signatures.
- Stable per-symbol API anchors for deep links into generated declarations.
- Grouped API symbol index links for faster large-reference navigation.
- Package-focused mooncakes.io README with library and API-generation examples.
- Runnable demo package with `moon run cmd/main`.
- Example documentation site and generated HTML outputs.
- Expanded showcase content covering project value, quality gates, deployment,
  library usage, and release history.
- Cross-platform compiled CLI integration tests for successful generation and
  expected failure paths.

### Verification

```bash
moon check
moon test
python tools/test_cli.py
moon run cmd/main
moon check --target js
moon run --target js cmd/moondockit --source examples/site --api pkg.generated.mbti --output dist-cli-example
python tools/build_example_site.py
```

Expected current result:

- `moon test` passes 45 tests.
- The compiled CLI passes 9 integration scenarios.
- The MoonBit CLI writes 12 files when generated API documentation is enabled.

### Known Scope Limits

- Markdown support is intentionally scoped to the first competition milestone.
- The current inline renderer intentionally supports code spans, strong text,
  and safe links rather than the complete CommonMark specification.
- The MoonBit CLI filesystem adapter currently targets Node.js through the
  JavaScript backend; the reusable library remains backend-neutral.
- mooncakes.io publishing is documented and will be completed when account
  access is available.
