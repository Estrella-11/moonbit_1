import os
import shutil
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def find_moon() -> str:
    env_moon = os.environ.get("MOON")
    if env_moon:
        return env_moon
    for name in ["moon", "moon.exe"]:
        found = shutil.which(name)
        if found:
            return found
    home_bin = Path.home() / ".moon" / "bin"
    candidates = [
        home_bin / ("moon.exe" if sys.platform.startswith("win") else "moon"),
        home_bin / "moon",
        home_bin / "moon.exe",
    ]
    for candidate in candidates:
        if candidate.exists():
            return str(candidate)
    raise SystemExit(
        "moon executable was not found; install MoonBit and ensure `moon` is on PATH"
    )


def deny_warn_is_unsupported(output: str) -> bool:
    lowered = output.lower()
    return (
        "unexpected argument '--deny-warn'" in lowered
        or "unrecognized option '--deny-warn'" in lowered
        or "unknown option: --deny-warn" in lowered
    )
