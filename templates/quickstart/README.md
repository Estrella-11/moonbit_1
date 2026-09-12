# MoonDocKit Quickstart Template

A copy-ready starting point for publishing a MoonBit package documentation site.
It contains three pages, a config file, and a deployment workflow you can drop
into any repository.

## Contents

```text
templates/quickstart/
  moondockit.json          build configuration
  site/
    overview.md            landing page (order 0)
    quick-start.md         build and publish steps (order 1)
    api-guide.md           front matter and Markdown reference (order 2)
  deploy-docs.yml.example  GitHub Actions workflow for GitHub Pages
  README.md                this file
```

## Use It In Three Steps

1. Copy this directory into your package repository.

   ```bash
   cp -r templates/quickstart docs-template   # or download it from the repo
   ```

2. Edit `site/*.md`. Keep the front matter block at the top of each file:
   `title` sets the navigation label, `order` sorts navigation, and `tags` feed
   the search index.

3. Build the site.

   ```bash
   moon run --target js cmd/moondockit --config moondockit.json --strict
   ```

   Run this from inside the MoonDocKit repository. If your project consumes
   MoonDocKit through mooncakes (`moon add Estrella-11/moondockit`), replace
   `cmd/moondockit` with the CLI package path as exposed in your project.

## What The Build Produces

| File | Purpose |
| --- | --- |
| `index.html` | Root entry for static hosts |
| `overview.html`, `quick-start.html`, `api-guide.html` | One page per source file |
| `search-index.json` | Backs the interactive search page |
| `sitemap.xml`, `robots.txt` | Search-engine artifacts |
| `site-manifest.json` | Machine-readable output inventory |
| `quality-report.json` | Publish-readiness gate result |

Add `--api pkg.generated.mbti` after running `moon info` to generate
`api-reference.html` as well.

## Publish

Rename `deploy-docs.yml.example` to `.github/workflows/deploy-docs.yml`, set
`site_url` in `moondockit.json` to your real domain, and push. The workflow
installs the MoonBit toolchain, builds the site, and publishes the output
directory with GitHub Pages.

## Grow The Site

- Add a file to `site/` — the file name becomes the route.
- Raise `--strict` usage in CI so empty pages and duplicate routes fail early.
- Add `--ai-quality` while writing to get per-page scores and suggestions.

See `docs/adoption-playbook.md` for the full adoption path and troubleshooting
table.
