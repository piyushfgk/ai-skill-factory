# Integrations, tracking and token budget

## Progress tracking

Use the tool the team already uses. If there is none, pick by team size.

| Option | Good for | Agent access | Trade-offs |
|---|---|---|---|
| `TASKS.md` or `docs/plan.md` in the repo | Solo, short projects | Plain file edits, no setup | No notifications or boards; merge conflicts with many writers |
| GitHub Issues + Projects | Code on GitHub, small to medium teams | `gh` CLI or an MCP server | Boards are simple; cross-repo planning is limited |
| GitLab Issues + Boards | Code on GitLab | `glab` CLI or API | Same as above for GitLab |
| Linear | Product teams that want speed and cycles | API, MCP server | Paid beyond small teams |
| Jira | Larger orgs, existing Jira process | CLI, API, MCP server | Heavy; agent needs a clear project and workflow mapping |
| Trello, Notion, others | Non-engineering stakeholders | API, MCP server | Weak link to code; keep task ids in commits |

Agree on a convention and write it in `.asf/project.md`:

- task id in the branch name and commit messages;
- when the agent moves a task (started, in review, done) and who closes it;
- where progress notes go (task comments, a changelog, the pull request).

## Choosing a route

For each app the agent must reach, take the first route that works.

| Route | Use when | Context cost | Watch out for |
|---|---|---|---|
| 1. Existing CLI (for example `gh`, `glab`, cloud CLIs, database clients) | A maintained CLI covers the tasks | None until called; output only | Auth stored on the machine; scope the token |
| 2. MCP server | No good CLI, or the server adds auth, rich data or a hosted sandbox | Its tool definitions load every session it is enabled (often 1k to 10k+ tokens) | Enable per project; turn off unused tools if the platform allows; trust only known publishers |
| 3. Custom CLI or script | An app with neither, or you need only 3 to 5 calls | None until called | You maintain it; keep it tiny and documented |
| Plain HTTP API calls | One-off reads | None | Easy to leak tokens in command history or logs |

Questions that settle a close call:

- Does the agent need this app every session, or once a week? Rare use favours a CLI.
- Is the data sensitive? Prefer the route with the narrowest token scope.
- Will humans use it too? A CLI they can run is easier to debug together.

## Custom CLI

When building one for the project:

- one file in `scripts/` or `.asf/tools/`, any language the project already uses;
- subcommands for only the calls the project needs (`list`, `get`, `create`…);
- `--help` that explains every subcommand in one line each, so the agent can
  discover it cheaply;
- reads credentials from an environment variable, never from arguments;
- prints compact output (JSON or short tables), with a `--limit` option;
- one line in `.asf/project.md` saying it exists and what it is for.

## Token budget

What is loaded every session, and how to keep it small:

| Always loaded | Keep it small by |
|---|---|
| Instruction file (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`) | Under about 100 lines; link to docs and `.asf/project.md` |
| Skill names and descriptions | Install only the project's team, only the current phase (`asf-project-kickoff`) |
| MCP tool definitions | Enable per project; disable servers and tools not in use |
| Files the agent reads to orient itself | Ignore build output, lockfiles, vendored and generated code, large data |

Habits that help: ask for summaries instead of full logs, run long searches in
a sub-agent where the platform has them, and start a fresh session for an
unrelated task.

## Setup record

Fill this into the "Setup" section of `.asf/project.md`:

```markdown
## Setup

- Agent platform: <Claude Code | Codex CLI | Gemini CLI | other>, runs <local | cloud | CI>
- Instruction file: <AGENTS.md (+ CLAUDE.md importing it) | GEMINI.md | ...>
- Tracker: <tool>, convention: <task id in branch and commits; agent moves to "In review">
- Code host: <host>, agent may <read | open PRs | merge after review>
- Integrations:
  - <app>: <CLI | MCP | custom CLI> (<why>), token scope: <scope>
- Install policy: <ask each time | allow-list: ... | container only | never>
- Tools: <runtime + version>, <package manager>, <linters>, <CLIs>
- Secrets: <env vars from an ignored .env | secret store>; names: <VAR_A, VAR_B>
```
