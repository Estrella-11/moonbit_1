# Acceptance Guide

This guide is the quick verification path for project reviewers.

## Required Commands

```bash
moon check
moon test
moon run cmd/main
```

Expected result:

- `moon check` completes successfully.
- `moon test` reports all tests passing.
- `moon run cmd/main` prints a MoonDocKit demo summary with generated files.

## Example Site

Build the example static site:

```bash
python tools/build_example_site.py
```

Expected generated files:

- `dist-example/quick-start.html`
- `dist-example/api.html`
- `dist-example/changelog.html`
- `dist-example/search-index.json`

## One-Shot Verification

Run:

```bash
python tools/verify_project.py
```

The script checks required files, validates the one-page proposal PDF, rebuilds
the example site, and runs the MoonBit check/test/demo commands.

## Competition Checklist

Before final submission, confirm:

- GitHub and Gitlink repositories are synchronized.
- README documents project goal and usage.
- CI covers check, test, and demo run.
- Core functionality has tests.
- One-page project proposal PDF exists.
- mooncakes.io publishing is completed or documented.
