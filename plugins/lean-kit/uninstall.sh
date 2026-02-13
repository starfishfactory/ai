#!/usr/bin/env bash
#
# lean-kit uninstall.sh - Uninstall script
# Removes lean-kit hooks from ~/.claude/settings.json and deletes scripts.
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

# === Path setup ===
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
TARGET_SCRIPT="$HOOKS_DIR/lean-kit-notify.sh"
TARGET_PERMIT="$HOOKS_DIR/lean-kit-auto-permit.sh"
TARGET_CONF="$HOOKS_DIR/lean-kit-permit.conf"
DEBUG_LOG="$HOOKS_DIR/lean-kit-debug.log"
TARGET_STATUSLINE="$CLAUDE_DIR/statusline.sh"

# === Delete scripts ===
if [ -f "$TARGET_SCRIPT" ]; then
  rm "$TARGET_SCRIPT"
  info "Script removed: $TARGET_SCRIPT"
else
  warn "Script already absent: $TARGET_SCRIPT"
fi

# === Delete auto-permit script ===
if [ -f "$TARGET_PERMIT" ]; then
  rm "$TARGET_PERMIT"
  info "Script removed: $TARGET_PERMIT"
else
  warn "Auto-permit script already absent: $TARGET_PERMIT"
fi

# === Delete statusline ===
if [ -f "$TARGET_STATUSLINE" ]; then
  rm "$TARGET_STATUSLINE"
  info "Script removed: $TARGET_STATUSLINE"
else
  warn "Statusline already absent: $TARGET_STATUSLINE"
fi

# === Config file notice (preserve user customizations) ===
if [ -f "$TARGET_CONF" ]; then
  warn "Config file preserved (may contain user modifications): $TARGET_CONF"
  warn "Manual removal: rm $TARGET_CONF"
fi

# === Delete debug log ===
if [ -f "$DEBUG_LOG" ]; then
  rm "$DEBUG_LOG"
  info "Debug log removed: $DEBUG_LOG"
fi

# === Delete cooldown file ===
if [ -f "/tmp/lean-kit-last-notify" ]; then
  rm -f "/tmp/lean-kit-last-notify"
  info "Cooldown file removed"
fi

# === Clean statusline cache ===
rm -f /tmp/ccusage_statusline.cache /tmp/ccusage_statusline.pid 2>/dev/null
rmdir /tmp/ccusage_statusline.lock 2>/dev/null

# === Remove hooks from settings.json ===
if [ -f "$SETTINGS" ] && command -v jq &> /dev/null; then
  # Validate JSON
  if ! jq empty "$SETTINGS" 2>/dev/null; then
    error "settings.json is not valid JSON. Please check manually."
    exit 1
  fi

  # Backup
  cp "$SETTINGS" "$SETTINGS.bak"

  # Remove only lean-kit hooks (preserve other hooks)
  jq '
    # Remove Notification hooks
    if .hooks.Notification then
      .hooks.Notification |= [
        .[] | select(
          (.hooks // []) | all(.command | test("lean-kit-notify\\.sh$") | not)
        )
      ] |
      if .hooks.Notification | length == 0 then
        del(.hooks.Notification)
      else . end
    else . end |
    # Remove PermissionRequest hooks
    if .hooks.PermissionRequest then
      .hooks.PermissionRequest |= [
        .[] | select(
          (.hooks // []) | all(.command | test("lean-kit-auto-permit\\.sh$") | not)
        )
      ] |
      if .hooks.PermissionRequest | length == 0 then
        del(.hooks.PermissionRequest)
      else . end
    else . end |
    # Remove statusLine (only lean-kit statusline.sh)
    if .statusLine.command then
      if (.statusLine.command | test("statusline\\.sh$")) then del(.statusLine)
      else . end
    else . end |
    # Remove hooks object if empty
    if .hooks and (.hooks | length == 0) then
      del(.hooks)
    else . end
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

  info "Hooks removed from settings.json"
else
  if [ ! -f "$SETTINGS" ]; then
    warn "settings.json not found."
  fi
  if ! command -v jq &> /dev/null; then
    warn "jq not available. Cannot modify settings.json. Please remove manually."
  fi
fi

# === Clean backup file (after verifying result) ===
if [ -f "$SETTINGS.bak" ]; then
  if jq empty "$SETTINGS" 2>/dev/null; then
    rm -f "$SETTINGS.bak"
    info "Backup file cleaned up"
  else
    warn "settings.json validation failed. Backup preserved: $SETTINGS.bak"
  fi
fi

info ""
info "Uninstall complete! Restart Claude Code to apply."
