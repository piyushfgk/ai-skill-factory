#!/usr/bin/env bash
# Install companion skills: a platform vendor's own Agent Skills, used next to the
# stack-neutral AI Skill Factory team once a project has chosen that platform.
# Each platform is described by one file in companions/ (see companions/README.md).
#
# Usage: scripts/companions.sh [options] [platform[:skill,skill] ...]
#   --list               list known platforms and their default skills, then exit
#   --show PLATFORM      print what a platform's file says (source, licence, skills)
#   --from FILE          install the companions listed between <!-- asf:companions -->
#                        and <!-- /asf:companions --> in FILE (an .asf/project.md); with
#                        --project, companion skills no longer listed are removed
#   --agent NAME         claude | agents | hermes | all (default all = claude + agents)
#   --project DIR        install into DIR/.claude/skills and DIR/.agents/skills, not $HOME
#   --ref REF            branch, tag or commit to fetch (overrides the file's ref)
#   --gitignore          with --project: git-ignore the symlinked companion folders
#   --copy               copy instead of symlinking into the local cache
#   --uninstall          remove the named (or listed) companion skills
#   --verify             fetch each platform's source and check its listed skills exist
#   --dry-run            print what would change, change nothing (no fetch)
#   -h, --help           show this help
#
# A platform with no skill list gets the file's default "skills". Examples:
#   scripts/companions.sh --list
#   scripts/companions.sh --project . cloudflare
#   scripts/companions.sh --project . cloudflare:cloudflare,wrangler,cf-cli
#   scripts/companions.sh --project . --from .asf/project.md --gitignore
#
# Sources are cloned (shallow) into ${ASF_CACHE:-$HOME/.cache/asf}/companions/<platform>.
# This fetches third-party content: review the source and licence before installing.
# Safety: only symlinks into that cache, or copies carrying the .asf-companion marker,
# are ever replaced or removed. Anything else with the same name is kept.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REG="$REPO_ROOT/companions"
CACHE="${ASF_CACHE:-$HOME/.cache/asf}/companions"
AGENT="all"; BASE="$HOME"; MODE="link"; ACTION="install"; WANT=()
FROM=""; PROJECT=""; GITIGNORE=""; DRY=""; REF_OVERRIDE=""
MARKER=".asf-companion"

usage() { sed -n '2,31p' "$0" | sed 's/^# \{0,1\}//'; }

