---
description: lean-kit 전체 기능 안내 및 활성화 상태 확인
allowed-tools: Read, Bash
---

# lean-kit Guide

lean-kit 플러그인의 3가지 기능 상태를 확인하고, 활성화 방법을 안내합니다.

---

## Step 1: 활성화 상태 확인

다음 2가지를 순서대로 확인하여 내부 변수로 기억합니다.

### 1-1. Statusline 상태

`~/.claude/settings.json`을 Read로 읽습니다.

- `statusLine.command`에 `statusline.sh`가 포함되어 있으면 → `statusline_active=true`
- 포함되어 있지 않거나 파일이 없으면 → `statusline_active=false`

### 1-2. Auto-permit 상태

Bash로 실행합니다:

```bash
echo "${LEAN_KIT_AUTO_PERMIT:-0}"
```

- 출력이 `1` → `autopermit_active=true`
- 그 외 → `autopermit_active=false`

> **참고**: Notification은 플러그인 설치 시 hooks.json으로 자동 등록되므로 별도 확인이 필요 없습니다. 항상 활성 상태입니다.

## Step 2: 기능 가이드 출력

아래 내용을 **markdown으로 직접 렌더링**하여 출력합니다. 코드 블록 안에 넣지 않습니다. 각 기능의 **상태** 열은 Step 1 결과에 따라 ✅ 활성 / ❌ 미설정으로 동적 표시합니다.

---

요약 테이블:

| # | 기능 | 설명 | 플랫폼 | 상태 |
|---|------|------|--------|------|
| 1 | Notification | 승인/입력 필요 시 macOS 데스크톱 알림 | macOS | ✅ 자동 활성 |
| 2 | Auto-permit | 안전한 도구/명령어 퍼미션 자동 승인 | 전체 | Step 1-2 결과 |
| 3 | Statusline | 터미널 하단 1줄 컴팩트 상태 표시줄 | 전체 | Step 1-1 결과 |

기능 1 — **Notification (macOS 데스크톱 알림)**:

사용자 입력이 필요할 때(승인, 유휴, 질문) macOS 네이티브 알림을 표시합니다.

- 상태: 플러그인 설치 시 자동 활성 (hooks.json 내장)
- 플랫폼: macOS 전용 (non-macOS에서는 자동 스킵)
- 조건: GUI 세션 필요 (SSH/headless 환경에서는 자동 스킵)

환경변수:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `LEAN_KIT_SOUND` | `Glass` | 알림 소리 (빈 문자열 = 무음) |
| `LEAN_KIT_DEBUG` | `0` | `1`이면 디버그 로그 기록 |

기능 2 — **Auto-permit (퍼미션 자동 승인)**:

안전한 Bash 명령어, 파일 수정, MCP 읽기 도구를 자동 승인합니다.

- 상태: **opt-in 필수** (`LEAN_KIT_AUTO_PERMIT=1` 설정 필요)
- 의존성: `jq` (미설치 시 자동 스킵)
- 커스터마이징: `~/.claude/hooks/lean-kit-permit.conf`

환경변수:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `LEAN_KIT_AUTO_PERMIT` | `0` | `1`이면 활성화 |
| `LEAN_KIT_DEBUG` | `0` | `1`이면 디버그 로그 기록 |
| `LEAN_KIT_PERMIT_CONF` | `~/.claude/hooks/lean-kit-permit.conf` | 커스텀 규칙 파일 경로 |

기능 3 — **Statusline (1줄 컴팩트 상태 표시줄)**:

터미널 하단에 계정, 디렉토리, 브랜치, 모델, 컨텍스트, 비용, 세션 정보를 1줄로 표시합니다.

- 상태: `~/.claude/settings.json`의 `statusLine.command` 수동 설정 필요
- 설정 방법: `/lean-kit:setup-statusline` 실행
- 의존성: `jq` (기본), `ccusage` (세션 잔여시간, 선택)

출력 항목:

| 아이콘 | 항목 |
|--------|------|
| 👤 | Anthropic 계정 |
| 📁 | 작업 디렉토리 |
| 🌿 | Git 브랜치 |
| 🤖 | 모델명 |
| 🧠 | 컨텍스트 잔여율 |
| 💰 | 비용 + 번레이트 |
| ⌛ | 세션 잔여시간 |

---

## Step 3: 조치 필요 사항 안내

Step 1 결과에 따라 조치가 필요한 항목만 안내합니다.

- `autopermit_active=false`인 경우 → 다음을 안내:

  > Auto-permit을 활성화하려면 셸 프로필(`.zshrc` 등)에 추가하세요:
  > `export LEAN_KIT_AUTO_PERMIT=1`
  > 현재 세션에서 바로 사용하려면 터미널에서 동일 명령을 실행하세요.

- `statusline_active=false`인 경우 → 다음을 안내:

  > Statusline을 설정하려면 `/lean-kit:setup-statusline`을 실행하세요.

- 모든 기능이 활성 상태인 경우 → 다음을 출력:

  > 모든 기능이 활성화되어 있습니다!
