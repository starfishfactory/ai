#!/usr/bin/env bash
#
# setup-statusline.sh — lean-kit statusline 설치 + 설정
#
# Usage:
#   --interactive         셸 프롬프트로 전체 설정 (Claude 없이 직접 사용)
#   --detect              Plan/JQ/CCUSAGE 상태만 출력 (Claude 커맨드용)
#   --plan TYPE           Pro|Max|API (생략 시 자동감지)
#   --hide ITEMS          쉼표 구분 비활성 항목 (COST,SESSION 등)
#   --show ITEMS          쉼표 구분 활성 항목
#   --no-deps             의존성 설치 건너뜀
#   --dry-run             실제 설치 없이 결과만 출력

set -euo pipefail

# === 경로 설정 ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_STATUSLINE="$SCRIPT_DIR/statusline.sh"
CLAUDE_DIR="$HOME/.claude"
TARGET_STATUSLINE="$CLAUDE_DIR/statusline.sh"
TARGET_CONF="$CLAUDE_DIR/statusline.conf"
SETTINGS="$CLAUDE_DIR/settings.json"

# === 색상 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[lean-kit]${NC} $1"; }
warn()  { echo -e "${YELLOW}[lean-kit]${NC} $1"; }
error() { echo -e "${RED}[lean-kit]${NC} $1" >&2; }

# === Plan 감지 ===
detect_plan() {
  local detected=""
  if [ -f "$HOME/.claude.json" ]; then
    local billing="" extra="" has_oauth=""
    if command -v jq >/dev/null 2>&1; then
      billing=$(jq -r '.oauthAccount.billingType // ""' "$HOME/.claude.json" 2>/dev/null)
      extra=$(jq -r '.oauthAccount.hasExtraUsageEnabled // false' "$HOME/.claude.json" 2>/dev/null)
      has_oauth=$(jq -r '.oauthAccount // empty' "$HOME/.claude.json" 2>/dev/null)
    else
      local claude_json
      claude_json=$(cat "$HOME/.claude.json" 2>/dev/null)
      billing=$(echo "$claude_json" | grep -o '"billingType"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)".*/\1/' || echo "")
      extra=$(echo "$claude_json" | grep -oE '"hasExtraUsageEnabled"[[:space:]]*:[[:space:]]*(true|false)' | head -1 | sed -E 's/.*:[[:space:]]*(true|false).*/\1/' || echo "false")
      has_oauth=$(echo "$claude_json" | grep -o '"oauthAccount"' | head -1 || echo "")
    fi

    if [ "$billing" = "stripe_subscription" ]; then
      [ "$extra" = "true" ] && detected="Max" || detected="Pro"
    elif [ -n "$has_oauth" ] && [ "$has_oauth" != "null" ]; then
      detected="Pro"
    else
      detected="API"
    fi
  fi
  echo "$detected"
}

# === 인자 파싱 ===
MODE=""
PLAN=""
HIDE_ITEMS=""
SHOW_ITEMS=""
NO_DEPS=0
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --interactive) MODE="interactive" ;;
    --detect)      MODE="detect" ;;
    --plan)        PLAN="$2"; shift ;;
    --hide)        HIDE_ITEMS="$2"; shift ;;
    --show)        SHOW_ITEMS="$2"; shift ;;
    --no-deps)     NO_DEPS=1 ;;
    --dry-run)     DRY_RUN=1 ;;
    *) error "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# === --detect 모드 ===
if [ "$MODE" = "detect" ]; then
  plan=$(detect_plan)
  has_jq=0; command -v jq >/dev/null 2>&1 && has_jq=1
  has_ccusage=0; command -v ccusage >/dev/null 2>&1 && has_ccusage=1
  echo "PLAN=${plan:-unknown} JQ=$has_jq CCUSAGE=$has_ccusage"
  exit 0
fi

# === Plan 결정 ===
[ -z "$PLAN" ] && PLAN=$(detect_plan)

# === Config 기본값 (all ON) ===
SHOW_ACCOUNT=1; SHOW_DIR=1; SHOW_GIT=1; SHOW_MODEL=1
SHOW_CONTEXT=1; SHOW_COST=1; SHOW_SESSION=1; SHOW_PLAN=1; SHOW_EXTRA_USAGE=1

# === Plan별 추천 기본값 ===
case "$PLAN" in
  Pro) SHOW_COST=0 ;;
  Max) SHOW_COST=0 ;;
  API) SHOW_EXTRA_USAGE=0 ;;
esac

