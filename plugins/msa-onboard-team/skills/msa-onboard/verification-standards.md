# 검증 기준 (Verification Standards)

Lead가 Phase 2(교차 검증)와 Phase 4(리포트 검증)에서 참조하는 검증 기준 문서입니다.

---

## 교차 검증 (Phase 2) — 5단계

### 1단계: 서비스 일관성

service-discoverer와 dependency-mapper의 결과를 대조합니다.

| 검증 항목 | 소스 A | 소스 B | 불일치 유형 |
|-----------|--------|--------|-----------|
| 서비스 존재 | service-discoverer.services | dependency-mapper.serviceDependencies.from/to | 누락 또는 유령 서비스 |
| 서비스 이름 | service-discoverer.services[].name | dependency-mapper.serviceDependencies[].from/to | 명명 불일치 |
| 서비스 수 | service-discoverer.services.length | dependency-mapper에서 참조된 고유 서비스 수 | 수량 불일치 |

**판정**: 불일치 항목당 -5점. 유령 서비스(dependency-mapper에만 존재)는 -10점.

### 2단계: 인프라-의존성 정합

infra-analyzer와 dependency-mapper의 결과를 대조합니다.

| 검증 항목 | 소스 A | 소스 B | 불일치 유형 |
|-----------|--------|--------|-----------|
| 포트 매핑 | infra-analyzer.containerOrchestration.services | dependency-mapper.serviceDependencies.detail | 포트 불일치 |
| DB 연결 | infra-analyzer.storage.databases | dependency-mapper.databaseConnections | DB 누락/불일치 |
| 네트워크 격리 | infra-analyzer.containerOrchestration.networks | dependency-mapper.serviceDependencies | 격리 위반 가능성 |

**판정**: 포트 불일치 -3점. DB 불일치 -5점. 네트워크 격리 위반 -8점.

### 3단계: 완전성 검사

Dockerfile/docker-compose에 정의되어 있으나 분석 결과에서 누락된 서비스를 탐지합니다.

| 검증 항목 | 탐지 방법 |
|-----------|----------|
| 미탐지 서비스 | `Dockerfile` 검색 결과 ↔ service-discoverer 결과 비교 |
| 미탐지 HTTP 통신 | `RestTemplate`, `WebClient`, `axios`, `fetch` 코드 검색 |
| 미탐지 gRPC | `.proto` 파일 검색 |
| 미탐지 MQ | `KafkaTemplate`, `@KafkaListener`, `amqplib` 코드 검색 |
| 미탐지 DB | `jdbc:`, `mongoose.connect`, `redis://` 코드 검색 |

**판정**: 미탐지 서비스당 -10점. 미탐지 통신/DB당 -5점.

### 4단계: Devil's Advocate

`[확인 필요]` 마커가 붙은 항목을 소스 코드에서 직접 확인합니다.

- 확인된 항목: `[확인 필요]` → `확인됨`으로 변경
- 확인 실패 항목: 불일치 목록에 추가
- 확인 불가 항목: `[확인 필요]` 유지 + 리포트에 명시

**판정**: 확인 실패 항목당 -5점. 확인 불가 항목당 -2점.

### 5단계: 신뢰도 점수 산출

**기본 점수**: 100점에서 감점.

| 점수 | 판정 | 처리 |
|------|------|------|
| 80-100 | PASS | 리포트 상단에 `✅ 신뢰도: N%` 표시. 루프 즉시 종료 |
| < 80 | WARN/FAIL | Generator-Critic 루프: Critic(Lead)이 피드백 → Generator(Teammate/Lead)가 JSON 수정 → 재검증 (최대 3회) |

**루프 종료 후 최종 판정**:

| 조건 | 처리 |
|------|------|
| PASS(80+) 달성 | Phase 3 진행 |
| 3회 완료 후 WARN(60-79) | `⚠️ [주의]` 마커 + 부록에 이슈 목록 + "수동 확인 권장". Phase 3 진행 |
| 3회 완료 후 FAIL(0-59) | 리포트 생성 중단. AskUserQuestion: (1) 계속 (2) 재분석 (3) 취소 |

**출력 형식**:

```json
{
  "round": 2,
  "score": 85,
  "verdict": "PASS",
  "history": [
    { "round": 1, "score": 68, "verdict": "WARN", "deductionCount": 7 },
    { "round": 2, "score": 85, "verdict": "PASS", "deductionCount": 3 }
  ],
  "deductions": [
    { "step": 1, "item": "서비스 이름 불일치: user-svc vs user-service", "points": -5 },
    { "step": 3, "item": "미탐지 DB 연결: order-service → Redis", "points": -5 },
    { "step": 4, "item": "확인 불가: payment-service → external-pg", "points": -2 }
  ],
  "corrections": [
    { "field": "dependency-mapper.serviceDependencies[2].to", "from": "user-svc", "to": "user-service", "round": 1 },
    { "field": "dependency-mapper.databaseConnections[+]", "added": "order-service → Redis", "round": 1 }
  ]
}
```

---

## 리포트 검증 (Phase 4) — 4단계

### 1단계: Mermaid 문법 유효성

#### alias 규칙

- 영문 소문자 + 숫자만 허용
- 하이픈(`-`), 공백, 언더스코어(`_`), 한글 불가

**변환 규칙**: `user-service` → `userservice`, `api-gateway` → `apigateway`

#### 구조 검증

