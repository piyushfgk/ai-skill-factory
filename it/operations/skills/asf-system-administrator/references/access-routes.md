# Access routes by host type

Each host type has its own normal way in. Use that route, with the least
privileged account, and record only the alias in committed files. The real
address, user and key location stay in the site profile and the SSH config.

| Host type | Usual route | Agent can usually | Watch out for |
|---|---|---|---|
| Server on the local network | VPN or overlay network (for example WireGuard, Tailscale), then SSH by alias | Read state, manage services and containers | Exposing SSH to the internet to "make it easier" |
| Cloud VM | SSH by alias, or the provider's session manager or serial console | Same as above, plus snapshots through the provider CLI | Security groups and keys managed in two places |
| Shared hosting | Control panel, SFTP, sometimes limited SSH; provider API if offered | Deploy files, read logs, set cron jobs | No root, no systemd, fixed runtime versions, rate limits |
| NAS or other appliance | Its web UI or API; SSH only if the vendor supports it | Read status, trigger snapshots or app updates through the API | Shell changes lost on firmware update; vendor-specific package systems |
| Managed platform (PaaS, serverless) | The platform CLI or API | Deploy, read logs, roll back releases | No host to log into; do it the platform's way |

## SSH conventions

- One `Host` alias per server in the SSH config, with `User`, `HostName`,
  `IdentityFile` and any `ProxyJump`. Skills and notes refer to the alias only.
- Keys: one per person or agent, with a passphrase or a hardware key or agent;
  never shared, never copied into a repo or chat.
- Prefer `ssh <alias> '<one command>'` for read-only checks over interactive
  sessions, so every command is visible in the transcript.
- Long-running changes: use a terminal multiplexer on the host so a dropped
  connection doesn't kill a half-done upgrade.

## When the agent has no route

Say so plainly: which host, which route is missing, and what a human needs to
run. Give the exact read-only command first, so the human can paste back the
output, and only then the change. Do not guess at a host you can't see.

## Recording a route (site profile, local only)

```markdown
| Alias | Type | How to reach it | Account | Highest allowed tier | Approver | Rollback |
|---|---|---|---|---|---|---|
| app-1 | cloud VM | SSH alias app-1 | deploy | change | owner | provider snapshot |
| nas-1 | NAS | vendor API via VPN | api-readonly | read-only | owner | built-in snapshots |
```
