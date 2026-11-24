#!/usr/bin/env bash
# Read-only scan of a project folder for asf-project-kickoff's adopt mode.
# Prints short facts (signals, not source code) so the agent does not have to
# open dozens of files. Changes nothing.
#
# Usage: detect.sh [project-dir]     (default: current folder)
set -uo pipefail

DIR="${1:-.}"
cd "$DIR" 2>/dev/null || { echo "No such folder: $DIR" >&2; exit 1; }

PRUNE='-name .git -o -name node_modules -o -name vendor -o -name dist -o -name build -o -name .next -o -name target -o -name .venv -o -name venv -o -name __pycache__ -o -name .asf -o -name .claude -o -name .agents -o -name .gemini'

# find limited to DEPTH levels, skipping heavy folders; prints paths without ./
f() { # depth find-args...
  local depth="$1"; shift
  # shellcheck disable=SC2086
  find . -maxdepth "$depth" \( $PRUNE \) -prune -o "$@" -print 2>/dev/null | sed 's|^\./||' | sort | head -n 40
}
has() { [[ -n "$(f "$@" | head -n 1)" ]]; }
line() { printf '%-22s %s\n' "$1" "${2:-none}"; }
join() { paste -sd',' - | sed 's/,/, /g'; }

echo "# detect.sh: $(pwd)"
echo

# Mode
src_count=$(f 4 -type f \( -name '*.js' -o -name '*.ts' -o -name '*.jsx' -o -name '*.tsx' -o -name '*.py' -o -name '*.php' -o -name '*.rb' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.kt' -o -name '*.swift' -o -name '*.cs' -o -name '*.dart' -o -name '*.vue' -o -name '*.svelte' -o -name '*.html' \) | wc -l | tr -d ' ')
commits=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then commits=$(git rev-list --count HEAD 2>/dev/null || echo 0); fi
if [[ -f .asf/project.md ]]; then mode="already adopted (.asf/project.md exists)"
elif (( src_count > 0 || commits > 5 )); then mode="existing project"
else mode="new project"; fi
line "mode:" "$mode"
line "source files (≤4 deep):" "$src_count$( (( src_count >= 40 )) && echo '+')"
line "git commits:" "$commits"
echo

# Layout
echo "## Top level"
for e in * .[!.]*; do
  [[ -e "$e" ]] || continue
  case "$e" in .git|node_modules|.DS_Store) continue ;; esac
  if [[ -d "$e" ]]; then echo "$e/"; else echo "$e"; fi
done | head -n 40 | join
echo

# Stack
echo "## Stack signals"
manifests=$(f 3 -type f \( -name package.json -o -name pyproject.toml -o -name requirements.txt -o -name Pipfile -o -name composer.json -o -name go.mod -o -name Cargo.toml -o -name Gemfile -o -name pom.xml -o -name 'build.gradle*' -o -name '*.csproj' -o -name pubspec.yaml -o -name Package.swift -o -name mix.exs \) | join)
line "manifests:" "$manifests"
lockfiles=$(f 3 -type f \( -name package-lock.json -o -name yarn.lock -o -name pnpm-lock.yaml -o -name bun.lockb -o -name poetry.lock -o -name uv.lock -o -name composer.lock -o -name Gemfile.lock -o -name Cargo.lock -o -name go.sum \) | join)
line "lockfiles:" "$lockfiles"
if [[ -f package.json ]]; then
  deps=$(tr -d '\n' < package.json | grep -oE '"(dependencies|devDependencies)"[[:space:]]*:[[:space:]]*\{[^}]*\}' \
    | sed -E 's/^"[a-zA-Z]+"[[:space:]]*:[[:space:]]*\{//' | grep -oE '"[^"]+"[[:space:]]*:' | sed -E 's/"//g; s/[[:space:]]*:$//' | head -n 30 | join)
  line "package.json deps:" "$deps"
fi
fwconf=$(f 2 -type f \( -name 'next.config.*' -o -name 'nuxt.config.*' -o -name 'vite.config.*' -o -name 'astro.config.*' -o -name 'svelte.config.*' -o -name 'angular.json' -o -name 'remix.config.*' -o -name 'gatsby-config.*' -o -name 'manage.py' -o -name 'artisan' -o -name 'wp-config.php' -o -name 'hugo.toml' -o -name '_config.yml' \) | join)
line "framework config:" "$fwconf"
mobile=$(f 2 -type d \( -name android -o -name ios \) | join)
line "mobile folders:" "$mobile"
echo

# Delivery
echo "## Build, deploy, operate"
line "ci:" "$(f 3 -type f \( -path './.github/workflows/*' -o -name .gitlab-ci.yml -o -name Jenkinsfile -o -name azure-pipelines.yml -o -path './.circleci/*' -o -name bitbucket-pipelines.yml \) | join)"
line "containers:" "$(f 3 -type f \( -name 'Dockerfile*' -o -name 'docker-compose*.y*ml' -o -name 'compose*.y*ml' \) | join)"
line "infra as code:" "$(f 3 \( -name '*.tf' -o -name 'Pulumi.yaml' -o -name 'serverless.y*ml' -o -name 'cdk.json' -o -name 'Chart.yaml' -o -name 'ansible.cfg' \) -type f | join)"
line "platform config:" "$(f 2 -type f \( -name vercel.json -o -name netlify.toml -o -name fly.toml -o -name render.yaml -o -name app.yaml -o -name Procfile -o -name 'firebase.json' -o -name wrangler.toml \) | join)"
line "release tags:" "$( (git tag 2>/dev/null | wc -l | tr -d ' ') || echo 0)"
line "monitoring hints:" "$( (grep -rIlE --exclude=detect.sh --exclude-dir={.git,node_modules,vendor,dist,build,.asf,.claude,.agents,.gemini} -m1 'sentry|bugsnag|rollbar|opentelemetry|newrelic|datadog' --include='*.json' --include='*.toml' --include='*.txt' --include='*.y*ml' . 2>/dev/null | sed 's|^\./||' | head -n 5 | join) || true)"
echo

# Quality
echo "## Tests and docs"
line "test folders:" "$(f 3 -type d \( -name test -o -name tests -o -name __tests__ -o -name spec -o -name e2e -o -name cypress -o -name playwright \) | join)"
line "test files (≤4 deep):" "$(f 4 -type f \( -name '*.test.*' -o -name '*.spec.*' -o -name 'test_*.py' -o -name '*_test.go' -o -name '*Test.php' \) | wc -l | tr -d ' ')"
line "docs:" "$(f 2 \( -name README.md -o -name CONTRIBUTING.md -o -name docs -o -name CHANGELOG.md \) | join)"
echo

# Web
echo "## Web signals"
line "pwa manifest:" "$(f 4 -type f \( -name manifest.webmanifest -o -name 'manifest.json' -o -name 'site.webmanifest' \) | grep -v node_modules | join)"
line "service worker:" "$(f 4 -type f \( -name 'sw.js' -o -name 'service-worker.*' -o -name 'serviceWorker.*' \) | join)"
line "robots / sitemap:" "$(f 4 -type f \( -name robots.txt -o -name 'sitemap*.xml' -o -name 'sitemap.*' \) | join)"
line "analytics hints:" "$( (grep -rIlE --exclude=detect.sh --exclude-dir={.git,node_modules,vendor,dist,build,.next,.asf,.claude,.agents,.gemini} -m1 'googletagmanager|gtag\(|google-analytics|plausible|matomo|umami|posthog|mixpanel|amplitude' . 2>/dev/null | sed 's|^\./||' | head -n 5 | join) || true)"
echo

# Agent setup
echo "## Existing agent setup"
line "instruction files:" "$(f 2 -type f \( -name AGENTS.md -o -name CLAUDE.md -o -name GEMINI.md -o -name '.cursorrules' -o -name 'copilot-instructions.md' \) | join)"
line "mcp config:" "$(f 2 -type f \( -name .mcp.json -o -path './.gemini/settings.json' -o -path './.codex/config.toml' -o -path './.vscode/mcp.json' \) | join)"
for sd in .claude/skills .agents/skills .gemini/skills; do
  [[ -d "$sd" ]] || continue
  asf=""; other=""
  for s in "$sd"/*; do
    [[ -e "$s" || -L "$s" ]] || continue
    n="${s##*/}"; if [[ "$n" == asf-* ]]; then asf+="${asf:+, }$n"; else other+="${other:+, }$n"; fi
  done
  line "$sd:" "asf: ${asf:-none}; other: ${other:-none}"
