# Git Plugin

Gitmoji + Conventional Commits 기반 스마트 커밋, 브랜치 관리, PR 자동 생성/리뷰를 제공하는 Claude Code 플러그인.

## 커맨드

### `/git:commit` — 스마트 커밋

변경사항을 분석하여 Gitmoji + Conventional Commits 형식으로 자동 커밋한다.

```bash
/git:commit                    # diff 분석 → 자동 메시지 생성
/git:commit fix login redirect # 메시지 지정 → gitmoji만 자동 추가
```

**프로세스**: 변경 감지 → Staging → 린트 → 메시지 생성 → 커밋

### `/git:branch` — 브랜치 관리

브랜치 생성, 전환, 정리를 수행한다.

```bash
/git:branch create    # 타입/이슈/설명 입력 → 브랜치 생성
/git:branch switch    # 브랜치 목록 → 선택 전환 (auto-stash)
/git:branch cleanup   # merged/stale 브랜치 감지 → 정리
```

### `/git:pr` — PR 생성 + 리뷰

PR 자동 생성 및 코드 리뷰를 수행한다.

```bash
/git:pr               # 미커밋 처리 → push → PR 생성
/git:pr create        # 위와 동일
/git:pr review        # 현재 브랜치 PR 리뷰
/git:pr review 123    # PR #123 리뷰
```

**create 프로세스**: 미커밋 변경 자동 커밋 → push → PR 본문 생성 → PR 생성 → 리뷰 연결 제안
**review 프로세스**: PR diff 수집 → 4관점 분석 (기능성/가독성/안정성/성능) → 피드백 출력

## 스킬

| 스킬 | 설명 |
|------|------|
| `gitmoji-convention` | Gitmoji 매핑, Conventional Commits 규칙, diff 기반 타입 추론 |
| `smart-commit` | 커밋 워크플로우 가이드 (commit, pr 공통 참조) |
| `pr-template` | PR 본문 GFM 템플릿, 자동 생성 규칙, 리뷰 체크리스트 |

## 유기적 연결

```
branch(타입)  ─────→ commit(gitmoji 자동 결정)  ← gitmoji-convention 스킬
                          │
                    smart-commit 스킬 (SSOT)
                          │
commit(히스토리) ─────→ pr create(Summary/Changes 자동)  ← pr-template 스킬
                          │
branch(이슈번호) ─────→ pr create(Closes #123 자동 링크)
                          │
pr(미커밋 감지) ──────→ smart-commit 스킬 참조하여 커밋 실행
                          │
pr create ────────────→ pr review(자동 연결 제안)
```

## 설치

```bash
claude install-plugin starfishfactory-ai/git
```

## 요구사항

- PR 관련 기능: [GitHub CLI (gh)](https://cli.github.com/) 설치 + 인증 필요
