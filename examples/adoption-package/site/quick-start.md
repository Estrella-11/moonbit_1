---
title: Quick Start
order: 2
tags: [guide, api]
---
# Quick Start

Install the package, prepare a sample, and call the statistics helpers.

```moonbit
let values = [1.0, 2.0, 3.0, 4.0]
let report = @sample_statkit.summarize(values)
```

The generated API page lists `mean`, `median`, `percentile`, and `summarize`
from the package interface. This lets users move from a short guide to exact
MoonBit declarations without searching the source tree.

## Release Gate

Before publishing docs, the package maintainer runs:

```bash
moon info
moon run --target js cmd/moondockit --config examples/adoption-package/moondockit.json --strict
```

Strict mode turns broken documentation into a release-blocking signal.
