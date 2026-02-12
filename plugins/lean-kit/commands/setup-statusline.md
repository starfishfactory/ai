---
description: 1줄 컴팩트 statusline 설치
allowed-tools: Read, Bash, Edit, Glob, AskUserQuestion
---

# Setup Statusline

lean-kit의 1줄 컴팩트 statusline을 설치합니다.

## 절차

### Step 1: statusline.sh 복사

이 플러그인의 `scripts/statusline.sh`를 `~/.claude/statusline.sh`로 복사합니다.

1. Glob으로 `scripts/statusline.sh` 경로 확인
2. Bash 실행:
   ```bash
   cp <확인된_절대경로> ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
   ```

### Step 2: settings.json 설정

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

### Step 3: 검증

```bash
echo '{"cwd":"/tmp","model":{"display_name":"Opus"}}' | ~/.claude/statusline.sh
```

1줄 출력에 📁, 🤖 아이콘이 있으면 성공. Claude Code 재시작 시 적용.

## 출력 항목

| 아이콘 | 항목 |
|--------|------|
| 👤 | Anthropic 계정 |
| 📁 | 작업 디렉토리 |
| 🌿 | Git 브랜치 |
| 🤖 | 모델명 |
| 🧠 | 컨텍스트 잔여율 |
| 💰 | 비용 + 번레이트 |
| ⌛ | 세션 잔여시간 |
