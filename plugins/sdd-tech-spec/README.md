# sdd-tech-spec

SDD(Specification-Driven Development) 방법론 기반 Tech Spec 풀 파이프라인 플러그인.
**Discuss → Write Spec → Decompose Tasks → Detect Drift** 전체 워크플로우를 지원한다.

## 파이프라인

```
discuss ──► write-spec ──► decompose-tasks ──► (implement) ──► detect-drift
(선택적)    +tier system    Generator-Critic                    Spec↔Code
             G-C loop       loop                                비교
                │
                ├──► review-spec
                └──► refine-spec
```

## 커맨드

| 커맨드 | 설명 | 용도 |
|--------|------|------|
| `/sdd-tech-spec:discuss <주제>` | 소크라테스식 요구사항 탐색 | Spec 작성 전 요구사항 정리 |
| `/sdd-tech-spec:write-spec <주제>` | Generator-Critic 루프로 Tech Spec 작성 | 신규 Spec 작성 |
| `/sdd-tech-spec:review-spec <파일>` | 기존 Spec에 Critic만 실행 (읽기 전용) | 품질 리뷰 |
| `/sdd-tech-spec:refine-spec <파일>` | 기존 Spec에 1회 Generator-Critic 루프 | 기존 Spec 개선 |
| `/sdd-tech-spec:decompose-tasks <파일>` | Spec을 구현 태스크로 분해 | Spec→Task 변환 |
| `/sdd-tech-spec:detect-drift <파일>` | Spec↔코드 괴리 감지 | 구현 후 정합성 확인 |

## Tier 시스템

Spec 복잡도에 따라 3단계 Tier를 자동 추천한다:

| 차원 | Light | Standard | Deep |
|------|-------|----------|------|
| 분량 | 1~2p | 5~10p | 10~20p |
| Goals 최소 | 2 | 3 | 5 |
| Non-Goals 최소 | 1 | 2 | 3 |
| Mermaid | 선택 | 1+ 필수 | 3+ 필수 |
| 대안 검토 | 불필요 | 2+ | 3+ |
| 리스크 | 1 | 3 (유형별 1+) | 5+ 정량 매트릭스 |
| G-C 루프 | 최대 1회 | 최대 3회 | 최대 5회 |
| PASS 임계값 | 70점 | 80점 | 85점 |
| 적합 상황 | 버그수정, 설정변경 | 중간기능, API변경 | 신규시스템, 대규모마이그레이션 |

**자동 선택 기준**: 사용자 명시 > 키워드(fix→Light, feature→Standard, migration→Deep) > 코드 컨텍스트(변경 파일 수) > 사용자 확인

## 아키텍처

```
                ┌──────────┐
                │ discuss  │ ← 요구사항 탐색 (선택적)
                └─────┬────┘
                      │ _discuss-summary.md
                      ▼
                ┌──────────┐
                │write-spec│ ← 오케스트레이터 + Tier 선택
                └─────┬────┘
                      │
       Phase 0~3 흐름 제어
                      │
       ┌──────────────┼──────────────┐
       ▼                             ▼
┌──────────────┐           ┌──────────────┐
│spec-generator│◄─────────►│ spec-critic  │
│ (에이전트)    │ G-C 루프   │ (에이전트)    │
│ 초안작성/개선 │ (Tier별    │ 100점 감점   │
└──────┬───────┘  최대N회)  └──────┬───────┘
       │                          │
       ▼                          ▼
┌──────────────┐           ┌──────────────┐
│ sdd-framework│           │quality-criteria│
│ tech-spec-   │           │ tier-system   │
│ template     │           │  (스킬)       │
│ spec-examples│           └──────────────┘
│  (스킬)      │
└──────────────┘

        ┌────────────────┐
        │decompose-tasks │ ← Spec→Task 분해
        └───────┬────────┘
                │
     ┌──────────┼──────────┐
     ▼                     ▼
┌──────────┐         ┌──────────┐
│task-     │◄───────►│task-     │
│planner   │ G-C     │critic    │
│(에이전트) │ (최대2회)│(에이전트) │
└──────────┘         └──────────┘

        ┌────────────────┐
        │ detect-drift   │ ← Spec↔Code 비교
        └───────┬────────┘
                │
                ▼
        ┌──────────────┐
        │drift-analyzer│
        │ (에이전트)    │
        └──────────────┘
```

