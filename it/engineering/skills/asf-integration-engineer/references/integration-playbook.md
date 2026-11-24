# Integration playbook

## Flow map

```markdown
| Flow | Source → destination | Trigger | Payload | Volume | On failure | Owner |
|---|---|---|---|---|---|---|
| New order to CRM | shop → CRM | order.paid webhook | order id, customer, total | ~200/day | retry 24 h, then failure list + alert | ops |
```

## Mechanism choice

| Mechanism | Good for | Trade-offs |
|---|---|---|
| Webhooks | Near real-time events | Need a public endpoint, signature checks, retries |
| Polling | Systems without webhooks | Delay and API quota use |
| Queue or event bus | High volume, many consumers | More infrastructure |
| File exchange (SFTP, object storage) | Batch, legacy partners | Delay; file format contracts |
| No-code flow tools (for example Zapier, Make, n8n) | Simple flows owned by non-developers | Per-task cost, limited testing and version control |

## Email sending

- Use a transactional email provider or a dedicated sending subdomain.
- Records (published by whoever owns DNS):
  - SPF: a `TXT` record listing the provider (`v=spf1 include:<provider> ~all`); one SPF record per name.
  - DKIM: the provider's selector records (`<selector>._domainkey`).
  - DMARC: `_dmarc` `TXT`, start with `p=none` and a report address, move to `quarantine` or `reject` when reports are clean.
- Handle bounces and complaints by webhook; stop sending to bad addresses.
- Separate transactional from marketing mail.

## Messaging platforms

- Use the platform's official API and app or bot model; respect rate limits.
- Store channel and user IDs, not names; handle users leaving.
- For messages to customers (SMS, WhatsApp), follow the platform's opt-in and template rules.

## MCP servers and CLIs

- Expose only the operations the job needs, with clear names and descriptions
  (they are what the agent reads, and they cost tokens every session).
- Read-only tools by default; write tools clearly named and documented.
- Credentials from environment variables or a secret store, never arguments.
- Return compact results with limits and pagination.
- A CLI: one command per operation, `--help` for each, JSON output option.

## Document automation

- Templates with named placeholders, versioned in the repo.
- Generate PDFs or office files server-side with a maintained library or service.
- Never put personal data into file names or URLs; expire download links.
