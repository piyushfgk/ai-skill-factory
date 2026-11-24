# Security playbook

## Threat model

Use a simple method the team will keep up to date (for example STRIDE per
trust boundary, or attack trees for the top assets).

| Asset | Entry point | Trust boundary | Threat | Likelihood | Impact | Mitigation | Status |
|---|---|---|---|---|---|---|---|
| User accounts | Login form | Browser → API | Credential stuffing | High | High | Rate limits, MFA option, breached-password check | planned |

Trust boundaries to always consider: browser to API, API to database, service
to service, admin panel to everything, third-party webhooks in, CI to
production, and people with production access.

## Review checklists

**Authentication and sessions**
- [ ] Passwords hashed with a slow, salted algorithm (for example Argon2id, bcrypt, scrypt).
- [ ] MFA available for admins at least; login rate-limited; account enumeration avoided.
- [ ] Session cookies `HttpOnly`, `Secure`, `SameSite`; sessions expire and rotate on login.
- [ ] Password reset tokens single-use, short-lived, and sent only to verified addresses.

**Access control**
- [ ] Every request checks the user's right to that object (no ID guessing, IDOR).
- [ ] Role checks on the server, never only in the UI.
- [ ] Admin functions separated and logged.

**Input and output**
- [ ] Parameterised queries everywhere; no string-built SQL or shell commands.
- [ ] Output encoded for its context; a Content Security Policy is set.
- [ ] File uploads checked for type and size, stored outside the web root.
- [ ] Server-side requests to user-given URLs are restricted (SSRF).

**Secrets and config**
- [ ] No secrets in the repo, images, logs or client apps; a secret scanner runs in CI.
- [ ] Debug off and stack traces hidden in production; security headers set.
- [ ] CORS allows only known origins.

**Dependencies and supply chain**
- [ ] Lockfiles committed; dependency and image scans in CI; a CVE response time agreed.
- [ ] CI tokens least-privilege; third-party actions or plugins pinned.

**Logging**
- [ ] Logins, permission changes and admin actions logged with who and when.
- [ ] No passwords, tokens or full personal data in logs.

## Findings tracker

```markdown
| ID | Title | Severity | Evidence | Impact | Fix | Owner | Due | Status | Verified by |
|---|---|---|---|---|---|---|---|---|---|
| SEC-1 | Order IDs readable across accounts | High | GET /api/orders/124 as user B returns user A's order (request saved) | Data leak | Check ownership in order query | backend | <date> | fixed | same request now 404 |
```

Severity from impact and likelihood for this product. Evidence must let
someone else reproduce it, with secrets redacted.

## Hardening baselines

Use a recognised baseline as the reference (for example the CIS Benchmarks for
the OS) and record exceptions with reasons.

**Linux**
- [ ] SSH keys only, no root login; sudo for named users.
- [ ] Firewall default deny inbound; only needed ports open.
- [ ] Automatic security updates or a followed patch schedule.
- [ ] Services as non-root users; mandatory access control (SELinux or AppArmor) on.
- [ ] Audit and auth logs kept and shipped off the host.

**Windows**
- [ ] Supported version, automatic updates, Defender or equivalent on.
- [ ] Local admin rights removed from daily accounts; LAPS or equivalent for local admin passwords.
- [ ] RDP only over VPN or a gateway, with network-level authentication.
- [ ] BitLocker on laptops; PowerShell script logging on servers.
- [ ] SMBv1 and other legacy protocols off.

## Incident first response

1. **Contain** without destroying evidence: revoke or rotate the exposed
   credential, block the route, isolate the host (with approval).
2. **Preserve**: copy logs and note times before they rotate.
3. **Assess**: what was exposed, for how long, whose data.
4. **Notify**: the owner, and check legal deadlines for notifying users or
   regulators (many data-protection laws have short ones).
5. **Fix and verify**, then write a blameless review with follow-up actions.

```markdown
| Time (UTC) | What happened / what we did | Who |
|---|---|---|
```
