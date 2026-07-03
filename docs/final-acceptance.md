# Final Acceptance Evidence

This page collects the evidence a reviewer can use to verify MoonDocKit without
searching across the repository.

## Public Links

- GitHub: https://github.com/Estrella-11/moonbit_1
- Gitlink: https://gitlink.org.cn/Estrella/moonbit
- Public showcase: https://estrella-11.github.io/moonbit_1/
- Generated MoonBit API: https://estrella-11.github.io/moonbit_1/api-reference.html
- mooncakes.io package: `Estrella-11/moondockit`

## Reviewer Path

Start with these files:

- `README.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SUPPORT.md`
- `SECURITY.md`
- `docs/final-submission.md`
- `docs/acceptance-guide.md`
- `docs/release.md`
- `docs/reviewer-scorecard.md`
- `docs/feature-evidence-map.md`
- `docs/reviewer-faq.md`
- `docs/award-sprint.md`
- `docs/architecture.md`
- `docs/accessibility-notes.md`
- `docs/security-model.md`
- `docs/maintenance-plan.md`
- `docs/change-impact-matrix.md`
- `docs/ecosystem-impact.md`
- `docs/adoption-playbook.md`
- `docs/demo-script.md`
- `docs/deployment-runbook.md`
- `docs/mooncakes-publishing.md`
- `docs/windows-toolchain-troubleshooting.md`

Then inspect these generated artifacts:

- `dist-cli-example/api-reference.html`
- `dist-cli-example/quality-report.json`
- `dist-cli-example/search-index.json`
- `dist-cli-example/site-manifest.json`
- `dist-adoption-example/api-reference.html`
- `dist-adoption-example/quality-report.json`
- `dist-adoption-example/site-manifest.json`
- `dist-example/quality-report.json`
- `dist-example/site-manifest.json`

## Verification Commands

```bash
moon check
moon check --target js
moon test
python tools/test_cli.py
python tools/verify_project.py
python tools/benchmark_cli.py --pages 10,100 --rounds 2
```

Expected evidence:

- `moon test` reports 50 passing tests.
- `python tools/test_cli.py` reports 10 compiled CLI integration scenarios.
- `python tools/verify_project.py` prints `Project verification passed.`
- The CLI writes 13 files for the example site with generated API docs.
- `site-manifest.json` lists generated paths, file kinds, and byte counts.
- `quality-report.json` records the release-gate score, checks, metrics, and
  diagnostics in a machine-readable form.

If local Windows policy blocks `moon.exe`, use
`docs/windows-toolchain-troubleshooting.md` to distinguish OS policy failures
from project check failures.

## Implemented Scope

- MoonBit library models for pages, routes, themes, validation, metrics, and
  generated output files.
- Markdown block parsing, inline rendering, table of contents, unique anchors,
  and front matter.
- Static site generation with HTML pages, root redirect, search index, sitemap,
  robots policy, and machine-readable output manifest.
- `.mbti` API extraction with declaration summaries, function arity, return
  types, per-symbol anchors, and grouped symbol index links.
- JavaScript-targeted CLI with config files, metadata options, strict mode,
  dry-run mode, diagnostics, and filesystem-level integration tests.

## Release Status

The mooncakes.io package has been published as `Estrella-11/moondockit`.
The repository contains `README.mbt.md`, release notes, and
`docs/mooncakes-publishing.md` for reviewers who want to inspect the package
metadata and release flow.
