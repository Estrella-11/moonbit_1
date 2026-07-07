import argparse
import subprocess
import sys

from moon_tools import ROOT, deny_warn_is_unsupported, find_moon


MBTI_FILES = [
    "pkg.generated.mbti",
    "cmd/main/pkg.generated.mbti",
    "cmd/moondockit/pkg.generated.mbti",
    "examples/adoption-package/pkg.generated.mbti",
]


def run_capture(command: list[str]) -> subprocess.CompletedProcess[str]:
    print("$ " + " ".join(command))
    result = subprocess.run(
        command,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    if result.stdout:
        print(result.stdout, end="" if result.stdout.endswith("\n") else "\n")
    return result


def run_deny_warn_gate(moon: str, subcommand: str) -> int:
    direct = run_capture([moon, subcommand, "--deny-warn"])
    if direct.returncode == 0:
        return 0
    if not deny_warn_is_unsupported(direct.stdout):
        return direct.returncode
    print(
        "warning: current moon toolchain does not support --deny-warn; "
        f"falling back to a compatible `{subcommand}` gate."
    )
    if subcommand == "info":
        info = run_capture([moon, "info"])
        if info.returncode != 0:
            return info.returncode
        diff = run_capture(["git", "diff", "--exit-code", "--"] + MBTI_FILES)
        if diff.returncode != 0:
            print(
                "error: `moon info` changed generated interface files; "
                "commit the updated .mbti output."
            )
        return diff.returncode
    fallback = run_capture([moon, subcommand, "--dry-run"])
    return fallback.returncode


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run MoonBit hard-gate commands with toolchain compatibility fallback."
    )
    parser.add_argument(
        "gate",
        choices=["fmt", "info", "all"],
        help="Run one hard gate or both fmt and info gates.",
    )
    args = parser.parse_args()
    moon = find_moon()
    gates = ["fmt", "info"] if args.gate == "all" else [args.gate]
    for gate in gates:
        code = run_deny_warn_gate(moon, gate)
        if code != 0:
            return code
    return 0


if __name__ == "__main__":
    sys.exit(main())
