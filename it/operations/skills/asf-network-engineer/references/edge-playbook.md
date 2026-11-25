# Edge playbook

Examples use `example.com` and documentation addresses (`192.0.2.x`,
`203.0.113.x`). Use the real values only on the host or in the site profile.

## Map the path

| Hop | Question | Read-only check |
|---|---|---|
| Registrar | Who holds the domain, when does it expire, is transfer lock on? | Registrar panel or `whois example.com` |
| Nameservers | Which DNS provider answers? | `dig NS example.com +short` |
| Records | What do the name and its aliases point to? | `dig A/AAAA/CNAME app.example.com +short` |
| Inside view | Does the local network get a different answer (split DNS)? | `dig @<local resolver> app.example.com` |
| CDN or tunnel | Is traffic going through a proxy or tunnel provider? | Response headers, provider dashboard or CLI |
| Reverse proxy | Which rule sends the request to which service and port? | Proxy config, `curl -I https://app.example.com` |
| Service | Is it listening and healthy? | Hand to `asf-system-administrator` |

## DNS change plan

```markdown
## DNS change example.com <YYYY-MM-DD>
Goal: <one line>     Tier: change | destructive     Approver: <name>
Zone export saved: <file or provider backup>

| Record | Type | Before | After | TTL |
|---|---|---|---|---|
| app | A | 192.0.2.10 | 203.0.113.20 | 300 (was 3600) |

Verify: public resolvers, inside resolver, HTTPS, redirects, mail checks.
Rollback: restore the "Before" values; with TTL 300, effective within ~5 minutes.
```

## Domain and DNS moves

1. Export the full zone from the old provider; recreate every record at the
   new one, including MX, SPF (`TXT v=spf1`), DKIM selectors, DMARC
   (`_dmarc`), verification TXT records, CAA and any SRV records.
2. Compare old and new answers record by record before switching nameservers.
3. Lower TTLs a day ahead. Switch nameservers. Keep the old zone unchanged
   until the switch has propagated (at least the old NS TTL).
4. For a site move to a new domain or between apex and `www`: 301 redirects
   for every old URL, canonical tags on the new one, and a search console
   change of address (with `asf-seo-specialist`).
5. Check email both ways after the move: send and receive, and read the
   SPF, DKIM and DMARC results in a received message's headers.

## Split DNS

Use it when a service should be reached directly on the local network but
through a public route from outside. Keep one source of truth for the list of
internal names, document which resolver serves the inside view, and test from
both sides after every change. Avoid publishing private addresses in public DNS.

## Reverse proxy and TLS

- Pick one reverse proxy the team can maintain (for example nginx, Caddy,
  Traefik, HAProxy, or the platform's own router); compare automatic
  certificates, config style and how routes are added.
- Forward `Host`, `X-Forwarded-Proto`, `X-Forwarded-For` and, for an app under
  a subpath, `X-Forwarded-Prefix` (or the framework's equivalent), and tell the
  app its public base URL so redirects and cookies are right.
- Test config before reload (the proxy's config test command), then reload,
  not restart, where supported.
- Certificates: automatic issue and renewal (ACME), HTTP-to-HTTPS redirect,
  HSTS once HTTPS is stable everywhere, and an alert before expiry.

## Tunnels and VPN

| Option | Good for | Trade-offs |
|---|---|---|
| Hosted tunnel (for example Cloudflare Tunnel, ngrok, Tailscale Funnel) | Publishing a service without opening ports | Traffic goes through a provider; their access rules apply |
| Overlay VPN (for example Tailscale, ZeroTier, Netbird) | Reaching private hosts from anywhere | Account with a coordinator service; simple setup |
| Self-hosted VPN (for example WireGuard, OpenVPN) | Full control, no third party | You run, patch and key-manage it |

## Exposure review

```markdown
| Host alias | Port / route | Exposed to | Reason | Owner | Keep? |
|---|---|---|---|---|---|
| app-1 | 443 | internet via proxy | public site | team | yes |
| app-1 | 22 | VPN only | admin | sysadmin | yes |
```

Check exposure only on systems you own or are authorised to test, for example a
port scan of your own public address from outside, read-only.
