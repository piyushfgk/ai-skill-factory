# AI Skill Factory

Plain-Markdown **role skills** that let one AI agent act as a specific industry
role: CTO, product manager, architect, frontend engineer, DevOps engineer,
designer and more.

Every skill follows the open [Agent Skills](https://agentskills.io/specification)
standard (`SKILL.md` + optional `references/`), so the same files work in
**Claude Code**, **Codex CLI**, **Gemini CLI** and other agents that support it.

## Start here

Don't install every skill. Install the kickoff and setup skills, give the
kickoff your project brief, and let it pick the team with you:

1. **`asf-project-kickoff`** reads your brief, asks up to five questions, and
   proposes a team preset: **Solo** (3 to 5 skills), **Small** (5 to 8),
   **Medium** (10 to 15) or **Large** (30 to 50), with a reason for every skill.
   You accept it or add and drop skills. For websites and web apps it also asks
   about PWA, rendering, SEO, search console and analytics.
2. It writes the decision to **`.asf/project.md`** in your project, so every
   later session, and every agent, reads the same team instead of guessing.
3. It installs only that team into the project, and only the skills for the
   current phase (discover, design, build, launch, operate). The rest wait in
   `.asf/bench/`, which agents don't scan.
4. **`asf-project-setup`** then sets up how the agent works: platform, progress
   tracker, code host access, and a route per app (existing CLI first, then a
   per-project MCP server, then a small custom CLI) to keep token use down.

Why: agents load the name and description of every installed skill in every
session and pick one skill per request by matching words. They never plan a
team by themselves, and with dozens of skills installed the descriptions cost
tokens and compete. A small, recorded, per-project team avoids both.

## Skills

| Bundle | Skill | Roles | Use it to… |
|---|---|---|---|
| `it/delivery` | [`asf-project-kickoff`](it/delivery/skills/asf-project-kickoff/SKILL.md) | Delivery lead, engagement manager | turn a brief into a confirmed team of skills, by preset and phase |
| `it/delivery` | [`asf-project-setup`](it/delivery/skills/asf-project-setup/SKILL.md) | Developer-experience engineer, platform engineer | choose agent platform, tracker, MCP servers or CLIs, install policy, secrets |
| `it/leadership` | [`asf-cto`](it/leadership/skills/asf-cto/SKILL.md) | CTO, tech lead | choose a stack, decide build vs buy, plan milestones, cost and risk |
| `it/leadership` | [`asf-product-manager`](it/leadership/skills/asf-product-manager/SKILL.md) | Product manager, business analyst | write a PRD, user stories, MVP scope, metrics |
| `it/engineering` | [`asf-software-architect`](it/engineering/skills/asf-software-architect/SKILL.md) | Software architect, API designer | design the system, data model and API contracts |
| `it/engineering` | [`asf-frontend-engineer`](it/engineering/skills/asf-frontend-engineer/SKILL.md) | Frontend engineer, accessibility specialist | build fast, accessible, responsive UI |
| `it/engineering` | [`asf-devops-engineer`](it/engineering/skills/asf-devops-engineer/SKILL.md) | DevOps engineer, SRE | CI/CD, infra as code, hosting, monitoring, releases |
| `it/design` | [`asf-ui-ux-designer`](it/design/skills/asf-ui-ux-designer/SKILL.md) | UI designer, UX researcher | research, flows, wireframes, design system |
| `it/growth` | [`asf-seo-specialist`](it/growth/skills/asf-seo-specialist/SKILL.md) | SEO specialist, web analytics specialist | technical SEO, keywords, search console, analytics and consent |

The full catalog, with each skill's phase, presets and signals, is in
[`asf-project-kickoff/references/catalog.md`](it/delivery/skills/asf-project-kickoff/references/catalog.md).

Skills are stack-neutral: they compare options and help you choose rather than
prescribing a framework or cloud.

**Starting a new web or mobile app?** Start with `asf-project-kickoff`. Without
it, run the roles roughly in this order: `asf-product-manager` → `asf-cto` →
`asf-ui-ux-designer` → `asf-software-architect` → `asf-devops-engineer` →
`asf-frontend-engineer` → `asf-seo-specialist`.

## Install

### Claude Code (plugin marketplace)

```text
/plugin marketplace add piyushfgk/ai-skill-factory
/plugin install asf-it-delivery@ai-skill-factory      # kickoff + setup: start here
/plugin install asf-it-leadership@ai-skill-factory
/plugin install asf-it-engineering@ai-skill-factory
/plugin install asf-it-design@ai-skill-factory
/plugin install asf-it-growth@ai-skill-factory
```

Plugins install whole bundles. To install only the skills your project's team
needs, use `scripts/install.sh --from` below.

Skills then activate automatically when relevant, or run one directly, for
example `/asf-it-leadership:asf-cto`.

### Codex CLI, Gemini CLI and others (`~/.agents/skills`)

```bash
git clone https://github.com/piyushfgk/ai-skill-factory.git
cd ai-skill-factory
./scripts/install.sh                     # all skills, for Claude Code + Codex + Gemini
./scripts/install.sh --agent agents      # only ~/.agents/skills (Codex, Gemini)
./scripts/install.sh asf-cto asf-devops-engineer   # just some skills
./scripts/install.sh --project ~/code/my-app       # into one project instead of $HOME
./scripts/install.sh --list

# Per project, from the team that asf-project-kickoff wrote:
cd ~/code/my-app
~/ai-skill-factory/scripts/install.sh --project . --from .asf/project.md --phase design
```

`--from` installs the skills listed in `.asf/project.md` and removes ones that
are no longer in the team. `--phase` keeps only that phase's skills active and
parks the rest in `.asf/bench/`. Run it again with the next phase when you move on.

The script symlinks each skill folder, so `git pull` updates them. Use `--copy`
to copy instead, and `--uninstall` to remove them.

| Agent | Where it looks | Notes |
|---|---|---|
| Claude Code | `~/.claude/skills/`, `.claude/skills/` | Or use the plugin marketplace above |
| Codex CLI | `~/.agents/skills/`, `.agents/skills/` (cwd up to repo root) | Use `/skills` or `$asf-cto` to invoke |
| Gemini CLI | `~/.gemini/skills/` or `~/.agents/skills/`, workspace `.agents/skills/` | Also: `gemini skills install https://github.com/piyushfgk/ai-skill-factory.git --path it/leadership/skills/asf-cto` |

### Any other agent

Point the agent at a `SKILL.md` file and ask it to follow it, or paste the file
into its instructions. The skills use no agent-specific tools.

## Repository layout

```
.claude-plugin/marketplace.json     # Claude Code marketplace: lists the bundles
AGENTS.md                           # rules for writing skills (CLAUDE.md imports it)
templates/SKILL.template.md         # copy this to start a new skill
scripts/install.sh                  # install into Claude / Codex / Gemini skill folders
scripts/catalog.sh                  # regenerate the kickoff's skill catalog from frontmatter
scripts/validate.sh                 # check every skill against the spec and repo rules
it/<discipline>/                    # a bundle, also a Claude Code plugin
  .claude-plugin/plugin.json
  skills/asf-<role>/SKILL.md
  skills/asf-<role>/references/*.md
```

## Contributing

Read [AGENTS.md](AGENTS.md). In short: names start with `asf-`, one skill covers
at most two roles, `SKILL.md` stays under 500 lines, and `./scripts/validate.sh`
must pass.

## Roadmap

Next skills, in preset order: backend engineer, QA engineer, security engineer,
mobile engineer (Android + iOS), data analyst, technical writer, then the
Large-preset groups (reliability, data and ML, compliance, growth, customers).

## License

[GNU GPL v3.0](LICENSE)
