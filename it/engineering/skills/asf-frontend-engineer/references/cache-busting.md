# Cache busting and versioned releases

Use this for every website, web app and PWA, before the first release. The
goal: after a deploy, every visitor gets the new version on their next page
load, with no "clear your cache" or "hard refresh" advice, while unchanged
files still come from cache.

The rule that makes this work: **a URL's content never changes; when content
changes, the URL changes.** Then long caching is safe for files, and only the
small entry documents (HTML, the service worker, the manifest) need to be
re-checked on every visit.

## Where stale copies hide

| Layer | What goes stale | Fix |
|---|---|---|
| Browser HTTP cache | HTML, CSS, JS, images kept by `Cache-Control` or heuristics (no header at all still gets cached) | Versioned URLs plus explicit headers on every response |
| Service worker caches (PWA) | The whole app shell, served offline-first | Versioned caches, update flow, old cache cleanup |
| CDN or edge cache | Any file the edge stored, including HTML if a "cache everything" rule exists | Versioned URLs, short or no edge TTL on HTML, purge on deploy |
| Reverse proxy or server page cache | Rendered HTML (CMS page caches, proxy caches) | Purge on deploy and on content publish |
| Installed PWA | Name, icons, theme colour from the manifest | Change icon URLs; the browser re-checks the manifest on its own schedule |

## 1. Give every release a version

- Pick one release version per deploy: a semantic version, a build number,
  a date stamp, or the short commit hash. Generate it in CI, never by hand.
- Expose it where people and tools can read it: a `<meta name="app-version">`
  tag or a comment in the HTML, a `version.json` (served `no-cache`), the
  footer of an admin page, and the error tracker's `release` tag.
- Use it for cache names in the service worker and in bug reports, so "which
  version are you on?" has an answer.

## 2. Version every asset URL

Pick one of these per asset type; both can live in the same project.

| Method | Example | Best for | Watch out for |
|---|---|---|---|
| Content hash in the file name | `app.3f9c2a1b.js`, `logo.8d1e4f.svg` | Anything the build tool processes (JS, CSS, fonts, imported images) | References must be rewritten by the build; keep the hash content-based, not time-based, so unchanged files keep their URL |
| Version query parameter | `/img/hero.jpg?v=1.4.2` or `?v=<file hash or mtime>` | Files that must keep a fixed name: CMS uploads, images in templates, files linked by other sites, emails, third-party embeds | Every CDN or proxy on the path must include the query string in its cache key; some old proxies don't cache query URLs at all |
| Versioned folder | `/assets/1.4.2/app.js` | Simple static sites without a bundler | Every file changes URL on every release, even unchanged ones |

Rules:

- A per-file hash or file modification time in `?v=` busts only the changed
  file; the release version busts everything on each deploy. Prefer the
  per-file value when the template can compute it.
- Update **every** reference: HTML, CSS `url(...)`, `@font-face`, JS imports
  and dynamic imports, `srcset`, `preload` links, the manifest's icon list.
- Never put a random value or the current time in the URL on each request;
  that disables caching entirely.
- Never use `?v=` on page URLs that search engines index (see
  `asf-seo-specialist`); use it on assets only.
- Keep the previous release's hashed files on the server or CDN for a while
  (at least a day, or until old sessions end). A tab opened before the deploy
  will still request old chunks; deleting them at once causes "chunk failed to
  load" errors. If a chunk still fails, catch the error and reload the page once.

## 3. Send the right cache headers

Agree these with `asf-devops-engineer` (server or CDN config) and
`asf-backend-engineer` (responses the app generates).

