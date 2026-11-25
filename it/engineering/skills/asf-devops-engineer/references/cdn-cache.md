# CDN and edge cache settings

Use this when a CDN, edge network, caching reverse proxy or tunnel provider
sits in front of a site. It is the edge half of the cache-busting plan; the
asset versioning and header table live in `asf-frontend-engineer`'s
`references/cache-busting.md`. If that skill is not installed, the short
version is: versioned asset URLs get `public, max-age=31536000, immutable`;
HTML, the service worker, the manifest and `version.json` get `no-cache`.

## Settings to check on any CDN

| Setting | Safe value | What goes wrong otherwise |
|---|---|---|
| Cache key | Includes the full query string (or at least `v`) | `?v=` versions are ignored and the old file is served |
| Origin headers | Respected: the edge and the browser follow the origin's `Cache-Control` | An edge "browser TTL" override makes `no-cache` HTML stick in browsers for hours |
| HTML caching | Not cached at the edge, or cached only with a purge on every deploy and publish | Visitors get the old page after a release |
| "Cache everything" or full-page rules | None, or scoped to paths that are purged on deploy | HTML and `sw.js` are frozen at the edge |
| Cookies and auth | Responses that set cookies or vary by `Authorization` are never shared-cached | One user's page served to another |
| Service worker and manifest | Bypass the edge cache or `no-cache` | PWA updates delayed for every user |
| Cache status header | Known and checked after each deploy | No way to tell a hit from a miss |

## Purge on deploy

- Add a pipeline stage after the new files are live: purge HTML and the
  unversioned entry files (`/`, page URLs, `sw.js`, the manifest,
  `version.json`) by URL, or purge everything on small sites. Versioned
  assets need no purge.
- Use the provider's API or CLI with a token scoped only to cache purge for
  that site, stored in the CI secret store. Never use an account-wide key.
- CMS sites: purge on content publish too (a CMS plugin or webhook), page cache first, then CDN.
- Purges can take seconds to minutes to reach every edge location; run the
  smoke test after the purge call returns, and recheck once if it fails.

## Verify

```bash
curl -sI https://example.com/ | grep -iE 'cache-control|age|etag|<cache status header>'
curl -sI https://example.com/assets/app.<hash>.js | grep -iE 'cache-control|<cache status header>'
```

- HTML: `Cache-Control: no-cache`; the cache status is a miss, bypass,
  dynamic or revalidated right after a deploy.
- Hashed asset: `max-age=31536000, immutable`; a hit on the second request.
- Change only the `?v=` value on a fixed-name file and confirm the response
  is a miss (the query string is in the cache key).

## Provider notes

Setting names change; confirm them in the provider's current docs or its
companion skills (listed in `.asf/project.md`) before changing anything.

### Cloudflare

- **Caching level**: keep Standard, which includes the query string in the
  cache key. "Ignore query string" breaks `?v=` versions.
- **Browser Cache TTL**: set to respect existing headers, so the origin's
  `no-cache` on HTML and `immutable` on assets reach the browser.
- **HTML** is not edge-cached by default. A Cache Rule (or older Page Rule)
  with "cache everything" or "eligible for cache" on HTML changes that; if one
  exists, the deploy must purge it.
- **Purge** through the API (purge by URL for HTML and entry files, or
  purge everything on small sites) with an API token that has only cache
  purge permission for that zone.
- **Pages and Workers static assets**: build tools usually hash file names
  and each deployment serves its own files; still set headers for HTML,
  `sw.js` and the manifest, for example in a `_headers` file.
- **Development mode** bypasses the cache for a few hours. Useful for
  debugging, never a substitute for versioning.
- **Cache status header**: `cf-cache-status` (`HIT`, `MISS`, `EXPIRED`,
  `REVALIDATED`, `BYPASS`, `DYNAMIC`).

### Other CDNs and proxies

Check the same table: the cache key or cache policy setting (query strings
included), whether it overrides origin TTLs, any full-page cache rules, the
purge or invalidation API, and its cache status header (often `x-cache` or
`age`). On a self-hosted caching proxy, key on the full URI and bypass the
cache for requests with session cookies.
