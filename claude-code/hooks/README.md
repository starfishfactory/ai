# Claude Code Slack Notifier

Claude Code 작업이 완료될 때 자동으로 Slack DM으로 알림을 보냅니다.

## 기능

- ✅ 작업 완료 시 자동 알림 (간결한 포맷)
- 📝 프롬프트를 헤더로 표시 (스마트 자르기)
- 💬 응답 메시지 표시 (스마트 자르기)
- 📁 작업 디렉토리 경로 표시
- 🛡️ 안전한 JSON 처리 (특수문자 이스케이핑)
- 📊 에러 로깅 및 추적

## 요구사항

- `jq` - JSON 처리
- `curl` - HTTP 요청
- Bash 4.0 이상

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

스크립트는 다음을 자동으로 수행합니다:
- 의존성 체크 (`jq`, `curl`)
- 입력값 검증 (Token/User ID 형식)
- 기존 설정 제거 (재설치 시)
- 환경변수 설정
- 훅 스크립트 생성
- 파일 권한 설정 (600)

입력 사항:
- Slack Bot Token (`xoxb-`로 시작)
- Slack User ID (`U`로 시작)

### 4. 환경변수 적용

```bash
source ~/.zshrc  # 또는 ~/.bashrc
```

## 보안

⚠️ **중요 보안 주의사항**

- Token은 쉘 설정 파일에 **평문**으로 저장됩니다
- 파일 권한이 자동으로 600으로 설정되지만, 시스템 관리자는 접근 가능합니다
- **공유 서버나 멀티 유저 환경에서는 사용을 권장하지 않습니다**
- Token이 노출되면 즉시 Slack에서 재생성하세요

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

1. **환경변수 확인:**
   ```bash
   echo $SLACK_BOT_TOKEN
   echo $SLACK_USER_ID
   ```

2. **훅 설정 확인:**
   ```bash
   cat ~/.claude/settings.json | jq '.hooks.Stop'
   ```

3. **에러 로그 확인:**
   ```bash
   cat ~/.claude/hooks/slack_notify.log
   ```
   로그에서 다음을 확인하세요:
   - HTTP 에러 (401: 잘못된 Token, 404: 잘못된 User ID)
   - Slack API 에러 (권한 부족, Rate limit 등)

4. **수동 테스트 (환경변수 직접 주입):**
   ```bash
   export STDIN_JSON='{"transcript_path":"'$HOME'/.claude/transcripts/latest.json","working_directory":"'$(pwd)'"}'
   ~/.claude/hooks/slack_notify.sh
   ```

### 의존성 문제

```bash
# macOS
brew install jq curl

# Ubuntu/Debian
sudo apt-get install jq curl

# CentOS/RHEL
sudo yum install jq curl
```

### 권한 오류

```bash
chmod +x ~/.claude/hooks/slack_notify.sh
chmod 600 ~/.zshrc  # 또는 ~/.bashrc
```

### 재설치

```bash
# 완전히 제거 후 재설치
./install.sh
# 스크립트가 자동으로 기존 설정을 제거하고 재설치합니다
```
