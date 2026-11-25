# Companion skills

The role skills in this library are stack-neutral. Once a project **chooses** a
platform, the platform vendor's own Agent Skills usually know its products,
CLIs and limits far better. A companion file says where those skills live,
which ones to install by default, and when to suggest them.

- `asf-project-kickoff` and `asf-project-setup` match a project's chosen
  platform against each file's `signals` and propose its `skills`, with the
  user's approval, in the `asf:companions` block of `.asf/project.md`.
- `scripts/companions.sh` fetches the source and installs only the listed
  skills into the project, next to the team (see `--help`).
- The role skills stay in charge of the practice (structure, safety, tests,
  hand-offs) and defer to the companions for vendor-specific detail.

| Platform | File |
|---|---|
| Cloudflare | [cloudflare.md](cloudflare.md) |

## Adding a platform

One file per platform, named `<platform>.md`, with this frontmatter (one line
per key, values unquoted):

```yaml
---
platform: <name, same as the file name>
title: <display name and main products>
source: https://<git host>/<owner>/<repo>
ref: <branch or tag to fetch by default>
path: <folder inside the repo that holds one folder per skill>
publisher: <who maintains it, and whether it is official>
license: <SPDX id of the source repo>
skills: <default skills, comma-separated>
optional: <other useful skills, comma-separated>
signals: <words in a brief or repo that point to this platform>
verified: <YYYY-MM-DD the skill names were last checked>
---
```

The body says when to suggest the companions, a table of skills with what each
is for, how the work splits with the `asf-` role skills, and the vendor's own
install routes (plugins, MCP servers) with their trade-offs.

Rules:

- Prefer skills published by the vendor. Use a community source only when no
  official one exists, say so in `publisher`, and check its licence and
  activity.
- List only skills that exist: run `scripts/companions.sh --verify <platform>`
  and update `verified`.
- Keep the default list short (about four skills); everything else goes in
  `optional`.
- Nothing site-specific (AGENTS.md rule 12) and no vendor contact addresses.

After adding or changing a file, run `scripts/catalog.sh` and
`scripts/validate.sh`.
