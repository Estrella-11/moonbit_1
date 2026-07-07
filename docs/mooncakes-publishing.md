# Mooncakes Publishing

The competition requires final accepted projects to publish to mooncakes.io.
This document records the package metadata and release path.

## Package Metadata

- Package name: `Estrella-11/moondockit`
- Version: `0.1.0`
- License: `Apache-2.0`
- Repository: `https://github.com/Estrella-11/moonbit_1`
- Description: `A MoonBit-first documentation site toolkit for package authors.`

## Pre-Publish Checklist

```bash
moon check
python tools/moon_hard_gate.py all
moon test
python tools/test_cli.py
moon run cmd/main
moon check --target js
moon run --target js cmd/moondockit --source examples/site --api pkg.generated.mbti --output dist-cli-example --title "MoonDocKit CLI Example"
python tools/verify_project.py
moon package
```

Also verify:

- README describes usage and competition fit.
- `README.mbt.md` provides package-level examples for the mooncakes.io page.
- `docs/ecosystem-impact.md` explains ecosystem value and differentiation.
- `docs/acceptance-guide.md` is current.
- `docs/release.md` is current.
- The MoonBit CLI produces 13 files with generated API documentation.
- GitHub and Gitlink are synchronized.
- No generated private credentials or local-only files are included.

The 0.1.0 package dry run succeeds and creates:

```text
_build/publish/Estrella-11-moondockit-0.1.0.zip
```

## Publish Command

The package has been published as `Estrella-11/moondockit`. The publish step
requires a mooncakes.io account:

```bash
moon login
moon publish
```

The current MoonBit CLI also requires credentials for `moon publish --dry-run`.
Use `moon package` as the unauthenticated package-build check.
