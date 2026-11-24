#!/usr/bin/env bash
# Install AI Skill Factory skills for Claude Code, Codex CLI, Gemini CLI and Hermes Agent.
#
# Usage: scripts/install.sh [options] [skill-name ...]
#   (no skill names)     install every skill in the repo
#   --agent claude       only ~/.claude/skills          (Claude Code)
#   --agent agents       only ~/.agents/skills          (Codex CLI, Gemini CLI)
#   --agent hermes       only ~/.hermes/skills          (Hermes Agent)
#   --agent all          claude + agents (default). Hermes also reads a project's
#                        .agents/skills once you run `hermes skills trust`
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
#   --dry-run            print what would change, change nothing
#   --list               list available skills and exit
#   -h, --help           show this help
#
# Example (from a project root):
#   ~/ai-skill-factory/scripts/install.sh --project . --from .asf/project.md --phase build --gitignore
#
# Safety: the installer only replaces or removes what it created itself: symlinks that
# point into this repo, and copies that carry its .asf-installed marker. Anything else
# with the same name is left alone and reported as "kept".
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT="all"; BASE="$HOME"; MODE="link"; ACTION="install"; WANT=()
FROM=""; PHASE=""; PROJECT=""; GITIGNORE=""; DRY=""
MARKER=".asf-installed"

usage() { sed -n '2,34p' "$0" | sed 's/^# \{0,1\}//'; }

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
    --dry-run)   DRY=1; shift ;;
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
  hermes) TARGETS=("$BASE/.hermes/skills") ;;
  all)    TARGETS=("$BASE/.claude/skills" "$BASE/.agents/skills") ;;
  *) echo "--agent must be claude, agents, hermes or all" >&2; exit 2 ;;
esac

# Every directory that holds a SKILL.md under */skills/ is a skill.
mapfile -t SKILL_DIRS < <(find "$REPO_ROOT" -path "$REPO_ROOT/.git" -prune -o \
  -path '*/skills/*/SKILL.md' -exec dirname {} \; | sort)

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

# True if DEST was created by this installer: a symlink into this repo, or a copy with our marker.
owned() { # dest
  if [[ -L "$1" ]]; then
    local target; target="$(readlink "$1")"
    [[ "$target" == "$REPO_ROOT"/* ]]
  else
    [[ -d "$1" && -f "$1/$MARKER" ]]
  fi
}
say() { # verb path
  if [[ -n "$DRY" ]]; then printf 'would %-8s %s\n' "$1" "$2"; else printf '%-8s %s\n' "$1" "$2"; fi
}
ensure_dir() { [[ -n "$DRY" ]] || mkdir -p "$1"; }

place() { # src-dir dest [verb]
  local d="$1" dest="$2" verb="${3:-}"
  if [[ -e "$dest" || -L "$dest" ]]; then
    if ! owned "$dest"; then
      echo "kept     $dest (not created by this installer; remove or rename it yourself)" >&2
      return
    fi
    [[ -n "$DRY" ]] || rm -rf "$dest"
  fi
  if [[ "$MODE" == "copy" ]]; then
    say "${verb:-copy}" "$dest"
    [[ -n "$DRY" ]] || { cp -R "$d" "$dest"; printf 'Installed by AI Skill Factory scripts/install.sh. Safe to delete with --uninstall.\n' > "$dest/$MARKER"; }
  else
    say "${verb:-link}" "$dest"
    [[ -n "$DRY" ]] || ln -s "$d" "$dest"
  fi
}
unplace() { # dest
  [[ -e "$1" || -L "$1" ]] || return 0
  if ! owned "$1"; then
    echo "kept     $1 (not created by this installer)" >&2
    return 0
  fi
  say remove "$1"
  [[ -n "$DRY" ]] || rm -rf "$1"
}

for d in "${selected[@]}"; do
  name="$(basename "$d")"
  if [[ "$ACTION" == "uninstall" ]]; then
    for t in "${TARGETS[@]}"; do unplace "$t/$name"; done
    unplace "$BENCH/$name"
    continue
  fi
  if in_phase "$d" "$PHASE"; then
    for t in "${TARGETS[@]}"; do ensure_dir "$t"; place "$d" "$t/$name"; done
    unplace "$BENCH/$name" >/dev/null
  else
    for t in "${TARGETS[@]}"; do unplace "$t/$name"; done
    ensure_dir "$BENCH"; place "$d" "$BENCH/$name" bench
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
    gi="$BASE/.gitignore"; [[ -n "$DRY" ]] || touch "$gi"
    entries=(".asf/bench/" ".asf/*.local.md")
    if [[ "$MODE" == "link" ]]; then
      for t in "${TARGETS[@]}"; do entries+=("${t#"$BASE"/}/asf-*"); done
    fi
    for e in "${entries[@]}"; do
      if ! grep -qxF "$e" "$gi" 2>/dev/null; then
        say ignore "$e"
        [[ -n "$DRY" ]] && continue
        grep -qxF "# AI Skill Factory (scripts/install.sh --gitignore)" "$gi" || \
          printf '\n# AI Skill Factory (scripts/install.sh --gitignore)\n' >> "$gi"
        echo "$e" >> "$gi"
      fi
    done
  fi
fi

if [[ -n "$DRY" ]]; then echo "Dry run: nothing was changed."; exit 0; fi
if [[ "$ACTION" == "install" ]]; then
  [[ -n "$PHASE" ]] && echo "Phase '$PHASE': skills for other phases are parked in $BENCH."
  echo "Done. Restart your agent (or run /skills reload in Gemini CLI) to pick up new skills."
fi
