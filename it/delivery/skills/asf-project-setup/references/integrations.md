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
| 2. MCP server | No good CLI, or the server saves tokens or adds auth, rich data or a hosted sandbox | Its tool definitions load every session it is enabled (often 1k to 10k+ tokens) | Enable per project; turn off unused tools if the platform allows; trust only known publishers |
| 3. Custom CLI or script | An app with neither, or you need only 3 to 5 calls | None until called | You maintain it; keep it tiny and documented |
| Plain HTTP API calls | One-off reads | None | Easy to leak tokens in command history or logs |

Questions that settle a close call:

- Does the agent need this app every session, or once a week? Rare use favours a CLI.
- Is the data sensitive? Prefer the route with the narrowest token scope.
- Will humans use it too? A CLI they can run is easier to debug together.

### MCP scope rule

| Kind of server | Scope | Why |
|---|---|---|
| Small and used in most sessions (docs lookup, code search or memory) | All projects (user level) | Low, steady context cost that pays for itself |
| Heavy or task-specific (browser automation, test runners, large SaaS toolsets) | Per project, only where needed | Thousands of tokens of tool definitions per session |
| Covered by a CLI the agent knows (code hosts, cloud providers, databases) | Usually none; use the CLI | No standing context cost |

Record the choice per server in the site profile (machine-wide) or
`.asf/project.md` (project-specific).

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

### Per-task token rules

What is spent while working, and how to spend less. These work on any agent
that can run a sub-agent or switch models; where it cannot, the user can do
the same by hand.

1. **Route large inputs through a summariser.** A file, log, web page or tool
   result over about 2,000 tokens (roughly 8 KB of text) goes to a sub-agent
   or a smaller, cheaper model first. It returns only what the task needs:
   the answer, the relevant lines with their locations, and anything
   surprising. The main session never holds the raw input. Skip this when the
   task is to edit that exact file.
2. **Match the model to the task.** Agree three tiers with the user and
   record them in the setup record:

   | Tier | Typical work | Model |
   |---|---|---|
   | Easy | Search, summarise, rename, format, fill a template, read logs | Smallest or cheapest available |
   | Normal | Write and fix code, write tests, review a diff | Mid-size default |
   | Hard | Architecture, tricky debugging, security review, planning across many files | Largest available |

   Delegate easy and normal work to a sub-agent on the cheaper model where the
   platform allows it, and keep the largest model for the hard parts. When
   unsure, start one tier lower and move up if the result is weak.
3. **Use the lowest reasoning or effort setting that does the job** on
   platforms that have one: low for lookups and mechanical edits, higher only
   for planning and debugging.
4. **Hand off before the context gets long.** Long sessions cost more per turn
   and the agent gets worse at using what is in them. When a session passes
   about half of the model's context window (or about 200,000 tokens, whichever
   comes first), or switches to an unrelated task, write a handoff note and
   start a fresh session from it. Use the template below.
5. **Keep images small.** Screenshots and other images cost far more than the
   same information as text. Prefer reading page text or the accessibility
   tree; when an image is needed, capture only the relevant area at reduced
   size.

#### Handoff note

Save it as `.asf/handoff.md` (git-ignored, or commit it if the team wants a
record) and start the next session with "Read `.asf/handoff.md` and continue".

```markdown
# Handoff: <task> (<date>)

- Goal: <what done looks like>
- Done so far: <changes, with file paths, branch, PR or commit>
- Decisions and why: <choices made, options rejected>
- Current state: <what works, what fails, exact error if any>
- Next steps: <ordered list>
- Open questions for the user: <list, or none>
- Read first: <the few files or docs the next session needs>
```

### Claude Code only

Optional tips for teams on Claude Code; other agents can skip this.

- **Effort levels.** Set a lower effort for simple tasks and raise it only for
  hard ones; the setting and its command change between versions, so check
  the current docs.
- **Prompt cache.** Repeated context is cached for a few minutes (longer on
  some plans). Coming back to a long session after the cache expires re-reads
  the whole history at full price; for a long session, a handoff to a fresh
  one is often cheaper than resuming.
- **Sub-agent models.** A sub-agent definition can name a smaller model, which
  is how the tiers above are applied.
- **Usage checks.** Use the built-in cost or usage command to see where tokens
  went before tuning anything.

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
- Model tiers: easy <model>, normal <model>, hard <model>; handoff at <about N tokens>
```
