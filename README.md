# Claude-Backup

Never lose your Claude context again. Back up every session, plan, and conversation automatically — resume any project from any account in seconds.

## The Problem

Claude accounts log you out. Sessions expire. Context disappears. You're left scrambling to remember what you were working on, what decisions were made, and where you left off.

## The Solution

**vault-resume** is two things:

1. **A scheduled backup** that runs every 6 hours, archiving all your Claude Code sessions, Cowork transcripts, implementation plans, prompt history, file edits, and config into a structured local vault (`~/Documents/ClaudeVault/`)

2. **A resume skill** that any new Claude session can use to read the vault and pick up exactly where you left off — regardless of which account you're on

## Install (10 seconds)

**macOS / Linux:**

```bash
git clone https://github.com/abhinav-adtechs/Claude-Backup.git
cd Claude-Backup
chmod +x install.sh
./install.sh
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/abhinav-adtechs/Claude-Backup.git
cd Claude-Backup
.\install.ps1
```

Or specify a custom vault location:

```bash
# macOS / Linux
./install.sh ~/Dropbox/ClaudeVault

# Windows
.\install.ps1 -VaultPath "C:\Users\you\Dropbox\ClaudeVault"
```

Then open Cowork, go to **Scheduled** in the sidebar, and hit **Run now** on `session-backup`.

That's it. Your first backup will populate the vault. Future backups run every 6 hours automatically.

## What Gets Backed Up

| Data                          | Source                              | Location in Vault               |
| ----------------------------- | ----------------------------------- | ------------------------------- |
| Full conversation transcripts | `~/.claude/projects/`               | `projects/<name>/transcripts/`  |
| Implementation plans          | `~/.claude/plans/`                  | `projects/<name>/plans/`        |
| Prompt history                | `~/.claude/history.jsonl`           | `projects/<name>/history.md`    |
| Session metadata              | `~/.claude/sessions/`               | `projects/<name>/sessions/`     |
| File edit history             | `~/.claude/file-history/`           | `projects/<name>/file-history/` |
| Global config                 | `~/.claude/CLAUDE.md`               | `_global/CLAUDE.md`             |
| Settings and hooks            | `~/.claude/settings.json`           | `_global/settings-snapshot.md`  |
| Installed plugins             | `~/.claude/plugins/`                | `_global/plugins.md`            |
| Cowork transcripts            | `~/.claude/projects/` + session API | `cowork/<id>/transcript.md`     |
| Cowork output files           | Cowork working dirs                 | `cowork/<id>/files/`            |
| Shell environment             | `~/.claude/shell-snapshots/`        | `shell-snapshots/`              |

Everything is organized **by project** with auto-generated summaries and a master index.

## How to Resume

In any new Claude session (Code, Cowork, or Chat), just say:

- "Pick up where I left off"
- "What was I working on?"
- "Resume [project name]"
- "What's the status of my projects?"

The **vault-resume** skill kicks in, reads your vault, and gives you full context — last prompts sent, architectural decisions, current bugs, and suggested next steps.

When you name a specific project, only that project's context is loaded. When you ask generally ("what was I working on?"), you get a summary across all projects.

## Additional Skills

Beyond the core resume workflow, two optional skills extend vault capabilities:

### vault-search

Find anything in your vault — past decisions, code snippets, architecture choices — across all projects at once.

Usage: "search my vault for [keyword]", "find where I decided X", "did I ever work on Y"

### vault-verify

Audit your vault health — check the last backup time, verify all projects are complete, and detect any issues.

Usage: "check my vault", "verify backup", "is my backup up to date"

## Vault Structure

