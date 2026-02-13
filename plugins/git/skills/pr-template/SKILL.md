---
name: pr-template
description: PR 본문 GFM 템플릿 및 자동 생성 규칙, 리뷰 체크리스트
user-invocable: false
---

# PR 본문 GFM 템플릿

## 템플릿

```markdown
## Summary
<!-- 커밋 히스토리 기반 자동 생성: PR의 목적과 주요 변경사항 3-5줄 요약 -->

## Changes
<!-- diff stat 기반 자동 생성: 변경 라인 수 상위 5개 파일 -->
- {변경 설명} (`{파일 경로}`)

## Test Plan
- [ ] {테스트 항목}

## Breaking Changes
None

## Related Issue
Closes #{이슈번호}

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## 자동 생성 규칙

### Summary 섹션
- 커밋 1개 → 해당 커밋 메시지 본문 사용
- 커밋 여러 개 → 커밋 메시지들을 종합하여 3-5줄로 요약

### Changes 섹션
- `git diff --stat` 결과 기반
- 변경 라인 수 상위 5개 파일만 나열
- 파일 경로로 변경 영역을 추론하여 설명 작성

### Test Plan 섹션
- 테스트 파일(`*.test.*`, `*.spec.*`, `**/tests/**`)이 추가/수정됨 → "단위 테스트 추가/수정" 항목 자동 추가
- 테스트 변경 없음 → 빈 체크리스트 제공 (`- [ ] `)

### Breaking Changes 섹션
- 커밋 메시지에 `BREAKING CHANGE` 또는 `!`가 포함되면 해당 내용 기재
- 없으면 "None"

### Related Issue 섹션
- 브랜치명에서 이슈 번호 추출: 정규식 `/(\d+)-/`
- 추출 성공 → `Closes #번호`
- 실패 → 섹션 제거

---

## PR 제목 생성 규칙

- 커밋 1개 → 커밋 메시지 subject 사용 (gitmoji 제거)
- 커밋 여러 개 → 브랜치명 기반 생성
  - 예: `feat/123-add-login` → "Add login"
  - kebab-case를 공백 분리 + 첫 글자 대문자
- 70자 이내 제한

---

## 리뷰 체크리스트

### 기능성 (Functionality)
- [ ] 요구사항을 올바르게 구현했는가?
- [ ] 엣지 케이스를 처리하는가?
- [ ] 에러 핸들링이 적절한가?
- [ ] 입력 검증이 충분한가?

### 가독성 (Readability)
- [ ] 함수/변수명이 명확한가?
- [ ] 코드 구조가 이해하기 쉬운가?
- [ ] 복잡한 로직에 설명 주석이 있는가?
- [ ] 불필요한 복잡성이 없는가?

### 안정성 (Reliability)
- [ ] 테스트 커버리지가 충분한가?
- [ ] null/undefined 체크가 있는가?
- [ ] Race condition 가능성이 없는가?
- [ ] 리소스 정리(close, cleanup)가 적절한가?

### 성능 (Performance)
- [ ] 불필요한 반복문/연산이 없는가?
- [ ] 메모리 누수 가능성이 없는가?
- [ ] DB 쿼리 최적화가 필요한가?
- [ ] N+1 쿼리 문제가 없는가?
