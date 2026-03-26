---
description: Search and read Jira issues and Confluence pages at Sundsvallskommun. Use when you need ticket details, project context, or internal documentation.
---

# Atlassian Integration

Access to Jira and Confluence at Sundsvallskommun via mcp-atlassian.

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

## Improvement Log
<!-- Append entries when this skill causes errors or misses edge cases -->
<!-- Format: YYYY-MM-DD: <what went wrong, what to do differently> -->
