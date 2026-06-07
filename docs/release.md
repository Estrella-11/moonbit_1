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
- JSON search index generation.
- Site summary metadata for demo and validation.
- Site validation diagnostics with severity, code, message, and optional page
  metadata.
- Theme configuration APIs for generated page colors and layout widths.
- Runnable demo package with `moon run cmd/main`.
- Example documentation site and generated HTML outputs.

### Verification

```bash
moon check
moon test
moon run cmd/main
python tools/build_example_site.py
```

Expected current result:

- `moon test` passes 17 tests.
- The example site writes 4 files to `dist-example`.

### Known Scope Limits

- Markdown support is intentionally scoped to the first competition milestone.
- Inline Markdown nodes are not implemented yet.
- The current filesystem writer is provided as a Python example script; the
  MoonBit package itself returns an output manifest without writing files.
- mooncakes.io publishing is documented and will be completed when account
  access is available.
