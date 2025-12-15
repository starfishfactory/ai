#!/bin/bash
set -e

echo "🚀 Claude Code Slack Notifier 설치"
echo ""

# 의존성 체크
echo "📦 의존성 확인 중..."
MISSING_DEPS=()

if ! command -v jq &> /dev/null; then
    MISSING_DEPS+=("jq")
fi

if ! command -v curl &> /dev/null; then
    MISSING_DEPS+=("curl")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "❌ 필수 의존성이 설치되지 않았습니다: ${MISSING_DEPS[*]}"
    echo ""
    echo "설치 방법:"
    echo "  macOS:   brew install ${MISSING_DEPS[*]}"
    echo "  Ubuntu:  sudo apt-get install ${MISSING_DEPS[*]}"
    echo "  CentOS:  sudo yum install ${MISSING_DEPS[*]}"
    exit 1
fi

echo "✅ 의존성 확인 완료"
echo ""

# Slack 정보 입력
read -p "Slack Bot Token (xoxb-...): " SLACK_BOT_TOKEN
read -p "Slack User ID (U...): " SLACK_USER_ID

# 입력 검증
if [[ ! "$SLACK_BOT_TOKEN" =~ ^xoxb- ]]; then
    echo "❌ 올바른 Slack Bot Token 형식이 아닙니다 (xoxb-로 시작해야 함)"
    exit 1
fi

if [[ ! "$SLACK_USER_ID" =~ ^U ]]; then
    echo "❌ 올바른 Slack User ID 형식이 아닙니다 (U로 시작해야 함)"
    exit 1
fi

# 환경변수 설정
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "❌ .zshrc 또는 .bashrc를 찾을 수 없습니다"
    exit 1
fi

# 기존 설정 제거 (중복 방지)
if grep -q "# Claude Code Slack Notifier" "$SHELL_RC"; then
    echo "⚠️  기존 설정 발견. 제거 후 재설치합니다..."
    # Claude Code Slack Notifier 섹션 전체 제거
    sed -i.bak '/# Claude Code Slack Notifier/,/export SLACK_USER_ID/d' "$SHELL_RC"
fi

# 환경변수 추가
echo "" >> "$SHELL_RC"
echo "# Claude Code Slack Notifier" >> "$SHELL_RC"
echo "export SLACK_BOT_TOKEN=\"$SLACK_BOT_TOKEN\"" >> "$SHELL_RC"
echo "export SLACK_USER_ID=\"$SLACK_USER_ID\"" >> "$SHELL_RC"

# 파일 권한 확인
chmod 600 "$SHELL_RC"

# 현재 세션에도 적용
export SLACK_BOT_TOKEN="$SLACK_BOT_TOKEN"
export SLACK_USER_ID="$SLACK_USER_ID"

# 훅 디렉토리 생성
HOOK_DIR="$HOME/.claude/hooks"
mkdir -p "$HOOK_DIR"

# 훅 스크립트 생성
cat > "$HOOK_DIR/slack_notify.sh" << 'EOF'
#!/bin/bash

# 디버그 로그
DEBUG_LOG="$HOME/.claude/hooks/debug.log"
echo "========== $(date) ==========" >> "$DEBUG_LOG"
echo "Hook started" >> "$DEBUG_LOG"

# 환경변수 로드
source ~/.bashrc 2>/dev/null || true

echo "ENV: SLACK_BOT_TOKEN=${SLACK_BOT_TOKEN:0:20}..." >> "$DEBUG_LOG"
echo "ENV: SLACK_USER_ID=$SLACK_USER_ID" >> "$DEBUG_LOG"

# stdin에서 JSON 읽기
INPUT_JSON=$(cat)

echo "RAW INPUT: $INPUT_JSON" >> "$DEBUG_LOG"

# transcript 경로 및 작업 디렉토리 추출
TRANSCRIPT_PATH=$(echo "$INPUT_JSON" | jq -r '.transcript_path // empty')
CWD=$(echo "$INPUT_JSON" | jq -r '.cwd // empty')

echo "TRANSCRIPT: $TRANSCRIPT_PATH" >> "$DEBUG_LOG"
echo "CWD: $CWD" >> "$DEBUG_LOG"

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    echo "No transcript or file not found" >> "$DEBUG_LOG"
    exit 0
fi

