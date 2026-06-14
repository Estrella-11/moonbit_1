---
title: Deployment
order: 4
tags: [deployment, github-pages, mooncakes]
---
# Deployment

MoonDocKit outputs ordinary static files and does not require a server runtime.

## GitHub Pages

The repository workflow runs the MoonBit CLI, verifies the generated MoonBit
API, uploads the static artifact, and deploys it through GitHub Pages.

## Other Hosts

The same output directory can be published to any service that hosts HTML,
JSON, XML, and text files.

## Package Release

`moon package` creates the mooncakes.io publication archive. The final release
flow verifies the package README, repository metadata, Apache-2.0 license, and
public API before running `moon publish`.
