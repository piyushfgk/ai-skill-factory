# Agent platforms

Where each agent looks for skills, instructions and MCP config. Agent tools
change quickly: confirm paths and commands against the platform's current docs
before writing config, and update this file when they move.

| | Claude Code | Codex CLI | Gemini CLI |
|---|---|---|---|
| Project skills | `.claude/skills/` | `.agents/skills/` (from the working folder up to the repo root) | `.gemini/skills/` or `.agents/skills/` |
| User skills | `~/.claude/skills/` | `~/.agents/skills/` | `~/.gemini/skills/` or `~/.agents/skills/` |
| Instruction file | `CLAUDE.md` (can import another file with `@AGENTS.md`) | `AGENTS.md` | `GEMINI.md` by default; can be set to read `AGENTS.md` in settings |
| MCP config | Project `.mcp.json`, or user settings; `claude mcp add` | `config.toml` under `~/.codex/` (`[mcp_servers.<name>]`); `codex mcp add` | `mcpServers` in `.gemini/settings.json` (project) or `~/.gemini/settings.json` |
| Install the library | Plugin marketplace, or `scripts/install.sh --agent claude` | `scripts/install.sh --agent agents` | `scripts/install.sh --agent agents`, or `gemini skills install` |

Other agents that support the Agent Skills standard usually read
`.agents/skills/`. Agents without skill support can be pointed at a
`SKILL.md` file directly.

## Choosing a platform

| Question | Why it matters |
|---|---|
| Which subscription or API account does the user already have? | Cost and rate limits usually decide it |
| Local only, or also cloud sessions and CI? | Cloud and CI runs need secrets and tools set up outside the laptop |
| Will several agents work on the same repo? | Then keep one shared setup (below) |
| Are sub-agents, hooks or sandboxes needed? | Support differs; check current docs for each |

Recommend the platform the user already pays for and knows, unless a needed
capability is missing there.

## One setup for several agents

- Keep the real instructions in `AGENTS.md`. Make `CLAUDE.md` a one-line
  `@AGENTS.md` import, and set Gemini to read `AGENTS.md` (or keep a short
  `GEMINI.md` that points to it).
- Install skills with `scripts/install.sh --project . --agent all`, which fills
  both `.claude/skills/` and `.agents/skills/`.
- Keep `.asf/project.md` as the single record of team, phase and setup.
- MCP config has no shared format across agents; keep each one minimal and list
  the servers in `.asf/project.md` so they stay in sync.

## What to commit

| Path | Commit? |
|---|---|
| `.asf/project.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` | Yes |
| `.claude/skills/`, `.agents/skills/` as symlinks | No: they point into one person's clone. Ignore them, or install with `--copy` and commit the copies |
| `.asf/bench/` | No (same reason) |
| Project MCP config | Yes, if it holds no secrets (use env var references) |
| `.env` and other secret files | Never; add to the ignore file |
