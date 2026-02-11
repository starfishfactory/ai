---
description: SDD 방법론 기반 Tech Spec 작성 (Generator-Critic 루프)
allowed-tools: Read, Write, Glob, Grep, Bash, Task, AskUserQuestion
argument-hint: <Spec 주제/기능 설명>
---

# Tech Spec 작성: $ARGUMENTS

SDD(Specification-Driven Development) 방법론 기반으로 Tech Spec을 작성한다.
Generator-Critic 루프 패턴으로 초안 생성 → 비평 → 개선을 반복하여 품질 임계값(80점)을 달성한다.

---

## Phase 0: 컨텍스트 수집

### Step 0.1: Spec 유형 선택
AskUserQuestion으로 Spec 유형을 확인한다:

- **기능 설계** (feature-design): 사용자 스토리, 인터페이스 계약, 수용 기준 중심
- **시스템 아키텍처** (system-architecture): C4 모델, 서비스 간 통신, 데이터 흐름 중심
- **API 스펙** (api-spec): 엔드포인트, 요청/응답 스키마, 에러 코드 중심
- **기타**: 범용 템플릿 적용

### Step 0.2: 프로젝트 경로 (선택)
AskUserQuestion으로 코드 분석을 위한 프로젝트 경로를 확인한다.
기본값은 "없음" (코드 분석 생략).

### Step 0.3: 출력 경로
AskUserQuestion으로 출력 경로를 확인한다.
기본값: `./docs/specs/`

### Step 0.4: 프로젝트 컨텍스트 스캔 (프로젝트 경로 제공 시)
프로젝트 경로가 제공된 경우 다음을 자동 스캔한다:
- 디렉토리 구조 (Glob `**/*`) → 아키텍처 섹션 반영
- 빌드 파일 (Glob `**/package.json`, `**/pom.xml`, `**/build.gradle*`, `**/Cargo.toml`, `**/go.mod`) → 의존성 섹션 반영
- 기존 API 엔드포인트 (Grep `@(Get|Post|Put|Delete|Patch)Mapping|router\.(get|post|put|delete)|app\.(get|post|put|delete)`) → API 스펙 섹션 반영
- 기술 스택 탐지 → 상세 설계 섹션 반영

### 스킬 로드
다음 스킬 파일을 Read로 읽어 컨텍스트로 활용한다:
- `skills/sdd-framework/SKILL.md`
- `skills/tech-spec-template/SKILL.md`
- `skills/quality-criteria/SKILL.md`
- `skills/spec-examples/SKILL.md`

---

## Phase 1: Goals/Non-Goals 확인

### Step 1.1: Goals/Non-Goals 초안 생성
Task 도구로 spec-generator를 호출한다:
- **프롬프트 구성**: `agents/spec-generator.md` 내용을 Read로 읽어 포함
- **전달 정보**: 주제(`$ARGUMENTS`), Spec 유형, 프로젝트 컨텍스트
- **요청**: Goals/Non-Goals 초안만 작성 (전체 Spec이 아님)
- **subagent_type**: `general-purpose`

### Step 1.2: 사용자 확인
AskUserQuestion으로 Goals/Non-Goals 초안을 제시하고 확인/수정을 요청한다.
사용자가 수정한 내용을 확정된 Goals/Non-Goals로 저장한다.

---

## Phase 2: Generator-Critic 루프 (최대 3회)

반복 N (N = 1, 2, 3):

### Step 2.N.1: Generator 호출
Task 도구로 spec-generator를 호출한다:
- **프롬프트 구성**: `agents/spec-generator.md` 내용을 Read로 읽어 포함
- **전달 정보**:
  - (N=1): 주제, 확정된 Goals/Non-Goals, Spec 유형, 프로젝트 컨텍스트, 관련 스킬 내용
  - (N>1): 이전 Spec 초안 전문 + Critic 피드백 JSON 전문
- **subagent_type**: `general-purpose`
- **출력**: `{출력경로}/_draft-v{N}.md` 로 Write 저장

### Step 2.N.2: Critic 호출
Task 도구로 spec-critic을 호출한다:
- **프롬프트 구성**: `agents/spec-critic.md` 내용을 Read로 읽어 포함
- **전달 정보**: `_draft-v{N}.md` 내용 + 원본 요구사항(주제, Goals/Non-Goals)
- **subagent_type**: `general-purpose`
- **출력**: `{출력경로}/_review-v{N}.json` 으로 Write 저장

### Step 2.N.3: 판정
`_review-v{N}.json`의 `score`와 `verdict`를 확인한다:
- **PASS** (80점 이상): 루프 종료, Phase 3 진행
- **REVISE** (60-79점): 다음 반복으로 진행 (score, 주요 이슈 요약 출력)
- **FAIL** (60점 미만): AskUserQuestion으로 선택 요청:
  - "계속": 다음 반복 진행 (REVISE와 동일)
  - "수정": Goals/Non-Goals 재설정 후 Phase 1로 복귀
  - "취소": 임시 파일 보존 후 종료

### 3회 후 PASS 미달 시
마지막 버전(`_draft-v3.md`)으로 Phase 3를 진행한다.
최종 출력에 `_review-v3.json`의 잔여 이슈 목록을 포함한다.

---

## Phase 3: 최종 출력

### Step 3.1: 확정 Spec 저장
확정된 Spec을 `{출력경로}/{제목-slug}.md` 로 저장한다.
- 파일명은 제목을 kebab-case 슬러그로 변환 (한글은 음역 또는 영문 변환)
- YAML frontmatter에 최종 메타데이터 확정:
  ```yaml
  ---
  title: {Spec 제목}
  status: draft
  tags: [{관련 태그들}]
  created: {오늘 날짜 YYYY-MM-DD}
  spec-type: {선택한 유형}
  ---
  ```

### Step 3.2: 임시 파일 정리
AskUserQuestion으로 임시 파일(`_draft-*`, `_review-*`) 보존 여부를 확인한다:
- "삭제": Bash rm으로 `{출력경로}/_draft-*` `{출력경로}/_review-*` 제거
- "보존": 그대로 유지 (디버깅/이력 용도)

### Step 3.3: 결과 요약
다음 정보를 출력한다:
- 최종 점수 및 판정
- Generator-Critic 반복 횟수
- 잔여 이슈 목록 (있는 경우)
- 최종 파일 경로
