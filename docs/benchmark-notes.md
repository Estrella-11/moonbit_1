# Benchmark Notes

MoonDocKit benchmarks focus on deterministic growth and easy regression checks
rather than unsupported performance claims.

## Current Workload

The current example site contains:

- 6 source Markdown pages
- 10 generated output files in the Python reference build
- 11 generated output files in the MoonBit CLI build with API documentation
- 1 search index
- 1 sitemap
- 1 robots.txt

Command:

```bash
python tools/build_example_site.py
moon check
moon test
moon run cmd/main
moon run --target js cmd/moondockit --source examples/site --api pkg.generated.mbti --output dist-cli-example
```

## Current Verification Result

As of the current baseline:

- `moon check` passes
- `moon test` passes with 42 tests
- `moon coverage analyze` reports 21 uncovered lines across the reusable
  library and executable entry points
- `moon run cmd/main` prints generated file counts and validation status
- The MoonBit JavaScript CLI combines 6 Markdown pages and the package `.mbti`
  interface into 11 output files
- `tools/build_example_site.py` writes 10 files to `dist-example`
- The generated example site includes inline code, strong text, safe links,
  description metadata, footer content, sitemap output, and robots.txt output
- The MoonBit-generated site exposes client-side search without requiring a
  server or external search service

## Future Benchmark Targets

- Parse and render 100 small documentation pages.
- Parse and render 1 large API reference page.
- Compare output manifest size and search index size.
- Track parser regressions with fixed example corpora.
