# Production readiness review

Run before launch and before any major architecture change. Mark each item
Pass, Fail (with an action and owner), or N/A.

## Release

- [ ] Automated pipeline from merge to production; no manual build steps.
- [ ] Same artifact deployed to staging and production.
- [ ] Rollback tested and takes under 15 minutes.
- [ ] Database migrations are backward compatible.
- [ ] Feature flags exist for risky features.
- [ ] Each release has a version visible in the page or `version.json`.
- [ ] Assets use hashed names or `?v=` versions; cache headers follow the
      table in `asf-frontend-engineer`'s `references/cache-busting.md`.
- [ ] The pipeline purges HTML and entry files from the CDN and page caches
      after deploy; the CDN cache key includes the query string.
- [ ] A returning browser sees the new release on a normal reload.

## Reliability

- [ ] Health and readiness endpoints exist and are used by the platform.
- [ ] At least two instances of each stateless service in production, or a
      documented reason why not.
- [ ] Timeouts, retries with backoff, and circuit breaking on external calls.
- [ ] Load test at 2× expected peak passed in staging.
- [ ] Graceful shutdown drains in-flight requests.

## Data

- [ ] Automated backups with retention that meets the recovery point objective.
- [ ] Restore tested and timed within the recovery time objective.
- [ ] Encryption in transit (TLS) and at rest.
- [ ] Personal data inventory and deletion procedure exist.

## Security

- [ ] Secrets in a secret store; rotation documented.
- [ ] Least-privilege IAM; MFA for all human accounts.
- [ ] Dependency and image scanning in CI with a policy for critical findings.
- [ ] Security headers and CORS configured for web.
- [ ] Rate limiting and basic bot protection on public endpoints.

## Observability

- [ ] Dashboards for golden signals.
- [ ] SLOs defined for critical journeys with burn-rate alerts.
- [ ] Error tracking for backend, web and mobile, tagged by release.
- [ ] Logs are searchable and retained for the required period.

## Operations

- [ ] On-call rota and escalation path.
- [ ] Runbooks for the top five failure modes.
- [ ] Incident process and post-incident review template.
- [ ] Cost budget with alerts.

## Runbook template

```markdown
# Runbook: <alert or failure mode>

**Severity:** <SEV level>  **Owner:** <team>  **Last tested:** <date>

## Symptoms
<What users and dashboards show.>

## Impact
<Which journeys are affected.>

## Diagnose
1. <check> — command or dashboard link
2. <check>

## Mitigate
1. <safe first action, e.g. roll back to previous release>
2. <next action>

## Escalate
<Who to call and when.>

## After the incident
<Clean-up steps; open a post-incident review.>
```
