# API design guidelines

These apply whichever style you choose. Pick the style first:

| Style | Good fit | Weak fit |
|---|---|---|
| REST over HTTP + JSON | Public APIs, CRUD, caching through HTTP | Many nested reads per screen |
| GraphQL | Many client types with different data needs | Simple CRUD, heavy HTTP caching needs |
| RPC (gRPC, tRPC, JSON-RPC) | Internal service calls, typed end to end | Public or browser-first APIs (varies by tool) |

## Contract first

Write the contract (OpenAPI, GraphQL SDL, or proto) and review it before building.
Generate client types from it where the stack allows.

## Naming and resources (REST)

- Plural nouns for collections: `/orders`, `/orders/{id}`, `/orders/{id}/items`.
- Verbs only for actions that are not CRUD: `POST /orders/{id}/cancel`.
- Use `kebab-case` paths and one casing for JSON fields across the whole API.

## Methods and status codes

| Method | Use | Success |
|---|---|---|
| GET | Read | 200 |
| POST | Create or action | 201 with `Location`, or 200/202 |
| PUT | Replace | 200 |
| PATCH | Partial update | 200 |
| DELETE | Delete | 204 |

Client errors: 400 validation, 401 not signed in, 403 not allowed, 404 not found,
409 conflict, 422 semantic error, 429 rate limited. Server errors: 500, 503.

## Errors

Use one error shape everywhere, for example RFC 9457 problem details:

```json
{
  "type": "https://example.com/errors/out-of-stock",
  "title": "Item out of stock",
  "status": 409,
  "detail": "SKU 123 has 0 units left.",
  "instance": "/orders/abc",
  "errors": [{ "field": "items[0].quantity", "message": "Exceeds stock" }]
}
```

## Pagination, filtering, sorting

- Prefer cursor pagination for feeds and large tables: `?limit=20&cursor=...`,
  return `next_cursor`.
- Filters as query parameters: `?status=paid&created_after=2026-01-01`.
- Sorting: `?sort=-created_at`.

## Versioning and compatibility

- Version in the path (`/v1`) or a header; pick one.
- Additive changes are non-breaking. Removing or renaming a field is breaking.
- Mobile apps stay installed for months: keep old versions working and publish
  a deprecation timeline.

## Reliability

- `Idempotency-Key` header on POST requests that create payments or orders.
- Timeouts and retries with backoff on every outbound call.
- Rate limits per user and per IP, returned with `429` and `Retry-After`.

## Security

- Authenticate every request (session cookie for web, short-lived tokens for
  mobile and third parties).
- Authorise per resource on the server.
- Validate all input against the contract; never trust client-side checks.
- Never return secrets, password hashes or internal IDs that must stay private.
- Use HTTPS only; set CORS to known origins.
