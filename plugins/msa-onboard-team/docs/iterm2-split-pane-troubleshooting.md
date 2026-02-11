# iTerm2에서 Claude Code Agent Teams 창 분할 트러블슈팅

## 1. 필수 설정 체크리스트

Agent Teams의 split pane 모드를 활성화하려면 아래 항목을 확인하세요.

> **핵심**: split pane 백엔드로 **tmux** 또는 **it2(iTerm2 네이티브)** 중 하나만 있으면 됩니다. 둘 다 설치할 필요는 없습니다.

### 공통 필수 항목

| # | 체크 항목 | 설정 방법 | 확인 방법 |
|---|---------|---------|---------|
| 1 | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 환경변수 | `~/.claude/settings.json`에 추가: `"env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }` | 터미널에서 `echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` |

### 방식 A: tmux 사용 (tmux 세션 안에서 실행)

| # | 체크 항목 | 설정 방법 | 확인 방법 |
|---|---------|---------|---------|
| A-1 | tmux 설치 | macOS: `brew install tmux` / Linux: `sudo apt install tmux` | `which tmux` 또는 `tmux -V` |
| A-2 | tmux 세션 안에서 claude 실행 | `tmux new-session -s work` 후 `claude` 실행 | `echo $TMUX`로 tmux 세션 확인 |

### 방식 B: it2 사용 (iTerm2 네이티브 split pane, tmux 불필요)

| # | 체크 항목 | 설정 방법 | 확인 방법 |
|---|---------|---------|---------|
| B-1 | `it2` CLI 설치 | `pip3 install --upgrade it2` (macOS 기본 환경에는 `pip`이 없으므로 `pip3` 사용) | `which it2` 실행하여 경로 확인 |
| B-2 | iTerm2 Python API 활성화 | **iTerm2 → Settings → General → Magic → Enable Python API 체크** | iTerm2 메뉴에서 직접 확인 |
| B-3 | tmux 세션 **밖**에서 실행 | 일반 iTerm2 탭에서 `claude --teammate-mode tmux` 실행 | `echo $TMUX` → 빈 값이면 OK |

> **참고**: `--teammate-mode tmux`는 "tmux만 사용하라"는 뜻이 아닙니다. 이 플래그를 설정하면 Claude Code가 환경을 자동 감지하여, tmux 세션 안이면 tmux split pane을, tmux 세션 밖이고 iTerm2 + it2가 있으면 iTerm2 네이티브 split pane을 사용합니다.

---

## 2. "auto" 모드와 "tmux" 모드의 동작 방식

공식 문서에 따르면 teammate 모드는 다음과 같이 작동합니다:

```
"auto" 모드 (기본값):
├─ tmux 세션 안에서 실행 → split pane 모드 자동 활성화
└─ 일반 터미널에서 직접 실행 → in-process 모드로 폴백 (split pane 안 됨)

"tmux" 모드 (--teammate-mode tmux):
├─ tmux 세션 안에서 실행 → tmux split pane 사용
└─ tmux 세션 밖 + iTerm2 + it2 → iTerm2 네이티브 split pane 사용
```

**[중요]** `"auto"` 모드에서는 tmux 세션 밖이면 split pane이 작동하지 않습니다. it2 방식을 쓰려면 반드시 `--teammate-mode tmux`를 지정하세요.

- `"auto"` (기본값): tmux 세션 자동 감지 → 있으면 split, 없으면 in-process
- `"tmux"`: split pane 모드 강제 활성화, **환경 자동 감지** (tmux 세션이면 tmux 사용, 아니면 it2 사용)
- `"in-process"`: split pane 사용 안 함 (Shift+Up/Down으로 teammate 전환)

---

## 3. 알려진 버그 및 해결책

### Bug #23572: `it2` CLI의 조용한 실패

**증상**:
- `"teammateMode": "tmux"` 설정했는데도 split pane이 작동하지 않음
- **오류 메시지 없음** - 아무 경고도 표시되지 않고 in-process 모드로 폴백됨

**근본 원인**:
- `it2` CLI 버전 0.1.8 이하에서 `shortcuts.py` 파라미터 이름 불일치 버그
- Claude Code가 `it2 split` 명령 실행 시 검증 실패
- 실패해도 아무 알림 없이 조용히 in-process 모드로 폴백

**기술 세부사항**:
```
잘못된 구문: it2 split --vertical
올바른 구문: it2 session split --vertical

버전 0.1.8: TypeError (session vs session_id 불일치)
버전 0.1.9+: 수정됨 (단, v0.2.0에서도 일부 사용자 보고 있음)
```

**해결 방법**:
```bash
# 현재 버전 확인
pip3 show it2

# v0.1.9 이상으로 업그레이드
pip3 install --upgrade it2

# 설치 후 it2 재설치 (캐시 제거)
pip3 install --force-reinstall it2
```

