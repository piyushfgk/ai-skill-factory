# DevOps playbook

## Hosting options

| Option | Good fit | Operational load | Watch out for |
|---|---|---|---|
| Static hosting + CDN | Static sites, SPAs | Very low | Server logic needs functions or a separate API |
| Platform as a service | Small teams, standard web apps | Low | Cost at scale; platform limits |
| Serverless functions | Spiky or low traffic, event-driven work | Low | Cold starts, timeouts, local dev, vendor lock-in |
| Single VM / VPS with containers | Tight budget, predictable load, Linux skills in team | Medium | You own patching, backups, TLS, scaling |
| Managed containers (non-Kubernetes) | Containerised apps that need autoscaling | Medium-low | Platform-specific config |
| Managed Kubernetes | Many services, platform team, portability needs | High | Complexity; needs dedicated skills |

Prefer managed databases over self-hosted unless cost or compliance forces it.

## Environments

| Environment | Purpose | Data | Deploys |
|---|---|---|---|
| Local | Development | Seed / fake data | Developer |
| Preview (per pull request) | Review UI and API changes | Seed data | Automatic on PR |
| Staging | Release candidate, smoke and load tests | Anonymised or synthetic | Automatic on merge |
| Production | Users | Real | Promotion of the staging artifact |

## Pipeline stages

1. **Checkout and cache** dependencies.
2. **Static checks**: format, lint, type check.
3. **Tests**: unit and component in parallel; integration tests against
   containers or ephemeral services.
4. **Build once**: produce a versioned artifact (container image, static bundle,
   mobile binary) tagged with the commit SHA.
5. **Scan**: dependency vulnerabilities, container image, secrets in code,
   infrastructure-as-code misconfiguration.
6. **Deploy to staging** and run database migrations (backwards compatible).
7. **Smoke and end-to-end tests** against staging.
8. **Promote to production** with the same artifact: rolling, blue-green or
   canary, with automatic rollback on failed health checks.
9. **Purge caches**: CDN and server page cache for HTML and unversioned
   entry files (or everything on small sites); versioned assets need no purge.
   Keep the previous release's hashed assets for at least a day.
10. **Verify**: health checks, error rate and latency compared with before
    deploy; the served release version and cache headers match the deploy.
11. **Notify** the team with the version and change log.

Rules: pipeline as code in the repo; required checks before merge; pin action or
image versions; least-privilege tokens (prefer short-lived OIDC credentials over
stored cloud keys).

## Database migrations

- Expand then contract: add new columns or tables first, deploy code that uses
  both, backfill, then remove the old ones in a later release.
- Migrations run automatically in the pipeline, never by hand in production.
- Every migration is tested against a copy of production-sized data before release.

## Mobile release pipeline

1. Build on CI with signing keys stored in the CI secret store or a dedicated
   signing service; never in the repo.
2. Version name from the release tag; build number from the CI run number.
3. Upload to internal test tracks (for example Google Play internal testing,
   Apple TestFlight).
4. Run automated UI tests on emulators/simulators or a device farm.
5. Staged rollout in production (for example 5% → 20% → 100%) while watching
   crash-free sessions.
6. Keep the API backward compatible with at least the previous two app versions;
   use remote config or feature flags to switch features off without a release.

## Observability baseline

- **Logs:** structured JSON, request ID on every line, no personal data or secrets.
- **Metrics:** golden signals per service; database connections and queue depth.
- **Traces:** propagate trace context from client to API to database.
- **Errors:** error tracking for backend, web and mobile, with release tags.
- **Uptime:** external checks on the main user journeys.
- **Dashboards:** one per service plus one business dashboard (sign-ups, orders).

## SLO example

| Journey | SLI | SLO | Error budget (30 days) |
|---|---|---|---|
| Checkout API | Share of requests with 2xx/4xx in < 500 ms | 99.5% | ~3.6 hours |

Alert on fast burn (for example 2% of budget in 1 hour) and slow burn (for
example 10% in 3 days).

## Linux host hardening (if you run VMs)

- SSH keys only, no root login, non-default user, firewall allowing only
  required ports.
- Automatic security updates; reboot window for kernel updates.
- Fail2ban or equivalent; audit logging; time sync.
- Run services as non-root users; containers with read-only filesystems where possible.
- TLS certificates renewed automatically.
