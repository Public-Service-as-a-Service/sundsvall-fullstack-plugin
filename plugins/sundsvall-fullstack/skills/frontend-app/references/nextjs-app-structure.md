# Next.js App Structure

App Router patterns, provider hierarchy, i18n setup, and configuration for Sundsvall web apps.

## Provider Hierarchy

The app uses a two-layer provider pattern:

```
<html>
  <body>
    <AppProvider>          ← GuiProvider (theme, sk-web-gui)
      <LocalizationProvider>  ← I18nextProvider (translations)
        <Page />
      </LocalizationProvider>
    </AppProvider>
  </body>
</html>
```

### Root Layout (`src/app/layout.tsx`)

Wraps the entire app in `AppProvider` for theming:

```tsx
import '@styles/tailwind.scss';
import { ReactNode } from 'react';
import AppProvider from '@components/app-provider/app-provider';
import i18nConfig from './i18nConfig';
import type { Viewport } from 'next';

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
};

interface RootLayoutProps {
  children: ReactNode;
}

const RootLayout = ({ children }: RootLayoutProps) => {
  return (
    <html lang={i18nConfig.defaultLocale}>
      <body>
        <AppProvider>{children}</AppProvider>
      </body>
    </html>
  );
};

export default RootLayout;
```

### Root Page (`src/app/page.tsx`)

Redirects to the default locale:

```tsx
import { redirect } from 'next/navigation';
import i18nConfig from './i18nConfig';

const RootIndex = () => {
  redirect(`/${i18nConfig.defaultLocale}`);
};

export default RootIndex;
```

### Locale Layout (`src/app/[locale]/layout.tsx`)

Handles server-side i18n initialization and wraps children in `LocalizationProvider`:

```tsx
import { ReactNode } from 'react';
import LocalizationProvider from '@components/localization-provider/localization-provider';
import initLocalization from '../i18n';
import i18nConfig from '../i18nConfig';

interface LocaleLayoutProps {
  children: ReactNode;
  params: Promise<{ locale: string }>;
}

const namespaces = ['common'];

export const generateStaticParams = () => i18nConfig.locales.map((locale) => ({ locale }));

const LocaleLayout = async ({ children, params }: LocaleLayoutProps) => {
  const { locale } = await params;
  const { resources } = await initLocalization(locale, namespaces);

  return <LocalizationProvider {...{ locale, resources, namespaces }}>{children}</LocalizationProvider>;
};

export const generateMetadata = async () => {
  return {
    title: process.env.NEXT_PUBLIC_APP_NAME || 'Dokument',
    description: 'Dokumenthantering',
  };
};

export default LocaleLayout;
```

## AppProvider — GuiProvider + Theme

The `AppProvider` is a client component that wraps `GuiProvider` with the default theme and configures dayjs for Swedish locale:

```tsx
'use client';

import { GuiProvider } from '@sk-web-gui/react';
import { defaultTheme } from '@sk-web-gui/theme';
import dayjs from 'dayjs';
import 'dayjs/locale/sv';
import updateLocale from 'dayjs/plugin/updateLocale';
import utc from 'dayjs/plugin/utc';
import { ReactNode, useMemo } from 'react';

dayjs.extend(utc);
dayjs.locale('sv');
dayjs.extend(updateLocale);
dayjs.updateLocale('sv', {
  months: [
    'Januari', 'Februari', 'Mars', 'April', 'Maj', 'Juni',
    'Juli', 'Augusti', 'September', 'Oktober', 'November', 'December',
  ],
  monthsShort: ['Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dec'],
});

interface AppProviderProps {
  children: ReactNode;
}

const AppProvider = ({ children }: AppProviderProps) => {
  const theme = useMemo(
    () => ({
      ...defaultTheme,
      screens: {
        ...defaultTheme.screens,
        'medium-device-max': '800px',
      },
    }),
    []
  );

  return (
    <GuiProvider theme={theme}>
      {children}
    </GuiProvider>
  );
};

export default AppProvider;
```

Key points:
- `'use client'` is required because `GuiProvider` uses React context
- Extend `defaultTheme` from `@sk-web-gui/theme` with custom breakpoints
- Configure dayjs for Swedish month names

## LocalizationProvider — i18next

Client component that creates an i18next instance per locale:

```tsx
'use client';

import { memo, ReactNode, useMemo } from 'react';
import { createInstance, Resource } from 'i18next';
import { I18nextProvider, initReactI18next } from 'react-i18next';
import i18nConfig from '@app/i18nConfig';

interface LocalizationProviderProps {
  children: ReactNode;
  locale: string;
  namespaces: string[];
  resources: Resource;
}

const LocalizationProvider = memo<LocalizationProviderProps>(({ children, locale, namespaces, resources }) => {
  const i18n = useMemo(() => {
    const instance = createInstance();
    instance.use(initReactI18next);
    void instance.init({
      lng: locale,
      resources,
      fallbackLng: i18nConfig.defaultLocale,
      supportedLngs: i18nConfig.locales,
      defaultNS: namespaces[0],
      fallbackNS: namespaces[0],
      ns: namespaces,
      preload: [],
      initImmediate: false,
    });
    return instance;
  }, [locale, namespaces, resources]);

  return <I18nextProvider {...{ i18n }}>{children}</I18nextProvider>;
});

LocalizationProvider.displayName = 'LocalizationProvider';
export default LocalizationProvider;
```

