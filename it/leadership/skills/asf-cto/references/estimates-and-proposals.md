# Estimates and proposals

## Estimate as ranges

| Work item | Best case | Likely | Worst case | Main assumption |
|---|---|---|---|---|
| Login and roles | 3 d | 5 d | 8 d | Uses a managed auth provider |
| Payments | 4 d | 6 d | 10 d | One provider, hosted checkout |

- Break work into items of at most a few days; unknown items get a short
  spike first, estimated separately.
- Add explicit buffers for integration, testing, review and deployment
  (often 20 to 40 percent of build time) rather than padding each item.
- State what would make the worst case happen.

## Proposal outline

```markdown
# Proposal: <project or change>
## Goal and success measure
## Options
| Option | What you get | Time (range) | Cost (range) | Risks | Run cost / month |
|---|---|---|---|---|---|
| A: minimal | ... | ... | ... | ... | ... |
| B: recommended | ... | ... | ... | ... | ... |
## Recommendation and why
## Assumptions and exclusions
## Milestones and what the client sees at each
## What we need from you (access, content, decisions, by when)
## Risks and how we reduce them
```

## Go / no-go checklist

- [ ] The goal and success measure are agreed in writing.
- [ ] Every estimate has an assumption list and an exclusion list.
- [ ] Run cost after launch is shown, not only build cost.
- [ ] Access and approvals needed from the client are listed with dates.
