# Backend runtime options

Pick the runtime per workload, not per project: a project can serve its API
from containers and run image processing in functions. Confirm current limits
(timeouts, memory, cold starts, pricing) in the provider's docs; they change.

## Where the code runs

| Option | Good for | Watch out for |
|---|---|---|
| **Long-running server** (a process on a VM, a container platform, a managed app service) | Steady traffic, WebSockets, long requests, in-memory caches, any language or library | You pay while idle; you own scaling, patching (on VMs) and graceful restarts |
| **Serverless functions** (per-request functions in one region) | Spiky or low traffic, webhooks, scheduled jobs, glue code | Cold starts, execution time limits, connection limits to traditional databases (use a pooler or an HTTP-based driver) |
| **Edge functions** (code run at many points of presence) | Low-latency reads, auth checks, redirects, personalisation, APIs near global users | Restricted runtime APIs and libraries, CPU limits, data far from the code unless the database is also distributed or cached |
| **Background workers** (a queue consumer process or managed queue consumer) | Email, media processing, imports, fan-out, retries | Need idempotency, a dead-letter path and monitoring of queue depth |

Rules of thumb:

- Keep the code close to its data. An edge function that calls a database in
  one far region is slower than a server next to it.
- Prefer one runtime for the main API until there is a measured reason for two.
- Write handlers so the framework or platform is a thin layer: business logic
  in plain modules is easier to test and to move.

## Data and storage

| Need | Options (examples, not a recommendation) | Trade-off |
|---|---|---|
| Relational data, transactions, reporting | A managed relational database (PostgreSQL, MySQL or MariaDB, or SQLite-based services) | Strong consistency and SQL; plan connections and migrations |
| Key-value or session data | A managed key-value store or cache | Fast and simple; limited queries, often eventually consistent |
| Files and media | Object storage with signed URLs | Cheap and durable; set lifecycle rules and never make buckets public by accident |
| Search | The database's full-text search first, a search engine later | Extra system to sync and operate |
| Queues and schedules | The platform's managed queue and cron, or a database-backed job table | Managed is less work; a job table is portable and transactional with your data |

## Email

| Option | Notes |
|---|---|
| Transactional email API from an email provider or the hosting platform | Set SPF, DKIM and DMARC on the sending domain; send from a job, not the request |
| SMTP relay | Portable; slower and harder to observe |
| Inbound email routing to a handler | Verify sender and size limits; treat the body as untrusted input |

## Decision record

```markdown
# Runtime for <workload>

- Date: YYYY-MM-DD
- Options considered: <server | functions | edge | worker>, with one line each
- Chosen: <option>, because <latency, cost, team skill, data location>
- Limits that matter: <timeout, memory, connections, regions>
- How we would move off it: <what is platform-specific in our code>
```
