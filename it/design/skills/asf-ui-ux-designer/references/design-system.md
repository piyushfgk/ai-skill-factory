# Design system starter

## Token structure

Name tokens by role, not by value. Keep a small primitive palette and map roles
onto it, so themes (light, dark, brand variants) only change the mapping.

```json
{
  "color": {
    "primitive": {
      "neutral-0": "#FFFFFF", "neutral-900": "#111827",
      "brand-500": "<brand>", "brand-600": "<brand darker>",
      "red-600": "<error>", "green-600": "<success>"
    },
    "text":    { "primary": "{neutral-900}", "secondary": "<grey>", "on-brand": "{neutral-0}", "danger": "{red-600}" },
    "surface": { "default": "{neutral-0}", "raised": "<light grey>", "brand": "{brand-500}" },
    "border":  { "default": "<grey>", "focus": "{brand-600}" }
  },
  "font": {
    "family": { "body": "<font stack>", "heading": "<font stack>", "mono": "<font stack>" },
    "size":   { "xs": "12px", "sm": "14px", "md": "16px", "lg": "20px", "xl": "24px", "2xl": "32px" },
    "weight": { "regular": 400, "medium": 500, "bold": 700 },
    "line-height": { "tight": 1.25, "normal": 1.5 }
  },
  "space":  { "1": "4px", "2": "8px", "3": "12px", "4": "16px", "6": "24px", "8": "32px", "12": "48px" },
  "radius": { "sm": "4px", "md": "8px", "lg": "16px", "full": "9999px" },
  "elevation": { "1": "<shadow>", "2": "<shadow>" },
  "motion": { "fast": "120ms", "normal": "200ms", "easing": "cubic-bezier(0.2, 0, 0, 1)" }
}
```

Body text at least 16 px on web. Use a 4 px or 8 px spacing grid.

## Contrast rules (WCAG 2.2 AA)

- Body text ≥ 4.5:1 against its background.
- Large text (≥ 24 px, or ≥ 18.66 px bold) ≥ 3:1.
- Icons, input borders and focus rings ≥ 3:1.
- Check every text/surface pair in both light and dark themes.

## Breakpoints (starting point)

| Name | Min width | Layout |
|---|---|---|
| sm | 0 | Single column, bottom or top navigation |
| md | 768 px | Two columns where useful |
| lg | 1024 px | Side navigation, multi-column |
| xl | 1440 px | Max content width, more whitespace |

## Component spec template

```markdown
## Component: <Button>

**Purpose:** <when to use it, and when not to>

**Anatomy:** <parts: container, label, icon>

**Variants:** primary | secondary | ghost | danger
**Sizes:** sm (32) | md (40) | lg (48)

**States:** default, hover, focus-visible, active, disabled, loading
| State | Surface | Text | Border | Notes |
|---|---|---|---|---|

**Behaviour:** <click, keyboard (Enter/Space), loading prevents double submit>

**Accessibility:** <native button element, label required for icon-only, focus ring token>

**Content:** <verb first, sentence case, max ~3 words>

**Platform notes:** <Android ripple; iOS highlight; minimum touch size 44 pt / 48 dp>
```

## Screen spec template

```markdown
## Screen: <name>

**Goal:** <what the user achieves here>
**Entry points:** <where users arrive from>
**Layout:** <regions top to bottom, with tokens for spacing>
**Content:** <copy for headings, labels, empty and error messages>
**States:** loading | empty | error | populated | no permission
**Interactions:** <what happens on each action>
**Responsive:** <changes at each breakpoint>
**Accessibility:** <heading order, focus order, announcements>
```
