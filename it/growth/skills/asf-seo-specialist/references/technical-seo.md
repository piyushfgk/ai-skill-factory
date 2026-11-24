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
