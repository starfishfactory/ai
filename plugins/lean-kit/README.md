# lean-kit

Claude Code 작업 중 사용자 입력이 필요할 때 macOS 네이티브 알림으로 알려주는 경량 유틸리티 플러그인.

## 지원 이벤트

| 이벤트 | 설명 | 알림 제목 |
|--------|------|-----------|
| `permission_prompt` | 도구 사용 권한 승인 필요 | Claude Code - 승인 필요 |
| `idle_prompt` | 유휴 상태, 입력 대기 | Claude Code - 입력 대기 |
| `elicitation_dialog` | 질문 응답 필요 | Claude Code - 응답 필요 |

## 설치

### 방법 1: 마켓플레이스 (권장)

클론 없이 Claude Code 안에서 바로 설치합니다.

```shell
/plugin marketplace add starfishfactory/ai
/plugin install lean-kit@starfishfactory-ai
```

> **Private repo**: `gh auth login`으로 GitHub 인증이 되어 있으면 동작합니다.

### 방법 2: 플러그인 모드

repo를 클론한 후 로컬 경로를 지정합니다.

```bash
claude --plugin-dir ./plugins/lean-kit
```

### 방법 3: 직접 설치 (standalone)

`~/.claude/settings.json`에 훅을 직접 등록합니다. jq가 없으면 brew를 통한 설치를 안내합니다.

```bash
./plugins/lean-kit/install.sh
```

설치 후 Claude Code를 재시작하세요.

## 환경변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `LEAN_KIT_SOUND` | `Glass` | 알림 소리 이름. 비워두면 무음 (`export LEAN_KIT_SOUND=`) |
| `LEAN_KIT_DEBUG` | `0` | `1`로 설정하면 `~/.claude/hooks/lean-kit-debug.log`에 로그 기록 |

```bash
# 소리 변경
export LEAN_KIT_SOUND=Ping

# 무음
export LEAN_KIT_SOUND=

# 디버그 로깅 활성화
export LEAN_KIT_DEBUG=1
```

## macOS 알림 설정

알림이 표시되지 않으면 macOS 알림 설정을 확인하세요:

1. **시스템 설정** > **알림** > **Script Editor** (또는 **osascript**)
2. **알림 허용**이 켜져 있는지 확인
3. 배너 또는 경고 스타일 선택

## 제거

### 마켓플레이스

```shell
/plugin uninstall lean-kit@starfishfactory-ai
```

### 직접 설치한 경우

```bash
./plugins/lean-kit/uninstall.sh
```

### 플러그인 모드

`--plugin-dir` 옵션을 제거하면 됩니다.

## 제한사항

- **macOS 전용**: Linux/Windows에서는 자동으로 무시됩니다 (exit 0)
- **GUI 세션 필요**: SSH, CI 등 headless 환경에서는 자동으로 무시됩니다
- **세션 재시작**: 직접 설치 후 Claude Code 재시작 필요
- **jq 의존성**: 직접 설치(`install.sh`/`uninstall.sh`) 시 jq 필요. 플러그인 모드의 `notify.sh`는 jq 없이도 동작 (fallback 메시지 사용)

## 구조

```
plugins/lean-kit/
├── .claude-plugin/
│   └── plugin.json           # 플러그인 매니페스트
├── hooks/
│   └── hooks.json            # 훅 설정 (플러그인 모드)
├── scripts/
│   └── notify.sh             # macOS 알림 스크립트
├── install.sh                # 직접 설치
├── uninstall.sh              # 제거
└── README.md
```
