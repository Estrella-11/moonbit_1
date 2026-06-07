# 2026 MoonBit Open Source Competition Plan

## Project

Name: MoonDocKit

Direction: application ecosystem / engineering tooling

Core idea: build a reusable MoonBit documentation site toolkit that helps
MoonBit package authors render guides, examples, changelogs, and API-oriented
notes into static HTML sites.

## Why This Direction

The competition encourages projects that start from a publishable MoonBit
package and contribute to the open-source ecosystem. A documentation toolkit is
useful for many future MoonBit packages, has clear boundaries, can be tested
well, and can be demonstrated convincingly.

This direction avoids directly duplicating the existing MoonBit Markdown parser
ecosystem. Markdown rendering is only one layer; MoonDocKit's project value is
site generation, navigation, metadata, templates, examples, and packaging.

## Hard Requirements From The Charter

- MoonBit is the main implementation language.
- Public GitHub and Gitlink repositories.
- Clear commit history after April 29, 2026.
- README with goal, installation, usage, and reproducible examples.
- CI covering check, build, and tests.
- At least one runnable example.
- Complete tests for core functionality.
- Publish to mooncakes.io before final acceptance.
- OSI-approved open-source license.

## Milestones

### M0: Submission Baseline

- Initialize MoonBit module.
- Add README, license, CI, and project proposal.
- Implement minimal rendering library and runnable demo.
- Keep 10-20 meaningful commits for project declaration.

### M1: Documentation Core

- Replace line renderer with block AST.
- Add front matter parser.
- Expand table-of-contents generation with duplicate anchor handling.
- Add deterministic route and asset planning.

### M2: Site Builder

- Add project config model.
- Build multi-page static site output.
- Add template renderer and default theme.
- Add search index generation.

### M3: Ecosystem Polish

- Add examples for MoonBit package docs, tutorial sites, and changelogs.
- Add benchmarks and coverage notes.
- Publish to mooncakes.io.
- Prepare final showcase script and demo site.

## Award Strategy

To compete for an excellent project award, the repository must look like a
maintained ecosystem package, not a short demo. The strongest signals will be:

- Clean public API.
- CI and tests always green.
- Useful examples.
- Clear docs and development log.
- A demo that shows real MoonBit docs rendered into a site.
- Honest explanation of AI-assisted work and design choices.