**GitHub Issue**: [#23572](https://github.com/anthropics/claude-code/issues/23572)

---

### Bug #23615: tmux split pane 레이스 컨디션

**증상**:
- 4명 이상의 teammate를 동시에 spawn할 때 split pane 명령이 꼬임
- 실행되는 명령어가 깨져서 `mmcd`, `mentcd` 같은 이상한 명령이 실행됨

**근본 원인**:
- Claude Code가 현재 pane을 `split-window`로 분할하는 방식 사용
- 여러 pane 생성을 동시에 처리할 때 tmux의 command queue에서 race condition 발생
- 특히 4명 이상의 teammate 동시 spawn에서 발생 빈도 높음

**임시 해결책**:
```
teammate 수를 2~3명으로 제한하면 대부분의 경우 회피 가능
```

**GitHub Issue**: [#23615](https://github.com/anthropics/claude-code/issues/23615)

---

## 4. 검증된 워크어라운드 4가지

### 방법 A: tmux -CC로 시작 (가장 안정적 - 공식 권장)

iTerm2의 네이티브 tmux 통합 모드 사용:

```bash
tmux -CC new-session claude
```

**장점**:
- iTerm2가 tmux 세션을 네이티브 탭/창으로 관리
- 가장 안정적인 split pane 동작
- 공식 문서에서 권장하는 방법

**작동 원리**:
- `-CC` 플래그: iTerm2 control sequence 모드 활성화
- `new-session`: 새로운 tmux 세션 생성
- Claude Code가 이 세션을 감지하여 자동으로 split pane 모드 활성화

---

### 방법 B: tmux 세션 안에서 실행

일반적인 tmux 세션 내에서 claude 실행:

```bash
# 1. 새 tmux 세션 생성
tmux new-session -s claude-work

# 2. 세션 안에서 실행 (세션 생성 후 자동 진입됨)
claude

# 또는 한 줄로:
tmux new-session -s work "claude"
```

**작동 방식**:
- Claude Code의 "auto" 모드가 tmux 환경변수 `$TMUX` 감지
- 자동으로 split pane 모드 활성화

---

### 방법 C: CLI 플래그로 강제 지정

settings.json 설정을 무시하고 CLI 플래그로 직접 지정:

```bash
claude --teammate-mode tmux
```

**용도**:
- `settings.json` 설정이 먹지 않을 때
- 일회성으로 split pane 테스트할 때

**참고**: CLI 플래그가 settings.json보다 우선순위 높음

---

### 방법 D: in-process 모드로 split pane 대신 터미널 전환

split pane 기능을 포기하고 in-process 모드 사용:

```bash
claude --teammate-mode in-process
```

**특징**:
- split pane 없음 (모든 teammate이 같은 터미널 공간 공유)
- **Shift+Up/Down** 단축키로 teammate 간 전환 가능
- 모든 teammate의 출력을 순차적으로 볼 수 있음

**언제 사용**:
- iTerm2 split pane 설정이 복잡할 때
- 터미널 분할 기능이 필요 없을 때

---

## 5. 권장 실행 순서

아래에서 **방식 A(tmux)** 또는 **방식 B(it2)** 중 하나를 선택하여 따라하세요.

### Step 1: settings.json 설정 (공통)

`~/.claude/settings.json` 파일을 열어 다음과 같이 설정:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

> **참고**: `teammateMode`는 settings.json의 유효한 필드가 아닙니다. teammate 모드는 환경 자동 감지 또는 CLI 플래그 `--teammate-mode tmux`로 지정합니다.

---

### 방식 A: tmux 사용

#### Step A-1: tmux 설치

```bash
# macOS
brew install tmux

# Linux (Ubuntu/Debian)
sudo apt install tmux
```

#### Step A-2: tmux로 실행 (3가지 선택지)

##### 선택지 1: tmux -CC (가장 권장)
```bash
tmux -CC new-session claude
```

##### 선택지 2: 일반 tmux 세션
```bash
tmux new-session -s work
# 세션 진입 후:
claude
```

##### 선택지 3: CLI 플래그 (빠른 테스트)
```bash
tmux new-session -s test "claude --teammate-mode tmux"
```

---

### 방식 B: it2 사용 (iTerm2 네이티브, tmux 불필요)

#### Step B-1: it2 설치

```bash
# Python 패키지 (iTerm2용) - macOS에서는 pip3 사용
pip3 install --upgrade it2
```

> **주의**: macOS 기본 환경에는 `pip`이 없고 `pip3`만 사용 가능합니다.
> 설치 후 `it2`가 PATH에 없다면, `~/.zshrc`에 다음을 추가하세요:
> ```bash
> export PATH="$HOME/Library/Python/3.9/bin:$PATH"
> ```

#### Step B-2: iTerm2 Python API 활성화

1. **iTerm2 메뉴 열기**: Preferences → General
2. **Magic 섹션 찾기**: General 탭 → 아래로 스크롤
3. **Python API 활성화**: "Enable Python API" 체크박스 선택
4. **iTerm2 재시작** (선택사항이지만 권장)

#### Step B-3: 실행

```bash
# tmux 세션 밖의 일반 iTerm2 탭에서:
claude --teammate-mode tmux
# → it2를 자동 감지하여 iTerm2 네이티브 split pane 사용
```

> **주의**: `--teammate-mode tmux`라는 이름이지만, tmux 세션 밖에서 실행하면 자동으로 it2 백엔드를 사용합니다.

---

## 6. 트러블슈팅 체크리스트

split pane이 여전히 작동하지 않는다면, 사용 중인 방식에 맞는 항목을 확인하세요:

### 공통 체크
```
□ `echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` → "1" 출력되는가?
□ ~/.claude/settings.json에 "env" 섹션이 있는가?
□ "squadSize"가 4 이상은 아닌가? (레이스 컨디션 회피)
```

### 방식 A (tmux) 체크
```
□ `which tmux` → 경로 출력되는가?
□ tmux 세션 안에서 실행하고 있는가? (`echo $TMUX` → 값이 있는가?)
```

### 방식 B (it2) 체크
```
□ `which it2` → 경로 출력되는가?
□ `it2 --version` → v0.1.9 이상인가?
□ iTerm2 Settings → General → Magic → "Enable Python API" 체크되어 있는가?
□ tmux 세션 밖에서 실행하고 있는가? (`echo $TMUX` → 빈 값인가?)
□ `--teammate-mode tmux` 플래그를 사용하고 있는가?
```

방식별 테스트 명령:
```bash
# 방식 A 테스트:
tmux -CC new-session claude

# 방식 B 테스트:
claude --teammate-mode tmux
```

---

## 7. 출처 및 참고 자료

### 공식 문서
- [Claude Code - Orchestrate teams of Claude Code sessions](https://code.claude.com/docs/en/agent-teams)
- [iTerm2 tmux Integration](https://iterm2.com/documentation-tmux-integration.html)

### GitHub Issues
- [#23572 - tmux 모드 조용한 폴백 버그](https://github.com/anthropics/claude-code/issues/23572)
- [#23615 - tmux split pane 레이스 컨디션](https://github.com/anthropics/claude-code/issues/23615)
- [#23574 - WezTerm 백엔드 요청](https://github.com/anthropics/claude-code/issues/23574)

### 커뮤니티 가이드
- [Addy Osmani - Claude Code Swarms](https://addyosmani.com/blog/claude-code-agent-teams/)
- [marc0.dev - Claude Code Agent Teams Setup Guide](https://www.marc0.dev/en/blog/claude-code-agent-teams-multiple-ai-agents-working-in-parallel-setup-guide-1770317684454)
- [Javier Aguilar - Scaling your Agentic Workflow: Claude Code Agent Teams in tmux](https://www.javieraguilar.ai/en/blog/claude-code-agent-teams)

---

## 추가 팁

### iTerm2 Python API 문제 시

만약 `it2 --help`가 작동하지 않는다면:

```bash
# iTerm2 내장 it2 사용
/Applications/iTerm.app/Contents/MacOS/it2 --help

# 또는 심볼릭 링크 생성
ln -s /Applications/iTerm.app/Contents/MacOS/it2 /usr/local/bin/it2
```

### 빠른 진단

```bash
# 현재 설정 진단 스크립트
echo "=== 진단 결과 ==="
echo "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS"
echo "tmux version: $(tmux -V 2>/dev/null || echo 'NOT INSTALLED')"
echo "it2 version: $(it2 --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "TMUX session: ${TMUX:-NOT IN TMUX (→ it2 방식 사용 가능)}"
echo "settings.json path: ~/.claude/settings.json"
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

### iTerm2 Dynamic Profile로 자동 시작

매번 명령을 수동 입력하는 대신, iTerm2 프로필에 등록하면 편리합니다. 방식 A(tmux)와 방식 B(it2) 프로필을 모두 등록해두면 상황에 따라 선택할 수 있습니다.

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

**사용 방법**:
1. iTerm2 → Profiles (`Cmd + O`) → 원하는 프로필 선택
   - **"Claude Teams (tmux)"**: tmux 세션 진입 → `claude` 실행
   - **"Claude Teams (it2 네이티브)"**: tmux 없이 바로 claude 실행 (it2로 split pane)
2. 기본 프로필로 설정하려면: Settings → Profiles → 원하는 프로필 → **Set as Default**

**설정 포인트**:
- tmux 프로필의 `-A` 플래그: 기존 `main` 세션이 있으면 재접속, 없으면 새로 생성
- it2 프로필: tmux 세션 밖에서 실행되므로 자동으로 iTerm2 네이티브 split pane 사용
- `Recycle`: 이전 작업 디렉토리를 유지

---

**마지막 업데이트**: 2026-02-11
**참고**: 이 가이드는 Claude Code v2.1.38 기준이며, 향후 버전에서 개선될 수 있습니다.
