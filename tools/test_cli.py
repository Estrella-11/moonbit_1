import json
import os
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MOON = Path.home() / ".moon" / "bin" / ("moon.exe" if shutil.which("moon.exe") else "moon")
CLI = ROOT / "_build" / "js" / "debug" / "build" / "cmd" / "moondockit" / "moondockit.js"


def run(command: list[str], *, expected: int = 0) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        command,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    if result.returncode != expected:
        raise AssertionError(
            f"expected exit {expected}, got {result.returncode}\n"
            f"$ {' '.join(command)}\n{result.stdout}"
        )
    return result


def require_text(path: Path, *markers: str) -> str:
    if not path.is_file():
        raise AssertionError(f"missing generated file: {path}")
    text = path.read_text(encoding="utf-8")
    for marker in markers:
        if marker not in text:
            raise AssertionError(f"{marker!r} not found in {path}")
    return text


def build_cli() -> None:
    run([str(MOON), "build", "--target", "js"])
    if not CLI.is_file():
        raise AssertionError(f"compiled CLI was not found: {CLI}")


def test_successful_build(workspace: Path) -> None:
    source = workspace / "site"
    output = workspace / "dist"
    source.mkdir()
    (source / "guide.md").write_text(
        "---\ntitle: Getting Started\norder: 1\ntags: [guide]\n---\n"
        "# Getting Started\n\nBuild **MoonBit** documentation.\n",
        encoding="utf-8",
    )
    (source / "reference.md").write_text(
        "---\ntitle: Library Reference\norder: 2\n---\n"
        "# Library Reference\n\nUse `build_site_manifest`.\n",
        encoding="utf-8",
    )
    interface = workspace / "package.mbti"
    interface.write_text(
        'package "acme/docs"\n\n// Values\npub fn build(String) -> String\n',
        encoding="utf-8",
    )

    result = run(
        [
            "node",
            str(CLI),
            "--source",
            str(source),
            "--output",
            str(output),
            "--api",
            str(interface),
            "--title",
            "Acme Docs",
            "--site-url",
            "https://example.com/docs",
            "--language",
            "zh-CN",
            "--description",
            "Acme MoonBit package documentation",
            "--footer",
            "Built with `MoonDocKit`",
        ]
    )
    for marker in ["quality: 100", "files: 8"]:
        if marker not in result.stdout:
            raise AssertionError(f"{marker!r} not found in CLI output")

    expected = {
        "api-reference.html",
        "guide.html",
        "index.html",
        "reference.html",
        "robots.txt",
        "search-index.json",
        "site-manifest.json",
        "sitemap.xml",
    }
    actual = {path.name for path in output.iterdir() if path.is_file()}
    if actual != expected:
        raise AssertionError(f"unexpected output files: {sorted(actual)}")

    guide = require_text(
        output / "guide.html",
        '<html lang="zh-CN">',
        'name="description" content="Acme MoonBit package documentation"',
        'href="https://example.com/docs/guide.html"',
        "Built with <code>MoonDocKit</code>",
        "data-search-input",
    )
    if "<strong>MoonBit</strong>" not in guide:
        raise AssertionError("inline Markdown was not rendered")

    require_text(
        output / "api-reference.html",
        "MoonBit API",
        "acme/docs",
        "pub fn build(String) -&gt; String",
    )
    search = json.loads((output / "search-index.json").read_text(encoding="utf-8"))
    paths = {entry["path"] for entry in search}
    if paths != {"guide.html", "reference.html", "api-reference.html"}:
        raise AssertionError(f"unexpected search paths: {sorted(paths)}")
    manifest = json.loads((output / "site-manifest.json").read_text(encoding="utf-8"))
    if manifest["file_count"] != 7:
        raise AssertionError("site manifest should describe generated files before itself")
    manifest_paths = {entry["path"] for entry in manifest["files"]}
    if "api-reference.html" not in manifest_paths or "search-index.json" not in manifest_paths:
        raise AssertionError(f"unexpected manifest paths: {sorted(manifest_paths)}")


def test_invalid_arguments() -> None:
    result = run(["node", str(CLI), "--unknown-option"], expected=2)
    if "unexpected argument" not in result.stdout:
        raise AssertionError("invalid-argument diagnostic was not printed")


def test_empty_site(workspace: Path) -> None:
    source = workspace / "empty"
    output = workspace / "empty-dist"
    source.mkdir()
    result = run(
        ["node", str(CLI), "--source", str(source), "--output", str(output)],
        expected=1,
    )
    for marker in [
        "quality gate failed",
        "empty-site",
        "hint: fix validation errors before publishing documentation",
    ]:
        if marker not in result.stdout:
            raise AssertionError(f"{marker!r} not found in empty-site diagnostic")
    if output.exists():
        raise AssertionError("failed quality gate must not write an output directory")


def test_missing_source(workspace: Path) -> None:
    result = run(
        [
            "node",
            str(CLI),
            "--source",
            str(workspace / "missing"),
            "--output",
            str(workspace / "missing-dist"),
        ],
        expected=1,
    )
    for marker in [
        "source directory not found",
        "hint: run with --config examples/moondockit.json",
    ]:
        if marker not in result.stdout:
            raise AssertionError(f"{marker!r} not found in missing-source diagnostic")


