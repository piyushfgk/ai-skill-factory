# Accessibility checklist (WCAG 2.2 AA)

Use this while building and as a review report. Mark each item Pass, Fail (with
the element and fix), or N/A.

## Perceivable

- [ ] Images have meaningful `alt` text; decorative images have empty `alt`.
- [ ] Video has captions; audio has a transcript.
- [ ] Text contrast ≥ 4.5:1 (≥ 3:1 for large text); UI component and focus
      indicator contrast ≥ 3:1.
- [ ] Colour is never the only way to convey meaning.
- [ ] Content reflows at 320 px width without horizontal scrolling.
- [ ] Text can be resized to 200% without loss of content.
- [ ] Headings form a logical outline; landmarks (`header`, `nav`, `main`,
      `footer`) are present.

## Operable

- [ ] Everything works with a keyboard; no keyboard traps.
- [ ] Focus is always visible and not hidden behind sticky headers.
- [ ] Focus order follows the visual order.
- [ ] A "skip to content" link exists on pages with repeated navigation.
- [ ] Target size is at least 24×24 CSS px, or has enough spacing.
- [ ] Anything that moves, blinks or auto-updates can be paused.
- [ ] Respects `prefers-reduced-motion`.
- [ ] Dragging actions have a single-pointer alternative.

## Understandable

- [ ] Page language is set (`lang`).
- [ ] Inputs have labels and instructions; required fields are marked in text.
- [ ] Errors are described in text and linked to the field.
- [ ] Navigation and naming are consistent across pages.
- [ ] Users are not asked to re-enter information already given in the same flow.
- [ ] Authentication does not rely on a memory or puzzle test alone (allow paste
      and password managers).

## Robust

- [ ] Native elements used where possible (`button`, `a`, `input`, `select`).
- [ ] Custom widgets follow the WAI-ARIA Authoring Practices pattern for that widget.
- [ ] Dialogs trap focus while open and return focus on close.
- [ ] Status messages (saved, error, results count) use a live region.

## Manual test pass

1. Tab through the page with no mouse.
2. Use a screen reader (VoiceOver, NVDA, TalkBack) on the core journey.
3. Zoom to 200% and test at 320 px width.
4. Turn on high contrast / forced colours mode.

## Report format

| # | Criterion | Element | Issue | Fix | Severity |
|---|---|---|---|---|---|
