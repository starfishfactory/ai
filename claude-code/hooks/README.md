# Claude Code Slack Notifier

Claude Code 작업이 완료될 때 자동으로 Slack DM으로 알림을 보냅니다.

## 기능

- ✅ 작업 완료 시 자동 알림
- 📝 마지막 프롬프트 표시
- 💬 마지막 응답 메시지 표시
- ⏰ 완료 시간 기록

## 설치

### 1. Slack Bot 설정

1. https://api.slack.com/apps 접속
2. "Create New App" → "From scratch"
3. "OAuth & Permissions"에서 권한 추가:
   - `chat:write`
4. "Install to Workspace" 클릭
5. **Bot User OAuth Token** 복사 (`xoxb-`로 시작)

### 2. User ID 확인

- Slack 프로필 → "프로필 더 보기" → "멤버 ID 복사" (`U`로 시작)

### 3. 설치 스크립트 실행

```bash
chmod +x install.sh
./install.sh
```

입력 사항:
- Slack Bot Token
- Slack User ID

### 4. 환경변수 적용

```bash
source ~/.zshrc  # 또는 ~/.bashrc
```

## 사용법

평소대로 Claude Code를 사용하면 됩니다. 세션이 종료될 때 자동으로 Slack 알림이 전송됩니다.

## 테스트

```bash
# Claude Code 실행
claude code

# 간단한 작업 수행 후 종료 (Ctrl+C 또는 /exit)
# Slack DM 확인
```

## 파일 구조

```
~/.claude/
├── settings.json          # 훅 설정
└── hooks/
    └── slack_notify.sh    # 알림 스크립트
```

## 제거

```bash
# 환경변수 제거
# ~/.zshrc 또는 ~/.bashrc에서 다음 줄 삭제:
# export SLACK_BOT_TOKEN="..."
# export SLACK_USER_ID="..."

# 훅 스크립트 제거
rm ~/.claude/hooks/slack_notify.sh

# settings.json에서 Stop 훅 제거
jq 'del(.hooks.Stop)' ~/.claude/settings.json > ~/.claude/settings.json.tmp
mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```

## 문제 해결

### 알림이 오지 않을 때

1. 환경변수 확인:
   ```bash
   echo $SLACK_BOT_TOKEN
   echo $SLACK_USER_ID
   ```

2. 훅 설정 확인:
   ```bash
   cat ~/.claude/settings.json
   ```

3. 수동 테스트:
   ```bash
   ~/.claude/hooks/slack_notify.sh
   ```

### 권한 오류

```bash
chmod +x ~/.claude/hooks/slack_notify.sh
```
