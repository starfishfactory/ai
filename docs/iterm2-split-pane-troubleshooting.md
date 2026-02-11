# iTerm2에서 Claude Code Agent Teams 창 분할 트러블슈팅

## TL;DR

**전제조건**: `~/.claude/settings.json`에 환경변수 설정이 필요합니다.

```bash
# 방식 A (tmux) — 가장 안정적
tmux -CC new-session claude

# 방식 B (it2) — tmux 없이 iTerm2 네이티브
claude --teammate-mode tmux

# in-process — split pane 없이 사용
claude --teammate-mode in-process
```

---

## 1. 개요

### 1.1 teammate 모드 의사결정 트리

Claude Code의 teammate 모드는 세 가지가 있습니다:

```
"auto" (기본값):
├─ tmux 세션 안에서 실행 → split pane 자동 활성화
└─ 일반 터미널에서 실행 → in-process 모드로 폴백 (split pane 안 됨)

"tmux" (--teammate-mode tmux):
├─ tmux 세션 안에서 실행 → tmux split pane 사용
└─ tmux 세션 밖 + iTerm2 + it2 → iTerm2 네이티브 split pane 사용

"in-process" (--teammate-mode in-process):
└─ split pane 없음, Shift+Up/Down으로 teammate 전환
```

> **주의**: `"auto"` 모드에서는 tmux 세션 밖이면 split pane이 작동하지 않습니다. it2를 사용하려면 반드시 `--teammate-mode tmux`를 지정하세요.

### 1.2 settings.json 설정

`~/.claude/settings.json`에 Agent Teams 환경변수를 설정합니다:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

설정 확인:

```bash
echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
# → "1"이 출력되면 정상
```

> **참고**: `teammateMode`는 settings.json의 유효한 필드가 아닙니다. teammate 모드는 환경 자동 감지 또는 CLI 플래그 `--teammate-mode tmux`로 지정합니다.

---

## 2. 방식 A — tmux

tmux 세션 안에서 Claude Code를 실행하여 split pane을 사용하는 방식입니다.

> **핵심**: split pane 백엔드로 **tmux** 또는 **it2(iTerm2 네이티브)** 중 하나만 있으면 됩니다. 둘 다 설치할 필요는 없습니다.

> **참고**: tmux 기본 사용법이 익숙하지 않다면 [tmux 사용법 가이드](./tmux-usage-guide.md)를 먼저 참고하세요.

### 2.1 설치

```bash
# macOS
brew install tmux

# Linux (Ubuntu/Debian)
sudo apt install tmux
```

설치 확인:

```bash
which tmux && tmux -V
```

### 2.2 실행

세 가지 실행 선택지가 있습니다. 상황에 맞게 선택하세요.

#### 선택지 1: tmux -CC (가장 권장)

iTerm2의 네이티브 tmux 통합 모드를 사용합니다:

```bash
tmux -CC new-session claude
```

- `-CC` 플래그가 iTerm2 control sequence 모드를 활성화합니다.
- iTerm2가 tmux 세션을 네이티브 탭/창으로 관리하여 가장 안정적입니다.

#### 선택지 2: 일반 tmux 세션

```bash
tmux new-session -s work
# 세션 진입 후:
claude
```

- Claude Code의 auto 모드가 `$TMUX` 환경변수를 감지하여 자동으로 split pane을 활성화합니다.
- `echo $TMUX` 실행 → 값이 출력되면 tmux 세션 안입니다.

#### 선택지 3: CLI 플래그로 강제 지정

settings.json 설정이 적용되지 않을 때 또는 일회성 테스트 시 사용합니다:

```bash
tmux new-session -s test "claude --teammate-mode tmux"
```

> **참고**: CLI 플래그가 settings.json보다 우선순위가 높습니다.

### 2.3 알려진 이슈: #23615 레이스 컨디션

**증상**:
- 4명 이상의 teammate를 동시에 spawn할 때 split pane 명령이 꼬입니다.
- 실행되는 명령어가 깨져서 `mmcd`, `mentcd` 같은 이상한 명령이 실행됩니다.

**원인**:
- Claude Code가 현재 pane을 `split-window`로 분할하는 방식을 사용합니다.
- 여러 pane 생성을 동시에 처리할 때 tmux의 command queue에서 race condition이 발생합니다.
- 특히 4명 이상의 teammate 동시 spawn에서 발생 빈도가 높습니다.

**대응**: teammate 수를 2~3명으로 제한하면 대부분 회피할 수 있습니다.

