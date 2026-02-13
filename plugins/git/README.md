# Git Plugin

Gitmoji + Conventional Commits 기반 스마트 커밋, 브랜치 관리, PR 자동 생성/리뷰를 제공하는 Claude Code 플러그인.

## 커맨드

### `/git:commit` — 스마트 커밋

```bash
/git:commit                    # diff 분석 → 자동 메시지 생성
/git:commit fix login redirect # 메시지 지정 → gitmoji만 추가
```

프로세스: 변경 감지 → Staging → 린트 → 메시지 생성 → 커밋

### `/git:branch` — 브랜치 관리

```bash
/git:branch create    # 타입/이슈/설명 → 브랜치 생성
/git:branch switch    # 목록 → 선택 전환 (auto-stash)
/git:branch cleanup   # merged/stale 감지 → 정리
```

### `/git:pr` — PR 생성 + 리뷰

```bash
/git:pr [create]      # Staging → Review(GC, max 3) → 커밋 → push → PR
/git:pr review [123]  # PR diff → Mode B 코드리뷰 → Markdown 피드백
```

## 스킬

| 스킬 | 설명 |
|------|------|
| `gitmoji-convention` | Gitmoji 매핑, Conventional Commits, diff 기반 타입 추론 |
| `smart-commit` | 커밋 워크플로우 (commit, pr 공통 참조) |
| `pr-template` | PR 본문 템플릿, 프로젝트 템플릿 감지, 자동 생성 규칙 |

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

## 설치

```bash
claude install-plugin starfishfactory-ai/git
```

## 요구사항

- PR 기능: [GitHub CLI (gh)](https://cli.github.com/) 설치 + 인증 필요
