---
description: "Reference patterns for dept44 Spring Boot microservices. Use this skill whenever the user asks about dept44 coding conventions, needs to understand how a specific layer works (entity, repository, service, resource, mapper, POJO, scheduler, integration test), wants to write or fix tests following dept44 style, or asks 'how do we do X in dept44'. Triggers on: 'dept44 pattern', 'how should I write', 'test pattern', 'what does the entity look like', 'service layer pattern', 'mapper pattern', 'resource test', 'apptest', 'integration test pattern', 'POJO style', 'bean test', reviewing or fixing code in a dept44 repo, or any question about dept44 coding conventions and test patterns. Also trigger when the user is working in a dept44 codebase and asks about the correct way to structure something."
---

# dept44 Pattern Reference

Quick-reference patterns for every layer in a dept44 Spring Boot microservice. Read the relevant reference file(s) based on what the user is working on.

## Pattern Index

| Layer / Concern | Reference file | When to read |
|---|---|---|
| API Models (POJOs) | `references/pattern-pojo.md` | Writing or testing `api/model/` classes |
| JPA Entities | `references/pattern-entity.md` | Writing or testing `integration/db/model/` classes and repositories |
| Feign Integrations | `references/pattern-integration.md` | Writing or testing external service clients in `integration/` |
| Mappers | `references/pattern-mapper.md` | Writing or testing `service/mapper/` classes |
| Services | `references/pattern-service.md` | Writing or testing `service/` classes |
| Resources (Controllers) | `references/pattern-resource.md` | Writing or testing `api/` REST controllers |
| Schedulers | `references/pattern-scheduler.md` | Writing or testing `service/scheduler/` jobs |
| AppTests (E2E) | `references/pattern-apptest.md` | Writing integration tests in `src/integration-test/` |

## Usage

Most tasks only need 1-2 reference files. Read the ones relevant to the user's question — no need to load everything.

## Related Skills

- If scaffolding a new component from scratch, use **dept44-scaffold** instead — it has full step-by-step instructions.
- For framework internals (where a class lives, AbstractAppTest API, Problem usage), use **dept44-source**.
- For validation annotations and custom validators, use **dept44-validators**.
- For migrating from dept44 7.x to 8.x, use **dept44-migrate**.

## Verification

After writing or modifying code based on these patterns, verify by running `mvn test` (unit tests) then `mvn verify` (integration tests + coverage). Check that `@CircuitBreaker` is present on all repository and Feign client interfaces — without it, a downstream failure cascades and takes down the entire service.

## When NOT to Use

- Do NOT use when creating components from scratch — use `/dept44-scaffold` instead.
- Do NOT use for validator patterns — use `/dept44-validators`.
- Do NOT use for framework internals lookup — use `/dept44-source`.

## Improvement Log
<!-- Append entries when this skill causes errors or misses edge cases -->
<!-- Format: YYYY-MM-DD: <what went wrong, what to do differently> -->
