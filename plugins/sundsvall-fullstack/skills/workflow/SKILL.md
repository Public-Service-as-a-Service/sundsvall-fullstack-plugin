---
description: Manage the Jira+GitHub workflow — pick up a ticket, create a branch, make a PR, link PR to Jira, and transition status. Use when the user wants to start working on a Jira ticket, create a PR for a ticket, or link a PR to Jira.
---

# Workflow: Jira + GitHub

Handles the full development workflow between Jira and GitHub.

## Safety rules — READ THESE FIRST

Before ANY write operation to Jira, you MUST:

1. **Identify the current user.** Call `get_user_profile` with the user's email or username. If you don't know it yet, ask the user. Cache this for the session.
2. **Check assignee.** Call `jira_get_issue` and verify `assignee` matches the current user. Exception: if the user is explicitly asking to pick up / assign the ticket to themselves.
3. **Never modify someone else's ticket.** If the assignee is someone else, tell the user and stop. Do NOT proceed even if the user insists — ask them to reassign in Jira first.
4. **Confirm before writing.** Always tell the user what you're about to do and wait for confirmation before calling any write tool.

## Available write tools

| Tool | Use for | Safety check |
|------|---------|-------------|
| `transition_issue` | Change status (e.g. → In Progress) | Must be assignee |
| `update_issue` | Assign to self | Only for assignee field |
| `add_comment` | Add PR link or notes | Must be assignee |
| `edit_comment` | Edit an existing comment | Must be assignee |
| `create_remote_issue_link` | Link a PR/URL to the ticket | Must be assignee |

## Workflows

### 1. Pick up a ticket

When the user says "pick up DRAKEN-1234" or "jag tar DRAKEN-1234":

```
Step 1: jira_get_issue("DRAKEN-1234")
        → Check current status and assignee
        → If assigned to someone else: STOP and inform user

Step 2: get_user_profile("<user-email>")
        → Get the user's Jira username/key

Step 3: Confirm with user:
        "Jag tilldelar DRAKEN-1234 till dig och sätter status In Progress. OK?"

Step 4: update_issue("DRAKEN-1234", fields={"assignee": {"name": "<username>"}})

Step 5: get_transitions("DRAKEN-1234")
        → Find the transition ID for "In Progress"

Step 6: transition_issue("DRAKEN-1234", transition_id="<id>")

Step 7: Create branch:
        git checkout -b feature/draken-1234-<short-description>
```

### 2. Create PR and link to Jira

When the user says "skapa PR", "create PR", or commits/pushes code on a feature branch.
**All steps below are mandatory and should happen automatically without being asked.**

```
Step 1: Parse the Jira ticket key from the branch name (e.g. feature/draken-1234-...)
        → If no ticket key found, ask the user

Step 2: jira_get_issue("DRAKEN-1234")
        → Verify assignee is current user
        → Get ticket summary for PR title/body

Step 3: Create the PR via gh:
        gh pr create --title "DRAKEN-1234: <summary>" --body "..."
        → Include Jira link in PR body (see PR body template below)

Step 4: add_comment("DRAKEN-1234", body="PR: <github-pr-url>")

Step 5: create_remote_issue_link("DRAKEN-1234",
          url="<github-pr-url>",
          title="PR: <pr-title>",
          summary="Pull request on GitHub")

Step 6: get_transitions("DRAKEN-1234")
        → Find the transition ID for "In Review"

Step 7: transition_issue("DRAKEN-1234", transition_id="<id>")
```

**This bidirectional linking (Jira→PR and PR→Jira) plus transition to In Review is the standard workflow and must always be followed.**

### 3. PR merged — close ticket

When the user says "PR mergad" or wants to close a ticket after merge:

```
Step 1: jira_get_issue("DRAKEN-1234")
        → Verify assignee is current user

Step 2: get_transitions("DRAKEN-1234")
        → Find transition for "Done" / "Ready for Production" / "Testing"

Step 3: Confirm with user:
        "Vilken status? Done / Testing / Ready for Production?"

Step 4: transition_issue("DRAKEN-1234", transition_id="<id>")
```

## Branch naming convention

Use the pattern: `feature/draken-<number>-<short-kebab-description>`

Examples:
- `feature/draken-1234-add-labels`
- `bugfix/draken-5678-fix-ssl-error`

## PR body template

```markdown
## Summary
<1-3 bullet points from Jira ticket>

## Test plan
- [ ] <from acceptance criteria>

https://jira.sundsvall.se/browse/DRAKEN-1234
```

**Important rules for PR body:**
- Jira links go at the **bottom** as plain URLs (not in a separate section)
- When editing an existing PR body, **always preserve all existing content** — never remove existing Jira links or other content
- **Never** include AI attribution (e.g. "Generated with Claude Code", "Co-Authored-By: Claude") in PR body, commits, or code

## Improvement Log
<!-- Append entries when this skill causes errors or misses edge cases -->
<!-- Format: YYYY-MM-DD: <what went wrong, what to do differently> -->
