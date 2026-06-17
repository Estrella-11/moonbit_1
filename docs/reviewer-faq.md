# Reviewer FAQ

This FAQ answers likely review and defense questions for MoonDocKit.

## Is this only a static website demo?

No. The static site is the visible output, but the reusable part is the MoonBit
library that models pages, routes, table-of-contents data, diagnostics, metrics,
quality checks, search documents, API entries, and generated output files.

The CLI is intentionally thin: it reads Markdown and `.mbti` files, calls the
MoonBit library, and writes the resulting manifest to disk.

## What makes it MoonBit-specific?

MoonDocKit consumes `pkg.generated.mbti` files produced by `moon info` and turns
the public package interface into a browsable API reference. It also keeps the
documentation build close to ordinary MoonBit workflows:

- `moon check`
- `moon test`
- `moon info`
- `moon run --target js cmd/moondockit`
- `moon package`

The project is therefore a MoonBit ecosystem tool rather than a generic website
template.

## What if another team builds a documentation generator too?

MoonDocKit should still be differentiated by its reviewable engineering surface:

- MoonBit-first core data models and renderer;
- `.mbti` API extraction with symbol grouping, anchors, arity, and return types;
- validation diagnostics and publish-readiness quality score;
- generated `site-manifest.json` for acceptance and deployment checks;
- config file, JSON schema, strict mode, dry-run mode, and CLI integration
  tests;
- adoption and ecosystem-impact documents for downstream packages.

The goal is not only to render Markdown, but to provide a repeatable
documentation release workflow for MoonBit package authors.

## How can reviewers verify that the output is not hand-written?

Run:

```bash
python tools/verify_project.py
```

The verifier checks required project files, validates the proposal PDF when
`pypdf` is installed, rebuilds the Python example site, rebuilds the MoonBit CLI
example with generated API documentation, runs CLI integration checks, and then
runs the MoonBit check/test/demo commands.

Reviewers can also inspect:

- `examples/site` for source Markdown;
- `pkg.generated.mbti` for source API declarations;
- `dist-cli-example/api-reference.html` for generated API output;
- `dist-cli-example/site-manifest.json` for machine-readable output metadata.

## How is code quality demonstrated?

The project keeps core behavior deterministic and testable:

- the renderer returns `Array[OutputFile]` instead of writing files directly;
- tests cover parsing, rendering, routing, validation, API extraction, and
  manifest behavior;
- the compiled CLI integration suite covers real builds and failure modes;
- generated `.mbti` files document the public API surface;
- CI checks the default backend and JavaScript CLI target.

## How is AI assistance controlled?

AI was used as an implementation and documentation assistant. The submitted
project remains participant-controlled through:

- explicit architecture and public API boundaries;
- Apache-2.0 licensing and repository-visible sources;
- reproducible checks and generated outputs;
- human-selected scope, acceptance criteria, and release materials.

This is documented in `docs/architecture.md`.

## What remains after the current checkpoint?

The remaining external release task is mooncakes.io publication. The repository
already includes `README.mbt.md`, release notes, a publishing plan, and package
metadata. Publication requires account credentials, so it is tracked separately
in `docs/mooncakes-publishing.md`.

Future engineering work can add richer Markdown syntax, source spans, more
theme presets, and adoption examples from real MoonBit packages.
