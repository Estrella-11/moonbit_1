# MoonDocKit Examples

The `site` directory contains a small documentation site used for demos and
acceptance checks.

Current pages:

- `quick-start.md`
- `api.md`
- `overview.md`
- `quality.md`
- `deployment.md`
- `changelog.md`

The example uses front matter fields supported by the library:

- `title`
- `order`
- `tags`

Build the source pages through the MoonBit CLI:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-cli-example \
  --title "MoonDocKit CLI Example"
```

This exercises the MoonBit parser, renderer, quality gate, interactive search,
manifest, and the JavaScript backend filesystem adapter end to end.
