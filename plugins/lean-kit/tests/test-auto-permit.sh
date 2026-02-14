#!/usr/bin/env bash
#
# test-auto-permit.sh - auto-permit.sh 훅 테스트
# 실행: bash plugins/lean-kit/tests/test-auto-permit.sh
#

set -euo pipefail

# === 경로 설정 ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_UNDER_TEST="$SCRIPT_DIR/../scripts/auto-permit.sh"

if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
  echo "ERROR: auto-permit.sh not found at $SCRIPT_UNDER_TEST"
  exit 1
fi

# === 색상 출력 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# === 카운터 ===
PASS=0
FAIL=0
TOTAL=0

# === 테스트 격리: 설정 파일을 존재하지 않는 경로로 지정 ===
NONEXISTENT_CONF="/tmp/lean-kit-test-nonexistent-$$/.conf"

# === 헬퍼 함수 ===

run_script() {
  # stdin으로 JSON 전달, auto-permit.sh 실행
  # 환경변수: LEAN_KIT_AUTO_PERMIT=1, LEAN_KIT_PERMIT_CONF=존재하지 않는 경로
  local json="$1"
  shift
  # 추가 환경변수를 인자로 전달 가능
  env LEAN_KIT_AUTO_PERMIT=1 \
      LEAN_KIT_PERMIT_CONF="$NONEXISTENT_CONF" \
      "$@" \
      bash "$SCRIPT_UNDER_TEST" <<< "$json" 2>/dev/null || true
}

assert_allow() {
  local desc="$1"
  local output="$2"
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q '"allow"'; then
    PASS=$((PASS + 1))
    printf "  ${GREEN}✓${RESET} %s\n" "$desc"
  else
    FAIL=$((FAIL + 1))
    printf "  ${RED}✗${RESET} %s ${RED}(expected allow, got: %s)${RESET}\n" "$desc" "${output:-<empty>}"
  fi
}

assert_deny() {
  local desc="$1"
  local output="$2"
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q '"deny"'; then
    PASS=$((PASS + 1))
    printf "  ${GREEN}✓${RESET} %s\n" "$desc"
  else
    FAIL=$((FAIL + 1))
    printf "  ${RED}✗${RESET} %s ${RED}(expected deny, got: %s)${RESET}\n" "$desc" "${output:-<empty>}"
  fi
}

assert_silent() {
  local desc="$1"
  local output="$2"
  TOTAL=$((TOTAL + 1))
  if [ -z "$output" ]; then
    PASS=$((PASS + 1))
    printf "  ${GREEN}✓${RESET} %s\n" "$desc"
  else
    FAIL=$((FAIL + 1))
    printf "  ${RED}✗${RESET} %s ${RED}(expected silent, got: %s)${RESET}\n" "$desc" "$output"
  fi
}

# JSON 입력 생성 헬퍼 (jq로 안전한 이스케이프)
bash_json() {
  local cmd="$1"
  jq -nc --arg c "$cmd" '{"tool_name":"Bash","tool_input":{"command":$c}}'
}

edit_json() {
  local path="$1"
  jq -nc --arg p "$path" '{"tool_name":"Edit","tool_input":{"file_path":$p,"old_string":"a","new_string":"b"}}'
}

write_json() {
  local path="$1"
  jq -nc --arg p "$path" '{"tool_name":"Write","tool_input":{"file_path":$p,"content":"hello"}}'
}

notebook_json() {
  local path="$1"
  jq -nc --arg p "$path" '{"tool_name":"NotebookEdit","tool_input":{"file_path":$p,"new_source":"x"}}'
}

tool_json() {
  local name="$1"
  jq -nc --arg n "$name" '{"tool_name":$n,"tool_input":{}}'
}

# === 테스트 그룹 실행 ===

group_header() {
  printf "\n${CYAN}${BOLD}[그룹 %s] %s${RESET}\n" "$1" "$2"
}

# ─────────────────────────────────────────────
# 그룹 0: 전제조건
# ─────────────────────────────────────────────
group_header 0 "전제조건"

