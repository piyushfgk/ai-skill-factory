#!/usr/bin/env bash
# Install AI Skill Factory skills for Claude Code, Codex CLI and Gemini CLI.
#
# Usage: scripts/install.sh [options] [skill-name ...]
#   (no skill names)     install every skill in the repo
#   --agent claude       only ~/.claude/skills          (Claude Code)
#   --agent agents       only ~/.agents/skills          (Codex CLI, Gemini CLI)
#   --agent all          both (default)
#   --project DIR        install into DIR/.claude/skills and DIR/.agents/skills instead of $HOME
#   --from FILE          install the team listed in FILE (an .asf/project.md written by
#                        asf-project-kickoff); with --project, skills no longer in the team
#                        are removed from that project
#   --phase NAME         activate only skills whose metadata.phase includes NAME (or "all");
#                        the rest are parked in <base>/.asf/bench, which agents do not scan.
#                        NAME: discover, design, build, launch, operate
#   --gitignore          with --project: add .asf/bench/ and symlinked asf-* skill folders
#                        to the project's .gitignore (symlinks point into one person's clone)
#   --copy               copy files instead of symlinking (symlinks follow `git pull`)
#   --uninstall          remove the named (or all) asf-* skills installed from this repo
#   --list               list available skills and exit
#   -h, --help           show this help
#
# Example (from a project root):
#   ~/ai-skill-factory/scripts/install.sh --project . --from .asf/project.md --phase build --gitignore
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT="all"; BASE="$HOME"; MODE="link"; ACTION="install"; WANT=()
FROM=""; PHASE=""; PROJECT=""; GITIGNORE=""

usage() { sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; }

# Value of a one-line frontmatter key (top level or under metadata).
fm() { # file key
  awk -v key="$2" '
    NR==1 && $0!="---" {exit}
    NR>1 && $0=="---" {exit}
    NR>1 {
      line=$0; sub(/^[ \t]+/, "", line)
      if (index(line, key ":")==1) { v=substr(line, length(key)+2); sub(/^[ \t]+/, "", v); gsub(/^"|"$/, "", v); print v; exit }
    }' "$1"
}

# Skill names listed between <!-- asf:team --> and <!-- /asf:team --> (first asf-* name per line).
team_from() { # file
  awk '/<!--[[:space:]]*\/asf:team/ {on=0} on && match($0, /asf-[a-z0-9]+(-[a-z0-9]+)*/) {print substr($0, RSTART, RLENGTH)} /<!--[[:space:]]*asf:team/ {on=1}' "$1" | sort -u
}

# True if the skill in DIR is active in PHASE.
in_phase() { # dir phase
  local p; p="$(fm "$1/SKILL.md" phase)"
  [[ -z "$2" || -z "$p" ]] && return 0
  [[ ",${p// /}," == *",all,"* || ",${p// /}," == *",$2,"* ]]
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)     AGENT="${2:?--agent needs a value}"; shift 2 ;;
    --project)   BASE="$(cd "${2:?--project needs a directory}" && pwd)"; PROJECT=1; shift 2 ;;
    --from)      FROM="${2:?--from needs a file}"; shift 2 ;;
    --phase)     PHASE="${2:?--phase needs a value}"; shift 2 ;;
    --gitignore) GITIGNORE=1; shift ;;
    --copy)      MODE="copy"; shift ;;
    --uninstall) ACTION="uninstall"; shift ;;
    --list)      ACTION="list"; shift ;;
    -h|--help)   usage; exit 0 ;;
    -*)          echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)           WANT+=("$1"); shift ;;
  esac
done

if [[ -n "$PHASE" && ! "$PHASE" =~ ^(discover|design|build|launch|operate)$ ]]; then
  echo "--phase must be discover, design, build, launch or operate" >&2; exit 2
fi
if [[ -n "$FROM" ]]; then
  [[ -f "$FROM" ]] || { echo "No such file: $FROM" >&2; exit 1; }
  mapfile -t FROM_TEAM < <(team_from "$FROM")
  [[ ${#FROM_TEAM[@]} -gt 0 ]] || { echo "No skills found between <!-- asf:team --> and <!-- /asf:team --> in $FROM" >&2; exit 1; }
  WANT+=("${FROM_TEAM[@]}")
fi
BENCH="$BASE/.asf/bench"

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
    if [[ -z "$found" ]]; then
      if [[ -n "$FROM" ]]; then echo "missing  $w (not in this library yet; skipped)" >&2; continue; fi
      echo "No such skill: $w (try --list)" >&2; exit 1
    fi
    selected+=("$found")
  done
fi

place() { # src-dir dest
  local d="$1" dest="$2"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "skip     $dest (exists and is not a symlink; remove it or use --uninstall first)" >&2
    return
  fi
  rm -f "$dest"
  if [[ "$MODE" == "copy" ]]; then cp -R "$d" "$dest"; echo "copied   $dest"
  else ln -s "$d" "$dest"; echo "linked   $dest"; fi
}
unplace() { # dest
  if [[ -L "$1" || -d "$1" ]]; then rm -rf "$1"; echo "removed  $1"; fi
}

for d in "${selected[@]}"; do
  name="$(basename "$d")"
  if [[ "$ACTION" == "uninstall" ]]; then
    for t in "${TARGETS[@]}"; do unplace "$t/$name"; done
    unplace "$BENCH/$name"
    continue
  fi
  if in_phase "$d" "$PHASE"; then
    for t in "${TARGETS[@]}"; do mkdir -p "$t"; place "$d" "$t/$name"; done
    unplace "$BENCH/$name" >/dev/null
  else
    for t in "${TARGETS[@]}"; do [[ -L "$t/$name" || -d "$t/$name" ]] && unplace "$t/$name"; done
    mkdir -p "$BENCH"; place "$d" "$BENCH/$name" | sed 's/^linked  /benched /; s/^copied  /benched /'
  fi
done

# With --from in a project, remove asf-* skills that are no longer in the team.
if [[ "$ACTION" == "install" && -n "$FROM" && -n "$PROJECT" ]]; then
  for t in "${TARGETS[@]}" "$BENCH"; do
    [[ -d "$t" ]] || continue
    for dest in "$t"/asf-*; do
      [[ -e "$dest" || -L "$dest" ]] || continue
      name="$(basename "$dest")"
      [[ " ${WANT[*]} " == *" $name "* ]] || unplace "$dest"
    done
  done
fi

# With --gitignore in a project, keep machine-specific paths out of git.
if [[ "$ACTION" == "install" && -n "$GITIGNORE" ]]; then
  if [[ -z "$PROJECT" ]]; then
    echo "--gitignore only applies with --project; skipped" >&2
  else
    gi="$BASE/.gitignore"; touch "$gi"
    entries=(".asf/bench/")
    if [[ "$MODE" == "link" ]]; then
      for t in "${TARGETS[@]}"; do entries+=("${t#"$BASE"/}/asf-*"); done
    fi
    for e in "${entries[@]}"; do
      if ! grep -qxF "$e" "$gi"; then
        grep -qxF "# AI Skill Factory (scripts/install.sh --gitignore)" "$gi" || \
          printf '\n# AI Skill Factory (scripts/install.sh --gitignore)\n' >> "$gi"
        echo "$e" >> "$gi"; echo "ignored  $e"
      fi
    done
  fi
fi

if [[ "$ACTION" == "install" ]]; then
  [[ -n "$PHASE" ]] && echo "Phase '$PHASE': skills for other phases are parked in $BENCH."
  echo "Done. Restart your agent (or run /skills reload in Gemini CLI) to pick up new skills."
fi
