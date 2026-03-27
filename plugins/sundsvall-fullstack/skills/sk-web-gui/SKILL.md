---
description: "Component reference for @sk-web-gui/react. Use when building UI in any project that uses @sk-web-gui — choosing components, checking props/variants, applying compound patterns (Table.Header, Card.Body), wrapping icons with Icon, configuring GuiProvider, or verifying whether a component exists before writing custom UI."
---

# sk-web-gui Design System

When building UI in any project that uses `@sk-web-gui`, always prefer its components over raw HTML elements or custom implementations.

**Routing heuristic:** If the question is "which component or prop should I use?", stay here. If the question is "where does this live in the app or how is it wired?", use `/frontend-app`.

## Import Pattern

The primary entry point is `@sk-web-gui/react` — it re-exports all components:

```tsx
import { Button, Input, Table, Modal, GuiProvider } from '@sk-web-gui/react';
```

Individual package imports also work:

```tsx
import { Button } from '@sk-web-gui/button';
import { Input, Select, Checkbox } from '@sk-web-gui/forms';
```

For Next.js projects, use the framework-specific packages:

```tsx
import { Link } from '@sk-web-gui/next-link';
import { Card } from '@sk-web-gui/next-card';
```

## Theme & Provider

All apps must wrap content in `GuiProvider`:

```tsx
import { GuiProvider } from '@sk-web-gui/react';

<GuiProvider colorScheme="system">
  <App />
</GuiProvider>
```

GuiProvider props:
- `colorScheme` — `'light'` | `'dark'` | `'system'` (default)
- `theme` — custom theme object
- `baseFontSize` — default: 10px

Some projects configure the `@sk-web-gui/core` Tailwind preset — see `/frontend-app` for app-level Tailwind setup.

## Composite/Compound Pattern

Most components use a compound pattern. Always use the sub-components:

```tsx
// Button with group
<Button.Group>
  <Button variant="secondary">Cancel</Button>
  <Button variant="primary">Save</Button>
</Button.Group>

// Table
<Table background scrollable="x">
  <Table.Header>
    <Table.Row>
      <Table.HeaderColumn>Name</Table.HeaderColumn>
    </Table.Row>
  </Table.Header>
  <Table.Body>
    <Table.Row>
      <Table.Column>John</Table.Column>
    </Table.Row>
  </Table.Body>
</Table>

// Card
<Card>
  <Card.Image src="..." />
  <Card.Body>
    <Card.Header>Title</Card.Header>
    <Card.Text>Description</Card.Text>
  </Card.Body>
</Card>

// Tabs
<Tabs>
  <Tabs.Item label="Tab 1">Content 1</Tabs.Item>
  <Tabs.Item label="Tab 2">Content 2</Tabs.Item>
</Tabs>

// Checkbox group
<Checkbox.Group>
  <Checkbox value="a">Option A</Checkbox>
  <Checkbox value="b">Option B</Checkbox>
</Checkbox.Group>

// RadioButton group
<RadioButton.Group>
  <RadioButton value="1">Option 1</RadioButton>
  <RadioButton value="2">Option 2</RadioButton>
</RadioButton.Group>
```

## Available Components by Category

### Core & Theming
| Package | What it provides |
|---------|-----------------|
| `@sk-web-gui/react` | Main barrel export — import everything from here |
| `@sk-web-gui/core` | Tailwind CSS plugin with component styling |
| `@sk-web-gui/theme` | `GuiProvider`, color schemes, design tokens |
| `@sk-web-gui/utils` | `cx()` classname helper, polymorphic component utils |

### Buttons & Links
| Component | Props | Usage |
|-----------|-------|-------|
| `Button` | `variant`: primary, secondary, tertiary, ghost, link | `<Button variant="primary" size="md">` |
| `Button` | `color`: primary, info, success, warning, error, vattjom, gronsta, bjornstigen, juniskar | `<Button color="primary">` |
| `Button` | `size`: sm, md, lg · `loading`, `rounded`, `inverted`, `iconButton` | `<Button loading loadingText="Saving...">` |
| `Button` | `leftIcon`, `rightIcon`, `as` (polymorphic) | `<Button as="a" href="/page" leftIcon={<Icon />}>` |
| `Link` | `external`, `hideExternalIcon`, `variant`: primary, tertiary | `<Link href="..." external>` |

### Form Components (`@sk-web-gui/forms`)
| Component | Key props |
|-----------|-----------|
| `Input` | `size`: sm/md/lg · `invalid`, `disabled`, `readOnly`, `hideExtra` |
| `TextField` | Wrapper with label/error: wraps `Input` with `FormControl` |
| `Textarea` | Same API as Input for multiline |
| `Select` | Native select dropdown |
| `Combobox` | Searchable select with autocomplete |
| `Checkbox` | `checked`, `indeterminate`, `labelPosition`: left/right · `.Group` |
| `RadioButton` | `.Group` with `value`/`onChange` |
| `Switch` | Toggle switch |
| `DatePicker` | Date input |
| `FileUpload` | File input |
| `FormControl` | Context for `FormLabel`, `FormErrorMessage`, `FormHelperText` |

