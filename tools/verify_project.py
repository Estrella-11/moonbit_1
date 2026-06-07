import subprocess
import sys
from pathlib import Path

from pypdf import PdfReader


ROOT = Path(__file__).resolve().parents[1]
PYTHON = sys.executable


def run(command: list[str]) -> None:
    print("$ " + " ".join(command))
    subprocess.run(command, cwd=ROOT, check=True)


def require(path: str) -> Path:
    target = ROOT / path
    if not target.exists():
        raise SystemExit(f"missing required file: {path}")
    return target


def verify_pdf() -> None:
    pdf = require("docs/MoonDocKit-项目申报书.pdf")
    reader = PdfReader(str(pdf))
    if len(reader.pages) != 1:
        raise SystemExit("project proposal PDF must be exactly one page")
    text = reader.pages[0].extract_text() or ""
    if "MoonDocKit 项目申报书" not in text:
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
        "docs/release.md",
        "docs/mooncakes-publishing.md",
        ".github/workflows/ci.yml",
    ]:
        require(path)
    verify_pdf()
    verify_example_site()
    run([str(Path.home() / ".moon" / "bin" / "moon.exe"), "check"])
    run([str(Path.home() / ".moon" / "bin" / "moon.exe"), "test"])
    run([str(Path.home() / ".moon" / "bin" / "moon.exe"), "run", "cmd/main"])
    print("Project verification passed.")


if __name__ == "__main__":
    main()
