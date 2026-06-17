# Accessibility Notes

MoonDocKit's generated documentation pages are intentionally simple and
keyboard-friendly. This note records the current accessibility decisions and
remaining improvement areas.

## Implemented

- Navigation uses `nav aria-label="Documentation"`.
- Pages include a `Skip to content` link targeting the main content region.
- The active page link uses `aria-current="page"`.
- The search input has a real label associated with `for="site-search"`.
- Search results use `aria-live="polite"` so updates can be announced without
  interrupting the user.
- Search results are built with DOM text nodes instead of injected HTML.
- Focus styles are visible on the search input.
- The responsive layout keeps navigation available on small screens.
- `prefers-reduced-motion: reduce` disables smooth scrolling for users who
  request reduced motion.
- Generated image syntax requires alt text from the Markdown source.

## Content Guidance

Package authors should:

- use one `#` heading per page;
- write descriptive link text instead of "click here";
- provide meaningful image alt text;
- keep code blocks short enough to scan;
- use front matter titles so navigation labels stay clear.

## Current Limits

- The generated color palette is configurable but not automatically contrast
  tested.
- The search result list does not yet expose keyboard shortcut hints.
- The static Python example site is intentionally simpler than the MoonBit CLI
  generated site.

## Future Improvements

- Add automated checks for heading order and missing image alt text.
- Add a high-contrast theme preset.
- Add more keyboard-focused tests for search and navigation.