```
~/Documents/ClaudeVault/
├── _index.md              # Master index with Quick Resume per project
├── _backup-log.md         # When backups ran
├── _global/               # Your Claude config, hooks, plugins
├── projects/
│   ├── my-web-app/
│   │   ├── _project-summary.md   # Overview + Quick Resume
│   │   ├── plans/                # Implementation plans (renamed to descriptive titles)
│   │   │   ├── _index.md         # Table of all plans with topics and summaries
│   │   │   └── *.md              # Individual plan files
│   │   ├── transcripts/          # Full conversation transcripts
│   │   ├── sessions/             # Session metadata
│   │   ├── history.md            # Every prompt you sent
│   │   └── file-history/         # Files Claude edited
│   └── _unmatched/               # Plans not tied to a project
├── cowork/
│   ├── _cowork-index.md
│   └── <session-id>/
│       ├── transcript.md
│       └── files/
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
# macOS / Linux
./install.sh /path/to/your/vault

# Windows
.\install.ps1 -VaultPath "C:\path\to\your\vault"
```

Works great with Dropbox, iCloud Drive, or an external drive for redundancy.

### Other install commands

```bash
# macOS / Linux
./install.sh --check        # verify installation
./install.sh --uninstall    # remove installed files

# Windows
.\install.ps1 -Check
.\install.ps1 -Uninstall
```

## Security

The vault contains your full conversation history, which may include API keys, passwords, or proprietary code shared during sessions.

**The install script automatically creates a `.gitignore`** in your vault directory that excludes sensitive content (transcripts, file history, shell snapshots) if you sync the vault to a git repo or cloud service. Plans, summaries, and history are considered safe to sync.

If you sync to a cloud service:

- Do not sync to a **public** repository
- Review `vault-gitignore.template` to understand what's excluded
- Consider using an encrypted vault location (e.g., a macOS encrypted disk image, or a VeraCrypt volume on Windows/Linux)

## How It Works

The backup task runs as a Cowork scheduled task. Each run:

1. Reads all Claude Code data from `~/.claude/`
2. Builds a project path map from `history.jsonl` to accurately decode encoded directory names
3. Groups everything by project and converts JSONL transcripts to readable markdown
4. Classifies plan files by reading their content and matching to projects
5. Renames plan files from random codenames (e.g., `binary-singing-lake.md`) to descriptive titles derived from the plan's heading
6. Captures active Cowork session transcripts and output files via the session API
7. Generates per-project summaries with "Quick Resume" sections
8. Runs incrementally — skips unchanged files using stored modification timestamps
9. Builds a master index linking everything together
10. Logs the run to `_backup-log.md`

The resume skill teaches Claude how to navigate the vault structure — which files to read first, how to scope context to the relevant project, and how to respect your coding conventions.

## How Path Encoding Works

Claude Code stores conversation files under `~/.claude/projects/` in directories named by encoding the project's absolute path: each `/` becomes `-`. For example, `/Users/alice/WebKitchen/my-app` is stored as `-Users-alice-WebKitchen-my-app`.

This is ambiguous if a directory or project name contains a dash. Claude-Backup resolves this by using `history.jsonl` as ground truth — every history entry contains the real absolute path — so it builds a map of known paths before decoding directory names, eliminating guesswork.

## Troubleshooting

**Backup ran but the vault is empty**

- Check that Cowork directory access was granted when the task ran (`~/.claude` and `~/Documents`)
- Re-run the backup and watch for access request dialogs

**A project is missing from the vault**

- The project may have no history entries yet (new project with no completed prompts)
- Check that `~/.claude/history.jsonl` has entries with the project's path: `grep "/your/project" ~/.claude/history.jsonl`

**Plans show up in `_unmatched/`**

- The plan file may not mention the project path or name
- Plans are classified by reading their full content — if the project context is ambiguous, they land in `_unmatched/`
- Move them manually to the correct `projects/<name>/plans/` directory

**Last backup shows `IN PROGRESS`**

- A previous backup did not complete successfully
- Check `_backup-log.md` for the timestamp — if it's more than 30 minutes old, the backup failed mid-run
- Re-run the backup; it will process files incrementally

**`./install.sh` fails on Linux with "Unsupported OS"**

- Check your `$OSTYPE`: `echo $OSTYPE`
- If it's not `linux-gnu`, open `install.sh` and add your variant to the Linux branch

## Requirements

- Claude Desktop with Cowork mode
- Claude Code (for Code session backups)
- macOS, Linux, or Windows (PowerShell 5.1+)

## License

MIT