def test_output_path_must_be_directory(workspace: Path) -> None:
    source = workspace / "output-conflict-source"
    source.mkdir()
    (source / "guide.md").write_text("# Guide\n\nValid content.\n", encoding="utf-8")
    output = workspace / "output-file"
    output.write_text("not a directory", encoding="utf-8")
    result = run(
        ["node", str(CLI), "--source", str(source), "--output", str(output)],
        expected=1,
    )
    for marker in [
        "output path exists and is not a directory",
        "hint: run with --config examples/moondockit.json",
    ]:
        if marker not in result.stdout:
            raise AssertionError(f"{marker!r} not found in output-path diagnostic")


def test_config_file_build(workspace: Path) -> None:
    source = workspace / "config-site"
    output = workspace / "config-dist"
    source.mkdir()
    (source / "intro.md").write_text(
        "---\ntitle: Config Intro\norder: 1\n---\n"
        "# Config Intro\n\nConfigured documentation.\n",
        encoding="utf-8",
    )
    interface = workspace / "config-api.mbti"
    interface.write_text(
        'package "acme/config"\n\n// Values\npub fn configured() -> Unit\n',
        encoding="utf-8",
    )
    config = workspace / "moondockit.json"
    config.write_text(
        json.dumps(
            {
                "source": str(source),
                "output": str(output),
                "api": str(interface),
                "title": "Configured Docs",
                "site_url": "https://example.com/configured",
                "language": "en-US",
                "description": "Configured MoonDocKit site",
                "footer": "Configured with `MoonDocKit`",
            }
        ),
        encoding="utf-8",
    )
    run(["node", str(CLI), "--config", str(config)])
    require_text(
        output / "intro.html",
        '<html lang="en-US">',
        "Configured Docs",
        'name="description" content="Configured MoonDocKit site"',
        "Configured with <code>MoonDocKit</code>",
    )
    require_text(output / "api-reference.html", "acme/config", "configured")


def test_cli_overrides_config(workspace: Path) -> None:
    source = workspace / "override-site"
    output = workspace / "override-dist"
    configured_output = workspace / "configured-output"
    source.mkdir()
    (source / "guide.md").write_text("# Guide\n\nOverride content.\n", encoding="utf-8")
    config = workspace / "override.json"
    config.write_text(
        json.dumps({
            "source": str(source),
            "output": str(configured_output),
            "title": "Configured Title",
        }),
        encoding="utf-8",
    )
    run([
        "node",
        str(CLI),
        "--config",
        str(config),
        "--output",
        str(output),
        "--title",
        "CLI Title",
    ])
    require_text(output / "guide.html", "CLI Title")
    if configured_output.exists():
        raise AssertionError("CLI output option did not override config output")


def test_strict_mode_fails_on_validation_warnings(workspace: Path) -> None:
    source = workspace / "strict-site"
    output = workspace / "strict-dist"
    strict_output = workspace / "strict-failed-dist"
    source.mkdir()
    (source / "guide.md").write_text("# Guide\n\nUseful content.\n", encoding="utf-8")
    (source / "empty.md").write_text("", encoding="utf-8")

    result = run(["node", str(CLI), "--source", str(source), "--output", str(output)])
    for marker in ["diagnostics:", "warning empty-source"]:
        if marker not in result.stdout:
            raise AssertionError(f"{marker!r} not found in non-strict diagnostic")
    require_text(output / "guide.html", "Useful content")

    result = run(
        [
            "node",
            str(CLI),
            "--source",
            str(source),
            "--output",
            str(strict_output),
            "--strict",
        ],
        expected=1,
    )
    for marker in [
        "strict validation failed",
        "warning empty-source",
        "hint: remove warnings or run without --strict for local previews",
    ]:
        if marker not in result.stdout:
            raise AssertionError(f"{marker!r} not found in strict diagnostic")
    if strict_output.exists():
        raise AssertionError("strict validation failure must not write output")


def test_dry_run_reports_without_writing(workspace: Path) -> None:
    source = workspace / "dry-run-site"
    output = workspace / "dry-run-dist"
    source.mkdir()
    (source / "guide.md").write_text("# Guide\n\nPreview content.\n", encoding="utf-8")

    result = run([
        "node",
        str(CLI),
        "--source",
        str(source),
        "--output",
        str(output),
        "--dry-run",
    ])
    for marker in ["quality: 100", "dry-run: true", "files: 6"]:
        if marker not in result.stdout:
            raise AssertionError(f"{marker!r} not found in dry-run output")
    if output.exists():
        raise AssertionError("dry-run must not write an output directory")


def main() -> None:
    build_cli()
    workspace = ROOT / "_build" / f"cli-integration-{os.getpid()}"
    if workspace.exists():
        shutil.rmtree(workspace)
    workspace.mkdir(parents=True)
    try:
        test_successful_build(workspace)
        test_invalid_arguments()
        test_empty_site(workspace)
        test_missing_source(workspace)
        test_output_path_must_be_directory(workspace)
        test_config_file_build(workspace)
        test_cli_overrides_config(workspace)
        test_strict_mode_fails_on_validation_warnings(workspace)
        test_dry_run_reports_without_writing(workspace)
    finally:
        shutil.rmtree(workspace, ignore_errors=True)
    print("CLI integration tests passed: 9 scenarios.")


if __name__ == "__main__":
    main()
