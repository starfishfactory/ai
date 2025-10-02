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

# 로그 파일 설정
LOG_FILE="$HOME/.claude/hooks/slack_notify.log"

# 에러 로깅 함수
log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
}

# 트랜스크립트 경로 가져오기
TRANSCRIPT_PATH=$(echo "$STDIN_JSON" | jq -r '.transcript_path // empty' 2>/dev/null)

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    exit 0
fi

# 작업 디렉토리 가져오기
WORK_DIR=$(echo "$STDIN_JSON" | jq -r '.working_directory // "Unknown"' 2>/dev/null)
if [ "$WORK_DIR" = "null" ]; then
    WORK_DIR="Unknown"
fi

# 마지막 프롬프트와 응답 추출
LAST_PROMPT=$(jq -r '[.transcript[] | select(.speaker == "user")] | last | .content' "$TRANSCRIPT_PATH" 2>/dev/null || echo "")
LAST_RESPONSE=$(jq -r '[.transcript[] | select(.speaker == "assistant")] | last | .content' "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

# 스마트 텍스트 자르기 함수 (줄바꿈 우선, 200자 제한)
smart_truncate() {
    local text="$1"
    local limit=200

    if [ ${#text} -le $limit ]; then
        echo "$text"
        return
    fi

    # 200자 내에서 마지막 줄바꿈 찾기
    local truncated="${text:0:$limit}"
    local last_newline=$(echo "$truncated" | grep -ob $'\n' | tail -1 | cut -d: -f1)

    if [ -n "$last_newline" ] && [ "$last_newline" -gt 100 ]; then
        echo "${text:0:$last_newline}..."
    else
        echo "${truncated}..."
    fi
}

PROMPT_SHORT=$(smart_truncate "$LAST_PROMPT")
RESPONSE_SHORT=$(smart_truncate "$LAST_RESPONSE")

# JSON 페이로드 생성 (jq로 안전하게)
PAYLOAD=$(jq -n \
  --arg channel "$SLACK_USER_ID" \
  --arg prompt "$PROMPT_SHORT" \
  --arg response "$RESPONSE_SHORT" \
  --arg workdir "$WORK_DIR" \
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

# Slack 메시지 전송
RESPONSE=$(curl -sS -w "\n%{http_code}" -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# 응답 파싱
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# 에러 체크
if [ "$HTTP_CODE" != "200" ]; then
    log_error "HTTP $HTTP_CODE: $BODY"
    exit 1
fi

# Slack API 에러 체크
if ! echo "$BODY" | jq -e '.ok' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$BODY" | jq -r '.error // "Unknown error"')
    log_error "Slack API Error: $ERROR_MSG"
    exit 1
fi
EOF

chmod +x "$HOOK_DIR/slack_notify.sh"

# settings.json 업데이트
SETTINGS_FILE="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# jq로 훅 추가
jq '.hooks.Stop = [{"matcher": "", "hooks": [{"type": "command", "command": "'"$HOOK_DIR/slack_notify.sh"'"}]}]' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
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
echo "🎉 이제 Claude Code 세션이 종료될 때마다 Slack으로 알림이 갑니다!"
