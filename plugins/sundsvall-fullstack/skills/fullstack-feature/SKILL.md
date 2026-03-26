---
description: "End-to-end feature implementation across backend (dept44) and frontend (Next.js + @sk-web-gui). Use when adding a complete feature spanning both stacks, when asking how frontend and backend connect, when implementing from database to UI, when needing the full implementation order for a new capability, or when building a new list view, CRUD page, search page, or entity with corresponding UI."
---

# Fullstack Feature Implementation

Implement features that span both the dept44 Spring Boot backend and the Next.js + @sk-web-gui frontend. Start with the backend API and tests — this establishes the contract that frontend code depends on, preventing rework when the API shape changes.

## 1. Feature Decomposition

Break every fullstack feature into ordered steps across three layers. Complete each layer before moving to the next — this catches contract errors early when they are cheap to fix.

### Backend (dept44 Spring Boot)
See `/dept44-scaffold` for templates and `/dept44-patterns` for conventions:
1. **Entity** — Create a JPA entity with `final` fields, manual getters/setters, `create()` + `with*()` fluent builders (no Lombok). **Verify**: class compiles, unit test for builder passes.
2. **Repository** — Create a Spring Data interface with `@CircuitBreaker`. **Verify**: interface compiles.
3. **Service** — Create business logic with constructor-injected dependencies (`final` fields, no `@Autowired`). **Verify**: unit tests pass.
4. **Resource** — Create a REST controller with OpenAPI annotations, `Problem.valueOf()` for errors. **Verify**: `mvn verify` passes, endpoint responds correctly.
5. **Tests** — Write AppTest (integration) + unit tests. **Verify**: `mvn verify` — all tests green.

### BFF (Express/Node.js proxy layer)
See `/frontend-app` for BFF patterns:
6. **Controller route** — Create an Express route in the BFF that proxies to the backend endpoint. Match the backend path exactly. **Verify**: `curl` the BFF route and confirm it returns the backend response.
7. **API service call** — Wire up the BFF `ApiService` method with auth token injection. **Verify**: authenticated request succeeds through BFF.

### Frontend (Next.js + @sk-web-gui)
See `/frontend-app` for app structure and `/sk-web-gui` for components:
8. **TypeScript interface** — Define the interface matching Java API model fields exactly (same names, same casing). **Verify**: `npm run type-check` passes.
9. **API service method** — Add `apiService.get/post/put/delete` calling the BFF route. **Verify**: `npm run type-check` passes.
10. **Zustand store** — Create state management with loading/error states. **Verify**: `npm run type-check` passes.
11. **Page component** — Build the Next.js page using sk-web-gui components. **Verify**: `npm run type-check && npm run lint` passes.
12. **i18n** — Add Swedish/English translations for all user-facing strings. **Verify**: no hardcoded strings in the component.

## 2. BFF Bridge Pattern

The BFF (Backend-for-Frontend) sits between the Next.js frontend and the Java backend. It handles authentication, token injection, and request proxying.

### BFF Controller Pattern
```typescript
// backend/src/controllers/[entity].controller.ts
@Controller()
export class EntityController {
  private apiService = new ApiService();

  @Get('/entities')
  async getEntities(@Res() response: Response) {
    const res = await this.apiService.get<{ content: Entity[] }>({
      url: '/entities',
    });
    return response.status(200).json({ data: res.data.content || [], message: 'success' });
  }

  @Get('/entities/:id')
  async getEntity(@Param('id') id: string, @Res() response: Response) {
    const res = await this.apiService.get<Entity>({ url: `/entities/${id}` });
    return response.status(200).json({ data: res.data, message: 'success' });
  }

  @Post('/entities')
  async createEntity(@Body() body: CreateEntityRequest, @Res() response: Response) {
    const res = await this.apiService.post<Entity>({ url: '/entities', data: body });
    return response.status(201).json({ data: res.data, message: 'success' });
  }
}
```

