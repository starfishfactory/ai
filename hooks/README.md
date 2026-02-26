# Claude Code Slack Notifier

Claude Code 작업이 완료될 때 자동으로 Slack DM으로 알림을 보낸다.

## 기능

- **각 프롬프트-응답마다 자동 알림** (UserPromptSubmit 훅 사용)
- 프롬프트를 헤더로 표시 (200자 제한)
- 응답 메시지 표시 (200자 제한)
- 작업 디렉토리 경로 표시
- 중복 알림 방지 (같은 프롬프트+응답 조합에 대해 1회만)
- 안전한 JSON 처리 (jq 사용)

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

스크립트는 다음을 자동으로 수행한다:
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

- Token은 쉘 설정 파일에 **평문**으로 저장된다
- 파일 권한이 자동으로 600으로 설정되지만, 시스템 관리자는 접근 가능하다
- **공유 서버나 멀티 유저 환경에서는 사용을 권장하지 않는다**
- Token이 노출되면 즉시 Slack에서 재생성하라

## 사용법

평소대로 Claude Code를 사용하면 된다. **각 프롬프트-응답마다** 자동으로 Slack 알림이 전송된다.

### 알림 타이밍

- 프롬프트를 제출하면 즉시 알림
- 같은 프롬프트에 대한 중복 알림 방지
- Slack DM으로 실시간 수신

## 테스트

```bash
# Claude Code 실행
claude code

# 간단한 질문 (예: "안녕")
# 응답이 완료되면 즉시 Slack DM 확인

# 같은 질문을 다시 하면 중복 방지로 알림이 가지 않는다
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

# settings.json에서 UserPromptSubmit 훅 제거
jq 'del(.hooks.UserPromptSubmit)' ~/.claude/settings.json > ~/.claude/settings.json.tmp
mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```

## 디버그

훅 실행 로그는 다음 위치에 저장된다:
```
~/.claude/hooks/debug.log
```

로그 확인:
```bash
tail -f ~/.claude/hooks/debug.log
```

## 문제 해결

### 알림이 오지 않을 때

1. **환경변수 확인:**
   ```bash
   echo $SLACK_BOT_TOKEN
   echo $SLACK_USER_ID
   ```

   비어있으면:
   ```bash
   source ~/.bashrc  # 또는 ~/.zshrc
   ```

2. **훅 설정 확인:**
   ```bash
   cat ~/.claude/settings.json | jq '.hooks.UserPromptSubmit'
   ```

   UserPromptSubmit 훅이 등록되어 있는지 확인한다.

3. **Slack Bot 권한 확인:**
   - https://api.slack.com/apps 에서 앱 선택
   - "OAuth & Permissions" → `chat:write` 권한이 있는지 확인한다
   - Token이 `xoxb-`로 시작하는지 확인한다

4. **중복 방지 파일 초기화:**
   ```bash
   rm ~/.claude/hooks/.last_sent
   ```

   그 후 다시 질문해 본다.

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
# 스크립트가 자동으로 기존 설정을 제거하고 재설치한다
```
