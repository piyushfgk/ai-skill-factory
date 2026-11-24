# Frontend standards

## Rendering strategy

| Strategy | Use for | Trade-off |
|---|---|---|
| Static generation | Marketing pages, docs, blogs | Rebuild or revalidate on content change |
| Server rendering | Public pages with dynamic data, SEO, fast first paint | Server cost; caching needed |
| Client rendering (SPA) | Apps behind login, heavy interactivity | Slower first load; SEO weak |
| Hybrid / islands | Mostly static pages with interactive parts | More moving parts in the framework |

Choose per route, not per project, when the framework allows.

## Performance budget

Starting targets, measured at the 75th percentile of real users or on a
throttled mid-range mobile profile:

| Metric | Good |
|---|---|
| Largest Contentful Paint (LCP) | ≤ 2.5 s |
| Interaction to Next Paint (INP) | ≤ 200 ms |
| Cumulative Layout Shift (CLS) | ≤ 0.1 |
| JavaScript on initial route (compressed) | ≤ 170 KB as a starting budget |

Techniques: code splitting by route, image sizing and modern formats, font
subsetting with `font-display: swap`, preloading the LCP resource, avoiding
layout shifts by reserving space, deferring non-critical scripts.

## Project structure (one option)

```
src/
  app/ or pages/        routes and layouts
  components/ui/        primitives (button, input, dialog)
  components/           composites shared across features
  features/<feature>/   screens, hooks and state for one feature
  lib/                  api client, utils, formatting
  styles/               tokens and global styles
  tests/                end-to-end tests
```

Group by feature once the app has more than a handful of screens.

## State

| Kind | Where it lives |
|---|---|
| Server state | A data-fetching cache with revalidation |
| URL state (filters, tabs, pagination) | The URL query string |
| Form state | The form library or local component state |
| UI state (open/closed) | Local component state |
| Global app state (current user, theme) | Small context or store |

## Forms

- Every input has a visible label.
- Validate on blur and on submit; show errors next to the field and in a summary.
- Do not clear the form on error.
- Disable submit only while submitting, and show progress.
- Match the server's validation rules; the server is the source of truth.

## Testing pyramid

- Unit: pure functions, formatting, reducers.
- Component: behaviour and accessibility of components, queried by role and label.
- End-to-end: sign in, the core journey, and payment if present.
- Automated accessibility scan on each page in CI (it catches only part of the
  issues; manual checks are still needed).
