# State Management & API Services

Zustand store conventions and frontend API service patterns for Sundsvall web apps.

## Zustand Store Pattern

Stores follow a consistent pattern: interface-first definition, `create<State>`, always include a `reset()` method.

### Example: Document Store

```ts
import { create } from 'zustand';

interface DocumentState {
  loading: boolean;
  error: string | null;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  reset: () => void;
}

export const useDocumentStore = create<DocumentState>((set) => ({
  loading: false,
  error: null,
  setLoading: (loading) => set({ loading }),
  setError: (error) => set({ error }),
  reset: () => set({ loading: false, error: null }),
}));
```

### Conventions

- **Interface first**: Define the full `State` interface before `create<State>()`
- **Naming**: `use{Entity}Store` (e.g., `useDocumentStore`, `useUserStore`)
- **File naming**: `{entity}-store.ts` in `src/stores/`
- **Reset method**: Every store must include a `reset()` that returns state to initial values
- **Setters**: Name setters `set{Property}` (e.g., `setLoading`, `setError`)
- **No async in stores**: Keep stores synchronous. API calls belong in services or components, not stores

### Usage in Components

```tsx
'use client';

import { useDocumentStore } from '@stores/document-store';

const MyComponent = () => {
  const { loading, error, setLoading, setError, reset } = useDocumentStore();

  // Or select specific values to minimize re-renders:
  const loading = useDocumentStore((state) => state.loading);

  return <div>{loading ? 'Loading...' : 'Ready'}</div>;
};
```

### Creating a New Store

Template for adding a new entity store:

```ts
import { create } from 'zustand';

interface {Entity}State {
  // Data
  items: {Entity}[];
  selected: {Entity} | null;

  // UI state
  loading: boolean;
  error: string | null;

  // Actions
  setItems: (items: {Entity}[]) => void;
  setSelected: (item: {Entity} | null) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  reset: () => void;
}

const initialState = {
  items: [],
  selected: null,
  loading: false,
  error: null,
};

export const use{Entity}Store = create<{Entity}State>((set) => ({
  ...initialState,
  setItems: (items) => set({ items }),
  setSelected: (selected) => set({ selected }),
  setLoading: (loading) => set({ loading }),
  setError: (error) => set({ error }),
  reset: () => set(initialState),
}));
```

## Frontend API Service

The `apiService` wraps axios with default configuration and the base URL builder. It is the single point of contact for all BFF API calls from the frontend.

### apiService (`src/services/api-service.ts`)

```ts
'use client';

import { apiURL } from '@utils/api-url';
import axios from 'axios';

export interface ApiResponse<T = unknown> {
  data: T;
  message: string;
}

const defaultOptions = {
  headers: {
    'Content-Type': 'application/json',
  },
};

const get = <T>(url: string, options?: { [key: string]: any }) =>
  axios.get<T>(apiURL(url), { ...defaultOptions, ...options });

const post = <T>(url: string, data: any, options?: { [key: string]: any }) => {
  return axios.post<T>(apiURL(url), data, { ...defaultOptions, ...options });
};

const postFormData = <T>(url: string, data: FormData, options?: { [key: string]: any }) => {
  return axios.post<T>(apiURL(url), data, { ...options });
};

export const apiService = { get, post, postFormData };
```

Key points:
- `'use client'` directive — this runs in the browser
- All methods are generic (`<T>`) for typed responses
- `postFormData` omits the `Content-Type` header so the browser sets the multipart boundary
- Always use `apiService` instead of raw `axios` or `fetch`

### ApiResponse Envelope

Both frontend and backend use the same response shape:

```ts
interface ApiResponse<T = unknown> {
  data: T;
  message: string;
}
```

Usage:

```ts
const response = await apiService.get<ApiResponse<Document[]>>('/documents');
const documents = response.data.data; // ApiResponse.data contains the actual payload
```

### URL Builder (`src/utils/api-url.ts`)

```ts
export const apiURL = (...parts: string[]): string => {
  const urlParts = [process.env.NEXT_PUBLIC_API_URL, ...parts];
  return urlParts.map((pathPart) => pathPart?.replace(/(^\/|\/+$)/g, '')).join('/');
};
```

Joins `NEXT_PUBLIC_API_URL` with path segments, stripping leading/trailing slashes:

```ts
// If NEXT_PUBLIC_API_URL = "http://localhost:3001/api"
apiURL('/documents')       // → "http://localhost:3001/api/documents"
apiURL('/documents', '123') // → "http://localhost:3001/api/documents/123"
```

### Using apiService with Zustand Stores

Typical pattern for fetching data and updating store state:

```tsx
'use client';

import { useEffect } from 'react';
import { apiService, ApiResponse } from '@services/api-service';
import { useDocumentStore } from '@stores/document-store';

interface Document {
  id: string;
  title: string;
}

const DocumentList = () => {
  const { loading, error, setLoading, setError } = useDocumentStore();
  const [documents, setDocuments] = useState<Document[]>([]);

  useEffect(() => {
    const fetchDocuments = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await apiService.get<ApiResponse<Document[]>>('/documents');
        setDocuments(response.data.data);
      } catch (err) {
        setError('Failed to load documents');
      } finally {
        setLoading(false);
      }
    };
    fetchDocuments();
  }, [setLoading, setError]);

  if (loading) return <Spinner />;
  if (error) return <p>{error}</p>;

  return (
    <ul>
      {documents.map((doc) => (
        <li key={doc.id}>{doc.title}</li>
      ))}
    </ul>
  );
};
```

### Path Alias Usage

Always import using the configured aliases:

```ts
import { apiService } from '@services/api-service';
import { useDocumentStore } from '@stores/document-store';
import { apiURL } from '@utils/api-url';
import AppProvider from '@components/app-provider/app-provider';
```

The aliases are defined in `tsconfig.base.json` and map to `src/` subdirectories:
- `@app/*` → `src/app/*`
- `@services/*` → `src/services/*`
- `@components/*` → `src/components/*`
- `@interfaces/*` → `src/interfaces/*`
- `@stores/*` → `src/stores/*`
- `@styles/*` → `src/styles/*`
- `@utils/*` → `src/utils/*`

## When to Use

- Adding a new data entity: create a store in `src/stores/` and a service in `src/services/`
- Making API calls from components: use `apiService`, never raw axios/fetch
- Managing UI state (loading, error, selections): use a Zustand store
- Building URLs for the BFF: use the `apiURL()` helper
