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
    for marker in ["quality: 100", "files: 7"]:
        if marker not in result.stdout:
            raise AssertionError(f"{marker!r} not found in CLI output")

    expected = {
        "api-reference.html",
        "guide.html",
        "index.html",
        "reference.html",
        "robots.txt",
        "search-index.json",
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
    for marker in ["quality gate failed", "empty-site"]:
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
    if "source directory not found" not in result.stdout:
        raise AssertionError("missing-source diagnostic was not printed")


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
    if "output path exists and is not a directory" not in result.stdout:
        raise AssertionError("output-path diagnostic was not printed")


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
    finally:
        shutil.rmtree(workspace, ignore_errors=True)
    print("CLI integration tests passed: 5 scenarios.")


if __name__ == "__main__":
    main()
