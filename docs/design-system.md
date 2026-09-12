# Design System

This document records the visual language of the generated documentation site.
It exists so the styling is reviewable rather than decorative: every colour and
size below is emitted by `render_theme_style()` in `moondockit.mbt`, and every
value can be confirmed from a generated page.

The design intent is "editorial paper": a warm, low-contrast reading surface
with a single deep teal accent, serif display type for headings, and sans-serif
body type. The goal is a site that stays readable for long reference pages
instead of competing with its own content.

## Colour tokens

Light mode is the default. `default_theme()` seeds the palette and
`render_theme_style()` maps it onto custom properties.

| Token | Value | Role |
| --- | --- | --- |
| `--page` | `#faf8f3` | Page background (warm paper) |
| `--card` | `#fffdf8` | Sidebar, TOC card, elevated surfaces |
| `--ink` | `#1a1923` | Primary text |
| `--ink-soft` | `color-mix(in oklab, #1a1923 76%, transparent)` | Secondary text, inactive navigation |
| `--ink-faint` | `color-mix(in oklab, #1a1923 62%, transparent)` | Captions, metadata |
| `--accent` | `#14635a` | Links, active state, section numbering |
| `--accent-light` | `#1a8a7a` | Gradient partner for the accent |
| `--accent-deep` | `#0f5c4f` | Emphasised inline text, hover |
| `--rule` | `#e6dfd2` | Hairlines, borders, dividers |
| `--plate` | `#191b22` | Code block surface |
| `--plate-ink` | `#ece7dc` | Code block text |
| `--gold` | `#b08948` | Blockquote rule, secondary accent |
| `--gold-light` | `#d4b07a` | Gold gradient partner |
| `--rose` | `#a65d57` | Emphasis inside prose |
| `--violet` | `#6b5b95` | Reserved tertiary accent |
| `--surface-warm` | `#f5ede0` | Figure backing, callout wash |

Three of these are deliberately derived rather than literal. `--ink-soft` and
`--ink-faint` are `color-mix()` blends of the ink colour, so dropping opacity is
expressed relative to the text colour instead of against an assumed background.
That keeps the hierarchy intact if the palette changes.

## Dark mode

Dark mode is not a separate stylesheet. `render_theme_style()` redefines the
same tokens under `:root[data-theme="dark"]`, and mirrors them under
`:root:not([data-theme="light"])` so `prefers-color-scheme` works before any
JavaScript runs.

| Token | Dark value |
| --- | --- |
| `--page` | `color-mix(in oklab, #0c1018 91%, var(--accent))` |
| `--card` | `color-mix(in oklab, #151b26 93%, var(--accent))` |
| `--ink` | `#e8e4db` |
| `--rule` | `color-mix(in oklab, #e8e4db 15%, transparent)` |
| `--plate` | `color-mix(in oklab, #080b12 85%, var(--accent))` |
| `--plate-ink` | `#eae6dd` |
| `--gold` | `#d8b871` |

The dark surfaces are tinted toward the accent rather than being neutral grey.
Components that cannot be expressed by tokens alone — figures, callouts, table
headers, inline code, emphasis — carry explicit dark overrides so no element
keeps a light-mode background.

Because dark mode is token substitution, a component only needs to be reviewed
once. If it reads correctly in light mode and uses tokens, it is correct in dark
mode.

## Typography

Two families, assigned by role rather than by element.

- `--font-display` — `"Iowan Old Style", "Palatino Linotype", Palatino,
  "Book Antiqua", "Songti SC", STSong, "Noto Serif CJK SC", Georgia, serif`.
  Headings, section numbers, table headers.
- `--font-body` — `ui-sans-serif, -apple-system, "Segoe UI", "PingFang SC",
  "Microsoft YaHei", system-ui, sans-serif`. Body copy and interface chrome.
- `--font-mono` — `ui-monospace, "SF Mono", "Cascadia Code", "JetBrains Mono",
  Menlo, Consolas, monospace`. Code and measurements.

