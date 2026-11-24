# Style choice, admin UI and hand-off

## Style choice

Offer two or three directions in words, then a small sample of each. Let the
user pick before writing tokens.

| Direction | Feels | Type | Colour | Density and shape |
|---|---|---|---|---|
| Calm utility | Trustworthy, quiet | Neutral sans, clear hierarchy | One accent, many greys | Comfortable spacing, small radius |
| Bold product | Energetic, modern | Expressive headings | Saturated brand colour | Large type, generous radius |
| Dense workspace | Efficient, expert | Compact sans, tabular numbers | Muted, status colours | Tight rows, minimal decoration |

Check each option for contrast (WCAG 2.2 AA), dark mode if needed, and how it
looks with real content, not lorem ipsum.

## Admin and back-office UI

For internal tools, a ready-made component library usually beats custom
design. Compare by the team's frontend stack and needs (tables, forms, charts,
permissions), for example:

| Option type | Examples | Good for | Trade-offs |
|---|---|---|---|
| Component library for your framework | MUI, Ant Design, Mantine, PrimeVue/PrimeReact, Vuetify, shadcn/ui | Custom admin inside the main app | You assemble screens yourself |
| Admin frameworks | React Admin, Refine, Filament (PHP), Django admin, Laravel Nova | CRUD over existing models fast | Opinionated; harder to deviate |
| Internal-tool builders | Low-code builders, self-hosted or SaaS | Very fast internal dashboards | Lock-in, limited custom logic |

Pick one, record the decision, and design only what the library lacks.

## Design hand-off

Hand off as text a developer or an agent can build from:

```markdown
# DESIGN.md
## Tokens          (link or inline JSON: colour roles, type scale, spacing, radius, motion)
## Components      (each with states: default, hover, focus, active, disabled, loading, error, empty)
## Screens         (layout, tokens used, responsive rules, behaviour, copy)
## Accessibility   (focus order, labels, contrast notes)
## Open questions
```

Or a single static HTML file with the screens and states, using the tokens as
CSS custom properties, which is easy to open, review and convert.
