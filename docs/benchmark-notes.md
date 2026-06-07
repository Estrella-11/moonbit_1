# Benchmark Notes

MoonDocKit is still in the early competition baseline stage, so benchmarks are
focused on deterministic growth and easy regression checks rather than final
performance claims.

## Current Workload

The current example site contains:

- 3 source Markdown pages
- 4 generated output files
- 1 search index

Command:

```bash
python tools/build_example_site.py
moon check
moon test
moon run cmd/main
```

## Current Verification Result

As of the current baseline:

- `moon check` passes
- `moon test` passes with 14 tests
- `moon run cmd/main` prints generated file counts
- `tools/build_example_site.py` writes 4 files to `dist-example`

## Future Benchmark Targets

- Parse and render 100 small documentation pages.
- Parse and render 1 large API reference page.
- Compare output manifest size and search index size.
- Track parser regressions with fixed example corpora.
