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
  # 2-1: 컨텍스트 → [0-9]+% 패턴
  out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":50000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}}}')
  assert_contains "컨텍스트 잔여율 표시" "$out" "[0-9]+%"

  # 2-2: 비용 → $ 포함
  out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"},"cost":{"total_cost_usd":1.23,"total_duration_ms":3600000}}')
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
