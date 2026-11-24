#!/usr/bin/env bash
# Install AI Skill Factory skills for Claude Code, Codex CLI and Gemini CLI.
#
# Usage: scripts/install.sh [options] [skill-name ...]
#   (no skill names)     install every skill in the repo
#   --agent claude       only ~/.claude/skills          (Claude Code)
#   --agent agents       only ~/.agents/skills          (Codex CLI, Gemini CLI)
#   --agent all          both (default)
#   --project DIR        install into DIR/.claude/skills and DIR/.agents/skills instead of $HOME
#   --copy               copy files instead of symlinking (symlinks follow `git pull`)
#   --uninstall          remove the named (or all) asf-* skills installed from this repo
#   --list               list available skills and exit
#   -h, --help           show this help
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT="all"; BASE="$HOME"; MODE="link"; ACTION="install"; WANT=()

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)     AGENT="${2:?--agent needs a value}"; shift 2 ;;
    --project)   BASE="$(cd "${2:?--project needs a directory}" && pwd)"; shift 2 ;;
    --copy)      MODE="copy"; shift ;;
    --uninstall) ACTION="uninstall"; shift ;;
    --list)      ACTION="list"; shift ;;
    -h|--help)   usage; exit 0 ;;
    -*)          echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)           WANT+=("$1"); shift ;;
  esac
done

case "$AGENT" in
  claude) TARGETS=("$BASE/.claude/skills") ;;
  agents) TARGETS=("$BASE/.agents/skills") ;;
  all)    TARGETS=("$BASE/.claude/skills" "$BASE/.agents/skills") ;;
  *) echo "--agent must be claude, agents or all" >&2; exit 2 ;;
esac

# Every directory that holds a SKILL.md under */skills/ is a skill.
mapfile -t SKILL_DIRS < <(find "$REPO_ROOT" -path "$REPO_ROOT/.git" -prune -o \
  -path '*/skills/*/SKILL.md' -print | xargs -r -n1 dirname | sort)

if [[ "$ACTION" == "list" ]]; then
  for d in "${SKILL_DIRS[@]}"; do printf '%-28s %s\n' "$(basename "$d")" "${d#"$REPO_ROOT"/}"; done
  exit 0
fi

selected=()
if [[ ${#WANT[@]} -eq 0 ]]; then
  selected=("${SKILL_DIRS[@]}")
else
  for w in "${WANT[@]}"; do
    found=""
    for d in "${SKILL_DIRS[@]}"; do [[ "$(basename "$d")" == "$w" ]] && found="$d"; done
    [[ -n "$found" ]] || { echo "No such skill: $w (try --list)" >&2; exit 1; }
    selected+=("$found")
  done
fi

for t in "${TARGETS[@]}"; do
  mkdir -p "$t"
  for d in "${selected[@]}"; do
    name="$(basename "$d")"; dest="$t/$name"
    if [[ "$ACTION" == "uninstall" ]]; then
      if [[ -L "$dest" || -d "$dest" ]]; then rm -rf "$dest"; echo "removed  $dest"; fi
      continue
    fi
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      echo "skip     $dest (exists and is not a symlink; remove it or use --uninstall first)" >&2
      continue
    fi
    rm -f "$dest"
    if [[ "$MODE" == "copy" ]]; then cp -R "$d" "$dest"; echo "copied   $dest"
    else ln -s "$d" "$dest"; echo "linked   $dest"; fi
  done
done

[[ "$ACTION" == "install" ]] && echo "Done. Restart your agent (or run /skills reload in Gemini CLI) to pick up new skills."
