---
name: vault-resume
description: "Load project context from the local backup vault to resume work seamlessly. Use this skill whenever starting a new session on any project, when the user says 'pick up where I left off', 'resume', 'continue', 'what was I working on', or references any project by name. Also use when the user asks about past sessions, previous work, project history, plans, or needs to recall what was done before. Trigger when the user says 'list plans', 'show me plans for X', 'what plans do I have', or asks about any specific plan. This skill is essential after account switches or fresh logins — it makes any session self-sufficient by reading from the local backup vault instead of relying on session memory."
---

You have access to a comprehensive local backup vault of all Claude work. The vault lives at `~/Documents/ClaudeVault/`. This is the user's continuity system — it exists so they can pick up exactly where they left off regardless of which account or session they're in.

## Scoping Rule — load only what's needed

**If the user names a specific project or plan, OR if you are in a Claude Code session and the cwd matches a project in the vault:**

- Load ONLY that project's context. Do not read `_index.md` or other projects.
- Read in this order: `_project-summary.md` → `plans/_index.md` → `history.md` (last 20 entries)
- Read full plan files only if the user asks about a specific plan or task

**If the user asks a general question ("what was I working on?", "list all projects", "what's my status?"):**

- Read `_index.md` only and summarize the Quick Resume sections
- Do not load individual project files unless the user drills into a specific project

This scoping keeps context focused. Never load all projects when a specific one is already known.

## When to use this skill

- The user starts a new session and wants to resume a project
- The user asks "what was I working on?" or "what's the status of X?"
- The user references a project by name
- The user says "continue", "resume", "pick up where I left off"
- The user asks about past decisions, architecture choices, or history
- The user asks to "list plans", "show plans", "what plans for X", or wants to read a specific plan
- You need context about what has been done before on any project

## How the vault is structured

```
ClaudeVault/
├── _index.md                    <- START HERE for general questions. Master index with all projects and Quick Resume summaries
├── _backup-log.md               <- Log of when backups ran
├── _global/
│   ├── CLAUDE.md                <- User's global coding conventions (IMPORTANT: follow these)
│   ├── settings-snapshot.md     <- Claude Code settings, hooks, preferences
│   ├── hooks-config.md          <- Hook configurations
│   └── plugins.md               <- Installed plugins and versions
├── projects/
│   ├── <project-name>/
│   │   ├── _project-summary.md  <- Project overview, tech stack, current status, QUICK RESUME
│   │   ├── plans/
│   │   │   ├── _index.md        <- PLAN INDEX: table of all plans with topic + summary
│   │   │   └── <descriptive-name>.md  <- Plans renamed from random words to descriptive titles
│   │   ├── transcripts/         <- Full conversation transcripts (every message, readable markdown)
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

### 1. Check for stale vault

Before loading any context, read `_backup-log.md` and find the most recent `SUCCESS` entry. If it was more than 24 hours ago, warn the user: "Your vault was last updated X hours ago — recent work may not be included."

### 2. For a specific project (named by user or matched by cwd):

Read only these files for that project:

1. `projects/<name>/_project-summary.md` — overview, tech stack, current status, Quick Resume
2. `projects/<name>/plans/_index.md` — table of every plan with topic and summary
3. `projects/<name>/history.md` — last 20 entries (most recent prompts at the bottom)
4. Individual plan files from `projects/<name>/plans/` — only when the user asks about a specific plan

Do not read `_index.md` or any other project's files.

### 3. For general "what was I doing?" questions:

Read `_index.md` only and summarize the Quick Resume sections across all active projects. Do not drill into individual project files unless asked.

### 4. For Cowork session context:

Read `cowork/_cowork-index.md` to find relevant sessions, then read the transcript.

### 5. Always respect the user's conventions:

Read `_global/CLAUDE.md` and follow the coding conventions defined there. These are the user's preferences for code style, git behavior, response format, etc.

## Plan listing and retrieval

Plans are the most valuable artifacts in the vault. They contain architecture decisions, tech stack details, implementation strategies, and progress markers. Each project has a `plans/_index.md` with a structured table.

### When the user asks "list plans" or "show me all plans":

1. Read `_index.md` to get all project names
2. For each project, read `projects/<name>/plans/_index.md`
3. Present a combined view grouped by project:

   **Project: my-web-app**
   | Plan | Topic | Summary |
   |------|-------|---------|
   | [Initial Architecture](plans/initial-architecture.md) | Architecture | Core data model, API design, and project structure... |
   | [Feature Implementation](plans/feature-implementation.md) | Feature build | Step-by-step plan for the main user-facing flow... |

   **Project: my-other-project**
   | Plan | Topic | Summary |
   |------|-------|---------|
   | ... | ... | ... |

### When the user asks "show plans for [project]":

1. Find the matching project directory in the vault
2. Read `projects/<name>/plans/_index.md`
3. Present the table, and offer to open any specific plan

### When the user asks about a specific plan or topic:

1. Search the plan indexes across projects for matching topic/keywords
2. Read the full plan file
3. Summarize the key points: goal, approach, tech decisions, current status, what's left to do

### When the user asks to "resume [plan name]":

1. Find and read the full plan file
2. Cross-reference with `history.md` to see the last prompts related to this plan
3. Present a concise "here's where you left off" summary: what was done, what's pending, last decisions made, and suggested next action

## Important behavior notes

- The vault is updated every 6 hours by a scheduled task. The `_backup-log.md` file tells you when the last backup ran.
- When resuming a project, proactively share what you found: "Based on your vault, here's where things stand with [project]..." — don't make the user ask for details.
- If the vault doesn't exist yet or is empty, tell the user: "Your backup vault hasn't been populated yet. You can trigger it from the scheduled task in the sidebar."
- Plan files have been renamed from random codenames (e.g. `gleaming-splashing-feather.md`) to descriptive titles (e.g. `feature-implementation-plan.md`). Always use the descriptive names when referring to plans.
- The history.md files show the user's actual prompts. The last few entries tell you exactly what they were working on and what problems they were solving.
- File history shows what files were actually modified, with versioned snapshots. Use these to understand the codebase state.
