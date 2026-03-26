---
description: "Quick-reference for dept44 framework internals — class locations, APIs, and cross-cutting patterns. Use this skill whenever you need to find where a dept44 class lives (AbstractAppTest, FeignMultiCustomizer, Problem, validators), understand how to throw errors with Problem.valueOf(), look up AbstractAppTest methods for writing AppTests, build JPA Specification filters, add pagination to an endpoint, or handle file uploads with MultipartFile. Also use when encountering unknown dept44 annotations or utilities, or before reaching for Context7/WebSearch — the local source at ~/code/scit/dept44/ is the authoritative reference. If you're working in any dept44 microservice and need to understand framework internals, check here first."
---

# dept44 Source Lookup

The dept44 framework source is at `~/code/scit/dept44/`. Read it with the `Read` tool. Use `Glob`/`Grep` for anything not in the reference files below.

**Never decompile JARs. Never use Context7 or WebSearch for dept44 internals.**

## Related Skills

- For coding conventions and test patterns per layer, use **dept44-patterns** instead.
- For generating new components from scratch, use **dept44-scaffold** instead.
- For validation annotations and custom validators, use **dept44-validators** instead.

## Reference Files

Read the relevant file(s) based on what you need — most tasks only need one or two.

| Topic | Reference file | When to read |
|---|---|---|
| Module paths & key class index | `references/module-index.md` | Finding any dept44 class or source path |
| `AbstractAppTest` API | `references/abstract-app-test.md` | Writing or understanding AppTest integration tests |
| `Problem` / error throwing | `references/problem-api.md` | Throwing errors in service or integration layers |
| Specification / filtering | `references/specification-builder.md` | Building dynamic JPA query filters for repository methods |
| Pagination | `references/pagination.md` | Adding paginated list endpoints (the full Resource->Service->Repo->Response flow) |
| File uploads / MultipartFile | `references/file-upload.md` | Handling file uploads, converting data to MultipartFile, validating file content types |

## When NOT to Use

- Do NOT use when writing application code — use `/dept44-patterns` or `/dept44-scaffold`.
- This skill is for understanding framework internals only.

## Improvement Log
<!-- Append entries when this skill causes errors or misses edge cases -->
<!-- Format: YYYY-MM-DD: <what went wrong, what to do differently> -->