# === --hide 적용 ===
apply_toggle() {
  local item="$1" value="$2"
  item=$(echo "$item" | tr '[:lower:]' '[:upper:]' | tr -d ' ')
  case "$item" in
    ACCOUNT)              eval "SHOW_ACCOUNT=$value" ;;
    DIR|DIRECTORY)        eval "SHOW_DIR=$value" ;;
    GIT)                  eval "SHOW_GIT=$value" ;;
    MODEL)                eval "SHOW_MODEL=$value" ;;
    CONTEXT)              eval "SHOW_CONTEXT=$value" ;;
    COST)                 eval "SHOW_COST=$value" ;;
    SESSION)              eval "SHOW_SESSION=$value" ;;
    PLAN)                 eval "SHOW_PLAN=$value" ;;
    EXTRA|EXTRA_USAGE)    eval "SHOW_EXTRA_USAGE=$value" ;;
  esac
}

if [ -n "$HIDE_ITEMS" ]; then
  IFS=',' read -ra items <<< "$HIDE_ITEMS"
  for item in "${items[@]}"; do apply_toggle "$item" 0; done
fi

if [ -n "$SHOW_ITEMS" ]; then
  IFS=',' read -ra items <<< "$SHOW_ITEMS"
  for item in "${items[@]}"; do apply_toggle "$item" 1; done
fi

# === Interactive 모드 ===
if [ "$MODE" = "interactive" ]; then
  echo -e "${CYAN}${BOLD}[lean-kit] Statusline Setup${NC}"
  echo "─────────────────────────────────"
  echo ""

  # [1] Plan 감지
  auto_plan=$(detect_plan)
  if [ -n "$auto_plan" ]; then
    echo -e "[1] Plan 감지: ${BOLD}$auto_plan${NC}"
    if [ -t 0 ]; then
      read -rp "    올바른가요? (Y/n/Pro/Max/API): " plan_answer
      case "$plan_answer" in
        [Pp]ro) PLAN="Pro" ;;
        [Mm]ax) PLAN="Max" ;;
        [Aa]pi|API) PLAN="API" ;;
        [Nn]) read -rp "    Plan 입력 (Pro/Max/API): " PLAN ;;
        *) PLAN="$auto_plan" ;;
      esac
    else
      PLAN="$auto_plan"
    fi
  else
    echo "[1] Plan 감지: 감지 불가"
    if [ -t 0 ]; then
      read -rp "    Plan 입력 (Pro/Max/API): " PLAN
    fi
  fi

  # Plan 기본값 재적용
  case "$PLAN" in
    Pro) SHOW_COST=0 ;;
    Max) SHOW_COST=0 ;;
    API) SHOW_EXTRA_USAGE=0 ;;
  esac
  echo ""

  # [2] 표시 요소 선택
  ELEMENTS=("ACCOUNT" "DIR" "GIT" "MODEL" "CONTEXT" "COST" "PLAN" "EXTRA_USAGE" "SESSION")
  ICONS=("👤" "📁" "🌿" "🤖" "🧠" "💰" "📋" "⚡" "⌛")
  LABELS=("Account" "Directory" "Git" "Model" "Context" "Cost" "Plan" "Extra" "Session")
  VALS=($SHOW_ACCOUNT $SHOW_DIR $SHOW_GIT $SHOW_MODEL $SHOW_CONTEXT $SHOW_COST $SHOW_PLAN $SHOW_EXTRA_USAGE $SHOW_SESSION)

  echo "[2] 표시 요소 선택 ($PLAN 추천 기본값):"
  for i in "${!ELEMENTS[@]}"; do
    local_status="ON"; [ "${VALS[$i]}" -eq 0 ] && local_status="OFF"
    printf "    %d. %s %-12s [%s]\n" $((i+1)) "${ICONS[$i]}" "${LABELS[$i]}" "$local_status"
  done

  if [ -t 0 ]; then
    read -rp "    토글할 번호 입력 (쉼표 구분, 완료=Enter): " toggle_input
    if [ -n "$toggle_input" ]; then
      IFS=',' read -ra toggles <<< "$toggle_input"
      for t in "${toggles[@]}"; do
        t=$(echo "$t" | tr -d ' ')
        if [[ "$t" =~ ^[1-9]$ ]] && [ "$t" -le "${#ELEMENTS[@]}" ]; then
          idx=$((t - 1))
          [ "${VALS[$idx]}" -eq 1 ] && VALS[$idx]=0 || VALS[$idx]=1
        fi
      done
    fi
  fi

  SHOW_ACCOUNT=${VALS[0]}; SHOW_DIR=${VALS[1]}; SHOW_GIT=${VALS[2]}
  SHOW_MODEL=${VALS[3]}; SHOW_CONTEXT=${VALS[4]}; SHOW_COST=${VALS[5]}
  SHOW_PLAN=${VALS[6]}; SHOW_EXTRA_USAGE=${VALS[7]}; SHOW_SESSION=${VALS[8]}
  echo ""
