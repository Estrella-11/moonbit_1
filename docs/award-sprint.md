# Award Sprint Plan

MoonDocKit has crossed the first acceptance bar: the package is published,
the repositories are synchronized, and the verification path is reproducible.
The award sprint should now optimize for reviewer confidence and ecosystem
impact rather than broad new surface area.

## North Star

Make MoonDocKit feel like a reusable MoonBit ecosystem tool, not only a
competition artifact. Every sprint item should produce evidence that a reviewer
can inspect in under two minutes.

## Highest-Return Work

1. Real adoption evidence

The repository now includes `examples/adoption-package`, a small downstream
MoonBit package fixture that uses MoonDocKit to produce guides plus `.mbti` API
documentation. The remaining lift is to add more real-world adoption evidence
from public packages.

2. Reviewer-first narrative

Keep `README.md`, `docs/final-acceptance.md`, `docs/demo-script.md`, and
`docs/reviewer-faq.md` aligned around the same claim: MoonDocKit connects
Markdown guides, MoonBit interfaces, validation, search, and static publishing.

3. Focused quality lift

The CLI now prints actionable hints for missing inputs, failed quality gates,
and strict validation warnings. Remaining focused improvements should keep the
same shape: small, testable, and visible in demos.

4. Evidence polish

Keep generated artifacts current after each change: `dist-cli-example`,
`dist-example`, `pkg.generated.mbti`, and the acceptance documents. A stale
artifact is more damaging than a missing stretch feature.

## Avoid During Sprint

- Rewriting the Markdown parser.
- Adding broad CommonMark compatibility without tests and examples.
- Introducing new dependencies unless they clearly reduce review risk.
- Large UI redesigns that make generated output harder to audit.

## Suggested Next Commit

Add another focused quality improvement and link it from:

- `README.md`
- `docs/demo-script.md`
- `docs/reviewer-scorecard.md`

The goal is to let reviewers say: this project keeps converting feedback into
small, verified release increments.
