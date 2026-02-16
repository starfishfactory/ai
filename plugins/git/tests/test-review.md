# Review Command Test Scenarios

`/git:review` 독립 커맨드 동작 검증. diff 모드(JSON), pr 모드(Markdown), early exit 시나리오.

## Preconditions (all scenarios)
- Git repository with remote origin
- `plugins/git/commands/review.md` loaded
- `plugins/git/skills/review-criteria/SKILL.md` accessible

---

## Scenario 1: diff 모드 기본 플로우

**Given**: `feat/add-login` branch, staged changes exist (`git diff --cached` non-empty)
**When**: `/git:review`
**Then**:
1. Arg parse → diff 모드 (no arguments)
2. `skills/review-criteria/SKILL.md` 로드
3. `git diff --cached` + `git diff --cached --stat` 수집
4. Step-by-step 감점 평가:
   - Scope assessment (file count + line count)
   - Category 1-4 순서대로 감점
   - confidence 레벨 할당 (high/medium/low per feedback item)
5. JSON 출력:
   ```json
   {
     "score": 85,
     "verdict": "PASS",
     "categories": {
       "functionality": { "score": 0, "max": 30, "issues": [] },
       "readability": { "score": 5, "max": 25, "issues": ["..."] },
       "reliability": { "score": 5, "max": 25, "issues": ["..."] },
       "performance": { "score": 5, "max": 20, "issues": ["..."] }
     },
     "good_practices": ["..."],
     "feedback": [
       {
         "file": "src/auth.ts:42",
         "category": "readability",
         "severity": "minor",
         "confidence": "high",
         "deduction": 3,
         "issue": "...",
         "suggestion": "..."
       }
     ]
   }
   ```
6. JSON만 출력 — 설명 텍스트 없음

**Verify**:
- [ ] diff 모드에서 `git diff --cached` 사용
- [ ] review-criteria SKILL.md 로드됨
- [ ] JSON 출력에 `confidence` 필드 포함 (high/medium/low)
- [ ] 모든 feedback 항목에 구체적 코드 수정 제안 포함 (`suggestion` 비어있지 않음)
- [ ] `score` = 100 - 총 감점
- [ ] verdict 임계값: PASS ≥80, REVISE 60-79, FAIL <60

---

## Scenario 2: pr 모드 기본 플로우

**Given**: `feat/existing` branch, PR #42 exists
**When**: `/git:review pr 42`
**Then**:
1. Arg parse → pr 모드, PR #42
2. `skills/review-criteria/SKILL.md` 로드
3. `gh pr view 42 --json title,body,files,additions,deletions` + `gh pr diff 42` 수집
4. Step-by-step 감점 평가 (diff 모드와 동일 기준)
5. Markdown 출력:
   ```markdown
   ## Overall Assessment
   2-3 sentence summary. Score: 85/100 (PASS)

   ## Good Practices
   - ...

   ## Critical Issues
   ### {issue title}
   - **File**: `src/auth.ts:42`
   - **Category**: Functionality
   - **Confidence**: high
   - **Description**: ...
   - **Suggestion**: ...

   ## Important Issues
   ...

   ## Nice-to-have
   ...
   ```
6. Markdown 포맷으로 출력 — JSON 아님

**Verify**:
- [ ] pr 모드에서 `gh pr diff <N>` 사용
- [ ] Markdown 출력에 `Confidence` 필드 포함
- [ ] 섹션 순서: Overall Assessment → Good Practices → Critical → Important → Nice-to-have
- [ ] 모든 이슈에 구체적 코드 수정 제안 (`Suggestion` 비어있지 않음)
- [ ] Score가 Overall Assessment에 표기

---

## Scenario 3: 변경 없을 때 early exit

**Given**: `feat/clean` branch, staged changes 없음 (`git diff --cached` empty)
**When**: `/git:review`
**Then**:
1. Arg parse → diff 모드
2. `git diff --cached` → empty
3. "No staged changes to review." 출력
4. **exit** (리뷰 실행하지 않음)

