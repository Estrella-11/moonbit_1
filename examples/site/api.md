---
title: Library Guide
order: 2
tags: [reference, api]
---
# Library Guide

The public API separates source models, deterministic transformations, and
filesystem output.

## Pages

`DocPage` stores a source page with a title, slug, and Markdown body.

`DocSite` groups pages under one site title. `SiteOptions` and `SiteTheme`
control metadata and presentation without changing source content.

## Routes

`plan_routes` reads page metadata and creates deterministic page paths.

`parse_document` exposes front matter and the block AST for tools that need to
inspect or transform documentation before rendering.

## Output

`build_site_manifest` returns generated files without touching the filesystem.

`inspect_manifest`, `validate_site`, and `evaluate_quality` provide explainable
evidence before publication.

## Generated API

`parse_mbti` and `mbti_to_page` convert the interface produced by `moon info`
into the separate MoonBit API page shown in this site.
