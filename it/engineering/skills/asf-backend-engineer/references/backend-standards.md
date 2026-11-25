# Backend standards

## Code structure

- Handlers (HTTP routes, job consumers, webhook receivers) parse input, call
  one use case, and map the result to a response. No business rules here.
- Use cases or services hold the rules and are testable without a network.
- Data access sits behind small functions or repositories per module. Only the
  module that owns an entity writes it.
- Configuration comes from the environment, read and validated once at start-up.
  Fail fast if a required variable is missing.

## Authentication and authorisation

- Prefer a well-maintained library or hosted identity provider over custom
  password, session or token code.
- Sessions: secure, HTTP-only, same-site cookies for browser apps. Tokens:
  short-lived access tokens, refresh tokens that rotate and can be revoked.
- Hash passwords with a slow, salted algorithm designed for passwords
  (for example Argon2id, scrypt or bcrypt). Never store reversible passwords.
- Authorise in one place per resource: a policy function such as
  `can(user, action, record)` called by every handler, including list, search,
  export and bulk endpoints.
- Service-to-service calls use their own credentials with the least scope, not
  a user's token and not an admin key.
- Rate limit sign-in, password reset, sign-up and any endpoint that sends email
  or SMS.

## Validation and errors

- Validate with a schema at the edge; reuse the API contract's schema if one exists.
- One error shape, for example:

  ```json
  { "error": { "code": "validation_failed", "message": "Email is required", "field": "email", "requestId": "<id>" } }
  ```

- Map errors deliberately: 400 invalid input, 401 not signed in, 403 not
  allowed, 404 not found (also for records the caller may not see), 409
  conflict, 422 business rule, 429 rate limited, 5xx only for server faults.

## Data access

- Parameterised queries only; never build SQL from strings.
- Wrap multi-step writes in a transaction. Keep transactions short; no network
  calls inside them.
- Every list endpoint paginates (cursor-based for large or changing sets).
- Add the index with the query. Check the plan (`EXPLAIN`) for new queries on
  large tables.
- Use optimistic locking (a version column or `updated_at` check) where two
  users can edit the same record.
- Soft delete only when the product needs undo or audit; otherwise delete, and
  honour personal-data deletion requests.

## Migrations

- One migration per change, committed with the code that needs it, applied by
  the pipeline, never by hand on production.
- For live data use **expand, migrate, contract**:
  1. add the new column or table (nullable or with a default) and deploy code
     that writes both;
  2. backfill in batches;
  3. switch reads to the new shape;
  4. remove the old column in a later release.
- Avoid long locks: add indexes concurrently where the engine supports it, and
  batch large updates.
- Write the down migration or the restore plan before applying the up one.

## Jobs, queues and webhooks

- Every job is idempotent: running it twice has the same effect as once. Use an
  idempotency key or a unique constraint.
- Retries with exponential backoff and a cap; then a dead-letter queue or a
  failed-jobs table someone looks at.
- Scheduled tasks guard against overlap (a lock or a "running" flag).
- Incoming webhooks: verify the signature, store the raw event, respond fast,
  process in a job, ignore duplicates.
- Outgoing webhooks: sign the payload, retry with backoff, let receivers replay.

## Caching

- Cache only what you can invalidate or what can be stale for a known time.
- Set HTTP cache headers for public, cacheable responses; never cache
  responses that depend on the user unless the cache key includes the user.
- Protect against stampedes on expensive keys (lock, early refresh or jitter).

## Files and uploads

- Upload directly to object storage with short-lived signed URLs where possible.
- Check size and content type on the server; scan or re-encode files that will
  be shown to other users.
- Store files under generated keys, never under user-supplied paths.

## Observability in code

- Structured logs (JSON or key-value) with a request id, user or tenant id
  (not personal details), route and duration.
- Emit metrics for request rate, errors and latency per route, and queue depth
  and job failures per queue.
- Propagate trace context across HTTP calls and jobs if the project uses tracing.

## Testing

| Level | What | Tip |
|---|---|---|
| Unit | Business rules, validation, policy functions | Fast, no network or database |
| Integration | Data access, migrations, transactions | Run against the same database engine as production, in a container or a local instance |
| Contract | Responses match the API contract | Generate from the OpenAPI, GraphQL or proto file where possible |
| End-to-end | One test per core journey through the real API | Keep few; they are slow |

Add a regression test for every bug fixed.
