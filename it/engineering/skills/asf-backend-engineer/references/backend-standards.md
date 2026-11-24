# Backend standards

## Choosing a runtime

Present options; the team's skills and the hosting they can run usually decide.

| Shape | Good for | Trade-offs |
|---|---|---|
| Long-running server (a framework app behind a proxy, in a container or process manager) | Steady traffic, websockets, background workers, complex apps | You run, scale and patch it |
| Serverless functions | Spiky or low traffic, event handlers, glue code | Cold starts, time and memory limits, vendor-specific triggers, harder local testing |
| Edge functions | Low-latency reads, auth checks, redirects | Limited runtime APIs and execution time |
| Managed backend (BaaS) | Prototypes, small apps with standard auth and data | Lock-in, limits on custom logic |
| Shared hosting (PHP) | Small sites with low budget | Fixed runtime versions, no long-running processes, limited control |

## Endpoint checklist

```markdown
### <METHOD> /v1/<resource>

- Auth: <who can call it; object-level check>
- Request: <fields, types, limits>
- Response 200: <shape>
- Errors: 400 validation (field errors), 401, 403, 404, 409 conflict, 429, 5xx
- Idempotency: <key header or natural key, if retried>
- Pagination: <cursor or page; max page size>
- Rate limit: <per user / per IP>
- Logs and metrics: <request id, outcome, duration>
- Example: <curl with example.com host and fake data>
```

Consistent error body, for example:

```json
{ "error": { "code": "validation_failed", "message": "Email is invalid", "fields": { "email": "invalid" }, "request_id": "req_123" } }
```

## Jobs and queues

- Every job has: a trigger, an idempotency key, a timeout, a retry policy with
  backoff and a maximum, and a dead-letter or failure record someone reviews.
- Jobs are safe to run twice and safe to run late.
- Scheduled jobs log start, end, items processed and failures; alert on "did not run".
- Long work goes to a queue, not the request; the client gets a job ID to poll
  or a callback.

## Caching

- Cache only what can be stale; name the maximum staleness.
- Invalidate on write, or use short TTLs; never cache per-user data in a shared cache key.
- Measure hit rate before adding layers.

## Webhooks received

- Verify the signature, check the timestamp, store the raw event, return 2xx
  quickly, process in a job, de-duplicate by event ID.

## Performance

- Look at the slowest endpoints by p95, then their queries (`EXPLAIN`).
- Batch or join instead of N+1; paginate lists; select only needed columns.
- Compress responses; avoid sending large blobs through the API when a signed URL will do.