done
line "tracker hints:" "$(f 3 \( -path './.github/ISSUE_TEMPLATE' -o -path './.gitlab/issue_templates' -o -name '.jira*' -o -name 'TASKS.md' -o -name 'TODO.md' \) | join)"
if (( commits > 0 )); then
  keys=$(git log -20 --format=%s 2>/dev/null | grep -oE '\b[A-Z][A-Z0-9]+-[0-9]+\b|#[0-9]+' | head -n 5 | join)
  line "issue refs in commits:" "$keys"
fi
echo

# Monorepo
ws=$(f 2 -type d \( -name apps -o -name packages -o -name services \) | join)
[[ -f pnpm-workspace.yaml || -f lerna.json || -f nx.json || -f turbo.json || -n "$ws" ]] && { echo "## Monorepo"; line "workspaces:" "$ws"; echo; }

# Phase hint (a guess for the user to confirm)
tags=$(git tag 2>/dev/null | wc -l | tr -d ' ')
deploy=$(f 3 -type f \( -name vercel.json -o -name netlify.toml -o -name fly.toml -o -name render.yaml -o -name app.yaml -o -name Procfile -o -name '*.tf' -o -name 'Dockerfile*' -o -name 'serverless.y*ml' \) | head -n 1)
if (( src_count == 0 )); then phase="design"
elif [[ -z "$deploy" ]]; then phase="build"
elif (( tags == 0 )); then phase="launch"
else phase="operate"; fi
line "phase guess:" "$phase (confirm with the user)"
