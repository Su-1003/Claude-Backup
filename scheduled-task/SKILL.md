---
name: session-backup
description: Back up all Claude Code sessions, plans, history, Cowork transcripts, working files, and config into a structured markdown vault organized by project.
---

You are running the Session Backup Workflow. Your job is to create a comprehensive, self-contained backup of ALL Claude work (Code, Cowork, and Chat) into a structured markdown vault so the user can pick up where they left off from any account.

## BACKUP DESTINATION

Create/update the backup vault at: `~/Documents/ClaudeVault/`

The vault structure should be:
```
ClaudeVault/
├── _index.md                    (master index of all projects and latest activity)
├── _backup-log.md               (append-only log of every backup run)
├── _global/
│   ├── CLAUDE.md                (copy of global ~/.claude/CLAUDE.md)
│   ├── settings-snapshot.md     (human-readable dump of settings.json)
│   ├── hooks-config.md          (human-readable dump of hooks config)
│   └── plugins.md               (installed plugins, marketplaces, versions)
├── projects/
│   ├── <project-name>/
│   │   ├── _project-summary.md  (overview, tech stack, current status, quick resume)
│   │   ├── plans/               (all plan .md files related to this project)
│   │   ├── sessions/            (session summaries with timestamps)
│   │   ├── transcripts/         (full conversation transcripts as readable markdown)
│   │   ├── history.md           (chronological prompt history for this project)
│   │   └── file-history/        (files edited, with version diffs)
│   └── _unmatched/              (plans that don't match any known project)
├── cowork/
│   ├── _cowork-index.md         (index of all cowork sessions)
│   └── <session-id>/
│       ├── transcript.md        (full conversation transcript)
│       └── files/               (all files from the session's working directory)
└── shell-snapshots/             (zsh snapshots for environment reconstruction)
```

## STEP-BY-STEP INSTRUCTIONS

### Step 1: Discover paths

Determine the user's home directory. Use `~` expansion or `$HOME` in bash. All paths below are relative to the home directory:
- Claude Code data: `~/.claude/`
- Vault output: `~/Documents/ClaudeVault/`

If running in Cowork, request directory access:
- Request access to `~/.claude` using request_cowork_directory with path "~/.claude"
- Request access to `~/Documents` using request_cowork_directory with path "~/Documents"

Then discover the VM mount prefix by running `ls /sessions/*/mnt/` in bash. Use that prefix for all bash commands (e.g., `/sessions/<session-name>/mnt/.claude/`). Use the host paths (as reported by request_cowork_directory) for Read/Write/Edit/Glob/Grep tools.

### Step 2: Create vault directory structure
Use bash to create the full directory tree under the vault path. Create all subdirectories: `_global`, `projects`, `cowork`, `shell-snapshots`.

### Step 3: Back up global config
- Copy `~/.claude/CLAUDE.md` to `ClaudeVault/_global/CLAUDE.md`
- Read `~/.claude/settings.json` and write a human-readable markdown version to `_global/settings-snapshot.md` — include all hooks, their matchers, commands, and timeouts in a readable format
- Document hooks config separately in `_global/hooks-config.md` with explanation of what each hook does
- Read `~/.claude/plugins/installed_plugins.json` and `~/.claude/plugins/known_marketplaces.json` and write `_global/plugins.md` documenting: plugin names, versions, install dates, marketplace sources

### Step 4: Process Claude Code history and plans (PROJECT-WISE)
- Read `~/.claude/history.jsonl` — each line is JSON: `{"display": "prompt text", "project": "/absolute/path", "sessionId": "uuid", "timestamp": epoch_ms}`
- Group all entries by `project` path
- For each project:
  - Extract a clean project name from the path (last 1-2 directory components)
  - Create `projects/<project-name>/history.md` with ALL prompts listed chronologically with human-readable timestamps and session IDs
  - Read ALL plan files from `~/.claude/plans/*.md`. For each plan, read its full content and determine which project it belongs to by looking for: project paths, project names, technology mentions, or contextual clues. Copy matching plans into `projects/<project-name>/plans/<original-filename>.md`
  - Create `projects/<project-name>/_project-summary.md` with:
    - Full project path on disk
    - Number of sessions and date range
    - List of all associated plans with one-line descriptions
    - **Quick Resume section**: what was last worked on (from most recent history entries), key architectural decisions (from plans), current bugs/issues being addressed, specific file paths mentioned, and suggested next steps

### Step 5: Back up Claude Code session metadata
- Read all files in `~/.claude/sessions/*.json` — each contains: `pid`, `sessionId`, `cwd` (project path), `startedAt` (epoch ms), `kind`, `entrypoint`
- Map each session to its project via the `cwd` field
- Write session info into `projects/<project-name>/sessions/sessions.md` as a chronological list with human-readable timestamps, session IDs, and entrypoint (interactive vs desktop)

### Step 6: Back up file edit history
- Check `~/.claude/file-history/` — organized by sessionId, each file is a versioned snapshot of files edited
- For each session directory, determine the project from session metadata
- Copy file history into `projects/<project-name>/file-history/` preserving the version structure
- In the project summary, add a "Files Modified" section listing all files touched