Key points:
- Server layout loads translations, then passes `resources` to this client component
- `initImmediate: false` ensures synchronous initialization (resources are pre-loaded)
- Memoized with `memo` to prevent unnecessary re-renders

## i18n Configuration

### i18nConfig (`src/app/i18nConfig.ts`)

```ts
const i18nConfig = {
  locales: ['sv', 'en'],
  defaultLocale: 'sv',
  prefixDefault: true,
  basePath: process.env.NEXT_PUBLIC_BASE_PATH || '',
};

export default i18nConfig;
```

Swedish (`sv`) is always the default locale. `prefixDefault: true` means even the default locale is prefixed in the URL (e.g., `/sv/page`).

### Server-side i18n Init (`src/app/i18n.ts`)

```ts
import { createInstance, i18n, Resource } from 'i18next';
import { initReactI18next } from 'react-i18next/initReactI18next';
import resourcesToBackend from 'i18next-resources-to-backend';
import i18nConfig from '@app/i18nConfig';

const initLocalization = async (locale: string, namespaces: string[], i18nInstance?: i18n, resources?: Resource) => {
  i18nInstance = i18nInstance || createInstance();
  i18nInstance.use(initReactI18next);

  if (!resources) {
    i18nInstance.use(
      resourcesToBackend((language: string, namespace: string) => import(`../../locales/${language}/${namespace}.json`))
    );
  }

  await i18nInstance.init({
    lng: locale,
    resources,
    fallbackLng: i18nConfig.defaultLocale,
    supportedLngs: i18nConfig.locales,
    defaultNS: namespaces[0],
    fallbackNS: namespaces[0],
    ns: namespaces,
    preload: resources ? [] : i18nConfig.locales,
  });

  return {
    i18n: i18nInstance,
    resources: i18nInstance.services.resourceStore.data,
    t: i18nInstance.t,
  };
};

export default initLocalization;
```

Translation files live at `locales/{language}/{namespace}.json` (e.g., `locales/sv/common.json`).

### Middleware (`src/middleware.ts`)

Uses `next-i18n-router` to handle locale detection and routing:

```ts
import { NextRequest } from 'next/server';
import { i18nRouter } from 'next-i18n-router';
import i18nConfig from '@app/i18nConfig';

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;
  req.headers.set('x-path', pathname);
  return i18nRouter(req, i18nConfig);
}

export const config = {
  matcher: '/((?!api|static|.*\\..*|_next).*)',
};
```

The matcher excludes API routes, static files, and Next.js internals from locale routing.

## Using Translations in Pages

Pages use the `useTranslation` hook from `react-i18next`:

```tsx
'use client';

import { useTranslation } from 'react-i18next';

const HomePage = () => {
  const { t } = useTranslation();

  return (
    <main className="main-container min-h-screen bg-vattjom-background-100">
      <div className="mx-auto max-w-screen-lg px-6 py-12">
        <h1 className="text-h1-sm md:text-h1-md xl:text-h1-lg mb-4">{t('common:title')}</h1>
        <p className="text-large">{t('common:description')}</p>
      </div>
    </main>
  );
};

export default HomePage;
```

## Tailwind Configuration

```js
/* tailwind.config.js */
module.exports = {
  content: [
    './src/app/**/*.{js,ts,jsx,tsx}',
    './src/components/**/*.{js,ts,jsx,tsx}',
    './src/services/**/*.{js,ts,jsx,tsx}',
    './node_modules/@sk-web-gui/*/dist/**/*.js',
  ],
  darkMode: 'class',
  presets: [require('@sk-web-gui/core').preset()],
};
```

The `@sk-web-gui/core` preset provides all design tokens, component styles, and Sundsvall-specific colors (vattjom, gronsta, bjornstigen, juniskar). The `node_modules/@sk-web-gui/*/dist/**/*.js` content path is required so Tailwind can detect classes used inside sk-web-gui components.

## Next.js Configuration

```js
/* next.config.js */
module.exports = {
  output: 'standalone',
  basePath: process.env.NEXT_PUBLIC_BASE_PATH || '',
  sassOptions: {
    prependData: `$basePath: '${process.env.NEXT_PUBLIC_BASE_PATH || ''}';`,
  },
  transpilePackages: ['lucide-react'],
  experimental: {
    optimizePackageImports: ['@sk-web-gui'],
  },
};
```

Key settings:
- `output: 'standalone'` — produces a self-contained build for Docker deployment
- `basePath` — supports deployment under a sub-path (e.g., `/dokument`)
- `transpilePackages: ['lucide-react']` — required for icon tree-shaking
- `optimizePackageImports: ['@sk-web-gui']` — reduces bundle size by only importing used components

## Path Aliases

Defined in `tsconfig.base.json`:

```json
{
  "compilerOptions": {
    "baseUrl": "./",
    "paths": {
      "@app/*": ["src/app/*"],
      "@services/*": ["src/services/*"],
      "@components/*": ["src/components/*"],
      "@interfaces/*": ["src/interfaces/*"],
      "@stores/*": ["src/stores/*"],
      "@styles/*": ["src/styles/*"],
      "@utils/*": ["src/utils/*"]
    }
  }
}
```

Always use these aliases in imports instead of relative paths:

```tsx
// Good
import { apiService } from '@services/api-service';
import { useDocumentStore } from '@stores/document-store';

// Bad
import { apiService } from '../../services/api-service';
```