# 마지막 실제 사용자 프롬프트 추출 (content가 문자열인 것만)
LAST_PROMPT=$(grep '"type":"user"' "$TRANSCRIPT_PATH" | \
    jq -r 'select(.message.content | type == "string") | .message.content' 2>/dev/null | \
    tail -1)

echo "PROMPT: [${LAST_PROMPT:0:100}]" >> "$DEBUG_LOG"

# 마지막 어시스턴트 응답 추출 (text 타입만, 전체 텍스트)
LAST_RESPONSE=$(grep '"type":"assistant"' "$TRANSCRIPT_PATH" | tail -1 | \
    jq -r '.message.content[]? | select(.type == "text") | .text' 2>/dev/null)

echo "RESPONSE: [${LAST_RESPONSE:0:100}]" >> "$DEBUG_LOG"

if [ -z "$LAST_PROMPT" ] || [ -z "$LAST_RESPONSE" ]; then
    echo "Empty prompt or response, exit" >> "$DEBUG_LOG"
    exit 0
fi

# 텍스트 자르기 (200자)
PROMPT_SHORT="${LAST_PROMPT:0:200}"
[ ${#LAST_PROMPT} -gt 200 ] && PROMPT_SHORT="${PROMPT_SHORT}..."

RESPONSE_SHORT="${LAST_RESPONSE:0:200}"
[ ${#LAST_RESPONSE} -gt 200 ] && RESPONSE_SHORT="${RESPONSE_SHORT}..."

# 중복 방지 (프롬프트 + 응답 조합으로 체크)
LAST_SENT_FILE="$HOME/.claude/hooks/.last_sent"
COMBINED_HASH=$(echo -n "${LAST_PROMPT}${LAST_RESPONSE}" | md5sum | cut -d' ' -f1)

echo "HASH: $COMBINED_HASH" >> "$DEBUG_LOG"

if [ -f "$LAST_SENT_FILE" ]; then
    LAST_HASH=$(cat "$LAST_SENT_FILE")
    echo "LAST_HASH: $LAST_HASH" >> "$DEBUG_LOG"
    if [ "$COMBINED_HASH" = "$LAST_HASH" ]; then
        echo "Duplicate detected, exit" >> "$DEBUG_LOG"
        exit 0
    fi
fi

echo "$COMBINED_HASH" > "$LAST_SENT_FILE"
echo "Sending to Slack..." >> "$DEBUG_LOG"

# Slack 메시지 전송
PAYLOAD=$(jq -n \
  --arg channel "$SLACK_USER_ID" \
  --arg prompt "$PROMPT_SHORT" \
  --arg response "$RESPONSE_SHORT" \
  --arg workdir "$CWD" \
  '{
    channel: $channel,
    blocks: [
      {
        type: "header",
        text: {
          type: "plain_text",
          text: $prompt
        }
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: $response
        }
      },
      {
        type: "context",
        elements: [
          {
            type: "mrkdwn",
            text: ("📁 " + $workdir)
          }
        ]
      }
    ]
  }')

RESPONSE=$(curl -sS -w "\n%{http_code}" -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

echo "HTTP: $HTTP_CODE" >> "$DEBUG_LOG"
echo "BODY: ${BODY:0:200}" >> "$DEBUG_LOG"
echo "Done" >> "$DEBUG_LOG"
EOF

chmod +x "$HOOK_DIR/slack_notify.sh"

# settings.json 업데이트
SETTINGS_FILE="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# jq로 훅 추가 (UserPromptSubmit: 각 프롬프트-응답 마다, Stop: 세션 종료 시)
jq '.hooks.UserPromptSubmit = [{"matcher": "", "hooks": [{"type": "command", "command": "'"$HOOK_DIR/slack_notify.sh"'"}]}] | .hooks.Stop = [{"matcher": "", "hooks": [{"type": "command", "command": "'"$HOOK_DIR/slack_notify.sh"'"}]}]' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

echo ""
echo "✅ 설치 완료!"
echo ""
echo "📝 다음 명령어를 실행하여 환경변수를 적용하세요:"
echo "   source $SHELL_RC"
echo ""
echo "🔒 보안 안내:"
echo "   - 쉘 설정 파일 권한이 600으로 설정되었습니다"
echo "   - Token은 평문으로 저장되므로 시스템 접근 권한 관리에 유의하세요"
echo "   - 공유 서버에서는 사용을 권장하지 않습니다"
echo ""
echo "🎉 이제 Claude Code에서 프롬프트-응답이 있을 때마다 Slack으로 알림이 갑니다!"
