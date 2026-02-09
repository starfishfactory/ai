# lean-kit

Claude Code를 위한 경량 유틸리티 플러그인. macOS 네이티브 알림과 퍼미션 자동 승인을 지원합니다.

## 기능

### 1. Notification - macOS 데스크톱 알림

사용자 입력이 필요할 때 macOS 네이티브 알림으로 알려줍니다.

| 이벤트 | 설명 | 알림 제목 |
|--------|------|-----------|
| `permission_prompt` | 도구 사용 권한 승인 필요 | Claude Code - 승인 필요 |
| `idle_prompt` | 유휴 상태, 입력 대기 | Claude Code - 입력 대기 |
| `elicitation_dialog` | 질문 응답 필요 | Claude Code - 응답 필요 |

### 2. Auto-permit - 퍼미션 자동 승인

`PermissionRequest` 훅을 사용하여 안전한 도구/명령어를 자동 승인합니다.
세션마다 반복되는 퍼미션 질의를 줄여줍니다.

**활성화 방법:**

```bash
export LEAN_KIT_AUTO_PERMIT=1
```

> 기본값은 비활성화(opt-in). 환경변수를 설정해야만 작동합니다.

**동작 원리:**
1. 퍼미션 다이얼로그 표시 직전에 훅 실행
2. `~/.claude/hooks/lean-kit-permit.conf` 설정 파일 참조
3. Bash 명령어: 거부 목록 우선 체크 → 허용 접두사 매칭
4. Edit/Write: 민감 파일 거부 체크 → 자동 승인
5. 미분류: 기존처럼 사용자에게 질의 (안전한 폴백)

## 설치

### 방법 1: 마켓플레이스 (권장)

클론 없이 Claude Code 안에서 바로 설치합니다.

```shell
/plugin marketplace add starfishfactory/ai
/plugin install lean-kit@starfishfactory-ai
```

> **Private repo**: `gh auth login`으로 GitHub 인증이 되어 있으면 동작합니다.

auto-permit을 사용하려면 설정 파일을 수동으로 복사해야 합니다:

```bash
# 플러그인 캐시 경로에서 기본 설정 파일 복사
cp ~/.claude/plugins/cache/starfishfactory-ai/lean-kit/*/scripts/lean-kit-permit.conf \
   ~/.claude/hooks/lean-kit-permit.conf
```

### 방법 2: 플러그인 모드

repo를 클론한 후 로컬 경로를 지정합니다.

```bash
claude --plugin-dir ./plugins/lean-kit
```

auto-permit을 사용하려면 설정 파일을 수동으로 복사해야 합니다:

```bash
mkdir -p ~/.claude/hooks
cp ./plugins/lean-kit/scripts/lean-kit-permit.conf ~/.claude/hooks/
```

### 방법 3: 직접 설치 (standalone)

`~/.claude/settings.json`에 훅을 직접 등록합니다. jq가 없으면 brew를 통한 설치를 안내합니다.

```bash
./plugins/lean-kit/install.sh
```

설치 후 Claude Code를 재시작하세요.

## 설정 파일

auto-permit 설정 파일(`~/.claude/hooks/lean-kit-permit.conf`)은 INI 스타일 섹션으로 구성됩니다.
직접 설치(`install.sh`)에서는 자동 복사되지만, 마켓플레이스/플러그인 모드에서는 수동 복사가 필요합니다.
설정 파일이 없으면 auto-permit이 비활성화되어 기존 동작(사용자 질의)과 동일합니다.

### 섹션 설명

| 섹션 | 매칭 방식 | 용도 |
|------|-----------|------|
| `[deny_bash]` | 포함 패턴 | Bash 명령어 거부 (우선 평가) |
| `[allow_bash]` | 접두사 매칭 | Bash 명령어 자동 승인 |
| `[deny_files]` | 포함 패턴 | 파일 수정 거부 (사용자 질의로 폴백) |
| `[allow_tools]` | 정확한 이름 | 도구 자동 승인 |
| `[allow_mcp]` | glob 패턴 | MCP 도구 자동 승인 |

### 커스터마이징 예시

```conf
# Bash 접두사 추가
[allow_bash]
terraform
kubectl

# 특정 MCP 도구 허용
[allow_mcp]
mcp__slack__post*

# 민감 경로 보호 추가
[deny_files]
/etc/
production.yml
```

> 수정 후 Claude Code 세션을 재시작하면 적용됩니다.

## 환경변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `LEAN_KIT_SOUND` | `Glass` | 알림 소리 이름. 비워두면 무음 (`export LEAN_KIT_SOUND=`) |
| `LEAN_KIT_AUTO_PERMIT` | `0` | `1`로 설정하면 퍼미션 자동 승인 활성화 |
| `LEAN_KIT_PERMIT_CONF` | `~/.claude/hooks/lean-kit-permit.conf` | 설정 파일 경로 오버라이드 |
| `LEAN_KIT_DEBUG` | `0` | `1`로 설정하면 `~/.claude/hooks/lean-kit-debug.log`에 로그 기록 |

```bash
# 소리 변경
export LEAN_KIT_SOUND=Ping

# 무음
export LEAN_KIT_SOUND=

# 퍼미션 자동 승인 활성화
export LEAN_KIT_AUTO_PERMIT=1

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

> 설정 파일(`lean-kit-permit.conf`)은 사용자 수정 보존을 위해 자동 삭제되지 않습니다. 수동 삭제: `rm ~/.claude/hooks/lean-kit-permit.conf`

### 플러그인 모드

`--plugin-dir` 옵션을 제거하면 됩니다.

## 제한사항

- **macOS 전용** (알림): Linux/Windows에서는 자동으로 무시됩니다 (exit 0)
- **GUI 세션 필요** (알림): SSH, CI 등 headless 환경에서는 자동으로 무시됩니다
- **non-interactive 모드 미지원** (auto-permit): `claude -p` 모드에서는 `PermissionRequest` 훅이 작동하지 않습니다. 공식 문서에 따르면 이 경우 `PreToolUse` 훅을 사용해야 합니다.
- **race condition 가능성** (auto-permit): 훅 응답이 1-2초 이상 걸리면 퍼미션 다이얼로그가 먼저 표시될 수 있습니다 ([#12176](https://github.com/anthropics/claude-code/issues/12176)). 스크립트는 수십 밀리초 내 응답하도록 최적화되어 있습니다.
- **세션 재시작**: 직접 설치 후 Claude Code 재시작 필요
- **설정 파일 수동 복사** (auto-permit): 마켓플레이스/플러그인 모드에서는 `install.sh`가 실행되지 않으므로 `lean-kit-permit.conf`를 `~/.claude/hooks/`에 수동 복사해야 합니다. 설정 파일이 없으면 auto-permit이 비활성화됩니다.
- **jq 의존성**: 직접 설치(`install.sh`/`uninstall.sh`) 시 jq 필요. 플러그인 모드의 `notify.sh`는 jq 없이도 동작 (fallback 메시지 사용). `auto-permit.sh`는 jq 없으면 자동 비활성화 (사용자 질의로 폴백).

## 구조

```
plugins/lean-kit/
├── .claude-plugin/
│   └── plugin.json              # 플러그인 매니페스트
├── hooks/
│   └── hooks.json               # 훅 설정 (플러그인 모드)
├── scripts/
│   ├── notify.sh                # macOS 알림 스크립트
│   ├── auto-permit.sh           # 퍼미션 자동 승인 스크립트
│   └── lean-kit-permit.conf     # 기본 설정 파일 (install.sh가 복사)
├── install.sh                   # 직접 설치
├── uninstall.sh                 # 제거
└── README.md
```
