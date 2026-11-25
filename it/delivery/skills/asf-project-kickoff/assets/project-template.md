# Project: <name>

This file records which AI Skill Factory skills this project uses and why.
Agents: read it at the start of each session. Change it with
`asf-project-kickoff` (team, phase) and `asf-project-setup` (tools).

## Profile

- Mode: <new | existing (adopted YYYY-MM-DD)>
- Goal: <build from scratch | maintain | add features | audit | migrate | launch or grow>
- What: <website | web app | mobile app | API | internal tool | data | mix>
- Users: <who, rough count in year one>
- Ambition and deadline: <prototype | MVP | production>, <date>
- Sensitive areas: <payments, personal data, health, none>
- Human roles: <roles people already cover, or none>
- Guesses to confirm: <anything assumed>

## Found in repo

<Existing projects only: the found-vs-guessed table from adopt mode (stack,
hosting, CI, tests, PWA, SEO, analytics, phase guess), and the project's own
conventions: code style, branch naming, commit format, test commands.>

## Team

Preset: <Solo | Small | Medium | Large> (<n> skills)
Current phase: <discover | design | build | launch | operate>

<!-- asf:team (one skill per line; scripts/install.sh --from reads this block) -->
- asf-product-manager: <why this project needs it>
- asf-frontend-engineer: <why>
<!-- /asf:team -->

Left out: <skill (reason)>
Needed but not in the library yet: <role (who covers it meanwhile)>

## Companions

<Vendor skills for the platform this project chose (see the catalog's
"Companion skills"), or "none". Pin with platform@commit once installed.>

<!-- asf:companions (platform[@ref]: skills; scripts/companions.sh --from reads this block) -->
<!-- /asf:companions -->

## Existing agent setup

<Instruction files, non-asf skills (kept), MCP servers, tracker. "None" for a new project.>

## Web

<Answers to the web kickoff questions, or "not a web project".>

## Setup

<Filled in by asf-project-setup: agent platform, tracker, code host,
integrations and their route (CLI, MCP, custom CLI), install policy, secrets.>

## Open decisions

- [ ] <decision> (owner: <skill or person>)

## Change log

- <YYYY-MM-DD>: Team created with the <preset> preset.
