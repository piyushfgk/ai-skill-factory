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
the same by hand. [Platform notes](#platform-notes) say how to apply them on
Claude Code and Codex CLI.

1. **Route large inputs through a summariser.** A file, log, web page or tool
   result over about 2,000 tokens (roughly 8 KB of text) goes to a sub-agent
   or a smaller, cheaper model first. Tell it what the task needs; it returns
   only that: the answer, the relevant lines with their path and line
   numbers, and anything surprising. The main session never holds the raw
   input, but keeps the path so it can later read one exact range instead of
   the whole thing. Skip this when the task is to edit that exact file, or
   when the user asks for the full text.
2. **Match the model to the task.** Agree three tiers with the user and
   record them in the setup record:

   | Tier | Typical work | Model |
   |---|---|---|
   | Easy | Search, summarise, rename, format, fill a template, read logs | Smallest or cheapest available |
   | Normal | Write and fix code, write tests, review a diff | Mid-size default |
   | Hard | Architecture, tricky debugging, security review, planning across many files | Largest available |

   Delegate easy and normal work to a sub-agent on the cheaper model where the
   platform allows it, and keep the largest model for the hard parts. The two
   mistakes cost differently: too big a model wastes money, too small a model
   gives a weak result that has to be redone. So move a task **down** a tier
   only when it is clearly easy (mechanical, local, fully specified), keep the
   normal tier when unsure, and move **up** as soon as a result is weak.
3. **Pick the reasoning effort per task**, on platforms that have a setting
   for it. Go through these in order and stop at the first that fits:
   1. The message only approves or continues earlier work ("yes", "go on",
      "option 2"): keep the current level.
   2. Quick, mechanical or back-and-forth work (a lookup, a rename, a format
      fix, a short rewrite, a rough draft to iterate on): low.
   3. A hidden mistake would be costly (money, data loss, security,
      production, a decision someone will act on), or the task is to check
      other work: high.
   4. A long, hard and critical job that the user hands off and will not be
      around to answer questions about (all three true): the highest normal
      level. Use the maximum only when the user asks for it.
   5. Everything else: medium. When unsure, medium.

   A long task is not by itself a hard one; rule-following work stays low or
   medium. Set the level when a task starts, not on every message: on some
   platforms a mid-session change of model or effort throws the prompt cache
   away (rule 6).
4. **Hand off before the context gets long.** Long sessions cost more per turn
   and the agent gets worse at using what is in them. When a session passes
   about half of the model's context window (or about 200,000 tokens, whichever
   comes first), switches to an unrelated task, or comes back from a long break
   on a large history, write a handoff note and start a fresh session from it.
   Use the template below. Built-in compaction also shortens a session, but it
   is automatic and lossy; a written note is explicit, can be reviewed, and
   works in any agent.
5. **Keep images small.** Screenshots and other images cost far more than the
   same information as text. Prefer reading page text or the accessibility
   tree. When an image is needed, crop to the relevant area and scale its long
   side down to about half, keeping text readable; when only the layout
   matters, have a cheap model describe it in words. Take a full-size image
   only when fine detail is the point.
6. **Work with the prompt cache, not against it.** Platforms cache the
   repeated start of a conversation (instructions, tool definitions, history)
   for minutes, not hours. A reply inside that window re-reads the history at
   a fraction of the price; a reply after it pays full price for all of it.
   Work in focused bursts, keep the instruction file, tool list and model
   stable during a session, and after a long break on a large session prefer
   a handoff (rule 4) to resuming.

#### Handoff note

Save it as `.asf/handoff.md` (git-ignored, or commit it if the team wants a
record) and start the next session with "Read `.asf/handoff.md` and continue".
Keep it under about 1,500 words. Leave out sections with nothing in them.

```markdown
# Handoff: <task> (<date>)

- Goal: <what done looks like>
- Requests so far: <each thing the user asked for, in order, marked done, in progress or not started>
- Done so far: <changes, with file paths, branch, PR or commit>
- Decisions and why: <choices made, options rejected>
- Rules the user set: <standing constraints from this session: approvals, things never to do, tone, naming>
- Current state: <what works, what fails, exact error if any; what was tested and what was not>
- Errors already solved: <error: fix, so the next session does not hit them again>
- Data that lives only in this session: <ids, URLs, numbers, verbatim; nothing that is already on disk>
- Next steps: <ordered list; the first one specific enough to start without a question>
- Open questions for the user: <list, or none>
- Read first: <at most about 15 files or docs, each with one line on why; paths only, never file content>
```

Never write a key, token or password into the note; write where it lives
instead (for example "in the project's ignored `.env`").

### Platform notes

How the rules above map onto two common agents. Commands and settings change
between versions, so check the platform's current docs or `/help` before
relying on one. Other agents (Gemini CLI and others) have similar controls;
look them up the same way.

| Rule | Claude Code | Codex CLI |
|---|---|---|
| 1. Large inputs | Run the reading in a sub-agent; very large tool output is saved to a file and the agent gets a path | Run the reading in a sub-agent; `tool_output_token_limit` in `config.toml` caps how much tool output stays in context |
| 2. Model tiers | `model:` in a sub-agent's definition (`.claude/agents/<name>.md`), for example a small, mid or large model alias, or `inherit` | `[agents]` table in `~/.codex/config.toml`: `default_subagent_model` (a model named at spawn wins); a profile file per tier (`~/.codex/<name>.config.toml`, run with `codex --profile <name>`) |
| 3. Effort | `/effort`, or the effort setting in `/config` | `model_reasoning_effort` (levels depend on the model), `plan_mode_reasoning_effort` for plan mode, `default_subagent_reasoning_effort` for sub-agents; `/model` changes model and effort in a session |
| 4. Handoff | `/context` shows what fills the window; `/compact` summarises; `/clear` starts fresh from the note | `/status` shows token use; `/compact` summarises; `/new` starts fresh from the note; `model_auto_compact_token_limit` sets when it compacts on its own |
| 5. Images | Prefer page text or the accessibility tree in browser tools; ask for a cropped or smaller screenshot | Same; attach cropped, scaled-down images rather than full screenshots |
| 6. Prompt cache | Automatic; lasts about 5 minutes after the last reply by default, longer on some plans and settings | Automatic for prompts over about 1,024 tokens; usually kept for about 5 to 10 minutes idle, up to an hour; API users can ask for longer retention |
| Usage check | `/cost` or `/usage`, depending on plan | `/status` |

**Community add-ons.** Both ecosystems have community plugins, hooks and
status lines that automate some of these rules, such as a cache countdown, an
automatic effort picker or screenshot shrinking. They only work on the
platform they were written for, are often built for one operating system, and
are not always licensed for reuse. If the user wants one: read its code before
installing, install it per user rather than in the project, and note it in the
setup record. The rules above still apply without them.

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
- Model tiers: easy <model>, normal <model>, hard <model>; default effort <level>; handoff at <about N tokens>
- Agent add-ons: <none | plugin or hook, who installed it, why>
```
