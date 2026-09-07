"""AI module performance benchmarks for MoonDocKit.

Measures build time and output size for each AI flag individually
and for the combined AI suite.
"""

import argparse
import json
import shutil
import subprocess
import time
from pathlib import Path

from moon_tools import find_moon

ROOT = Path(__file__).resolve().parents[1]
MOON = find_moon()
WORKSPACE = ROOT / "_build" / "ai_benchmark"

AI_FLAGS = [
    ("ai-doc", "--ai-doc"),
    ("ai-quality", "--ai-quality"),
    ("ai-summary", "--ai-summary"),
    ("ai-xref", "--ai-xref"),
    ("ai-coverage", "--ai-coverage"),
    ("ai-consistency", "--ai-consistency"),
    ("ai-seo", "--ai-seo"),
    ("ai-recommend", "--ai-recommend"),
    ("ai-tests", "--ai-tests"),
]


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=True,
    )


def build_output(output_dir: Path, flags: list[str]) -> dict:
    output_dir.parent.mkdir(parents=True, exist_ok=True)
    if output_dir.exists():
        shutil.rmtree(output_dir)

    cmd = [
        str(MOON), "run", "--target", "js", "cmd/moondockit",
        "--source", "examples/site",
        "--api", "pkg.generated.mbti",
        "--output", str(output_dir),
        "--title", "MoonDocKit AI Benchmark",
    ] + flags

    start = time.perf_counter()
    result = run(cmd)
    elapsed = time.perf_counter() - start

    total_bytes = 0
    file_count = 0
    if output_dir.exists():
        for f in output_dir.rglob("*"):
            if f.is_file():
                total_bytes += f.stat().st_size
                file_count += 1

    return {
        "elapsed_seconds": round(elapsed, 3),
        "file_count": file_count,
        "total_bytes": total_bytes,
        "exit_code": result.returncode,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="AI module benchmarks")
    parser.add_argument("--rounds", type=int, default=1, help="Rounds per flag")
    parser.add_argument("--output", type=str, default=None, help="Output JSON path")
    args = parser.parse_args()

    results: dict = {"flags": {}, "combined": {}}

    print("=== Baseline (no AI) ===")
    baseline_dir = WORKSPACE / "baseline"
    baseline = build_output(baseline_dir, [])
    print(f"  time={baseline['elapsed_seconds']}s files={baseline['file_count']} bytes={baseline['total_bytes']}")
    results["baseline"] = baseline

    for name, flag in AI_FLAGS:
        print(f"=== {name} ===")
        runs = []
        for i in range(args.rounds):
            output_dir = WORKSPACE / f"{name}_{i}"
            r = build_output(output_dir, [flag])
            runs.append(r)
            print(f"  round {i+1}: time={r['elapsed_seconds']}s files={r['file_count']} bytes={r['total_bytes']}")

        if args.rounds > 1:
            avg_time = sum(r["elapsed_seconds"] for r in runs) / len(runs)
            results["flags"][name] = {
                "flag": flag,
                "rounds": runs,
                "avg_time": round(avg_time, 3),
            }
        else:
            results["flags"][name] = {**runs[0], "flag": flag}

    print("=== Combined AI Suite ===")
    all_flags = [f for _, f in AI_FLAGS]
    combined_runs = []
    for i in range(args.rounds):
        output_dir = WORKSPACE / f"combined_{i}"
        r = build_output(output_dir, all_flags)
        combined_runs.append(r)
        print(f"  round {i+1}: time={r['elapsed_seconds']}s files={r['file_count']} bytes={r['total_bytes']}")

    results["combined"] = {
        "flags": all_flags,
        "rounds": combined_runs,
    }

    output_path = Path(args.output) if args.output else ROOT / "docs" / "ai-benchmark-results.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(results, indent=2), encoding="utf-8")
    print(f"\nResults saved to {output_path}")


if __name__ == "__main__":
    main()
