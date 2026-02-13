#!/usr/bin/env bash
#
# lean-kit install.sh - User-scope standalone installer
# Adds Notification + PermissionRequest hooks to ~/.claude/settings.json.
#

set -euo pipefail

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[lean-kit]${NC} $1"; }
warn()  { echo -e "${YELLOW}[lean-kit]${NC} $1"; }
error() { echo -e "${RED}[lean-kit]${NC} $1" >&2; }

# === macOS check ===
if [ "$(uname -s)" != "Darwin" ]; then
  error "Only supported on macOS."
  exit 1
fi

# === jq dependency check ===
if ! command -v jq &> /dev/null; then
  warn "jq is not installed."

  # Check if running in interactive terminal (prevent read hang in pipe/CI)
  if [ ! -t 0 ]; then
    error "jq is required. Run manually in terminal: brew install jq"
    exit 1
  fi

  if command -v brew &> /dev/null; then
    read -rp "[lean-kit] Install jq via brew? (Y/n) " answer || answer="n"
    if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
      info "Installing jq..."
      if brew install jq; then
        info "jq installed successfully"
      else
        error "jq installation failed. Install manually: brew install jq"
        exit 1
      fi
    else
      info "Installation cancelled."
      exit 0
    fi
  else
    error "jq is required but brew is not installed either."
    error "Install Homebrew first:"
    error '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    error "Then: brew install jq"
    exit 1
  fi
fi

# === Path setup ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
TARGET_SCRIPT="$HOOKS_DIR/lean-kit-notify.sh"
SOURCE_SCRIPT="$SCRIPT_DIR/scripts/notify.sh"
TARGET_PERMIT="$HOOKS_DIR/lean-kit-auto-permit.sh"
SOURCE_PERMIT="$SCRIPT_DIR/scripts/auto-permit.sh"
TARGET_CONF="$HOOKS_DIR/lean-kit-permit.conf"
SOURCE_CONF="$SCRIPT_DIR/scripts/lean-kit-permit.conf"
TARGET_STATUSLINE="$CLAUDE_DIR/statusline.sh"
SOURCE_STATUSLINE="$SCRIPT_DIR/scripts/statusline.sh"

# === Verify source scripts ===
if [ ! -f "$SOURCE_SCRIPT" ]; then
  error "Cannot find notify.sh: $SOURCE_SCRIPT"
  exit 1
fi

if [ ! -f "$SOURCE_PERMIT" ]; then
  error "Cannot find auto-permit.sh: $SOURCE_PERMIT"
  exit 1
fi

if [ ! -f "$SOURCE_STATUSLINE" ]; then
  error "Cannot find statusline.sh: $SOURCE_STATUSLINE"
  exit 1
fi

# === Create directories ===
mkdir -p "$HOOKS_DIR"

# === Copy scripts ===
cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"
info "Script installed: $TARGET_SCRIPT"

cp "$SOURCE_PERMIT" "$TARGET_PERMIT"
chmod +x "$TARGET_PERMIT"
info "Script installed: $TARGET_PERMIT"

cp "$SOURCE_STATUSLINE" "$TARGET_STATUSLINE"
chmod +x "$TARGET_STATUSLINE"
info "Script installed: $TARGET_STATUSLINE"

# === Copy config file (skip if already exists - preserve user modifications) ===
if [ ! -f "$TARGET_CONF" ]; then
  cp "$SOURCE_CONF" "$TARGET_CONF"
  info "Config file installed (for customization): $TARGET_CONF"
  info "  Works with default rules even without config file."
else
  warn "Config file already exists (preserving user modifications): $TARGET_CONF"
fi

# === settings.json handling ===
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
  info "Created settings.json"
fi

# === JSON validation ===
if ! jq empty "$SETTINGS" 2>/dev/null; then
  error "settings.json is not valid JSON. Please check manually."
  exit 1
fi

# === Backup ===
cp "$SETTINGS" "$SETTINGS.bak"
info "Backup created: $SETTINGS.bak"

# === Duplicate check (Notification) ===
HOOK_COMMAND="$TARGET_SCRIPT"
EXISTING=$(jq --arg cmd "$HOOK_COMMAND" -r '
  .hooks.Notification // [] |
  [.[].hooks[]? | select(.command == $cmd)] |
  length
' "$SETTINGS" 2>/dev/null || echo "0")

if [ "$EXISTING" != "0" ]; then
  warn "Notification hook already installed. Skipping."
else
  jq --arg cmd "$HOOK_COMMAND" '
    .hooks //= {} |
    .hooks.Notification //= [] |
    .hooks.Notification += [{
      "matcher": "permission_prompt|idle_prompt|elicitation_dialog",
      "hooks": [{"type": "command", "command": $cmd, "timeout": 15}]
    }]
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  info "Notification hook registered"
fi

# === Duplicate check (PermissionRequest) ===
PERMIT_COMMAND="$TARGET_PERMIT"
EXISTING_PERMIT=$(jq --arg cmd "$PERMIT_COMMAND" -r '
  .hooks.PermissionRequest // [] |
  [.[].hooks[]? | select(.command == $cmd)] |
  length
' "$SETTINGS" 2>/dev/null || echo "0")

if [ "$EXISTING_PERMIT" != "0" ]; then
  warn "PermissionRequest hook already installed. Skipping."
else
  jq --arg cmd "$PERMIT_COMMAND" '
    .hooks //= {} |
    .hooks.PermissionRequest //= [] |
    .hooks.PermissionRequest += [{
      "matcher": "",
      "hooks": [{"type": "command", "command": $cmd, "timeout": 5}]
    }]
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  info "PermissionRequest hook registered"
fi

# === statusLine setup ===
EXISTING_SL=$(jq -r '.statusLine.command // ""' "$SETTINGS" 2>/dev/null)
if echo "$EXISTING_SL" | grep -q 'statusline\.sh$'; then
  warn "statusLine already configured. Skipping."
else
  SKIP_SL=0
  if [ -n "$EXISTING_SL" ]; then
    warn "Existing statusLine config: $EXISTING_SL"
    if [ -t 0 ]; then
      read -rp "[lean-kit] Replace with lean-kit statusline? (Y/n) " sl_answer || sl_answer="n"
      [[ ! "${sl_answer:-Y}" =~ ^[Yy]$ ]] && SKIP_SL=1
    else
      warn "Non-interactive mode: preserving existing statusLine."
      SKIP_SL=1
    fi
  fi
  if [ "$SKIP_SL" != "1" ]; then
    jq '.statusLine = {"type":"command","command":"~/.claude/statusline.sh","padding":0}' \
      "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    info "statusLine configuration registered"
  fi
fi

info ""
info "Installation complete! Restart Claude Code to apply."
info ""
info "Optional environment variables:"
info "  export LEAN_KIT_SOUND=Glass    # Notification sound (empty for silent: LEAN_KIT_SOUND=)"
info "  export LEAN_KIT_AUTO_PERMIT=1  # Enable permission auto-approval"
info "  export LEAN_KIT_DEBUG=1        # Enable debug logging"
