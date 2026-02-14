---
description: 1줄 컴팩트 statusline v3 설치 (플랜 감지 + 요소 커스터마이즈)
allowed-tools: Read, Bash, Edit, Glob, AskUserQuestion, Write
---

# Setup Statusline v3

lean-kit의 1줄 컴팩트 statusline을 설치하고, 플랜 타입에 맞는 최적 설정을 구성합니다.

## 절차

### Step 1: statusline.sh 복사

이 플러그인의 `scripts/statusline.sh`를 `~/.claude/statusline.sh`로 복사합니다.

1. Glob으로 `scripts/statusline.sh` 경로 확인
2. Bash 실행:
   ```bash
   cp <확인된_절대경로> ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
   ```

### Step 2: 플랜 자동 감지

`~/.claude.json`에서 플랜 타입을 감지합니다:
- `billingType=stripe_subscription` + `hasExtraUsageEnabled=true` → **Max**
- `billingType=stripe_subscription` + `hasExtraUsageEnabled=false` → **Pro**
- oauthAccount 없음 → **API**

감지 결과를 AskUserQuestion으로 확인/수정:
```
감지된 플랜: {detected_plan}
이 플랜이 맞습니까?
옵션: [맞습니다] [Pro] [Max] [API]
```

### Step 3: 표시 요소 선택

플랜별 기본 추천값을 제시하고 사용자 커스터마이즈를 받습니다.

**기본 추천값:**
- **Pro**: 💰 비용 OFF, 나머지 ON
- **Max**: 💰 비용 OFF, ⚡ Extra ON, 나머지 ON
- **API**: ⚡ Extra OFF, 나머지 ON

AskUserQuestion(multiSelect)으로 OFF할 요소를 선택:
```
추천 설정을 기반으로, 추가로 끄고 싶은 요소가 있나요?
옵션 (multiSelect):
[ ] 👤 계정 (SHOW_ACCOUNT)
[ ] 📁 디렉토리 (SHOW_DIR)
[ ] 🌿 Git (SHOW_GIT)
[ ] 🤖 모델 (SHOW_MODEL)
[ ] 🧠 컨텍스트 (SHOW_CONTEXT)
[ ] 💰 비용 (SHOW_COST)
[ ] 📋 플랜 (SHOW_PLAN)
[ ] ⚡ Extra (SHOW_EXTRA_USAGE)
[ ] ⌛ 세션 (SHOW_SESSION)
```

### Step 4: statusline.conf 생성

사용자 선택을 반영한 `~/.claude/statusline.conf` 파일을 Write로 생성:
```bash
# lean-kit statusline v3.0 설정
# 0=숨김, 1=표시
SHOW_ACCOUNT=1
SHOW_DIR=1
SHOW_GIT=1
SHOW_MODEL=1
SHOW_CONTEXT=1
SHOW_COST=0          # Pro/Max 추천: OFF
SHOW_SESSION=1
SHOW_PLAN=1
SHOW_EXTRA_USAGE=1
PLAN_TYPE=           # 빈 값이면 자동 감지
```

### Step 5: settings.json 설정

`~/.claude/settings.json`을 Read로 읽음:
- `statusLine` 필드가 이미 있으면 → AskUserQuestion으로 교체 확인
- 없거나 동의 → Edit으로 추가:
  ```json
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
  ```
- 다른 필드는 절대 수정하지 않음

### Step 6: 검증

```bash
echo '{"cwd":"/tmp","model":{"display_name":"Opus"}}' | ~/.claude/statusline.sh
```

1줄 출력에 설정한 요소가 표시되면 성공. Claude Code 재시작 시 적용.

## 출력 항목

| 아이콘 | 항목 | 설명 |
|--------|------|------|
| 👤 | Anthropic 계정 | ~/.claude.json의 이메일 |
| 📁 | 작업 디렉토리 | 현재 프로젝트 경로 |
| 🌿 | Git 브랜치 | 현재 브랜치/커밋 |
| 🤖 | 모델명 | Claude 모델 |
| 🧠 | 컨텍스트 잔여율 | 프로그레스바 포함 |
| 💰 | 비용 + 번레이트 | API 사용자용 ($/h) |
| 📋 | 플랜 타입 | Pro/Max/API |
| ⚡ | Extra Usage | Max 플랜 전용 |
| ⌛ | 세션 잔여시간 | ccusage 연동 |

## 설정 파일

`~/.claude/statusline.conf`로 표시 요소를 제어합니다.
`STATUSLINE_CONF` 환경변수로 경로를 오버라이드할 수 있습니다.
