---
description: "Migrate a dept44 Spring Boot microservice from dept44 7.x to 8.0.x (Spring Boot 4). Use this skill whenever the user mentions upgrading, migrating, or updating a dept44 service to version 8, Spring Boot 4, Jackson 3, WireMock 3, or the new Zalando Problem replacement. Triggers on: 'migrate to dept44 8', 'upgrade to Spring Boot 4', 'dept44 8 migration', 'Jackson 3 migration', 'WireMock 3 upgrade', 'zalando problem replacement', 'dept44 parent 8', or any mention of updating a dept44 service to a newer major version. Also trigger when the user encounters compilation errors related to moved packages (org.zalando.problem, com.fasterxml.jackson.core, etc.) in a dept44 context."
---

# dept44 8.0 Migration

Migrate a dept44 service from 7.x to 8.0.x. This is a major upgrade covering Spring Boot 4, Jackson 3, WireMock 3, and the Zalando Problem → dept44 Problem transition.

## Instructions

Read `references/migrate-dept44-8.md` for the complete migration guide. It covers:

1. **pom.xml** changes (parent version, new/renamed dependencies)
2. **Zalando Problem → dept44 Problem** (package rename + `Violation` is now a record)
3. **Jackson 2 → 3** (selective package renames, `JacksonException` replaces `JsonProcessingException`)
4. **Cache** (`@EnableCaching` moves to a `@Configuration` class)
5. **FeignException** (`contentUTF8()` replaces `getDetail()`)
6. **Test changes** (`@AutoConfigureWebTestClient`, `@Captor` needs `MockitoExtension`, etc.)
7. **Generated OpenAPI sources** (may need regeneration for Jackson 3)
8. **WireMock 3.x** mapping file cleanup (remove `persistent`, duplicate UUIDs, etc.)

The guide includes `sed` commands for bulk renames and a Python script for WireMock cleanup. Follow the steps in order.

## Related Skills

- After migrating, use **dept44-patterns** to verify code follows the 8.x conventions (e.g., `@UuidGenerator` instead of `@GeneratedValue`, `Violation::field` instead of `Violation::getField`).
- For framework internals and class locations in the new version, use **dept44-source**.

## Verification

After completing all migration steps:
1. Run `mvn test` — all unit tests must pass with the new imports and APIs.
2. Run `mvn verify` — integration tests must pass, especially tests using `WebTestClient` (need `@AutoConfigureWebTestClient`) and `@Captor` (needs `MockitoExtension`).
3. Search for leftover `org.zalando.problem` imports — none should remain.
4. Search for `com.fasterxml.jackson` — should be `tools.jackson` after Jackson 3 migration.
