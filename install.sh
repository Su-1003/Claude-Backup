#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/vault-resume"
SCHEDULED_DIR="$HOME/Documents/Claude/Scheduled/session-backup"

# Allow custom vault location: ./install.sh /path/to/my/vault
VAULT_DIR="${1:-$HOME/Documents/ClaudeVault}"

echo "Installing Claude-Backup..."
echo "  Vault location: $VAULT_DIR"
echo ""

# Install the skill (with vault path substituted)
mkdir -p "$SKILL_DIR"
sed "s|~/Documents/ClaudeVault/|$VAULT_DIR/|g" skill/SKILL.md > "$SKILL_DIR/SKILL.md"
echo "  Skill installed to $SKILL_DIR"

# Install the scheduled task (with vault path substituted)
mkdir -p "$SCHEDULED_DIR"
sed "s|~/Documents/ClaudeVault/|$VAULT_DIR/|g" scheduled-task/SKILL.md > "$SCHEDULED_DIR/SKILL.md"
echo "  Scheduled task installed to $SCHEDULED_DIR"

echo ""
echo "Done! Next steps:"
echo "  1. Open Claude Desktop (Cowork mode)"
echo "  2. Go to Scheduled tasks in the sidebar"
echo "  3. Click 'Run now' on 'session-backup' to do your first backup"
echo "  4. The backup will run automatically every 6 hours after that"
echo ""
echo "To resume any project, just say 'pick up where I left off' in any new session."
