---
title: API Reference
order: 2
tags: [reference, api]
---
# API Reference

The public API is built around a few small data models.

## Pages

`DocPage` stores a source page with a title, slug, and Markdown body.

## Routes

`plan_routes` reads page metadata and creates deterministic page paths.

## Output

`build_site_manifest` returns generated files without touching the filesystem.
