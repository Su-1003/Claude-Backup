---
name: vault-search
description: "Search across all backed-up Claude work — plans, transcripts, history, project summaries — to find past decisions, context, or code. Use when the user says 'search my vault for X', 'find where I decided X', 'did I ever work on Y', 'what did I decide about X', 'find the plan where I...', or needs to recall something specific from past sessions."
---

You can search the entire backup vault at `~/Documents/ClaudeVault/` to find past decisions, architecture choices, prompts, or any content from previous sessions.

## How to search the vault

### 1. Determine the search scope

If the user is in a Claude Code session with a known `cwd` that matches a project in the vault, search that project's directory first before expanding to the full vault.

### 2. Search in priority order

Use Grep with the user's query across these locations, in order:

1. `~/Documents/ClaudeVault/projects/*/plans/*.md` — highest signal, contains architectural decisions and implementation strategies
2. `~/Documents/ClaudeVault/projects/*/_project-summary.md` — quick project context and status
3. `~/Documents/ClaudeVault/projects/*/history.md` — the user's exact prompts
4. `~/Documents/ClaudeVault/projects/*/transcripts/*.md` — full conversation context
5. `~/Documents/ClaudeVault/cowork/*/transcript.md` — Cowork session transcripts

### 3. Present grouped results

For each match, show:

- **Project**: name of the project
- **Source**: file type (plan / summary / history / transcript)
- **File**: relative path within the vault
- **Context**: 3 lines surrounding the match

Group all results by project. Example output:

**my-web-app** — 3 matches

- `plans/initial-architecture.md` (Architecture): "...decided to use PostgreSQL over SQLite because..."
- `history.md` (Prompt): "...migrate the database schema to support..."
- `transcripts/abc123.md` (Transcript): "...the migration will need to handle existing rows..."

### 4. Handle large result sets

If there are more than 20 matches:

- Summarize the pattern ("Found 35 matches across 4 projects — most are in plans/")
- Show the top 5 most relevant hits (prefer plans and summaries over transcripts)
- Offer to drill into a specific project or file type

### 5. Handle concept searches

If the user's query is a concept rather than an exact string (e.g., "authentication approach", "database choice"), search for related terms and synonyms. For example, "auth" → also search "login", "session", "token", "JWT", "OAuth".

## What to do with results

After presenting results, offer to:

- Open a specific plan file and summarize it in full
- Load that project's full context for resuming work
- Search for a related term if results are thin
