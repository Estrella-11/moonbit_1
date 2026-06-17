# Security Model

MoonDocKit generates static documentation from repository-owned Markdown and
MoonBit interface files. This page documents the security boundaries used by
the renderer and CLI.

## Trust Boundary

Trusted inputs:

- project configuration written by the package maintainer;
- local Markdown source files in the selected source directory;
- generated `.mbti` interface files from `moon info`.

Untrusted or semi-trusted content:

- Markdown text copied from external sources;
- link and image URLs inside Markdown;
- page titles, tags, and front matter fields;
- public API names and signatures shown in generated HTML.

MoonDocKit treats rendered text as data. It should not be allowed to become
raw HTML or executable JavaScript unless a future feature explicitly documents
and tests that behavior.

## Output Safety

The renderer applies separate escaping rules for different output formats:

- HTML text and attributes use `html_escape`.
- JSON search and manifest data use `json_escape`.
- XML sitemap entries use `xml_escape`.
- Inline links and image sources pass through `safe_href`.

This keeps source text such as `<script>`, unsafe image alt text, and API
signatures from being interpreted as HTML.

## Link and Image Policy

Markdown links and images allow:

- `http://`
- `https://`
- `#`
- `./`
- `../`
- plain relative paths without a URI scheme

Other URI schemes are replaced with `#`. This blocks common script-style
payloads such as `javascript:alert(1)` while keeping normal documentation
links usable.

Autolinks only accept `http://` and `https://` URLs in angle brackets. Other
angle-bracket content is escaped as text.

## Search UI Safety

The generated search UI fetches `search-index.json` and builds result elements
with DOM APIs:

- `textContent` is used for titles and excerpts;
- `href` is assigned from generated path metadata;
- `innerHTML` is intentionally avoided.

This prevents search index text from being injected into the page as HTML.

## CLI Filesystem Boundary

The reusable MoonBit library returns deterministic `OutputFile` values. The
CLI package is responsible for reading Markdown files and writing output files.
Keeping filesystem access in the CLI makes the core renderer easier to test and
reduces the amount of code that can affect local files.

## Known Non-Goals

MoonDocKit does not attempt to sanitize arbitrary raw HTML because raw HTML is
not a supported Markdown feature in the current scope. Unsupported syntax is
rendered as escaped text.

MoonDocKit is not a sandbox for hostile repositories. It is a documentation
tool for package maintainers and CI systems that already trust the repository
being built.

## Security Regression Checks

Before release, confirm:

```bash
moon test
python tools/test_cli.py
python tools/verify_project.py
```

The blackbox suite covers HTML escaping, unsafe links, safe image sources,
autolinks, JSON/XML escaping, and search UI DOM construction.
