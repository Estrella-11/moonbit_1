# Deployment and Release Runbook

## 1. Deploy the Public Showcase

After pushing `.github/workflows/pages.yml`:

1. Open the GitHub repository.
2. Go to `Settings`, then `Pages`.
3. Under `Build and deployment`, select `GitHub Actions` as the source.
4. Open the `Deploy showcase` workflow and run it if the push did not trigger
   it automatically.
5. Verify:
   https://estrella-11.github.io/moonbit_1/
6. Open the generated API directly:
   https://estrella-11.github.io/moonbit_1/api-reference.html

Current status: the public showcase and MoonBit API page are deployed and
accessible.

The workflow builds the site from `examples/site` with the MoonBit CLI. It does
not publish the checked-in generated directory.

The Actions run page is only a build and deployment record. The generated site
is opened through the `github-pages` environment link or the public URLs above.
The build summary lists every uploaded file and fails if `api-reference.html`
or its `parse_mbti` declaration is missing.

## 2. Publish to mooncakes.io

The package build has already passed:

```bash
moon package
```

Publishing and even `moon publish --dry-run` require local account credentials.
Log in, then publish:

```bash
moon login
moon publish
```

After publication, open the package page and verify that the README, repository,
license, version, and public API are displayed correctly.

## 3. Create the 0.1.0 Release

After Pages and mooncakes.io are available:

```bash
git tag -a v0.1.0 -m "MoonDocKit 0.1.0 competition release"
git push origin v0.1.0
git push gitlink v0.1.0
```

Create a GitHub release from `v0.1.0` using `docs/release.md` as the release
notes.

## 4. Final Evidence

Capture or link:

- green CI run;
- green Pages deployment;
- public showcase URL;
- mooncakes.io package page;
- GitHub and Gitlink repository heads;
- passing tests and the current coverage baseline;
- `docs/demo-script.md` and `docs/architecture.md`.

Only mark the final acceptance checklist complete after every public URL works
in a logged-out browser.
