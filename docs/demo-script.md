# 90-Second Reviewer Demo

## Opening: 0-15 seconds

MoonDocKit is a MoonBit-first documentation site toolkit. It turns a directory
of Markdown package notes into a deployable static documentation site while
keeping parsing, routing, validation, rendering, and quality checks in MoonBit.

Open the public showcase:

https://estrella-11.github.io/moonbit_1/

Point out the responsive navigation, table of contents, page metadata, and
mobile layout.

## Build: 15-40 seconds

Show the three Markdown files under `examples/site`, then run:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-demo \
  --title "MoonDocKit Demo"
```

The CLI reports a quality score and writes seven static files, including the
root page, documentation pages, search index, sitemap, and robots policy.

## Engineering: 40-65 seconds

Run:

```bash
moon test
moon coverage analyze
python tools/verify_project.py
```

Current evidence:

- 38 blackbox tests pass;
- only 20 lines remain uncovered, including executable entry points;
- default and JavaScript MoonBit targets pass;
- the one-shot verifier rebuilds both example sites;
- the publish quality gate scores the example at 100.

## Ecosystem Value: 65-90 seconds

Explain the architecture:

- the reusable MoonBit library returns a deterministic output manifest;
- the Node.js adapter only performs filesystem input and output;
- package authors can embed the library or use the bundled CLI;
- Apache-2.0 licensing, CI, examples, release notes, and mooncakes.io metadata
  make the project reusable beyond the competition.

Finish by opening `docs/architecture.md` and the mooncakes.io package page after
publication.

## Likely Reviewer Questions

**Why not use an existing Markdown parser?**

Markdown parsing is one layer. MoonDocKit focuses on the missing site-building
workflow: routes, navigation, TOC, metadata, search data, sitemap, validation,
quality scoring, theming, and deployable output.

**How much is implemented in MoonBit?**

All domain logic is MoonBit. The JavaScript adapter is deliberately limited to
reading and writing files.

**How is AI-assisted work controlled?**

Every accepted change must pass formatting, both target checks, blackbox tests,
the example builds, and the repository verification script. Architecture and
public API decisions remain participant-controlled.
