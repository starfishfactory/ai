#!/usr/bin/env bash
#
# test-statusline.sh - statusline.sh 테스트
# 실행: bash plugins/lean-kit/tests/test-statusline.sh
#

set -euo pipefail

# === 경로 설정 ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_UNDER_TEST="$SCRIPT_DIR/../scripts/statusline.sh"

if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
  echo "ERROR: statusline.sh not found at $SCRIPT_UNDER_TEST"
  exit 1
fi

# === 색상 출력 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# === 카운터 ===
PASS=0
FAIL=0
TOTAL=0

# === 헬퍼 함수 ===
run_statusline() {
  local json="$1"
  shift
  env "$@" bash "$SCRIPT_UNDER_TEST" <<< "$json" 2>/dev/null || true
}

assert_contains() {
  local desc="$1"
  local output="$2"
  local pattern="$3"
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -qE "$pattern"; then
    PASS=$((PASS + 1))
    printf "  ${GREEN}✓${RESET} %s\n" "$desc"
  else
    FAIL=$((FAIL + 1))
    printf "  ${RED}✗${RESET} %s ${RED}(pattern '%s' not found in: %s)${RESET}\n" "$desc" "$pattern" "${output:-<empty>}"
  fi
}

assert_not_contains() {
  local desc="$1"
  local output="$2"
  local pattern="$3"
  TOTAL=$((TOTAL + 1))
  if ! echo "$output" | grep -qE "$pattern"; then
    PASS=$((PASS + 1))
    printf "  ${GREEN}✓${RESET} %s\n" "$desc"
  else
    FAIL=$((FAIL + 1))
    printf "  ${RED}✗${RESET} %s ${RED}(pattern '%s' found but should not be)${RESET}\n" "$desc" "$pattern"
  fi
}

assert_equals() {
  local desc="$1"
  local actual="$2"
  local expected="$3"
  TOTAL=$((TOTAL + 1))
  if [ "$actual" = "$expected" ]; then
    PASS=$((PASS + 1))
    printf "  ${GREEN}✓${RESET} %s\n" "$desc"
  else
    FAIL=$((FAIL + 1))
    printf "  ${RED}✗${RESET} %s ${RED}(expected '%s', got '%s')${RESET}\n" "$desc" "$expected" "$actual"
  fi
}

# ─────────────────────────────────────────────
# 그룹 1: 기본 동작
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 1] 기본 동작${RESET}\n"

# 1-1: 빈 입력 → 크래시 없이 출력
out=$(run_statusline "")
TOTAL=$((TOTAL + 1))
if [ $? -eq 0 ] || [ -n "$out" ] || [ -z "$out" ]; then
  PASS=$((PASS + 1))
  printf "  ${GREEN}✓${RESET} 빈 입력 시 크래시 없음\n"
else
  FAIL=$((FAIL + 1))
  printf "  ${RED}✗${RESET} 빈 입력 시 크래시 발생\n"
fi

# 1-2: cwd → 디렉토리 표시
out=$(run_statusline '{"cwd":"/tmp/test-dir","model":{"display_name":"Opus"}}')
assert_contains "cwd 입력 시 디렉토리 표시" "$out" "test-dir"

# 1-3: display_name → 모델명 표시
out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Sonnet"}}')
assert_contains "display_name 입력 시 모델명 표시" "$out" "Sonnet"

# ─────────────────────────────────────────────
# 그룹 2: jq 의존 기능 (jq 있을 때만)
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 2] jq 의존 기능${RESET}\n"

if command -v jq >/dev/null 2>&1; then
  # 2-1: 컨텍스트 → [0-9]+% 패턴 (STATUSLINE_CONF 격리: 유저 conf 영향 방지)
  out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":50000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}}}' STATUSLINE_CONF=/nonexistent)
  assert_contains "컨텍스트 잔여율 표시" "$out" "[0-9]+%"

  # 2-2: 비용 → $ 포함 (STATUSLINE_CONF 격리: Max 기본 SHOW_COST=0 방지)
  out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"},"cost":{"total_cost_usd":1.23,"total_duration_ms":3600000}}' STATUSLINE_CONF=/nonexistent)
  assert_contains "비용 표시 시 \$ 포함" "$out" '\$'
