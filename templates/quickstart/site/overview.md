---
title: Welcome
order: 0
tags: [overview, start]
---
# Welcome

This is the MoonDocKit starter template. Copy this directory into your own
MoonBit package and you have a documentation site pipeline in three commands.

## What You Get

- A static documentation site with sidebar navigation.
- An interactive search page backed by `search-index.json`.
- `sitemap.xml`, `robots.txt`, and `site-manifest.json` for deployment.
- `quality-report.json` as a machine-readable release gate.
- An optional API reference generated from your package `.mbti` file.

## How The Pipeline Works

```text
your Markdown + moon info output
  -> MoonDocKit
  -> static site + search + quality gate
```

MoonDocKit never writes into your source tree. Every generated file lands in
the output directory, so the build is safe to run in CI on every push.

> Start with three pages. Grow the site by adding files to `site/` — front
> matter `order` controls navigation, and the file name becomes the route.

## Next

Read [Quick Start](quick-start.html) to run your first build.
