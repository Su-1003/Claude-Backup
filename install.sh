#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/vault-resume"

# Detect OS and set default paths accordingly
if [[ "$OSTYPE" == "darwin"* ]]; then
  DEFAULT_VAULT="$HOME/Documents/ClaudeVault"
  SCHEDULED_DIR="$HOME/Documents/Claude/Scheduled/session-backup"
elif [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "linux"* ]]; then
  DEFAULT_VAULT="$HOME/.local/share/ClaudeVault"
  SCHEDULED_DIR="$HOME/.local/share/claude/Scheduled/session-backup"
else
  echo "ERROR: Unsupported OS: $OSTYPE" >&2
  echo "  For Windows, run: powershell ./install.ps1" >&2
  exit 1
fi

# --check: verify existing installation
if [[ "$1" == "--check" ]]; then
  echo "Checking Claude-Backup installation..."
  if [[ -f "$SKILL_DIR/SKILL.md" ]]; then
    echo "  Resume skill:     installed ($SKILL_DIR/SKILL.md)"
  else
    echo "  Resume skill:     NOT FOUND ($SKILL_DIR/SKILL.md)"
  fi
  if [[ -f "$SCHEDULED_DIR/SKILL.md" ]]; then
    echo "  Scheduled backup: installed ($SCHEDULED_DIR/SKILL.md)"
  else
    echo "  Scheduled backup: NOT FOUND ($SCHEDULED_DIR/SKILL.md)"
  fi
  exit 0
fi

# --uninstall: remove installed files
if [[ "$1" == "--uninstall" ]]; then
  echo "Uninstalling Claude-Backup..."
  rm -rf "$SKILL_DIR"
  echo "  Removed: $SKILL_DIR"
  rm -rf "$SCHEDULED_DIR"
  echo "  Removed: $SCHEDULED_DIR"
  echo "Done. Your vault data at the backup destination was NOT removed."
  exit 0
fi

# Allow custom vault location: ./install.sh /path/to/my/vault
VAULT_DIR="${1:-$DEFAULT_VAULT}"

echo "Installing Claude-Backup..."
echo "  OS:             $OSTYPE"
echo "  Vault location: $VAULT_DIR"
echo ""

# Warn if reinstalling
if [[ -f "$SKILL_DIR/SKILL.md" ]]; then
  echo "  Existing installation found — updating..."
fi

# Install the resume skill (with vault path substituted)
mkdir -p "$SKILL_DIR"
sed "s|~/Documents/ClaudeVault/|$VAULT_DIR/|g" skill/SKILL.md > "$SKILL_DIR/SKILL.md"
echo "  Resume skill installed to: $SKILL_DIR"

# Install the scheduled backup task (with vault path substituted)
mkdir -p "$SCHEDULED_DIR"
sed "s|~/Documents/ClaudeVault/|$VAULT_DIR/|g" scheduled-task/SKILL.md > "$SCHEDULED_DIR/SKILL.md"
echo "  Scheduled task installed to: $SCHEDULED_DIR"

# Install .gitignore template to vault directory (only on first install)
if [[ ! -f "$VAULT_DIR/.gitignore" ]]; then
  mkdir -p "$VAULT_DIR"
  cp vault-gitignore.template "$VAULT_DIR/.gitignore"
  echo "  Security: .gitignore installed to $VAULT_DIR"
fi

# Verify both files were written
if [[ ! -f "$SKILL_DIR/SKILL.md" ]]; then
  echo "ERROR: Resume skill install failed — $SKILL_DIR/SKILL.md not found" >&2
  exit 1
fi
if [[ ! -f "$SCHEDULED_DIR/SKILL.md" ]]; then
  echo "ERROR: Scheduled task install failed — $SCHEDULED_DIR/SKILL.md not found" >&2
  exit 1
fi

echo ""
echo "Done! Next steps:"
echo "  1. Open Claude Desktop (Cowork mode)"
echo "  2. Go to Scheduled tasks in the sidebar"
echo "  3. Click 'Run now' on 'session-backup' to do your first backup"
echo "  4. The backup will run automatically every 6 hours after that"
echo ""
echo "To resume any project, say 'pick up where I left off' in any new session."
echo ""
echo "Other commands:"
echo "  ./install.sh --check      Verify installation"
echo "  ./install.sh --uninstall  Remove installed files"
echo "  ./install.sh /custom/path Install with custom vault location"
