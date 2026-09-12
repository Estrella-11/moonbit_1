---
title: Writing Great Pages
order: 2
tags: [guide, markdown, front-matter]
---
# Writing Great Pages

MoonDocKit renders a focused Markdown subset. Keeping pages inside it makes
output predictable and keeps the quality gate high.

## Front Matter

```markdown
---
title: Display Title
order: 2
tags: [guide, markdown]
---
```

- `title` sets the navigation label and the page heading fallback.
- `order` sorts navigation; lower numbers come first.
- `tags` feed the search index and related-content suggestions.
- Unknown fields are preserved, so custom metadata is safe to add.

## Supported Blocks

- H1 to H3 headings, with stable ASCII anchors.
- Paragraphs; adjacent lines fold into one paragraph.
- Ordered and unordered lists.
- Block quotes.
- Fenced code blocks with language labels.

## Inline Syntax

Use `code spans`, **strong text**, _emphasis_, [links](https://moonbitlang.com),
and fenced blocks:

```moonbit
fn greet(name : String) -> String {
  "Hello, \{name}"
}
```

## What The Quality Gate Checks

The generated `quality-report.json` scores publish readiness. Pages lose points
for missing titles, empty content, duplicate routes, unlabeled code blocks, and
heading hierarchy jumps.

> Run with `--ai-quality` during review to get per-page scores plus concrete
> improvement suggestions for completeness, readability, and example coverage.