## 워크플로우

### discuss (요구사항 탐색)

```
Phase 1: 문제 정의 — 무엇을, 왜, 지금?
Phase 2: 범위 탐색 — MVP, 제외사항
Phase 3: 사용자/이해관계자 — 누가, 성공 기준
Phase 4: 기술 제약 — 연동, 제약, 성능
Phase 5: 종합 → _discuss-summary.md 생성
```

### write-spec (Tech Spec 작성)

```
Phase 0: 컨텍스트 수집
  ├── Discuss 연계 (_discuss-summary.md 자동 감지)
  ├── Spec 유형 선택 (기능설계/시스템아키텍처/API스펙/기타)
  ├── Tier 선택 (Light/Standard/Deep)
  ├── 프로젝트 경로 (선택, 코드 분석용)
  ├── 출력 경로 (기본값: ./docs/specs/)
  └── 프로젝트 자동 스캔

Phase 1: Goals/Non-Goals 확인
  ├── Generator → Goals/Non-Goals 초안
  └── 사용자 확인/수정

Phase 2: Generator-Critic 루프 (Tier별 최대: L:1 / S:3 / D:5)
  ├── Generator → _draft-vN.md
  ├── Critic → _review-vN.json
  └── 판정: PASS / REVISE / FAIL (Tier별 임계값)

Phase 3: 최종 출력
  ├── {제목-slug}.md 저장
  ├── 임시 파일 정리
  └── 결과 요약 + decompose-tasks 안내
```

### decompose-tasks (Spec→Task 분해)

```
Phase 0: Spec 로드 + 유형/Tier 감지
Phase 1: Generator-Critic 루프 (최대 2회)
  ├── task-planner → _tasks-vN.md
  ├── task-critic → _task-review-vN.json
  └── 판정: PASS(80+) / REVISE / FAIL
Phase 2: 사용자 확인/조정
Phase 3: {spec-slug}-tasks.md 저장
```

### detect-drift (Spec↔코드 괴리 감지)

```
Phase 0: Spec 읽기 + 프로젝트 경로 확인
Phase 1: Spec 요소 추출 (API, 데이터 모델, 의존성, 설정)
Phase 2: drift-analyzer로 코드 스캔
Phase 3: 리포트 생성 ({spec-slug}-drift.md)
```

## Generator-Critic 루프 적용

| 기능 | Generator | Critic | 최대 반복 |
|------|-----------|--------|----------|
| write-spec | spec-generator | spec-critic | Light:1 / Standard:3 / Deep:5 |
| decompose-tasks | task-planner | task-critic | 2 |
| detect-drift | drift-analyzer | (비교 로직 내장) | 1 (단일 패스) |

## 품질 평가 기준

100점 만점, 5개 카테고리 감점 방식 (Tier별 조정):

| 카테고리 | 배점 | 주요 검증 항목 |
|---------|------|---------------|
| 완전성 | 30점 | 필수 섹션, Goals/Non-Goals 최소 개수, FR/NFR |
| 구체성 | 25점 | 모호 표현 배제, NFR 수치 기준, Mermaid 다이어그램 |
| 일관성 | 15점 | Goals↔설계 정합성, 용어 통일, 참조 유효성 |
| 실행가능성 | 15점 | 의존성 명시, 마일스톤 논리성, 제약사항 식별 |
| 리스크관리 | 15점 | 유형별 리스크, 영향도/확률, 완화 전략 |

## 출력 형식

