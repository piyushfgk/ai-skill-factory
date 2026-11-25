# Cloud playbook

## Account structure

```markdown
| Account / project | Purpose | Who has access | Guardrails |
|---|---|---|---|
| management | billing, organisation policies | owners only | MFA, no workloads |
| prod | production workloads | deploy role via CI; break-glass for people | deny region X, deny public buckets |
| staging | pre-production | team | budget alert |
| dev / sandbox | experiments | team | auto-cleanup, low budget |
```

Smaller projects can start with two (production and everything else); keep
production separate from day one.

## Infrastructure as code

- One state per environment; remote backend with locking and versioning.
- Pin provider and module versions.
- Secrets never in state where avoidable; when unavoidable, encrypt and restrict the backend.
- Plan in CI on every pull request; apply only from the main branch after review.
- Import hand-made resources instead of recreating them.

## Cost

```markdown
| Environment | Service | Size | Est. monthly | Notes |
|---|---|---|---|---|
| prod | compute | 2 × small | <amount> | autoscale to 4 |
| prod | database | managed, small, HA | <amount> | backups included |
| prod | egress / CDN | ~200 GB | <amount> | |
| **Total** | | | **<amount>** | at 10× usage: <amount> |
```

Monthly review: top five cost lines, unused resources, rightsizing,
commitments or reservations only for steady load.

## Quotas and limits

Check before launch: instance and IP counts, API rate limits, function
concurrency, database connections, email sending limits, storage request
rates. Request increases early; some take days.

## Exit plan

```markdown
| Service | Lock-in | Portable alternative | Data export | Effort to move |
|---|---|---|---|---|
| Object storage | low | any S3-compatible store | sync tool | days |
| Proprietary queue | medium | open-source broker | drain and replay | weeks |
| Proprietary database | high | open-source engine | export + rewrite queries | months |
```