| Response | `Cache-Control` | Why |
|---|---|---|
| HTML pages and the app entry document | `no-cache` (or `max-age=0, must-revalidate`), with an `ETag` or `Last-Modified` | Browser re-checks on every load; a 304 costs almost nothing |
| Hashed or `?v=`-versioned assets | `public, max-age=31536000, immutable` | The URL changes when the content does, so cache for a year |
| Unversioned files you cannot rename | Short `max-age` (minutes to an hour) with revalidation | Limits how stale they get |
| Service worker script (`sw.js`) | `no-cache` | Browsers check it on navigation; a cached copy delays every update |
| Web app manifest | `no-cache` or a short `max-age` | Lets name, icon and colour changes arrive |
| `version.json` and config files read at runtime | `no-cache` | The app can poll it to detect a new release |
| API responses with user data | `private, no-store` or `private, no-cache` | Never stored by a shared cache |

`no-cache` means "check before using", not "never store". Use `no-store` only
for sensitive responses; it also stops the back/forward cache from working.

## 4. PWAs: update the service worker safely

See also [pwa.md](pwa.md#updates).

- Change the service worker file on every release (embed the release version
  or the precache list with file hashes); an identical file means "no update".
- Name caches with the version (for example `app-shell-1.4.2`) and, in the
  `activate` handler, delete caches whose names don't match the current set.
- Choose the update flow and write it down:
  - **Prompt to reload** (default for apps with forms or unsaved work): the new
    worker installs and waits; the page shows "A new version is available,
    reload"; on click, tell the waiting worker to skip waiting and reload once
    when the controller changes.
  - **Activate immediately** (content sites with little state): call the
    skip-waiting step on install and claim clients on activate, then reload or
    accept that the open page runs the old code until the next navigation.
- Check for updates while the app stays open: call the registration's update
  check on page focus or every few hours, and poll `version.json` if the app
  also needs to notice new server releases.
- Precache the app shell by hashed URL; serve HTML network-first (fall back to
  cache when offline) so online users always get the latest page.
- Keep the kill switch from [pwa.md](pwa.md#updates) ready.

## 5. Manifest and icons

- Version icon URLs (hashed names or `?v=`) and change them whenever the art
  changes; the installed app picks up the new icons when the browser next
  re-checks the manifest, which can take a day or more and varies by platform.
- Keep the manifest URL stable and set its `id`, so the installed app keeps its
  identity; change the content, not the URL.
- Version favicons and touch icons linked from the HTML in the same way.

## 6. Purge shared caches on deploy

Hand the purge step to `asf-devops-engineer` as a pipeline stage, after the
new files are live and before the smoke test:

- Purge HTML and the unversioned entry files (`/`, page URLs, `sw.js`, the
  manifest, `version.json`), or purge everything on small sites.
- Versioned assets need no purge; that is the point of versioning.
- CMS sites: purge the server page cache and the CDN when content is
  published, not only on deploy.
- Check the CDN's cache key includes the query string when `?v=` is used, and
  that the CDN respects the origin's `Cache-Control` for HTML.

If the project uses a CDN vendor's companion skills (see
`.asf/project.md`), use them for the exact purge command and cache settings.

## 7. Verify after each deploy

With `asf-qa-engineer`:

- [ ] `curl -sI https://example.com/` shows the HTML `Cache-Control` from the table.
- [ ] A hashed asset shows `max-age=31536000, immutable`; its URL changed if its content changed.
- [ ] The release version in the page or `version.json` matches the deploy.
- [ ] A returning browser (not a private window) sees the new version on a
      normal reload, without clearing data.
- [ ] PWA: the new service worker installs, the update prompt or auto-activate
      works, and old caches are gone (browser dev tools, Application panel).
- [ ] CDN response header shows a miss or revalidation for HTML after the purge.
- [ ] An old tab opened before the deploy can still navigate without chunk errors.

## Anti-patterns

- **"Tell users to hard refresh."** If a deploy needs that, versioning is missing.
- **Same file name, new content, long cache.** The classic cause of stale CSS and JS.
- **`no-store` on everything.** Slow for every visitor and still doesn't fix a cached service worker.
- **"Cache everything" CDN rule including HTML** without a purge step.
- **Long-cached `sw.js`.** Users stay on the old app for days.
- **Deleting old chunks in the same deploy.** Breaks every tab that is already open.
- **Timestamps in URLs on every request.** Busts the cache for unchanged files too.
