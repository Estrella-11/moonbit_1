import argparse
import json
import platform
import shutil
import statistics
import subprocess
import time
from datetime import date
from pathlib import Path

from moon_tools import find_moon


ROOT = Path(__file__).resolve().parents[1]
MOON = find_moon()
CLI_CANDIDATES = [
    ROOT / "_build" / "js" / "release" / "build" / "cmd" / "moondockit" / "moondockit.js",
    ROOT / "_build" / "js" / "debug" / "build" / "cmd" / "moondockit" / "moondockit.js",
]
WORKSPACE = ROOT / "_build" / "benchmark"


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=True,
    )


def find_cli() -> Path:
    for candidate in CLI_CANDIDATES:
        if candidate.is_file():
            return candidate
    raise SystemExit(
        "compiled CLI was not found; run `moon build --target js --release` first"
    )


def build_release_cli() -> None:
    run([str(MOON), "build", "--target", "js", "--release", "cmd/moondockit"])


def command_version(command: list[str]) -> str:
    try:
        return run(command).stdout.splitlines()[0]
    except (OSError, subprocess.CalledProcessError):
        return "unavailable in current environment"


def write_corpus(source: Path, page_count: int) -> None:
    source.mkdir(parents=True)
    for index in range(page_count):
        page_number = index + 1
        (source / f"page-{page_number:04}.md").write_text(
            "---\n"
            f"title: Guide {page_number}\n"
            f"order: {page_number}\n"
            "tags: [benchmark, guide]\n"
            "---\n"
            f"# Guide {page_number}\n\n"
            "MoonDocKit turns package notes into deterministic static output.\n\n"
            "## Workflow\n\n"
            "- parse front matter\n"
            "- plan routes\n"
            "- render safe HTML\n"
            "- build search data\n\n"
            "```mbt\n"
            f'let page_{page_number} = "benchmark"\n'
            "```\n",
            encoding="utf-8",
        )


def directory_size(directory: Path) -> int:
    return sum(path.stat().st_size for path in directory.rglob("*") if path.is_file())


def benchmark_case(cli: Path, page_count: int, rounds: int) -> dict[str, object]:
    case = WORKSPACE / f"pages-{page_count}"
    source = case / "source"
    write_corpus(source, page_count)
    timings: list[float] = []
    final_output = case / "output"

    for round_index in range(rounds):
        output = case / f"output-{round_index}"
        started = time.perf_counter()
        result = run(
            [
                "node",
                str(cli),
                "--source",
                str(source),
                "--output",
                str(output),
                "--title",
                f"MoonDocKit {page_count}-page benchmark",
                "--site-url",
                "https://example.com/benchmark",
            ]
        )
        timings.append((time.perf_counter() - started) * 1000)
        if "quality: 100" not in result.stdout:
            raise AssertionError("benchmark corpus did not pass the quality gate")
        if round_index == rounds - 1:
            final_output = output

    search = json.loads((final_output / "search-index.json").read_text(encoding="utf-8"))
    file_count = sum(1 for path in final_output.iterdir() if path.is_file())
    expected_files = page_count + 6
    if file_count != expected_files:
        raise AssertionError(f"expected {expected_files} files, got {file_count}")
    if len(search) != page_count:
        raise AssertionError(f"expected {page_count} search entries, got {len(search)}")

    return {
        "pages": page_count,
        "rounds": rounds,
        "median_ms": round(statistics.median(timings), 2),
        "min_ms": round(min(timings), 2),
        "max_ms": round(max(timings), 2),
        "output_files": file_count,
        "output_bytes": directory_size(final_output),
        "search_entries": len(search),
    }


def parse_counts(value: str) -> list[int]:
    counts = [int(item.strip()) for item in value.split(",") if item.strip()]
    if not counts or any(count <= 0 for count in counts):
        raise argparse.ArgumentTypeError("page counts must be positive integers")
    return counts


def main() -> None:
    parser = argparse.ArgumentParser(description="Benchmark the compiled MoonDocKit CLI.")
    parser.add_argument("--pages", type=parse_counts, default=[10, 100, 500])
    parser.add_argument("--rounds", type=int, default=3)
    parser.add_argument("--write", type=Path)
    args = parser.parse_args()
    if args.rounds <= 0:
        parser.error("--rounds must be positive")

    build_release_cli()
    cli = find_cli()
    if WORKSPACE.exists():
        shutil.rmtree(WORKSPACE)
    WORKSPACE.mkdir(parents=True)
    try:
        results = [benchmark_case(cli, count, args.rounds) for count in args.pages]
    finally:
        shutil.rmtree(WORKSPACE, ignore_errors=True)

    report = {
        "date": date.today().isoformat(),
        "platform": platform.platform(),
        "python": platform.python_version(),
        "node": run(["node", "--version"]).stdout.strip(),
        "moon": command_version([str(MOON), "version"]),
        "cli_build": "release" if "release" in cli.parts else "debug",
        "results": results,
    }
    rendered = json.dumps(report, indent=2, ensure_ascii=True) + "\n"
    print(rendered, end="")
    if args.write:
        target = args.write if args.write.is_absolute() else ROOT / args.write
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(rendered, encoding="utf-8")


if __name__ == "__main__":
    main()
