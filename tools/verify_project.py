import subprocess
import sys
from pathlib import Path

try:
    from pypdf import PdfReader
except ModuleNotFoundError:
    PdfReader = None


ROOT = Path(__file__).resolve().parents[1]
PYTHON = sys.executable
MOON = Path.home() / ".moon" / "bin" / "moon.exe"


def run(command: list[str]) -> None:
    print("$ " + " ".join(command))
    subprocess.run(command, cwd=ROOT, check=True)


def require(path: str) -> Path:
    target = ROOT / path
    if not target.exists():
        raise SystemExit(f"missing required file: {path}")
    return target


def verify_pdf() -> None:
    pdf = ROOT / "docs" / "MoonDocKit-项目申报书-附录二模板版.pdf"
    if not pdf.exists():
        raise SystemExit("missing required file: docs/MoonDocKit-项目申报书-附录二模板版.pdf")
    if PdfReader is None:
        print("warning: pypdf is not installed; skipped one-page PDF validation")
        return
    reader = PdfReader(str(pdf))
    if len(reader.pages) != 1:
        raise SystemExit("project proposal PDF must be exactly one page")
    text = reader.pages[0].extract_text() or ""
    if "MoonDocKit" not in text:
        raise SystemExit("project proposal PDF title was not found")


def verify_example_site() -> None:
    run([PYTHON, "tools/build_example_site.py"])
    for path in [
        "dist-example/overview.html",
        "dist-example/quick-start.html",
        "dist-example/api.html",
        "dist-example/quality.html",
        "dist-example/deployment.html",
        "dist-example/changelog.html",
        "dist-example/robots.txt",
        "dist-example/search-index.json",
        "dist-example/sitemap.xml",
    ]:
        require(path)


def verify_moonbit_cli() -> None:
    run(
        [
            str(MOON),
            "run",
            "--target",
            "js",
            "cmd/moondockit",
            "--source",
            "examples/site",
            "--api",
            "pkg.generated.mbti",
            "--output",
            "dist-cli-example",
            "--title",
            "MoonDocKit CLI Example",
            "--site-url",
            "https://example.com/moondockit-cli",
            "--language",
            "en",
            "--description",
            "MoonDocKit verification site",
            "--footer",
            "Verified by `MoonDocKit`",
        ]
    )
    for path in [
        "dist-cli-example/index.html",
        "dist-cli-example/api-reference.html",
        "dist-cli-example/overview.html",
        "dist-cli-example/quick-start.html",
        "dist-cli-example/api.html",
        "dist-cli-example/quality.html",
        "dist-cli-example/deployment.html",
        "dist-cli-example/changelog.html",
        "dist-cli-example/robots.txt",
        "dist-cli-example/search-index.json",
        "dist-cli-example/sitemap.xml",
    ]:
        require(path)
    overview = require("dist-cli-example/overview.html").read_text(encoding="utf-8")
    for marker in [
        "data-search-input",
        "data-search-results",
        "search-index.json",
        'name="description" content="MoonDocKit verification site"',
        "Verified by",
    ]:
        if marker not in overview:
            raise SystemExit(f"interactive search marker not found: {marker}")


def main() -> None:
    for path in [
        "README.md",
        "LICENSE",
        "moon.mod",
        "cmd/moondockit/moon.pkg",
        "docs/acceptance-guide.md",
        "docs/architecture.md",
        "docs/demo-script.md",
        "docs/deployment-runbook.md",
        "docs/final-submission.md",
        "docs/release.md",
        "docs/mooncakes-publishing.md",
        "tools/test_cli.py",
        ".github/workflows/ci.yml",
    ]:
        require(path)
    verify_pdf()
    verify_example_site()
    verify_moonbit_cli()
    run([PYTHON, "tools/test_cli.py"])
    run([str(MOON), "check"])
    run([str(MOON), "check", "--target", "js"])
    run([str(MOON), "test"])
    run([str(MOON), "run", "cmd/main"])
    print("Project verification passed.")


if __name__ == "__main__":
    main()
