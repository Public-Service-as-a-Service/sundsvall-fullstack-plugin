# Sundsvall Fullstack Plugin

Claude Code plugin marketplace for Sundsvallskommun fullstack development — dept44 Spring Boot microservices and Next.js + @sk-web-gui web applications.

## Installation

Add the marketplace, then install the plugin:

```bash
# Add the marketplace (one-time)
/plugin marketplace add Sundsvallskommun/sundsvall-fullstack-plugin

# Install the fullstack plugin
/plugin install sundsvall-fullstack@sundsvall-fullstack-plugin
```

### Atlassian integration (optional)

The plugin includes Jira/Confluence integration via MCP. The MCP server reads tokens from your shell environment when Claude Code starts, so the variables need to be set **before** launching Claude Code.

**One-time setup** — add to your shell profile so the tokens persist across sessions:

```bash
# Add these lines to ~/.zshrc (macOS) or ~/.bashrc (Linux)
export JIRA_PERSONAL_TOKEN="your-jira-token"
export CONFLUENCE_PERSONAL_TOKEN="your-confluence-token"
```

Then reload your shell (`source ~/.zshrc`) or open a new terminal. The tokens are now available every time you start Claude Code — you do not need to set them again.

> **Note:** The tokens are stored in plain text in your shell profile. If your organization requires more secure token storage, you can reference a secrets manager instead:
> ```bash
> export JIRA_PERSONAL_TOKEN="$(security find-generic-password -s jira-token -w)"  # macOS Keychain
> ```

Without these tokens, the Atlassian skills (`/sundsvall-fullstack:atlassian`, `/sundsvall-fullstack:workflow`) and MCP tools will not function. Everything else works without configuration.

## What's included

### Plugin: sundsvall-fullstack

A single consolidated plugin covering the full Sundsvall development stack.

#### Skills (13)

**Backend** (6 skills) — dept44 Spring Boot microservice patterns:

| Skill | What it does |
|---|---|
| `/sundsvall-fullstack:dept44-scaffold` | Scaffold new endpoints, entities, integrations, schedulers, and AppTests |
| `/sundsvall-fullstack:dept44-patterns` | Reference patterns for every layer — entity, resource, service, mapper, POJO, integration, scheduler, AppTest |
| `/sundsvall-fullstack:dept44-source` | Framework internals — AbstractAppTest API, Problem usage, Specification filters, pagination, file uploads |
| `/sundsvall-fullstack:dept44-migrate` | Migration guide from dept44 7.x to 8.0.x (Spring Boot 4, Jackson 3, WireMock 3) |
| `/sundsvall-fullstack:dept44-validators` | Built-in validators, custom validators, composite validators, and testing |
| `/sundsvall-fullstack:backend-security` | OAuth2 resource server, WSO2 gateway, service-to-service token flows |

**Frontend** (4 skills) — Next.js + @sk-web-gui web applications:

| Skill | What it does |
|---|---|
| `/sundsvall-fullstack:sk-web-gui` | Full component reference for @sk-web-gui/react — components, props, compound patterns, theming |
| `/sundsvall-fullstack:frontend-app` | App Router structure, provider hierarchy, BFF pattern, Zustand state, i18n, Tailwind config |
| `/sundsvall-fullstack:frontend-design` | UI/UX guidelines — accessibility (WCAG AA), responsive design, component structure, code review checklist |
| `/sundsvall-fullstack:frontend-testing` | Jest + React Testing Library — component tests, mocking apiService/stores, testing i18n |

**Cross-stack** (3 skills) — workflow and integration:

| Skill | What it does |
|---|---|
| `/sundsvall-fullstack:fullstack-feature` | End-to-end feature implementation — backend-first ordering, BFF bridge, contract alignment, verification |
| `/sundsvall-fullstack:atlassian` | Jira/Confluence tool reference — JQL/CQL queries, issue lookup, documentation search |
| `/sundsvall-fullstack:workflow` | Jira+GitHub workflow — pick up ticket, create branch, PR with Jira linking, status transitions |

#### Subagents (3)

Specialized agents that Claude dispatches automatically based on task context:

| Agent | Specialization |
|---|---|
| `backend-expert` | dept44 Spring Boot — enforces patterns, runs `mvn verify`, preloads backend skills |
| `frontend-expert` | Next.js + @sk-web-gui — enforces component usage, runs lint/typecheck, preloads frontend skills |
| `fullstack-reviewer` | Cross-stack review — verifies contract alignment, checks both stacks for pattern violations |

#### Hooks (3)

Automated checks that run without being asked:

| Hook | When it fires | What it does |
|---|---|---|
| PR workflow reminder | Creating a PR (Swedish/English) | Reminds to link Jira, add PR comment, transition status |
| Dept44 pattern check | After writing/editing Java files | Flags Lombok, @Autowired, wrong imports, missing @CircuitBreaker |
| Contract alignment | After any subagent completes | Reminds to verify field names, routes, and response types match across stacks |

#### Always-on rules (CLAUDE.md)

Loaded into every conversation automatically:

- Karpathy-inspired coding principles (read before writing, simplest solution, surgical changes, verify against goal)
- Frontend golden rules (@sk-web-gui first, compound pattern, GuiProvider, i18n)
- Backend golden rules (final everywhere, no Lombok, @CircuitBreaker, constructor injection, Problem.valueOf)
- Common mistakes to avoid for both stacks
- Jira PR workflow checklist

## How it works

Skills use **progressive disclosure** — CLAUDE.md is always loaded (~50 lines of essential rules), while detailed reference material is loaded on demand when a skill triggers. This keeps context usage low when working on one stack.

Skills include **behavioral routing** ("When NOT to Use" sections) that direct Claude to the correct skill when triggers overlap, and **improvement logs** where the agent can record edge cases it encounters for future reference.

## Adding more plugins

This repo is a **marketplace** — future plugins can be added alongside `sundsvall-fullstack`:

1. Create a new directory under `plugins/` with `.claude-plugin/plugin.json`
2. Add the plugin entry to `.claude-plugin/marketplace.json`
3. Users install it with `/plugin install new-plugin@sundsvall-fullstack-plugin`

## Tech stack covered

| Layer | Technology |
|---|---|
| **Backend framework** | dept44 (Spring Boot, JPA, Feign, Shedlock) |
| **Backend database** | MariaDB via Flyway migrations |
| **Backend testing** | JUnit 5, Mockito, WebTestClient, WireMock, Testcontainers |
| **Frontend framework** | Next.js 15 (App Router) |
| **Frontend UI** | @sk-web-gui/react (Sundsvallskommun design system) |
| **Frontend state** | Zustand |
| **Frontend i18n** | i18next + react-i18next |
| **Frontend styling** | Tailwind CSS with @sk-web-gui/core preset |
| **BFF** | Express + routing-controllers with OAuth2 token management |
| **API gateway** | WSO2 |
| **Issue tracking** | Jira (via mcp-atlassian) |
| **Documentation** | Confluence (via mcp-atlassian) |

## License

MIT
