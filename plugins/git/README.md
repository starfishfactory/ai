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

### `/git:review` — 독립 코드 리뷰

```bash
/git:review            # staged diff → 100점 감점 리뷰 → JSON 출력
/git:review pr         # 현재 PR → 리뷰 → Markdown 출력
/git:review pr 42      # PR #42 → 리뷰 → Markdown 출력
```

**v1.2.0 신규**: 독립 실행 가능한 코드 리뷰 커맨드.
- 100점 감점 기준 (Functionality/Readability/Reliability/Performance)
- confidence 필터링 (high/medium/low) — high만 점수에 반영
- 모든 피드백에 구체적 코드 수정 제안 포함
- 재리뷰 시 이전 피드백 해결 여부 추적

### `/git:pr` — PR 생성 + 리뷰

```bash
/git:pr [create]      # Auto-stage → Review(GC) → 커밋 → push → PR
/git:pr review [123]  # PR diff → 4관점 분석 → Markdown 피드백
```

**v1.2.0 변경사항**:
- 리뷰 로직을 `review.md`로 분리 (inline 위임, Task 서브에이전트 제거)
- confidence 필터링 적용 — high-confidence 이슈만 주요 표시
- 재리뷰 시 이전 피드백 해결 추적 (`resolved_from_previous`)

**v1.1.0 변경사항**:
- AskUserQuestion 4+회 → 0-2회 (리뷰 Pass/Fix + 브랜치 Continue/New branch)
- Phase 0(사전 조건 확인) 제거 → 실패 시 지연 폴백 안내
- 자동 스테이징 + 민감 파일 감지/자동 언스테이징
- main/master → 리뷰 후 자동 브랜치 생성 (Branch Ensure)
- 기존 PR 중복 생성 방지
- 커밋 메시지/PR 본문 자동 생성 (확인 질문 없음)

## 스킬

| 스킬 | 설명 |
|------|------|
| `gitmoji-convention` | Gitmoji 매핑, Conventional Commits, diff 기반 타입 추론 |
| `smart-commit` | 커밋 워크플로우 (commit, pr 공통 참조) |
| `pr-template` | PR 본문 템플릿, 프로젝트 템플릿 감지, 자동 생성 규칙 |
| `review-criteria` | 코드 리뷰 100점 감점 기준, confidence 레벨, 출력 스키마 |

## 유기적 연결

```
branch(타입) ──→ commit(gitmoji) ← gitmoji-convention
                      │
                smart-commit (SSOT)
                      │
pr(auto-stage) ──→ review(GC Loop, max 3) ──→ auto-commit ──→ push ──→ PR 생성
                    ↑     ↓    ← review-criteria (100점 감점)
                 재리뷰 ←── 수정 (REVISE/FAIL, AskUserQ 1회)
                      │
review(독립) ──→ staged diff → JSON / PR diff → Markdown
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

- PR 기능: [GitHub CLI (gh)](https://cli.github.com/) — 미설치/미인증 시 PR 생성 단계에서 안내
