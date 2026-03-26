---
description: "Patterns for adding field validation in dept44 microservices — from using built-in annotations to writing custom validators. Use this skill whenever you need to validate API model fields, check which dept44 validators already exist (@ValidUuid, @ValidMunicipalityId, @OneOf, @MemberOf, etc.), create a custom ConstraintValidator, compose multiple validators with OR/AND logic, validate complex objects with multiple violation messages, or write tests for validators. Also use when you see validation-related compilation errors, need to understand why enums aren't used in API models (use @OneOf instead), or are adding new fields to a request DTO and need to pick the right validation approach."
---

# Validator Pattern

dept44 provides a rich set of built-in validators in `dept44-common-validators`. Always check these first — writing a custom validator when a built-in one exists is wasted effort.

Source: `~/code/scit/dept44/dept44-common-validators/src/main/java/se/sundsvall/dept44/common/validators/annotation/`

## Reference Files

Read the relevant file(s) based on your situation.

| Topic | Reference file | When to read |
|---|---|---|
| Built-in validators + simple field validator | `references/builtin-and-simple.md` | Looking up existing validators or writing a basic single-field validator |
| Complex object validator | `references/complex-validator.md` | Validating an object with multiple fields, emitting multiple violation messages |
| Composite validator (OR/AND) | `references/composite-validator.md` | Combining existing validators without writing an implementation class |
| Testing validators | `references/testing.md` | Writing unit tests and `{Resource}FailureTest` integration tests for validators |

## Related Skills

- For the full Resource test pattern (including `@AutoConfigureWebTestClient`), use **dept44-patterns** and read `pattern-resource.md`.
- For scaffolding a complete new endpoint with validation, use **dept44-scaffold**.
- For framework internals on how Problem/ConstraintViolationProblem works, use **dept44-source** and read `problem-api.md`.

## Verification

After adding validators, verify by running `mvn test` then `mvn verify`. Check that:
- Each custom validator has a unit test (`isValid` with valid, invalid, and null inputs)
- Each validated field has a `{Resource}FailureTest` case asserting the correct violation message
- `Violation::field` and `Violation::message` are used (record-style accessors, not `getField`/`getMessage`)

## When NOT to Use

- Do NOT use for general field validation with Jakarta annotations — use `/dept44-patterns` pattern-pojo reference.
- This skill is for custom dept44 validators only.

## Improvement Log
<!-- Append entries when this skill causes errors or misses edge cases -->
<!-- Format: YYYY-MM-DD: <what went wrong, what to do differently> -->
