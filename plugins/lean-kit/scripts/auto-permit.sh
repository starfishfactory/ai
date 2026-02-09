#!/usr/bin/env bash
#
# lean-kit auto-permit.sh - PermissionRequest 자동 승인
# 퍼미션 다이얼로그 표시 시 안전한 도구/명령어를 자동 승인합니다.
#
# 환경변수:
#   LEAN_KIT_AUTO_PERMIT=1  이 값이 설정되어야 작동 (opt-in)
#   LEAN_KIT_DEBUG=1        디버그 로깅
#
# 설정 파일: ~/.claude/hooks/lean-kit-permit.conf
# 의존성: jq
# 제한: non-interactive 모드(-p)에서는 작동하지 않음 (공식 제한)

# === opt-in 확인 ===
[ "${LEAN_KIT_AUTO_PERMIT:-0}" != "1" ] && exit 0

# === jq 의존성 확인 ===
command -v jq &>/dev/null || exit 0

# === 설정 파일 로드 ===
CONF="${LEAN_KIT_PERMIT_CONF:-$HOME/.claude/hooks/lean-kit-permit.conf}"
# 설정 파일 없으면 기본 동작 (사용자 질의)
[ ! -f "$CONF" ] && exit 0

INPUT=$(cat)
[ -z "$INPUT" ] && exit 0

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
[ -z "$TOOL_NAME" ] && exit 0

# === 디버그 로깅 ===
if [ "${LEAN_KIT_DEBUG:-0}" = "1" ]; then
  LOG="$HOME/.claude/hooks/lean-kit-debug.log"
  echo "[$(date)] auto-permit: tool=$TOOL_NAME" >> "$LOG"
fi

# JSON 응답 헬퍼
allow_json() {
  printf '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
}
deny_json() {
  printf '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","message":"%s"}}}' "$1"
}

# 설정 파일에서 섹션 읽기 (# 주석과 빈 줄 무시)
read_section() {
  sed -n "/^\[$1\]/,/^\[/p" "$CONF" | grep -v '^\[' | grep -v '^#' | grep -v '^$'
}

# === 1. Bash 명령어 처리 ===
if [ "$TOOL_NAME" = "Bash" ]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

  # deny 섹션: 포함 패턴 매칭
  while IFS= read -r pattern; do
    case "$CMD" in *$pattern*)
      deny_json "Blocked by deny rule: $pattern"
      exit 0 ;;
    esac
  done < <(read_section "deny_bash")

  # allow 섹션: 접두사 매칭
  while IFS= read -r prefix; do
    case "$CMD" in "$prefix"\ *|"$prefix")
      allow_json; exit 0 ;;
    esac
  done < <(read_section "allow_bash")

  exit 0  # 미분류 → 사용자 질의
fi

# === 2. 파일 수정 도구 ===
case "$TOOL_NAME" in
  Edit|Write|NotebookEdit)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    # deny_files 섹션: 민감 파일 보호
    while IFS= read -r pattern; do
      case "$FILE_PATH" in *$pattern*)
        exit 0 ;;  # 사용자 질의로 폴백
      esac
    done < <(read_section "deny_files")
    # allow_tools에 Edit/Write가 있으면 승인
    if read_section "allow_tools" | grep -qx "$TOOL_NAME"; then
      allow_json; exit 0
    fi ;;
esac

# === 3. 기타 도구 (Task, MCP 등) ===
if read_section "allow_tools" | grep -qx "$TOOL_NAME"; then
  allow_json; exit 0
fi

# === 4. MCP 도구 - 패턴 매칭 ===
while IFS= read -r pattern; do
  case "$TOOL_NAME" in $pattern)
    allow_json; exit 0 ;;
  esac
done < <(read_section "allow_mcp")

# === 5. 기타 → 사용자 질의 ===
exit 0
