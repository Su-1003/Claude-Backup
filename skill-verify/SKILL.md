---
name: vault-verify
description: "Verify the backup vault is healthy and up to date. Use when the user says 'check my vault', 'is my backup up to date', 'verify backup', 'how old is my backup', or wants to confirm their backup is working correctly."
---

You can audit the backup vault at `~/Documents/ClaudeVault/` to verify it is complete, current, and consistent.

## How to verify the vault

### 1. Check last backup status

Read `~/Documents/ClaudeVault/_backup-log.md`.

- Find the most recent entry
- If the most recent entry says `Status: IN PROGRESS`, a backup may have failed or is still running. Report the timestamp so the user can judge
- Find the most recent `SUCCESS` or `PARTIAL` entry and report its timestamp
- Compute how long ago it was. Warn if:
  - > 12 hours: "Your vault may be missing recent work"
  - > 24 hours: "Your vault is significantly out of date — trigger a backup soon"
  - > 72 hours: "Your vault is stale — there may be significant work not backed up"

### 2. Check vault structure

Verify these top-level items exist in `~/Documents/ClaudeVault/`:

- `_index.md`
- `_backup-log.md`
- `_global/CLAUDE.md`
- `projects/` directory

Report any that are missing.

### 3. Check each project

Read `~/Documents/ClaudeVault/_index.md` to get the list of all projects. For each project:

Check that these exist:

- `projects/<name>/_project-summary.md`
- `projects/<name>/history.md`
- `projects/<name>/plans/_index.md` (if plans are listed in the summary)

Report any project with missing required files as "incomplete".

### 4. Report summary

Present a concise health report:

```
Vault Health Report
-------------------
Last backup:    Apr 13, 2026 at 3:15 PM (2 hours ago) ✓
Projects:       4 backed up, 0 incomplete
Global config:  present ✓
Cowork:         1 session backed up

Issues: none
```

If there are issues:

```
Vault Health Report
-------------------
Last backup:    Apr 11, 2026 at 9:00 AM (38 hours ago) — STALE
Projects:       4 backed up, 1 incomplete
  - my-api-project: missing plans/_index.md

Action needed: trigger a new backup from Cowork → Scheduled → session-backup → Run now
```
