# Product requirements document — template

```markdown
# <Product or feature> — PRD

**Date:** <YYYY-MM-DD>  **Owner:** <name>  **Status:** draft | review | agreed

## 1. Problem
<Who has the problem, what it is, how they cope today, and why now.>

## 2. Goals and success metrics
| Metric | Type | Target | Measured by |
|---|---|---|---|
| <north-star> | North star | | |
| <metric> | Supporting | | |

## 3. Non-goals
- <What we are deliberately not doing in this release.>

## 4. Personas
### <Persona name>
- **Goal:** <...>
- **Frustration today:** <...>
- **Context:** <device, environment, frequency of use>

## 5. User journey
1. <step> → Epic: <name>
2. <step> → Epic: <name>

## 6. Requirements
### Epic: <name>
| ID | Story | Priority | Notes |
|---|---|---|---|
| US-001 | As a <persona>, I want <capability> so that <benefit>. | Must | |

Acceptance criteria for each story are listed below the table.

## 7. Non-functional requirements
- Performance: <for example, main screen usable within 2 s on a mid-range phone on 4G>
- Accessibility: <for example, WCAG 2.2 AA>
- Privacy and security: <data collected, retention, consent>
- Platforms: <browsers, OS versions, devices>
- Localisation: <languages, currencies, time zones>

## 8. MVP scope
<List of story IDs above the MVP line.>

## 9. Out of scope / later
<List of story IDs below the line, with the reason.>

## 10. Open questions
| Question | Owner | Due |
|---|---|---|
```

## User stories

**Format:** `As a <persona>, I want <capability> so that <benefit>.`

Write stories that are **INVEST**: Independent, Negotiable, Valuable, Estimable,
Small (one to three days of work), Testable.

**Acceptance criteria** use Given / When / Then. Cover the happy path, at least
one error path, and any permission rule.

```markdown
**US-014** As a returning shopper, I want to reorder a past order so that I can
buy my usual items quickly.

- Given I am signed in and have at least one past order,
  when I open Order history and choose Reorder on an order,
  then all items still in stock are added to my cart and I see the cart.
- Given an item from that order is out of stock,
  when I choose Reorder,
  then the other items are added and I see which item was skipped.
- Given I am not signed in,
  when I open Order history,
  then I am asked to sign in and returned to Order history afterwards.
```
