#!/bin/bash
# Custom Claude Code statusline (1-line compact)
# Features: account, directory, git, model, context, burnrate, session
STATUSLINE_VERSION="3.0.0"

input=$(cat)

# ---- statusline.conf 읽기 (화이트리스트 기반) ----
SHOW_ACCOUNT=1
SHOW_DIR=1
SHOW_GIT=1
SHOW_MODEL=1
SHOW_CONTEXT=1
SHOW_COST=1
SHOW_SESSION=1
SHOW_PLAN=1
SHOW_EXTRA_USAGE=1
PLAN_TYPE=""

CONF_FILE="${STATUSLINE_CONF:-$HOME/.claude/statusline.conf}"
if [ -f "$CONF_FILE" ]; then
  while IFS='=' read -r key value; do
    # 주석과 빈 줄 건너뜀
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    key=$(echo "$key" | tr -d '[:space:]')
    value=$(echo "$value" | tr -d '[:space:]')
    case "$key" in
      SHOW_ACCOUNT)     [[ "$value" =~ ^[01]$ ]] && SHOW_ACCOUNT="$value" ;;
      SHOW_DIR)         [[ "$value" =~ ^[01]$ ]] && SHOW_DIR="$value" ;;
      SHOW_GIT)         [[ "$value" =~ ^[01]$ ]] && SHOW_GIT="$value" ;;
      SHOW_MODEL)       [[ "$value" =~ ^[01]$ ]] && SHOW_MODEL="$value" ;;
      SHOW_CONTEXT)     [[ "$value" =~ ^[01]$ ]] && SHOW_CONTEXT="$value" ;;
      SHOW_COST)        [[ "$value" =~ ^[01]$ ]] && SHOW_COST="$value" ;;
      SHOW_SESSION)     [[ "$value" =~ ^[01]$ ]] && SHOW_SESSION="$value" ;;
      SHOW_PLAN)        [[ "$value" =~ ^[01]$ ]] && SHOW_PLAN="$value" ;;
      SHOW_EXTRA_USAGE) [[ "$value" =~ ^[01]$ ]] && SHOW_EXTRA_USAGE="$value" ;;
      PLAN_TYPE)        [[ "$value" =~ ^(Pro|Max|API)$ ]] && PLAN_TYPE="$value" ;;
    esac
  done < "$CONF_FILE"
fi

# ---- check jq availability ----
HAS_JQ=0
if command -v jq >/dev/null 2>&1; then
  HAS_JQ=1
fi

# ---- color helpers (force colors for Claude Code) ----
use_color=1
[ -n "$NO_COLOR" ] && use_color=0

C() { if [ "$use_color" -eq 1 ]; then printf '\033[%sm' "$1"; fi; }
RST() { if [ "$use_color" -eq 1 ]; then printf '\033[0m'; fi; }

# ---- modern sleek colors ----
account_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;159m'; fi; } # light cyan
dir_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;117m'; fi; }    # sky blue
model_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;147m'; fi; }  # light purple
rst() { if [ "$use_color" -eq 1 ]; then printf '\033[0m'; fi; }

# ---- time helpers ----
to_epoch() {
  ts="$1"
  if command -v gdate >/dev/null 2>&1; then gdate -d "$ts" +%s 2>/dev/null && return; fi
  date -u -j -f "%Y-%m-%dT%H:%M:%S%z" "${ts/Z/+0000}" +%s 2>/dev/null && return
  python3 - "$ts" <<'PY' 2>/dev/null
import sys, datetime
s=sys.argv[1].replace('Z','+00:00')
print(int(datetime.datetime.fromisoformat(s).timestamp()))
PY
}

progress_bar() {
  pct="${1:-0}"; width="${2:-10}"
  [[ "$pct" =~ ^[0-9]+$ ]] || pct=0; ((pct<0))&&pct=0; ((pct>100))&&pct=100
  filled=$(( pct * width / 100 )); empty=$(( width - filled ))
  printf '%*s' "$filled" '' | tr ' ' '='
  printf '%*s' "$empty" '' | tr ' ' '-'
}

# git utilities
num_or_zero() { v="$1"; [[ "$v" =~ ^[0-9]+$ ]] && echo "$v" || echo 0; }

