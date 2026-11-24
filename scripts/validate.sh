#!/usr/bin/env bash
# Validate every skill against the Agent Skills spec and this repo's rules (see AGENTS.md).
# Usage: scripts/validate.sh            exit code 1 if any check fails
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0; count=0
err() { echo "  ✗ $*"; fail=1; }

# Print the value of a top-level or metadata key from YAML frontmatter (simple, one-line values).
fm() { # file key
  awk -v key="$2" '
    NR==1 && $0!="---" {exit}
    NR>1 && $0=="---" {exit}
    NR>1 {
      line=$0; sub(/^[ \t]+/, "", line)
      if (index(line, key ":")==1) { v=substr(line, length(key)+2); sub(/^[ \t]+/, "", v); gsub(/^"|"$/, "", v); print v; exit }
    }' "$1"
}

while IFS= read -r skill_md; do
  count=$((count+1))
  dir="$(dirname "$skill_md")"; folder="$(basename "$dir")"
  echo "• ${dir#"$REPO_ROOT"/}"

  [[ "$(head -n1 "$skill_md")" == "---" ]] || { err "SKILL.md must start with YAML frontmatter (---)"; continue; }

  name="$(fm "$skill_md" name)"
  desc="$(fm "$skill_md" description)"
  roles="$(fm "$skill_md" roles)"

  [[ -n "$name" ]] || err "missing name"
  [[ "$name" == "$folder" ]] || err "name '$name' must equal folder '$folder'"
  [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || err "name must be lowercase a-z, 0-9 and single hyphens"
  (( ${#name} <= 64 )) || err "name longer than 64 characters"
  [[ "$name" == asf-* ]] || err "name must start with asf-"

  [[ -n "$desc" ]] || err "missing description"
  (( ${#desc} <= 1024 )) || err "description is ${#desc} characters (max 1024)"

  if [[ -z "$roles" ]]; then err "metadata.roles is missing"
  else
    n=$(awk -F',' '{print NF}' <<<"$roles")
    (( n <= 2 )) || err "metadata.roles lists $n roles (max 2): $roles"
  fi

  # Fields the kickoff router relies on (see AGENTS.md).
  phase="$(fm "$skill_md" phase)"; presets="$(fm "$skill_md" presets)"; signals="$(fm "$skill_md" signals)"
  [[ -n "$signals" ]] || err "metadata.signals is missing"
  if [[ -z "$phase" ]]; then err "metadata.phase is missing"
  else for v in ${phase//,/ }; do
    [[ "$v" =~ ^(all|discover|design|build|launch|operate)$ ]] || err "metadata.phase has unknown value '$v'"
  done; fi
  if [[ -z "$presets" ]]; then err "metadata.presets is missing"
  else for v in ${presets//,/ }; do
    [[ "$v" =~ ^(core|solo|small|medium|large)$ ]] || err "metadata.presets has unknown value '$v'"
  done; fi

  # Only spec fields at the top level of the frontmatter.
  bad=$(awk 'NR==1{next} $0=="---"{exit} /^[A-Za-z_-]+:/{k=$0; sub(/:.*/, "", k); print k}' "$skill_md" \
        | grep -vxE 'name|description|license|compatibility|metadata' || true)
  [[ -z "$bad" ]] || err "non-portable frontmatter keys: ${bad//$'\n'/ }"

  grep -q '^## Safety tiers' "$skill_md" || err "missing a '## Safety tiers' section (see templates/SKILL.template.md)"

  lines=$(wc -l < "$skill_md")
  (( lines < 500 )) || err "SKILL.md has $lines lines (keep under 500; move detail to references/)"

  # Relative links must resolve.
  while IFS= read -r link; do
    [[ -e "$dir/$link" ]] || err "broken link: $link"
  done < <(grep -oE '\]\((references|scripts|assets)/[^)#]+' "$skill_md" | sed 's/^](//' | sort -u)
done < <(find "$REPO_ROOT" -path "$REPO_ROOT/.git" -prune -o -path '*/skills/*/SKILL.md' -print | sort)

# Duplicate skill names across bundles would clash once installed into one folder.
dupes=$(find "$REPO_ROOT" -path '*/skills/*/SKILL.md' -not -path '*/.git/*' -exec dirname {} \; | sed 's|.*/||' | sort | uniq -d)
[[ -z "$dupes" ]] || { echo "• duplicate skill names: $dupes"; fail=1; }

# Every bundle with a plugin.json must be in the marketplace.
mk="$REPO_ROOT/.claude-plugin/marketplace.json"
while IFS= read -r pj; do
  bundle="$(dirname "$(dirname "$pj")")"; rel="./${bundle#"$REPO_ROOT"/}"
  pname="$(grep -oE '"name"[^,]*' "$pj" | head -n1 | sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')"
  grep -q "\"$rel\"" "$mk" || { echo "• $rel is not listed in marketplace.json"; fail=1; }
  grep -q "\"name\": \"$pname\"" "$mk" || { echo "• plugin $pname is not listed in marketplace.json"; fail=1; }
done < <(find "$REPO_ROOT" -path "$REPO_ROOT/.claude-plugin" -prune -o -path '*/.claude-plugin/plugin.json' -print)

# The kickoff's catalog must match the skills' frontmatter.
if [[ -x "$REPO_ROOT/scripts/catalog.sh" ]]; then
  "$REPO_ROOT/scripts/catalog.sh" --check || { echo "• run scripts/catalog.sh and commit the result"; fail=1; }
fi

# No personal or secret data in a public repo; frontmatter is real YAML.
if command -v python3 >/dev/null 2>&1; then
  echo "• content scan (IPs, emails, key paths, tokens) and YAML frontmatter"
  python3 "$REPO_ROOT/scripts/check_content.py" "$REPO_ROOT" || fail=1
else
  echo "• python3 not found: content scan skipped (CI runs it)"
fi

# Optional: the reference validator from https://github.com/agentskills/agentskills
if command -v skills-ref >/dev/null 2>&1; then
  while IFS= read -r skill_md; do skills-ref validate "$(dirname "$skill_md")" || fail=1; done \
    < <(find "$REPO_ROOT" -path '*/skills/*/SKILL.md' -not -path '*/.git/*')
fi

echo
if (( fail )); then echo "Validation failed ($count skills checked)."; exit 1; fi
echo "All $count skills passed."
