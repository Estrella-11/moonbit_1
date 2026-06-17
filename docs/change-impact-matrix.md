# Change Impact Matrix

Use this matrix before making or reviewing a MoonDocKit change. It helps keep
code, generated evidence, tests, and competition materials aligned.

## Matrix

| Change Area | Examples | Required Checks | Usually Update |
| --- | --- | --- | --- |
| Public MoonBit API | New public function, struct, enum, or field | `moon info`, `moon check`, `moon test` | `pkg.generated.mbti`, `README.mbt.md`, `docs/release.md` |
| Markdown parser | New block or inline syntax, front matter behavior | `moon test`, `python tools/test_cli.py` | `moondockit_test.mbt`, `README.md`, `docs/acceptance-checklist.md` |
| HTML renderer | Page shell, navigation, escaping, anchors, search UI | `moon test`, generated site inspection | `dist-cli-example`, `docs/demo-script.md`, `docs/release.md` |
| API reference generator | `.mbti` parsing, symbol grouping, signatures | `moon info`, `moon test`, CLI build with `--api` | `pkg.generated.mbti`, `dist-cli-example/api-reference.html` |
| CLI behavior | Flags, config, exit codes, diagnostics | `moon check --target js`, `python tools/test_cli.py` | `docs/configuration.md`, `examples/moondockit.schema.json` |
| Quality gate or validation | New diagnostics, scoring rules, strict mode | `moon test`, `python tools/test_cli.py`, `python tools/benchmark_cli.py` | `docs/acceptance-guide.md`, `docs/benchmark-notes.md` |
| Generated metadata | sitemap, robots, search index, `site-manifest.json` | CLI build, `python tools/verify_project.py` | `dist-cli-example/site-manifest.json`, `docs/final-acceptance.md` |
| Release or review docs | Acceptance notes, FAQ, scorecard, runbooks | `python -m py_compile tools/verify_project.py` | `README.md`, `docs/final-submission.md`, `docs/reviewer-scorecard.md` |
| Packaging | mooncakes metadata, package README, license | `moon package` | `README.mbt.md`, `docs/mooncakes-publishing.md`, `docs/release.md` |

## Review Questions

Before committing, check:

1. Did the change affect public API? If yes, review `.mbti` diffs.
2. Did generated output change? If yes, rebuild examples and update evidence.
3. Did command-line behavior change? If yes, add or update CLI integration
   coverage.
4. Did test counts or acceptance claims change? If yes, update all reviewer
   materials consistently.
5. Could a Windows toolchain policy issue hide the result? If yes, reference
   `docs/windows-toolchain-troubleshooting.md`.

## Minimal Safe Paths

For a private renderer-only change:

```bash
moon fmt
moon test
python tools/test_cli.py
```

For a public API or package release change:

```bash
moon info
moon fmt
moon check
moon check --target js
moon test
python tools/test_cli.py
python tools/verify_project.py
moon package
```

For a documentation-only change:

```bash
python -m py_compile tools/verify_project.py tools/test_cli.py
git diff --check
```

Documentation-only changes do not replace MoonBit checks for release builds,
but they are enough to catch local formatting and script syntax mistakes before
review.
