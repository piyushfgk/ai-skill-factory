---
platform: cloudflare
title: Cloudflare (Workers, Pages, R2, D1, KV, Queues, Email Service)
source: https://github.com/cloudflare/skills
ref: main
path: skills
publisher: Cloudflare (official)
license: Apache-2.0
skills: cloudflare, wrangler, workers-best-practices, cloudflare-email-service
optional: cf-cli, cloudflare-app-bootstrap, workers-development, frameworks-on-cloudflare, nextjs-on-cloudflare, durable-objects, agents-sdk, turnstile-spin, cloudflare-one
signals: cloudflare, workers, cloudflare pages, r2, d1, kv, durable objects, wrangler, cloudflare email, email routing, turnstile, move to cloudflare
verified: 2026-11-25
---

# Cloudflare companion skills

Cloudflare publishes its own Agent Skills, and an optional plugin that also
adds its remote MCP server, at <https://github.com/cloudflare/skills>
(Apache-2.0). They track Cloudflare's products and CLIs much more closely than
a stack-neutral role skill can, so when a project chooses Cloudflare, install
the few that match the work alongside the AI Skill Factory team.

## When to suggest them

Suggest them when the profile, the repo scan or the user names Cloudflare
hosting or a Cloudflare product: Workers, Pages, R2 (object storage), D1
(SQL database), KV, Durable Objects, Queues, Email Routing or Email Sending,
Turnstile. Also when the brief is a move from another host or shared hosting
to Cloudflare. Typical case: a site moving from shared hosting to Cloudflare,
with files in R2, data in D1, an API on Workers and mail through Email Routing.

## Which skills

| Skill | Use for | Install by default |
|---|---|---|
| `cloudflare` | Choosing Cloudflare products for a need, and Cloudflare error pages | Yes |
| `wrangler` | Wrangler CLI: dev, deploy, KV, R2, D1, Queues, in projects that already have a Wrangler config file | Yes |
| `workers-best-practices` | Writing, reviewing and configuring production Workers | Yes |
| `cloudflare-email-service` | Email Sending, Email Routing and delivery configuration | Yes |
| `cf-cli` | The newer `cf` CLI; Cloudflare recommends it over Wrangler for new projects with no Wrangler config | New projects |
| `cloudflare-app-bootstrap` | Getting a checked-out app to a working local request: bindings, secrets, seed data | When onboarding an existing app |
| `workers-development` | Local development and debugging of Workers | During build |
| `frameworks-on-cloudflare`, `nextjs-on-cloudflare` | Running a web framework on Workers | When the frontend framework is deployed there |
| `durable-objects`, `agents-sdk` | Stateful coordination; AI agents on Cloudflare | Only if the design uses them |
| `turnstile-spin` | Bot checks on forms (Turnstile); ships its own scripts, review them first | If forms need bot protection |
| `cloudflare-one` | Zero-trust access, tunnels, gateway | For network and access work, not app hosting |

The repo has more skills; list them from the source before adding others.

## How the roles split

- `asf-devops-engineer` still owns environments, CI/CD, DNS and the domain
  move, secrets storage and monitoring; it uses the companions for
  Cloudflare-specific commands and config.
- `asf-backend-engineer` still owns code structure, validation, auth, jobs and
  tests; it uses `workers-best-practices`, `wrangler` and
  `cloudflare-email-service` for the platform APIs.
- `asf-software-architect` and `asf-cto` decide whether Cloudflare fits; the
  `cloudflare` skill helps map needs to products once it does.

## Install routes

Pick one per agent. All of them fetch third-party content: show the user the
source and licence, and get approval first (change tier).

| Route | Command | Trade-off |
|---|---|---|
| AI Skill Factory (any agent, only the chosen skills) | `scripts/companions.sh --project . --from .asf/project.md` | Installs only the listed skills, next to the team; no MCP server |
| Claude Code plugin | `/plugin marketplace add cloudflare/skills` then `/plugin install cloudflare@cloudflare` | Adds every Cloudflare skill and its MCP server: more always-loaded context |
| Codex plugin | `codex plugin marketplace add cloudflare/skills` then `codex plugin add cloudflare@cloudflare` | Same as above, for Codex |
| `npx skills` | `npx skills add https://github.com/cloudflare/skills` | Needs Node; installs the collection |

The MCP server is optional. Following `asf-project-setup`, prefer the CLI
(`wrangler` or `cf`) and add the MCP server per project only if the work needs
the Cloudflare API or live docs beyond what the CLI gives.
