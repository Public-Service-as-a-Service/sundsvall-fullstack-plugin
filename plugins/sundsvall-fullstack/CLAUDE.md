# Sundsvall Fullstack Plugin

## How to Work

1. **Read before writing** — understand the existing codebase, read relevant files completely, identify dependencies and side effects before making changes.
2. **Simplest solution** — write the simplest code that solves the problem. No premature abstractions, no features beyond what's requested.
3. **Surgical changes** — only change what's necessary. Don't refactor surrounding code, don't add comments or type annotations to unchanged code.
4. **Verify against goal** — define success criteria before starting, verify changes against the original request, surface blockers immediately.

## Frontend Golden Rules

1. **Always use `@sk-web-gui/react`** — never raw HTML or custom implementations when a component exists.
2. **Compound pattern** — use `Table.Header`, `Card.Body`, `Button.Group`, etc. No raw HTML inside sk-web-gui components.
3. **GuiProvider required** — must wrap app root for theming (`colorScheme: light/dark/system`).
4. **Check existing components first** — `grep -r "from '@sk-web-gui" src/` before creating anything new.
5. **No raw HTML for UI elements** — if `@sk-web-gui` has it, use it.

## Backend Golden Rules

1. **`final` everywhere** — all fields, parameters, variables, and local vars use `final`.
2. **No Lombok** — no `@Data`, `@Builder`, `@Getter`, `@Setter`, `@AllArgsConstructor`, etc. Use manual getters/setters, `create()` + `with*()` fluent builders, and manual `equals`/`hashCode`/`toString`.
3. **`@CircuitBreaker` on all repositories and Feign clients** — mandatory on every `@FeignClient` interface and repository interface.
4. **Constructor injection only** — no `@Autowired`. All dependencies are `final` fields set via constructor.
5. **`Problem.valueOf()` for errors** — use `Problem.valueOf(Status, message)` from `se.sundsvall.dept44.problem`, never return null for not-found cases.

## Common Mistakes

### Frontend
- Missing `GuiProvider` wrapper at app root
- Using raw `<button>`, `<input>`, `<table>` instead of sk-web-gui components
- Hardcoded Swedish strings instead of using i18n
- Direct API calls from components instead of BFF pattern
- Missing path aliases (`@components/`, `@services/`)

### Backend
- Missing `@CircuitBreaker` on repository or Feign client interfaces
- Using `@Autowired` instead of constructor injection
- Lombok annotations (`@Data`, `@Builder`, `@Getter`, `@Setter`)
- Using `org.zalando.problem` instead of `se.sundsvall.dept44.problem`
- Wildcard imports (`import java.util.*`)
- Missing `final` on method parameters or local variables
- Returning `null` instead of `Problem.valueOf(NOT_FOUND, ...)`
- Using `@PathVariable("name")` with redundant name attribute

## Jira PR Workflow

When creating a PR, ALWAYS do all steps automatically:
1. **PR body** — include Jira link: `[DRAKEN-XXXX](https://jira.sundsvall.se/browse/DRAKEN-XXXX)`
2. **Jira comment** — add PR link as comment on the Jira ticket
3. **Jira transition** — transition the ticket to "In Review"
