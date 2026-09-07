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

The example content demonstrates inline code, strong text, emphasis, safe
links, safe autolinks, and safe image syntax.

## Adoption Example

The `adoption-package` directory is a small downstream-package fixture. It
shows how a separate MoonBit package can keep its own guides plus a
`pkg.generated.mbti` interface and build a complete documentation site:

```bash
moon run --target js cmd/moondockit --config examples/adoption-package/moondockit.json --strict
```

The generated output lives in `dist-adoption-example` and gives reviewers a
concrete second-package adoption case.

## AI-Enhanced Adoption Example

Build the adoption package with the full AI suite using the AI config:

```bash
moon run --target js cmd/moondockit \
  --config examples/adoption-package/moondockit-ai.json \
  --ai-doc --ai-quality --ai-summary --ai-xref \
  --ai-coverage --ai-consistency --ai-seo --ai-recommend \
  --ai-tests
```

This generates the same static site as the basic adoption example plus 11 AI
output files in `dist-adoption-ai-example/`, demonstrating that MoonDocKit's
AI suite works with any MoonBit package documentation, not just the built-in
example site.

## AI-Enhanced Example

Build the example site with the full AI suite to generate quality reports,
summaries, cross-references, coverage analysis, consistency checks, SEO
metadata, and content recommendations:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --api pkg.generated.mbti \
  --output dist-ai-example \
  --ai-doc \
  --ai-quality \
  --ai-summary \
  --ai-xref \
  --ai-coverage \
  --ai-consistency \
  --ai-seo \
  --ai-recommend \
  --ai-tests \
  --title "MoonDocKit AI Full"
```

This generates 11 AI-enhanced output files in `dist-ai-example/`:

- `ai-api-reference.html` — Enhanced API reference with complexity and usage analysis
- `ai-quality-report.md` — Per-page quality scores with structure analysis
- `ai-site-quality-report.md` — Site-level quality aggregation
- `ai-site-summary.md` — Content summaries with keywords and audience estimation
- `ai-cross-reference.md` — Page-to-page relationship map
- `ai-coverage-report.md` — API symbol documentation coverage
- `ai-consistency-report.md` — Style and content consistency analysis
- `ai-seo-report.md` — SEO metadata and search optimization
- `ai-recommendations.md` — Learning paths and related content
- `ai-generated-test.mbt` — Test stubs from API symbols
- `ai-overview.html` — AI-enhanced overview page
