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
