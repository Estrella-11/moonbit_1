# Contributing to MoonDocKit

MoonDocKit is a MoonBit-first documentation toolkit. Contributions should keep
the project reusable for package authors and easy for reviewers to verify.

## Good First Contributions

- Improve examples in `examples/site`.
- Add focused Markdown renderer tests in `moondockit_test.mbt`.
- Improve diagnostics, documentation, or release evidence.
- Add `.mbti` API reference fixtures from real MoonBit packages.
- Refine generated site accessibility and static output metadata.

## Development Setup

Install the MoonBit toolchain, then run:

```bash
moon info
moon fmt
moon check
moon check --target js
moon test
python tools/test_cli.py
python tools/benchmark_cli.py --pages 10,100 --rounds 2
python tools/verify_project.py
```

On Windows, if `moon.exe` is blocked by Device Guard or an organization policy,
see `docs/windows-toolchain-troubleshooting.md`.

## Change Checklist

Before opening a pull request or preparing a release commit:

- Use `docs/change-impact-matrix.md` to choose the right checks.
- Update `pkg.generated.mbti` if the public MoonBit API changed.
- Add or update tests for behavior changes.
- Rebuild generated examples when rendered output changes.
- Update `docs/final-acceptance.md` when reviewer evidence changes.
- Keep generated credentials, local caches, and `_build` outputs out of commits.

## Coding Guidelines

- Keep reusable behavior in the MoonBit library.
- Keep filesystem access in CLI packages.
- Prefer deterministic output manifests over direct writes in core code.
- Escape rendered text and route all links/images through the documented safety
  policy.
- Keep unsupported Markdown syntax safe as text until it has tests.

## Pull Request Notes

Describe:

- what changed;
- what checks were run;
- whether public API or generated output changed;
- which reviewer evidence files were updated.

Small, focused changes are easier to review and keep the competition evidence
clear.
