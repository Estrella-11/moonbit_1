# Acceptance Guide

This guide is the quick verification path for project reviewers.

## Required Commands

```bash
moon check
moon test
moon run cmd/main
moon check --target js
moon run --target js cmd/moondockit --source examples/site --api pkg.generated.mbti --output dist-cli-example --title "MoonDocKit CLI Example"
```

Expected result:

- `moon check` completes successfully.
- `moon test` reports 42 passing tests.
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
- `dist-example/sitemap.xml`
- `dist-example/robots.txt`

## One-Shot Verification

Run:

```bash
python tools/verify_project.py
```

The script checks required files, validates the one-page proposal PDF, rebuilds
both example sites, and runs the MoonBit check/test/demo and JavaScript CLI
commands.

If the local Python environment does not provide `pypdf`, the script prints a
warning and skips strict PDF page-count validation while keeping the rest of the
checks active.

## Competition Checklist

Before final submission, confirm:

- GitHub and Gitlink repositories are synchronized.
- README documents project goal and usage.
- CI covers check, test, and demo run.
- Core functionality has tests.
- The public showcase search returns documentation and API results.
- One-page project proposal PDF exists.
- `docs/final-submission.md` is current.
- mooncakes.io publishing is completed or documented.
