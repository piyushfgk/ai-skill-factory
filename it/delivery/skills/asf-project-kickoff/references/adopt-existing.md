# Adopt an existing project

Use this when the folder already has code (detect mode "existing project").
The flow is the same as for a new project, with three changes: read the repo
before asking, pick the team by the user's **goal**, and keep everything the
project already has.

## 1. Read signals, not source

Run the read-only scan from the project root:

```bash
<this skill's folder>/scripts/detect.sh .
```

It prints mode, stack, CI, deploy, tests, web signals (PWA, SEO, analytics),
existing agent setup and a phase guess, in about 40 lines. If scripts can't
run, check the same things by hand, and only these:

- the top-level folder list (two levels at most);
- package or build manifests (names and dependency lists, not lockfile contents);
- CI, container, infrastructure and hosting config files;
- `README`, `CONTRIBUTING`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`;
- skills folders (`.claude/skills/`, `.agents/skills/`, `.gemini/skills/`) and MCP config;
- the last 20 commit subjects.

Do not read every source file. Open a source file only to answer a specific
question the signals leave open.

## 2. Show found vs guessed

Fill the profile and mark each line, then ask only about the guesses:

```markdown
| Item | Value | Source |
|---|---|---|
| Kind | Web app with public marketing pages | found: framework config, `src/pages` |
| Stack | TypeScript, <framework> | found: `package.json` |
| Hosting | <platform> | found: `<platform config file>` |
| CI | Lint and tests on pull requests | found: `.github/workflows/ci.yml` |
| Tests | 12 test files, no end-to-end | found |
| PWA | Manifest, no service worker | found |
| SEO | `robots.txt`, no sitemap | found |
| Analytics | Tag manager snippet, no consent banner | found |
| Phase | `launch` | guessed: deploy config, no release tags |
| Users and scale | ? | ask |
```

## 3. What the repo tells you

| What | Where to look (examples, any stack) | Pulls in |
|---|---|---|
| Kind of project | Web framework config, mobile folders, API route folders, notebooks | Frontend, mobile, architect, data skills |
| Languages and frameworks | Package and build manifests | Recorded; skills follow the existing stack |
| Hosting and infra | Container files, IaC folders, platform config | `asf-devops-engineer` |
| CI/CD | CI workflow files | `asf-devops-engineer` |
| Tests | Test folders and runner config | QA (planned) when missing or thin |
| PWA | Web app manifest, service worker | `asf-frontend-engineer` PWA reference |
| SEO | `robots.txt`, sitemap, meta tags, structured data | `asf-seo-specialist` |
| Analytics | Analytics or tag-manager snippets, consent banner | `asf-seo-specialist` |
| Tracker and code host | Issue templates, issue keys in commits | `asf-project-setup` |
| Agent setup | Instruction files, skills folders, MCP config | `asf-project-setup` (kept, not replaced) |

## 4. Phase from the repo

| Signals | Likely phase |
|---|---|
| Mostly docs or mockups, little code | `design` |
| Code, but no production deploy config | `build` |
| Deploy config, but no release tags, monitoring or error tracking | `launch` |
| Release tags, monitoring or error tracking, regular fixes | `operate` |

Always present the phase as a guess and let the user confirm it.

## 5. Ask the goal, then pick the team

Ask: **"What do you want the agent to do next on this project?"** Map the
answer to a goal preset in [presets.md](presets.md#goal-presets), then scale it
with the size presets.

Offer an **audit first** when the user isn't sure, or before a launch or
migration: run the checklists of the relevant skills against the repo
(production readiness, accessibility, technical SEO, and so on) and produce one
gap list. Each gap names the skill that owns it; that list then drives the team.

```markdown
| Gap | Evidence | Owner skill | Size |
|---|---|---|---|
| No sitemap | no `sitemap*.xml` found | asf-seo-specialist | S |
| No tested restore | no backup or restore docs | asf-devops-engineer | M |
```

## 6. Respect what exists

- **Instruction files.** Never rewrite `AGENTS.md`, `CLAUDE.md` or `GEMINI.md`.
  Show the `asf:pointer` block and append it to the file the user's agent reads,
  or replace an existing `asf:pointer` block. If only `CLAUDE.md` exists and the
  user works with several agents, *offer* to move shared rules into `AGENTS.md`
  and make `CLAUDE.md` import it (`@AGENTS.md`); never do it unasked.
- **Conventions win.** Record the project's code style, branch naming, commit
  format and test commands in the profile. Role skills follow the existing
  stack; they propose a new one only when the goal is a migration.
- **Other skills.** Leave skills that are not `asf-*` alone and list them in
  the profile. If one overlaps an asf skill (for example the team's own deploy
  skill), ask which one to keep. The installer only touches `asf-*` names and
  skips real folders it didn't create.
- **Tools already set up.** Record the existing tracker, MCP config and CI;
  hand gaps (not working setups) to `asf-project-setup`.
- **Monorepos.** One team at the repo root by default. If apps differ a lot,
  offer a team per app: write `.asf/project.md` inside that app's folder and run
  the installer with `--project <app folder>`. Agents that read skills from the
  working folder up to the repo root then see both.
- **Git.** Work on a branch if the project uses pull requests. Commit
  `.asf/project.md`. After asking, run the installer with `--gitignore` so
  `.asf/bench/` and symlinked skill folders stay out of git.
