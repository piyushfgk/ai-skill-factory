# Service readiness checklist

Run before handing a new service, endpoint group or job to
`asf-devops-engineer` for its first production deploy. Mark each line pass,
fail or not applicable, with evidence (test name, log line, config file).

## Correctness

- [ ] The implementation matches the API contract (contract tests pass).
- [ ] Validation rejects bad input with the documented error shape.
- [ ] Authorisation is enforced per resource, with a test for "another user's record".
- [ ] Retries and duplicate deliveries do not create duplicate side effects.

## Data

- [ ] Migrations ran on a copy of production-sized data; duration and locks noted.
- [ ] A rollback (down migration or restore) is written and tested.
- [ ] New queries have indexes; no unbounded result sets.
- [ ] Personal data fields are listed, and deletion on request works.

## Dependencies

- [ ] Every external call has a timeout, a retry policy and a failure path.
- [ ] Credentials have the least scope and come from the secret store.
- [ ] Webhook signatures are verified.
- [ ] Rate limits protect sign-in, reset and messaging endpoints.

## Operations

- [ ] Health endpoint reports readiness (dependencies reachable) separately from liveness.
- [ ] The service shuts down gracefully: finishes in-flight requests and jobs.
- [ ] Logs are structured, carry a request id and contain no secrets or personal data.
- [ ] Metrics exist for errors, latency and queue depth; DevOps knows which to alert on.
- [ ] Configuration is documented: every environment variable, required or optional, with a safe default.

## Hand-off note

```markdown
## Backend hand-off: <service or feature>

- What changed: <endpoints, jobs, migrations>
- New environment variables: <names only>
- Migrations: <order, expected duration, rollback>
- New external dependencies: <service, timeout, failure mode>
- What to watch after deploy: <metric or log query>
```
