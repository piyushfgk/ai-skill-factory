# Orchestration playbook

## Task board

```markdown
| ID | Task | Role skill | Owns (files or folders) | Depends on | Wave | Tier | Status | Gate |
|---|---|---|---|---|---|---|---|---|
| T1 | API design for orders | asf-software-architect | docs/design/orders.md | – | 1 | change | done | passed |
| T2 | Orders API | asf-backend-engineer | src/orders/ | T1 | 2 | change | in review | – |
| T3 | Orders page | asf-frontend-engineer | web/orders/ | T1 | 2 | change | running | – |
| T4 | Regression tests | asf-qa-engineer | tests/orders/ | T2, T3 | 3 | change | waiting | – |
```

Status values: waiting, running, in review, changes asked, done, blocked.

## Worker brief

```markdown
# Brief T<n>: <task>

**Goal:** <one sentence on the outcome>
**Role skill:** <asf-...>
**Context:** <links to the design, issue, related files; what already exists>
**You own:** <files or folders>. Do not edit anything else; if you need to, stop and say so.
**Allowed tier:** read-only | change. Anything destructive: stop and ask.
**Done when:**
- <acceptance criterion>
- tests <named tests> pass
**Hand-off note:** reply with
- what changed (files);
- how you checked it (commands and results);
- what is left or uncertain;
- anything the next task needs to know.
```

Keep briefs short and self-contained: a worker starts without your context.

## Review gate

- [ ] The diff only touches the files the brief owns.
- [ ] The done criteria are met, with evidence (test output, screenshots).
- [ ] Tests and linters pass on the merged result, not only on the worker's branch.
- [ ] No secrets, site-specific details or debug leftovers.
- [ ] A reviewer other than the author checked anything non-trivial.
- [ ] The hand-off note is complete.

On a failed gate, return a short list of required changes; after a second
failure, escalate to the person.

## Running without helper agents

Run the same briefs yourself in task-board order, one at a time. Start each
task from its brief, not from memory of the previous one, and still run the
gate before moving on.

## Cost and progress

Track per wave: tasks done, tasks blocked, rough tokens or spend, and time.
Report at the agreed rhythm and whenever a limit is close.

## Close-out

```markdown
# Close-out: <goal>

- **Done:** <tasks and what they delivered>
- **Verified by:** <tests, reviews, checks>
- **Open items:** <follow-ups with owners>
- **Cost:** <tokens or spend, time>
- **Decisions taken by the person:** <list>
```
