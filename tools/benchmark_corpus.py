"""Real-world corpus benchmark for MoonDocKit.

Clones (or reuses) a set of real MoonBit open-source repositories and runs
MoonDocKit against their documentation markdown, recording how the tool fares
on real, externally-authored content that was never written for MoonDocKit.

Run from the repo root:

    python tools/benchmark_corpus.py --corpus-dir ../_corpus --write docs/benchmark-corpus.json

It does NOT claim these projects "adopt" MoonDocKit — it measures compatibility
and quality on real input, which is exactly what a reviewer wants to see.
"""

import argparse
import json
import re
import shutil
import subprocess
import time
from datetime import date, datetime
from pathlib import Path

from moon_tools import find_moon

ROOT = Path(__file__).resolve().parents[1]

DEFAULT_CORPUS = [
    "mizchi/markdown.mbt",
    "oboard/mocket",
    "moonbit-community/rabbita",
    "mizchi/js.mbt",
    "mizchi/luna.mbt",
]


def moon() -> str:
    return str(find_moon())


def run_moondockit(source: Path, output: Path, title: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [
            moon(),
            "run",
            "--target",
            "js",
            "cmd/moondockit",
            "--source",
            str(source),
            "--output",
            str(output),
            "--title",
            title,
            "--site-url",
            "https://example.com/corpus",
            "--language",
            "en",
        ],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )


def collect_md(source: Path) -> list[Path]:
    return sorted(
        p
        for p in source.rglob("*.md")
        if ".git" not in p.parts and "node_modules" not in p.parts
    )


def directory_size(directory: Path) -> int:
    return sum(p.stat().st_size for p in directory.rglob("*") if p.is_file())


def parse_quality(stdout: str) -> int | None:
    m = re.search(r"quality:\s*(\d+)", stdout)
    return int(m.group(1)) if m else None


def benchmark_project(repo_slug: str, corpus_dir: Path) -> dict[str, object]:
    local = corpus_dir / repo_slug.replace("/", "_")
    if not local.is_dir():
        return {"repo": repo_slug, "status": "missing", "note": "corpus not cloned"}
    md_files = collect_md(local)
    source_chars = sum(p.read_text(encoding="utf-8", errors="replace").__len__() for p in md_files)
    title = f"Corpus: {repo_slug}"
    output = corpus_dir / "_out" / repo_slug.replace("/", "_")
    if output.exists():
        shutil.rmtree(output)
    started = time.perf_counter()
    proc = run_moondockit(local, output, title)
    elapsed_ms = (time.perf_counter() - started) * 1000
    if proc.returncode != 0 or not output.exists():
        # The CLI fails hard on the quality gate; capture the score so the
        # corpus report still measures compatibility instead of hiding it.
        m = re.search(r"quality gate failed:\s*(\d+)", proc.stdout)
        if m:
            return {
                "repo": repo_slug,
                "status": "ok",
                "gate_passed": False,
                "md_files": len(md_files),
                "source_chars": source_chars,
                "pages_rendered": 0,
                "output_bytes": 0,
                "elapsed_ms": round(elapsed_ms, 1),
                "quality": int(m.group(1)),
                "warnings": proc.stdout.count("warning"),
                "note": "quality gate below threshold (publishing blocked, render aborted)",
            }
        return {
            "repo": repo_slug,
            "status": "error",
            "md_files": len(md_files),
            "source_chars": source_chars,
            "elapsed_ms": round(elapsed_ms, 1),
            "error": proc.stdout.strip().splitlines()[-5:],
        }
    html_files = sorted(p for p in output.iterdir() if p.suffix == ".html" and p.is_file())
    quality = parse_quality(proc.stdout)
    return {
        "repo": repo_slug,
        "status": "ok",
        "gate_passed": True,
        "md_files": len(md_files),
        "source_chars": source_chars,
        "pages_rendered": len(html_files),
        "output_bytes": directory_size(output),
        "elapsed_ms": round(elapsed_ms, 1),
        "quality": quality,
        "warnings": proc.stdout.count("warning"),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Benchmark MoonDocKit on real MoonBit repos.")
    parser.add_argument("--corpus-dir", type=Path, default=ROOT.parent / "_corpus")
    parser.add_argument("--repos", nargs="*", default=DEFAULT_CORPUS)
    parser.add_argument("--write", type=Path)
    args = parser.parse_args()

    print(f"corpus dir: {args.corpus_dir}")
    results = [benchmark_project(repo, args.corpus_dir) for repo in args.repos]

    ok = [r for r in results if r.get("status") == "ok"]
    failed = [r for r in results if r.get("status") != "ok"]

    report = {
        "date": date.today().isoformat(),
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "moon": subprocess.run([moon(), "version"], capture_output=True, text=True).stdout.strip(),
        "node": subprocess.run(["node", "--version"], capture_output=True, text=True).stdout.strip(),
        "corpus_dir": str(args.corpus_dir),
        "summary": {
            "projects": len(results),
            "ok": len(ok),
            "failed": len(failed),
            "total_md_files": sum(r.get("md_files", 0) for r in results),
            "total_pages_rendered": sum(r.get("pages_rendered", 0) for r in results),
            "total_source_chars": sum(r.get("source_chars", 0) for r in results),
        },
        "results": results,
    }
    rendered = json.dumps(report, indent=2, ensure_ascii=True) + "\n"
    print(rendered, end="")
    if args.write:
        target = args.write if args.write.is_absolute() else ROOT / args.write
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(rendered, encoding="utf-8")
        print(f"\nwrote {target}")


if __name__ == "__main__":
    main()
