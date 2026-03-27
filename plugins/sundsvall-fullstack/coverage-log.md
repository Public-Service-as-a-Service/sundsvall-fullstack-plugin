# Sundsvall Fullstack Plugin — Coverage Log

## Skills (15 total)

### Backend Skills (6)
| Skill | Purpose | Patterns Covered |
|---|---|---|
| `dept44-scaffold` | Scaffold new backend components (entities, endpoints, integrations, schedulers) | 6 reference templates: new-entity, new-endpoint-crud, new-endpoint-proxy, new-integration, new-scheduler, new-apptest |
| `dept44-patterns` | Reference guide for dept44 coding patterns and conventions | 8 pattern references: entity, pojo, resource, service, integration, mapper, scheduler, apptest |
| `dept44-source` | Deep-dive into dept44 framework source code and utilities | 6 references: abstract-app-test, file-upload, module-index, pagination, problem-api, specification-builder |
| `dept44-migrate` | Guide for migrating projects to dept44 framework version 8 | 1 reference: migrate-dept44-8 |
| `dept44-validators` | Custom validation annotations and constraint validators | 4 references: builtin-and-simple, complex-validator, composite-validator, testing |
| `backend-security` | OAuth2, resource server, and WSO2 API gateway patterns | Resource server config, FeignMultiCustomizer OAuth2, token flows, security configuration |

### Frontend Skills (4)
| Skill | Purpose | Patterns Covered |
|---|---|---|
| `frontend-app` | Next.js application structure, BFF pattern, state management with Zustand | 3 references: nextjs-app-structure, bff-pattern, state-and-services |
| `sk-web-gui` | @sk-web-gui component library usage and patterns | Component usage, compound patterns, theming, GuiProvider |
| `frontend-design` | Design system guidelines and visual patterns | Styling, responsive design, accessibility |
| `frontend-testing` | Jest + React Testing Library patterns | Component tests, apiService mocking, Zustand store mocking, i18n testing |

### Cross-Stack Skills (3)
| Skill | Purpose | Patterns Covered |
|---|---|---|
| `atlassian` | Jira and Confluence integration — search, read, limited write | JQL/CQL queries, issue lookup, Confluence search |
| `workflow` | Full Jira+GitHub development workflow | Ticket pickup, branch creation, PR creation, bidirectional Jira-GitHub linking, status transitions |
| `fullstack-feature` | End-to-end feature implementation across both stacks | Feature decomposition, BFF bridge, contract alignment, implementation order, verification sequence |

### Plugin Maintenance (2)
| Skill | Purpose | Patterns Covered |
|---|---|---|
| `improve-skill` | Review, classify, and promote accumulated skill improvement entries into concrete SKILL.md edits | JSONL review, classification (skill bug/project-specific/noise), atomic compaction, manual intake |
| `memory-manager` | Manage durable cross-project memory — ecosystem facts, workflow defaults, personal preferences | Two user-scoped files (~/.claude/sundsvall-memory.md, sundsvall-user.md), routing rules, lock+atomic writes, bilingual triggers (Swedish/English), overflow and stale detection |

## Subagents (3)
| Agent | Specialization | Preloaded Skills |
|---|---|---|
| `backend-expert` | dept44 Spring Boot development | dept44-patterns, dept44-source, dept44-validators, backend-security |
| `frontend-expert` | Next.js + @sk-web-gui frontend development | sk-web-gui, frontend-app, frontend-design, frontend-testing |
| `fullstack-reviewer` | Cross-stack code review and contract validation | dept44-patterns, sk-web-gui, frontend-app, fullstack-feature |

## Hooks (3)
| Hook | Event | Trigger | Purpose |
|---|---|---|---|
| PR reminder | UserPromptSubmit | Matches PR creation requests (Swedish/English) | Reminds to follow full Jira+GitHub PR workflow |
| Dept44 pattern check | PostToolUse | Write/Edit of Java files | Checks for Lombok, @Autowired, wrong problem imports, wildcard imports, missing @CircuitBreaker |
| Contract alignment | SubagentStop | Any subagent completion | Reminds to verify frontend-backend contract alignment (field names, routes, response envelope) |

## Self-Improvement Mechanism

CLAUDE.md instructs the agent to notice objectively wrong skill guidance (wrong API, wrong import, wrong pattern) during normal work. When detected, the agent fixes the task first, then asks the user whether to log the finding to `~/.claude/sundsvall-improvements.jsonl`.

The `/improve-skill` command reviews accumulated entries, classifies them (skill bug, project-specific, or noise), proposes concrete SKILL.md edits for skill bugs, and compacts the JSONL after review. It also supports manual intake for issues the agent didn't catch. Run it from the plugin repo to commit improvements directly.

## Memory Routing Model

The plugin distinguishes five destinations for persistent information:

