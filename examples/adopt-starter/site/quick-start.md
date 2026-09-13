---
order: 2
tags: [guide]
---

# Quick Start

Build this starter from the MoonDocKit repository root:

```bash
moon run --target js cmd/moondockit \
  --config examples/adopt-starter/moondockit.json --strict
```

The `--strict` flag fails the build on any quality-gate problem before a single
file is written. Output lands in `dist-adopt-starter/` — open `index.html` or
serve the folder with any static host.

## Add an API reference (optional)

If your project ships a MoonBit package, generate its interface file and point
the config at it:

```bash
moon info > pkg.generated.mbti
```

```json
{
  "api": "pkg.generated.mbti"
}
```

MoonDocKit merges the `.mbti` symbols into a browsable `api-reference.html`
with anchors and a grouped index — no manual copying of signatures.
