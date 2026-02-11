# tmux 사용법 가이드

## TL;DR — 생존 키트

| 상황 | 일반 tmux | tmux -CC (iTerm2) |
|------|----------|-------------------|
| 에이전트 패인으로 이동 | Ctrl+b → 방향키 | Cmd+[ / Cmd+] 또는 클릭 |
| 실수로 detach했다 | `tmux attach -t 세션이름` | (동일) |
| Ctrl+b가 안 먹힌다 | Claude Code가 키 입력 가로챔 → 마우스 모드 또는 -CC 전환 | -CC에서는 prefix 불필요 |
| 새 패인 만들기 | Ctrl+b % (좌우) / Ctrl+b " (상하) | Cmd+D (좌우) / Cmd+Shift+D (상하) |
| 터미널 닫아도 세션 유지됨 | `tmux attach`로 복귀 | (동일) |

> Split pane 설정/트러블슈팅은 [iTerm2 Split Pane 트러블슈팅](./iterm2-split-pane-troubleshooting.md)을 참고하세요.
> 이 가이드는 해당 문서의 "방식 A (tmux)"를 사용할 때 필요한 tmux 기본 조작법을 다룹니다.

---

## 1. 핵심 개념

### 1.1 세션 → 윈도우 → 패인 계층

tmux는 세 단계의 계층 구조로 터미널을 관리합니다.

```
세션 (session)
├── 윈도우 0 (window)
│   ├── 패인 0 (pane) ← 에이전트 A
│   ├── 패인 1 (pane) ← 에이전트 B
│   └── 패인 2 (pane) ← 에이전트 C
└── 윈도우 1 (window)
    └── 패인 0 (pane)
```

- **세션**: 독립적인 작업 공간입니다. detach해도 서버에서 유지됩니다.
- **윈도우**: 세션 안의 탭입니다. 하단 상태바에 목록이 표시됩니다.
- **패인**: 윈도우 안에서 분할된 각 터미널 영역입니다. Agent Teams의 각 에이전트가 여기에 할당됩니다.

### 1.2 prefix 키

tmux의 모든 키바인딩은 **prefix 키를 먼저 누르고 릴리스한 후** 명령 키를 입력하는 방식입니다.

- **기본 prefix**: Ctrl+b
- 예시: 패인 이동 → Ctrl+b를 누르고 손을 뗀 후 → 방향키
- **tmux -CC 모드에서는 prefix가 불필요합니다**. iTerm2가 직접 tmux를 제어하기 때문입니다.
- 모든 키바인딩 확인: Ctrl+b ?

### 1.3 상태바 읽기

tmux 하단에 표시되는 상태바의 구조입니다.

```
[세션이름] 0:bash*  1:claude-  2:vim
```

- `[세션이름]`: 현재 연결된 세션의 이름입니다.
- `*`: 현재 활성 윈도우를 표시합니다.
- `-`: 직전에 사용하던 윈도우를 표시합니다.
- 숫자: 윈도우 인덱스입니다. Ctrl+b 숫자로 직접 이동할 수 있습니다.

출처: tmux wiki Getting Started

### 1.4 명령어 프롬프트

Ctrl+b : 을 누르면 상태바에 명령어 프롬프트가 열립니다. 자주 쓰는 명령어:

| 명령어 | 설명 |
|--------|------|
| `kill-session` | 현재 세션 종료 |
| `list-keys` | 전체 키바인딩 목록 |
| `source-file ~/.tmux.conf` | 설정 파일 다시 로드 |
| `set -g mouse on` | 마우스 모드 즉시 활성화 |

---

## 2. Agent Teams에서 자주 쓰는 tmux 조작 ★

### 2.1 에이전트 패인 간 이동

| 모드 | 이동 방법 | 비고 |
|------|----------|------|
| 일반 tmux | Ctrl+b → 방향키 | prefix 후 방향키 |
| 일반 tmux | Ctrl+b q → 번호 입력 | 패인 번호로 직접 이동 |
| tmux -CC | Cmd+[ / Cmd+] 또는 마우스 클릭 | iTerm2 네이티브 |
| in-process | Shift+Up / Shift+Down | split pane 없이 |

> **참고**: Ctrl+b q를 누르면 각 패인에 번호가 잠시 표시됩니다. 표시되는 동안 해당 번호를 누르면 이동합니다.

### 2.2 Ctrl+b가 안 먹힐 때

Claude Code가 실행 중인 패인에서는 키 입력을 가로채기 때문에 Ctrl+b가 작동하지 않을 수 있습니다. 아래 방법을 순서대로 시도하세요.

