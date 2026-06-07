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
        "dist-example/quick-start.html",
        "dist-example/api.html",
        "dist-example/changelog.html",
        "dist-example/search-index.json",
    ]:
        require(path)


def main() -> None:
    for path in [
        "README.md",
        "LICENSE",
        "moon.mod",
        "docs/acceptance-guide.md",
        "docs/final-submission.md",
        "docs/release.md",
        "docs/mooncakes-publishing.md",
        ".github/workflows/ci.yml",
    ]:
        require(path)
    verify_pdf()
    verify_example_site()
    run([str(MOON), "check"])
    run([str(MOON), "test"])
    run([str(MOON), "run", "cmd/main"])
    print("Project verification passed.")


if __name__ == "__main__":
    main()
