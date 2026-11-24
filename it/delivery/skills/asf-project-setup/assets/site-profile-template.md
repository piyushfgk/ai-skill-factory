# Site profile (local, never committed)

<!--
Copy to ~/.asf/site.local.md (shared by all projects on this machine).
A project can add .asf/site.local.md for project-only details; it wins over
the machine file. Both names end in .local.md, which the AI Skill Factory
installer adds to .gitignore. Never paste passwords, tokens or private keys
here: record WHERE a secret lives (a variable or secret-store name), not
the secret. Prefer aliases (an SSH config Host name, a CLI profile name)
over raw addresses.
-->

Last reviewed: <YYYY-MM-DD>

## Workspaces

| Workspace | Purpose | Code host account | Default approver |
|---|---|---|---|
| <personal> | <side projects> | <CLI profile or wrapper name> | <me> |

## Hosts

| Alias | Type | How to reach it | Account | Highest allowed tier | Approver | Rollback |
|---|---|---|---|---|---|---|
| <app-server-1> | <lan server, cloud VM, shared hosting, NAS or appliance> | <SSH config alias, VPN + SSH, provider API, control panel> | <login or profile name> | <read-only, change, destructive> | <who says yes> | <snapshot, backup, none> |

## Access routes

- <VPN or tunnel name>: <what it reaches, how it is started>
- <SSH config alias>: <jump host, if any>

## Accounts and secrets (names only)

| Service | CLI profile or env var | Where the secret is stored | Scope |
|---|---|---|---|
| <cloud provider> | <profile name> | <password manager item, secret store path> | <read-only, deploy> |

## Tools on this machine

- CLIs: <official CLIs, wrappers per account>
- MCP servers for all projects: <small, everyday ones>
- MCP servers per project: <heavy ones, and which projects>

## Approvals

| Tier | Needs |
|---|---|
| read-only | Nothing; the agent may run it |
| change | Approval from <approver> for this step, a known rollback |
| destructive | Approval from <approver> for this exact command, a fresh backup or snapshot, a maintenance window |
