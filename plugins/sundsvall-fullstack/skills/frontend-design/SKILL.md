---
description: "UI/UX and accessibility guidelines for Sundsvall frontend development. Use when designing page layouts, structuring components, reviewing accessibility (WCAG AA), ensuring responsive design, or checking if a component follows the code review checklist. Also use when deciding how to split components, where to put styles, or how to handle loading and error states."
---

# Frontend Design Guidelines

Follow these guidelines when building UI in Sundsvallskommun web applications — they ensure consistency, accessibility, and maintainability.

## Principles

### 1. Consistency Over Creativity
- Follow established design patterns in the application — match spacing, typography, and color usage from surrounding UI
- Reuse existing layouts and component compositions before creating new ones
- Check existing code with `grep -r "className" src/` to find established patterns

### 2. Accessibility First
- Make all interactive elements keyboard navigable
- Use semantic HTML (`<nav>`, `<main>`, `<section>`, `<article>`)
- Add `aria-label` for elements without visible text
- Ensure sufficient color contrast (WCAG AA minimum)
- Associate every form field with a `<label>` element
- **Verify**: tab through every interactive element on the page

### 3. Responsive Design
- Start mobile-first, then add breakpoints
- Test layouts at 320px, 768px, 1024px, and 1440px
- Use relative units (`rem`, `%`) over fixed pixels
- Never allow horizontal scrolling on any viewport size
- **Verify**: resize the browser through all breakpoints

### 4. Performance
- Lazy load components below the fold
- Memoize expensive computations — but don't over-optimize
- Consider bundle size impact when adding dependencies

## Component Structure

- Keep one component per file
- Co-locate styles, types, and tests with the component
- Extract shared logic into custom hooks, not utility files
- Split components when they exceed ~150 lines

## Code Review Checklist

Use this before marking any frontend task as complete:

- [ ] Uses `@sk-web-gui` components where available (see `/sk-web-gui`)
- [ ] Keyboard navigation works for all interactive elements
- [ ] No hardcoded strings — all user-facing text uses i18n
- [ ] Responsive on mobile (320px) and desktop (1440px)
- [ ] No console errors or warnings
- [ ] Loading and error states handled

## When NOT to Use

- Do NOT use for component APIs — use `/sk-web-gui`.
- Do NOT use for app structure, routing, or state management — use `/frontend-app`.

## Improvement Log
<!-- Append entries when this skill causes errors or misses edge cases -->
<!-- Format: YYYY-MM-DD: <what went wrong, what to do differently> -->
