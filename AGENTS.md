# AGENTS.md — rules for working in this repository

This repository is a library of **role skills**: plain-Markdown files that let a
single AI agent (Claude Code, Codex CLI, Gemini CLI or any agent that supports
the [Agent Skills](https://agentskills.io/specification) standard) act as a
specific industry role.

These rules apply to anyone, human or agent, who adds or edits a skill.

## Layout

```
<domain>/<discipline>/                 # a bundle; also a Claude Code plugin
  .claude-plugin/plugin.json           # plugin manifest (name: asf-<domain>-<discipline>)
  skills/<skill-name>/
    SKILL.md                           # required
    references/*.md                    # optional, loaded only when needed
    scripts/ assets/                   # optional
```

Every bundle must be listed in `.claude-plugin/marketplace.json` at the repo root.

## Hard rules

1. **Prefix.** Every skill name starts with `asf-` (AI Skill Factory), e.g. `asf-devops-engineer`.
2. **Name = folder.** `name` in the frontmatter must equal the skill's folder name:
   lowercase `a-z`, `0-9` and single hyphens, at most 64 characters.
3. **At most two roles per skill.** List them in `metadata.roles` as a
   comma-separated string. If a skill needs a third role, split it.
4. **Description ≤ 1024 characters**, written in the third person, saying what
   the skill does *and* when to use it. It is the only text an agent sees before
   the skill activates, so include the words a user would actually type.
5. **SKILL.md under 500 lines.** Move templates, long checklists and examples to
   `references/` and link them with relative paths, one level deep.
6. **Agent-neutral.** Do not name agent-specific tools (`Read`, `apply_patch`,
   `run_shell_command`…) and do not use `allowed-tools`. Say "read the file",
   "run the command", "ask the user".
7. **Stack-neutral.** Do not prescribe a framework, cloud or vendor. Present
   options with trade-offs and help the user choose. Examples may name tools
   only as one option among several. Vendor-specific guidance belongs in the
   vendor's own skills, listed as **companions** in `companions/<platform>.md`
   (see `companions/README.md`) and installed only once a project has chosen
   that platform.
8. **Only frontmatter fields from the spec:** `name`, `description`, `license`,
   `compatibility`, `metadata`. Keep `metadata` values as strings.
9. **Router metadata.** Every skill sets three `metadata` strings that
   `asf-project-kickoff` uses to pick teams:
   - `phase`: comma-separated from `all, discover, design, build, launch, operate`;
   - `presets`: comma-separated from `core, solo, small, medium, large`;
   - `signals`: comma-separated needs or words in a brief that pull the skill in.
10. **Say what it is not for.** End the description with one "Not for … (use
    `asf-…`)" sentence when a neighbouring skill could be confused with it.
11. **Safety tiers.** A skill that runs commands or changes systems has a
    "Safety tiers" section (read-only, change, destructive) as in the template.
12. **Nothing site-specific.** This repo is public. No real IP addresses,
    hostnames, email addresses, home-directory or key paths, account names or
    tokens. Use `192.0.2.x`, `198.51.100.x`, `203.0.113.x`, `example.com` and
    `<placeholders>`. A person's own hosts, accounts, tools and approvals go in
    their git-ignored site profile (`~/.asf/site.local.md`); skills tell the
    agent to read it. `validate.sh` scans for these and fails.
13. **Valid YAML.** Frontmatter must parse as YAML: no `: ` inside an unquoted
    value (rephrase, or quote the value).

## Writing a skill

Copy `templates/SKILL.template.md` and keep its section order. A good role skill:

- states the role's mindset and what it owns, and what it hands off;
- asks the user the few questions that change the answer before doing work;
- gives a numbered workflow and concrete deliverables;
- ends with checklists and anti-patterns the role would catch in review.

## Before you commit

```bash
./scripts/catalog.sh           # regenerate the kickoff's catalog after any frontmatter change
./scripts/validate.sh          # spec + repo rules, catalog, content scan, YAML, routing tests
shellcheck scripts/*.sh        # CI also runs shellcheck and gitleaks
```

When you add a skill or change its `signals`, add or update a made-up brief in
`tests/routing/` and run `./scripts/check_routing.py -v`.

Bump `metadata.version` in the skill and `version` in the bundle's
`plugin.json` when you change behaviour.