- 다이어그램 타입 선언 (`C4Context`, `C4Container`, `C4Component`, `graph`)
- `title` 선언 존재
- 모든 괄호 짝맞춤: `(` ↔ `)`, `{` ↔ `}`
- `Rel(from, to, "라벨")`에서 from/to가 정의된 alias
- 중복 alias 없음
- 코드블록 ` ```mermaid ` ~ ` ``` ` 올바른 래핑

#### 요소별 문법

```
Person(alias, "이름", "설명")
System(alias, "이름", "설명")
System_Ext(alias, "이름", "설명")
Container(alias, "이름", "기술", "설명")
ContainerDb(alias, "이름", "기술", "설명")
ContainerQueue(alias, "이름", "기술", "설명")
Component(alias, "이름", "기술", "설명")
Container_Boundary(alias, "이름") { ... }
Rel(from, to, "라벨")
```

**판정**: 문법 오류당 -5점. 미정의 alias 참조 -10점.

### 2단계: Obsidian 링크 유효성

#### 위키 링크 형식

| 패턴 | 예시 |
|------|------|
| `[[파일명]]` | `[[02-container]]` |
| `[[파일명\|표시명]]` | `[[02-container\|Container Diagram]]` |
| `[[파일명#섹션]]` | `[[04-service-catalog#서비스 목록]]` |
| `[[경로/파일명]]` | `[[03-components/user-service]]` |
| `[[../파일명]]` | `[[../02-container]]` |

#### YAML 프론트매터

```yaml
---
created: YYYY-MM-DD     # 필수
tags:                    # 필수
  - msa
  - c4-model
---
```

#### 검증 항목

- 모든 `[[...]]` 링크가 실제 생성된 파일을 가리킴
- `#섹션` 참조가 대상 파일의 실제 헤딩과 일치
- `03-components/` 하위 파일의 상대 경로가 올바름
- YAML 프론트매터가 유효한 YAML
- 프론트매터에 `created`, `tags` 필드 존재

**판정**: 깨진 링크당 -3점. 프론트매터 누락/오류 -5점.

### 3단계: C4 모델 완전성

#### Level 1 (System Context) 필수 요소

| 요소 | 중요도 |
|------|--------|
| title | 필수 |
| Person 최소 1개 | 필수 |
| System 최소 1개 | 필수 |
| Rel 최소 1개 | 필수 |
| System_Ext (있는 경우) | 권장 |

#### Level 2 (Container) 필수 요소

| 요소 | 중요도 |
|------|--------|
| title | 필수 |
| Container_Boundary | 필수 |
| 모든 서비스 포함 (service-discoverer 결과 전체) | 필수 |
| ContainerDb (DB 있는 경우) | 권장 |
| ContainerQueue (MQ 있는 경우) | 권장 |
| Rel (서비스 간 관계) | 필수 |

#### Level 3 (Component) 필수 요소

| 요소 | 중요도 |
|------|--------|
| title | 필수 |
| Container_Boundary | 필수 |
| Component 최소 1개 | 필수 |
| 외부 의존성 | 권장 |

**판정**: 필수 요소 누락당 -10점. 권장 요소 누락당 -3점.

### 4단계: 분석결과-리포트 일치성

- service-discoverer 결과의 모든 서비스가 Container 다이어그램에 포함되었는지
- dependency-mapper 결과의 주요 의존성이 Rel로 표현되었는지
- infra-analyzer 결과의 DB/MQ가 ContainerDb/ContainerQueue로 표현되었는지
- 교차 검증에서 수정된 항목이 리포트에 반영되었는지

**판정**: 누락 서비스당 -10점. 누락 의존성당 -5점. 미반영 수정사항당 -5점.

---

## 품질 점수 최종 산출

**기본 점수**: 100점에서 4단계 감점 합산.

| 점수 | 처리 |
|------|------|
| 80-100 | 최종 출력. 루프 즉시 종료 |
| < 80 | Generator-Critic 루프: Critic(Lead) 피드백 → Generator(Lead) 수정 → 재검증 (최대 3회) |

**루프 종료 후 최종 판정**:

| 조건 | 처리 |
|------|------|
| PASS(80+) 달성 | 최종 출력 |
| 3회 완료 후 60+ | 경고와 함께 최종 출력 |
| 3회 완료 후 < 60 | `❌ 품질 검증 미달` 경고 + 오류 목록 + 수동 수정 가이드 |

**출력 형식**:

```json
{
  "round": 2,
  "score": 88,
  "verdict": "PASS",
  "history": [
    { "round": 1, "score": 68, "verdict": "WARN", "issueCount": 5, "autoFixCount": 3, "manualFixCount": 2 },
    { "round": 2, "score": 88, "verdict": "PASS", "issueCount": 1, "autoFixCount": 0, "manualFixCount": 1 }
  ],
  "issues": [
    { "step": 2, "severity": "warning", "item": "03-components/order.md: [[../04-service-catalog#주문]] 섹션 미존재", "autoFixable": false }
  ],
  "fixHistory": [
    { "round": 1, "fixed": "02-container.md: alias 'user-service' → 'userservice'", "type": "mermaid-alias" },
    { "round": 1, "fixed": "01-system-context.md: Person 요소 추가", "type": "c4-element" },
    { "round": 1, "fixed": "03-components/order.md: 깨진 링크 수정", "type": "obsidian-link" }
  ],
  "autoFixCount": 0,
  "manualFixCount": 1
}
```