### Frontend API Service Call
```typescript
// frontend/src/services/entity-service.ts
import { apiService } from '@services/api-service';

export const getEntities = () => apiService.get<ApiResponse<Entity[]>>('/entities');
export const getEntity = (id: string) => apiService.get<ApiResponse<Entity>>(`/entities/${id}`);
export const createEntity = (data: CreateEntityRequest) => apiService.post<ApiResponse<Entity>>('/entities', data);
```

## 3. Contract Alignment

Mismatched contracts are the most common fullstack bug. Align these across all three layers:

### Field Name Mapping
| Java (backend) | TypeScript (frontend) | Notes |
|---|---|---|
| `camelCase` fields | `camelCase` fields | Must match exactly — no snake_case conversion |
| `LocalDate` | `string` (ISO format) | Frontend receives `"2026-03-26"` |
| `UUID` | `string` | Frontend treats as opaque string |
| `enum` values | `string` union type | e.g., `"ACTIVE" \| "INACTIVE"` |
| `Page<T>` (Spring) | `{ content: T[], totalPages: number, ... }` | Paginated responses |

### Path Alignment
| Layer | Path | Example |
|---|---|---|
| Java Resource | `@RequestMapping("/entities")` | `GET /entities`, `GET /entities/{id}` |
| BFF Controller | `@Get('/entities')` | Same paths, proxied with auth |
| Frontend apiService | `apiService.get('/entities')` | Calls BFF, which calls backend |

### Naming Conventions
- **Java**: `EntityResource.java`, `EntityService.java`, `EntityRepository.java`
- **BFF**: `entity.controller.ts`, `entity.service.ts`
- **Frontend**: `entity-service.ts` (service), `useEntityStore.ts` (store), `entity-list.tsx` (component)

## 4. Implementation Order

Implement in this order — each layer validates the one before it:

```
1. Backend API + tests     →  mvn verify
2. BFF proxy route         →  curl the BFF endpoint
3. Frontend store + service →  npm run type-check
4. UI component (sk-web-gui) →  npm run lint
5. End-to-end manual test  →  verify full flow in browser
```

### Why This Order
- **Backend first** — the API contract is the source of truth. Changing it later forces rework in both BFF and frontend.
- **BFF second** — validates the backend API is reachable and returns the expected shape before frontend code depends on it.
- **Frontend last** — types and components depend on the API contract being stable. Building frontend against a hypothetical API leads to interface mismatches.
- **Never skip a layer** — even if you think you know the shape, verify each layer works before building the next.

## 5. Verification Sequence

Run these checks at each stage:

### After backend changes
```bash
mvn verify                    # Compiles, runs all tests
mvn test -pl <module>         # Single module tests
```

### After frontend changes
```bash
npm run type-check            # TypeScript compilation
npm run lint                  # ESLint + Prettier
npm run build                 # Full build verification
```

### Full verification
```bash
# Backend
cd backend && mvn verify

# Frontend
cd frontend && npm run type-check && npm run lint
```

## 6. Common Mistakes

### Contract Mismatches
- Java field `createdAt` but TypeScript interface has `created_at` — field names must match exactly
- Backend returns `Page<Entity>` (wrapped in `content` array) but frontend expects a plain array
- Backend enum `Status.ACTIVE` but frontend checks for `"active"` (lowercase) — enums are uppercase strings

### BFF Mistakes
- Forgetting to add the BFF proxy route — frontend gets 404 because the route does not exist in the BFF
- Not forwarding query parameters from frontend to backend through BFF
- Not handling error responses from backend in BFF controller

### Frontend Mistakes
- Importing from `@sk-web-gui/react` but using raw HTML elements — always use sk-web-gui components (see `/sk-web-gui`)
- Hardcoded Swedish strings instead of using i18n translation keys
- Direct API calls from components instead of going through the apiService/store
- Missing `GuiProvider` wrapper — required for sk-web-gui theming
- Not using compound component pattern: `Table.Header`, `Card.Body`, etc.

### Backend Mistakes
- Missing `@CircuitBreaker` on repository or Feign client interfaces
- Using `@Autowired` instead of constructor injection with `final` fields
- Lombok annotations — not allowed, use manual getters/setters
- Returning `null` for not-found instead of `Problem.valueOf(NOT_FOUND, ...)`
