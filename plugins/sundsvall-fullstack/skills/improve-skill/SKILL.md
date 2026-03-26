---
description: "Review accumulated skill improvement entries and propose concrete edits to plugin skills. Use when you want to improve the sundsvall-fullstack plugin based on real-world usage, review what went wrong in past sessions, promote improvement entries into skill updates, or manually log a skill issue you noticed. Also use when asked to maintain or improve the plugin's quality."
---

# Skill Improvement Manager

Review, classify, and promote accumulated improvement entries into concrete skill edits.

## How It Works

Developers log objectively wrong skill guidance to `~/.claude/sundsvall-improvements.jsonl` during normal work. This skill reviews those entries, classifies them, and proposes targeted SKILL.md edits.

## Step 0: Status and Validation (always runs first)

1. Read `~/.claude/sundsvall-improvements.jsonl`. Create `~/.claude/` if missing.
2. Show a status summary: "3 pending entries across 2 skills (dept44-scaffold, frontend-app)" — or "No pending entries."
3. Validate the file before proceeding:
   - **Malformed JSON lines**: skip them, report which lines were dropped, ask user for confirmation before rewriting the file without them.
   - **Unknown skill names** (not matching any `skills/*/` directory): warn and ask the reviewer to map to a renamed skill, discard, or leave unprocessed.
   - **Exact duplicates** (same `skill` + same `summary` after lowercasing and trimming): merge into one entry, keep the earliest date.
4. If entries exist after cleanup, offer Mode 1 (review). If empty or missing, offer Mode 2 (manual intake).

## Mode 1: Review and Promote

Run this mode from the `sundsvall-fullstack-plugin` repo so SKILL.md edits can be committed directly. If invoked outside the plugin repo, say: "I can log manually from here, but review/promote requires the sundsvall-fullstack-plugin repo."

1. **Semantically group** similar entries by skill — entries about the same underlying issue but worded differently. This is deeper than Step 0's exact-duplicate cleanup.
2. **Present each group** to the user for classification:
   - **Skill bug** — wrong pattern, wrong API, wrong import, missing mandatory convention
   - **Project-specific** — this repo does it differently, not a plugin-wide issue
   - **Noise** — model mistake, not a skill issue
3. **Propose concrete edits** for skill bugs:
   - Show the current SKILL.md snippet that needs changing
   - Show the proposed edit
   - Factual errors (wrong API, wrong import): propose fix on 1 entry
   - Subjective improvements (wording, emphasis): suggest only if 2+ similar entries
   - For repeated gaps across multiple entries pointing to uncovered territory, suggest "Consider creating a new skill for X" — do not auto-create
4. **Ask user** "Apply this change?" per edit. If rejected, ask: "Keep for later review, or discard?"
5. **Compact the JSONL**: write remaining unprocessed entries to a temp file, then atomically rename to `~/.claude/sundsvall-improvements.jsonl`. Promoted, discarded, and noise entries are removed. If an unknown skill was mapped to a renamed one, rewrite to the canonical name.
6. **Show session summary**: "Reviewed 4 entries: 2 promoted, 1 discarded, 1 left for later." Include malformed line handling if applicable.

## Mode 2: Manual Intake

Log a skill issue the agent didn't catch during normal work. Works from any project — only writes to `~/.claude/sundsvall-improvements.jsonl`.

1. Ask for the skill name. If it doesn't match any installed skill, show the list of valid names and ask the user to pick one.
2. Ask what went wrong (the `summary`).
3. Ask for evidence — what the correct approach is. This field is **optional** — don't block logging because the developer only knows "this skill missed X."
4. Append a structured entry using atomic write (temp file + rename). Create `~/.claude/` if missing with normal user-only permissions.
5. Show confirmation: "Logged 1 issue for dept44-scaffold."

## JSONL Entry Schema

```jsonl
{"skill": "dept44-patterns", "date": "2026-03-26", "summary": "Suggested @Autowired for dependency injection", "evidence": "dept44 requires constructor injection with final fields — @Autowired is never used"}
{"skill": "frontend-app", "date": "2026-03-27", "summary": "Missing guidance on dynamic routes with [slug]", "evidence": "App Router supports [slug]/page.tsx for dynamic segments, skill only covers [locale]"}
```

Fields:
- `skill` — which skill gave wrong guidance (must match a `skills/*/` directory name)
- `date` — when the issue occurred (YYYY-MM-DD)
- `summary` — what went wrong (concise)
- `evidence` — what the correct approach is (optional for manual intake)

No `type` field at write time — classification happens during review (Mode 1).

## When NOT to Use

- Do NOT use for subjective wording preferences — only objective errors (wrong API, wrong import, wrong pattern).
- Do NOT use for project-specific exceptions — those belong in the project's own CLAUDE.md, not the shared plugin.
- Do NOT use to create new skills automatically — suggest new skills during review, but let the developer create them.

## Per-Session Behavior

When the CLAUDE.md rule triggers during normal work, ask only once per unique issue per session. Uniqueness = normalized `skill + summary` (lowercased, trimmed). If the same issue comes up again in the same session, skip the prompt.
