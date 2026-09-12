# Feature Evidence Map

This map links MoonDocKit's implemented features to source files, tests,
examples, and generated artifacts.

| Feature | Source | Test or Check | Evidence |
| --- | --- | --- | --- |
| Markdown block parsing | `moondockit.mbt` | `moondockit_test.mbt` | `examples/site`, `dist-example` |
| Inline code, emphasis, strong text | `render_inline` in `moondockit.mbt` | inline renderer blackbox tests | `dist-example/quick-start.html` |
| Safe links, images, and autolinks | `safe_href`, `parse_autolink`, `render_inline` | safety-focused renderer tests | `docs/security-model.md` |
| Front matter metadata | `parse_document` and route planning APIs | front matter and route tests | `examples/site/*.md` |
| Table of contents and anchors | `extract_toc`, `unique_anchor`, `render_toc` | TOC and duplicate-anchor tests | generated page navigation |
| Multi-page site output | `build_site_manifest` and render APIs | site rendering tests | `dist-cli-example`, `dist-example` |
| Search index and safe UI | search entry builders and search script | search and DOM safety tests | `search-index.json`, rendered search UI |
| Sitemap and robots output | sitemap and robots builders | manifest/output tests | `sitemap.xml`, `robots.txt` |
| Site validation diagnostics | `validate_site`, `diagnostics_to_text` | validation tests and CLI tests | strict-mode CLI behavior |
| Quality gate | `evaluate_quality` | quality gate tests and benchmark checks | `docs/benchmark-notes.md` |
| Quality report artifact | `build_quality_report_json` | report serialization and CLI tests | `quality-report.json` in generated sites |
| `.mbti` API extraction | `parse_mbti`, API page builders | API parser tests | `dist-cli-example/api-reference.html` |
| API review notes | `mbti_to_page` | API page tests | generated `Review Notes` section |
| CLI generation | `cmd/moondockit` | `tools/test_cli.py` | compiled CLI build output |
| Config file workflow | CLI config parsing and schema | CLI integration tests | `examples/moondockit.json`, schema |
| Release readiness | release and acceptance docs | `tools/verify_project.py` | `docs/final-acceptance.md` |
| AI documentation generation | `ai/ai_doc_gen.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-api-reference.html` |
| AI quality assessment | `ai/ai_quality.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-quality-report.md` |
| AI site quality aggregation | `ai/ai_quality.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-site-quality-report.md` |
| AI content summarization | `ai/ai_summary.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-site-summary.md` |
| AI cross-reference detection | `ai/ai_xref.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-cross-reference.md` |
| AI documentation coverage | `ai/ai_coverage.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-coverage-report.md` |
| AI consistency checker | `ai/ai_consistency.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-consistency-report.md` |
| AI SEO metadata | `ai/ai_seo.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-seo-report.md` |
| AI content recommendations | `ai/ai_recommend.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-recommendations.md` |
| AI test generation | `ai/ai_test_gen.mbt` | `ai/ai_test.mbt` | `dist-ai-example/ai-generated-test.mbt` |
| AI core configuration | `ai/ai_core.mbt` | `ai/ai_test.mbt` | `ai/pkg.generated.mbti` |
| AI prompt templates | `ai/ai_prompts.mbt` | `ai/ai_test.mbt` | `ai/pkg.generated.mbti` |

## Fast Review Path

For a quick technical review:

1. Read `README.md` for scope and usage.
2. Read `docs/self-assessment.md` for the September hackathon self-assessment.
3. Read `docs/security-model.md` for renderer and search safety.
4. Inspect `moondockit_test.mbt` for behavior coverage.
5. Inspect `ai/ai_test.mbt` for AI module test coverage (89 tests).
6. Inspect `tools/test_cli.py` for filesystem-level CLI checks.
7. Open `dist-cli-example/api-reference.html` for generated MoonBit API docs.
8. Inspect `dist-cli-example/quality-report.json` for structured release-gate
   evidence.
9. Open `dist-ai-example/ai-quality-report.md` for AI quality assessment.
10. Open `dist-ai-example/ai-recommendations.md` for AI content recommendations.

## Why This Matters

The project is intentionally reviewable: every major feature has source code,
tests, documentation, and at least one generated artifact. This helps reviewers
distinguish implemented behavior from roadmap ideas.