fm() { # file key -> one-line frontmatter value
  awk -v key="$2" '
    NR==1 && $0!="---" {exit}
    NR>1 && $0=="---" {exit}
    NR>1 && index($0, key ":")==1 { v=substr($0, length(key)+2); sub(/^[ \t]+/, "", v); gsub(/^"|"$/, "", v); print v; exit }' "$1"
}
csv() { tr ',' '\n' <<<"$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$' || true; }
platforms() { for f in "$REG"/*.md; do [[ "$(basename "$f")" == README.md ]] || basename "$f" .md; done; }
reg_file() { # platform
  local f="$REG/$1.md"
  [[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && -f "$f" ]] || { echo "Unknown platform: $1 (try --list)" >&2; exit 1; }
  echo "$f"
}

# Entries between <!-- asf:companions --> and <!-- /asf:companions -->, as "platform[@ref]:a,b".
companions_from() { # file
  awk '/<!--[[:space:]]*\/asf:companions/ {on=0}
       on && match($0, /^[[:space:]]*-[[:space:]]+[a-z0-9@._-]+:/) {
         line=$0; sub(/^[[:space:]]*-[[:space:]]+/, "", line)
         p=substr(line, 1, index(line, ":")-1); rest=substr(line, index(line, ":")+1)
         sub(/\(.*$/, "", rest); gsub(/[[:space:]]/, "", rest); print p ":" rest }
       /<!--[[:space:]]*asf:companions/ {on=1}' "$1"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list)      ACTION="list"; shift ;;
    --show)      ACTION="show"; WANT+=("${2:?--show needs a platform}"); shift 2 ;;
    --from)      FROM="${2:?--from needs a file}"; shift 2 ;;
    --agent)     AGENT="${2:?--agent needs a value}"; shift 2 ;;
    --project)   BASE="$(cd "${2:?--project needs a directory}" && pwd)"; PROJECT=1; shift 2 ;;
    --ref)       REF_OVERRIDE="${2:?--ref needs a value}"; shift 2 ;;
    --gitignore) GITIGNORE=1; shift ;;
    --copy)      MODE="copy"; shift ;;
    --uninstall) ACTION="uninstall"; shift ;;
    --verify)    ACTION="verify"; shift ;;
    --dry-run)   DRY=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    -*)          echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)           WANT+=("$1"); shift ;;
  esac
done

case "$ACTION" in
  list)
    printf '%-14s %-10s %-14s %s\n' PLATFORM VERIFIED LICENSE "DEFAULT SKILLS (source)"
    while IFS= read -r p; do
      f="$REG/$p.md"
      printf '%-14s %-10s %-14s %s (%s)\n' "$p" "$(fm "$f" verified)" "$(fm "$f" license)" "$(fm "$f" skills)" "$(fm "$f" source)"
    done < <(platforms)
    exit 0 ;;
  show)
    f="$(reg_file "${WANT[0]}")"
    for k in title source ref path publisher license skills optional verified; do printf '%-10s %s\n' "$k:" "$(fm "$f" "$k")"; done
    exit 0 ;;
esac

if [[ -n "$FROM" ]]; then
  [[ -f "$FROM" ]] || { echo "No such file: $FROM" >&2; exit 1; }
  mapfile -t FROM_LIST < <(companions_from "$FROM")
  [[ ${#FROM_LIST[@]} -gt 0 ]] || { echo "No companions found between <!-- asf:companions --> and <!-- /asf:companions --> in $FROM" >&2; exit 1; }
  WANT+=("${FROM_LIST[@]}")
fi
if [[ "$ACTION" == "verify" && ${#WANT[@]} -eq 0 ]]; then mapfile -t WANT < <(platforms); fi
[[ ${#WANT[@]} -gt 0 ]] || { echo "Name a platform, or use --from or --list" >&2; usage >&2; exit 2; }

case "$AGENT" in
  claude) TARGETS=("$BASE/.claude/skills") ;;
  agents) TARGETS=("$BASE/.agents/skills") ;;
  hermes) TARGETS=("$BASE/.hermes/skills") ;;
  all)    TARGETS=("$BASE/.claude/skills" "$BASE/.agents/skills") ;;
  *) echo "--agent must be claude, agents, hermes or all" >&2; exit 2 ;;
esac

say() { if [[ -n "$DRY" ]]; then printf 'would %-8s %s\n' "$1" "$2"; else printf '%-8s %s\n' "$1" "$2"; fi; }
owned() { # dest: a symlink into the cache, or a copy with our marker
  if [[ -L "$1" ]]; then [[ "$(readlink "$1")" == "$CACHE"/* ]]; else [[ -d "$1" && -f "$1/$MARKER" ]]; fi
}

# Fetch PLATFORM's source at REF into the cache; print the checked-out commit.
fetch() { # platform url ref
  local dir="$CACHE/$1"
  mkdir -p "$CACHE"
  if [[ ! -d "$dir/.git" ]]; then git init -q "$dir"; git -C "$dir" remote add origin "$2"; fi
  git -C "$dir" remote set-url origin "$2"
  git -C "$dir" fetch -q --depth 1 origin "$3"
  git -C "$dir" checkout -q --detach FETCH_HEAD
  git -C "$dir" rev-parse HEAD
}

place() { # src dest
  if [[ -e "$2" || -L "$2" ]]; then
    owned "$2" || { echo "kept     $2 (not installed by companions.sh; remove or rename it yourself)" >&2; return; }
    [[ -n "$DRY" ]] || rm -rf "$2"
  fi
  if [[ "$MODE" == "copy" ]]; then
    say copy "$2"
    [[ -n "$DRY" ]] || { cp -R "$1" "$2"; printf 'Companion skill installed by AI Skill Factory scripts/companions.sh.\n' > "$2/$MARKER"; }
  else
    say link "$2"
    [[ -n "$DRY" ]] || ln -s "$1" "$2"
    LINKED+=("${2#"$BASE"/}")
  fi
}
unplace() { # dest
  [[ -e "$1" || -L "$1" ]] || return 0
  owned "$1" || { echo "kept     $1 (not installed by companions.sh)" >&2; return 0; }
  say remove "$1"
  [[ -n "$DRY" ]] || rm -rf "$1"
}

ALL_NAMES=(); LINKED=(); fail=0
for entry in "${WANT[@]}"; do
  spec="${entry%%:*}"; list=""; [[ "$entry" == *:* ]] && list="${entry#*:}"
  platform="${spec%%@*}"; ref=""; [[ "$spec" == *@* ]] && ref="${spec#*@}"
  f="$(reg_file "$platform")"
  url="$(fm "$f" source)"; sub="$(fm "$f" path)"
  ref="${REF_OVERRIDE:-${ref:-$(fm "$f" ref)}}"; ref="${ref:-main}"
  [[ -n "$list" ]] || list="$(fm "$f" skills)"
  if [[ "$ACTION" == "verify" ]]; then list="$(fm "$f" skills),$(fm "$f" optional)"; fi
  mapfile -t names < <(csv "$list")
  for n in "${names[@]}"; do
    [[ "$n" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || { echo "Bad skill name '$n' for $platform" >&2; exit 1; }
  done
  ALL_NAMES+=("${names[@]}")

  if [[ "$ACTION" == "uninstall" ]]; then
    for n in "${names[@]}"; do for t in "${TARGETS[@]}"; do unplace "$t/$n"; done; done
    continue
  fi

  echo "$platform: ${names[*]}"
  echo "  source $url ($ref), licence $(fm "$f" license), publisher $(fm "$f" publisher)"
  if [[ -n "$DRY" ]]; then
    say fetch "$CACHE/$platform"
    src_root="$CACHE/$platform/$sub"
  else
    commit="$(fetch "$platform" "$url" "$ref")"
    echo "  fetched commit $commit (pin it with $platform@$commit in .asf/project.md)"
    src_root="$CACHE/$platform/$sub"
  fi

  for n in "${names[@]}"; do
    if [[ -z "$DRY" && ! -f "$src_root/$n/SKILL.md" ]]; then
      echo "missing  $n (not in $url at $ref)" >&2; fail=1; continue
    fi
    [[ -z "$DRY" && -d "$src_root/$n/scripts" ]] && echo "  note: $n ships scripts; read them before letting the agent run them"
    [[ "$ACTION" == "verify" ]] && { echo "ok       $n"; continue; }
    for t in "${TARGETS[@]}"; do [[ -n "$DRY" ]] || mkdir -p "$t"; place "$src_root/$n" "$t/$n"; done
  done
done

# With --from in a project, remove companion skills that are no longer listed.
if [[ "$ACTION" == "install" && -n "$FROM" && -n "$PROJECT" ]]; then
  for t in "${TARGETS[@]}"; do
    [[ -d "$t" ]] || continue
    for dest in "$t"/*; do
      [[ -e "$dest" || -L "$dest" ]] || continue
      owned "$dest" || continue
      [[ " ${ALL_NAMES[*]} " == *" $(basename "$dest") "* ]] || unplace "$dest"
    done
  done
fi

if [[ "$ACTION" == "install" && -n "$GITIGNORE" ]]; then
  if [[ -z "$PROJECT" ]]; then echo "--gitignore only applies with --project; skipped" >&2
  elif [[ "$MODE" == "link" ]]; then
    gi="$BASE/.gitignore"; [[ -n "$DRY" ]] || touch "$gi"
    for e in "${LINKED[@]}"; do
      grep -qxF "$e" "$gi" 2>/dev/null && continue
      say ignore "$e"; [[ -n "$DRY" ]] && continue
      grep -qxF "# AI Skill Factory companions (scripts/companions.sh --gitignore)" "$gi" || \
        printf '\n# AI Skill Factory companions (scripts/companions.sh --gitignore)\n' >> "$gi"
      echo "$e" >> "$gi"
    done
  fi
fi

if [[ -n "$DRY" ]]; then echo "Dry run: nothing was fetched or changed."; exit "$fail"; fi
(( fail )) && { echo "Some skills were not found; check the platform file in companions/." >&2; exit 1; }
[[ "$ACTION" == "install" ]] && echo "Done. Restart your agent (or run /skills reload in Gemini CLI) to pick up new skills."
exit 0
