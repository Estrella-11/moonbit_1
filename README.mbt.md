# MoonDocKit

MoonDocKit is a MoonBit-first toolkit for turning package guides and generated
interfaces into deployable static documentation sites.

**Try it without installing anything:** the real renderer, compiled from this
MoonBit source to JavaScript, runs in the browser at
<https://estrella-11.github.io/moonbit_1/playground/>. Type Markdown on the
left, see the generated page on the right, with live quality metrics.

## Library API

Create pages and build a deterministic output manifest:

```mbt nocheck
///|
let guide : @moondockit.DocPage = {
  title: "Quick Start",
  slug: "quick-start",
  source: "# Quick Start\n\nBuild MoonBit documentation.",
}

///|
let site : @moondockit.DocSite = { title: "Package Docs", pages: [guide], }

///|
let files = @moondockit.build_site_manifest(site)
```

The manifest contains a root page, rendered HTML pages, a JSON search index,
an XML sitemap, and robots.txt without performing filesystem access.

## MoonBit API Documentation

Run `moon info`, then convert the generated interface into a documentation
page:

```mbt nocheck
///|
let api_page = @moondockit.mbti_to_page(interface_source)
```

`parse_mbti` extracts public functions, structs, enums, and traits. The bundled
JavaScript-targeted CLI accepts `--api pkg.generated.mbti` to combine generated
API documentation with handwritten Markdown guides.

The CLI also accepts `--language`, `--description`, `--footer`, and
`--site-url` so package authors can configure generated metadata without
editing renderer code. Use `--theme package` or `--theme api` for built-in
package-guide and API-reference visual presets.

## Quality and Validation

- `validate_site` reports route and content diagnostics.
- `measure_site` returns documentation metrics.
- `evaluate_quality` returns explainable publish-readiness checks and a score.
- `inspect_manifest` summarizes generated file types and sizes.

## AI Enhancement

The `ai/` package adds AI-driven documentation tooling:

- `generate_function_doc` creates structured docs from API symbols with
  complexity and usage frequency analysis.
- `assess_page_quality` scores completeness, readability, example coverage,
  and structure (heading hierarchy, title quality, code language detection).
- `aggregate_site_quality` generates site-level quality reports with
  distribution and common suggestions.
- `summarize_page` generates content summaries with keyword extraction,
  content type detection, and audience estimation.
- `detect_cross_references` finds page-to-page relationships based on
  shared keywords and identifies orphan pages.
- `analyze_coverage` detects undocumented API symbols and missing fields.
- `check_consistency` detects heading style, hierarchy, code label, duplicate
  content, and length outlier inconsistencies.
- `generate_site_seo` produces SEO metadata with meta descriptions, keyword
  density, and search boost scores.
- `generate_recommendations` creates learning paths, next-step suggestions,
  and related page recommendations.
- `generate_symbol_tests` bootstraps test stubs from API references.
- `build_chat_request_json` builds OpenAI-compatible request payloads.

CLI flags: `--ai-doc`, `--ai-quality`, `--ai-summary`, `--ai-xref`,
`--ai-coverage`, `--ai-consistency`, `--ai-seo`, `--ai-recommend`,
`--ai-tests`.

## Safety and Portability

Generated HTML escapes source text and sanitizes unsafe links. The reusable
library is backend-neutral; Node.js is used only by the optional CLI filesystem
adapter.

Repository: https://github.com/Estrella-11/moonbit_1

Mirror: https://gitlink.org.cn/Estrella/moonbit

Public docs: https://estrella-11.github.io/moonbit_1/

Generated API reference: https://estrella-11.github.io/moonbit_1/api-reference.html

Adoption guide: `docs/adoption-playbook.md`

Ecosystem impact: `docs/ecosystem-impact.md`

License: Apache-2.0
