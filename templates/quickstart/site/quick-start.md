---
title: Quick Start
order: 1
tags: [guide, cli]
---
# Quick Start

Three commands take you from this template to a published site.

## 1. Describe the build

Edit `moondockit.json`:

```json
{
  "source": "site",
  "output": "dist",
  "title": "My Package Docs",
  "site_url": "https://example.com/my-package",
  "language": "en",
  "description": "Documentation for my MoonBit package",
  "footer": "Built with MoonDocKit"
}
```

Every field is optional on the command line. Put values in the config file when
you want repeatable builds, and pass CLI flags when you want to override them.

## 2. Build

```bash
moon run --target js cmd/moondockit --config moondockit.json
```

Add `--strict` in CI to fail on validation warnings before anything is written.
Add `--dry-run` to see the planned output files without writing them.

## 3. Publish

Upload the output directory to any static host. `index.html` is generated at
the root, so GitHub Pages, Cloudflare Pages, and object storage all work
without extra configuration.

## Add Your API Reference

Generate the interface file, then point the build at it:

```bash
moon info
moon run --target js cmd/moondockit \
  --config moondockit.json \
  --api pkg.generated.mbti
```

The generated `api-reference.html` lists public functions, structs, enums, and
traits with per-symbol anchors and a grouped index.

## Useful Flags

| Flag | Purpose |
| --- | --- |
| `--strict` | Fail on validation warnings before writing output |
| `--dry-run` | Report planned files without writing them |
| `--ai-quality` | Write per-page and site-level quality reports |
| `--ai-summary` | Write keyword, audience, and summary reports |
| `--ai-doc` | Generate AI-enhanced API documentation |
