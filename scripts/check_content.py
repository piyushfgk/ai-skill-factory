#!/usr/bin/env python3
"""Content checks for scripts/validate.sh.

1. Frontmatter: every SKILL.md frontmatter parses as YAML (when PyYAML is
   installed) and every metadata value is a string.
2. Sensitive data: no real IP addresses, email addresses, private key paths,
   home-directory paths or tokens anywhere in the repo. This is a public
   library; site-specific details belong in a git-ignored *.local.md file.

Allowed: documentation IP ranges (192.0.2.0/24, 198.51.100.0/24,
203.0.113.0/24), 127.0.0.1, 0.0.0.0, network addresses written as CIDR
(for example 10.0.0.0/8), and example.com / example.org / example.net
addresses. Add "asf-scan: allow" on a line to accept a deliberate exception.

Usage: scripts/check_content.py [repo-root]     exit 1 on any finding
"""
import os
import re
import sys

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), ".."))
SKIP_DIRS = {".git", "node_modules"}
SKIP_FILES = {"LICENSE"}
TEXT_EXT = {".md", ".sh", ".json", ".yml", ".yaml", ".toml", ".txt", ".py", ".cfg", ".ini", ""}

IPV4 = re.compile(r"(?<![\w.])((?:\d{1,3}\.){3}\d{1,3})(/\d{1,2})?(?![\w.])")
EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}")
PATTERNS = [
    ("private key path", re.compile(r"\bid_(?:rsa|dsa|ecdsa|ed25519)(?:_[\w-]+)?\b|[\w-]+\.(?:pem|ppk|p12|pfx)\b")),
    ("home directory path", re.compile(r"(?:/home|/Users)/(?!user\b|<|\$|you\b|example\b)[A-Za-z0-9._-]+|C:\\\\?Users\\\\?(?!<|%|example\b)[A-Za-z0-9._-]+", re.I)),
    ("GitHub token", re.compile(r"\b(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,})")),
    ("GitLab token", re.compile(r"\bglpat-[A-Za-z0-9_-]{20,}")),
    ("AWS access key", re.compile(r"\b(?:AKIA|ASIA)[0-9A-Z]{16}\b")),
    ("Slack token", re.compile(r"\bxox[abposr]-[A-Za-z0-9-]{10,}")),
    ("Google API key", re.compile(r"\bAIza[0-9A-Za-z_-]{35}\b")),
    ("API secret key", re.compile(r"\bsk-(?:live_|proj-|ant-)?[A-Za-z0-9_-]{20,}")),
    ("private key block", re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")),
]
EXAMPLE_DOMAINS = re.compile(r"@(?:[\w-]+\.)*example\.(?:com|org|net)$|@example$", re.I)


def ip_allowed(ip, cidr):
    parts = [int(p) for p in ip.split(".")]
    if any(p > 255 for p in parts):
        return True  # not an IP (a version number or similar)
    if ip in ("127.0.0.1", "0.0.0.0", "255.255.255.255"):
        return True
    if ip.startswith(("192.0.2.", "198.51.100.", "203.0.113.")):
        return True
    if cidr and parts[3] == 0:
        return True  # a network written as CIDR, e.g. 10.0.0.0/8
    return False


def scan_file(path, rel, findings):
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.readlines()
    except (UnicodeDecodeError, OSError):
        return
    for no, line in enumerate(lines, 1):
        if "asf-scan: allow" in line:
            continue
        for m in IPV4.finditer(line):
            if not ip_allowed(m.group(1), m.group(2)):
                findings.append(f"{rel}:{no}: IP address {m.group(0)} (use 192.0.2.x, 198.51.100.x or 203.0.113.x in examples)")
        for m in EMAIL.finditer(line):
            addr = m.group(0)
            if addr.lower().startswith("git@") or EXAMPLE_DOMAINS.search(addr):
                continue
            findings.append(f"{rel}:{no}: email address {addr} (use an example.com address)")
        for label, rx in PATTERNS:
            m = rx.search(line)
            if m:
                findings.append(f"{rel}:{no}: {label} '{m.group(0)}'")


def check_frontmatter(path, rel, findings):
    try:
        import yaml  # noqa: PLC0415
    except ImportError:
        return False
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    if not text.startswith("---\n"):
        return True  # validate.sh reports this
    end = text.find("\n---", 4)
    try:
        data = yaml.safe_load(text[4:end]) or {}
    except yaml.YAMLError as exc:
        findings.append(f"{rel}: frontmatter is not valid YAML: {exc}".splitlines()[0])
        return True
    meta = data.get("metadata") or {}
    if not isinstance(meta, dict):
        findings.append(f"{rel}: metadata must be a mapping")
    else:
        for key, value in meta.items():
            if not isinstance(value, str):
                findings.append(f"{rel}: metadata.{key} must be a string (quote it)")
    return True


def main():
    findings = []
    yaml_checked = None
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            if name in SKIP_FILES or name.endswith(".local.md"):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, ROOT)
            if os.path.splitext(name)[1].lower() not in TEXT_EXT:
                continue
            scan_file(path, rel, findings)
            if name == "SKILL.md":
                yaml_checked = check_frontmatter(path, rel, findings)
    for f in findings:
        print(f"  ✗ {f}")
    if yaml_checked is False:
        print("  (PyYAML not installed: frontmatter YAML check skipped; pip install pyyaml)")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
