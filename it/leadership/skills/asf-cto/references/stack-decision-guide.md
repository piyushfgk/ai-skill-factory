# Stack decision guide

Use this to compare options. It deliberately names categories, not winners.
Fill the comparison table with the specific tools the user is considering.

## 1. Classify the project

| Type | Typical signals | What matters most |
|---|---|---|
| Content / marketing site | Mostly read-only pages, SEO critical | Static or server rendering, CDN, CMS editing |
| CRUD / SaaS app | Forms, dashboards, accounts, billing | Productivity framework, relational DB, auth, admin |
| Real-time app | Chat, live collaboration, tracking | WebSockets or similar, pub/sub, state sync |
| Marketplace | Two-sided users, payments, trust | Payments with split payouts, search, moderation |
| Data-heavy app | Reports, analytics, large imports | Query performance, background jobs, warehouse |
| Mobile-first app | Device features, offline, push | Mobile approach, sync strategy, store release |

## 2. Platform approach

| Approach | Choose when | Watch out for |
|---|---|---|
| Responsive web | Users are on desktop and mobile browsers; fastest to ship | No store presence; limited device APIs |
| PWA | Need install/offline on Android and web with one codebase | iOS support for some APIs is limited |
| Cross-platform mobile | Need store apps on both platforms with one team | Native-feature gaps; bridge upgrades |
| Native mobile (per platform) | Heavy device integration, top performance, platform-specific UX | Two codebases, two skill sets |
| Web + cross-platform mobile | Product needs both a web app and store apps | Share API and design system, not necessarily UI code |

## 3. Comparison criteria (score 1–5)

| Criterion | Question to answer |
|---|---|
| Team familiarity | Can the current team be productive in week one? |
| Hiring pool | Can we hire for this in the user's market and budget? |
| Time to MVP | How much do we get out of the box (auth, admin, ORM, UI kit)? |
| Run cost | Cost at launch and at 10× usage, including managed services |
| Ecosystem maturity | Libraries, docs, long-term support, security patch cadence |
| Lock-in | Effort to move off this choice in two years |
| Operational load | What must we patch, scale and monitor ourselves? |
| Fit for requirements | Compliance, real-time, offline, data residency |

Template:

| Criterion | Option A | Option B | Option C |
|---|---|---|---|
| Team familiarity | | | |
| Hiring pool | | | |
| Time to MVP | | | |
| Run cost | | | |
| Ecosystem maturity | | | |
| Lock-in | | | |
| Operational load | | | |
| Fit for requirements | | | |
| **Total** | | | |

Weight the criteria for the project before adding them up (for example, a
prototype weights time to MVP heavily; a regulated product weights fit for
requirements).

## 4. Build vs buy defaults for early products

| Capability | Usually | Build it yourself only if |
|---|---|---|
| Authentication | Managed identity service or framework's built-in auth | Unusual identity model or strict data residency |
| Payments | Payment provider's hosted checkout | You are the payment business |
| Transactional email / SMS | Delivery provider | Never at MVP stage |
| Search | Database full-text, then a managed search service | Search is the core product |
| File storage | Object storage with signed URLs | Never |
| Analytics | Product analytics tool | Privacy rules forbid third parties |
| Push notifications | Platform push services via a provider | Never |
| Admin panel | Framework admin or internal-tool builder | Admins need a polished product of their own |

## Existing systems

| Question | Why it matters |
|---|---|
| Which runtime, framework and database versions run in production, and when do they leave security support? | An end-of-life runtime is a security risk and blocks library updates |
| What does the hosting allow (root access, background workers, runtime versions, cron, outbound connections)? | Shared hosting limits often decide the migration path |
| Who owns each account, domain, server and vendor contract? | Changes stall when nobody can approve or nobody has access |
| What is the rollback at each step? | Staged migrations need a way back at every stage |

Staged migration, typical order: backups and monitoring first, then hosting
or runtime, then framework upgrades, then refactoring, then new features.
Each stage ships on its own and can be rolled back.
