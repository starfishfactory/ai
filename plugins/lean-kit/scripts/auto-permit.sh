#!/usr/bin/env bash
#
# lean-kit auto-permit.sh - PermissionRequest 자동 승인
# 퍼미션 다이얼로그 표시 시 안전한 도구/명령어를 자동 승인합니다.
#
# 환경변수:
#   LEAN_KIT_AUTO_PERMIT=1  이 값이 설정되어야 작동 (opt-in)
#   LEAN_KIT_DEBUG=1        디버그 로깅
#
# 설정 파일(선택): ~/.claude/hooks/lean-kit-permit.conf
#   파일이 없으면 아래 기본 규칙으로 작동합니다.
#   파일이 있으면 해당 섹션만 오버라이드됩니다.
#
# 의존성: jq
# 제한: non-interactive 모드(-p)에서는 작동하지 않음 (공식 제한)

# === opt-in 확인 ===
[ "${LEAN_KIT_AUTO_PERMIT:-0}" != "1" ] && exit 0

# === jq 의존성 확인 ===
command -v jq &>/dev/null || exit 0

# === 기본 규칙 (설정 파일이 없을 때 사용) ===
read -r -d '' DEFAULT_DENY_BASH <<'RULES' || true
rm -rf /
rm -rf ~
sudo rm
mkfs
dd if=
chmod -R 777 /
RULES

read -r -d '' DEFAULT_ALLOW_BASH <<'RULES' || true
git
npm
npx
node
python
pip
brew
ls
cat
head
tail
wc
echo
mkdir
cp
mv
chmod
touch
ln
curl
wget
jq
gh
docker
make
cargo
yarn
pnpm
which
type
env
printenv
pwd
date
whoami
id
uname
sort
uniq
diff
find
grep
rg
sed
awk
tr
xargs
tee
source
bash
sh
test
claude
realpath
dirname
basename
RULES

read -r -d '' DEFAULT_DENY_FILES <<'RULES' || true
.env
credentials
.ssh/
.gnupg/
secrets
.git/
RULES

read -r -d '' DEFAULT_ALLOW_TOOLS <<'RULES' || true
Edit
Write
NotebookEdit
Task
RULES

read -r -d '' DEFAULT_ALLOW_MCP <<'RULES' || true
mcp__*get*
mcp__*list*
mcp__*read*
mcp__*search*
mcp__*query*
mcp__*fetch*
mcp__*view*
mcp__*find*
mcp__*count*
mcp__*describe*
mcp__*show*
RULES

# === 설정 파일 (선택적 오버라이드) ===
CONF="${LEAN_KIT_PERMIT_CONF:-$HOME/.claude/hooks/lean-kit-permit.conf}"

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

# 설정 파일에서 섹션 읽기, 없으면 기본값 사용 (bash 3.2 호환)
read_section() {
  local section="$1"
  # 설정 파일에 해당 섹션이 존재하면 파일에서 읽기
  if [ -f "$CONF" ] && grep -q "^\[$section\]" "$CONF" 2>/dev/null; then
    sed -n "/^\[$section\]/,/^\[/p" "$CONF" | grep -v '^\[' | grep -v '^#' | grep -v '^$'
    return
  fi
  # 기본값 사용
  case "$section" in
    deny_bash)    echo "$DEFAULT_DENY_BASH" ;;
    allow_bash)   echo "$DEFAULT_ALLOW_BASH" ;;
    deny_files)   echo "$DEFAULT_DENY_FILES" ;;
    allow_tools)  echo "$DEFAULT_ALLOW_TOOLS" ;;
    allow_mcp)    echo "$DEFAULT_ALLOW_MCP" ;;
  esac
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