# 0-1: AUTO_PERMIT 미설정 시 silent
out=$(env LEAN_KIT_AUTO_PERMIT=0 \
         LEAN_KIT_PERMIT_CONF="$NONEXISTENT_CONF" \
         bash "$SCRIPT_UNDER_TEST" <<< "$(bash_json 'ls')" 2>/dev/null || true)
assert_silent "AUTO_PERMIT=0이면 silent" "$out"

# 0-2: AUTO_PERMIT 미설정 (unset)
out=$(env -u LEAN_KIT_AUTO_PERMIT \
         LEAN_KIT_PERMIT_CONF="$NONEXISTENT_CONF" \
         bash "$SCRIPT_UNDER_TEST" <<< "$(bash_json 'ls')" 2>/dev/null || true)
assert_silent "AUTO_PERMIT unset이면 silent" "$out"

# 0-3: 빈 입력
out=$(run_script "")
assert_silent "빈 입력이면 silent" "$out"

# 0-4: tool_name 없는 JSON
out=$(run_script '{"tool_input":{}}')
assert_silent "tool_name 없으면 silent" "$out"

# 0-5: 잘못된 JSON
out=$(run_script 'not-json-at-all')
assert_silent "잘못된 JSON이면 silent" "$out"

# 0-6: tool_name이 빈 문자열
out=$(run_script '{"tool_name":"","tool_input":{}}')
assert_silent "tool_name 빈 문자열이면 silent" "$out"

# ─────────────────────────────────────────────
# 그룹 1: Bash deny
# ─────────────────────────────────────────────
group_header 1 "Bash deny (위험 명령 차단)"

out=$(run_script "$(bash_json 'rm -rf /')")
assert_deny "rm -rf / 차단" "$out"

out=$(run_script "$(bash_json 'rm -rf ~')")
assert_deny "rm -rf ~ 차단" "$out"

out=$(run_script "$(bash_json 'sudo rm -rf /tmp/data')")
assert_deny "sudo rm 차단" "$out"

out=$(run_script "$(bash_json 'mkfs.ext4 /dev/sda1')")
assert_deny "mkfs 차단" "$out"

out=$(run_script "$(bash_json 'dd if=/dev/zero of=/dev/sda')")
assert_deny "dd if= 차단" "$out"

out=$(run_script "$(bash_json 'chmod -R 777 /')")
assert_deny "chmod -R 777 / 차단" "$out"

out=$(run_script "$(bash_json 'echo hello && rm -rf /')")
assert_deny "파이프에 포함된 rm -rf / 차단" "$out"

# ─────────────────────────────────────────────
# 그룹 2: Bash allow
# ─────────────────────────────────────────────
group_header 2 "Bash allow (안전 명령 승인)"

out=$(run_script "$(bash_json 'git status')")
assert_allow "git status 승인" "$out"

out=$(run_script "$(bash_json 'git')")
assert_allow "git 단독 승인" "$out"

out=$(run_script "$(bash_json 'npm install')")
assert_allow "npm install 승인" "$out"

out=$(run_script "$(bash_json 'ls -la')")
assert_allow "ls -la 승인" "$out"

out=$(run_script "$(bash_json 'docker compose up')")
assert_allow "docker compose up 승인" "$out"

out=$(run_script "$(bash_json 'node index.js')")
assert_allow "node index.js 승인" "$out"

out=$(run_script "$(bash_json 'python script.py')")
assert_allow "python script.py 승인" "$out"

out=$(run_script "$(bash_json 'make build')")
assert_allow "make build 승인" "$out"

out=$(run_script "$(bash_json 'echo hello world')")
assert_allow "echo hello world 승인" "$out"

out=$(run_script "$(bash_json 'curl https://example.com')")
assert_allow "curl 승인" "$out"

out=$(run_script "$(bash_json 'gh pr list')")
assert_allow "gh pr list 승인" "$out"

