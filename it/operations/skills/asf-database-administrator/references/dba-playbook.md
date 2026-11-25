# DBA playbook

## Baseline

| Item | Relational examples | Document store examples |
|---|---|---|
| Version | `SELECT version();` | server status / build info |
| Size by table | system catalog size queries | collection stats |
| Connections | current vs max connections | current connections |
| Slow queries | slow-query log, statement statistics | profiler, slow operation log |
| Replication | replica lag, replica status | replica set status |
| Last backup | backup tool's list command | backup tool's list command |

## Migration plan

```markdown
## Migration <name> <YYYY-MM-DD>
Engine/version: <...>    Tables and rows: <orders, ~2M rows>
Tested on copy: <yes, took 4 min, lock held 0.3 s>
Backup taken: <id, time>      Approver: <name>      Window: <time>

Expand:   add nullable column `currency`; deploy app writing both
Migrate:  backfill in batches of 5,000 rows, sleep 100 ms between batches
Contract: after all app versions use `currency`, make it NOT NULL; drop old column in a later release

Verify: row counts, NULL count = 0, app error rate, replication lag < 5 s
Rollback: before contract, app reverts and ignores the new column; after contract, forward fix only
```

Lock-safe habits: create indexes concurrently or online where the engine
supports it; add columns as nullable first; avoid rewriting large tables in
one statement; set a statement or lock timeout for migrations.

## Backups and restores

| Item | Decision |
|---|---|
| RPO (data loss you can accept) | <for example 15 minutes> |
| RTO (time to be back) | <for example 1 hour> |
| Method | Logical dumps, physical snapshots, continuous log archiving (point-in-time), or the managed service's backups |
| Schedule and retention | <daily full, continuous logs, keep 30 days, monthly for 12 months> |
| Location | Off the host and another region or provider; encrypted |
| Drill | <monthly restore to scratch, check counts and app boot, record duration> |

```markdown
| Date | Backup restored | Target | Duration | Checks | Result |
|---|---|---|---|---|---|
```

## Query tuning

1. Find the top queries by total time, not just the slowest single run.
2. Read the plan (`EXPLAIN ANALYZE` or the engine's equivalent) on realistic data.
3. Fix in this order: the query itself (N+1, unbounded scans, `SELECT *`),
   then an index that matches filter and sort order, then caching, then hardware.
4. Re-measure and record before and after.

## Choosing an engine

| Engine type | Good for | Watch out for |
|---|---|---|
| Relational server (for example PostgreSQL, MySQL/MariaDB) | Most apps; transactions; reporting | Schema migrations need care at scale |
| Embedded (for example SQLite) | Single-process apps, mobile, edge, small sites | One writer at a time; not on network shares |
| Document store (for example MongoDB) | Flexible, nested documents with simple access patterns | Joins and multi-document transactions are harder; schema drift |
| Managed service | Less operations work, built-in backups | Cost, version lag, limits on extensions |
