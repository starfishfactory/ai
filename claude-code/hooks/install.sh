#!/bin/bash
set -e

echo "🚀 Claude Code Slack Notifier 설치"
echo ""

# Slack 정보 입력
read -p "Slack Bot Token (xoxb-...): " SLACK_BOT_TOKEN
read -p "Slack User ID (U...): " SLACK_USER_ID

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

# 환경변수 추가 (중복 체크)
if ! grep -q "SLACK_BOT_TOKEN" "$SHELL_RC"; then
    echo "" >> "$SHELL_RC"
    echo "# Claude Code Slack Notifier" >> "$SHELL_RC"
    echo "export SLACK_BOT_TOKEN=\"$SLACK_BOT_TOKEN\"" >> "$SHELL_RC"
    echo "export SLACK_USER_ID=\"$SLACK_USER_ID\"" >> "$SHELL_RC"
fi

# 현재 세션에도 적용
export SLACK_BOT_TOKEN="$SLACK_BOT_TOKEN"
export SLACK_USER_ID="$SLACK_USER_ID"

# 훅 디렉토리 생성
HOOK_DIR="$HOME/.claude/hooks"
mkdir -p "$HOOK_DIR"

# 훅 스크립트 생성
cat > "$HOOK_DIR/slack_notify.sh" << 'EOF'
#!/bin/bash

# 트랜스크립트 경로 가져오기
TRANSCRIPT_PATH=$(echo "$STDIN_JSON" | jq -r '.transcript_path // empty')

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    exit 0
fi

# 마지막 프롬프트와 응답 추출
LAST_PROMPT=$(jq -r '[.transcript[] | select(.speaker == "user")] | last | .content' "$TRANSCRIPT_PATH" 2>/dev/null || echo "")
LAST_RESPONSE=$(jq -r '[.transcript[] | select(.speaker == "assistant")] | last | .content' "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

# 텍스트 자르기 (200자)
if [ ${#LAST_PROMPT} -gt 200 ]; then
    PROMPT_SHORT="${LAST_PROMPT:0:200}..."
else
    PROMPT_SHORT="$LAST_PROMPT"
fi

if [ ${#LAST_RESPONSE} -gt 200 ]; then
    RESPONSE_SHORT="${LAST_RESPONSE:0:200}..."
else
    RESPONSE_SHORT="$LAST_RESPONSE"
fi

# Slack 메시지 전송
curl -sS -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"channel\": \"$SLACK_USER_ID\",
    \"blocks\": [
      {
        \"type\": \"header\",
        \"text\": {
          \"type\": \"plain_text\",
          \"text\": \"✅ Claude Code 작업 완료\"
        }
      },
      {
        \"type\": \"section\",
        \"fields\": [
          {
            \"type\": \"mrkdwn\",
            \"text\": \"*프롬프트:*\n$PROMPT_SHORT\"
          },
          {
            \"type\": \"mrkdwn\",
            \"text\": \"*시간:*\n$(date +'%Y-%m-%d %H:%M:%S')\"
          }
        ]
      },
      {
        \"type\": \"section\",
        \"text\": {
          \"type\": \"mrkdwn\",
          \"text\": \"*마지막 응답:*\n$RESPONSE_SHORT\"
        }
      }
    ]
  }" > /dev/null 2>&1
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
echo "🎉 이제 Claude Code 세션이 종료될 때마다 Slack으로 알림이 갑니다!"