**GitHub Issue**: [#23615](https://github.com/anthropics/claude-code/issues/23615)

---

## 3. 방식 B — it2

tmux 없이 iTerm2의 네이티브 split pane을 사용하는 방식입니다. `it2` CLI를 통해 iTerm2 Python API와 통신합니다.

### 3.1 설치

```bash
pip3 install --upgrade it2
```

> **주의**: macOS 기본 환경에는 `pip`이 없고 `pip3`만 사용 가능합니다.

설치 후 `it2`가 PATH에 없다면:

```bash
# PATH에 추가
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
# 영구 적용하려면 ~/.zshrc에도 추가하세요
```

`pip3`로 설치한 `it2`가 작동하지 않는다면 iTerm2 내장 바이너리를 사용할 수 있습니다:

```bash
# iTerm2 내장 it2 확인
/Applications/iTerm.app/Contents/MacOS/it2 --help

# 심볼릭 링크로 등록
ln -s /Applications/iTerm.app/Contents/MacOS/it2 /usr/local/bin/it2
```

설치 확인:

```bash
which it2 && it2 --version
# → v0.1.9 이상이어야 합니다
```

### 3.2 iTerm2 Python API 활성화

1. **iTerm2 → Settings → General** 메뉴를 엽니다.
2. **Magic** 섹션을 찾습니다 (General 탭 하단).
3. **"Enable Python API"** 체크박스를 선택합니다.
4. iTerm2를 재시작합니다 (권장).

### 3.3 실행

tmux 세션 **밖**의 일반 iTerm2 탭에서 실행합니다:

```bash
claude --teammate-mode tmux
```

> **주의**: `--teammate-mode tmux`라는 이름이지만, tmux 세션 밖에서 실행하면 자동으로 it2 백엔드를 사용합니다. `echo $TMUX` 실행 → 빈 값이면 it2가 사용됩니다.

### 3.4 알려진 이슈: #23572 조용한 실패

**증상**:
- `--teammate-mode tmux`를 지정했는데도 split pane이 작동하지 않습니다.
- **오류 메시지 없이** 조용히 in-process 모드로 폴백됩니다.

**원인**:
- `it2` CLI v0.1.8 이하에서 `shortcuts.py` 파라미터 이름 불일치 버그가 있습니다.
- Claude Code가 `it2 split` 명령 실행 시 검증에 실패하지만, 아무 알림 없이 in-process 모드로 폴백됩니다.

**기술 세부사항**:

```
잘못된 구문: it2 split --vertical
올바른 구문: it2 session split --vertical

버전 0.1.8: TypeError (session vs session_id 불일치)
버전 0.1.9+: 수정됨 (단, v0.2.0에서도 일부 사용자 보고 있음)
```

**해결**:

```bash
# 현재 버전 확인
pip3 show it2

# v0.1.9 이상으로 업그레이드
pip3 install --upgrade it2

# 캐시 문제 시 강제 재설치
pip3 install --force-reinstall it2
```

**GitHub Issue**: [#23572](https://github.com/anthropics/claude-code/issues/23572)

---

## 4. 트러블슈팅

### 4.1 진단 스크립트

아래 스크립트를 실행하면 현재 환경의 설정 상태를 한눈에 확인할 수 있습니다:

```bash
echo "=== 진단 결과 ==="
echo "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS"
echo "tmux version: $(tmux -V 2>/dev/null || echo 'NOT INSTALLED')"
echo "it2 version: $(it2 --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "TMUX session: ${TMUX:-NOT IN TMUX}"
echo ""
echo "=== 사용 가능한 방식 ==="
if [ -n "$TMUX" ]; then
  echo "✅ 방식 A (tmux): 현재 tmux 세션 안 → 바로 claude 실행 가능"
else
  echo "ℹ️  방식 A (tmux): tmux 세션 밖 → tmux new-session 필요"
fi
if command -v it2 &>/dev/null; then
  echo "✅ 방식 B (it2): it2 설치됨 → claude --teammate-mode tmux 실행 가능"
else
  echo "❌ 방식 B (it2): it2 미설치 → pip3 install it2 필요"
fi
```

### 4.2 체크리스트

split pane이 작동하지 않는다면 아래 항목을 확인하세요.

#### 공통

```
□ echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS → "1"이 출력되는가?
□ ~/.claude/settings.json에 "env" 섹션이 올바르게 설정되어 있는가?
□ teammate 수가 4명 이상은 아닌가? (레이스 컨디션 회피)
```

#### tmux prefix 키 충돌

```
□ Claude Code 실행 중 Ctrl+b가 안 먹히는가? → tmux 사용법 가이드 섹션 2.2 참고
```

> 자세한 해결 방법은 [tmux 사용법 가이드 — Ctrl+b가 안 먹힐 때](./tmux-usage-guide.md#22-ctrlb가-안-먹힐-때)를 참고하세요.

#### 방식 A (tmux)

```
□ which tmux → 경로가 출력되는가?
□ echo $TMUX → 값이 출력되는가? (tmux 세션 안인지 확인)
```

#### 방식 B (it2)

```
□ which it2 → 경로가 출력되는가?
□ it2 --version → v0.1.9 이상인가?
□ iTerm2 Settings → General → Magic → "Enable Python API"가 체크되어 있는가?
□ echo $TMUX → 빈 값인가? (tmux 세션 밖에서 실행해야 함)
□ --teammate-mode tmux 플래그를 사용하고 있는가?
```

---

## 5. 부록

### 5.1 iTerm2 Dynamic Profile

매번 명령을 수동으로 입력하는 대신, iTerm2 프로필에 등록하면 편리합니다. 방식 A(tmux)와 방식 B(it2) 프로필을 모두 등록해두면 상황에 따라 선택할 수 있습니다.

다음 파일을 생성하세요:

**`~/Library/Application Support/iTerm2/DynamicProfiles/tmux-claude.json`**

```json
{
  "Profiles": [
    {
      "Name": "Claude Teams (tmux)",
      "Guid": "tmux-claude-teams-profile",
      "Initial Text": "tmux new-session -A -s main",
      "Custom Directory": "Recycle"
    },
    {
      "Name": "Claude Teams (it2 네이티브)",
      "Guid": "it2-claude-teams-profile",
      "Initial Text": "claude --teammate-mode tmux",
      "Custom Directory": "Recycle"
    }
  ]
}
```

**사용**:
1. iTerm2 → Profiles (`Cmd + O`) → 원하는 프로필을 선택합니다.
   - **"Claude Teams (tmux)"**: tmux 세션 진입 → `claude` 실행
   - **"Claude Teams (it2 네이티브)"**: tmux 없이 바로 claude 실행 (it2로 split pane)
2. 기본 프로필로 설정하려면: Settings → Profiles → 원하는 프로필 → **Set as Default**

> **참고**: tmux 프로필의 `-A` 플래그는 기존 `main` 세션이 있으면 재접속하고, 없으면 새로 생성합니다. `Recycle`은 이전 작업 디렉토리를 유지합니다.

### 5.2 in-process 모드 (split pane 대안)

split pane 설정이 어렵거나 터미널 분할이 필요 없다면 in-process 모드를 사용할 수 있습니다:

```bash
claude --teammate-mode in-process
```

- split pane 없이 모든 teammate이 같은 터미널 공간을 공유합니다.
- **Shift+Up/Down** 단축키로 teammate 간 전환이 가능합니다.

### 5.3 참고 자료

**내부 가이드**:
- [tmux 사용법 가이드](./tmux-usage-guide.md) — tmux 핵심 개념, 명령어, 설정

**공식 문서**:
- [Claude Code - Orchestrate teams of Claude Code sessions](https://code.claude.com/docs/en/agent-teams)
- [iTerm2 tmux Integration](https://iterm2.com/documentation-tmux-integration.html)

**GitHub Issues**:
- [#23572 - tmux 모드 조용한 폴백 버그](https://github.com/anthropics/claude-code/issues/23572)
- [#23615 - tmux split pane 레이스 컨디션](https://github.com/anthropics/claude-code/issues/23615)
- [#23574 - WezTerm 백엔드 요청](https://github.com/anthropics/claude-code/issues/23574)

**커뮤니티 가이드**:
- [Addy Osmani - Claude Code Swarms](https://addyosmani.com/blog/claude-code-agent-teams/)
- [marc0.dev - Claude Code Agent Teams Setup Guide](https://www.marc0.dev/en/blog/claude-code-agent-teams-multiple-ai-agents-working-in-parallel-setup-guide-1770317684454)
- [Javier Aguilar - Scaling your Agentic Workflow](https://www.javieraguilar.ai/en/blog/claude-code-agent-teams)

---

**마지막 업데이트**: 2026-02-11
**참고**: 이 가이드는 Claude Code v2.1.38 기준이며, 향후 버전에서 개선될 수 있습니다.
