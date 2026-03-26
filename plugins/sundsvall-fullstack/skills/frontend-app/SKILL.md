---
description: "Next.js application patterns for Sundsvall web apps — App Router structure, provider hierarchy (GuiProvider + LocalizationProvider), BFF proxy backend, Zustand state management, i18n with Swedish default, API service patterns, Tailwind with @sk-web-gui/core preset. Use when creating new pages, components, stores, or services in a Sundsvall Next.js app, or when setting up a new web-app-* project."
---

# Frontend App Patterns

Conventions and architecture for Sundsvall `web-app-*` projects — Next.js frontend with Express BFF backend.

## When to Use

- Setting up a new `web-app-*` project
- Creating new pages, layouts, or route segments
- Adding providers or configuring i18n
- Building API services or Zustand stores
- Setting up the Express BFF backend
- Connecting frontend to upstream APIs through the BFF proxy

## Routing Table

| What you need | Reference file |
|---|---|
| App Router structure, provider hierarchy, i18n setup, Tailwind/Next.js config, path aliases | [nextjs-app-structure.md](references/nextjs-app-structure.md) |
| Express BFF architecture, controllers, upstream API calls with OAuth, error handling | [bff-pattern.md](references/bff-pattern.md) |
| Zustand store conventions, frontend apiService wrapper, ApiResponse envelope, URL builder | [state-and-services.md](references/state-and-services.md) |

## Project Structure Overview

```
web-app-{name}/
  frontend/
    src/
      app/                    # Next.js App Router
        layout.tsx            # Root layout — wraps AppProvider
        page.tsx              # Root redirect to /sv
        i18n.ts               # Server-side i18n init
        i18nConfig.ts         # Locale config (sv default)
        [locale]/
          layout.tsx          # Locale layout — wraps LocalizationProvider
          page.tsx            # Home page
      components/
        app-provider/         # GuiProvider + theme setup
        localization-provider/ # i18next provider
      services/               # API service wrappers
      stores/                 # Zustand state stores
      utils/                  # Helpers (api-url, etc.)
      styles/                 # Tailwind entry (tailwind.scss)
      interfaces/             # TypeScript interfaces
    middleware.ts             # i18n routing middleware
    tailwind.config.js        # @sk-web-gui/core preset
    next.config.js            # standalone output, basePath
    tsconfig.base.json        # Path aliases
  backend/
    src/
      app.ts                  # Express setup with routing-controllers
      server.ts               # Entry point
      controllers/            # Route handlers (@Controller decorators)
      services/               # API + token services
      middlewares/             # Error handling
      config/                 # Environment config
      exceptions/             # HttpException
```

## Common Mistakes

- Forgetting to wrap the root layout in `AppProvider` (breaks all sk-web-gui theming)
- Placing `'use client'` on server components that need async data fetching
- Calling the upstream API directly from the frontend instead of going through the BFF
- Hardcoding strings instead of using `t('namespace:key')` for i18n
- Missing `@sk-web-gui/core` preset in tailwind.config.js (components render unstyled)
- Not including `node_modules/@sk-web-gui/*/dist/**/*.js` in Tailwind content paths
- Using `fetch` instead of the `apiService` wrapper (loses default headers and base URL)
- Creating stores without a `reset()` method

## Related Skills

- For UI component usage and the compound component pattern, see the **sk-web-gui** skill
- For design principles, accessibility, and responsive layout guidance, see the **frontend-design** skill

## When NOT to Use

- Do NOT use for component API reference — use `/sk-web-gui`.
- Do NOT use for design principles — use `/frontend-design`.
