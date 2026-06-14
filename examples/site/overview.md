---
title: Why MoonDocKit
order: 0
tags: [overview, ecosystem, moonbit]
---
# Why MoonDocKit

MoonBit packages need more than source code. Maintainers also publish guides,
API contracts, examples, release notes, and deployment instructions.

MoonDocKit turns those materials into one deterministic static site while
keeping the domain pipeline in MoonBit.

## One Toolchain

- handwritten Markdown guides
- generated `.mbti` public interfaces
- stable routes and navigation
- searchable page and API content
- validation and quality scoring
- deployable static files

## MoonBit First

Parsing, routing, rendering, metrics, validation, search data, and API
extraction are implemented in MoonBit. The optional Node.js adapter only reads
and writes files.

## Reusable By Design

The core library returns `Array[OutputFile]`. A package can use the bundled CLI
or embed the deterministic manifest API in a different build workflow.
