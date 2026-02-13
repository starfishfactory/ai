---
name: smart-commit
description: 스마트 커밋 워크플로우 가이드 (commit.md, pr.md 공통 참조)
user-invocable: false
---

# 스마트 커밋 프로세스

다음 단계를 순서대로 실행한다. **gitmoji-convention 스킬을 반드시 함께 로드하여 참조한다.**

---

## Step 1: Staging

- `git diff --cached --name-only` → staged 파일 확인
- `git diff --name-only` → unstaged 파일 확인
- staged 없고 unstaged만 있으면 → AskUserQuestion으로 스테이징 방식 선택:
  - "전체 추가": `git add -A`
  - "선택 추가": 파일 목록을 제시하고 사용자가 선택한 파일만 `git add <파일>`
- 스테이징 후 `git diff --cached --name-only` → staged 파일이 없으면 "커밋할 변경사항이 없습니다" 출력 후 종료
- 둘 다 없으면 → "커밋할 변경사항이 없습니다" 출력 후 종료

---

## Step 2: 린트

- `package.json`에 `scripts.lint`가 있으면 → `npm run lint` 실행
- `Makefile`에 `lint` 타겟이 있으면 → `make lint` 실행
- 둘 다 감지 실패 → 린트 단계 생략
- 린트 실패 → 오류 내용 표시 + "린트 오류를 수정한 후 다시 커밋하세요" 출력 후 종료

---

## Step 3: 커밋 메시지 생성

1. **타입 결정**: gitmoji-convention 스킬의 타입 결정 우선순위 규칙 적용
   - 브랜치명 → diff 파일 패턴 추론 → AskUserQuestion
2. **Gitmoji 매핑**: 결정된 타입 → gitmoji-convention 스킬의 매핑 테이블에서 이모지 선택
3. **Scope 결정**: 변경 파일들의 공통 상위 디렉토리 (선택, 없으면 생략)
4. **Subject 생성**: 변경 내용을 요약한 50자 이내 명령형 메시지
5. **Body 추가**: 3개 이상 파일 변경 시 주요 변경사항 목록 추가
6. **형식**: `<gitmoji> <type>(<scope>): <subject>`
7. AskUserQuestion으로 생성된 메시지 확인/수정

---

## Step 4: 커밋 실행

- `git commit` 실행 (HEREDOC 형식, Co-Authored-By 포함)
  ```
  git commit -m "$(cat <<'EOF'
  <gitmoji> <type>(<scope>): <subject>

  <body>

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```
- 실패 → 에러 내용 표시 + 종료
- 성공 → `git log -1 --oneline` 출력하여 커밋 결과 확인