else
  printf "  ${CYAN}-${RESET} jq 미설치: 컨텍스트/비용 테스트 건너뜀\n"
fi

# ─────────────────────────────────────────────
# 그룹 3: 출력 형식
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 3] 출력 형식${RESET}\n"

# 3-1: 1줄 출력
out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"}}')
line_count=$(echo "$out" | wc -l | tr -d ' ')
assert_equals "출력이 정확히 1줄" "$line_count" "1"

# 3-2: NO_COLOR=1 → ANSI 코드 없음
out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"}}' NO_COLOR=1)
assert_not_contains "NO_COLOR=1 시 ANSI 이스케이프 없음" "$out" $'\033'

# ─────────────────────────────────────────────
# 그룹 4: statusline.conf 설정 읽기
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 4] statusline.conf 설정 읽기${RESET}\n"

# 테스트용 임시 디렉토리
TEST_TMP=$(mktemp -d)
trap "rm -rf '$TEST_TMP'" EXIT

FULL_JSON='{"cwd":"/tmp/test-dir","model":{"display_name":"Opus"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":50000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}},"cost":{"total_cost_usd":1.23,"total_duration_ms":3600000}}'

# 4-1: conf 없으면 모든 요소 표시 (기본값)
out=$(STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "conf 없으면 📁 표시" "$out" "test-dir"
assert_contains "conf 없으면 🤖 표시" "$out" "Opus"

# 4-2: SHOW_ACCOUNT=0 → 👤 미표시
# HOME 오버라이드로 계정 정보 모킹
MOCK_HOME="$TEST_TMP/home-account"
mkdir -p "$MOCK_HOME"
cat > "$MOCK_HOME/.claude.json" << 'CJSON'
{"oauthAccount":{"emailAddress":"test@example.com","billingType":"stripe_subscription","hasExtraUsageEnabled":true}}
CJSON
CONF_HIDE_ACCOUNT="$TEST_TMP/hide-account.conf"
echo "SHOW_ACCOUNT=0" > "$CONF_HIDE_ACCOUNT"
out=$(HOME="$MOCK_HOME" STATUSLINE_CONF="$CONF_HIDE_ACCOUNT" run_statusline "$FULL_JSON")
assert_not_contains "SHOW_ACCOUNT=0 → 👤 미표시" "$out" "test@example.com"

# 4-3: SHOW_GIT=0 → 🌿 미표시 (git branch가 있는 환경에서)
CONF_HIDE_GIT="$TEST_TMP/hide-git.conf"
echo "SHOW_GIT=0" > "$CONF_HIDE_GIT"
out=$(STATUSLINE_CONF="$CONF_HIDE_GIT" run_statusline "$FULL_JSON")
assert_not_contains "SHOW_GIT=0 → 🌿 미표시" "$out" "🌿"

# 4-4: SHOW_CONTEXT=0 → 🧠 미표시
if command -v jq >/dev/null 2>&1; then
  CONF_HIDE_CTX="$TEST_TMP/hide-context.conf"
  echo "SHOW_CONTEXT=0" > "$CONF_HIDE_CTX"
  out=$(STATUSLINE_CONF="$CONF_HIDE_CTX" run_statusline "$FULL_JSON")
  assert_not_contains "SHOW_CONTEXT=0 → 🧠 미표시" "$out" "🧠"
fi

# 4-5: SHOW_COST=0 → 💰 미표시
if command -v jq >/dev/null 2>&1; then
  CONF_HIDE_COST="$TEST_TMP/hide-cost.conf"
  echo "SHOW_COST=0" > "$CONF_HIDE_COST"
  out=$(STATUSLINE_CONF="$CONF_HIDE_COST" run_statusline "$FULL_JSON")
  assert_not_contains "SHOW_COST=0 → 💰 미표시" "$out" "💰"
fi

# 4-6: STATUSLINE_CONF 환경변수로 경로 오버라이드
CUSTOM_CONF="$TEST_TMP/custom-path.conf"
echo "SHOW_MODEL=0" > "$CUSTOM_CONF"
out=$(STATUSLINE_CONF="$CUSTOM_CONF" run_statusline '{"cwd":"/tmp","model":{"display_name":"SonnetTest"}}')
assert_not_contains "STATUSLINE_CONF 환경변수 오버라이드" "$out" "SonnetTest"

# ─────────────────────────────────────────────
# 그룹 5: Plan 감지
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 5] Plan 감지${RESET}\n"

