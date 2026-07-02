# Maintenance Plan

This plan describes how MoonDocKit should stay useful after the competition
baseline.

## Maintenance Goals

- Keep the public MoonBit API small, documented, and stable.
- Preserve deterministic generated output so sites can be reviewed and tested.
- Keep the CLI thin and move reusable behavior into the MoonBit library.
- Prefer explainable diagnostics over silent rendering surprises.
- Maintain release evidence that reviewers and package users can reproduce.

## Versioning Policy

MoonDocKit follows a conservative pre-1.0 policy:

- patch releases fix bugs, diagnostics, docs, examples, and packaging;
- minor releases may add Markdown nodes, configuration fields, or output files;
- breaking API changes must be listed in `docs/release.md` and reflected in
  `README.mbt.md`;
- generated `.mbti` diffs should be reviewed before every release.

## Change Workflow

Every meaningful change should answer four questions:

1. Does it change the public MoonBit API?
2. Does it change generated HTML, JSON, sitemap, robots, or manifest output?
3. Does it affect CLI behavior or exit codes?
4. Does it need an example-site or acceptance-material update?

If the answer is yes, update tests and the relevant docs in the same change.

Use `docs/change-impact-matrix.md` to choose the required checks and evidence
updates for each change area.

## Required Checks

Before a release or final acceptance update, run:

```bash
moon info
moon fmt
moon check
moon check --target js
moon test
python tools/test_cli.py
python tools/benchmark_cli.py --pages 10,100 --rounds 2
python tools/verify_project.py
moon package
```

Review `pkg.generated.mbti` and `cmd/moondockit/pkg.generated.mbti` after
`moon info` to confirm that public API changes are intentional.

## Issue Triage

| Issue Type | Priority | Expected Response |
| --- | --- | --- |
| Unsafe HTML or link escaping | High | Fix before the next release |
| CLI crash or wrong exit status | High | Add an integration test and patch |
| Broken generated API reference | High | Add `.mbti` fixture coverage |
| Missing or confusing diagnostics | Medium | Improve validation message and docs |
| New Markdown syntax request | Medium | Add only when it supports package docs |
| Theme or layout refinement | Low | Keep defaults simple and accessible |

## Compatibility Boundaries

MoonDocKit intentionally supports a focused Markdown subset for package
documentation. Compatibility promises should be made around:

- safe output for supported syntax;
- stable route and anchor generation;
- predictable manifest entries;
- documented CLI flags and config fields;
- generated API references from MoonBit `.mbti` files.

Unsupported syntax should remain safe text until a tested implementation is
added.

## Release Evidence

Each release should keep these files current:

- `README.md`
- `README.mbt.md`
- `docs/release.md`
- `docs/acceptance-guide.md`
- `docs/final-acceptance.md`
- `docs/reviewer-scorecard.md`
- `docs/change-impact-matrix.md`
- `docs/ecosystem-impact.md`
- `docs/windows-toolchain-troubleshooting.md`
- `dist-cli-example/site-manifest.json`
- `dist-cli-example/api-reference.html`

This keeps the repository useful for both users and competition reviewers.

## Next Engineering Priorities

1. Add source span metadata for parsed blocks and inline nodes.
2. Add more API-reference fixtures from real MoonBit packages.
3. Add additional theme presets for package, tutorial, and reference sites.
4. Add richer Markdown nodes only when they improve package documentation.
5. Keep the published mooncakes.io package metadata aligned with repository
   releases.
