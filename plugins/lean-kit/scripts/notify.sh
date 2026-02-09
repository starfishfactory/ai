#!/usr/bin/env bash
#
# lean-kit notify.sh - macOS 네이티브 알림 전송
# Claude Code 훅에서 호출되어 사용자 입력 대기 시 데스크톱 알림을 보냅니다.
#

# === macOS 환경 감지 ===
[ "$(uname -s)" != "Darwin" ] && exit 0

# === GUI 세션 확인 (headless/SSH 환경 제외) ===
if ! pgrep -x "WindowServer" > /dev/null 2>&1; then
  exit 0
fi

# === stdin JSON 읽기 ===
INPUT=$(cat)
[ -z "$INPUT" ] && exit 0

# === 필드 추출 (jq fallback 포함) ===
NTYPE=""
MSG=""
CWD=""
if command -v jq &> /dev/null; then
  NTYPE=$(echo "$INPUT" | jq -r '.notification_type // empty' 2>/dev/null) || NTYPE=""
  MSG=$(echo "$INPUT" | jq -r '.message // empty' 2>/dev/null) || MSG=""
  CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null) || CWD=""
fi

# === notification_type별 한국어 제목 ===
case "$NTYPE" in
  permission_prompt)  TITLE="Claude Code - 승인 필요" ;;
  idle_prompt)        TITLE="Claude Code - 입력 대기" ;;
  elicitation_dialog) TITLE="Claude Code - 응답 필요" ;;
  *)                  TITLE="Claude Code" ;;
esac

# === 기본값 처리 ===
[ -z "$MSG" ] && MSG="Claude Code에서 입력을 기다리고 있습니다"

# === 메시지 길이 제한 (150자) ===
[ ${#MSG} -gt 150 ] && MSG="${MSG:0:147}..."

# === 작업 디렉토리명 (subtitle) ===
SUBTITLE=""
[ -n "$CWD" ] && SUBTITLE="$(basename "$CWD")"

# === 소리 설정 (환경변수로 제어, 기본: Glass) ===
SOUND="${LEAN_KIT_SOUND-Glass}"

# === 알림 쿨다운 (5초 이내 재알림 억제) ===
COOLDOWN_FILE="/tmp/lean-kit-last-notify"
if [ -f "$COOLDOWN_FILE" ]; then
  LAST=$(cat "$COOLDOWN_FILE" 2>/dev/null) || LAST=0
  NOW=$(date +%s)
  [ $((NOW - LAST)) -lt 5 ] && exit 0
fi
date +%s > "$COOLDOWN_FILE"

# === 디버그 로깅 ===
if [ "${LEAN_KIT_DEBUG:-0}" = "1" ]; then
  LOG="$HOME/.claude/hooks/lean-kit-debug.log"
  mkdir -p "$(dirname "$LOG")"
  echo "[$(date)] type=$NTYPE msg=${MSG:0:50} cwd=$CWD" >> "$LOG"
fi

# === osascript 전송 (on run argv 패턴 - 인젝션 방지) ===
osascript - "$TITLE" "$SUBTITLE" "$MSG" "$SOUND" <<'APPLESCRIPT' 2>/dev/null || exit 0
on run argv
  set theTitle to item 1 of argv
  set theSubtitle to item 2 of argv
  set theMessage to item 3 of argv
  set theSound to item 4 of argv

  if theSound is not "" then
    display notification theMessage with title theTitle subtitle theSubtitle sound name theSound
  else
    display notification theMessage with title theTitle subtitle theSubtitle
  end if
end run
APPLESCRIPT
