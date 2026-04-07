---
description: Search and read Jira issues and Confluence pages at Sundsvallskommun. Use when you need ticket details, project context, or internal documentation. Also covers the one-time setup required to enable the mcp-atlassian server.
---

# Atlassian Integration

Access to Jira and Confluence at Sundsvallskommun via mcp-atlassian.

## Setup — the MCP server is opt-in

To keep the default session lean, this plugin does **not** auto-load the Atlassian MCP server. Enable it once per machine (or per project) with the steps below. You only need this if you plan to read or write Jira/Confluence from Claude Code.

### Prerequisites
- `uvx` installed (`pipx install uv` or `brew install uv`)
- A Jira/Confluence personal access token
- Network access to `jira.sundsvall.se` / `confluence.sundsvall.se` (internal network or VPN)

### 1. Set credentials

Export these in your shell rc file (`~/.zshrc` or `~/.bashrc`):

```bash
export JIRA_PERSONAL_TOKEN="..."
export CONFLUENCE_PERSONAL_TOKEN="..."
```

### 2. Register the MCP server

Pick **one** of these two options:

**Option A — project scope (recommended, only loads in repos where you work tickets):**
```bash
cp "$(find ~/.claude/plugins -name mcp-atlassian.template.json | head -1)" ./.mcp.json
```
Run this in each Sundsvall repo where you expect to use Jira from Claude Code. Other projects stay lean and pay zero MCP token cost. Commit (or `.gitignore`) the `.mcp.json` according to team policy.

**Option B — user scope (for devs who work Jira every session, in every project):**
```bash
claude mcp add-json --scope user mcp-atlassian "$(cat "$CLAUDE_PLUGIN_ROOT/mcp-atlassian.template.json" | jq '.mcpServers["mcp-atlassian"]')"
```

If `$CLAUDE_PLUGIN_ROOT` is not set (you're outside a hook), locate the template with:
```bash
find ~/.claude/plugins -name mcp-atlassian.template.json
```

User-scope loads the MCP in every Claude Code session regardless of project, which is convenient but costs ~4–6K tokens per turn always. Only pick this if your work is predominantly ticket-driven.

### 3. Verify

In a new Claude Code session, run `/mcp` and confirm `mcp-atlassian` is listed as connected. If the tools below are still missing, check your token, VPN, and `uvx` installation.

### Disabling again

- User scope: `claude mcp remove --scope user mcp-atlassian`
- Project scope: delete the `.mcp.json` in the repo root.

## Available read tools

### Jira

| Tool | What it does | Example |
|------|-------------|---------|
| `jira_search` | Search issues with JQL | `jira_search("project = DRAKEN AND status = 'In Progress'")` |
| `jira_get_issue` | Get full issue details | `jira_get_issue("DRAKEN-1234")` |
| `jira_get_issue_comments` | Read comments on an issue | `jira_get_issue_comments("DRAKEN-1234")` |
| `jira_get_transitions` | Get available status transitions | `jira_get_transitions("DRAKEN-1234")` |
| `get_user_profile` | Get user info | `get_user_profile("user@sundsvall.se")` |

### Confluence

| Tool | What it does | Example |
|------|-------------|---------|
| `confluence_search` | Search pages with CQL | `confluence_search("text ~ 'authentication flow'")` |
| `confluence_get_page` | Get full page content | `confluence_get_page(page_id)` |

## Available write tools

See `/workflow` for the full Jira+GitHub workflow skill.

| Tool | What it does | Safety |
|------|-------------|--------|
| `transition_issue` | Change issue status | Must be assignee |
| `update_issue` | Update issue fields (assignee) | Must be assignee or assigning self |
| `add_comment` | Add a comment | Must be assignee |
| `edit_comment` | Edit an existing comment | Must be assignee |
| `create_remote_issue_link` | Add a web link (e.g. PR) | Must be assignee |

**Before any write:** always verify assignee with `jira_get_issue` first.

## Common JQL queries

```
# All open issues in a project
project = DRAKEN AND status != Done

# Issues assigned to current user
project = DRAKEN AND assignee = currentUser()

# Recently updated
project = DRAKEN AND updated >= -7d ORDER BY updated DESC

# By type
project = DRAKEN AND issuetype = Bug AND status = Open

# Text search
project = DRAKEN AND text ~ "search term"
```

## Common CQL queries

```
# Search by text
text ~ "authentication"

# In a specific space
space = "DEV" AND text ~ "deployment"

# Recently modified
lastModified >= "2026-01-01" AND text ~ "architecture"
```

## Workflow

### When user references a ticket

1. Call `jira_get_issue` to read the full description and acceptance criteria
2. Use that context to guide your implementation
3. Reference the ticket details in your response

### When starting a new task

1. Call `jira_search` to find related tickets and understand the broader context
2. Check if there are existing tickets with similar work or known issues
3. Use the context to avoid duplicate work or known pitfalls

### When you need documentation

1. Call `confluence_search` with relevant keywords
2. Read the most relevant pages for context
3. Use internal documentation over assumptions
