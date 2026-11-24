# QA playbook

## Test strategy

| Level | What it proves | Speed | Share of tests |
|---|---|---|---|
| Unit | Logic in isolation | Milliseconds | Most |
| Integration / contract | Parts work together; an API keeps its promised shape | Seconds | Many |
| End-to-end | A user journey works through the real UI | Seconds to minutes | Few, critical journeys only |
| Manual / exploratory | Things automation misses: feel, edge cases, new features | Minutes | Targeted sessions |

API contract tests check status codes, required fields, types and error
shapes for each endpoint, ideally from a shared contract (for example an
OpenAPI file or consumer-driven contracts), so a backend change that breaks a
client fails before release.

## Test plan

```markdown
## Test plan: <feature or release>
Scope: <in> / Out of scope: <out>
Risks: <what is most likely to break and why>
| Area | Level | Tests | Environment | Data | Owner |
|---|---|---|---|---|---|
| Checkout | E2E | pay with test card, declined card | staging | test account | qa |
Entry criteria: <build deployed to staging, data seeded>
Exit criteria: <all critical tests pass, no open high bugs>
```

## Before and after

Capture the same things before and after a change, on the same environment
and data:

- screenshots of key pages at fixed viewport sizes;
- API responses for a fixed set of requests (ignore timestamps and IDs);
- timings (page load, p95 of key endpoints) over several runs;
- counts that should not move (rows, pages indexed, jobs processed).

```markdown
| Item | Before | After | Verdict |
|---|---|---|---|
| /pricing screenshot | ok | button colour changed | intended |
| GET /v1/orders | 200, 12 fields | 200, 11 fields (missing `currency`) | bug |
| p95 /v1/orders | 180 ms | 190 ms | noise |
```

## Smoke tests

A short, read-only list run right after each deploy (by CI or the agent):

```markdown
| Check | Expected | On failure |
|---|---|---|
| GET /health | 200 within 1 s | roll back |
| Home page loads, no console errors | yes | roll back |
| Login with smoke-test account | dashboard shown | roll back |
| Main API list endpoint | 200, non-empty | investigate 10 min, then roll back |
```

Agree the rollback criteria before the deploy, not during the incident.

## Bug report

```markdown
### <Short, specific title>
Environment: <prod/staging, URL, app version, browser/device>
Steps:
1. ...
Expected: ...
Actual: ...
Evidence: <screenshot, response, log excerpt with secrets removed>
Frequency: <always / 3 of 10>
Severity: <blocker / high / medium / low>, Impact: <who is affected>
```

## Flaky tests

1. Record the failure rate and the error.
2. Look for shared state, timing waits, test order, external services, time zones.
3. Fix the cause; if that takes time, quarantine with an owner and a date.

## Release sign-off

- [ ] Critical journeys pass on the release candidate.
- [ ] No open blocker or high bugs (or each accepted by the product owner).
- [ ] Before/after differences all explained.
- [ ] Smoke tests and rollback criteria ready for the deploy.
- [ ] Release notes list known issues.
