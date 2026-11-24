# Team presets

Presets are starting points. Pick the smallest one that covers the brief, then
add or drop skills by signal (see the catalog). The `core` skills,
`asf-project-kickoff` and `asf-project-setup`, are always available and do not
count toward team size.

Skills marked *(planned)* are on the roadmap but not in the library yet. Name
them in the proposal so the user knows the gap, and cover the work with the
nearest available skill or a human.

## Choosing a preset

| Preset | Team size | Typical brief | Signals that point here |
|---|---|---|---|
| Solo | 3 to 5 | Landing page, portfolio, small marketing site, prototype, internal script | One person, days to a few weeks, no accounts or payments |
| Small | 5 to 8 | MVP web app, small SaaS, simple mobile app | Sign-in, a database, a few screens, first real users |
| Medium | 10 to 15 | Product with paying users, web plus mobile, several integrations | Payments, personal data, a public API, a team of humans |
| Large | 30 to 50 | Platform, marketplace, regulated product, many teams | Compliance, multiple products, growth and support functions |

When signals disagree, ask the user which matters more: speed (smaller team) or
coverage (larger team).

## Starting teams

### Solo

| Skill | Why |
|---|---|
| `asf-product-manager` | Turns the idea into a short scope so the build stays small |
| `asf-frontend-engineer` | Builds the pages or UI |
| `asf-devops-engineer` | Domain, hosting, deploys |
| `asf-seo-specialist` | Only if it is a public site that should be found in search |

### Small = Solo plus

| Skill | Why |
|---|---|
| `asf-cto` | Stack and build-vs-buy choices that are expensive to undo |
| `asf-ui-ux-designer` | Flows and screens before code |
| `asf-backend-engineer` *(planned)* | API, auth, database |
| `asf-qa-engineer` *(planned)* | Test plan and release checks |

### Medium = Small plus

| Skill | Why |
|---|---|
| `asf-software-architect` | Boundaries, data model and API contracts across several parts |
| `asf-security-engineer` *(planned)* | Payments, personal data, threat model |
| `asf-mobile-engineer` *(planned)* | Android and iOS apps |
| `asf-data-analyst` *(planned)* | Metrics, dashboards, experiments |
| `asf-technical-writer` *(planned)* | User docs, API docs, release notes |

### Large = Medium plus, by need

Pick from these groups; most large projects need three or four of them, not all.

| Group | Skills *(all planned unless noted)* |
|---|---|
| Reliability and scale | SRE split from DevOps, performance engineer, database administrator |
| Data and ML | data engineer, ML engineer, analytics engineer |
| Compliance and trust | compliance and privacy officer, legal reviewer, accessibility auditor |
| Growth | marketing strategist, content strategist, `asf-seo-specialist` (available), growth analyst |
| Customers | customer support lead, customer success, sales engineer |
| Delivery at scale | program manager, scrum master, release manager |
| Global | localisation and i18n specialist |

## Phases

Each skill's `phase` metadata says when it is active. Only the current phase's
skills are installed as active; the others wait in `.asf/bench/`.

| Phase | Typical active skills |
|---|---|
| `discover` | product manager, CTO |
| `design` | product manager, CTO, UI/UX designer, architect |
| `build` | architect, UI/UX designer, frontend, DevOps, SEO |
| `launch` | product manager, frontend, DevOps, SEO |
| `operate` | DevOps, SEO |

A skill can list several phases. `all` means always active.

## Proposal format

Show the user this, then ask: accept, switch preset, or add/drop skills?

```markdown
**Preset: Small (6 skills)**, because <one line tied to the brief>.

| Skill | Roles | Phase | Why this project needs it |
|---|---|---|---|
| asf-product-manager | product manager, business analyst | discover, design, launch | ... |

**Left out:** asf-software-architect (one service, one database; the CTO covers it).
**Needed but not in the library yet:** backend engineer (planned); the frontend
and architect skills cover the API for now.
```