Both stacks list CJK faces before the generic fallback so Chinese text resolves
to a real serif/sans rather than a synthesised one.

### Scale

Sizes are fluid. The scale runs from `--step-neg2` to `--step-4`, and every step
except `--step-1` is a `clamp()` so the site scales with the viewport instead of
stepping at breakpoints.

| Step | Value |
| --- | --- |
| `--step-neg2` | `clamp(0.68rem, 0.66rem + 0.08vw, 0.74rem)` |
| `--step-neg1` | `clamp(0.78rem, 0.76rem + 0.09vw, 0.85rem)` |
| `--step-0` | `clamp(1.02rem, 0.99rem + 0.16vw, 1.12rem)` |
| `--step-1` | `1.26rem` |
| `--step-2` | `clamp(1.5rem, 1.26rem + 1.02vw, 1.95rem)` |
| `--step-3` | `clamp(2.05rem, 1.42rem + 2.6vw, 3rem)` |
| `--step-4` | `clamp(2.8rem, 2rem + 4vw, 4.2rem)` |

`--step-4` is reserved for the landing page. Documentation pages use `--step-3`
for the page title so a long title does not dominate the first screen.

## Layout

| Property | Value |
| --- | --- |
| Sidebar width | `272px` (fixed) |
| Content measure | `760px` |
| Reading measure | `68ch` |
| Two-column breakpoint | `1172px` |
| Narrow breakpoint | `1092px` |
| Mobile breakpoint | `760px` |

The sidebar is fixed and the content column is offset by `margin-left`, so
scrolling never moves the navigation.

The table-of-contents rail is a grid column, not a float. It only appears above
`1172px`; below that the TOC returns to the top of the page flow. The rail is
`position: sticky`, which requires the grid item to be `align-self: start` — a
stretched grid item has no room to travel and sticky would silently do nothing.

One structural detail is load-bearing. The rule that creates the second column
is written as `.content:has(> .toc)`, with the child combinator. `:has()` on its
own is descendant-based, so a bare `.content:has(.toc)` also matches when the
TOC has been nested a level deeper, and the two-column grid is then applied to
the wrong element. The child combinator states the actual precondition: the TOC
must be a direct child of the content container.

## Motion

Motion is limited to three places: link and control colour transitions
(`--ease: cubic-bezier(.2, .7, .2, 1)`, 200ms), a reading-progress bar, and the
figure hover scale. Nothing animates on load.

`@media (prefers-reduced-motion: reduce)` disables transitions and animations
globally, and `@media print` removes the sidebar, progress bar, theme toggle,
search, and copy buttons.

## Accessibility

- The skip link is the first focusable element on every page.
- Navigation marks the current page with `aria-current="page"`, and the TOC rail
  marks the current section with `aria-current="true"`.
- The theme toggle is a real `<button>` with `aria-pressed`.
- Search results are announced through `aria-live="polite"`.
- Copy buttons are revealed on hover **and** `:focus-visible`, so they remain
  keyboard reachable.
- Layout tokens are fixed values rather than viewport-scaled font sizes on the
  body copy, so browser text zoom up to 200% does not break the column.

## Verifying these values

Every number above is reproducible from a build:

```bash
moon run --target js cmd/moondockit \
  --source examples/site \
  --api pkg.generated.mbti \
  --output dist-showcase \
  --title "MoonDocKit" \
  --site-url "https://estrella-11.github.io/moonbit_1" \
  --language en \
  --description "MoonBit-first documentation site toolkit"

grep -o -- '--accent:[^;}]*'        dist-showcase/overview.html
grep -o 'aside{width:[^}]*}'        dist-showcase/overview.html
grep -o -- '--measure:[^;}]*'       dist-showcase/overview.html
```

`docs/assets/design-light.png` and `docs/assets/design-dark.png` are captures of
that output at a 1440px viewport. Regenerate them after any change to the theme
so the screenshots do not drift from the code.