1. **마우스 모드 사용** — `tmux set -g mouse on` 실행 후 원하는 패인을 마우스로 클릭합니다.
2. **tmux -CC로 전환** — prefix 키가 불필요하므로 충돌이 없습니다. (출처: Reddit r/tmux 커뮤니티 추천)
3. **Escape 후 재시도** — Escape 키를 몇 번 누른 후 Ctrl+b를 시도합니다.
4. **prefix 키 변경** — `.tmux.conf`에서 prefix를 Ctrl+a 등으로 변경합니다 (섹션 4.2 참고).

### 2.3 detach/재접속

실수로 detach해도 세션과 에이전트는 살아 있습니다.

| 조작 | 설명 |
|------|------|
| Ctrl+b d | detach (실수로 누르기 쉬움) |
| `tmux attach -t 세션이름` | 재접속 |
| `tmux ls` | 활성 세션 목록 확인 |
| `tmux attach` | 가장 최근 세션에 재접속 |

> **중요**: detach는 세션을 종료하는 것이 아닙니다. 에이전트는 백그라운드에서 계속 실행됩니다. `tmux attach`로 돌아오면 됩니다.

### 2.4 특정 에이전트 패인 확대

- Ctrl+b z = 현재 패인을 전체화면으로 확대합니다 (zoom).
- 다시 Ctrl+b z = 원래 레이아웃으로 복귀합니다.
- 특정 에이전트의 출력을 자세히 봐야 할 때 유용합니다.

### 2.5 패인 레이아웃 정리

- Ctrl+b Space = 프리셋 레이아웃을 순환합니다 (`even-horizontal` → `even-vertical` → `main-horizontal` → `main-vertical` → `tiled`).
- 에이전트 3명일 때 `tiled` 레이아웃이 각 패인을 균등하게 배치하여 유용합니다.
- tmux -CC에서는 iTerm2 창 경계를 드래그하여 직접 크기를 조절할 수 있습니다.

---

## 3. 기본 조작 레퍼런스

### 3.1 세션 관리

| 명령어 | 설명 |
|--------|------|
| `tmux new -s 이름` | 새 세션 생성 |
| `tmux ls` | 세션 목록 |
| `tmux attach -t 이름` | 세션에 재접속 |
| `tmux kill-session -t 이름` | 세션 종료 |
| Ctrl+b d | 현재 세션에서 detach |
| Ctrl+b s | 세션 목록에서 선택하여 이동 |

### 3.2 윈도우 관리

| 키바인딩 | 설명 |
|----------|------|
| Ctrl+b c | 새 윈도우 생성 |
| Ctrl+b n | 다음 윈도우 |
| Ctrl+b p | 이전 윈도우 |
| Ctrl+b w | 윈도우 목록에서 선택 |
| Ctrl+b 0-9 | 번호로 윈도우 이동 |
| Ctrl+b , | 현재 윈도우 이름 변경 |

> **참고**: Agent Teams 사용 시 윈도우를 직접 관리할 일은 거의 없습니다. 에이전트들은 같은 윈도우의 패인으로 분할됩니다.

### 3.3 패인 관리

| 키바인딩 | 설명 |
|----------|------|
| Ctrl+b % | **좌우 분할** (tmux 용어: horizontal — 세로선이 생김) |
| Ctrl+b " | **상하 분할** (tmux 용어: vertical — 가로선이 생김) |
| Ctrl+b 방향키 | 패인 이동 |
| Ctrl+b o | 다음 패인으로 순환 이동 |
| Ctrl+b q | 패인 번호 표시 → 번호로 이동 |
| Ctrl+b Ctrl+방향키 | 패인 크기 조절 |
| Ctrl+b { | 현재 패인을 이전 위치로 교환 |
| Ctrl+b } | 현재 패인을 다음 위치로 교환 |
| Ctrl+b z | 패인 전체화면 토글 (zoom) |
| `exit` 또는 Ctrl+d | 패인 닫기 |

> **주의**: tmux에서 "horizontal split"은 세로선을 기준으로 좌우로 나누는 것이고, "vertical split"은 가로선을 기준으로 상하로 나누는 것입니다. 직관과 반대이므로 주의하세요.

### 3.4 Copy Mode

터미널 출력을 스크롤하거나 텍스트를 복사할 때 사용합니다.

| 키바인딩 | 설명 |
|----------|------|
| Ctrl+b [ | copy mode 진입 |
| q | copy mode 종료 |
| 방향키 / PgUp / PgDn | 스크롤 |
| / | 정방향 검색 |
| ? | 역방향 검색 |
| Space | 선택 시작 |
| Enter | 선택 복사 |
| Ctrl+b ] | 붙여넣기 |

