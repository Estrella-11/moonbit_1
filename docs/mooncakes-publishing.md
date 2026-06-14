# Mooncakes Publishing Plan

The competition requires final accepted projects to publish to mooncakes.io.
This document records the intended release path.

## Package Metadata

- Package name: `moonbit-community/moondockit`
- Version: `0.1.0`
- License: `Apache-2.0`
- Repository: `https://github.com/Estrella-11/moonbit_1`
- Description: `A MoonBit-first documentation site toolkit for package authors.`

## Pre-Publish Checklist

```bash
moon check
moon test
moon run cmd/main
moon check --target js
moon run --target js cmd/moondockit --source examples/site --output dist-cli-example --title "MoonDocKit CLI Example"
python tools/verify_project.py
moon package
```

Also verify:

- README describes usage and competition fit.
- `docs/acceptance-guide.md` is current.
- `docs/release.md` is current.
- The MoonBit CLI produces the seven expected static-site files.
- GitHub and Gitlink are synchronized.
- No generated private credentials or local-only files are included.

The 0.1.0 package dry run succeeds and creates:

```text
_build/publish/moonbit-community-moondockit-0.1.0.zip
```

## Publish Command

The final publish step requires a mooncakes.io account:

```bash
moon login
moon publish
```

The current MoonBit CLI also requires credentials for `moon publish --dry-run`.
Use `moon package` as the unauthenticated package-build check.

If publishing is not possible before a checkpoint because account approval is
pending, include this document and a screenshot/log of `moon package` in the
submission material, then publish as soon as account access is ready.
