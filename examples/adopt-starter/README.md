# Adopt MoonDocKit — starter

A copy-paste starting point so a MoonBit project can document itself with
MoonDocKit in **one command**. This kit needs no `.mbti` file: it renders plain
Markdown. Add an API reference later by generating `pkg.generated.mbti` (see
`quick-start.md`).

## Use it

From the MoonDocKit repository root:

```bash
moon run --target js cmd/moondockit \
  --config examples/adopt-starter/moondockit.json --strict
```

Output: `dist-adopt-starter/`.

## Make it yours

- Edit `site/*.md` — your real documentation.
- Edit `moondockit.json` — `title`, `site_url`, `description`, `theme`.
- (Optional) `moon info > pkg.generated.mbti` and set `"api"` in the config to
  get an `api-reference.html` from your package's public symbols.

This starter is the lowest-friction path referenced by
[`docs/adoption-case-study.md`](../adoption-case-study.md) and the real-repo
compatibility showcase in [`docs/adoption-showcase.md`](../adoption-showcase.md).