# ---- JSON extraction utilities ----
# Pure bash JSON value extractor (fallback when jq not available)
extract_json_string() {
  local json="$1"
  local key="$2"
  local default="${3:-}"

  # For nested keys like workspace.current_dir, get the last part
  local field="${key##*.}"
  field="${field%% *}"  # Remove any jq operators

  # Try to extract string value (quoted)
  local value=$(echo "$json" | grep -o "\"${field}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/')

  # Convert escaped backslashes to forward slashes for Windows paths
  if [ -n "$value" ]; then
    value=$(echo "$value" | sed 's/\\\\/\//g')
  fi

  # If no string value found, try to extract number value (unquoted)
  if [ -z "$value" ] || [ "$value" = "null" ]; then
    value=$(echo "$json" | grep -o "\"${field}\"[[:space:]]*:[[:space:]]*[0-9.]\+" | head -1 | sed 's/.*:[[:space:]]*\([0-9.]\+\).*/\1/')
  fi

  # Return value or default
  if [ -n "$value" ] && [ "$value" != "null" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

# ---- plan detection ----
detected_plan=""
extra_usage_enabled="false"
plan_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;245m'; fi; }  # default gray (API)
extra_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;220m'; fi; }  # bright gold

# Pure bash boolean extractor (true/false)
extract_json_bool() {
  local json="$1"
  local key="$2"
  local default="${3:-false}"
  local field="${key##*.}"
  local value=$(echo "$json" | grep -o "\"${field}\"[[:space:]]*:[[:space:]]*\(true\|false\)" | head -1 | sed 's/.*:[[:space:]]*\(true\|false\).*/\1/')
  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

# Plan detection from ~/.claude.json
if [ -n "$PLAN_TYPE" ]; then
  # conf에서 수동 오버라이드된 경우
  detected_plan="$PLAN_TYPE"
  # 수동 오버라이드 시 extra_usage_enabled도 claude.json에서 읽기 시도
  if [ -f "$HOME/.claude.json" ]; then
    if [ "$HAS_JQ" -eq 1 ]; then
      extra_usage_enabled=$(jq -r '.oauthAccount.hasExtraUsageEnabled // false' "$HOME/.claude.json" 2>/dev/null)
    else
      claude_json=$(cat "$HOME/.claude.json" 2>/dev/null)
      extra_usage_enabled=$(extract_json_bool "$claude_json" "hasExtraUsageEnabled" "false")
    fi
  fi
elif [ -f "$HOME/.claude.json" ]; then
  if [ "$HAS_JQ" -eq 1 ]; then
    billing_type=$(jq -r '.oauthAccount.billingType // ""' "$HOME/.claude.json" 2>/dev/null)
    extra_usage_enabled=$(jq -r '.oauthAccount.hasExtraUsageEnabled // false' "$HOME/.claude.json" 2>/dev/null)
    has_oauth=$(jq -r '.oauthAccount // empty' "$HOME/.claude.json" 2>/dev/null)
  else
    claude_json=$(cat "$HOME/.claude.json" 2>/dev/null)
    billing_type=$(extract_json_string "$claude_json" "billingType" "")
    extra_usage_enabled=$(extract_json_bool "$claude_json" "hasExtraUsageEnabled" "false")
    has_oauth=$(echo "$claude_json" | grep -o '"oauthAccount"' | head -1)
  fi

  if [ "$billing_type" = "stripe_subscription" ]; then
    if [ "$extra_usage_enabled" = "true" ]; then
      detected_plan="Max"
    else
      detected_plan="Pro"
    fi
  elif [ -n "$has_oauth" ] && [ "$has_oauth" != "null" ]; then
    detected_plan="Pro"
  else
    detected_plan="API"
  fi
fi

# Plan 색상 설정
case "$detected_plan" in
  Max) plan_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;183m'; fi; } ;;  # 연보라
  Pro) plan_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;111m'; fi; } ;;  # 파란
  API) plan_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;245m'; fi; } ;;  # 회색
esac

# ---- account email from Anthropic auth ----
account_email=""
if [ -f "$HOME/.claude.json" ]; then
  if [ "$HAS_JQ" -eq 1 ]; then
    account_email=$(jq -r '.oauthAccount.emailAddress // ""' "$HOME/.claude.json" 2>/dev/null)
  else
    account_email=$(extract_json_string "$(cat "$HOME/.claude.json" 2>/dev/null)" "emailAddress" "")
  fi
fi

# ---- basics ----
if [ "$HAS_JQ" -eq 1 ]; then
  current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "unknown"' 2>/dev/null | sed "s|^$HOME|~|g")
  model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"' 2>/dev/null)
  session_id=$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null)
