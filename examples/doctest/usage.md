---
title: Usage Examples
order: 1
tags:
  - examples
---

# Usage Examples

Every MoonBit block on this page is extracted by MoonDocKit itself and compiled
as a `moon test` case, so the snippets below cannot silently drift away from the
library they document. Blocks tagged `nocheck` stay illustrative and are skipped.

## Stable identifiers

```mbt
///|
inspect(
  @moondockit.slugify("MoonBit Docs: Quick Start!"),
  content="moonbit-docs-quick-start",
)
```

## Safe generated markup

```mbt
///|
inspect(
  @moondockit.html_escape("<script>alert('x')</script>"),
  content="&lt;script&gt;alert(&#39;x&#39;)&lt;/script&gt;",
)
```

## Documented examples are machine-checkable

```mbt
///|
let markdown = "```mbt\n///|\nlet a = 1\n```\n"
inspect(@moondockit.count_doc_examples(markdown), content="1")
```

## Illustrative snippets stay illustrative

```mbt nocheck
///|
let site : @moondockit.DocSite = { title: "Package Docs", pages: [], }
let files = @moondockit.build_site_manifest(site)
```

## Shell commands are not MoonBit

```bash
moon test
```
