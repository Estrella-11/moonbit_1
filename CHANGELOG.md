# Changelog

All notable changes to MoonDocKit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] — 2026-09-07

### Added — AI Documentation Suite

Eleven new AI modules providing comprehensive documentation analysis and
generation:

- **AI Documentation Generation** (`ai_doc_gen.mbt`): Enhanced API reference
  generation with complexity scoring and usage frequency estimation.
- **AI Quality Assessment** (`ai_quality.mbt`): Rule-based quality scoring
  covering completeness, readability, example coverage, and structure (heading
  hierarchy, title quality, code language detection). Includes site-level
  aggregation with distribution and common suggestions.
- **AI Content Summarization** (`ai_summary.mbt`): Automatic page summaries with
  keyword extraction, content type detection, and audience estimation.
- **AI Cross-Reference Detection** (`ai_xref.mbt`): Page-to-page relationship
  detection based on keyword overlap, with orphan page and hub page
  identification.
- **AI Documentation Coverage** (`ai_coverage.mbt`): API symbol documentation
  coverage analysis with per-kind breakdown and recommendations.
- **AI Consistency Checker** (`ai_consistency.mbt`): Detection of heading style
  mismatches, heading hierarchy jumps, unlabeled code blocks, duplicate content,
  and content length outliers. Produces a site-level style score.
- **AI SEO Metadata** (`ai_seo.mbt`): Per-page meta descriptions, keyword density
  analysis, search boost scoring, and optimization recommendations.
- **AI Content Recommendations** (`ai_recommend.mbt`): Learning path generation,
  next-step suggestions with confidence scores, related page recommendations,
  and hub page identification.
- **AI Test Generation** (`ai_test_gen.mbt`): Test stub generation from API
  symbols for quick test bootstrapping.
- **AI Core** (`ai_core.mbt`): AI configuration, chat messages, JSON request
  builder, and JSON field parser.
- **AI Prompts** (`ai_prompts.mbt`): Prompt template system with variable
  substitution for LLM integration.

### Added — CLI Integration

Nine new CLI flags for AI features:

- `--ai-doc`: Generate AI-enhanced API documentation.
- `--ai-quality`: Run AI quality assessment on all pages.
- `--ai-summary`: Generate AI content summaries.
- `--ai-xref`: Generate AI cross-reference map.
- `--ai-coverage`: Analyze API documentation coverage.
- `--ai-consistency`: Check documentation consistency.
- `--ai-seo`: Generate SEO metadata report.
- `--ai-recommend`: Generate content recommendations and learning paths.
- `--ai-tests`: Generate AI test stubs.

### Added — Testing

- 84 new AI module tests covering all public functions and edge cases.
- Total test count increased from 34 to 118, all passing.

### Added — CI/CD

- CI pipeline now includes "Build with full AI suite" step exercising all 9 AI
  flags in a single build.
- CI pipeline now includes "Verify AI output files" step validating 11 AI
  output files and their content.

### Added — Documentation

- README.md: New Installation section with MoonBit toolchain, dependency, and
  source build instructions.
- README.md: Documentation sections for all 9 AI features with usage examples.
- README.md: Combined AI Build section showing one-shot AI build command.
- README.md: Updated AI Module Architecture table with all 11 modules.
- README.md: Updated Competition Fit section with September contributions.
- examples/README.md: AI-Enhanced Example section with 11 output file
  descriptions.
- docs/self-assessment.md: Detailed self-assessment report for September
  hackathon.

### Changed

- Version upgraded from 0.1.0 to 0.2.0.
- moon.mod: Added 6 new keywords (consistency-checker, seo-metadata,
  content-recommendations, content-summarization, cross-reference,
  coverage-analysis).
- moon.mod: Updated description to include all new AI capabilities.
- moon.pkg: Added ai module dependency to cmd/moondockit.

### Fixed

- Cleared all compiler warnings (unused variables, reserved keyword conflicts).
- Made `extract_json_field` public for external use.
- Fixed keyword extraction sensitivity in cross-reference detection.
- Fixed content length outlier thresholds in consistency checker.

## [0.1.0] — 2026-07-08

### Initial Release

- MoonBit-first static documentation site generator.
- Block-level Markdown parser (H1-H3, paragraphs, lists, blockquotes, code
  blocks).
- Inline Markdown renderer (code spans, emphasis, strong text, safe links,
  autolinks, safe images).
- HTML rendering with safe escaping.
- Front matter metadata support.
- Table of contents and heading anchors.
- Multi-page site output with navigation.
- Search index and interactive search UI.
- Sitemap.xml and robots.txt generation.
- Site validation diagnostics.
- Quality gate with scoring.
- .mbti API reference generation.
- CLI with config file support.
- 34 tests covering core functionality.
- Published to mooncakes.io.
