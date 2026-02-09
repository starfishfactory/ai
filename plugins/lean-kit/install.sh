#!/usr/bin/env bash
#
# lean-kit install.sh - 유저 스콥 직접 설치 (standalone)
# ~/.claude/settings.json에 Notification 훅을 추가합니다.
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

# === macOS 체크 ===
if [ "$(uname -s)" != "Darwin" ]; then
  error "macOS에서만 지원됩니다."
  exit 1
fi

# === jq 의존성 체크 ===
if ! command -v jq &> /dev/null; then
  error "jq가 필요합니다. 설치: brew install jq"
  exit 1
fi

# === 경로 설정 ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
TARGET_SCRIPT="$HOOKS_DIR/lean-kit-notify.sh"
SOURCE_SCRIPT="$SCRIPT_DIR/scripts/notify.sh"

# === 소스 스크립트 확인 ===
if [ ! -f "$SOURCE_SCRIPT" ]; then
  error "notify.sh를 찾을 수 없습니다: $SOURCE_SCRIPT"
  exit 1
fi

# === 디렉토리 생성 ===
mkdir -p "$HOOKS_DIR"

# === 스크립트 복사 ===
cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"
info "스크립트 설치: $TARGET_SCRIPT"

# === settings.json 처리 ===
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
  info "settings.json 생성"
fi

# === JSON 유효성 검증 ===
if ! jq empty "$SETTINGS" 2>/dev/null; then
  error "settings.json이 유효한 JSON이 아닙니다. 수동으로 확인해주세요."
  exit 1
fi

# === 백업 ===
cp "$SETTINGS" "$SETTINGS.bak"
info "백업 생성: $SETTINGS.bak"

# === 중복 체크 ===
HOOK_COMMAND="$TARGET_SCRIPT"
EXISTING=$(jq -r '
  .hooks.Notification // [] |
  [.[].hooks[]? | select(.command == "'"$HOOK_COMMAND"'")] |
  length
' "$SETTINGS" 2>/dev/null || echo "0")

if [ "$EXISTING" != "0" ]; then
  warn "이미 설치되어 있습니다. 건너뜁니다."
  exit 0
fi

# === 훅 추가 (기존 배열에 append) ===
NEW_HOOK=$(cat <<EOF
{
  "matcher": "permission_prompt|idle_prompt|elicitation_dialog",
  "hooks": [
    {
      "type": "command",
      "command": "$HOOK_COMMAND",
      "timeout": 15
    }
  ]
}
EOF
)

jq --argjson hook "$NEW_HOOK" '
  .hooks //= {} |
  .hooks.Notification //= [] |
  .hooks.Notification += [$hook]
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

info "Notification 훅 등록 완료"
info ""
info "설치 완료! Claude Code를 재시작하면 적용됩니다."
info ""
info "환경변수 설정 (선택):"
info "  export LEAN_KIT_SOUND=Glass    # 알림 소리 (비워두면 무음: LEAN_KIT_SOUND=)"
info "  export LEAN_KIT_DEBUG=1        # 디버그 로깅"
