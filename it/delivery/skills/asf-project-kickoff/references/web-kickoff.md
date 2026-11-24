# Web kickoff questions

Ask these when the project is a website or web app. Skip any the brief or the
code already answers. Write the answers to the "Web" section of
`.asf/project.md`, so the frontend and SEO skills read them instead of asking
again.

PWA and SEO are not either/or. A progressive web app can rank well when its
pages are pre-built or rendered on the server. What hurts search is a
client-only single-page app for content that should be found. So ask about each
need on its own.

## Questions

| # | Question | Why it matters | What the answer changes |
|---|---|---|---|
| 1 | Is this mostly content people find through search (marketing site, blog, docs, shop), mostly a logged-in app, or both? | Decides whether search is in scope and how pages are rendered | Adds or drops `asf-seo-specialist`; may change the preset |
| 2 | How should pages be rendered: pre-built static, server-rendered, client-only, or a mix by section? | Client-only content indexes poorly; static is cheapest to host | `asf-frontend-engineer` rendering plan, `asf-software-architect` |
| 3 | Should it install like an app, work offline, or send push notifications (a PWA)? | Needs a web app manifest, a service worker, a caching plan and an update strategy | PWA work for `asf-frontend-engineer` (its `references/pwa.md`) |
| 4 | Should the SEO skill run: keyword and content plan, metadata, structured data, sitemap, Core Web Vitals? | A team that doesn't need search traffic skips it | `asf-seo-specialist` on or off |
| 5 | Should we set up a search console: Google Search Console, Bing Webmaster Tools, others, or none? | Needs domain verification (DNS record or HTML file) and a submitted sitemap | Task for `asf-devops-engineer` (DNS) and `asf-seo-specialist` |
| 6 | Which analytics, if any: Google Analytics 4, a privacy-first tool (for example Plausible, Matomo, Umami), product analytics, or none? | Consent rules and page weight differ a lot between options | `asf-seo-specialist` analytics plan; consent banner task |
| 7 | Which countries and languages? | Drives consent rules, `hreflang`, translation and date/number formats | i18n tasks, legal or privacy check |

## Defaults when the user has no preference

Offer these as a starting point and let the user change them:

- Content site: pre-built static pages, SEO skill on, a search console on,
  privacy-first analytics, no PWA.
- Logged-in app: client or server rendering by route, SEO only for public
  marketing pages, product analytics on, PWA if users are mobile or offline.
- Both: split public pages (static or server-rendered, SEO on) from the app
  (behind login, PWA optional).

## Record in `.asf/project.md`

```markdown
## Web

- Kind: content site | web app | both
- Rendering: static | server | client | mixed (<which sections>)
- PWA: no | installable | offline | push
- SEO skill: on | off
- Search console: none | Google | Bing | <other>; verification: DNS | HTML file
- Analytics: none | <tool>; consent banner: yes | no
- Countries and languages: <list>
```
