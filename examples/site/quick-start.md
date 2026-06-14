---
title: Quick Start
order: 1
tags: [guide, moonbit]
---
# Quick Start

MoonDocKit turns MoonBit package notes into a **small static documentation site**.

- parse front matter
- render `HTML` pages
- generate navigation
- build a search index
- generate MoonBit API documentation

## Install

After publication, add `moonbit-community/moondockit` from mooncakes.io.

## Generate

Generate the project interface and build a site:

```text
moon info
moon run --target js cmd/moondockit --source docs --api pkg.generated.mbti --output dist
```

The CLI validates the site, reports its quality score, and writes a root page,
HTML documentation, search data, sitemap, and crawler policy.

## Embed

Use the library API to build an output manifest, then write every `OutputFile`
through your preferred backend. See the [MoonBit website](https://www.moonbitlang.com)
for language documentation.
