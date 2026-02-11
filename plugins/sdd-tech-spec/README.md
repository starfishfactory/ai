# sdd-tech-spec

SDD(Specification-Driven Development) 방법론 기반 Tech Spec 작성 플러그인.
**Generator-Critic 루프** 패턴으로 작성 에이전트가 초안을 생성하고, 비평 에이전트가 피드백하며, 품질 임계값(80점)까지 반복 개선한다.

## 커맨드

| 커맨드 | 설명 | 용도 |
|--------|------|------|
| `/sdd-tech-spec:write-spec <주제>` | Generator-Critic 루프로 Tech Spec 전체 작성 | 신규 Spec 작성 |
| `/sdd-tech-spec:review-spec <파일>` | 기존 Spec에 Critic만 실행 (읽기 전용) | 품질 리뷰 |
| `/sdd-tech-spec:refine-spec <파일>` | 기존 Spec에 1회 Generator-Critic 루프 | 기존 Spec 개선 |

## 아키텍처

```
                    ┌─────────────────┐
                    │   write-spec    │ ← 오케스트레이터
                    │  (커맨드)       │
                    └────────┬────────┘
                             │
              Phase 0~3 흐름 제어
                             │
            ┌────────────────┼────────────────┐
            ▼                                 ▼
   ┌─────────────────┐              ┌─────────────────┐
   │ spec-generator  │◄────────────►│  spec-critic    │
   │  (에이전트)      │  Generator-  │  (에이전트)      │
   │  초안 작성/개선   │  Critic 루프  │  100점 감점 평가  │
   └────────┬────────┘   (최대 3회)  └────────┬────────┘
            │                                 │
            ▼                                 ▼
   ┌─────────────────┐              ┌─────────────────┐
   │  sdd-framework  │              │ quality-criteria │
   │  tech-spec-     │              │  (감점 테이블)    │
   │  template       │              │                  │
   │  spec-examples  │              │                  │
   │  (스킬)          │              │  (스킬)          │
   └─────────────────┘              └─────────────────┘
```

## 워크플로우 (`write-spec`)

```
Phase 0: 컨텍스트 수집
  ├── Spec 유형 선택 (기능설계/시스템아키텍처/API스펙/기타)
  ├── 프로젝트 경로 (선택, 코드 분석용)
  ├── 출력 경로 (기본값: ./docs/specs/)
  └── 프로젝트 자동 스캔

Phase 1: Goals/Non-Goals 확인
  ├── Generator → Goals/Non-Goals 초안
  └── 사용자 확인/수정

Phase 2: Generator-Critic 루프 (최대 3회)
  ├── Generator → _draft-vN.md
  ├── Critic → _review-vN.json
  └── 판정: PASS(80+) / REVISE(60-79) / FAIL(<60)

Phase 3: 최종 출력
  ├── {제목-slug}.md 저장
  ├── 임시 파일 정리
  └── 결과 요약
```

## 품질 평가 기준

100점 만점, 5개 카테고리 감점 방식:

| 카테고리 | 배점 | 주요 검증 항목 |
|---------|------|---------------|
| 완전성 | 30점 | 필수 섹션, Goals 3개+, Non-Goals 2개+, FR/NFR |
| 구체성 | 25점 | 모호 표현 배제, NFR 수치 기준, Mermaid 다이어그램 |
| 일관성 | 15점 | Goals↔설계 정합성, 용어 통일, 참조 유효성 |
| 실행가능성 | 15점 | 의존성 명시, 마일스톤 논리성, 제약사항 식별 |
| 리스크관리 | 15점 | 3유형 리스크, 영향도/확률, 완화 전략 |

판정: **PASS**(80+) / **REVISE**(60-79) / **FAIL**(<60)

## 출력 형식

- **GFM 표준 마크다운**: GitHub PR 리뷰 환경 대상
- **YAML frontmatter**: title, status, tags, created, spec-type
- **표준 링크**: `[text](file.md)` (`[[위키링크]]` 미사용)
- **Mermaid 다이어그램**: 아키텍처, 시퀀스, 상태 다이어그램

## 사용 예시

```bash
# 플러그인 로드
claude --plugin-dir ./plugins/sdd-tech-spec

# 신규 Spec 작성
> /sdd-tech-spec:write-spec 사용자 인증 시스템 설계

# 기존 Spec 리뷰
> /sdd-tech-spec:review-spec ./docs/specs/auth-system.md

# 기존 Spec 개선
> /sdd-tech-spec:refine-spec ./docs/specs/auth-system.md
```

## 디렉토리 구조

```
plugins/sdd-tech-spec/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── write-spec.md          # 메인: Generator-Critic 루프
│   ├── review-spec.md         # 읽기 전용 리뷰
│   └── refine-spec.md         # 1회 개선
├── agents/
│   ├── spec-generator.md      # Tech Spec 작성 에이전트
│   └── spec-critic.md         # Tech Spec 비평 에이전트
├── skills/
│   ├── sdd-framework/
│   │   └── SKILL.md           # SDD 방법론 + 유형별 가이드
│   ├── tech-spec-template/
│   │   └── SKILL.md           # GFM 출력 템플릿
│   ├── quality-criteria/
│   │   └── SKILL.md           # 감점 테이블 + 피드백 형식
│   └── spec-examples/
│       └── SKILL.md           # 좋은/나쁜 패턴 예시
└── README.md
```
