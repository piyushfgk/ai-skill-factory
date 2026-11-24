#!/usr/bin/env python3
"""Routing tests: check that each made-up brief in tests/routing/ pulls in the
skills it should, and not the ones it should not, by matching the brief
against every skill's metadata.signals (whole words, case-insensitive).

This is a smoke test of the signals, not of the kickoff's judgement: the
kickoff also weighs presets, phase and the user's answers.

Case file format (tests/routing/<case>.md):

    ---
    expect: asf-backend-engineer, asf-qa-engineer
    reject: asf-mobile-engineer
    ---
    <the brief, in plain words>

Usage: scripts/check_routing.py [-v]     exit code 1 if any case fails
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VERBOSE = "-v" in sys.argv[1:]


def frontmatter(text):
    if not text.startswith("---\n"):
        return {}, text
    head, _, body = text[4:].partition("\n---\n")
    data = {}
    for line in head.splitlines():
        key, sep, value = line.strip().partition(":")
        if sep:
            data[key.strip()] = value.strip().strip('"')
    return data, body


def split(value):
    return [v.strip() for v in value.split(",") if v.strip()]


def load_signals():
    skills = {}
    for md in sorted(ROOT.glob("*/*/skills/*/SKILL.md")):
        data, _ = frontmatter(md.read_text(encoding="utf-8"))
        name = data.get("name", md.parent.name)
        skills[name] = split(data.get("signals", ""))
    return skills


def hits(brief, signals):
    text = brief.lower()
    found = []
    for s in signals:
        pattern = r"(?<![a-z0-9])" + re.escape(s.lower()) + r"(?![a-z0-9])"
        if re.search(pattern, text):
            found.append(s)
    return found


def main():
    skills = load_signals()
    cases = [c for c in sorted((ROOT / "tests" / "routing").glob("*.md"))
             if c.name.lower() != "readme.md"]
    if not cases:
        print("no routing cases found in tests/routing/")
        return 1
    failed = 0
    for case in cases:
        data, brief = frontmatter(case.read_text(encoding="utf-8"))
        expect, reject = split(data.get("expect", "")), split(data.get("reject", ""))
        pulled = {n: h for n, s in skills.items() if (h := hits(brief, s))}
        problems = []
        for name in expect + reject:
            if name not in skills:
                problems.append(f"unknown skill {name}")
        problems += [f"expected {n}, no signal matched" for n in expect if n in skills and n not in pulled]
        problems += [f"rejected {n}, matched on: {', '.join(pulled[n])}" for n in reject if n in pulled]
        mark = "✗" if problems else "✓"
        print(f"{mark} {case.stem}")
        for p in problems:
            print(f"    {p}")
        if VERBOSE:
            for n in sorted(pulled):
                print(f"    · {n}: {', '.join(pulled[n])}")
        failed += bool(problems)
    print(f"\n{len(cases) - failed} of {len(cases)} routing cases passed.")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