| Information Type | Destination | Scope |
|---|---|---|
| Skill defect (wrong API, wrong pattern) | `~/.claude/sundsvall-improvements.jsonl` via `/improve-skill` | Plugin-wide |
| Ecosystem-wide technical fact | `~/.claude/sundsvall-memory.md` via `/memory-manager` | Cross-project |
| Personal cross-project preference | `~/.claude/sundsvall-user.md` via `/memory-manager` | User-wide |
| Project-specific shared rule | Project's own CLAUDE.md | Per-project (team) |
| Project-specific personal preference | Claude Code project memory | Per-project (personal) |

CLAUDE.md rule 6 tells the agent which destination to use. `/memory-manager` enforces routing when invoked explicitly and never writes outside the two plugin memory files.

## Behavioral Routing

9 skills include a **When NOT to Use** section that explicitly routes to sibling skills for overlapping trigger words. This prevents the wrong skill from firing on ambiguous prompts.

## Quality Audit (per-skill)

Assessed against skill-creator methodology: description trigger quality, imperative voice, verification criteria, and cross-references.

| Skill | Description Quality | Imperative Voice | Verification Criteria | Cross-References | Notes |
|---|---|---|---|---|---|
| `dept44-scaffold` | Strong — pushy with many trigger keywords | Yes | Yes — mvn test/verify + checklist | Yes — routes to patterns/source/validators | Already strong from backend-builder |
| `dept44-patterns` | Strong — covers all layer keywords | Yes | Yes — mvn test/verify + @CircuitBreaker check | Yes — routes to scaffold/source/validators/migrate | Already strong from backend-builder |
| `dept44-source` | Strong — lists specific classes and use cases | Yes | N/A (lookup skill, not action skill) | Yes — routes to patterns/scaffold/validators | Already strong from backend-builder |
| `dept44-migrate` | Strong — covers version numbers and error symptoms | Yes | Yes — 4-step verification checklist | Yes — routes to patterns/source | Already strong from backend-builder |
| `dept44-validators` | Strong — covers annotations by name | Yes | Yes — mvn test/verify + accessor style check | Yes — routes to patterns/scaffold/source | Already strong from backend-builder |
| `backend-security` | Strong — covers OAuth2, 401/403, WSO2 keywords | Yes | Yes — mvn verify + secrets check + health endpoint | Yes — routes to dept44-source, frontend-app | New skill, built with guidelines |
| `sk-web-gui` | Strong — library-generic, works for any @sk-web-gui project, routing heuristic added | Yes | N/A (reference skill) | Yes — routes to frontend-app/frontend-design | Boundary-cleaned: Tailwind config moved to frontend-app |
| `frontend-app` | Strong — explicitly Sundsvall web-app-* architecture, routing heuristic added | Yes | Implicit via reference files | Yes — routes to sk-web-gui/frontend-design | Boundary-cleaned: component API guidance deferred to sk-web-gui |
| `frontend-design` | Improved — added WCAG, responsive, component splitting triggers | Improved — converted passive to imperative | Improved — added "Verify:" steps | Improved — added /sk-web-gui cross-ref | Strengthened by integrator |
| `frontend-testing` | Strong — covers Jest, mocking, test setup keywords | Yes | Yes — npm test + coverage + act() warnings | Yes — routes to dept44-patterns for backend tests | New skill, built with guidelines |
| `fullstack-feature` | Improved — added "database to UI", "how they connect" triggers | Yes | Yes — per-step verification with mvn/npm commands | Yes — routes to dept44-scaffold/frontend-app/sk-web-gui | Strengthened by integrator |
| `atlassian` | Adequate — covers Jira/Confluence keywords | Yes | N/A (tool reference) | No — standalone | Copied verbatim, adequate for purpose |
| `workflow` | Adequate — covers PR workflow keywords | Yes | N/A (workflow steps are verification) | Yes — references /atlassian | Copied verbatim, adequate for purpose |
| `improve-skill` | Strong — covers "wrong guidance", "skill bug", "log improvement" triggers | Yes | N/A (review session is verification) | Yes — routes to SKILL.md files | JSONL lifecycle documented |
| `memory-manager` | Strong — bilingual triggers (Swedish/English), covers remember/forget/review/defaults | Yes | N/A (write protocol is verification) | Yes — routes to /improve-skill, project CLAUDE.md | New skill |

## Validation Results
- All 15 skill directories have SKILL.md with YAML frontmatter and description field
- All 28 reference files exist and are accessible
- All 3 JSON config files (hooks.json, plugin.json, .mcp.json) are valid
- All 3 agent files have required frontmatter (name, description, tools, skills)
- CLAUDE.md is 54 lines (under 80 limit), covers both stacks + memory routing
- Hook script check-dept44-patterns.sh exists and is executable
- No orphan files detected

## Remaining Gaps
- **E2E/Cypress testing**: No skill for end-to-end browser testing (frontend-testing covers unit/component only)
- **CI/CD patterns**: No skill for pipeline configuration or deployment patterns
- **Database migration patterns**: Flyway conventions are covered in scaffold templates but not as a standalone skill
