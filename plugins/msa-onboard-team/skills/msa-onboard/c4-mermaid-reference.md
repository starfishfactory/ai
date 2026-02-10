# C4 모델 + Mermaid 문법 참조

## C4 모델 개요

C4 모델은 소프트웨어 아키텍처를 4개 레벨로 시각화합니다:

| 레벨 | 이름 | 대상 청중 | 설명 |
|------|------|-----------|------|
| 1 | System Context | 모든 사람 | 시스템과 외부 시스템/사용자의 관계 |
| 2 | Container | 기술 팀 | 서비스, DB, MQ 등 배포 단위 |
| 3 | Component | 개발자 | 주요 서비스의 내부 컴포넌트 |
| 4 | Code | 개발자 | 클래스/모듈 수준 (이 플러그인에서는 미사용) |

## Mermaid C4 문법

### Level 1: System Context

```mermaid
C4Context
    title System Context Diagram

    Person(user, "사용자", "시스템을 사용하는 사람")

    System(system, "대상 시스템", "분석 대상 MSA 시스템")

    System_Ext(extSystem, "외부 시스템", "외부 연동 시스템")

    Rel(user, system, "사용")
    Rel(system, extSystem, "API 호출")
```

### Level 2: Container

```mermaid
C4Container
    title Container Diagram

    Person(user, "사용자")

    Container_Boundary(system, "대상 시스템") {
        Container(web, "Web App", "React", "프론트엔드")
        Container(api, "API Gateway", "Spring Cloud Gateway", "라우팅")
        Container(svc1, "Service A", "Spring Boot", "비즈니스 로직")
        Container(svc2, "Service B", "Node.js", "비즈니스 로직")
        ContainerDb(db1, "Database A", "PostgreSQL", "데이터 저장")
        ContainerQueue(mq, "Message Queue", "Kafka", "비동기 통신")
    }

    Rel(user, web, "HTTPS")
    Rel(web, api, "REST API")
    Rel(api, svc1, "REST")
    Rel(api, svc2, "REST")
    Rel(svc1, db1, "JDBC")
    Rel(svc1, mq, "publish")
    Rel(svc2, mq, "subscribe")
```

### Level 3: Component

```mermaid
C4Component
    title Component Diagram - Service A

    Container_Boundary(svc, "Service A") {
        Component(ctrl, "Controller", "Spring MVC", "REST API 엔드포인트")
        Component(service, "Service Layer", "Spring", "비즈니스 로직")
        Component(repo, "Repository", "Spring Data JPA", "데이터 접근")
        Component(client, "External Client", "WebClient", "외부 API 호출")
    }

    ContainerDb(db, "Database", "PostgreSQL")
    Container(extSvc, "External Service")

    Rel(ctrl, service, "호출")
    Rel(service, repo, "쿼리")
    Rel(service, client, "HTTP 요청")
    Rel(repo, db, "SQL")
    Rel(client, extSvc, "REST API")
```

## C4 요소 타입 정리

| 요소 | Mermaid 문법 | 용도 |
|------|-------------|------|
| 사람 | `Person(alias, "이름", "설명")` | 사용자, 관리자 |
| 시스템 | `System(alias, "이름", "설명")` | 분석 대상 시스템 |
| 외부 시스템 | `System_Ext(alias, "이름", "설명")` | 외부 연동 |
| 컨테이너 | `Container(alias, "이름", "기술", "설명")` | 서비스, 앱 |
| DB | `ContainerDb(alias, "이름", "기술", "설명")` | 데이터베이스 |
| 큐 | `ContainerQueue(alias, "이름", "기술", "설명")` | 메시지 큐 |
| 컴포넌트 | `Component(alias, "이름", "기술", "설명")` | 내부 모듈 |
| 경계 | `Container_Boundary(alias, "이름")` | 그룹핑 |
| 관계 | `Rel(from, to, "라벨")` | 의존성 표현 |

## 관계(Rel) 표현 가이드

| 유형 | 라벨 예시 |
|------|-----------|
| REST API | `"REST/HTTP"`, `"GET /api/users"` |
| gRPC | `"gRPC"` |
| 메시지 | `"publish/subscribe"`, `"Kafka: topic-name"` |
| DB 접근 | `"JDBC"`, `"SQL"`, `"MongoDB Driver"` |
| 파일 | `"S3"`, `"NFS"` |

## 주의사항

1. alias는 영문 소문자 + 숫자만 사용 (하이픈, 공백 불가)
2. 이름과 설명은 한글 사용 가능
3. Mermaid C4 다이어그램은 Obsidian 1.4+에서 네이티브 렌더링
4. GitHub에서도 Mermaid C4 지원
5. 다이어그램이 복잡할 경우 서비스 그룹별로 분리