out=$(run_script "$(bash_json 'basename /foo/bar.txt')")
assert_allow "basename 승인" "$out"

# ─────────────────────────────────────────────
# 그룹 3: Bash 접두사 경계
# ─────────────────────────────────────────────
group_header 3 "Bash 접두사 경계 검증"

out=$(run_script "$(bash_json 'gitsecret reveal')")
assert_silent "gitsecret은 git에 매칭 안됨" "$out"

out=$(run_script "$(bash_json 'node_modules/.bin/jest')")
assert_silent "node_modules는 node에 매칭 안됨" "$out"

out=$(run_script "$(bash_json 'making-stuff')")
assert_silent "making-stuff는 make에 매칭 안됨" "$out"

out=$(run_script "$(bash_json 'pythonic-linter src/')")
assert_silent "pythonic-linter는 python에 매칭 안됨" "$out"

out=$(run_script "$(bash_json 'echoing test')")
assert_silent "echoing은 echo에 매칭 안됨" "$out"

# ─────────────────────────────────────────────
# 그룹 4: 파일 도구 deny
# ─────────────────────────────────────────────
group_header 4 "파일 도구 deny (민감 파일 보호)"

out=$(run_script "$(edit_json '/project/.env')")
assert_silent ".env 파일 Edit 차단 (silent)" "$out"

out=$(run_script "$(write_json '/project/.env.production')")
assert_silent ".env.production Write 차단 (silent)" "$out"

out=$(run_script "$(edit_json '/home/user/.ssh/id_rsa')")
assert_silent ".ssh/ 파일 Edit 차단 (silent)" "$out"

out=$(run_script "$(write_json '/home/user/.gnupg/private.key')")
assert_silent ".gnupg/ 파일 Write 차단 (silent)" "$out"

out=$(run_script "$(edit_json '/project/config/credentials.json')")
assert_silent "credentials 파일 Edit 차단 (silent)" "$out"

out=$(run_script "$(notebook_json '/project/.git/config')")
assert_silent ".git/ 파일 NotebookEdit 차단 (silent)" "$out"

# ─────────────────────────────────────────────
# 그룹 5: 파일 도구 allow
# ─────────────────────────────────────────────
group_header 5 "파일 도구 allow (일반 파일 승인)"

out=$(run_script "$(edit_json '/project/src/main.py')")
assert_allow "일반 파일 Edit 승인" "$out"

out=$(run_script "$(write_json '/project/README.md')")
assert_allow "README.md Write 승인" "$out"

out=$(run_script "$(notebook_json '/project/analysis.ipynb')")
assert_allow "ipynb NotebookEdit 승인" "$out"

out=$(run_script "$(edit_json '/project/src/components/Button.tsx')")
assert_allow "tsx 파일 Edit 승인" "$out"

out=$(run_script "$(write_json '/project/package.json')")
assert_allow "package.json Write 승인" "$out"

# ─────────────────────────────────────────────
# 그룹 6: 기타 도구
# ─────────────────────────────────────────────
group_header 6 "기타 도구 (정확 매칭)"

out=$(run_script "$(tool_json 'Task')")
assert_allow "Task 도구 승인" "$out"

out=$(run_script "$(tool_json 'Edit')")
assert_allow "Edit 도구 (파일 경로 없이) 승인" "$out"

out=$(run_script "$(tool_json 'UnknownTool')")
assert_silent "UnknownTool은 silent (폴백)" "$out"

out=$(run_script "$(tool_json 'Taskify')")
assert_silent "Taskify는 Task에 정확 매칭 안됨" "$out"

# ─────────────────────────────────────────────
# 그룹 7: MCP 도구
# ─────────────────────────────────────────────
group_header 7 "MCP 도구 (패턴 매칭)"

out=$(run_script "$(tool_json 'mcp__github__get_issue')")
assert_allow "mcp__github__get_issue 승인" "$out"

out=$(run_script "$(tool_json 'mcp__db__list_tables')")
assert_allow "mcp__db__list_tables 승인" "$out"