- **GFM 표준 마크다운**: GitHub PR 리뷰 환경 대상
- **YAML frontmatter**: title, status, tags, created, spec-type, tier
- **표준 링크**: `[text](file.md)` (`[[위키링크]]` 미사용)
- **Mermaid 다이어그램**: 아키텍처, 시퀀스, 상태 다이어그램

## 사용 예시

```bash
# 요구사항 탐색 (선택적)
> /sdd-tech-spec:discuss 사용자 인증 시스템 설계

# 신규 Spec 작성
> /sdd-tech-spec:write-spec 사용자 인증 시스템 설계

# 기존 Spec 리뷰
> /sdd-tech-spec:review-spec ./docs/specs/auth-system.md

# 기존 Spec 개선
> /sdd-tech-spec:refine-spec ./docs/specs/auth-system.md

# Spec → Task 분해
> /sdd-tech-spec:decompose-tasks ./docs/specs/auth-system.md

# Spec ↔ 코드 괴리 감지
> /sdd-tech-spec:detect-drift ./docs/specs/auth-system.md
```

## 설치

### 마켓플레이스 (권장)

클론 없이 Claude Code 안에서 바로 설치한다.

```shell
/plugin marketplace add starfishfactory/ai
/plugin install sdd-tech-spec@starfishfactory-ai
```

### 플러그인 모드

repo를 클론한 후 로컬 경로를 지정한다.

```bash
claude --plugin-dir ./plugins/sdd-tech-spec
```

## 업데이트

### 마켓플레이스

마켓플레이스 갱신 후 플러그인을 업데이트한다:

```shell
/plugin marketplace update starfishfactory-ai
```

> 자동 업데이트를 활성화하면 마켓플레이스 갱신과 플러그인 업데이트가 Claude Code 시작 시 자동으로 수행된다:
> `/plugin` 실행 → **Marketplaces** 탭 → `starfishfactory-ai` 선택 → **Enable auto-update**

### 플러그인 모드

로컬 저장소를 pull하고 Claude Code를 재시작하면 된다.

```bash
git pull origin main
```

## 제거

### 마켓플레이스

```shell
/plugin uninstall sdd-tech-spec@starfishfactory-ai
```

### 플러그인 모드

`--plugin-dir` 옵션을 제거하면 된다.

## 구조

```
plugins/sdd-tech-spec/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── spec-generator.md      # Tech Spec 작성 에이전트
│   ├── spec-critic.md         # Tech Spec 비평 에이전트
│   ├── task-planner.md        # Task 분해 에이전트
│   ├── task-critic.md         # Task 분해 비평 에이전트
│   └── drift-analyzer.md     # Spec↔코드 괴리 분석 에이전트
├── skills/
│   ├── discuss/SKILL.md       # 요구사항 탐색
│   ├── write-spec/SKILL.md    # 메인: Generator-Critic 루프
│   ├── review-spec/SKILL.md   # 읽기 전용 리뷰
│   ├── refine-spec/SKILL.md   # 1회 개선
│   ├── decompose-tasks/SKILL.md # Spec→Task 분해
│   ├── detect-drift/SKILL.md  # Spec↔코드 괴리 감지
│   ├── tier-system/SKILL.md   # Light/Standard/Deep Tier 정의
│   ├── sdd-framework/SKILL.md # SDD 방법론 + 유형별 가이드
│   ├── tech-spec-template/
│   │   ├── SKILL.md           # GFM 출력 템플릿
│   │   └── references/
│   │       ├── full-template.md   # Standard/Deep 템플릿
│   │       └── light-template.md  # Light 축약 템플릿
│   ├── quality-criteria/
│   │   └── SKILL.md           # 감점 테이블 + Tier별 조정
│   ├── task-format/
│   │   ├── SKILL.md           # Task 출력 포맷
│   │   └── references/
│   │       └── task-template.md   # Task 목록 템플릿
│   └── spec-examples/
│       ├── SKILL.md           # 좋은/나쁜 패턴 예시
│       └── references/
│           └── patterns.md    # 패턴 상세 예제
└── README.md
```