### Layout & Navigation
| Component | Package | What it does |
|-----------|---------|-------------|
| `Header`, `Footer` | `@sk-web-gui/layout` | Page layout components |
| `NavigationBar` | `@sk-web-gui/navigation-bar` | Top navigation bar |
| `MenuVertical` | `@sk-web-gui/menu-vertical` | Sidebar menu |
| `Breadcrumb` | `@sk-web-gui/breadcrumb` | Breadcrumb navigation |

### Data Display
| Component | Pattern | Key features |
|-----------|---------|-------------|
| `Table` | `.Header`, `.Body`, `.Row`, `.Column`, `.HeaderColumn`, `.SortButton`, `.Footer` | `background`, `scrollable`, `dense` |
| `AutoTable` | Automatic columns from data array | Pass `data` prop directly |
| `Pagination` | Standalone | `pages`, `activePage`, `changePage`, `fitContainer`, `asSelect` |
| `Accordion` | `.Item` | Expandable sections |
| `Tabs` | `.Item` with `label` | `size`: sm/md/lg · `underline`, `color` |
| `List` | `.Item` | List items |
| `Badge` | — | `color`, `counter`, `rounded`, `inverted` |
| `Chip` | — | Interactive tag element |
| `Avatar` | — | Avatar image |

### Feedback & Overlays
| Component | Package | Usage pattern |
|-----------|---------|-------------|
| `Modal` | `@sk-web-gui/modal` | Modal dialog with context/hooks |
| `Dialog` | `@sk-web-gui/modal` | Simple dialog |
| `Confirm` | `@sk-web-gui/modal` | Confirmation dialog with `useConfirm()` hook |
| `Snackbar` | `@sk-web-gui/snackbar` | Notification bar |
| `Toast` | `@sk-web-gui/toast` | Toast notifications |
| `Tooltip` | `@sk-web-gui/tooltip` | Hover tooltip |
| `PopupMenu` | `@sk-web-gui/popup-menu` | Context menu |
| `Callout` | `@sk-web-gui/callout` | Alert/callout box |
| `Alert` | `@sk-web-gui/alert` | Alert component |

### Icons & Media
| Component | Package | Usage |
|-----------|---------|-------|
| `Icon` | `@sk-web-gui/icon` | `<Icon icon={<Plus />} />` — wraps `lucide-react` icons |
| `Icon.Padded` | `@sk-web-gui/icon` | Icon with padding |
| `Image` | `@sk-web-gui/image` | Image component |
| `Logo` | `@sk-web-gui/logo` | Logo component |

### Specialized
| Component | Package | What it does |
|-----------|---------|-------------|
| `SearchField` | `@sk-web-gui/searchfield` | Search input with suggestions |
| `Filter` | `@sk-web-gui/filter` | Filter controls |
| `ProgressBar` | `@sk-web-gui/progress-bar` | Progress indicator |
| `ProgressStepper` | `@sk-web-gui/progress-stepper` | Multi-step process indicator |
| `Spinner` | `@sk-web-gui/spinner` | Loading spinner |
| `UserMenu` | `@sk-web-gui/user-menu` | User profile dropdown |
| `CookieConsent` | `@sk-web-gui/cookie-consent` | Cookie consent banner |
| `AI` | `@sk-web-gui/ai` | AI feed, chat, assistant components |
| `TextEditor` | `@sk-web-gui/text-editor` | Rich text editor |
| `CountrycodeSelect` | `@sk-web-gui/countrycode-select` | Country code picker |
| `Divider` | `@sk-web-gui/divider` | Horizontal divider |
| `Text` | `@sk-web-gui/text` | Text with `urlAsLink` auto-linkify |

## Available Sizes & Colors

**Sizes** (most components): `sm`, `md`, `lg`

**Colors**:
- Standard: `primary`, `info`, `success`, `warning`, `error`
- Regional (Sundsvall): `vattjom`, `gronsta`, `bjornstigen`, `juniskar`

**Button variants**: `primary`, `secondary`, `tertiary`, `ghost`, `link`

## Polymorphic Components

Button, Link, and Text support the `as` prop:

```tsx
<Button as="a" href="/page">Link styled as button</Button>
<Link as="button" onClick={handler}>Button styled as link</Link>
```

## Icons

Use `lucide-react` icons wrapped in the `Icon` component:

```tsx
import { Icon } from '@sk-web-gui/react';
import { Plus, Trash2, Edit } from 'lucide-react';

<Icon icon={<Plus />} />
<Button leftIcon={<Plus size={18} />}>Add item</Button>
```

## Discovery Steps

When unsure if a component exists:

1. Search the project's `package.json` for installed `@sk-web-gui/*` packages
2. Check `node_modules/@sk-web-gui/react/dist/esm/index.js` for all exports
3. Look at existing code: `grep -r "from '@sk-web-gui" src/`
4. Refer to Storybook if available: `yarn dev` in the web-shared-components repo

## Rules

- **Don't reinvent**: If `@sk-web-gui/button` exists, never create `<button className="...">`
- **Use compound pattern**: Always use `Table.Header`, `Card.Body`, etc. — not raw HTML inside components
- **Stay consistent**: Use the same variants and sizes across the application
- **Check existing usage**: Look at how the project already uses a component before adding new usage
- **GuiProvider required**: Ensure the app root has `<GuiProvider>` wrapping all content

## When NOT to Use

- Do NOT use for app architecture, routing, state management, BFF, i18n, or project bootstrapping — use `/frontend-app`.
- Do NOT use for design principles or accessibility guidelines — use `/frontend-design`.
