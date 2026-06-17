# Ecosystem Impact

MoonDocKit is designed as infrastructure for the MoonBit package ecosystem, not
only as a demonstration site for this repository.

## Ecosystem Problem

MoonBit packages often have three documentation surfaces that drift apart:

- `README.md` for repository visitors;
- handwritten guides and examples for users;
- generated `.mbti` interfaces from `moon info`.

When these surfaces are not connected, package authors spend extra effort
maintaining docs, reviewers have to inspect source files manually, and users do
not get a browsable API reference.

## MoonDocKit Contribution

MoonDocKit joins those surfaces into one repeatable workflow:

```text
Markdown guides + pkg.generated.mbti + project metadata
  -> MoonBit renderer and quality checks
  -> static docs, search index, API reference, sitemap, site manifest
```

The important ecosystem contribution is that the core implementation is
MoonBit-first. Package authors can reuse the library APIs directly, while the
CLI remains a thin filesystem adapter for real projects and CI.

## Value by User Group

| User | Value |
| --- | --- |
| Package authors | Generate browsable guides and API docs from existing repo files |
| New MoonBit users | Read tutorials, API pages, and release notes in one static site |
| Reviewers | Verify outputs through `site-manifest.json`, tests, and acceptance docs |
| Ecosystem maintainers | Encourage repeatable release documentation and clearer package pages |

## Differentiation

MoonDocKit is not trying to be a generic Markdown website framework. The project
is differentiated by:

- `.mbti` API extraction from MoonBit interface files;
- MoonBit data models for pages, routes, metrics, diagnostics, and output files;
- quality gates for publish-readiness, not only HTML rendering;
- generated `site-manifest.json` for review and deployment checks;
- documentation that explains how other MoonBit packages can adopt the tool.

## Adoption Readiness

The project includes materials that make reuse realistic:

- `README.mbt.md` for mooncakes.io package readers;
- `docs/adoption-playbook.md` for downstream package authors;
- `examples/moondockit.json` and `examples/moondockit.schema.json` for
  repeatable configuration;
- `tools/verify_project.py` for acceptance-style verification;
- `dist-cli-example/api-reference.html` as a self-hosted API reference example.

## Award-Relevant Evidence

For competition review, MoonDocKit demonstrates:

- a complete MoonBit implementation rather than a mockup;
- reusable public APIs and generated `.mbti` interface;
- a runnable CLI with validation, strict mode, dry-run mode, and integration
  tests;
- generated public documentation, API reference, search index, sitemap, and
  output manifest;
- open-source readiness through license, release notes, publishing plan, and
  adoption guidance.

This gives the project a clearer ecosystem story than a one-off static site:
it helps future MoonBit packages publish better documentation with less manual
work.