### Step 7: Back up shell snapshots
- Copy all files from `~/.claude/shell-snapshots/` to `ClaudeVault/shell-snapshots/`
- These are zsh environment snapshots useful for reconstructing the terminal setup

### Step 8: Back up ALL conversation transcripts (Code, Cowork, and Chat)

The primary transcript store is `~/.claude/projects/`. This directory contains EVERY conversation — Claude Code sessions, Cowork sessions, and Desktop chat sessions — as JSONL files organized by project path.

**Structure of `~/.claude/projects/`:**
```
~/.claude/projects/
├── -Users-<username>-<project-path>/     (project dir, path encoded with dashes)
│   ├── <session-uuid>.jsonl              (full conversation transcript)
│   ├── <session-uuid>/
│   │   ├── subagents/                    (subagent conversation logs)
│   │   │   └── agent-<id>.jsonl
│   │   └── tool-results/                 (tool output files)
│   │       └── toolu_<id>.txt
│   └── ...more sessions
├── -Users-<username>-Library-Application-Support-Claude-local-agent-mode-sessions-<...>/ (Cowork sessions)
│   └── <session-uuid>.jsonl
└── ...more projects
```

**How to process:**
1. Use the Glob tool to list all directories under `~/.claude/projects/` — each directory name is an encoded project path
2. Decode the directory name to recover the original project path: replace leading dashes with `/`, so `-Users-<user>-WebKitchen-MyApp` becomes `/Users/<user>/WebKitchen/MyApp`
3. Directories containing `local-agent-mode-sessions` in their name are **Cowork sessions** — save these under `cowork/` in the vault
4. All other directories are **Claude Code / Desktop sessions** — save these under the matching `projects/<name>/` in the vault

**For each project directory:**
- Find all `*.jsonl` files at the root level (these are main conversation transcripts)
- Each JSONL file is one session. Each line is a JSON object representing a message. Extract the human-readable conversation by filtering for user and assistant messages.
- Convert each JSONL transcript into a readable markdown file:
  - Parse each line as JSON
  - Extract `role` (user/assistant) and message `content`
  - Skip system messages and tool-use details (keep it readable)
  - Format as a clean markdown conversation with timestamps where available
- Save as `projects/<project-name>/transcripts/<session-uuid>.md` (for Code sessions) or `cowork/<session-id>/transcript.md` (for Cowork sessions)
- Also check for `subagents/` directories and note their existence in the session metadata

**For Cowork sessions specifically:**
- Also use `list_sessions` (limit 50) to get any currently active sessions and their transcripts via `read_transcript` — this captures sessions that may not yet be flushed to disk
- Check if the Cowork session's working directory is accessible and copy any output files to `cowork/<session-id>/files/`

**Update indexes:**
- Add a transcript count to each project's `_project-summary.md`
- Update `cowork/_cowork-index.md` with all discovered Cowork sessions, their dates, and topic summaries

### Step 9: Build the master index
Create/update `_index.md` with:
- Backup timestamp (human-readable)
- **Projects section**: table of all projects with: name, path, latest activity date, number of plans, session count, one-line status
- **Quick Resume per project**: 2-3 sentence summary of where things stand plus the last prompt sent
- **Cowork Sessions section**: list of recent sessions with dates and topics
- **Global Config**: note that settings, hooks, and plugins are backed up
- Relative links to all project summaries and cowork transcripts

### Step 10: Update backup log
Append to `_backup-log.md`:
```
## Backup: [human-readable timestamp]
- Projects backed up: [count]
- Plans archived: [count]
- Conversation transcripts backed up: [count] (Code: [n], Cowork: [n])
- History entries processed: [count]
- File history entries: [count]
- Shell snapshots: [count]
- Status: SUCCESS/PARTIAL (with notes on any failures)
```

### Step 11: Handle unmatched plans
- Any plan files that don't clearly belong to a known project go in `projects/_unmatched/plans/`
- List them in the master index under "Unmatched Plans"

## IMPORTANT NOTES

- This runs every 6 hours automatically. Be INCREMENTAL — check file modification times before rewriting unchanged files. Use bash `stat` or `find -newer` to compare.
- NEVER delete or overwrite with less data. Only add or update.
- Use human-readable timestamps everywhere (e.g., "Apr 13, 2026 at 2:30 PM")
- The vault must be entirely self-contained — someone opening it fresh should understand the full state of everything
- If a step fails, log the failure in _backup-log.md and continue with remaining steps
- For the Quick Resume sections, be VERY detailed: include file paths, current bugs, architectural decisions, the exact last prompt sent, and what the likely next step would be
- When reading plan files to classify them, read the FULL content, not just the first few lines — project context may be deep in the file

## SUCCESS CRITERIA
The vault at ~/Documents/ClaudeVault/ should contain everything needed to resume ANY project from scratch on a new account. A new session reading `_index.md` should be able to understand all active work and continue seamlessly.
