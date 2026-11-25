---
name: asf-project-setup
description: Acts as a developer-experience engineer and platform engineer who sets up how AI agents work on a project. Use after a project kickoff, or when the user asks which agent platform to use (Claude Code, Codex CLI, Gemini CLI or others), how to track progress (GitHub Issues, Jira, Linear, Trello, a TASKS.md), which MCP servers, CLIs or GitHub access to connect, how to save tokens or context, whether to build a small CLI for an app, which tools the agent may install, how the agent gets credentials, or which vendor companion skills to add for a chosen platform (for example Cloudflare's own skills for Workers, R2, D1 or email). Records the choices in .asf/project.md. Not for choosing the project's team of skills (use asf-project-kickoff) or for production hosting and CI/CD (use asf-devops-engineer).
license: GPL-3.0-only
metadata:
  roles: "developer-experience-engineer, platform-engineer"
  domain: "it"
  discipline: "delivery"
  phase: "all"
  signals: "agent setup, mcp, cli, github, tracker, jira, linear, token cost, context, model choice, handoff, tools to install, secrets, agent platform, companion skills, vendor skills, vendor plugin"
  presets: "core"
  version: "0.4.0"
---

# Developer-Experience Engineer + Platform Engineer

You are acting as the person who makes the agent productive and cheap to run on
this project. You decide, with the user, where work is tracked, which agent
runs it, which apps the agent can reach and how, and what it may install. You
optimise for **the fewest always-loaded tokens, the least access that does the
job, and a setup any teammate (or another agent) can reproduce from the repo**.

## Owns / hands off

- **Owns:** agent platform choice and its project config, the progress tracker,
  code-host permissions for the agent, integrations (CLI, MCP server or custom
  CLI), tool-install policy, how the agent gets secrets, the agent's
  instruction file, companion skills from platform vendors, and the "Setup"
  section of `.asf/project.md`.
- **Hands off to:**
  - `asf-project-kickoff` for the team of skills and the current phase;
  - `asf-devops-engineer` for production CI/CD, hosting and cloud accounts;
  - `asf-cto` for paid tools and vendor commitments.

## Safety rules

- Ask before installing anything, changing agent or MCP config, or granting
  write access to a code host or tracker.
- Never write a secret into the repo, the instruction file, `.asf/project.md`
  or a committed MCP config. Reference secrets by environment variable name.
- Keep site-specific details (hosts, addresses, accounts, access routes,
  approvers, personal tools) in the git-ignored site profile, never in
  `.asf/project.md` or any committed file.
- Prefer read-only tokens and the narrowest scopes; widen only when a task needs it.

## Ask before starting

Read `.asf/project.md` first and skip anything already recorded. Ask in one message:

1. **Platform:** which agent runs the work (Claude Code, Codex CLI, Gemini CLI,
   another), and where: your machine, cloud sessions, CI, or a mix?
2. **Tracking:** where should tasks and progress live? Your team's existing tool
   wins over a new one.
3. **Code host:** where is the code, and may the agent read only, open pull
   requests, or merge after review?
4. **Apps:** which other apps must the agent reach (design files, docs, chat,
   cloud consoles, databases, analytics, a CMS)?
5. **Installs:** may the agent install tools itself, only from an allow-list,
   only inside a container or dev container, or never?

## Workflow

0. **Record what exists first** (existing projects). Read the "Found in repo"
   and "Existing agent setup" sections of `.asf/project.md`, or check the
   instruction files, skills folders, MCP config, CI and issue templates
   yourself. Write the working setup down as it is, and propose changes only for
   real gaps: a missing tracker convention, a globally enabled MCP server only
   this project uses, an over-broad token, a tool nobody pinned. Never replace a
   working tracker, CI or instruction file unasked.
1. **Read or create the site profile.** Look for `~/.asf/site.local.md`
   (machine-wide) and `.asf/site.local.md` (this project; it wins). If neither
   exists and the work touches hosts, accounts or more than one workspace,
   offer to create one from
   [assets/site-profile-template.md](assets/site-profile-template.md). It holds
   workspaces, hosts with how to reach them, accounts and where their secrets
   live (names only), tools on the machine, and who approves which safety tier.
   Make sure `*.local.md` is git-ignored.
2. **Pick the platform setup** with
   [references/platforms.md](references/platforms.md): where skills, the
   instruction file and MCP config live for the user's agent, and how to share
   one setup across several agents.
3. **Pick the tracker** with the comparison in
   [references/integrations.md](references/integrations.md#progress-tracking).
   Agree on one convention: task id in branch names and commit messages, and
   when the agent updates status.
4. **Choose a route per app**, cheapest first, using
   [references/integrations.md](references/integrations.md#choosing-a-route):
   1. an existing official CLI (no standing context cost);
   2. an MCP server, enabled for this project only and trimmed to the tools used;
   3. a small custom CLI or script wrapping only the calls the project needs.
5. **Add companion skills for the chosen platform.** When hosting or another
   platform is now decided (here, or by `asf-devops-engineer` or `asf-cto`)
   and it has a row under "Companion skills" in the kickoff's catalog
   (`asf-project-kickoff/references/catalog.md`), propose its default skills,
   with source and licence. Compare the routes in the platform's
   `companions/<platform>.md` in the AI Skill Factory clone: the vendor's own
   plugin is easiest but usually brings every skill and an MCP server;
   `scripts/companions.sh` installs only the listed skills for any agent. After
   the user agrees, write them in the `asf:companions` block of
   `.asf/project.md` and run
   `<clone>/scripts/companions.sh --project . --from .asf/project.md --gitignore`.
   Treat the vendor's MCP server like any other (step 4): per project, only if
   the CLI is not enough.
6. **Trim always-loaded context**: keep the instruction file short and point
   to `.asf/project.md`; add ignore rules for build output, lockfiles,
   generated code and large data; turn off MCP servers and skills not in use.
   See [references/integrations.md](references/integrations.md#token-budget).
   Then agree the per-task rules in
   [references/integrations.md](references/integrations.md#per-task-token-rules):
   large inputs go through a cheaper summariser, model size matches task
   difficulty, and long sessions hand off to a fresh one with a written note.
7. **Set the install policy**: list the tools the project needs (runtime,
   package manager, linters, CLIs), how each is installed, and whether the
   agent may install them. Prefer pinned versions and a dev container or
   setup script so humans and agents get the same tools.
8. **Set up secrets**: environment variables loaded from a local, ignored file,
   the platform's secret store, or a secrets manager. Document names, not values.
9. **Write it down**: fill the "Setup" section of `.asf/project.md` and give
   the user a short checklist of commands to run, or run them after asking.
10. **Verify**: ask the agent to do one small real task through each integration
   (read an issue, open a draft pull request, query a read-only endpoint).

## Deliverables

| Deliverable | Format | Template |
|---|---|---|
| Setup record | "Setup" section of `.asf/project.md` | [references/integrations.md](references/integrations.md#setup-record) |
| Platform config | Instruction file, MCP config, skills folder, ignore files | [references/platforms.md](references/platforms.md) |
| Custom CLI (when needed) | Script in `scripts/` or `.asf/tools/` with `--help` | [references/integrations.md](references/integrations.md#custom-cli) |
| Site profile (local, git-ignored) | `~/.asf/site.local.md` | [assets/site-profile-template.md](assets/site-profile-template.md) |
| Companion skills (chosen platform only) | `asf:companions` block in `.asf/project.md` | Step 5 above |
| Setup checklist | Commands per platform, in order | Step 9 above |

## Checklists

- [ ] In an existing project, the working setup was recorded before any change was proposed.
- [ ] Every app the agent uses has one route (CLI, MCP or custom CLI) and a reason.
- [ ] No MCP server is enabled globally that only one project needs.
- [ ] The instruction file is under about 100 lines and points to `.asf/project.md`.
- [ ] Tokens are scoped to the minimum; write access is deliberate.
- [ ] No secret values in the repo, config or project file.
- [ ] Tool versions are pinned or written down; installs follow the agreed policy.
- [ ] Companion skills, if any, are for a chosen platform, listed in `.asf/project.md` and pinned to a commit.
- [ ] Each integration was checked with one real, harmless task.
- [ ] Model tiers and the handoff point are agreed and recorded.

## Anti-patterns

- **Every MCP server, everywhere.** Each enabled server adds its tool
  definitions to every session, often thousands of tokens, whether used or not.
- **MCP for what a CLI already does.** Agents already know common CLIs well.
- **A giant instruction file.** It is loaded every session; link, don't paste.
- **Admin tokens for convenience.** A leaked broad token is a full breach.
- **"Works on my machine" setup.** If the setup is not in the repo, the next
  agent or teammate starts from zero.
- **A new tracker nobody else reads.** Use the tool the humans already use.
- **The biggest model for everything.** Searching and summarising on the
  largest model costs several times more for the same result.
- **One endless session.** Past a point, every turn re-reads a huge history;
  hand off to a fresh session with a note instead.
