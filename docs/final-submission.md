# Final Submission Notes

MoonDocKit is ready for the declaration-stage submission of the 2026 MoonBit
open-source competition.

## Repository Links

- GitHub: https://github.com/Estrella-11/moonbit_1
- Gitlink: https://gitlink.org.cn/Estrella/moonbit

## Reviewer Entry Points

- Project overview: `README.md`
- One-page proposal PDF: `docs/MoonDocKit-项目申报书-附录二模板版.pdf`
- Acceptance guide: `docs/acceptance-guide.md`
- Release notes: `docs/release.md`
- Example source pages: `examples/site`
- Generated example site: `dist-example`

## Verification Commands

```bash
moon check
moon test
moon run cmd/main
python tools/verify_project.py
```

Expected result:

- `moon check` completes without errors.
- `moon test` reports 17 passing tests.
- `moon run cmd/main` prints generated files, summary metadata, and validation
  diagnostics.
- `python tools/verify_project.py` rebuilds the example site and prints
  `Project verification passed.`

## Implemented Highlights

- Block-level Markdown AST and reusable HTML renderer.
- Stable route planning, page-unique anchors, and generated table of contents.
- Front matter parsing for title, order, tags, and custom fields.
- Static output manifests for HTML pages and JSON search index.
- Site summary and validation diagnostics for pre-publish checks.
- Theme configuration APIs for colors and layout widths.
- Example documentation site, generated output, CI workflow, release notes,
  publishing plan, and acceptance checklist.

## Submission Status

- GitHub and Gitlink repositories are synchronized.
- Required competition PDF proposal exists.
- Core behavior is covered by blackbox tests.
- mooncakes.io publishing is documented and remains the final post-review
  release step.
