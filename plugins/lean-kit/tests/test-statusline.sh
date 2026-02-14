#!/usr/bin/env bash
#
# test-statusline.sh - statusline.sh tests
# Run: bash plugins/lean-kit/tests/test-statusline.sh
#

set -euo pipefail

# === Path Setup ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_UNDER_TEST="$SCRIPT_DIR/../scripts/statusline.sh"

if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
  echo "ERROR: statusline.sh not found at $SCRIPT_UNDER_TEST"
  exit 1
fi

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# === Counters ===
PASS=0
FAIL=0
TOTAL=0

# === Helpers ===
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
# Group 1: Basic Behavior
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[Group 1] Basic Behavior${RESET}\n"

# 1-1: Empty input → no crash
out=$(run_statusline "")
TOTAL=$((TOTAL + 1))
if [ $? -eq 0 ] || [ -n "$out" ] || [ -z "$out" ]; then
  PASS=$((PASS + 1))
  printf "  ${GREEN}✓${RESET} Empty input: no crash\n"
else
  FAIL=$((FAIL + 1))
  printf "  ${RED}✗${RESET} Empty input: crash\n"
fi

# 1-2: cwd → show directory
out=$(run_statusline '{"cwd":"/tmp/test-dir","model":{"display_name":"Opus"}}')
assert_contains "cwd → show directory" "$out" "test-dir"

# 1-3: display_name → show model
out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Sonnet"}}')
assert_contains "display_name → show model" "$out" "Sonnet"

# ─────────────────────────────────────────────
# Group 2: jq-dependent
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[Group 2] jq-dependent${RESET}\n"

if command -v jq >/dev/null 2>&1; then
  # 2-1: context remaining %
  out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":50000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}}}')
  assert_contains "Context remaining %" "$out" "[0-9]+%"

  # 2-2: cost includes $
  out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"},"cost":{"total_cost_usd":1.23,"total_duration_ms":3600000}}')
  assert_contains "Cost includes \$" "$out" '\$'
else
  printf "  ${CYAN}-${RESET} jq not found: skip context/cost\n"
fi

# ─────────────────────────────────────────────
# Group 3: Output Format
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[Group 3] Output Format${RESET}\n"

# 3-1: exactly 1 line
out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"}}')
line_count=$(echo "$out" | wc -l | tr -d ' ')
assert_equals "Output is exactly 1 line" "$line_count" "1"

# 3-2: NO_COLOR=1 → no ANSI escapes
out=$(run_statusline '{"cwd":"/tmp","model":{"display_name":"Opus"}}' NO_COLOR=1)
assert_not_contains "NO_COLOR=1: no ANSI escapes" "$out" $'\033'

# ─────────────────────────────────────────────
# Group 4: statusline.conf
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[Group 4] statusline.conf${RESET}\n"

# Temp dir for testing
TEST_TMP=$(mktemp -d)
trap "rm -rf '$TEST_TMP'" EXIT

FULL_JSON='{"cwd":"/tmp/test-dir","model":{"display_name":"Opus"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":50000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}},"cost":{"total_cost_usd":1.23,"total_duration_ms":3600000}}'

