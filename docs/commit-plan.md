# Meaningful Commit Plan

The competition asks for visible, continuous, traceable engineering work. This
plan keeps commits small enough to review but meaningful enough to show real
progress.

## Declaration Stage

1. Initialize MoonDocKit competition project.
2. Record repository synchronization status.
3. Mark repository synchronization complete.
4. Add one-page project proposal PDF.
5. Add block AST data model.
6. Implement block parser for headings, paragraphs, lists, quotes, and code.
7. Refactor HTML rendering to use the block AST.
8. Add duplicate heading anchor handling.
9. Add front matter parser.
10. Add route planning for multi-page docs.

## Development Stage

11. Implement static output manifest.
12. Add default template renderer.
13. Add search index model and generator.
14. Add example documentation site.
15. Add benchmark notes and performance tests.
16. Add error reporting and validation helpers.
17. Add mooncakes.io publishing notes.
18. Add final acceptance checklist updates.
19. Add showcase script and demo walkthrough.
20. Prepare final release candidate.

## Commit Quality Rules

- Each commit should change one coherent feature, test, document, or workflow.
- Avoid empty commits and artificial file churn.
- Keep tests passing after every code commit.
- Update `docs/development-log.md` when a milestone becomes externally visible.
