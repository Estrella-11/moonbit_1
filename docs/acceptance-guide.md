# Acceptance Guide

This guide is the quick verification path for project reviewers.

## Required Commands

```bash
moon check
moon test
python tools/test_cli.py
python tools/benchmark_cli.py --pages 10,100 --rounds 2
moon run cmd/main
moon check --target js
moon run --target js cmd/moondockit --source examples/site --api pkg.generated.mbti --output dist-cli-example --title "MoonDocKit CLI Example"
```

Expected result:

- `moon check` completes successfully.
- `moon test` reports 47 passing tests.
- `python tools/test_cli.py` passes nine compiled CLI integration scenarios.
- `python tools/benchmark_cli.py --pages 10,100 --rounds 2` records a small
  reproducible scale check for the compiled CLI.
- `moon check --target js` verifies the Node.js CLI target.
- `moon run cmd/main` prints a MoonDocKit demo summary with generated files,
  site statistics, and validation diagnostics.
- The MoonBit CLI writes a complete static site to `dist-cli-example`.
- `api-reference.html` documents the package's generated MoonBit interface.

## Example Site

Build the example static site:

```bash
python tools/build_example_site.py
```

Expected generated files:

- `dist-example/index.html`
- `dist-example/overview.html`
- `dist-example/quick-start.html`
- `dist-example/api.html`
- `dist-example/quality.html`
- `dist-example/deployment.html`
- `dist-example/changelog.html`
- `dist-example/search-index.json`
- `dist-example/site-manifest.json`
- `dist-example/sitemap.xml`
- `dist-example/robots.txt`
- `examples/moondockit.json`
- `examples/moondockit.schema.json`

## One-Shot Verification

Run:

```bash
python tools/verify_project.py
```

The script checks required files, validates the one-page proposal PDF, rebuilds
both example sites, runs the nine CLI integration scenarios, and executes the
MoonBit check/test/demo and JavaScript CLI commands.

If the local Python environment does not provide `pypdf`, the script prints a
warning and skips strict PDF page-count validation while keeping the rest of the
checks active.

## Competition Checklist

Before final submission, confirm:

- GitHub and Gitlink repositories are synchronized.
- README documents project goal and usage.
- Configuration guide and example config are current.
- Adoption playbook explains how another MoonBit package can reuse the tool.
- CI covers check, test, and demo run.
- Core functionality has tests.
- The public showcase search returns documentation and API results.
- One-page project proposal PDF exists.
- `docs/final-submission.md` is current.
- `docs/reviewer-faq.md` answers likely defense questions.
- `docs/maintenance-plan.md` documents post-competition maintenance.
- mooncakes.io publishing is completed or documented.