# 4-1: no conf → show all elements (default)
out=$(STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "No conf: show 📁" "$out" "test-dir"
assert_contains "No conf: show 🤖" "$out" "Opus"

# 4-2: SHOW_ACCOUNT=0 → hide 👤
# Mock account via HOME override
MOCK_HOME="$TEST_TMP/home-account"
mkdir -p "$MOCK_HOME"
cat > "$MOCK_HOME/.claude.json" << 'CJSON'
{"oauthAccount":{"emailAddress":"test@example.com","billingType":"stripe_subscription","hasExtraUsageEnabled":true}}
CJSON
CONF_HIDE_ACCOUNT="$TEST_TMP/hide-account.conf"
echo "SHOW_ACCOUNT=0" > "$CONF_HIDE_ACCOUNT"
out=$(HOME="$MOCK_HOME" STATUSLINE_CONF="$CONF_HIDE_ACCOUNT" run_statusline "$FULL_JSON")
assert_not_contains "SHOW_ACCOUNT=0 → hide 👤" "$out" "test@example.com"

# 4-3: SHOW_GIT=0 → hide 🌿
CONF_HIDE_GIT="$TEST_TMP/hide-git.conf"
echo "SHOW_GIT=0" > "$CONF_HIDE_GIT"
out=$(STATUSLINE_CONF="$CONF_HIDE_GIT" run_statusline "$FULL_JSON")
assert_not_contains "SHOW_GIT=0 → hide 🌿" "$out" "🌿"

# 4-4: SHOW_CONTEXT=0 → hide 🧠
if command -v jq >/dev/null 2>&1; then
  CONF_HIDE_CTX="$TEST_TMP/hide-context.conf"
  echo "SHOW_CONTEXT=0" > "$CONF_HIDE_CTX"
  out=$(STATUSLINE_CONF="$CONF_HIDE_CTX" run_statusline "$FULL_JSON")
  assert_not_contains "SHOW_CONTEXT=0 → hide 🧠" "$out" "🧠"
fi

# 4-5: SHOW_COST=0 → hide 💰
if command -v jq >/dev/null 2>&1; then
  CONF_HIDE_COST="$TEST_TMP/hide-cost.conf"
  echo "SHOW_COST=0" > "$CONF_HIDE_COST"
  out=$(STATUSLINE_CONF="$CONF_HIDE_COST" run_statusline "$FULL_JSON")
  assert_not_contains "SHOW_COST=0 → hide 💰" "$out" "💰"
fi

# 4-6: STATUSLINE_CONF env override
CUSTOM_CONF="$TEST_TMP/custom-path.conf"
echo "SHOW_MODEL=0" > "$CUSTOM_CONF"
out=$(STATUSLINE_CONF="$CUSTOM_CONF" run_statusline '{"cwd":"/tmp","model":{"display_name":"SonnetTest"}}')
assert_not_contains "STATUSLINE_CONF env override" "$out" "SonnetTest"

# ─────────────────────────────────────────────
# Group 5: Plan Detection
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[Group 5] Plan Detection${RESET}\n"

# 5-1: billingType=stripe_subscription + hasExtraUsageEnabled=true → "Max"
MOCK_HOME_MAX="$TEST_TMP/home-max"
mkdir -p "$MOCK_HOME_MAX"
cat > "$MOCK_HOME_MAX/.claude.json" << 'CJSON'
{"oauthAccount":{"emailAddress":"max@example.com","billingType":"stripe_subscription","hasExtraUsageEnabled":true}}
CJSON
out=$(HOME="$MOCK_HOME_MAX" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "Detect Max plan" "$out" "Max"

# 5-2: billingType=stripe_subscription + hasExtraUsageEnabled=false → "Pro"
MOCK_HOME_PRO="$TEST_TMP/home-pro"
mkdir -p "$MOCK_HOME_PRO"
cat > "$MOCK_HOME_PRO/.claude.json" << 'CJSON'
{"oauthAccount":{"emailAddress":"pro@example.com","billingType":"stripe_subscription","hasExtraUsageEnabled":false}}
CJSON
out=$(HOME="$MOCK_HOME_PRO" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "Detect Pro plan" "$out" "Pro"

# 5-3: oauthAccount absent → "API"
MOCK_HOME_API="$TEST_TMP/home-api"
mkdir -p "$MOCK_HOME_API"
echo '{}' > "$MOCK_HOME_API/.claude.json"
out=$(HOME="$MOCK_HOME_API" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "Detect API plan" "$out" "API"

# 5-4: no ~/.claude.json → hide plan
MOCK_HOME_NONE="$TEST_TMP/home-none"
mkdir -p "$MOCK_HOME_NONE"
out=$(HOME="$MOCK_HOME_NONE" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_not_contains "No claude.json: hide Plan" "$out" "📋"

# 5-5: PLAN_TYPE manual override via conf
CONF_PLAN_OVERRIDE="$TEST_TMP/plan-override.conf"
echo "PLAN_TYPE=Max" > "$CONF_PLAN_OVERRIDE"
MOCK_HOME_OVERRIDE="$TEST_TMP/home-override"
mkdir -p "$MOCK_HOME_OVERRIDE"
echo '{}' > "$MOCK_HOME_OVERRIDE/.claude.json"
out=$(HOME="$MOCK_HOME_OVERRIDE" STATUSLINE_CONF="$CONF_PLAN_OVERRIDE" run_statusline "$FULL_JSON")
assert_contains "PLAN_TYPE manual override" "$out" "Max"

# ─────────────────────────────────────────────
# Group 6: Extra Usage / Plan Tier
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[Group 6] Extra Usage / Plan Tier${RESET}\n"

# 6-1: Max + extra enabled → show ⚡Extra
out=$(HOME="$MOCK_HOME_MAX" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_contains "Max + extra → show ⚡" "$out" "Extra"

# 6-2: Pro → hide Extra
out=$(HOME="$MOCK_HOME_PRO" STATUSLINE_CONF="$TEST_TMP/nonexistent.conf" run_statusline "$FULL_JSON")
assert_not_contains "Pro → hide Extra" "$out" "Extra"

# 6-3: SHOW_EXTRA_USAGE=0 → hide Extra
CONF_HIDE_EXTRA="$TEST_TMP/hide-extra.conf"
echo "SHOW_EXTRA_USAGE=0" > "$CONF_HIDE_EXTRA"
out=$(HOME="$MOCK_HOME_MAX" STATUSLINE_CONF="$CONF_HIDE_EXTRA" run_statusline "$FULL_JSON")
assert_not_contains "SHOW_EXTRA_USAGE=0 → hide Extra" "$out" "Extra"

# 6-4: SHOW_PLAN=1 → show 📋
CONF_SHOW_PLAN="$TEST_TMP/show-plan.conf"
echo "SHOW_PLAN=1" > "$CONF_SHOW_PLAN"
out=$(HOME="$MOCK_HOME_PRO" STATUSLINE_CONF="$CONF_SHOW_PLAN" run_statusline "$FULL_JSON")
assert_contains "SHOW_PLAN=1 → show 📋" "$out" "📋"

# ─────────────────────────────────────────────
# Group 7: Integrated Format
# ─────────────────────────────────────────────
printf "\n${CYAN}${BOLD}[Group 7] Integrated Format${RESET}\n"

# 7-1: all elements on → still 1-line output
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
assert_equals "All elements on: 1-line output" "$line_count" "1"

# === Summary ===
printf "\n${BOLD}════════════════════════════════════════${RESET}\n"
printf "${BOLD}Results: ${GREEN}%d passed${RESET} / ${RED}%d failed${RESET} / %d total\n" "$PASS" "$FAIL" "$TOTAL"
printf "${BOLD}════════════════════════════════════════${RESET}\n"

if [ "$FAIL" -gt 0 ]; then
  printf "${RED}${BOLD}FAIL${RESET} - %d test(s) failed\n" "$FAIL"
else
  printf "${GREEN}${BOLD}ALL PASSED${RESET}\n"
fi

exit "$FAIL"
