# Host runbook

Commands are examples for common Linux hosts; use the host's own equivalents
(another init system, package manager or a vendor CLI) where they differ.

## Baseline

Read-only. Save the output with the date before any change.

| Item | Example commands |
|---|---|
| OS, kernel, uptime | `cat /etc/os-release`, `uname -r`, `uptime` |
| Disk and inodes | `df -h`, `df -i`, largest folders under the app and log paths |
| Memory and load | `free -h`, `top -bn1 \| head -20` |
| Services | `systemctl --failed`, `systemctl list-units --type=service --state=running` |
| Process managers | the manager's list command (for example `pm2 ls`), PHP-FPM pool status |
| Containers | `docker compose ps`, `docker ps --format '{{.Names}} {{.Status}}'` |
| Listening ports | `ss -tulpn` |
| Recent errors | `journalctl -p err --since '24 hours ago'`, app and web server error logs |
| Pending updates | the package manager's "list upgradable" command |
| Scheduled jobs | `crontab -l` for the service user, systemd timers |

```markdown
## Baseline <alias> <YYYY-MM-DD HH:MM>
- OS / kernel / uptime:
- Disk: / 62% used; /var 40%
- Failed services: none
- Containers: app (healthy), worker (up)
- Ports: 22, 80, 443
- Errors last 24h: none
- Pending updates: 14 (2 security)
```

## Change plan

```markdown
## Change <alias> <YYYY-MM-DD>
Goal: <one line>
Tier: change | destructive    Approver: <name>    Window: <time>
Rollback point: <snapshot id, backup, previous config copy, previous image tag>

| Step | Command | Expected result | Check |
|---|---|---|---|
| 1 | cp app.conf app.conf.bak-<date> | copy exists | ls -l |
| 2 | <edit> | config valid | <config test command> |
| 3 | systemctl reload <service> | active, no errors | systemctl status; journalctl -u <service> --since -5m |

Rollback: restore app.conf.bak-<date>, reload, check.
Verified: <what was tested, result>
```

## Common tasks

- **Service won't start:** status and the last 50 log lines; config test; recent
  package or config changes; disk and permissions. Fix the cause, not the symptom.
- **Disk full:** find the biggest folders, rotate or compress logs, prune old
  releases or images only after listing them and getting approval.
- **Patching:** check pending updates, snapshot, apply security updates first,
  restart affected services, check, schedule the reboot if the kernel changed.
- **Compose stacks:** pin image tags; `docker compose pull` then `up -d` per
  stack; keep the previous tag to roll back; never `down -v` without a backup.

## Hardening checklist

- [ ] SSH: keys only, no root login, only the users who need it.
- [ ] Firewall allows only the ports the services need; admin ports only over VPN.
- [ ] Automatic security updates, or a patch schedule that is followed.
- [ ] Services run as their own non-root users; files owned accordingly.
- [ ] Brute-force protection on exposed logins.
- [ ] Time sync on; logs kept long enough to investigate an incident.
- [ ] Backups or snapshots run and a restore has been tested.
- [ ] Unused services, packages and accounts removed (with approval).
