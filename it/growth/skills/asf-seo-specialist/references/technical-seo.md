# Technical SEO

## Audit checklist

| Area | Check | How to check |
|---|---|---|
| Rendering | Main content and links are in the HTML response | Fetch the page without running scripts (for example `curl`) and look for the text |
| Status codes | Live pages 200; moved pages 301 to the final URL; gone pages 404 or 410 | Crawl the site or request key URLs |
| Redirect chains | At most one hop | Follow redirects and count |
| Robots | `robots.txt` doesn't block pages, CSS or JS that pages need; no stray `noindex` | Read `robots.txt` and page `<meta name="robots">` and `X-Robots-Tag` headers |
| Sitemap | XML sitemap of canonical, indexable URLs; referenced in `robots.txt` | Open it; compare with a crawl |
| Canonicals | Each page points to itself or its preferred version; no chains | Read `<link rel="canonical">` |
| Duplicates | One version of each URL: one host (www or not), HTTPS only, consistent trailing slash, parameters handled | Request variants; all should redirect to one |
| Cache-busting parameters | `?v=` versions only on assets (CSS, JS, images), never on page URLs, internal links, canonicals or sitemap entries; `robots.txt` doesn't block versioned assets; image URLs in structured data and social tags use the current version | Read templates and the sitemap; search the crawl for `?v=` on pages |
| Freshness after deploy | Changed pages update `lastmod` in the sitemap; HTML isn't long-cached at the CDN, so crawlers get the new content | Read the sitemap; `curl -I` a page and read `Cache-Control` and the CDN cache status header |
| International | `hreflang` pairs are reciprocal and include `x-default` when there are language versions | Read `<link rel="alternate" hreflang>` |
| Mobile | Same content on mobile; viewport set; readable without zoom | View at 360 px wide |
| Speed | Core Web Vitals (LCP, INP, CLS) pass at the 75th percentile on mobile | Field data in the search console or a lab test with throttling |
| Structured data | Valid and matching visible content | A structured-data testing tool |
| Images | Descriptive file names and alt text; modern formats; sized; lazy-loaded below the fold | Inspect templates |
| Internal links | Every important page is linked from somewhere crawlable, in a few clicks from home | Crawl depth report |
| Errors | No soft 404s; a helpful 404 page | Request a missing URL |

## Keyword map

| Intent group | Main keywords | Intent (learn, compare, buy, local) | Target page | Status |
|---|---|---|---|---|
| | | | | new, exists, needs update |

Rules: one target page per intent group; if two pages target the same group,
merge them or make their intents different.

## On-page spec

```markdown
### <URL>

- Intent group: <group>
- Title (≈50–60 chars): <title>
- Meta description (≈150–160 chars): <description>
- H1: <one heading>
- Outline: H2 <...>, H2 <...>
- Must answer: <questions searchers ask>
- Internal links in: <pages that should link here>; out: <pages this links to>
- Structured data: <type, key fields>
- Images: <image, alt text>
```

## Search console setup

1. Ask the site owner to create or own the property in their account; the agent
   or contractor is added as a user with the least role needed.
2. Prefer **domain verification by DNS record** (covers all subdomains and
   protocols); hand the record to `asf-devops-engineer`. An HTML file or meta
   tag works when DNS is out of reach.
3. Submit the sitemap; check coverage and indexing errors after a few days.
4. Repeat for other search engines the audience uses (for example Bing
   Webmaster Tools, which can import from Google Search Console).
5. On a migration, use the console's change-of-address tool if offered, and
   keep the old property to watch the move.

## Domain moves

- [ ] Decide the one canonical host (apex or `www`) and redirect the other to it.
- [ ] Map every old URL to a new URL (from the sitemap, analytics and a crawl); no mass redirects to the home page.
- [ ] 301 redirects in one hop, for HTTP and HTTPS, with and without `www`.
- [ ] Canonical tags, hreflang, sitemaps and internal links use the new URLs.
- [ ] The new domain is verified in each search console before the switch; use the change-of-address tool where offered.
- [ ] Keep the old domain and its redirects for at least a year.
- [ ] Watch indexed pages, crawl errors and traffic for several weeks; fix 404s quickly.
- [ ] Email records (MX, SPF, DKIM, DMARC) are kept working (with `asf-network-engineer`).
