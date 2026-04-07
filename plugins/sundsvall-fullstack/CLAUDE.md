# Sundsvall Fullstack Plugin

## How to Work

1. **Read before writing** — understand the existing codebase, read relevant files completely, identify dependencies and side effects before making changes.
2. **Simplest solution** — write the simplest code that solves the problem. No premature abstractions, no features beyond what's requested.
3. **Surgical changes** — only change what's necessary. Don't refactor surrounding code, don't add comments or type annotations to unchanged code.
4. **Verify against goal** — define success criteria before starting, verify changes against the original request, surface blockers immediately.
5. **Log skill issues** — if a skill from this plugin gives objectively wrong guidance (wrong API, wrong import, wrong pattern, missing mandatory convention), fix the task first, then ask the user if they want to log it to `~/.claude/sundsvall-improvements.jsonl`.
6. **Durable memory** — when the user says "remember this" / "kom ihåg detta" or shares a persistent cross-project preference, route to `/memory-manager`. The agent may also proactively offer to save once per conversation when a clearly durable cross-project preference is detected — after the main task, never mid-execution. Skill defects go to `/improve-skill`, not memory. Project-specific shared rules go to the project's `CLAUDE.md`; personal per-project preferences go to Claude Code project memory.

## Where the conventions live

This file intentionally stays small — the detailed rules live in skills, which load on demand only when they're actually needed. Consult them when working in the relevant area.

| Area | Skill | Covers |
|---|---|---|
| Backend patterns (entity, service, resource, mapper, scheduler, apptest) | `dept44-patterns` | All layer patterns + the `final` / no-Lombok / `@CircuitBreaker` / constructor-injection / `Problem.valueOf` rules |
| Backend scaffolding | `dept44-scaffold` | Step-by-step templates for new endpoints, entities, integrations, schedulers |
| Backend framework internals | `dept44-source` | Where classes live (`AbstractAppTest`, `Problem`, validators, pagination, uploads) |
| Backend validation | `dept44-validators` | Built-in + custom validator patterns |
| Backend security | `backend-security` | OAuth2, resource server, WSO2 gateway, FeignMultiCustomizer |
| Backend major upgrades | `dept44-migrate` | dept44 7.x → 8.x migration |
| Frontend component library | `sk-web-gui` | `@sk-web-gui/react` components, compound pattern, `GuiProvider`, icons |
| Frontend app structure | `frontend-app` | Next.js App Router, BFF pattern, Zustand, i18n, apiService |
| Frontend design + a11y | `frontend-design` | Layout, responsive, WCAG AA, review checklist |
| Frontend tests | `frontend-testing` | Jest + RTL patterns, mocking apiService + stores |
| End-to-end features | `fullstack-feature` | How backend + frontend connect; full implementation order |
| Jira/GitHub workflow | `workflow` | Pick up ticket → branch → PR → link → transition. **Always follow this when creating a PR.** |
| Jira/Confluence lookups | `atlassian` | Read tools (JQL/CQL), write safety rules, and the one-time MCP setup |

## Jira/Confluence integration is opt-in

The `atlassian` and `workflow` skills use an MCP server to talk to `jira.sundsvall.se` and `confluence.sundsvall.se`. It is **not enabled by default** — see `skills/atlassian/SKILL.md` for setup.
