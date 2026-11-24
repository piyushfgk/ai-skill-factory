# Analytics and consent

## Choosing a tool

Present options; the user picks. Re-check pricing and features with the vendor.

| Option | Good for | Consent impact | Trade-offs |
|---|---|---|---|
| Google Analytics 4 | Free, deep reports, ads and Search Console links | Usually needs consent in the EU/UK and similar regions | Heavier script; data sampling and retention limits; data goes to Google |
| Privacy-first hosted (for example Plausible, Fathom, Simple Analytics) | Simple traffic and goals, light pages | Often usable without a cookie banner (confirm for your jurisdiction) | Paid; fewer reports |
| Self-hosted (for example Matomo, Umami) | Full data ownership | Can be configured cookie-less | You run and update the server |
| Product analytics (for example PostHog, Mixpanel, Amplitude) | Funnels and retention inside a logged-in app | Needs consent for identified tracking | More setup; overlaps with web analytics |
| None, plus search console only | Small sites that only care about search | None | No on-site behaviour data |

## Consent basics

- Find out which laws apply from where visitors are (for example GDPR and
  ePrivacy in the EU, UK GDPR, CCPA/CPRA in California, others). This is not
  legal advice; flag the need for a legal check on regulated projects.
- Where consent is required, load non-essential tracking **only after** the
  visitor agrees, make "reject" as easy as "accept", and remember the choice.
- Anonymise or avoid personal data in events; never send emails, names or
  free-text form input to analytics.
- Keep the consent banner light so it does not hurt Core Web Vitals.

## Tracking plan

Write this before any tracking code.

| Event | Trigger | Parameters | Conversion? | Owner |
|---|---|---|---|---|
| `sign_up` | Account created successfully | `method` | Yes | Product |
| `generate_lead` | Contact form submitted | `form_id` | Yes | Marketing |
| `search` | Site search submitted | `term_length` (not the term if it may hold personal data) | No | Product |

Rules: name events in one style (`snake_case`), keep parameters few and
documented, and test every event on a preview site before launch.

## Monthly report

```markdown
## SEO and traffic, <month>

| Metric | This month | Last month | Change |
|---|---|---|---|
| Indexed pages | | | |
| Search impressions | | | |
| Search clicks | | | |
| Average position (key topics) | | | |
| Core Web Vitals (mobile, pass rate) | | | |
| Conversions | | | |

**What moved and why:** <2–3 lines>
**Next three actions:** 1. ... 2. ... 3. ...
```
