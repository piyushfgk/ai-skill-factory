# Technical strategy brief — template

```markdown
# <Product> — technical strategy

**Date:** <YYYY-MM-DD>  **Author:** <name>  **Status:** draft | agreed

## 1. Goal
<Two or three sentences: what we are building, for whom, and what success
looks like for the first release.>

## 2. Assumptions and constraints
- Deadline: <date>
- Budget: <build> / <monthly run cost>
- Team: <people and skills>
- Compliance / data residency: <...>
- Expected scale in year one: <users, requests, data size>

## 3. Platform approach
<Chosen approach and why. One line on each rejected option.>

## 4. Stack
<Comparison table from the stack decision guide, then the recommendation.>

## 5. Build vs buy
| Capability | Decision | Option | Reason |
|---|---|---|---|

## 6. Milestones
| # | Milestone | Demo-able outcome | Duration | Roles |
|---|---|---|---|---|
| 1 | | | | |
| — | **MVP cut line** | | | |

## 7. Cost estimate
| Item | At launch / month | At 10× / month |
|---|---|---|

## 8. Risk register
| Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|

## 9. Engineering standards
- Branching and review: <...>
- Testing floor: <...>
- Definition of done: <...>

## 10. Decisions
- DR-001 <title> — <link>
```

## Decision record

One file per decision, for example `docs/decisions/DR-001-database.md`.

```markdown
# DR-<number>: <decision title>

**Date:** <YYYY-MM-DD>  **Status:** proposed | accepted | superseded by DR-<n>

## Context
<What forces are at play. What problem needs a decision.>

## Options considered
1. <option> — pros / cons
2. <option> — pros / cons

## Decision
<What we chose.>

## Consequences
<What becomes easier, what becomes harder, and the cost to reverse.>
```
