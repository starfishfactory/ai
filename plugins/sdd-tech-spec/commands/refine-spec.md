---
description: 기존 Tech Spec에 피드백 반영하여 1회 개선
allowed-tools: Read, Write, Glob, Grep, Task, AskUserQuestion
argument-hint: <Spec 파일 경로>
---

# Tech Spec 개선: $ARGUMENTS

기존 Tech Spec 파일에 1회 Generator-Critic 루프를 실행하여 품질을 개선한다.
원본은 `.bak` 파일로 백업하고, 개선된 버전으로 덮어쓴다.

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
- `agents/spec-generator.md`: Generator 에이전트 프롬프트
- `skills/quality-criteria/SKILL.md`: 평가 기준 및 감점 테이블
- `skills/sdd-framework/SKILL.md`: SDD 방법론 및 유형별 가이드
- `skills/tech-spec-template/SKILL.md`: 출력 템플릿
- `skills/spec-examples/SKILL.md`: 작성 패턴 예시

## Step 4: Critic 호출 (현재 상태 평가)

Task 도구로 spec-critic을 호출한다:
- **프롬프트 구성**: `agents/spec-critic.md` 내용 포함
- **전달 정보**: Spec 파일 전문, Spec 유형, quality-criteria SKILL, sdd-framework SKILL
- **subagent_type**: `general-purpose`
- **출력**: 피드백 JSON 획득

현재 점수와 주요 이슈를 사용자에게 요약 출력한다.

## Step 5: Generator 호출 (피드백 반영 개선)

Task 도구로 spec-generator를 호출한다:
- **프롬프트 구성**: `agents/spec-generator.md` 내용 포함
- **전달 정보**:
  - 원본 Spec 전문
  - Critic 피드백 JSON 전문
  - Spec 유형
  - 관련 스킬 내용 (tech-spec-template, spec-examples, sdd-framework)
- **subagent_type**: `general-purpose`
- **요청**: 피드백을 반영하여 개선된 Spec 전문 출력

## Step 6: 백업 및 저장

1. 원본 파일을 `{원본파일명}.bak` 으로 복사 (Bash `cp`)
2. 개선된 Spec을 원본 경로에 Write로 저장

## Step 7: 개선 후 재평가 (선택)

개선된 Spec을 다시 Critic으로 평가하여 점수 변화를 확인한다.
이 단계는 결과 요약에 사용되며, 추가 반복은 하지 않는다.

## Step 8: 결과 요약 출력

다음 정보를 출력한다:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Tech Spec 개선 결과
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

파일: {파일 경로}
백업: {백업 파일 경로}

점수 변화: {개선 전 점수} → {개선 후 점수} ({판정})

카테고리별 변화:
  완전성:     {전} → {후}
  구체성:     {전} → {후}
  일관성:     {전} → {후}
  실행가능성: {전} → {후}
  리스크관리: {전} → {후}

주요 개선 사항:
  - {개선 내용 1}
  - {개선 내용 2}

잔여 이슈 (있는 경우):
  - {미해결 이슈}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
