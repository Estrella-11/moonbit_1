# Configuration

MoonDocKit can be run entirely from command-line options or from a JSON
configuration file. The configuration path is useful for project repositories
because it keeps documentation builds repeatable in local terminals and CI.

## Example

```json
{
  "source": "examples/site",
  "output": "dist-cli-example",
  "api": "pkg.generated.mbti",
  "title": "MoonDocKit CLI Example",
  "site_url": "https://example.com/moondockit-cli",
  "language": "en",
  "description": "MoonDocKit documentation generated from a config file",
  "footer": "Built with `MoonDocKit`"
}
```

Run it with:

```bash
moon run --target js cmd/moondockit --config examples/moondockit.json
```

Command-line options override config-file values. For example, CI can keep the
shared configuration but change only the output directory:

```bash
moon run --target js cmd/moondockit --config examples/moondockit.json --output dist-ci
```

## Fields

- `source`: directory containing Markdown source files.
- `output`: directory where generated static files are written.
- `api`: optional generated `.mbti` file to include as MoonBit API
  documentation.
- `title`: generated documentation site title.
- `site_url`: optional public base URL for canonical and Open Graph metadata.
- `language`: HTML language code for generated pages.
- `theme`: page theme preset. Supported values are `default`, `package`,
  `api`, and `api-reference`.
- `description`: site description used in generated metadata.
- `footer`: Markdown-style inline footer content.

The JSON schema for editor hints and review is available at
`examples/moondockit.schema.json`.

## Diagnostics

When required inputs are missing or invalid, the CLI prints a stable
`MoonDocKit input error` line plus a `hint:` line that points users toward
`--config examples/moondockit.json` or explicit `--source` and `--output`
arguments. Quality-gate and strict-mode failures also print next-step hints so
CI logs explain how to recover.
