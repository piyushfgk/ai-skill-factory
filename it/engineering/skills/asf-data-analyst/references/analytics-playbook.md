# Analytics playbook

## Metric definition

```markdown
| Metric | Definition | Formula | Grain | Filters | Source | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Weekly active users | Distinct signed-in users with at least one key action | count(distinct user_id) | week (Mon, UTC) | excludes staff and test accounts | events.key_action | product | changed 2026-01: added mobile |
```

## Tracking plan

```markdown
| Event | When it fires | Properties | Where (client/server) | Personal data? | Owner |
|---|---|---|---|---|---|
| order_paid | payment confirmed by provider webhook | order_id, amount, currency | server | no (ids only) | backend |
```

Prefer server-side events for anything money or audit related; client events
miss blocked or closed sessions.

## Tool options

| Need | Options (pick by team size and budget) |
|---|---|
| Ad hoc analysis | SQL client, notebooks, spreadsheets for small data |
| Data modelling | SQL views, a modelling tool such as dbt or SQLMesh |
| Warehouse | The production database's replica for small data; a columnar warehouse when queries get heavy |
| Dashboards | Open-source BI (for example Metabase, Superset) or a hosted BI tool |

## Experiments

- Write the hypothesis, primary metric, guardrail metrics and minimum
  detectable effect before starting.
- Work out the sample size; run for full weeks; do not stop early on a peek.
- Check that groups are balanced (sample ratio mismatch) before reading results.
- Report the effect with a confidence interval, not only a p-value.

## Investigating a drop or spike

1. Is it real? Check tracking changes, releases, outages, bots, time zones.
2. Where is it? Split by platform, country, channel, new vs returning.
3. When did it start? Match against the change log.
4. Write what is known, what is ruled out, and what is next.

## Evidence and provenance

```markdown
**Number:** <value and unit>
**Question:** <what it answers>
**Source:** <system, table or export>
**Query:** <link to the query in version control, or the query itself>
**Filters and assumptions:** <...>
**Run at:** <date and time with time zone>, by <person or agent>
**Checked by:** <second person, or re-run result>
```
