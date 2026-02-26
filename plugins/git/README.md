# git

Gitmoji + Conventional Commits 기반 스마트 커밋, 브랜치 관리, PR 자동 생성/리뷰를 제공하는 Claude Code 플러그인이다.

## 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/git:commit` | diff 분석 → gitmoji 자동 메시지 생성 |
| `/git:commit {메시지}` | 메시지 지정 → gitmoji만 추가 |
| `/git:branch create` | 타입/이슈/설명 → 브랜치 생성 |
| `/git:branch switch` | 목록 → 선택 전환 (auto-stash) |
| `/git:branch cleanup` | merged/stale 감지 → 정리 |
| `/git:pr [create]` | Staging → Review(GC, max 3) → 커밋 → push → PR |
| `/git:pr review [123]` | PR diff → 코드리뷰 → Markdown 피드백 |
| `/git:review` | 현재 변경사항 코드 리뷰 |

## 스킬

| 스킬 | 설명 |
|------|------|
| `gitmoji-convention` | Gitmoji 매핑, Conventional Commits, diff 기반 타입 추론 |
| `smart-commit` | 커밋 워크플로우 (commit, pr 공통 참조) |
| `pr-template` | PR 본문 템플릿, 프로젝트 템플릿 감지, 자동 생성 규칙 |
| `review-criteria` | 코드 리뷰 기준 |

## 유기적 연결

```
branch(타입) ──→ commit(gitmoji) ← gitmoji-convention
                      │
                smart-commit (SSOT)
                      │
pr(staging) ──→ pr-reviewer(GC Loop, max 3) ──→ commit ──→ push ──→ PR 생성
                    ↑              ↓
                 재리뷰 ←── 수정 (REVISE/FAIL)
                      │
commit(히스토리) ──→ pr(Summary/Changes) ← pr-template
branch(이슈번호) ──→ pr(Closes #123)
pr(프로젝트 템플릿) → .github/PULL_REQUEST_TEMPLATE.md 우선
```

## 전제조건

- PR 기능: [GitHub CLI (gh)](https://cli.github.com/) 설치 + 인증이 필요하다.

## 설치

### 마켓플레이스 (권장)

```shell
/plugin marketplace add starfishfactory/ai
/plugin install git@starfishfactory-ai
```

### 플러그인 모드

```bash
claude --plugin-dir ./plugins/git
```

## 업데이트

### 마켓플레이스

```shell
/plugin marketplace update starfishfactory-ai
```

### 플러그인 모드

```bash
git pull origin main
```

## 제거

### 마켓플레이스

```shell
/plugin uninstall git@starfishfactory-ai
```

### 플러그인 모드

`--plugin-dir` 옵션을 제거하면 된다.

## 구조

```
plugins/git/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── review.md
├── skills/
│   ├── branch/SKILL.md
│   ├── commit/SKILL.md
│   ├── gitmoji-convention/SKILL.md
│   ├── pr/SKILL.md
│   ├── pr-template/SKILL.md
│   ├── review/SKILL.md
│   ├── review-criteria/SKILL.md
│   └── smart-commit/SKILL.md
├── tests/
│   ├── test-pr-flow.md
│   └── test-review.md
└── README.md
```