else
  # Bash fallback for JSON extraction
  current_dir=$(echo "$input" | grep -o '"workspace"[[:space:]]*:[[:space:]]*{[^}]*"current_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | sed 's/\\\\/\//g')

  # Fall back to cwd if workspace extraction failed
  if [ -z "$current_dir" ] || [ "$current_dir" = "null" ]; then
    current_dir=$(echo "$input" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | sed 's/\\\\/\//g')
  fi

  # Fallback to unknown if all extraction failed
  [ -z "$current_dir" ] && current_dir="unknown"
  current_dir=$(echo "$current_dir" | sed "s|^$HOME|~|g")

  # Extract model name from nested model object
  model_name=$(echo "$input" | grep -o '"model"[[:space:]]*:[[:space:]]*{[^}]*"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  [ -z "$model_name" ] && model_name="Claude"

  session_id=$(extract_json_string "$input" "session_id" "")
fi

# ---- git colors ----
git_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;150m'; fi; }  # soft green

# ---- git ----
git_branch=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
fi

# ---- context window calculation (native) ----
context_pct=""
context_remaining_pct=""
context_color() { if [ "$use_color" -eq 1 ]; then printf '\033[1;37m'; fi; }  # default white

if [ "$HAS_JQ" -eq 1 ]; then
  # Get context window size and current usage from native Claude Code input
  CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000' 2>/dev/null)
  USAGE=$(echo "$input" | jq '.context_window.current_usage' 2>/dev/null)

  if [ "$USAGE" != "null" ] && [ -n "$USAGE" ]; then
    # Calculate current context from current_usage fields
    CURRENT_TOKENS=$(echo "$USAGE" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)' 2>/dev/null)

    if [ -n "$CURRENT_TOKENS" ] && [ "$CURRENT_TOKENS" -gt 0 ] 2>/dev/null; then
      context_used_pct=$(( CURRENT_TOKENS * 100 / CONTEXT_SIZE ))
      context_remaining_pct=$(( 100 - context_used_pct ))
      # Clamp to valid range
      (( context_remaining_pct < 0 )) && context_remaining_pct=0
      (( context_remaining_pct > 100 )) && context_remaining_pct=100

      # Set color based on remaining percentage
      if [ "$context_remaining_pct" -le 20 ]; then
        context_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;203m'; fi; }  # coral red
      elif [ "$context_remaining_pct" -le 40 ]; then
        context_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;215m'; fi; }  # peach
      else
        context_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;158m'; fi; }  # mint green
      fi

      context_pct="${context_remaining_pct}%"
    fi
  fi
fi

# ---- usage colors ----
cost_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;222m'; fi; }   # light gold
burn_color() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;220m'; fi; }   # bright gold
session_color() {
  rem_pct=$(( 100 - session_pct ))
  if   (( rem_pct <= 10 )); then SCLR='38;5;210'  # light pink
  elif (( rem_pct <= 25 )); then SCLR='38;5;228'  # light yellow
  else                          SCLR='38;5;194'; fi  # light green
  if [ "$use_color" -eq 1 ]; then printf '\033[%sm' "$SCLR"; fi
}

# ---- cost extraction ----
session_pct=0
cost_usd=""; cost_per_hour=""

if [ "$HAS_JQ" -eq 1 ]; then
  cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)
  total_duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty' 2>/dev/null)

  if [ -n "$cost_usd" ] && [ -n "$total_duration_ms" ] && [ "$total_duration_ms" -gt 0 ]; then
    cost_per_hour=$(echo "$cost_usd $total_duration_ms" | awk '{printf "%.2f", $1 * 3600000 / $2}')
  fi
else
  cost_usd=$(echo "$input" | grep -o '"total_cost_usd"[[:space:]]*:[[:space:]]*[0-9.]*' | sed 's/.*:[[:space:]]*\([0-9.]*\).*/\1/')
  total_duration_ms=$(echo "$input" | grep -o '"total_duration_ms"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*:[[:space:]]*\([0-9]*\).*/\1/')

  if [ -n "$cost_usd" ] && [ -n "$total_duration_ms" ] && [ "$total_duration_ms" -gt 0 ]; then
    cost_per_hour=$(echo "$cost_usd $total_duration_ms" | awk '{printf "%.2f", $1 * 3600000 / $2}')
  fi
fi

session_txt_short=""
# Session reset time requires ccusage (only feature that needs external tool)
if command -v ccusage >/dev/null 2>&1 && [ "$HAS_JQ" -eq 1 ]; then
  blocks_output=""

  # File-based locking to prevent concurrent ccusage spawning
  LOCK_FILE="/tmp/ccusage_statusline.lock"
  LOCK_PID_FILE="/tmp/ccusage_statusline.pid"
  CACHE_FILE="/tmp/ccusage_statusline.cache"
  CACHE_MAX_AGE=60  # seconds

  # Check cache first
  if [ -f "$CACHE_FILE" ]; then
    cache_age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
    if [ "$cache_age" -lt "$CACHE_MAX_AGE" ]; then
      blocks_output=$(cat "$CACHE_FILE" 2>/dev/null)
    fi
  fi

  # If no cache, try to fetch with lock
  if [ -z "$blocks_output" ]; then
    if mkdir "$LOCK_FILE" 2>/dev/null; then
      echo $$ > "$LOCK_PID_FILE"
      # Try ccusage with timeout
      if command -v gtimeout >/dev/null 2>&1; then
        blocks_output=$(gtimeout 5s ccusage blocks --json 2>/dev/null)
      else
        blocks_output=$(ccusage blocks --json 2>/dev/null)
      fi
      # Cache the result
      if [ -n "$blocks_output" ]; then
        echo "$blocks_output" > "$CACHE_FILE" 2>/dev/null
      fi
      rm -f "$LOCK_PID_FILE" 2>/dev/null
      rmdir "$LOCK_FILE" 2>/dev/null
    fi
  fi

  if [ -n "$blocks_output" ]; then
    active_block=$(echo "$blocks_output" | jq -c '.blocks[] | select(.isActive == true)' 2>/dev/null | head -n1)
    if [ -n "$active_block" ]; then
      # Session time calculation from ccusage
      reset_time_str=$(echo "$active_block" | jq -r '.usageLimitResetTime // .endTime // empty')
      start_time_str=$(echo "$active_block" | jq -r '.startTime // empty')

      if [ -n "$reset_time_str" ] && [ -n "$start_time_str" ]; then
        start_sec=$(to_epoch "$start_time_str"); end_sec=$(to_epoch "$reset_time_str"); now_sec=$(date +%s)
        total=$(( end_sec - start_sec )); (( total<1 )) && total=1
        elapsed=$(( now_sec - start_sec )); (( elapsed<0 ))&&elapsed=0; (( elapsed>total ))&&elapsed=$total
        session_pct=$(( elapsed * 100 / total ))
        remaining=$(( end_sec - now_sec )); (( remaining<0 )) && remaining=0
        rh=$(( remaining / 3600 )); rm=$(( (remaining % 3600) / 60 ))
        session_txt_short="$(printf '%dh%dm' "$rh" "$rm")"
      fi
    fi
  fi
fi

# ---- render statusline (1-line compact) ----
sep=""  # 첫 요소 앞에는 구분자 없음

# 계정
if [ "$SHOW_ACCOUNT" -eq 1 ] && [ -n "$account_email" ]; then
  printf '%s👤 %s%s%s' "$sep" "$(account_color)" "$account_email" "$(rst)"
  sep="  "
fi
# 디렉토리
if [ "$SHOW_DIR" -eq 1 ]; then
  printf '%s📁 %s%s%s' "$sep" "$(dir_color)" "$current_dir" "$(rst)"
  sep="  "
fi
# Git 브랜치
if [ "$SHOW_GIT" -eq 1 ] && [ -n "$git_branch" ]; then
  printf '%s🌿 %s%s%s' "$sep" "$(git_color)" "$git_branch" "$(rst)"
  sep="  "
fi
# 모델
if [ "$SHOW_MODEL" -eq 1 ]; then
  printf '%s🤖 %s%s%s' "$sep" "$(model_color)" "$model_name" "$(rst)"
  sep="  "
fi
# 컨텍스트
if [ "$SHOW_CONTEXT" -eq 1 ] && [ -n "$context_pct" ]; then
  printf '%s🧠 %s%s[%s]%s' "$sep" "$(context_color)" "$context_pct" "$(progress_bar "$context_remaining_pct" 10)" "$(rst)"
  sep="  "
fi
# 비용 + burn rate
if [ "$SHOW_COST" -eq 1 ] && [ -n "$cost_usd" ] && [[ "$cost_usd" =~ ^[0-9.]+$ ]]; then
  printf '%s💰 %s$%.2f%s' "$sep" "$(cost_color)" "$cost_usd" "$(rst)"
  [ -n "$cost_per_hour" ] && printf '(%s$%.2f/h%s)' "$(burn_color)" "$cost_per_hour" "$(rst)"
  sep="  "
fi
# 플랜
if [ "$SHOW_PLAN" -eq 1 ] && [ -n "$detected_plan" ]; then
  printf '%s📋 %s%s%s' "$sep" "$(plan_color)" "$detected_plan" "$(rst)"
  sep="  "
fi
# Extra Usage
if [ "$SHOW_EXTRA_USAGE" -eq 1 ] && [ "$extra_usage_enabled" = "true" ] && [ "$detected_plan" = "Max" ]; then
  printf '%s⚡%sExtra%s' "$sep" "$(extra_color)" "$(rst)"
  sep="  "
fi
# 세션 잔여 시간
if [ "$SHOW_SESSION" -eq 1 ] && [ -n "$session_txt_short" ]; then
  printf '%s⌛ %s%s%s' "$sep" "$(session_color)" "$session_txt_short" "$(rst)"
  sep="  "
fi
printf '\n'
