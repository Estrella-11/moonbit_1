# Security Policy

MoonDocKit is a static documentation generator. Its main security concerns are
safe rendering, safe generated metadata, and predictable filesystem behavior in
the CLI.

## Supported Versions

The competition baseline is `0.1.0`. Security fixes should target the current
main branch until a tagged release process is active.

## Reporting a Vulnerability

For now, report suspected security issues through a private message to the
repository owner if possible. If private reporting is not available, open an
issue with a minimal reproduction and avoid including exploit details beyond
what is needed to reproduce the problem.

Useful details:

- the input Markdown or `.mbti` snippet;
- the generated HTML, JSON, XML, or manifest output;
- the command used to generate the output;
- whether the issue affects links, images, search, sitemap, or CLI paths.

## Security Scope

In scope:

- unsafe HTML output from supported Markdown syntax;
- unsafe link, image, or autolink handling;
- search index data being inserted as HTML;
- JSON or XML escaping bugs in generated artifacts;
- CLI behavior that writes outside the requested output directory.

Out of scope:

- unsupported raw HTML syntax that is rendered as escaped text;
- malicious repositories already trusted by the local user or CI;
- local operating-system policy blocks such as Windows Device Guard.

See `docs/security-model.md` for the current renderer and CLI safety model.