fi

# === Dependency check ===
if [ "$NO_DEPS" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ "$MODE" = "interactive" ]; then
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq 미설치 (일부 기능 제한: context, cost)"
    if [ -t 0 ] && command -v brew >/dev/null 2>&1; then
      read -rp "[lean-kit] brew install jq 실행? (Y/n): " jq_answer
      if [[ "${jq_answer:-Y}" =~ ^[Yy]$ ]]; then
        brew install jq
      fi
    fi
  fi
  if ! command -v ccusage >/dev/null 2>&1 && [[ "$PLAN" =~ ^(Pro|Max)$ ]]; then
    warn "ccusage 미설치 (⌛ 세션 추적 비활성)"
    if [ -t 0 ] && command -v npm >/dev/null 2>&1; then
      read -rp "[lean-kit] npm install -g ccusage 실행? (y/N): " cc_answer
      if [[ "${cc_answer:-n}" =~ ^[Yy]$ ]]; then
        npm install -g ccusage
      fi
    fi
  fi
fi

# === Dry-run ===
if [ "$DRY_RUN" -eq 1 ]; then
  echo "[dry-run] Plan=$PLAN"
  echo "[dry-run] Would copy: $SOURCE_STATUSLINE → $TARGET_STATUSLINE"
  echo "[dry-run] Would create: $TARGET_CONF"
  echo "[dry-run] Would update: $SETTINGS"
  echo "[dry-run] Config:"
  echo "  SHOW_ACCOUNT=$SHOW_ACCOUNT SHOW_DIR=$SHOW_DIR SHOW_GIT=$SHOW_GIT"
  echo "  SHOW_MODEL=$SHOW_MODEL SHOW_CONTEXT=$SHOW_CONTEXT SHOW_COST=$SHOW_COST"
  echo "  SHOW_SESSION=$SHOW_SESSION SHOW_PLAN=$SHOW_PLAN SHOW_EXTRA_USAGE=$SHOW_EXTRA_USAGE"
  exit 0
fi

# === 소스 확인 ===
if [ ! -f "$SOURCE_STATUSLINE" ]; then
  error "statusline.sh not found: $SOURCE_STATUSLINE"
  exit 1
fi

# === 설치 ===
mkdir -p "$CLAUDE_DIR"

# 1. statusline.sh 복사
cp "$SOURCE_STATUSLINE" "$TARGET_STATUSLINE"
chmod +x "$TARGET_STATUSLINE"
info "✓ statusline.sh → $TARGET_STATUSLINE"

# 2. statusline.conf 생성
cat > "$TARGET_CONF" << CONF
# lean-kit statusline config
# Generated by setup-statusline.sh
# 0=hide, 1=show
SHOW_ACCOUNT=$SHOW_ACCOUNT
SHOW_DIR=$SHOW_DIR
SHOW_GIT=$SHOW_GIT
SHOW_MODEL=$SHOW_MODEL
SHOW_CONTEXT=$SHOW_CONTEXT
SHOW_COST=$SHOW_COST
SHOW_SESSION=$SHOW_SESSION
SHOW_PLAN=$SHOW_PLAN
SHOW_EXTRA_USAGE=$SHOW_EXTRA_USAGE
PLAN_TYPE=$PLAN
CONF
info "✓ statusline.conf → $TARGET_CONF"

# 3. settings.json에 statusLine 등록
if [ -f "$SETTINGS" ]; then
  if command -v jq >/dev/null 2>&1; then
    jq '.statusLine = {"type":"command","command":"~/.claude/statusline.sh","padding":0}' \
      "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  fi
else
  mkdir -p "$(dirname "$SETTINGS")"
  if command -v jq >/dev/null 2>&1; then
    echo '{}' | jq '.statusLine = {"type":"command","command":"~/.claude/statusline.sh","padding":0}' \
      > "$SETTINGS"
  else
    echo '{"statusLine":{"type":"command","command":"~/.claude/statusline.sh","padding":0}}' > "$SETTINGS"
  fi
fi
info "✓ settings.json statusLine 설정"

# 4. 검증
echo ""
if [ -f "$TARGET_STATUSLINE" ]; then
  verify_out=$(echo '{"cwd":"/tmp","model":{"display_name":"Opus"}}' | bash "$TARGET_STATUSLINE" 2>/dev/null || true)
  info "검증: $verify_out"
fi

info ""
info "완료! Claude Code 재시작 후 적용됩니다."