> **참고**: copy mode 진입 사실을 모르고 "입력이 안 된다"고 착각하는 경우가 많습니다. q를 눌러 탈출하세요.

---

## 4. 마우스 모드와 추천 설정

### 4.1 마우스 모드

마우스 모드를 활성화하면 패인 클릭으로 이동하고, 경계선 드래그로 크기를 조절할 수 있습니다.

```bash
# 즉시 활성화 (현재 세션에만 적용)
tmux set -g mouse on
```

**장점**:
- 패인을 클릭하여 선택할 수 있습니다 (Ctrl+b 충돌 우회).
- 패인 경계선을 드래그하여 크기를 조절할 수 있습니다.
- 스크롤 휠로 copy mode에 자동 진입합니다.

**단점**:
- OS 기본 텍스트 선택/복사가 비활성화됩니다.
- Option(Alt) 키를 누른 채 드래그하면 OS 기본 선택을 사용할 수 있습니다.

출처: Reddit r/tmux 커뮤니티 추천 — 초보자에게 `mouse on`이 가장 먼저 추천되는 설정입니다.

### 4.2 추천 .tmux.conf (초보자용 최소 설정)

```bash
# prefix 변경: Ctrl+b → Ctrl+a (한 손으로 누르기 편함)
# 출처: Reddit r/tmux — "Caps Lock → Ctrl 매핑"과 조합 시 가장 편리
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# 직관적 패인 분할 키
bind | split-window -h   # 좌우 분할
bind - split-window -v   # 상하 분할

# 마우스 모드 활성화
set -g mouse on

# Vim ESC 지연 제거
set -sg escape-time 0

# 스크롤 히스토리 확장
set -g history-limit 50000

# 윈도우/패인 인덱스 1부터 시작 (0은 키보드 왼쪽 끝이라 불편)
set -g base-index 1
setw -g pane-base-index 1

# 설정 리로드 단축키
bind r source-file ~/.tmux.conf \; display-message "설정을 다시 로드했습니다"
```

> **적용 방법**: 파일 저장 후 `tmux source-file ~/.tmux.conf`를 실행하거나, 위 설정이 적용된 상태라면 Ctrl+a r을 누르세요.

### 4.3 추천 .tmux.conf (중급자용 추가 설정)

```bash
# Alt+방향키로 패인 이동 (prefix 없이)
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# 256 color 지원
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# focus-events 활성화 (Vim/Neovim 연동 시 필요)
set -g focus-events on

# 현재 경로에서 새 패인 열기
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
```

---

## 5. 초보자가 자주 하는 실수

| 실수 | 해결 |
|------|------|
| prefix 키 안 누르고 키바인딩 시도 | Ctrl+b를 먼저 누르고 **릴리스한 후** 명령 키를 누르세요 |
| tmux 안에서 tmux 중첩 실행 | 이미 tmux 안이면 새 윈도우(Ctrl+b c)나 패인(Ctrl+b %)만 생성하세요 |
| copy mode 진입 사실 모르고 입력 안 됨 | q를 눌러 copy mode를 탈출하세요 |
| detach와 kill 혼동 | detach(Ctrl+b d)는 세션 유지, `exit`는 종료입니다 |
| `.tmux.conf` 수정 후 반영 안 됨 | `tmux source-file ~/.tmux.conf`를 실행해야 합니다 |
| Ctrl+b %가 "수직 분할"인 줄 착각 | **좌우 분할**(세로선) = %, **상하 분할**(가로선) = " |
| `tmux` 안에서 `tmux` 명령 실행 | `tmux new-session` 대신 Ctrl+b c로 윈도우를 만드세요 |

---

## 6. 참고 자료

### 공식 문서
- [tmux GitHub Wiki](https://github.com/tmux/tmux/wiki)
- [tmux Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started)

### 치트시트
- [tmuxcheatsheet.com](https://tmuxcheatsheet.com/)
- [MohamedAlaa tmux Cheatsheet](https://gist.github.com/MohamedAlaa/2961058) (GitHub Gist)

### 커뮤니티
- [Reddit r/tmux](https://www.reddit.com/r/tmux/)
- [gpakosz/.tmux (Oh my tmux!)](https://github.com/gpakosz/.tmux)
- [Addy Osmani - Claude Code Swarms](https://addyosmani.com/blog/claude-code-agent-teams/)

### 내부 가이드
- [iTerm2 Split Pane 트러블슈팅](./iterm2-split-pane-troubleshooting.md)

---

마지막 업데이트: 2026-02-11
관련 문서: [iTerm2 Split Pane 트러블슈팅](./iterm2-split-pane-troubleshooting.md)