**Verify**:
- [ ] staged diff가 비어있으면 즉시 종료
- [ ] 리뷰 평가 실행하지 않음
- [ ] 사용자 친화적 메시지 출력

---

## Scenario 4: diff 모드 재리뷰 (이전 피드백 포함)

**Given**: `fix/null-check` branch, staged changes exist, 이전 리뷰 JSON 제공됨
**When**: `/git:review` with previous review JSON as context
**Then**:
1. diff 모드 실행
2. 이전 피드백 대비 해결된 항목 추적
3. JSON 출력에 `resolved_from_previous` 필드 포함:
   ```json
   {
     "score": 90,
     "verdict": "PASS",
     "resolved_from_previous": [
       "src/auth.ts:42 - null check added"
     ],
     "categories": { ... },
     "feedback": [ ... ]
   }
   ```

**Verify**:
- [ ] 이전 리뷰 JSON이 제공되면 `resolved_from_previous` 필드 포함
- [ ] 이전 피드백 항목이 해결되었는지 비교
- [ ] 새 이슈에만 집중 (이전 해결 항목은 감점하지 않음)

---

## Scenario 5: Auto-filter로 false positive 방지

**Given**: `feat/add-feature` branch, staged changes exist, diff 외 라인에 기존 이슈 존재 (예: 변경하지 않은 파일의 미사용 import)
**When**: `/git:review`
**Then**:
1. diff 모드 실행
2. 리뷰 평가 시 Auto-Filter Rules 적용:
   - Pre-existing: diff에 포함되지 않은 라인의 이슈 스킵
   - Lint-detectable: 프로젝트에 linter 있으면 포매팅/unused import 스킵
   - Speculative: 구체적 증거 없는 "might cause" 이슈 스킵
3. JSON 출력의 feedback 배열에 필터된 항목 미포함

**Verify**:
- [ ] feedback이 모두 diff 범위 내 라인만 참조
- [ ] lint가 잡을 수 있는 이슈(포매팅, unused import 등) 미포함 (linter 존재 시)
- [ ] "might cause issues" 류의 근거 없는 추측 이슈 미포함

---

## Scenario 6: Confidence downgrade 검증

**Given**: `feat/api-wrapper` branch, staged diff에 외부 라이브러리 래퍼 코드 (해당 라이브러리 문서 없이 정확성 판단 불가)
**When**: `/git:review`
**Then**:
1. diff 모드 실행
2. Confidence downgrade trigger 적용:
   - 특정 라인을 인용할 수 없으면 → max `medium`
   - config/env에 의존하면 → max `medium`
   - "might"/"could"/"possibly" 추론 → `low`
   - 익숙하지 않은 프레임워크 패턴 → `low`
3. JSON 출력에서 해당 이슈가 `high`가 아님
4. `score` 계산에 medium/low 항목 감점 미반영

**Verify**:
- [ ] downgrade trigger 해당 이슈가 `high` confidence가 아님
- [ ] `score`에 medium/low confidence 이슈의 감점 미반영
- [ ] feedback 항목의 `deduction` 값이 medium/low인 경우 0

---

## Acceptance Criteria

| Metric | Expected |
|--------|----------|
| diff 모드 출력 | JSON only (설명 텍스트 없음) |
| pr 모드 출력 | Markdown (섹션 구조) |
| confidence 필드 | 모든 feedback 항목에 포함 |
| suggestion 필드 | 모든 feedback 항목에 비어있지 않음 |
| empty diff | early exit + 메시지 |
| 재리뷰 | resolved_from_previous 필드 |
| allowed-tools | Read, Bash, Glob, Grep (Task 없음) |
| auto-filter | pre-existing + lint 이슈 미포함 |
| confidence downgrade | 불확실 이슈에 low 할당 |
