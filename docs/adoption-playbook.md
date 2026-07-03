# Adoption Playbook

This playbook shows how another MoonBit package can adopt MoonDocKit without
copying project-specific assumptions from this repository.

## Target User

MoonDocKit is intended for package authors who already keep Markdown guides,
release notes, or API notes beside their MoonBit source code and want a
repeatable static documentation site.

Good early adopters include:

- libraries that already run `moon info` and publish `.mbti` interfaces;
- packages with `README.md`, examples, and release notes;
- teaching or tutorial repositories that need a browsable site;
- competition or community projects that need clear acceptance evidence.

## Minimal Adoption Path

1. Keep source documentation in a directory such as `docs/site` or
   `examples/site`.
2. Add front matter to each page:

```markdown
---
title: Quick Start
order: 10
tags: guide,setup
---

# Quick Start

Install the package and run the first example.
```

3. Generate the MoonBit public interface:

```bash
moon info
```

4. Build a static site with the CLI:

```bash
moon run --target js cmd/moondockit \
  --source docs/site \
  --api pkg.generated.mbti \
  --output dist-docs \
  --title "My MoonBit Package" \
  --site-url https://example.com/my-package
```

5. Publish `dist-docs` with GitHub Pages, Gitlink Pages, or any static host.

## Recommended Repository Layout

```text
my-package/
  moon.mod
  moon.pkg
  README.md
  README.mbt.md
  pkg.generated.mbti
  docs/
    site/
      quick-start.md
      api.md
      changelog.md
  dist-docs/
```

The source directory is versioned. The generated output may be versioned for
review-heavy workflows or produced only in CI for release workflows.

## Repository Example

This repository includes a small downstream-package fixture at
`examples/adoption-package`. It documents a sample statistics package from
three guide pages plus `examples/adoption-package/pkg.generated.mbti`:

```bash
moon run --target js cmd/moondockit --config examples/adoption-package/moondockit.json --strict
```

The generated result is checked into `dist-adoption-example` so reviewers can
inspect a concrete adoption case without creating another repository.

## Config File

For repeatable builds, keep a JSON config in the repository:

```json
{
  "source": "docs/site",
  "output": "dist-docs",
  "title": "My MoonBit Package",
  "site_url": "https://example.com/my-package",
  "api": "pkg.generated.mbti",
  "language": "en",
  "description": "Documentation for a MoonBit package",
  "footer": "Built with `MoonDocKit`"
}
```

Then run:

```bash
moon run --target js cmd/moondockit --config docs/moondockit.json --strict
```

## CI Gate

A practical CI job should run:

```bash
moon check
moon test
moon info
moon run --target js cmd/moondockit --config docs/moondockit.json --strict
```

Use `--strict` for release branches so empty pages, empty titles, duplicate
routes, and failed quality gates stop the build before publishing.

## Reviewer Evidence

When using MoonDocKit for a competition, package release, or open-source review,
link these files from the repository README:

- generated site home page;
- generated API reference page;
- `site-manifest.json`;
- source Markdown directory;
- CI workflow or verification script;
- release notes and publishing instructions.

This makes the documentation workflow inspectable instead of only visually
presentable.

## Migration Notes

- Existing Markdown does not need to be rewritten all at once. Start with
  headings, paragraphs, lists, fenced code blocks, links, and code spans.
- Unsupported Markdown syntax is treated conservatively as text.
- Prefer stable, ASCII page slugs when a site will be published under a public
  URL.
- Use front matter `order` values to keep navigation deterministic.
- Keep API documentation generated from `pkg.generated.mbti` so published docs
  follow the MoonBit package interface.

## Troubleshooting

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| Missing API page | `--api` was omitted or points to the wrong file | Run `moon info`, then pass `--api pkg.generated.mbti` |
| Duplicate output route | Two pages resolve to the same slug | Rename one source file or add a distinct title |
| Empty navigation title | Missing page title and heading | Add front matter `title` or a top-level heading |
| CI passes but docs are stale | The generated output was not rebuilt | Add the MoonDocKit command after `moon info` |
| Published site has wrong canonical URLs | `site_url` is missing or points to another host | Set `site_url` in the config file |

## Success Criteria

An adopted package is in good shape when:

- docs can be rebuilt from a single command;
- the generated API page reflects the current `.mbti` interface;
- the search index contains guide pages and API entries;
- `site-manifest.json` lists all published outputs;
- CI or a local verification script catches broken documentation before release.