out=$(run_script "$(tool_json 'mcp__fs__read_file')")
assert_allow "mcp__fs__read_file 승인" "$out"

out=$(run_script "$(tool_json 'mcp__api__search_users')")
assert_allow "mcp__api__search_users 승인" "$out"

out=$(run_script "$(tool_json 'mcp__jira__fetch_sprint')")
assert_allow "mcp__jira__fetch_sprint 승인" "$out"

out=$(run_script "$(tool_json 'mcp__stats__count_records')")
assert_allow "mcp__stats__count_records 승인" "$out"

out=$(run_script "$(tool_json 'mcp__github__create_issue')")
assert_silent "mcp__github__create_issue 불허 (silent)" "$out"

out=$(run_script "$(tool_json 'mcp__db__delete_table')")
assert_silent "mcp__db__delete_table 불허 (silent)" "$out"

# ─────────────────────────────────────────────
# 그룹 8: 설정 파일 오버라이드
# ─────────────────────────────────────────────
group_header 8 "설정 파일 오버라이드"

TEMP_CONF=$(mktemp)
trap "rm -f '$TEMP_CONF'" EXIT

# 8-1: allow_bash만 오버라이드 (git만 허용, npm 제거)
cat > "$TEMP_CONF" <<'EOF'
[allow_bash]
git
ls
EOF

out=$(env LEAN_KIT_AUTO_PERMIT=1 LEAN_KIT_PERMIT_CONF="$TEMP_CONF" \
     bash "$SCRIPT_UNDER_TEST" <<< "$(bash_json 'git status')" 2>/dev/null || true)
assert_allow "오버라이드: git은 여전히 승인" "$out"

out=$(env LEAN_KIT_AUTO_PERMIT=1 LEAN_KIT_PERMIT_CONF="$TEMP_CONF" \
     bash "$SCRIPT_UNDER_TEST" <<< "$(bash_json 'npm install')" 2>/dev/null || true)
assert_silent "오버라이드: npm은 제거되어 silent" "$out"

# 8-2: deny_bash는 오버라이드하지 않았으므로 기본값 유지
out=$(env LEAN_KIT_AUTO_PERMIT=1 LEAN_KIT_PERMIT_CONF="$TEMP_CONF" \
     bash "$SCRIPT_UNDER_TEST" <<< "$(bash_json 'rm -rf /')" 2>/dev/null || true)
assert_deny "오버라이드: deny_bash 기본값 유지 (rm -rf /)" "$out"

# 8-3: allow_tools는 오버라이드하지 않았으므로 기본값 유지
out=$(env LEAN_KIT_AUTO_PERMIT=1 LEAN_KIT_PERMIT_CONF="$TEMP_CONF" \
     bash "$SCRIPT_UNDER_TEST" <<< "$(tool_json 'Task')" 2>/dev/null || true)
assert_allow "오버라이드: allow_tools 기본값 유지 (Task)" "$out"

# 8-4: deny_files만 오버라이드 (secrets만 차단)
cat > "$TEMP_CONF" <<'EOF'
[deny_files]
secrets
EOF

out=$(env LEAN_KIT_AUTO_PERMIT=1 LEAN_KIT_PERMIT_CONF="$TEMP_CONF" \
     bash "$SCRIPT_UNDER_TEST" <<< "$(edit_json '/project/.env')" 2>/dev/null || true)
assert_allow "오버라이드: .env가 deny_files에서 제거되어 승인" "$out"

# ─────────────────────────────────────────────
# 그룹 9: 부분 문자열 엣지케이스
# ─────────────────────────────────────────────
group_header 9 "부분 문자열 엣지케이스"

# 9-1: rm 단독 (deny에 "rm -rf /"가 있지만 "rm" 단독은 해당 안됨)
out=$(run_script "$(bash_json 'rm temp.txt')")
assert_silent "rm 단독은 deny 매칭 안됨 (미분류 silent)" "$out"

