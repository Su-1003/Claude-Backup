---
name: vault-resume
description: "Load project context from the local backup vault to resume work seamlessly. Use this skill whenever starting a new session on any project, when the user says 'pick up where I left off', 'resume', 'continue', 'what was I working on', or references any project by name. Also use when the user asks about past sessions, previous work, project history, or needs to recall what was done before. This skill is essential after account switches or fresh logins — it makes any session self-sufficient by reading from the local backup vault instead of relying on session memory."
---

You have access to a comprehensive local backup vault of all Claude work. The vault lives at `~/Documents/ClaudeVault/`. This is the user's continuity system — it exists so they can pick up exactly where they left off regardless of which account or session they're in.

## When to use this skill

- The user starts a new session and wants to resume a project
- The user asks "what was I working on?" or "what's the status of X?"
- The user references a project by name
- The user says "continue", "resume", "pick up where I left off"
- The user asks about past decisions, architecture choices, or history
- You need context about what has been done before on any project

## How the vault is structured

```
ClaudeVault/
├── _index.md                    <- START HERE. Master index with all projects and Quick Resume summaries
├── _backup-log.md               <- Log of when backups ran
├── _global/
│   ├── CLAUDE.md                <- User's global coding conventions (IMPORTANT: follow these)
│   ├── settings-snapshot.md     <- Claude Code settings, hooks, preferences
│   ├── hooks-config.md          <- Hook configurations
│   └── plugins.md               <- Installed plugins and versions
├── projects/
│   ├── <project-name>/
│   │   ├── _project-summary.md  <- Project overview, tech stack, current status, QUICK RESUME
│   │   ├── plans/               <- Detailed implementation plans (the real gold -- read these)
│   │   ├── sessions/            <- Session metadata (when, how long, from Code vs Desktop)
│   │   ├── history.md           <- Every prompt the user sent, chronologically
│   │   └── file-history/        <- Snapshots of files Claude edited (versioned)
│   └── _unmatched/              <- Plans not tied to a specific project
├── cowork/
│   ├── _cowork-index.md         <- Index of all Cowork sessions
│   └── <session-id>/
│       ├── transcript.md        <- Full conversation transcript
│       └── files/               <- Files created during the session
└── shell-snapshots/             <- Terminal environment snapshots
```

## Step-by-step: How to load context

### 1. Read the master index first
Always start by reading `_index.md`. It has:
- A summary of every project with its latest activity date
- Quick Resume blurbs telling you what was last worked on per project
- Links to detailed project summaries

### 2. For a specific project, read in this order:
1. `projects/<name>/_project-summary.md` — overview, tech stack, current status, and the Quick Resume section with last prompts, decisions, and suggested next steps
2. `projects/<name>/history.md` — the user's actual prompts, most recent at the bottom. This tells you exactly what they were doing and thinking
3. The most recent plan files in `projects/<name>/plans/` — these contain detailed implementation plans, architecture decisions, and current progress

### 3. For general "what was I doing?" questions:
Read `_index.md` and summarize the Quick Resume sections across all active projects.

### 4. For Cowork session context:
Read `cowork/_cowork-index.md` to find relevant sessions, then read the transcript.

### 5. Always respect the user's conventions:
Read `_global/CLAUDE.md` and follow the coding conventions defined there. These are the user's preferences for code style, git behavior, response format, etc.

## Important behavior notes

- The vault is updated every 6 hours by a scheduled task. The `_backup-log.md` file tells you when the last backup ran.
- When resuming a project, proactively share what you found: "Based on your vault, here's where things stand with [project]..." — don't make the user ask for details.
- If the vault doesn't exist yet or is empty, tell the user: "Your backup vault hasn't been populated yet. You can trigger it from the scheduled task in the sidebar."
- The plan files are the most valuable artifacts — they contain architecture decisions, tech stack details, implementation strategies, and progress markers. Treat them as the source of truth for project state.
- The history.md files show the user's actual prompts. The last few entries tell you exactly what they were working on and what problems they were solving.
- File history shows what files were actually modified, with versioned snapshots. Use these to understand the codebase state.
