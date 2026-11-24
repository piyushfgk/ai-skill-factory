# AI Skill Factory

Plain-Markdown **role skills** that let one AI agent act as a specific industry
role: CTO, product manager, architect, frontend engineer, DevOps engineer,
designer and more.

Every skill follows the open [Agent Skills](https://agentskills.io/specification)
standard (`SKILL.md` + optional `references/`), so the same files work in
**Claude Code**, **Codex CLI**, **Gemini CLI** and other agents that support it.

## Skills

| Bundle | Skill | Roles | Use it to… |
|---|---|---|---|
| `it/leadership` | [`asf-cto`](it/leadership/skills/asf-cto/SKILL.md) | CTO, tech lead | choose a stack, decide build vs buy, plan milestones, cost and risk |
| `it/leadership` | [`asf-product-manager`](it/leadership/skills/asf-product-manager/SKILL.md) | Product manager, business analyst | write a PRD, user stories, MVP scope, metrics |
| `it/engineering` | [`asf-software-architect`](it/engineering/skills/asf-software-architect/SKILL.md) | Software architect, API designer | design the system, data model and API contracts |
| `it/engineering` | [`asf-frontend-engineer`](it/engineering/skills/asf-frontend-engineer/SKILL.md) | Frontend engineer, accessibility specialist | build fast, accessible, responsive UI |
| `it/engineering` | [`asf-devops-engineer`](it/engineering/skills/asf-devops-engineer/SKILL.md) | DevOps engineer, SRE | CI/CD, infra as code, hosting, monitoring, releases |
| `it/design` | [`asf-ui-ux-designer`](it/design/skills/asf-ui-ux-designer/SKILL.md) | UI designer, UX researcher | research, flows, wireframes, design system |

Skills are stack-neutral: they compare options and help you choose rather than
prescribing a framework or cloud.

**Starting a new web or mobile app?** Run them roughly in this order:
`asf-product-manager` → `asf-cto` → `asf-ui-ux-designer` →
`asf-software-architect` → `asf-devops-engineer` → `asf-frontend-engineer`.

## Install

### Claude Code (plugin marketplace)

```text
/plugin marketplace add piyushfgk/ai-skill-factory
/plugin install asf-it-leadership@ai-skill-factory
/plugin install asf-it-engineering@ai-skill-factory
/plugin install asf-it-design@ai-skill-factory
```

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
```

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

Next skills: backend developer, mobile developer (Android + iOS), QA engineer,
SEO specialist, marketing strategist.

## License

[GNU GPL v3.0](LICENSE)
