# Progressive web app (PWA)

Use this when `.asf/project.md` (Web section) says the app should install, work
offline or send push notifications. A PWA is a set of capabilities, not a
framework: it can sit on any rendering approach. Content that should rank in
search still needs pre-built or server-rendered HTML.

## Decide what you need

| Capability | Needs | Ask |
|---|---|---|
| Installable | Web app manifest, HTTPS, icons, a service worker on most browsers | Which name, icons, colours, start URL and display mode? |
| Offline or flaky network | Service worker with a caching strategy per request type | Which screens must work offline? What happens to writes made offline? |
| Push notifications | Push subscription, a push service on the server, permission UX | What is worth interrupting the user for? Which platforms must get it? |
| Background sync | Queue writes and replay when online | Can writes conflict? Who wins? |

Platform support differs (especially iOS for push, install and storage limits).
Check current browser support for each capability before promising it.

## Manifest checklist

- [ ] `name`, `short_name`, `start_url`, `scope`, `display`, `theme_color`, `background_color`.
- [ ] Icons at least 192×192 and 512×512, plus a maskable icon.
- [ ] `id` set so the installed app keeps its identity if `start_url` changes.
- [ ] Linked from every page with `<link rel="manifest">`.

## Caching strategies

| Request | Strategy | Why |
|---|---|---|
| App shell (HTML entry, core CSS and JS) | Precache at install, versioned | Instant start, offline launch |
| Hashed static assets | Cache first | Immutable; the hash changes on deploy |
| API reads | Network first, fall back to cache (or stale-while-revalidate for non-critical data) | Fresh when online, usable offline |
| API writes | Network only; queue for background sync if offline writes are allowed | Avoid silent data loss |
| Images and media | Cache first with a size and age limit | Storage is limited and can be evicted |

Use a well-maintained service worker library or your build tool's plugin
rather than hand-writing caching logic, unless the needs are tiny.

## Updates

- A new service worker waits until all tabs of the old one close. Decide:
  show an "Update available, reload" prompt, or activate on next visit.
- Never cache the service worker file itself for long; serve it with
  `Cache-Control: no-cache` (coordinate with `asf-devops-engineer`).
- Version caches and delete old ones on activate.
- Have a kill switch: a no-op service worker you can deploy if a bad one ships.

## UX checklist

- [ ] Offline state is visible ("You're offline; showing saved data").
- [ ] Actions that need the network are disabled or queued, with a message.
- [ ] Install prompt appears after the user gets value, not on first load.
- [ ] Push permission is requested only after the user asks for a notification feature.
- [ ] Storage use is bounded; the app copes when the browser evicts the cache.

## Test

- Run the browser's PWA and Lighthouse-style audits on a production build.
- Test offline, slow 3G and update flows in a real browser, not only in dev mode.
- Test install and push on each target platform, including iOS if it matters.