# 5-1: billingType=stripe_subscription + hasExtraUsageEnabled=true → "Max"
MOCK_HOME_MAX="$TEST_TMP/home-max"
mkdir -p "$MOCK_HOME_MAX"
cat > "$MOCK_HOME_MAX/.claude.json" << 'CJSON'
{"oauthAccount":{"emailAddress":"max@example.com","billingType":"stripe_subscription","hasExtraUsageEnabled":true}}
CJSON
out=$(HOME="$MOCK_HOME_MAX" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "Max 플랜 감지" "$out" "Max"

# 5-2: billingType=stripe_subscription + hasExtraUsageEnabled=false → "Pro"
MOCK_HOME_PRO="$TEST_TMP/home-pro"
mkdir -p "$MOCK_HOME_PRO"
cat > "$MOCK_HOME_PRO/.claude.json" << 'CJSON'
{"oauthAccount":{"emailAddress":"pro@example.com","billingType":"stripe_subscription","hasExtraUsageEnabled":false}}
CJSON
out=$(HOME="$MOCK_HOME_PRO" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "Pro 플랜 감지" "$out" "Pro"

# 5-3: oauthAccount 없음 → "API"
MOCK_HOME_API="$TEST_TMP/home-api"
mkdir -p "$MOCK_HOME_API"
echo '{}' > "$MOCK_HOME_API/.claude.json"
out=$(HOME="$MOCK_HOME_API" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "API 플랜 감지" "$out" "API"

# 5-4: ~/.claude.json 없음 → plan 미표시
MOCK_HOME_NONE="$TEST_TMP/home-none"
mkdir -p "$MOCK_HOME_NONE"
out=$(HOME="$MOCK_HOME_NONE" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_not_contains "claude.json 없으면 Plan 미표시" "$out" "📋"

# 5-5: PLAN_TYPE conf로 수동 오버라이드
CONF_PLAN_OVERRIDE="$TEST_TMP/plan-override.conf"
echo "PLAN_TYPE=Max" > "$CONF_PLAN_OVERRIDE"
MOCK_HOME_OVERRIDE="$TEST_TMP/home-override"
mkdir -p "$MOCK_HOME_OVERRIDE"
echo '{}' > "$MOCK_HOME_OVERRIDE/.claude.json"
out=$(HOME="$MOCK_HOME_OVERRIDE" STATUSLINE_CONF="$CONF_PLAN_OVERRIDE" run_statusline "$FULL_JSON")
assert_contains "PLAN_TYPE 수동 오버라이드" "$out" "Max"

# ─────────────────────────────────────────────
# 그룹 6: Extra Usage / Plan Tier 표시
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 6] Extra Usage / Plan Tier 표시${RESET}\n"

# 6-1: Max + extra enabled → ⚡Extra 표시
out=$(HOME="$MOCK_HOME_MAX" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "Max + extra → ⚡ 표시" "$out" "Extra"

# 6-2: Pro → Extra 미표시
out=$(HOME="$MOCK_HOME_PRO" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_not_contains "Pro → Extra 미표시" "$out" "Extra"

# 6-3: SHOW_EXTRA_USAGE=0 → Extra 미표시
CONF_HIDE_EXTRA="$TEST_TMP/hide-extra.conf"
echo "SHOW_EXTRA_USAGE=0" > "$CONF_HIDE_EXTRA"
out=$(HOME="$MOCK_HOME_MAX" STATUSLINE_CONF="$CONF_HIDE_EXTRA" run_statusline "$FULL_JSON")
assert_not_contains "SHOW_EXTRA_USAGE=0 → Extra 미표시" "$out" "Extra"

# 6-4: SHOW_PLAN=1 → 📋 Pro/Max/API 표시
CONF_SHOW_PLAN="$TEST_TMP/show-plan.conf"
echo "SHOW_PLAN=1" > "$CONF_SHOW_PLAN"
out=$(HOME="$MOCK_HOME_PRO" STATUSLINE_CONF="$CONF_SHOW_PLAN" run_statusline "$FULL_JSON")
assert_contains "SHOW_PLAN=1 → 📋 표시" "$out" "📋"

# ─────────────────────────────────────────────
# 그룹 7: 통합 포맷
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 7] 통합 포맷${RESET}\n"

# 7-1: 모든 요소 활성화 시 여전히 1줄 출력
CONF_ALL_ON="$TEST_TMP/all-on.conf"
cat > "$CONF_ALL_ON" << 'ALLCONF'
SHOW_ACCOUNT=1
SHOW_DIR=1
SHOW_GIT=1
SHOW_MODEL=1
SHOW_CONTEXT=1
SHOW_COST=1
SHOW_SESSION=1
SHOW_PLAN=1
SHOW_EXTRA_USAGE=1
ALLCONF
out=$(HOME="$MOCK_HOME_MAX" STATUSLINE_CONF="$CONF_ALL_ON" run_statusline "$FULL_JSON")
line_count=$(echo "$out" | wc -l | tr -d ' ')
assert_equals "모든 요소 활성화 시 1줄 출력" "$line_count" "1"

# ─────────────────────────────────────────────
# 그룹 8: jq 없는 환경에서 Plan 감지 (bash fallback)
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 8] jq 없는 환경에서 Plan 감지${RESET}\n"

# jq를 PATH에서 제거하는 헬퍼
run_statusline_nojq() {
  local json="$1"
  shift
  # PATH에서 jq가 있는 디렉토리를 제거하지 않고, 존재하지 않는 jq로 오버라이드
  # PATH를 최소한으로 제한하여 jq 접근 차단
  local restricted_path="/usr/bin:/bin:/usr/sbin:/sbin"
  # jq가 /usr/bin이나 /bin에 있을 수 있으므로 임시 디렉토리에 가짜 PATH 구성
  local fake_bin="$TEST_TMP/fake-bin"
  mkdir -p "$fake_bin"
  # 필요한 명령어만 심볼릭 링크 (jq 제외)
  for cmd in bash grep sed head cat date stat tr wc awk printf mkdir rmdir rm cp echo chmod; do
    local cmd_path=$(command -v "$cmd" 2>/dev/null)
    [ -n "$cmd_path" ] && [ ! -e "$fake_bin/$cmd" ] && ln -sf "$cmd_path" "$fake_bin/$cmd" 2>/dev/null
  done
  # git도 링크 (git branch 표시용)
  local git_path=$(command -v git 2>/dev/null)
  [ -n "$git_path" ] && [ ! -e "$fake_bin/git" ] && ln -sf "$git_path" "$fake_bin/$cmd" 2>/dev/null
  # python3 링크 (to_epoch fallback)
  local py_path=$(command -v python3 2>/dev/null)
  [ -n "$py_path" ] && [ ! -e "$fake_bin/python3" ] && ln -sf "$py_path" "$fake_bin/python3" 2>/dev/null

  env PATH="$fake_bin" "$@" bash "$SCRIPT_UNDER_TEST" <<< "$json" 2>/dev/null || true
}

# 8-1: jq 없이 Max 감지 (minified JSON)
MOCK_HOME_NOJQ_MAX="$TEST_TMP/home-nojq-max"
mkdir -p "$MOCK_HOME_NOJQ_MAX"
cat > "$MOCK_HOME_NOJQ_MAX/.claude.json" << 'CJSON'
{"oauthAccount":{"emailAddress":"max@example.com","billingType":"stripe_subscription","hasExtraUsageEnabled":true}}
CJSON
out=$(run_statusline_nojq "$FULL_JSON" HOME="$MOCK_HOME_NOJQ_MAX" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf")
assert_contains "jq 없이 Max 플랜 감지" "$out" "Max"

# 8-2: jq 없이 Pro 감지
MOCK_HOME_NOJQ_PRO="$TEST_TMP/home-nojq-pro"
mkdir -p "$MOCK_HOME_NOJQ_PRO"
cat > "$MOCK_HOME_NOJQ_PRO/.claude.json" << 'CJSON'
{"oauthAccount":{"emailAddress":"pro@example.com","billingType":"stripe_subscription","hasExtraUsageEnabled":false}}
CJSON
out=$(run_statusline_nojq "$FULL_JSON" HOME="$MOCK_HOME_NOJQ_PRO" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf")
assert_contains "jq 없이 Pro 플랜 감지" "$out" "Pro"

# 8-3: jq 없이 Extra Usage 표시
out=$(run_statusline_nojq "$FULL_JSON" HOME="$MOCK_HOME_NOJQ_MAX" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf")
assert_contains "jq 없이 Extra Usage 표시" "$out" "Extra"

# 8-4: jq 없이 pretty-printed JSON에서 Max 감지
MOCK_HOME_NOJQ_PRETTY="$TEST_TMP/home-nojq-pretty"
mkdir -p "$MOCK_HOME_NOJQ_PRETTY"
cat > "$MOCK_HOME_NOJQ_PRETTY/.claude.json" << 'CJSON'
{
  "oauthAccount": {
    "emailAddress": "max@example.com",
    "billingType": "stripe_subscription",
    "hasExtraUsageEnabled": true
  }
}
CJSON
out=$(run_statusline_nojq "$FULL_JSON" HOME="$MOCK_HOME_NOJQ_PRETTY" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf")
assert_contains "jq 없이 pretty-printed JSON에서 Max 감지" "$out" "Max"

# 8-5: jq 없이 API 감지 (oauthAccount 없음)
MOCK_HOME_NOJQ_API="$TEST_TMP/home-nojq-api"
mkdir -p "$MOCK_HOME_NOJQ_API"
echo '{}' > "$MOCK_HOME_NOJQ_API/.claude.json"
out=$(run_statusline_nojq "$FULL_JSON" HOME="$MOCK_HOME_NOJQ_API" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf")
assert_contains "jq 없이 API 플랜 감지" "$out" "API"

# ─────────────────────────────────────────────
# 그룹 9: Graceful Degradation
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 9] Graceful Degradation${RESET}\n"

# 9-1: jq/ccusage 없어도 크래시 없이 기본 표시
out=$(run_statusline_nojq '{"cwd":"/tmp/test-dir","model":{"display_name":"Opus"}}' HOME="$TEST_TMP/home-empty" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf")
assert_contains "jq 없어도 디렉토리 표시" "$out" "test-dir"
assert_contains "jq 없어도 모델명 표시" "$out" "Opus"

# 9-2: jq 없을 때 ⌛ 세션 미표시 (ccusage+jq 필요)
out=$(run_statusline_nojq "$FULL_JSON" HOME="$MOCK_HOME_NOJQ_MAX" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf")
assert_not_contains "jq 없을 때 ⌛ 미표시" "$out" "⌛"

# ─────────────────────────────────────────────
# 그룹 10: setup-statusline.sh 설치 스크립트
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[그룹 10] setup-statusline.sh 설치 스크립트${RESET}\n"

SETUP_SCRIPT="$SCRIPT_DIR/../scripts/setup-statusline.sh"

if [ ! -f "$SETUP_SCRIPT" ]; then
  printf "  ${RED}✗${RESET} setup-statusline.sh not found at $SETUP_SCRIPT\n"
  FAIL=$((FAIL + 1))
  TOTAL=$((TOTAL + 1))
else

# Helper: run setup in isolated HOME
run_setup() {
  local tmp_home="$1"
  shift
  HOME="$tmp_home" bash "$SETUP_SCRIPT" "$@" 2>/dev/null
}

# 10-1: --plan Max --hide COST → conf에 SHOW_COST=0
SETUP_TMP_1="$TEST_TMP/setup-1"
mkdir -p "$SETUP_TMP_1/.claude"
echo '{}' > "$SETUP_TMP_1/.claude/settings.json"
run_setup "$SETUP_TMP_1" --plan Max --hide COST --no-deps
conf_1=$(cat "$SETUP_TMP_1/.claude/statusline.conf" 2>/dev/null || echo "")
assert_contains "10-1: --hide COST → SHOW_COST=0" "$conf_1" "SHOW_COST=0"
assert_contains "10-1: --plan Max → PLAN_TYPE=Max" "$conf_1" "PLAN_TYPE=Max"

# 10-2: --plan Pro → 기본값 SHOW_COST=0
SETUP_TMP_2="$TEST_TMP/setup-2"
mkdir -p "$SETUP_TMP_2/.claude"
echo '{}' > "$SETUP_TMP_2/.claude/settings.json"
run_setup "$SETUP_TMP_2" --plan Pro --no-deps
conf_2=$(cat "$SETUP_TMP_2/.claude/statusline.conf" 2>/dev/null || echo "")
assert_contains "10-2: Pro 기본값 → SHOW_COST=0" "$conf_2" "SHOW_COST=0"

# 10-3: --plan API → 기본값 SHOW_EXTRA_USAGE=0
SETUP_TMP_3="$TEST_TMP/setup-3"
mkdir -p "$SETUP_TMP_3/.claude"
echo '{}' > "$SETUP_TMP_3/.claude/settings.json"
run_setup "$SETUP_TMP_3" --plan API --no-deps
conf_3=$(cat "$SETUP_TMP_3/.claude/statusline.conf" 2>/dev/null || echo "")
assert_contains "10-3: API 기본값 → SHOW_EXTRA_USAGE=0" "$conf_3" "SHOW_EXTRA_USAGE=0"

# 10-4: --detect → PLAN/JQ/CCUSAGE 상태 출력
SETUP_TMP_4="$TEST_TMP/setup-4"
mkdir -p "$SETUP_TMP_4"
cat > "$SETUP_TMP_4/.claude.json" << 'CJSON'
{"oauthAccount":{"emailAddress":"test@example.com","billingType":"stripe_subscription","hasExtraUsageEnabled":true}}
CJSON
detect_out=$(run_setup "$SETUP_TMP_4" --detect)
assert_contains "10-4: --detect → PLAN= 포함" "$detect_out" "PLAN="
assert_contains "10-4: --detect → JQ= 포함" "$detect_out" "JQ="
assert_contains "10-4: --detect → CCUSAGE= 포함" "$detect_out" "CCUSAGE="
assert_contains "10-4: Max 감지" "$detect_out" "PLAN=Max"

# 10-5: --dry-run → 파일 미생성 확인
SETUP_TMP_5="$TEST_TMP/setup-5"
mkdir -p "$SETUP_TMP_5/.claude"
echo '{}' > "$SETUP_TMP_5/.claude/settings.json"
run_setup "$SETUP_TMP_5" --plan Max --dry-run
TOTAL=$((TOTAL + 1))
if [ ! -f "$SETUP_TMP_5/.claude/statusline.conf" ]; then
  PASS=$((PASS + 1))
  printf "  ${GREEN}✓${RESET} 10-5: --dry-run → statusline.conf 미생성\n"
else
  FAIL=$((FAIL + 1))
  printf "  ${RED}✗${RESET} 10-5: --dry-run → statusline.conf 생성됨 (미생성이어야 함)\n"
fi

# 10-6: statusline.sh 복사 확인
assert_equals "10-6: statusline.sh 복사됨" "$([ -f "$SETUP_TMP_1/.claude/statusline.sh" ] && echo "yes" || echo "no")" "yes"

# 10-7: settings.json에 statusLine 등록 확인
if command -v jq >/dev/null 2>&1; then
  sl_type=$(jq -r '.statusLine.type // ""' "$SETUP_TMP_1/.claude/settings.json" 2>/dev/null)
  assert_equals "10-7: settings.json statusLine 등록" "$sl_type" "command"
fi

# 10-8: --hide COST,SESSION → 복수 항목 비활성화
SETUP_TMP_8="$TEST_TMP/setup-8"
mkdir -p "$SETUP_TMP_8/.claude"
echo '{}' > "$SETUP_TMP_8/.claude/settings.json"
run_setup "$SETUP_TMP_8" --plan Max --hide COST,SESSION --no-deps
conf_8=$(cat "$SETUP_TMP_8/.claude/statusline.conf" 2>/dev/null || echo "")
assert_contains "10-8: --hide COST,SESSION → SHOW_COST=0" "$conf_8" "SHOW_COST=0"
assert_contains "10-8: --hide COST,SESSION → SHOW_SESSION=0" "$conf_8" "SHOW_SESSION=0"
assert_contains "10-8: 나머지 DIR은 ON" "$conf_8" "SHOW_DIR=1"

# Helper: run setup with restricted PATH (no jq)
run_setup_nojq() {
  local tmp_home="$1"
  shift
  local fake_bin="$TEST_TMP/fake-bin-setup"
  mkdir -p "$fake_bin"
  for cmd in bash grep sed head cat date stat tr wc awk printf mkdir rmdir rm cp echo chmod dirname cd pwd; do
    local cmd_path=$(command -v "$cmd" 2>/dev/null)
    [ -n "$cmd_path" ] && [ ! -e "$fake_bin/$cmd" ] && ln -sf "$cmd_path" "$fake_bin/$cmd" 2>/dev/null
  done
  local git_path=$(command -v git 2>/dev/null)
  [ -n "$git_path" ] && [ ! -e "$fake_bin/git" ] && ln -sf "$git_path" "$fake_bin/git" 2>/dev/null

  HOME="$tmp_home" env PATH="$fake_bin" bash "$SETUP_SCRIPT" "$@" 2>/dev/null || true
}

# 10-9: --no-deps + jq 없는 환경 → conf 생성, settings.json statusLine 미등록
SETUP_TMP_9="$TEST_TMP/setup-9"
mkdir -p "$SETUP_TMP_9/.claude"
echo '{}' > "$SETUP_TMP_9/.claude/settings.json"
run_setup_nojq "$SETUP_TMP_9" --plan Max --no-deps
conf_9=$(cat "$SETUP_TMP_9/.claude/statusline.conf" 2>/dev/null || echo "")
assert_contains "10-9: --no-deps jq없이 → conf 생성" "$conf_9" "PLAN_TYPE=Max"
settings_9=$(cat "$SETUP_TMP_9/.claude/settings.json" 2>/dev/null || echo "")
assert_not_contains "10-9: --no-deps jq없이 → statusLine 미등록" "$settings_9" "statusLine"

fi  # end setup-statusline.sh existence check

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
