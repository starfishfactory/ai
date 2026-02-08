# 출력 파일 템플릿

## README.md 템플릿

```markdown
---
created: {날짜}
target: {분석 대상 경로}
tags:
  - msa
  - c4-model
  - architecture
  - onboarding
---

# MSA 아키텍처 리포트

> 이 문서는 `msa-onboard` 플러그인으로 자동 생성되었습니다.

## 개요

- **분석 대상**: {프로젝트 경로}
- **분석 일시**: {날짜}
- **서비스 수**: {N}개
- **아키텍처 유형**: {mono-repo / multi-repo}

## 목차

1. [[01-system-context|System Context (Level 1)]]
2. [[02-container|Container (Level 2)]]
3. [[03-components/|Component (Level 3)]]
4. [[04-service-catalog|서비스 카탈로그]]
5. [[05-infra-overview|인프라 구성]]
6. [[06-dependency-map|의존성 맵]]

## 기술 스택 요약

| 영역 | 기술 |
|------|------|
| 언어 | {언어 목록} |
| 프레임워크 | {프레임워크 목록} |
| 데이터베이스 | {DB 목록} |
| 메시지 큐 | {MQ 목록} |
| 인프라 | {인프라 목록} |
```

## 01-system-context.md 템플릿

```markdown
---
created: {날짜}
tags:
  - c4-model
  - system-context
---

# System Context (Level 1)

> 시스템 전체와 외부 시스템/사용자의 관계를 보여줍니다.

## 다이어그램

\`\`\`mermaid
C4Context
    title System Context - {시스템 이름}

    Person(user, "사용자", "시스템을 사용하는 사람")
    System(system, "{시스템 이름}", "{시스템 설명}")
    {외부 시스템들}
    {관계들}
\`\`\`

## 설명

| 요소 | 설명 |
|------|------|
| {요소} | {설명} |

## 관련 문서

- [[02-container|Container Diagram →]]
- [[04-service-catalog|서비스 카탈로그]]
```

## 02-container.md 템플릿

```markdown
---
created: {날짜}
tags:
  - c4-model
  - container
---

# Container (Level 2)

> 시스템 내부의 배포 단위(서비스, DB, MQ 등)를 보여줍니다.

## 다이어그램

\`\`\`mermaid
C4Container
    title Container Diagram - {시스템 이름}

    {사용자}
    Container_Boundary(system, "{시스템 이름}") {
        {컨테이너들}
    }
    {관계들}
\`\`\`

## 서비스 목록

| 서비스 | 기술 | 역할 | 포트 |
|--------|------|------|------|
| {이름} | {기술} | {역할} | {포트} |

## 관련 문서

- [[01-system-context|← System Context]]
- [[03-components/|Component Diagram →]]
- [[06-dependency-map|의존성 맵]]
```

## 03-components/{service}.md 템플릿

```markdown
---
created: {날짜}
service: {서비스 이름}
tags:
  - c4-model
  - component
  - {서비스 이름}
---

# Component - {서비스 이름} (Level 3)

> {서비스 이름}의 내부 컴포넌트 구조를 보여줍니다.

## 다이어그램

\`\`\`mermaid
C4Component
    title Component Diagram - {서비스 이름}

    Container_Boundary(svc, "{서비스 이름}") {
        {컴포넌트들}
    }
    {외부 의존성}
    {관계들}
\`\`\`

## 컴포넌트 설명

| 컴포넌트 | 기술 | 역할 |
|----------|------|------|
| {이름} | {기술} | {역할} |

## API 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| {GET/POST/...} | {경로} | {설명} |

## 관련 문서

- [[../02-container|← Container Diagram]]
- [[../04-service-catalog#{서비스}|서비스 카탈로그]]
```

## 04-service-catalog.md 템플릿

```markdown
---
created: {날짜}
tags:
  - msa
  - service-catalog
---

# 서비스 카탈로그

## 서비스 목록

### {서비스 이름}

| 항목 | 값 |
|------|---|
| 경로 | `{경로}` |
| 언어 | {언어} |
| 프레임워크 | {프레임워크} |
| 빌드 도구 | {빌드 도구} |
| 포트 | {포트} |
| DB | {DB 종류} |
| 주요 역할 | {설명} |

## 기술 스택 매트릭스

| 서비스 | 언어 | 프레임워크 | DB | MQ |
|--------|------|-----------|----|----|
| {이름} | {언어} | {FW} | {DB} | {MQ} |
```

## 05-infra-overview.md 템플릿

```markdown
---
created: {날짜}
tags:
  - msa
  - infrastructure
---

# 인프라 구성

## 컨테이너 오케스트레이션

{Docker Compose / Kubernetes / ECS 등}

## 네트워크 구성

| 네트워크 | 연결된 서비스 | 용도 |
|----------|-------------|------|
| {이름} | {서비스들} | {용도} |

## CI/CD 파이프라인

| 단계 | 도구 | 설명 |
|------|------|------|
| {빌드/테스트/배포} | {도구} | {설명} |

## 환경 설정

| 서비스 | 주요 환경변수 키 |
|--------|-----------------|
| {서비스} | {키 목록 (값 제외)} |

## 관련 문서

- [[02-container|Container Diagram]]
- [[04-service-catalog|서비스 카탈로그]]
```

## 06-dependency-map.md 템플릿

```markdown
---
created: {날짜}
tags:
  - msa
  - dependency
---

# 의존성 맵

## 서비스 간 통신

| From | To | 프로토콜 | 설명 | 신뢰도 |
|------|----|---------|------|--------|
| {서비스A} | {서비스B} | REST/gRPC/Kafka | {설명} | 확인됨/[확인 필요] |

## 데이터베이스 연결

| 서비스 | DB | 종류 | 접근 방식 |
|--------|-----|------|----------|
| {서비스} | {DB명} | {PostgreSQL/MongoDB...} | {JDBC/Mongoose...} |

## 메시지 큐

| Producer | Topic/Queue | Consumer | 브로커 |
|----------|------------|----------|--------|
| {서비스} | {토픽명} | {서비스} | Kafka/RabbitMQ |

## 외부 시스템 연동

| 서비스 | 외부 시스템 | 프로토콜 | 설명 |
|--------|-----------|---------|------|
| {서비스} | {외부} | {HTTP/SDK} | {설명} |

## 의존성 다이어그램

\`\`\`mermaid
graph LR
    {서비스 간 의존성 그래프}
\`\`\`

## 관련 문서

- [[02-container|Container Diagram]]
- [[04-service-catalog|서비스 카탈로그]]
```
