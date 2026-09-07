# MoonDocKit

[English](README.md) | [中文](README_CN.md)

[![CI](https://github.com/Estrella-11/moonbit_1/actions/workflows/ci.yml/badge.svg)](https://github.com/Estrella-11/moonbit_1/actions/workflows/ci.yml)
[![Showcase](https://github.com/Estrella-11/moonbit_1/actions/workflows/pages.yml/badge.svg)](https://estrella-11.github.io/moonbit_1/)

MoonDocKit is a MoonBit-first documentation site toolkit for package authors.
It turns package notes and guides into small static HTML documentation sites
with safe HTML escaping, stable anchors, navigation, and testable rendering
logic.

This repository is being developed for the 2026 MoonBit Open Source Competition.
The project is intentionally scoped as an ecosystem tool rather than another
standalone Markdown parser: the long-term goal is to help MoonBit package
authors publish clear docs, examples, API guides, and release notes with a
simple MoonBit workflow.

Repository mirrors:

- GitHub: <https://github.com/Estrella-11/moonbit_1>
- Gitlink: <https://gitlink.org.cn/Estrella/moonbit>

Public showcase: <https://estrella-11.github.io/moonbit_1/>

Generated MoonBit API:

- Public showcase: <https://estrella-11.github.io/moonbit_1/api-reference.html>
- Repository artifact: `dist-cli-example/api-reference.html`

## Current Features

- Safe HTML escaping for generated pages.
- Stable ASCII slug generation for headings and page routes.
- Block-level Markdown AST for H1-H3 headings, paragraphs, lists, block quotes, and
  fenced code blocks.
- Inline Markdown rendering for code spans, emphasis, strong text, safe links,
  autolinks, and safe images.
- Paragraph line folding and fenced code language labels.
- HTML rendering from parsed Markdown blocks.
- Heading extraction and automatic on-page table of contents.
- Page-unique heading anchors for duplicate section titles.
- Front matter parsing for page title, order, tags, and custom fields.
- MoonBit `.mbti` public API extraction and reference-page generation.
- API reference summaries with declaration counts, function arity, and return
  type extraction from MoonBit signatures.
- Per-symbol API anchors so generated reference pages can deep-link directly to
  individual functions, structs, enums, and traits.
- Grouped API symbol index links for fast navigation across large generated
  reference pages.
- Route planning for multi-page sites using page slug and front matter order.
- Static output manifest generation for rendered HTML files.
- JSON search index generation with a built-in interactive search interface.
- XML sitemap generation.
- robots.txt generation for generated static sites.
- Machine-readable `site-manifest.json` and `quality-report.json` generation
  for deploy, acceptance, and reviewer evidence checks.
- Build report generation for output file counts, file kinds, and byte totals.
- Document and site metrics for headings, code blocks, word counts, and
  estimated reading time.
- Quality gate evaluation for publish-readiness checks and scoring.
- MoonBit CLI for reading a Markdown directory and writing a complete static
  documentation site.
- Responsive documentation layout with active navigation, skip links, and
  mobile support.
- Root `index.html` generation for direct static-host deployment.
- Site summary metadata for demos and validation.
- Site validation diagnostics for empty sites, empty titles, empty source
  pages, and duplicate output routes.
- Theme configuration for generated page colors and layout widths.
- Template options for generated page language, description metadata, and
  footer content.
- Canonical links and Open Graph metadata for generated pages.
- Runnable demo that prints generated files and site statistics.
- Nine-scenario compiled CLI integration suite covering real builds, generated
  API output, invalid arguments, empty sites, missing source directories, and
  output path conflicts, plus config-file builds, CLI overrides, strict
  validation, and dry-run previews.
- Site-level rendering with sidebar navigation.
- Runnable demo package at `cmd/main`.
- Blackbox tests for public behavior.
- AI-enhanced documentation generation from `.mbti` interface files.
- AI-driven quality assessment with completeness, readability, example
  coverage, and structure scoring (heading hierarchy, title quality, code
  language detection).
- AI content summarization with keyword extraction, content type detection,
  and audience estimation.
- AI cross-reference detection between documentation pages based on shared
  keywords and topic overlap.
- AI documentation coverage analysis identifying undocumented API symbols and
  missing documentation fields.
- AI consistency checker detecting heading style mismatches, heading hierarchy
  jumps, unlabeled code blocks, duplicate content, and content length outliers.
- AI SEO metadata generator with meta descriptions, keyword density analysis,
  search boost scoring, and optimization recommendations.
- AI content recommendation engine generating learning paths, next-step
  suggestions, related page links, and hub page identification.
- Site-level quality aggregation report with distribution, best/worst pages,
  and common suggestions.
- AI test stub generation from API symbols for quick test bootstrapping.
- Prompt template system with variable substitution for LLM integration.
- OpenAI-compatible chat request JSON builder for external LLM calls.

## Installation

### Prerequisites

Install the MoonBit toolchain:

```bash
# Linux / macOS
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

# Windows (PowerShell)
irm https://cli.moonbitlang.com/install/powershell.ps1 | iex
```

Verify the installation:

```bash
moon version
```

### Use as a Dependency

Add MoonDocKit to your MoonBit project:

```bash
moon add Estrella-11/moondockit
```

### Build from Source

```bash
git clone https://github.com/Estrella-11/moonbit_1.git
cd moonbit_1
moon check
moon test
```

## Quick Start

```bash
moon check
moon test
moon info
git diff --exit-code
moon fmt
git diff --exit-code
moon run cmd/main
python tools/test_cli.py
python tools/benchmark_cli.py --pages 10,100 --rounds 2
python tools/verify_project.py
```

The demo prints generated output files, summary metadata, and validation
diagnostics for an in-memory documentation site.

Build the included Markdown example with the MoonBit CLI:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-cli-example \
  --title "MoonDocKit CLI Example" \
  --site-url https://example.com/moondockit-cli \
  --language en \
  --description "MoonDocKit CLI documentation" \
  --footer "Built with `MoonDocKit`"
```

The CLI reads every `.md` file, evaluates the quality gate, and writes a root
`index.html`, documentation pages, an interactive search experience backed by
`search-index.json`, plus `sitemap.xml`, `robots.txt`, `site-manifest.json`,
and `quality-report.json`.

For repeatable project builds, put the same fields in JSON and pass `--config`:

```bash
moon run --target js cmd/moondockit --config examples/moondockit.json
```

The example configuration is documented in `docs/configuration.md`, and
`examples/moondockit.schema.json` describes the supported fields for editor
hints and review.

The CLI exposes source, output, language, description, footer, canonical URL,
and optional `.mbti` API inputs. Command-line options override config-file
values. The compiled Node.js CLI returns non-zero process exit codes for
invalid arguments and failed quality gates. Add `--strict` when CI should fail
on validation warnings before any output is written; without `--strict`, warning
diagnostics are printed while successful builds still complete. Add `--dry-run`
to validate and report planned output files without writing the output
directory.

Include generated MoonBit package API documentation:

```bash
moon info
moon run --target js cmd/moondockit \
  --source examples/site \
  --api pkg.generated.mbti \
  --output dist-api \
  --title "MoonDocKit"
```

The `.mbti` parser extracts public functions, structs, enums, and traits into a
searchable API reference page. It also derives a compact API summary, function
parameter counts, return types, per-symbol anchors, and a grouped symbol index
from signatures so the generated reference is useful during review instead of
being only a raw declaration dump. This keeps the generated documentation
aligned with the package interface produced by the MoonBit toolchain.

## AI-Enhanced Documentation

MoonDocKit now includes an AI module (`ai/`) that enhances documentation
generation, quality assessment, and test bootstrapping. The AI features
work without external API keys using rule-based baseline implementations,
and are designed for future LLM integration via OpenAI-compatible APIs.

### AI Documentation Generation

Generate AI-enhanced API documentation from a `.mbti` file:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --api pkg.generated.mbti \
  --output dist-ai \
  --ai-doc \
  --title "MoonDocKit AI"
```

The `--ai-doc` flag generates two additional pages:
- **AI Overview**: A module-level summary with symbol listings.
- **AI API Reference**: Per-symbol documentation with descriptions, parameters,
  return values, and usage examples.

### AI Quality Assessment

Run AI-driven quality assessment on all documentation pages:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-ai \
  --ai-quality \
  --title "MoonDocKit AI"
```

The `--ai-quality` flag generates two files:
- `ai-quality-report.md`: Per-page scores for completeness, readability, example
  coverage, and structure (heading hierarchy, title quality, code language detection).
  Each page includes identified strengths and actionable improvement suggestions.
- `ai-site-quality-report.md`: Site-level aggregation with average score, quality
  distribution (Excellent/Good/Fair/Poor), best and worst pages, and common
  suggestions across all pages.

### AI Content Summarization

Generate AI content summaries for all documentation pages:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-ai \
  --ai-summary \
  --title "MoonDocKit AI"
```

The `--ai-summary` flag generates an `ai-site-summary.md` file with:
- Per-page summaries extracted from first paragraphs.
- Top 5 keywords for each page.
- Content type detection (tutorial, reference, guide, code-snippet).
- Target audience estimation (beginner, intermediate, developer, advanced).
- Key sections listing from H1-H2 headings.

### AI Cross-Reference Detection

Detect cross-references between documentation pages:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-ai \
  --ai-xref \
  --title "MoonDocKit AI"
```

The `--ai-xref` flag generates an `ai-cross-reference.md` file with:
- Detected page-to-page relationships based on shared keywords.
- Relevance scores (0-100) for each cross-reference.
- Orphan pages with no incoming references.
- Most referenced pages ranking.
- Shared keyword lists for each detected reference.

### AI Documentation Coverage Analysis

Analyze API documentation coverage gaps:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --api pkg.generated.mbti \
  --output dist-ai \
  --ai-coverage \
  --title "MoonDocKit AI"
```

The `--ai-coverage` flag generates an `ai-coverage-report.md` file with:
- Total API symbols and how many are referenced in documentation.
- Coverage percentage with documented vs. undocumented counts.
- Per-kind breakdown (functions, structs, enums).
- List of undocumented symbols with missing fields.
- Actionable recommendations for improving coverage.

### AI Test Generation

Generate test stubs from API symbols:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --api pkg.generated.mbti \
  --output dist-ai \
  --ai-tests \
  --title "MoonDocKit AI"
```

The `--ai-tests` flag generates an `ai-generated-test.mbt` file with:
- Test stubs for each public API symbol.
- Test type classification (unit, construction, pattern-match, etc.).
- Ready-to-run `assert_true` placeholders for quick bootstrapping.

### AI Consistency Checker

Check documentation style and content consistency:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-ai \
  --ai-consistency \
  --title "MoonDocKit AI"
```

The `--ai-consistency` flag generates an `ai-consistency-report.md` file with:
- Heading style consistency (H1 presence across pages).
- Heading hierarchy violations (level jumps like H1 to H3).
- Unlabeled code block detection.
- Duplicate content detection across pages.
- Content length outlier detection (too short or too long).
- Site-level style score (0-100).

### AI SEO Metadata

Generate search optimization metadata:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-ai \
  --ai-seo \
  --title "MoonDocKit AI"
```

The `--ai-seo` flag generates an `ai-seo-report.md` file with:
- Per-page meta descriptions (auto-generated, max 160 chars).
- Keyword density analysis (top 5 keywords per page).
- Search boost scores (0-100) based on content quality signals.
- OpenGraph type classification.
- Pages with low search boost identification.
- Optimization recommendations.

### AI Content Recommendations

Generate learning paths and related content suggestions:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --output dist-ai \
  --ai-recommend \
  --title "MoonDocKit AI"
```

The `--ai-recommend` flag generates an `ai-recommendations.md` file with:
- Structured learning paths from introductory to advanced pages.
- Next-step recommendations with confidence scores.
- Related page suggestions based on keyword overlap.
- Hub page identification (most recommended destinations).
- Difficulty estimation (beginner, intermediate, advanced).

### Combined AI Build

Run all AI features in a single build:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --api pkg.generated.mbti \
  --output dist-ai-full \
  --ai-doc \
  --ai-quality \
  --ai-summary \
  --ai-xref \
  --ai-coverage \
  --ai-consistency \
  --ai-seo \
  --ai-recommend \
  --ai-tests \
  --title "MoonDocKit AI Full"
```

This generates all AI-enhanced output files in one pass, providing a
comprehensive AI-assisted documentation analysis suite.

### AI Module Architecture

The `ai/` package provides:

| File | Purpose |
|------|---------|
| `ai_core.mbt` | AI config, chat messages, JSON request builder, JSON field parser, string utilities |
| `ai_prompts.mbt` | Prompt templates with `{{variable}}` substitution |
| `ai_doc_gen.mbt` | AI documentation generation with complexity and usage frequency analysis |
| `ai_quality.mbt` | Rule-based quality assessment with structure scoring, heading hierarchy, title quality, and site-level aggregation |
| `ai_summary.mbt` | AI content summarization with keyword extraction, content type detection, and audience estimation |
| `ai_xref.mbt` | AI cross-reference detection with keyword overlap and orphan page identification |
| `ai_coverage.mbt` | AI documentation coverage analysis with per-kind breakdown and recommendations |
| `ai_consistency.mbt` | AI consistency checker detecting heading style, hierarchy, code labels, duplicates, and length outliers |
| `ai_seo.mbt` | AI SEO metadata with meta descriptions, keyword density, search boost scoring, and recommendations |
| `ai_recommend.mbt` | AI content recommendations with learning paths, next steps, related pages, and hub identification |
| `ai_test_gen.mbt` | Test stub generation from API symbols |
| `ai_test.mbt` | 118 blackbox tests covering all AI public functions |

All AI functions accept an `AiConfig` parameter for future LLM provider
configuration. The current baseline uses rule-based heuristics that produce
meaningful results without requiring an API key.

## Reviewer Path

For competition review, start with:

- `docs/final-submission.md`
- `docs/final-acceptance.md`
- `docs/reviewer-scorecard.md`
- `docs/acceptance-guide.md`
- `docs/release.md`
- `dist-example`
- `dist-cli-example/overview.html`
- `dist-cli-example/api-reference.html`
- `dist-cli-example/quality-report.json`

## Competition Materials

- One-page project proposal: `docs/MoonDocKit-project-proposal-appendix-template.pdf`
- Development plan: `docs/competition-plan.md`
- Acceptance checklist: `docs/acceptance-checklist.md`
- Acceptance guide: `docs/acceptance-guide.md`
- Final acceptance evidence: `docs/final-acceptance.md`
- Reviewer scorecard: `docs/reviewer-scorecard.md`
- Feature evidence map: `docs/feature-evidence-map.md`
- Reviewer FAQ: `docs/reviewer-faq.md`
- Final submission notes: `docs/final-submission.md`
- Release notes: `docs/release.md`
- Architecture and design decisions: `docs/architecture.md`
- Accessibility notes: `docs/accessibility-notes.md`
- Security model: `docs/security-model.md`
- Security policy: `SECURITY.md`
- Maintenance plan: `docs/maintenance-plan.md`
- Change impact matrix: `docs/change-impact-matrix.md`
- Contributing guide: `CONTRIBUTING.md`
- Code of conduct: `CODE_OF_CONDUCT.md`
- Support guide: `SUPPORT.md`
- 90-second reviewer demo: `docs/demo-script.md`
- Deployment and release runbook: `docs/deployment-runbook.md`
- Configuration guide: `docs/configuration.md`
- Adoption playbook: `docs/adoption-playbook.md`
- Ecosystem impact: `docs/ecosystem-impact.md`
- Windows toolchain troubleshooting: `docs/windows-toolchain-troubleshooting.md`
- Mooncakes publishing plan: `docs/mooncakes-publishing.md`
- Award sprint plan: `docs/award-sprint.md`
- Development log: `docs/development-log.md`
- Benchmark notes: `docs/benchmark-notes.md`
- Example site sources: `examples/site`
- Generated example site: `dist-example`
- MoonBit CLI generated site: `dist-cli-example`
- Downstream adoption fixture: `examples/adoption-package`
- Generated adoption site: `dist-adoption-example`

## Award Sprint Direction

MoonDocKit is now an end-to-end documentation toolkit for the MoonBit
ecosystem and has been published to mooncakes.io as `Estrella-11/moondockit`.
The next milestones focus on award-level evidence and adoption quality:

- Add source spans and richer inline nodes to the Markdown AST.
- Add a real MoonBit package adoption case with before/after documentation
  output.
- Improve filesystem diagnostics for common CLI mistakes.
- Add additional focused theme presets after the package and API reference
  presets.
- Turn reviewer feedback into small, well-tested release increments.
- Integrate real LLM API calls for AI documentation generation and quality
  assessment.
- Add AI-powered documentation suggestions during the build process.
- Expand AI test generation with smarter assertions and edge case detection.
- Enhance cross-reference detection with semantic similarity analysis.
- Add multi-language documentation support and internationalization.

## Competition Fit

The competition charter asks for projects that are real, reusable, testable,
maintainable, and valuable to the MoonBit open-source ecosystem. MoonDocKit
targets a common ecosystem gap: package authors need a simple way to turn
MoonBit project documentation into browsable static sites without leaving the
MoonBit toolchain.

The project participates in the **季度优秀社区项目评选** direction,
building on the existing MoonDocKit project with significant new contributions
during the September competition cycle:

- **11 AI modules** providing documentation generation, quality assessment,
  content summarization, cross-reference detection, coverage analysis,
  consistency checking, SEO metadata, content recommendations, and test
  generation.
- **118 tests** covering all AI public functions and edge cases.
- **9 CLI AI flags** enabling comprehensive documentation analysis.
- **CI pipeline** covering check, test, format, build, and full AI suite
  verification.
- **Published on mooncakes.io** at version 0.2.0.
- **Apache-2.0 license**, OSI-approved.

See `docs/ecosystem-impact.md` for the award-oriented ecosystem contribution
summary.

## License

Apache-2.0.
