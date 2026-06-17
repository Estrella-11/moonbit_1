# Benchmark Notes

MoonDocKit benchmarks focus on deterministic growth and easy regression checks
rather than unsupported performance claims.

## Current Workload

The current example site contains:

- 6 source Markdown pages
- 11 generated output files in the Python reference build
- 12 generated output files in the MoonBit CLI build with API documentation
- 1 search index
- 1 site manifest
- 1 sitemap
- 1 robots.txt

Command:

```bash
python tools/build_example_site.py
moon check
moon test
python tools/test_cli.py
python tools/benchmark_cli.py --write docs/benchmark-results.json
moon run cmd/main
moon run --target js cmd/moondockit --source examples/site --api pkg.generated.mbti --output dist-cli-example
```

## Current Verification Result

As of the current baseline:

- `moon check` passes
- `moon test` passes with 45 tests
- `python tools/test_cli.py` passes 9 compiled CLI integration scenarios
- `moon coverage analyze` reports 21 uncovered lines across the reusable
  library and executable entry points
- `moon run cmd/main` prints generated file counts and validation status
- The MoonBit JavaScript CLI combines 6 Markdown pages and the package `.mbti`
  interface into 12 output files
- `tools/build_example_site.py` writes 11 files to `dist-example`
- The generated example site includes inline code, strong text, safe links,
  description metadata, footer content, sitemap output, and robots.txt output
- The MoonBit-generated site exposes client-side search without requiring a
  server or external search service

## CLI Scale Benchmark

`tools/benchmark_cli.py` creates deterministic synthetic documentation corpora,
builds the release JavaScript CLI, and runs it against 10, 100, and 500 page
sites. It records median, minimum, and maximum wall-clock time across repeated runs,
output file count, output byte size, and search-index entry count.

The benchmark is intentionally framed as a regression signal rather than a
hard performance claim: different machines, Node.js versions, and MoonBit build
modes will produce different absolute timings. A healthy run should preserve
these invariants:

- generated file count is `page_count + 5`;
- search entry count equals `page_count`;
- every generated corpus passes the quality gate;
- no external service or browser runtime is required.

The quality gate evaluates readability per page rather than by total site
reading time, so large collections of individually readable pages are accepted
while a single oversized page is still flagged for splitting.

Current release-build benchmark results are recorded in
`docs/benchmark-results.json`. On the Windows 11 validation machine used for
this checkpoint, the compiled release CLI generated:

- 10 pages in 98.81 ms median time, producing 15 files;
- 100 pages in 436.93 ms median time, producing 105 files;
- 500 pages in 8005.9 ms median time, producing 505 files.

## Future Benchmark Targets

- Parse and render 100 small documentation pages.
- Parse and render 1 large API reference page.
- Compare output manifest size and search index size.
- Track parser regressions with fixed example corpora.
