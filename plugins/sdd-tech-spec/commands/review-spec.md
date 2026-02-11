---
description: 기존 Tech Spec에 대한 SDD 품질 리뷰 (읽기 전용)
allowed-tools: Read, Grep, Glob, Task
argument-hint: <Spec 파일 경로>
---

# Tech Spec 리뷰: $ARGUMENTS

기존 Tech Spec 파일을 SDD 품질 기준으로 평가한다.
파일을 수정하거나 생성하지 않으며, 평가 결과만 출력한다.

---

## Step 1: Spec 파일 읽기

`$ARGUMENTS` 경로의 파일을 Read로 읽는다.
파일이 존재하지 않으면 오류 메시지를 출력하고 종료한다.

## Step 2: Spec 유형 감지

YAML frontmatter의 `spec-type` 필드를 확인한다:
- `feature-design`: 기능 설계
- `system-architecture`: 시스템 아키텍처
- `api-spec`: API 스펙
- 필드 없음 또는 기타 값: "기타"로 간주

## Step 3: 스킬 및 에이전트 프롬프트 로드

다음 파일을 Read로 읽는다:
- `agents/spec-critic.md`: Critic 에이전트 프롬프트
- `skills/quality-criteria/SKILL.md`: 평가 기준 및 감점 테이블
- `skills/sdd-framework/SKILL.md`: SDD 방법론 및 유형별 가이드

## Step 4: Critic 호출

Task 도구로 spec-critic을 호출한다:
- **프롬프트 구성**: `agents/spec-critic.md` 내용 포함
- **전달 정보**:
  - Spec 파일 전문
  - Spec 유형
  - quality-criteria SKILL의 평가 기준
  - sdd-framework SKILL의 유형별 가이드
- **subagent_type**: `general-purpose`
- **요청**: 평가 결과를 quality-criteria SKILL의 JSON 출력 형식으로 반환

## Step 5: 결과 출력

Critic의 평가 결과를 가독성 있게 포맷팅하여 출력한다.
파일 수정이나 생성은 하지 않는다.

### 출력 형식

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Tech Spec 리뷰 결과
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

파일: {파일 경로}
유형: {Spec 유형}
점수: {총점}/100 ({판정})

카테고리별 점수:
  완전성:     {점수}/{만점}
  구체성:     {점수}/{만점}
  일관성:     {점수}/{만점}
  실행가능성: {점수}/{만점}
  리스크관리: {점수}/{만점}

주요 이슈 (major):
  - [{섹션}] {이슈 설명}
    → {개선 제안}

경미한 이슈 (minor):
  - [{섹션}] {이슈 설명}
    → {개선 제안}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
