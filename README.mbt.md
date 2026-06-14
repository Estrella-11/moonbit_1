# MoonDocKit

MoonDocKit is a MoonBit-first toolkit for turning package guides and generated
interfaces into deployable static documentation sites.

## Library API

Create pages and build a deterministic output manifest:

```mbt
let guide : @moondockit.DocPage = {
  title: "Quick Start",
  slug: "quick-start",
  source: "# Quick Start\n\nBuild MoonBit documentation.",
}
let site : @moondockit.DocSite = {
  title: "Package Docs",
  pages: [guide],
}
let files = @moondockit.build_site_manifest(site)
```

The manifest contains a root page, rendered HTML pages, a JSON search index,
an XML sitemap, and robots.txt without performing filesystem access.

## MoonBit API Documentation

Run `moon info`, then convert the generated interface into a documentation
page:

```mbt
let api_page = @moondockit.mbti_to_page(interface_source)
```

`parse_mbti` extracts public functions, structs, enums, and traits. The bundled
JavaScript-targeted CLI accepts `--api pkg.generated.mbti` to combine generated
API documentation with handwritten Markdown guides.

## Quality and Validation

- `validate_site` reports route and content diagnostics.
- `measure_site` returns documentation metrics.
- `evaluate_quality` returns explainable publish-readiness checks and a score.
- `inspect_manifest` summarizes generated file types and sizes.

## Safety and Portability

Generated HTML escapes source text and sanitizes unsafe links. The reusable
library is backend-neutral; Node.js is used only by the optional CLI filesystem
adapter.

Repository: https://github.com/Estrella-11/moonbit_1

License: Apache-2.0
