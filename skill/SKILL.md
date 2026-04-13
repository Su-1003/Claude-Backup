---
name: vault-resume
description: "Load project context from the local backup vault to resume work seamlessly. Use this skill whenever starting a new session on any project, when the user says 'pick up where I left off', 'resume', 'continue', 'what was I working on', or references any project by name. Also use when the user asks about past sessions, previous work, project history, plans, or needs to recall what was done before. Trigger when the user says 'list plans', 'show me plans for X', 'what plans do I have', or asks about any specific plan. This skill is essential after account switches or fresh logins — it makes any session self-sufficient by reading from the local backup vault instead of relying on session memory."
---

You have access to a comprehensive local backup vault of all Claude work. The vault lives at `~/Documents/ClaudeVault/`. This is the user's continuity system — it exists so they can pick up exactly where they left off regardless of which account or session they're in.

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

### 1. Read the master index first
Always start by reading `_index.md`. It has:
- A summary of every project with its latest activity date
- Quick Resume blurbs telling you what was last worked on per project
- Links to detailed project summaries

### 2. For a specific project, read in this order:
1. `projects/<name>/_project-summary.md` — overview, tech stack, current status, and the Quick Resume section with last prompts, decisions, and suggested next steps
2. `projects/<name>/plans/_index.md` — the plan index: a table of every plan with its topic and a 1-2 sentence summary. Read this to understand what work has been planned and done.
3. `projects/<name>/history.md` — the user's actual prompts, most recent at the bottom. This tells you exactly what they were doing and thinking
4. Read specific plan files from `projects/<name>/plans/` as needed — these contain detailed implementation plans, architecture decisions, and current progress
5. `projects/<name>/transcripts/` — full conversation transcripts from every session. Read the most recent one(s) to understand the exact flow of the last session including tool calls and decisions made

### 3. For general "what was I doing?" questions:
Read `_index.md` and summarize the Quick Resume sections across all active projects.

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

   **Project: Circle-Up DRHP**
   | Plan | Topic | Summary |
   |------|-------|---------|
   | [Verification Platform Development](plans/circle-up-verification-platform-development-plan.md) | Architecture | 4-panel synchronized React app for DRHP financial verification... |
   | [Playground Page Implementation](plans/playground-page-implementation.md) | Feature build | DevTools drawer with section extraction controls... |

   **Project: FIFA League Tracker**
   | Plan | Topic | Summary |
   |------|-------|---------|
   | ...  | ...   | ...     |

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
3. Check `transcripts/` for the most recent session that worked on this plan
4. Present a comprehensive "here's where you left off" summary: what was done, what's pending, last decisions made, and suggested next action

## Important behavior notes

- The vault is updated every 6 hours by a scheduled task. The `_backup-log.md` file tells you when the last backup ran.
- When resuming a project, proactively share what you found: "Based on your vault, here's where things stand with [project]..." — don't make the user ask for details.
- If the vault doesn't exist yet or is empty, tell the user: "Your backup vault hasn't been populated yet. You can trigger it from the scheduled task in the sidebar."
- Plan files have been renamed from random codenames (like `gleaming-splashing-feather.md`) to descriptive titles (like `circle-up-verification-platform-development-plan.md`). Always use the descriptive names when referring to plans.
- The history.md files show the user's actual prompts. The last few entries tell you exactly what they were working on and what problems they were solving.
- File history shows what files were actually modified, with versioned snapshots. Use these to understand the codebase state.
