---
description: "Scaffold new components in dept44 Spring Boot microservices. Use this skill whenever the user wants to create, generate, or scaffold a new CRUD endpoint, proxy endpoint, JPA entity, Feign integration, scheduled job, or integration tests (AppTests) in a dept44 service. Triggers on: 'new endpoint', 'create entity', 'add integration', 'scaffold', 'new scheduler', 'add a feign client', 'proxy endpoint', 'create CRUD', 'new job', 'add apptest', 'integration test', 'OpenAPI test', or any request to generate boilerplate for a Spring Boot microservice following dept44 conventions. Also trigger when the user mentions creating something 'like the other endpoints' or 'following the existing pattern' in a dept44 repo."
---

# dept44 Scaffolder

Generate new components in dept44 Spring Boot microservices. This skill routes to the appropriate scaffolding template based on what the user needs.

## How to use

1. Figure out which type of component the user needs (see table below)
2. Read the corresponding reference file for the full instructions
3. Follow those instructions to scaffold all required files

## Component Types

| User wants... | Read this reference |
|---|---|
| CRUD endpoint backed by a local database | `references/new-endpoint-crud.md` |
| Endpoint that proxies to an external service via Feign | `references/new-endpoint-proxy.md` |
| JPA entity + repository + Flyway migration (no endpoint) | `references/new-entity.md` |
| Feign client integration to an external service (no endpoint) | `references/new-integration.md` |
| Scheduled background job | `references/new-scheduler.md` |
| Integration tests (AppTests) + OpenAPI contract test | `references/new-apptest.md` |

## Routing hints

- If the user mentions "database", "table", "CRUD", or "persist" → **new-endpoint-crud**
- If the user mentions "proxy", "forward", "external service", "feign" with an endpoint → **new-endpoint-proxy**
- If the user only needs the data layer (entity/repo/migration) without an API → **new-entity**
- If the user only needs to call another service without exposing an endpoint → **new-integration**
- If the user mentions "cron", "scheduled", "batch", "job", "cleanup", "periodic" → **new-scheduler**
- If the user mentions "apptest", "integration test", "IT test", "OpenAPI test", "end-to-end test" → **new-apptest**

## Related Skills

- For understanding existing patterns without scaffolding, use **dept44-patterns** — it explains the conventions per layer.
- For framework internals (AbstractAppTest API, Problem usage, Specification filters), use **dept44-source**.
- For validation annotations on new API models, use **dept44-validators**.

## Cross-cutting rules

These apply to all scaffolding regardless of type — they're the dept44 way:

- Examine existing code in the repo first to match exact style — every repo has minor variations.
- Use `final` on all variables and parameters — the compiler catches reassignment bugs and the codebase is consistent.
- Use static imports for enums and constants — keeps lines short and readable.
- No Lombok, no wildcard imports — the codebase uses manual getters/setters with `create()`/`with*()` fluent builders.
- Add `@CircuitBreaker` on all repositories and Feign clients — without it, a downstream failure cascades and takes down the entire service.
- Tests are not optional — every component gets full test coverage.

## Verification

After scaffolding, run `mvn test` to verify unit tests pass, then `mvn verify` to check integration tests and coverage (85% line + branch minimum). Confirm that:
- All new classes have corresponding test classes
- `@CircuitBreaker` is present on every repository and Feign client interface
- No Lombok annotations, no wildcard imports, `final` on all parameters
- Flyway migrations use correct version numbering (check existing migrations)

## When NOT to Use

- Do NOT use when modifying existing endpoints or code — use `/dept44-patterns` instead.
- Do NOT use for framework internals lookup — use `/dept44-source`.
- Do NOT use for validator patterns — use `/dept44-validators`.

## Improvement Log
<!-- Append entries when this skill causes errors or misses edge cases -->
<!-- Format: YYYY-MM-DD: <what went wrong, what to do differently> -->
