# Reviewer Scorecard

This scorecard maps the competition review dimensions to concrete repository
evidence.

## Completion

- End-to-end CLI: `cmd/moondockit`
- Example source site: `examples/site`
- Generated showcase output: `dist-cli-example`
- Public API page: `dist-cli-example/api-reference.html`
- Machine-readable output manifest: `dist-cli-example/site-manifest.json`
- Final acceptance index: `docs/final-acceptance.md`
- Feature evidence map: `docs/feature-evidence-map.md`
- Defense FAQ: `docs/reviewer-faq.md`
- Award sprint plan: `docs/award-sprint.md`

## Code Quality

- Reusable MoonBit library APIs: `moondockit.mbt`
- Generated public interface: `pkg.generated.mbti`
- Blackbox tests: `moondockit_test.mbt`
- Accessibility notes for generated pages: `docs/accessibility-notes.md`
- Security model and escaping boundaries: `docs/security-model.md`
- Compiled CLI integration suite: `tools/test_cli.py`
- One-shot verification script: `tools/verify_project.py`
- Benchmark script and recorded results: `tools/benchmark_cli.py`,
  `docs/benchmark-results.json`
- Maintenance policy and release checks: `docs/maintenance-plan.md`
- Change-to-check mapping: `docs/change-impact-matrix.md`

## Open Source Compliance

- License: `LICENSE`
- Contributing guide and GitHub templates: `CONTRIBUTING.md`, `.github`
- Community health files: `CODE_OF_CONDUCT.md`, `SUPPORT.md`, `SECURITY.md`
- Repository metadata: `moon.mod`
- Package README for mooncakes.io: `README.mbt.md`
- Release notes: `docs/release.md`
- Publishing plan: `docs/mooncakes-publishing.md`
- Adoption path for downstream MoonBit packages: `docs/adoption-playbook.md`
- AI assistance and design boundaries: `docs/architecture.md`

## MoonBit Ecosystem Relevance

- Ecosystem impact summary: `docs/ecosystem-impact.md`
- `.mbti` API extraction and generated MoonBit API reference.
- MoonBit-first data models for routes, pages, diagnostics, metrics, and output
  files.
- CLI workflow that keeps documentation generation close to `moon check`,
  `moon test`, and `moon package`.
- Config files, JSON schema, strict mode, dry-run mode, and deployment-ready
  static outputs for package authors.
- Adoption guidance that explains how other MoonBit packages can add source
  docs, generated API pages, CI gates, and static hosting.

## Reviewer Short Path

1. Open `README.md`.
2. Open `docs/final-acceptance.md`.
3. Run `python tools/verify_project.py`.
4. Inspect `dist-cli-example/api-reference.html`.
5. Inspect `dist-cli-example/site-manifest.json`.
