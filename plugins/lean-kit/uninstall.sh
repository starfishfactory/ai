#!/usr/bin/env bash
#
# lean-kit uninstall.sh - 제거 스크립트
# ~/.claude/settings.json에서 lean-kit 훅을 제거하고 스크립트를 삭제합니다.
#

set -euo pipefail

# === 색상 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[lean-kit]${NC} $1"; }
warn()  { echo -e "${YELLOW}[lean-kit]${NC} $1"; }
error() { echo -e "${RED}[lean-kit]${NC} $1" >&2; }

# === 경로 설정 ===
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
TARGET_SCRIPT="$HOOKS_DIR/lean-kit-notify.sh"
DEBUG_LOG="$HOOKS_DIR/lean-kit-debug.log"

# === 스크립트 삭제 ===
if [ -f "$TARGET_SCRIPT" ]; then
  rm "$TARGET_SCRIPT"
  info "스크립트 삭제: $TARGET_SCRIPT"
else
  warn "스크립트가 이미 없습니다: $TARGET_SCRIPT"
fi

# === 디버그 로그 삭제 ===
if [ -f "$DEBUG_LOG" ]; then
  rm "$DEBUG_LOG"
  info "디버그 로그 삭제: $DEBUG_LOG"
fi

# === settings.json에서 훅 제거 ===
if [ -f "$SETTINGS" ] && command -v jq &> /dev/null; then
  # JSON 유효성 확인
  if ! jq empty "$SETTINGS" 2>/dev/null; then
    error "settings.json이 유효한 JSON이 아닙니다. 수동으로 확인해주세요."
    exit 1
  fi

  # 백업
  cp "$SETTINGS" "$SETTINGS.bak"

  # lean-kit 관련 훅만 제거 (다른 Notification 훅 보존)
  jq '
    if .hooks.Notification then
      .hooks.Notification |= [
        .[] | select(
          (.hooks // []) | all(.command | test("lean-kit") | not)
        )
      ] |
      if .hooks.Notification | length == 0 then
        del(.hooks.Notification)
      else . end |
      if .hooks | length == 0 then
        del(.hooks)
      else . end
    else . end
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

  info "settings.json에서 훅 제거 완료"
else
  if [ ! -f "$SETTINGS" ]; then
    warn "settings.json이 없습니다."
  fi
  if ! command -v jq &> /dev/null; then
    warn "jq가 없어 settings.json을 수정할 수 없습니다. 수동으로 제거해주세요."
  fi
fi

# === 백업 파일 정리 ===
if [ -f "$SETTINGS.bak" ]; then
  rm "$SETTINGS.bak"
  info "백업 파일 정리"
fi

info ""
info "제거 완료! Claude Code를 재시작하면 적용됩니다."
