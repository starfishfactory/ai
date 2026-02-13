---
description: Gitmoji + Conventional Commits 기반 스마트 커밋
allowed-tools: Read, Bash, AskUserQuestion, Glob
argument-hint: "[커밋 메시지 (선택, 생략 시 자동 생성)]"
---

# 스마트 커밋: $ARGUMENTS

Gitmoji + Conventional Commits 기반으로 변경사항을 분석하여 스마트 커밋을 수행한다.

---

## Phase 0: 컨텍스트 수집

### Step 0.1: 변경사항 확인
`git status --porcelain` 실행 → 변경 없으면 "커밋할 변경사항이 없습니다" 출력 후 **종료**.

### Step 0.2: 브랜치 정보 추출
`git rev-parse --abbrev-ref HEAD` → 브랜치명에서 타입과 이슈번호를 추출한다.

파싱 규칙: `<type>/<issue>-<desc>` 또는 `<type>/<desc>`
- 예: `feat/123-add-login` → type=feat, issue=123
- 예: `fix/resolve-crash` → type=fix, issue=없음

### Step 0.3: 스킬 로드
다음 스킬 파일을 Read로 읽어 컨텍스트로 활용한다:
- `skills/gitmoji-convention/SKILL.md`
- `skills/smart-commit/SKILL.md`

### Step 0.4: 인자 처리
`$ARGUMENTS`에 커밋 메시지가 제공된 경우:
- `git diff --cached --name-only` → staged 파일 확인
- staged 없으면 → `git add -A` 실행 (빠른 커밋 의도이므로 전체 추가)
- gitmoji-convention 스킬의 매핑 테이블에서 적절한 gitmoji를 선택
- 메시지 앞에 gitmoji를 추가하여 **Phase 4(커밋 실행)로 직행**
- 형식: `<gitmoji> <사용자 메시지>`
- **참고**: 린트는 생략된다 (사용자가 메시지를 직접 지정한 빠른 커밋 경로)

---

## Phase 1~4: smart-commit 스킬 위임

`$ARGUMENTS`에 메시지가 없는 경우, smart-commit 스킬의 Step 1~4를 순서대로 실행한다:

1. **Step 1: Staging** — staged/unstaged 확인 → 스테이징 방식 선택
2. **Step 2: 린트** — 린트 도구 감지 → 실행 → 실패 시 종료
3. **Step 3: 커밋 메시지 생성** — 타입 결정(브랜치→diff→사용자) → gitmoji 매핑 → 메시지 생성 → 확인
4. **Step 4: 커밋 실행** — HEREDOC 커밋 → 결과 출력

Phase 0에서 추출한 브랜치 타입과 이슈번호를 Step 3의 타입 결정에 전달한다.
gitmoji-convention 스킬의 타입 결정 우선순위/매핑 테이블을 참조한다.
