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

## Phase 3: 교차 검증 — Generator-Critic Self-Reflection 루프 (최대 3회)

> **역할 분담**: Generator = Lead (분석 결과 수정), Critic = Lead (교차 검증 수행). Self-Reflection 패턴.
> verify-report에서는 Agent Teams를 사용하지 않으므로 Lead가 양 역할을 수행합니다.
> ※ 3단계(완전성 검사)에서 원본 소스 코드 대조가 필요하므로, 해당 단계에서 AskUserQuestion으로 원본 프로젝트 경로를 확인합니다.

`verification-standards.md`의 "교차 검증 — 5단계"를 참조합니다.

### 루프 절차 (Round 1~3)

각 Round에서 다음을 수행합니다:

#### Critic (Lead): 교차 검증 수행

1. **서비스 일관성**: 서비스 목록 ↔ 의존성 맵 대조
2. **인프라-의존성 정합**: 인프라 정보 ↔ 의존성 맵 대조
3. **완전성 검사**: AskUserQuestion으로 원본 프로젝트 경로를 확인하여 소스 코드 대조
4. **Devil's Advocate**: `[확인 필요]` 항목 소스 코드 검증
5. **신뢰도 점수 산출**: 100점 기준 감점 방식

#### 판정 및 분기

| 점수 | 판정 | 처리 |
|------|------|------|
| 80-100 | PASS | 루프 즉시 종료 → Phase 4 진행 |
| < 80 | WARN/FAIL | 피드백 작성 → Generator(Lead)가 JSON/리포트 수정 → 다음 Round |

#### Generator (Lead): 피드백 기반 수정

Critic(Lead)이 PASS 미달 시, 불일치 항목을 직접 수정합니다:
- 서비스 이름 불일치 통일
- 누락된 의존성/DB 연결 추가
- `[확인 필요]` 항목 업데이트

### 루프 종료 조건

| 조건 | 처리 |
|------|------|
| PASS(80+) 달성 | 즉시 Phase 4 진행 |
| 3회 완료 후 WARN(60-79) | 경고와 함께 Phase 4 진행 |
| 3회 완료 후 FAIL(0-59) | AskUserQuestion: (1) 계속 진행 (2) 취소 |

---

## Phase 4: 리포트 검증 — Generator-Critic Self-Reflection 루프 (최대 3회)

> **역할 분담**: Generator = Lead (리포트 수정), Critic = Lead (리포트 검증). Self-Reflection 패턴.

`verification-standards.md`의 "리포트 검증 — 4단계"를 참조합니다.

### 루프 절차 (Round 1~3)

각 Round에서 다음을 수행합니다:

#### Critic (Lead): 리포트 검증 수행

1. **Mermaid 문법 유효성**: alias 규칙, 구조, 요소별 문법
2. **Obsidian 링크 유효성**: 위키 링크, 프론트매터
3. **C4 모델 완전성**: Level 1/2/3 필수 요소
4. **분석결과-리포트 일치성**: 복원된 분석 결과와 리포트 대조

#### 판정 및 분기

| 점수 | 판정 | 처리 |
|------|------|------|
| 80-100 | PASS | 루프 즉시 종료 → Phase 5 진행 |
| < 80 | WARN/FAIL | 피드백(이슈 목록) 작성 → Generator(Lead)가 수정 → 다음 Round |

#### Generator (Lead): 피드백 기반 수정

Critic(Lead)이 PASS 미달 시, `autoFixable` 항목을 중심으로 수정합니다:
- Mermaid alias 규칙 위반 수정 (예: `user-service` → `userservice`)
- Obsidian 깨진 링크 수정
- 누락 C4 요소 추가
- 수정 내역을 `_report-audit.json`의 `fixHistory`에 기록

### 루프 종료 조건 (리포트 검증)

| 조건 | 처리 |
|------|------|
| PASS(80+) 달성 | 즉시 Phase 5 진행 |
| 3회 완료 후 60+ | 경고와 함께 Phase 5 진행 |
| 3회 완료 후 < 60 | `❌ 품질 검증 미달` 경고 + 오류 목록 + 수동 수정 가이드 |

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