# 9-2: echo "sudo rm" - echo가 allow지만 sudo rm이 deny에 해당
# deny가 먼저 검사되므로 deny가 우선
out=$(run_script "$(bash_json 'echo "sudo rm something"')")
assert_deny "echo 안에 sudo rm 포함 시 deny 우선" "$out"

# 9-3: .environment 경로가 .env deny 패턴에 매칭됨 (부분 문자열)
out=$(run_script "$(edit_json '/project/.environment/config.yml')")
assert_silent ".environment는 .env 포함으로 매칭됨 (silent)" "$out"

# 9-4: secrets_backup 경로가 secrets deny 패턴에 매칭됨
out=$(run_script "$(write_json '/project/secrets_backup/data.json')")
assert_silent "secrets_backup은 secrets 포함으로 매칭됨 (silent)" "$out"

# ─────────────────────────────────────────────
# 그룹 10: 디버그 로깅
# ─────────────────────────────────────────────
group_header 10 "디버그 로깅"

DEBUG_LOG="$HOME/.claude/hooks/lean-kit-debug.log"
# 기존 로그 백업 후 제거
if [ -f "$DEBUG_LOG" ]; then
  cp "$DEBUG_LOG" "${DEBUG_LOG}.bak.$$"
  rm -f "$DEBUG_LOG"
fi

# 10-1: LEAN_KIT_DEBUG=1 시 로그 기록 확인
env LEAN_KIT_AUTO_PERMIT=1 LEAN_KIT_PERMIT_CONF="$NONEXISTENT_CONF" LEAN_KIT_DEBUG=1 \
    bash "$SCRIPT_UNDER_TEST" <<< "$(bash_json 'ls')" > /dev/null 2>&1 || true
TOTAL=$((TOTAL + 1))
if [ -f "$DEBUG_LOG" ] && grep -q "tool=Bash" "$DEBUG_LOG"; then
  PASS=$((PASS + 1))
  printf "  ${GREEN}✓${RESET} DEBUG=1 시 로그 파일에 기록됨\n"
else
  FAIL=$((FAIL + 1))
  printf "  ${RED}✗${RESET} DEBUG=1 시 로그 파일에 기록 안됨\n"
fi

# 10-2: LEAN_KIT_DEBUG=0 시 로그 기록 안됨
rm -f "$DEBUG_LOG"
env LEAN_KIT_AUTO_PERMIT=1 LEAN_KIT_PERMIT_CONF="$NONEXISTENT_CONF" LEAN_KIT_DEBUG=0 \
    bash "$SCRIPT_UNDER_TEST" <<< "$(bash_json 'ls')" > /dev/null 2>&1 || true
TOTAL=$((TOTAL + 1))
if [ ! -f "$DEBUG_LOG" ]; then
  PASS=$((PASS + 1))
  printf "  ${GREEN}✓${RESET} DEBUG=0 시 로그 파일에 기록 안됨\n"
else
  FAIL=$((FAIL + 1))
  printf "  ${RED}✗${RESET} DEBUG=0 시 로그 파일에 기록됨 (예상: 기록 안됨)\n"
fi

# 로그 복원
rm -f "$DEBUG_LOG"
if [ -f "${DEBUG_LOG}.bak.$$" ]; then
  mv "${DEBUG_LOG}.bak.$$" "$DEBUG_LOG"
fi

# === 결과 요약 ===
printf "\n${BOLD}════════════════════════════════════════${RESET}\n"
printf "${BOLD}결과: ${GREEN}%d 통과${RESET} / ${RED}%d 실패${RESET} / 총 %d개\n" "$PASS" "$FAIL" "$TOTAL"
printf "${BOLD}════════════════════════════════════════${RESET}\n"

if [ "$FAIL" -gt 0 ]; then
  printf "${RED}${BOLD}FAIL${RESET} - %d개 테스트 실패\n" "$FAIL"
else
  printf "${GREEN}${BOLD}ALL PASSED${RESET}\n"
fi

exit "$FAIL"
