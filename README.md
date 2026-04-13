# Claude-Backup

Never lose your Claude context again. Back up every session, plan, and conversation automatically — resume any project from any account in seconds.

## The Problem

Claude accounts log you out. Sessions expire. Context disappears. You're left scrambling to remember what you were working on, what decisions were made, and where you left off.

## The Solution

**vault-resume** is two things:

1. **A scheduled backup** that runs every 6 hours, archiving all your Claude Code sessions, Cowork transcripts, implementation plans, prompt history, file edits, and config into a structured local vault (`~/Documents/ClaudeVault/`)

2. **A resume skill** that any new Claude session can use to read the vault and pick up exactly where you left off — regardless of which account you're on

## Install (10 seconds)

```bash
git clone https://github.com/abhinav-adtechs/Claude-Backup.git
cd Claude-Backup
chmod +x install.sh
./install.sh
```

Or specify a custom vault location:

```bash
./install.sh ~/Dropbox/ClaudeVault    # back up to Dropbox
./install.sh /Volumes/USB/ClaudeVault  # back up to external drive
```

Then open Cowork, go to **Scheduled** in the sidebar, and hit **Run now** on `session-backup`.

That's it. Your first backup will populate the vault. Future backups run every 6 hours automatically.

## What Gets Backed Up

| Data | Source | Location in Vault |
|------|--------|-------------------|
| Implementation plans | `~/.claude/plans/` | `projects/<name>/plans/` |
| Prompt history | `~/.claude/history.jsonl` | `projects/<name>/history.md` |
| Session metadata | `~/.claude/sessions/` | `projects/<name>/sessions/` |
| File edit history | `~/.claude/file-history/` | `projects/<name>/file-history/` |
| Global config | `~/.claude/CLAUDE.md` | `_global/CLAUDE.md` |
| Settings and hooks | `~/.claude/settings.json` | `_global/settings-snapshot.md` |
| Installed plugins | `~/.claude/plugins/` | `_global/plugins.md` |
| Cowork transcripts | Cowork session API | `cowork/<id>/transcript.md` |
| Cowork output files | Cowork working dirs | `cowork/<id>/files/` |
| Shell environment | `~/.claude/shell-snapshots/` | `shell-snapshots/` |

Everything is organized **by project** with auto-generated summaries and a master index.

## How to Resume

In any new Claude session (Code, Cowork, or Chat), just say:

- "Pick up where I left off"
- "What was I working on?"
- "Resume [project name]"
- "What's the status of my projects?"

The **vault-resume** skill kicks in, reads your vault, and gives you full context — last prompts sent, architectural decisions, current bugs, and suggested next steps.

## Vault Structure

```
~/Documents/ClaudeVault/
├── _index.md              # Start here — master index with Quick Resume per project
├── _backup-log.md         # When backups ran
├── _global/               # Your Claude config, hooks, plugins
├── projects/
│   ├── my-web-app/
│   │   ├── _project-summary.md   # Overview + Quick Resume
│   │   ├── plans/                # Implementation plans
│   │   ├── sessions/             # Session metadata
│   │   ├── history.md            # Every prompt you sent
│   │   └── file-history/         # Files Claude edited
│   └── _unmatched/               # Plans not tied to a project
├── cowork/
│   ├── _cowork-index.md
│   └── <session-id>/
│       ├── transcript.md         # Full conversation
│       └── files/                # Files from the session
└── shell-snapshots/              # Terminal environment
```

## Manual Backup

Don't want to wait 6 hours? Trigger a backup anytime:

1. Open Cowork
2. Go to **Scheduled** in the sidebar
3. Click **Run now** on `session-backup`

## Customization

### Change backup frequency

Edit the cron expression in the scheduled task. Default is `0 */6 * * *` (every 6 hours). Some alternatives:

- Every hour: `0 * * * *`
- Every 12 hours: `0 */12 * * *`
- Once daily at midnight: `0 0 * * *`

### Change vault location

Reinstall with a custom path:

```bash
./install.sh /path/to/your/vault
```

This updates both the scheduled task and the resume skill automatically. Works great with Dropbox, iCloud Drive, or an external drive for extra redundancy.

## How It Works

The backup task runs as a Cowork scheduled task. Each run:

1. Reads all Claude Code data from `~/.claude/`
2. Groups everything by project (using paths from history and session metadata)
3. Classifies plan files by reading their content and matching to projects
4. Captures Cowork session transcripts and output files via the session API
5. Generates per-project summaries with "Quick Resume" sections
6. Builds a master index linking everything together
7. Logs the run to `_backup-log.md`

The resume skill teaches Claude how to navigate the vault structure — which files to read first, how to present context, and how to respect your coding conventions.

## Requirements

- Claude Desktop with Cowork mode
- Claude Code (for Code session backups)
- macOS (paths use `~/Documents/` — adapt for Linux/Windows)

## License

MIT
