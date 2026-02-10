---
description: 기존 MSA 리포트에 대해 교차 검증 + 품질 검증 실행 (Lead 직접 수행)
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
argument-hint: <리포트 경로>
---

# 리포트 독립 검증: $ARGUMENTS

## 검증 대상

리포트 경로: `$ARGUMENTS`

> `$ARGUMENTS`가 비어있으면 AskUserQuestion으로 리포트 경로를 확인합니다.

## 리포트 파일 스캔

!`ls -la ${ARGUMENTS:-.} 2>/dev/null`

---

## Phase 1: 리포트 존재 확인

다음 파일들이 존재하는지 확인합니다:
- `README.md`
- `01-system-context.md`
- `02-container.md`
- `03-components/` (디렉토리)
- `04-service-catalog.md`
- `05-infra-overview.md`
- `06-dependency-map.md`

파일이 부족한 경우 사용자에게 안내합니다.

## Phase 2: 분석 결과 복원

리포트 내용에서 분석 결과를 역추출합니다:
- `04-service-catalog.md`에서 서비스 목록 추출
- `05-infra-overview.md`에서 인프라 정보 추출
- `06-dependency-map.md`에서 의존성 정보 추출

JSON이 별도 저장되어 있는 경우 (`_service-discovery.json`, `_infra-analysis.json`, `_dependency-map.json`) 해당 파일을 직접 사용합니다.

## Phase 3: 교차 검증 (Lead 직접 수행)

`verification-standards.md`의 "교차 검증 — 5단계"를 참조하여 직접 수행합니다.

1. **서비스 일관성**: 서비스 목록 ↔ 의존성 맵 대조
2. **인프라-의존성 정합**: 인프라 정보 ↔ 의존성 맵 대조
3. **완전성 검사**: AskUserQuestion으로 원본 프로젝트 경로를 확인하여 소스 코드 대조
4. **Devil's Advocate**: `[확인 필요]` 항목 소스 코드 검증
5. **신뢰도 점수 산출**: 100점 기준 감점 방식

## Phase 4: 리포트 검증 (Lead 직접 수행)

`verification-standards.md`의 "리포트 검증 — 4단계"를 참조하여 직접 수행합니다.

1. **Mermaid 문법 유효성**: alias 규칙, 구조, 요소별 문법
2. **Obsidian 링크 유효성**: 위키 링크, 프론트매터
3. **C4 모델 완전성**: Level 1/2/3 필수 요소
4. **분석결과-리포트 일치성**: 복원된 분석 결과와 리포트 대조

### 판정 기준 (리포트 검증)

| 점수 | 처리 |
|------|------|
| 80-100 | 최종 출력 |
| 60-79 | Mermaid/링크 자동 수정 시도 → 재검증 1회. 미달 시 오류 목록과 함께 출력 |
| 0-59 | `❌ 품질 검증 미달` 경고 + 오류 목록 + 수동 수정 가이드 |

## Phase 5: 결과 출력

사용자에게 다음을 출력합니다:

1. **신뢰도 점수** (교차 검증): 점수/100
   - 80-100: ✅ PASS
   - 60-79: ⚠️ WARN — 수동 확인 권장 항목 요약
   - 0-59: ❌ FAIL — 주요 이슈 목록
2. **품질 점수** (리포트 검증): 점수/100
   - 80-100: ✅ PASS
   - 60-79: ⚠️ WARN — 자동 수정/미수정 항목 요약
   - 0-59: ❌ FAIL — 오류 목록 + 수동 수정 가이드
3. **발견된 이슈 목록** (심각도별 정렬)
4. **수정 제안** (자동 수정 가능 여부 표시)
