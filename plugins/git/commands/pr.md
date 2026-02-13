---
description: PR 자동 생성 및 코드 리뷰
allowed-tools: Read, Bash, Task, AskUserQuestion, Glob
argument-hint: "[create|review [PR번호]]"
---

# PR: $ARGUMENTS

PR 자동 생성 및 코드 리뷰를 수행한다.

---

## 인자 파싱

`$ARGUMENTS` 파싱:
- 없음 또는 `create` → **create 모드**
- `review` → **review 모드** (현재 브랜치 PR 자동 감지)
- `review <번호>` → **review 모드** (지정 PR 번호 사용)

---

## 공통 Phase 0: 사전 조건

### Step 0.1: gh CLI 확인
`gh --version` 실행 → 없으면 "gh CLI가 필요합니다. 설치: `brew install gh`" 출력 후 **종료**.

### Step 0.2: 인증 확인
`gh auth status` 실행 → 인증 안 됨 → "`gh auth login`을 먼저 실행하세요" 출력 후 **종료**.

---

## create 모드

### Phase 1: 미커밋 변경 처리

`git status --porcelain` → 변경사항이 있으면:
1. "커밋되지 않은 변경사항이 있습니다. 먼저 커밋합니다." 출력
2. 다음 스킬 파일을 Read로 로드:
   - `skills/smart-commit/SKILL.md`
   - `skills/gitmoji-convention/SKILL.md`
3. smart-commit 스킬의 가이드에 따라 커밋 프로세스 실행 (Step 1~4: Staging → 린트 → 메시지 생성 → 커밋)
4. **린트 실패 시** → "린트 오류를 수정한 후 다시 시도하세요" 출력 후 **PR 생성도 중단 (종료)**
5. 커밋 완료 후 다음 Phase 진행

### Phase 2: Push

- `git rev-list --count @{u}..HEAD 2>/dev/null || echo "no-upstream"` → unpushed 커밋 또는 upstream 없음 확인
- unpushed 있으면 → `git push -u origin $(git rev-parse --abbrev-ref HEAD)`
- **실패** → "push 실패. `git pull --rebase` 후 다시 시도하세요" 안내 후 **종료**

### Phase 3: PR 정보 수집

다음 정보를 병렬로 수집한다:
- `git rev-parse --abbrev-ref HEAD` → 현재 브랜치
- `git rev-parse --abbrev-ref origin/HEAD | sed 's|origin/||'` → base 브랜치
- `git log origin/<base>..HEAD --oneline` → 커밋 히스토리
- `git diff origin/<base>..HEAD --stat` → 변경 통계
- 브랜치명에서 이슈 번호 추출 (정규식: `/(\d+)-/`)
- 이슈 번호 추출 성공 시 → `gh issue view <번호> --json title,body` 로 이슈 정보 가져오기 (실패 시 무시)

### Phase 4: PR 본문 생성

1. Read: `skills/pr-template/SKILL.md` 로드
2. **PR 제목 생성**:
   - 커밋 1개 → 해당 커밋 메시지 사용 (gitmoji 제거, 70자 이내)
   - 커밋 여러 개 → 브랜치명 기반 생성
3. **PR 본문 생성** (pr-template 스킬 템플릿 적용):
   - **Summary**: 커밋 히스토리 기반 요약
   - **Changes**: diff stat 기반 주요 변경 파일
   - **Test Plan**: 테스트 파일 추가/수정 여부에 따라 자동 채움
   - **Related Issue**: `Closes #<이슈번호>` (있을 경우)
4. AskUserQuestion으로 제목+본문 확인/수정

### Phase 5: PR 생성

- `gh pr create --title "..." --body "..."` 실행 (HEREDOC 사용)
- **실패** → "이미 PR이 존재합니다" 등 에러 표시 + `gh pr view --web` 안내
- **성공** → PR URL 출력

### Phase 6: 리뷰 연결

- AskUserQuestion: "PR 리뷰를 바로 실행할까요?"
- 승인 시 → 아래 review 모드의 Phase 1~4를 실행 (생성된 PR 번호 사용)

---

## review 모드

### Phase 1: PR 특정

- `$ARGUMENTS`에 PR 번호가 있으면 → 해당 번호 사용
- 없으면 → `gh pr view --json number --jq '.number'` → 현재 브랜치 PR 자동 감지
- **실패** → "현재 브랜치에 PR이 없습니다. 번호를 지정하세요" 출력 후 **종료**

### Phase 2: PR 정보 + diff 수집

- `gh pr view <번호> --json title,body,files,additions,deletions`
- `gh pr diff <번호>`

### Phase 3: pr-reviewer 에이전트 호출

1. Read: `agents/pr-reviewer.md` → 에이전트 프롬프트 로드
2. Task(subagent_type: `general-purpose`)로 호출:
   - **시스템 프롬프트**: `agents/pr-reviewer.md` 전문 (역할/프로세스/출력형식/원칙)
   - **컨텍스트 섹션**: PR 메타데이터 (title, body, files, additions, deletions)
   - **분석 대상**: `gh pr diff` 결과 전문
   - **요청**: "위 PR을 리뷰 프로세스에 따라 분석하고, 출력 형식에 맞춰 피드백을 작성하라"

### Phase 4: 결과 출력

- 에이전트 리뷰 피드백을 포맷팅하여 출력
- AskUserQuestion: "리뷰 코멘트를 PR에 등록할까요?"
- 승인 시 → `gh pr comment <번호> --body "..."` 실행
