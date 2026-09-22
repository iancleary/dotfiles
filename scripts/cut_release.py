#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""Create a validated, calendar-versioned nix-fleet release."""

from __future__ import annotations

import argparse
from datetime import date
from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parent.parent
VERSION_RE = re.compile(r"^\d{4}\.\d{2}\.\d{2}\.\d{2}$")


def run(*command: str) -> None:
    subprocess.run(command, cwd=ROOT, check=True)


def output(*command: str) -> str:
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )
    return result.stdout.strip()


def release_tags(tags: list[str]) -> list[str]:
    return [tag for tag in tags if VERSION_RE.fullmatch(tag)]


def current_version(tags: list[str]) -> str:
    versions = release_tags(tags)
    return max(versions, key=lambda version: tuple(map(int, version.split("."))), default="")


def next_version(tags: list[str], today: date) -> str:
    day = today.strftime("%Y.%m.%d")
    sequences = [
        int(tag.rsplit(".", 1)[1])
        for tag in release_tags(tags)
        if tag.startswith(f"{day}.")
    ]
    sequence = max(sequences, default=-1) + 1
    if sequence > 99:
        raise ValueError(f"Release sequence exhausted for {day}; maximum is .99")
    return f"{day}.{sequence:02d}"


def local_tags() -> list[str]:
    return output("git", "tag", "--list").splitlines()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", metavar="YYYY.MM.DD.XX", help="cut an explicit calendar release")
    parser.add_argument("--notes-file", type=Path, help="use curated Markdown instead of generated notes")
    parser.add_argument("--dry-run", action="store_true", help="validate and print the release plan without mutation")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--print-current-version", action="store_true", help="print the newest local release tag")
    mode.add_argument("--print-next-version", action="store_true", help="print today's next local release version")
    mode.add_argument(
        "--validate-version",
        metavar="YYYY.MM.DD.XX",
        help="validate one release version for release.toml",
    )
    return parser.parse_args()


def validate_version(version: str) -> None:
    if not VERSION_RE.fullmatch(version):
        raise ValueError(f"Release version must match YYYY.MM.DD.XX: {version}")
    year, month, day, sequence = map(int, version.split("."))
    date(year, month, day)
    if sequence > 99:
        raise ValueError(f"Release sequence must be between 00 and 99: {version}")


def main() -> None:
    args = parse_args()
    if args.print_current_version:
        print(current_version(local_tags()))
        return
    if args.print_next_version:
        print(next_version(local_tags(), date.today()))
        return
    if args.validate_version:
        validate_version(args.validate_version)
        return

    if args.version:
        validate_version(args.version)
    run("git", "fetch", "origin", "--tags")
    version = args.version or next_version(local_tags(), date.today())
    command = [
        "uv",
        "run",
        "--script",
        "scripts/release.py",
        "run",
        "--dry-run" if args.dry_run else "--apply",
        "--version",
        version,
        "--json",
    ]
    if args.notes_file:
        command.extend(("--notes-file", str(args.notes_file)))
    run(*command)


if __name__ == "__main__":
    try:
        main()
    except (subprocess.CalledProcessError, ValueError) as error:
        print(error, file=sys.stderr)
        raise SystemExit(1)
