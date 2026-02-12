#!/usr/bin/env bash
#
# lean-kit install.sh - 유저 스콥 직접 설치 (standalone)
# ~/.claude/settings.json에 Notification + PermissionRequest 훅을 추가합니다.
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
  warn "jq가 설치되어 있지 않습니다."

  # 대화형 터미널인지 확인 (파이프/CI 환경에서 read 행 걸림 방지)
  if [ ! -t 0 ]; then
    error "jq가 필요합니다. 터미널에서 직접 실행해주세요: brew install jq"
    exit 1
  fi

  if command -v brew &> /dev/null; then
    read -rp "[lean-kit] brew install jq 로 설치할까요? (Y/n) " answer || answer="n"
    if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
      info "jq 설치 중..."
      if brew install jq; then
        info "jq 설치 완료"
      else
        error "jq 설치 실패. 수동으로 설치해주세요: brew install jq"
        exit 1
      fi
    else
      info "설치를 취소했습니다."
      exit 0
    fi
  else
    error "jq가 필요하지만 brew도 설치되어 있지 않습니다."
    error "먼저 Homebrew를 설치해주세요:"
    error '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    error "그 후: brew install jq"
    exit 1
  fi
fi

# === 경로 설정 ===
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

# === 소스 스크립트 확인 ===
if [ ! -f "$SOURCE_SCRIPT" ]; then
  error "notify.sh를 찾을 수 없습니다: $SOURCE_SCRIPT"
  exit 1
fi

if [ ! -f "$SOURCE_PERMIT" ]; then
  error "auto-permit.sh를 찾을 수 없습니다: $SOURCE_PERMIT"
  exit 1
fi

if [ ! -f "$SOURCE_STATUSLINE" ]; then
  error "statusline.sh를 찾을 수 없습니다: $SOURCE_STATUSLINE"
  exit 1
fi

# === 디렉토리 생성 ===
mkdir -p "$HOOKS_DIR"

# === 스크립트 복사 ===
cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"
info "스크립트 설치: $TARGET_SCRIPT"

cp "$SOURCE_PERMIT" "$TARGET_PERMIT"
chmod +x "$TARGET_PERMIT"
info "스크립트 설치: $TARGET_PERMIT"

cp "$SOURCE_STATUSLINE" "$TARGET_STATUSLINE"
chmod +x "$TARGET_STATUSLINE"
info "스크립트 설치: $TARGET_STATUSLINE"

# === 설정 파일 복사 (이미 존재하면 스킵 - 사용자 수정 보존) ===
if [ ! -f "$TARGET_CONF" ]; then
  cp "$SOURCE_CONF" "$TARGET_CONF"
  info "설정 파일 설치 (커스터마이징용): $TARGET_CONF"
  info "  설정 파일 없이도 기본 규칙으로 작동합니다."
else
  warn "설정 파일이 이미 존재합니다 (사용자 수정 보존): $TARGET_CONF"
fi

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

# === 중복 체크 (Notification) ===
HOOK_COMMAND="$TARGET_SCRIPT"
EXISTING=$(jq --arg cmd "$HOOK_COMMAND" -r '
  .hooks.Notification // [] |
  [.[].hooks[]? | select(.command == $cmd)] |
  length
' "$SETTINGS" 2>/dev/null || echo "0")

if [ "$EXISTING" != "0" ]; then
  warn "Notification 훅이 이미 설치되어 있습니다. 건너뜁니다."
else
  jq --arg cmd "$HOOK_COMMAND" '
    .hooks //= {} |
    .hooks.Notification //= [] |
    .hooks.Notification += [{
      "matcher": "permission_prompt|idle_prompt|elicitation_dialog",
      "hooks": [{"type": "command", "command": $cmd, "timeout": 15}]
    }]
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  info "Notification 훅 등록 완료"
fi

# === 중복 체크 (PermissionRequest) ===
PERMIT_COMMAND="$TARGET_PERMIT"
EXISTING_PERMIT=$(jq --arg cmd "$PERMIT_COMMAND" -r '
  .hooks.PermissionRequest // [] |
  [.[].hooks[]? | select(.command == $cmd)] |
  length
' "$SETTINGS" 2>/dev/null || echo "0")

if [ "$EXISTING_PERMIT" != "0" ]; then
  warn "PermissionRequest 훅이 이미 설치되어 있습니다. 건너뜁니다."
else
  jq --arg cmd "$PERMIT_COMMAND" '
    .hooks //= {} |
    .hooks.PermissionRequest //= [] |
    .hooks.PermissionRequest += [{
      "matcher": "",
      "hooks": [{"type": "command", "command": $cmd, "timeout": 5}]
    }]
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  info "PermissionRequest 훅 등록 완료"
fi

# === statusLine 설정 ===
EXISTING_SL=$(jq -r '.statusLine.command // ""' "$SETTINGS" 2>/dev/null)
if echo "$EXISTING_SL" | grep -q 'statusline\.sh$'; then
  warn "statusLine이 이미 설정되어 있습니다. 건너뜁니다."
else
  SKIP_SL=0
  if [ -n "$EXISTING_SL" ]; then
    warn "기존 statusLine 설정: $EXISTING_SL"
    if [ -t 0 ]; then
      read -rp "[lean-kit] lean-kit statusline으로 교체할까요? (Y/n) " sl_answer || sl_answer="n"
      [[ ! "${sl_answer:-Y}" =~ ^[Yy]$ ]] && SKIP_SL=1
    else
      warn "비대화형 모드: 기존 statusLine을 보존합니다."
      SKIP_SL=1
    fi
  fi
  if [ "$SKIP_SL" != "1" ]; then
    jq '.statusLine = {"type":"command","command":"~/.claude/statusline.sh","padding":0}' \
      "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    info "statusLine 설정 등록 완료"
  fi
fi

info ""
info "설치 완료! Claude Code를 재시작하면 적용됩니다."
info ""
info "환경변수 설정 (선택):"
info "  export LEAN_KIT_SOUND=Glass    # 알림 소리 (비워두면 무음: LEAN_KIT_SOUND=)"
info "  export LEAN_KIT_AUTO_PERMIT=1  # 퍼미션 자동 승인 활성화"
info "  export LEAN_KIT_DEBUG=1        # 디버그 로깅"
