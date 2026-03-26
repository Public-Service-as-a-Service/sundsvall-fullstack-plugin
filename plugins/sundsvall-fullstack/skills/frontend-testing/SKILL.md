---
description: "Jest and React Testing Library patterns for Sundsvall Next.js web apps. Use when writing component tests, mocking apiService or Zustand stores, testing i18n components, or setting up test infrastructure in a web-app-* project. Also use when asking how to test a React component, what to mock, or how to structure test files in the Sundsvall frontend stack."
---

# Frontend Testing Patterns

Testing conventions for Sundsvall `web-app-*` Next.js applications using Jest and React Testing Library.

## Test File Structure

Place test files next to their components:

```
components/
  document-list/
    document-list.tsx
    document-list.test.tsx
```

Name test files `{component-name}.test.tsx`. Use `describe` blocks matching the component name.

## Component Test Pattern

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { DocumentList } from './document-list';

describe('DocumentList', () => {
  it('renders document titles', () => {
    render(<DocumentList documents={mockDocuments} />);
    expect(screen.getByText('Test Document')).toBeInTheDocument();
  });

  it('calls onSelect when a row is clicked', async () => {
    const onSelect = jest.fn();
    render(<DocumentList documents={mockDocuments} onSelect={onSelect} />);
    await userEvent.click(screen.getByText('Test Document'));
    expect(onSelect).toHaveBeenCalledWith('doc-123');
  });
});
```

## Mocking apiService

```tsx
jest.mock('@services/api-service', () => ({
  apiService: {
    get: jest.fn(),
    post: jest.fn(),
    postFormData: jest.fn(),
  },
}));

import { apiService } from '@services/api-service';
const mockGet = apiService.get as jest.Mock;

beforeEach(() => {
  mockGet.mockResolvedValue({ data: { data: mockDocuments, message: 'OK' } });
});
```

## Mocking Zustand Stores

```tsx
import { useDocumentStore } from '@stores/document-store';

// Mock the entire store
jest.mock('@stores/document-store');

beforeEach(() => {
  (useDocumentStore as unknown as jest.Mock).mockReturnValue({
    loading: false,
    error: null,
    setLoading: jest.fn(),
    setError: jest.fn(),
    reset: jest.fn(),
  });
});
```

## Testing i18n Components

Wrap components that use `useTranslation()` in the provider:

```tsx
import { I18nextProvider } from 'react-i18next';
import i18n from '@app/i18n-test'; // test i18n instance with sv translations loaded

const renderWithI18n = (ui: React.ReactElement) =>
  render(<I18nextProvider i18n={i18n}>{ui}</I18nextProvider>);
```

## Verification

After writing tests:
1. Run `npm test` — all tests must pass
2. Check coverage: `npm test -- --coverage`
3. Verify no `act()` warnings in test output
4. Ensure mocks are reset between tests (`beforeEach` with `jest.clearAllMocks()`)

## When NOT to Use

- Do NOT use for E2E/Cypress testing — this skill covers unit and component tests only.
- Do NOT use for backend Java tests — use `/dept44-patterns` (pattern-apptest, pattern-resource references).
