# C4 Model + Mermaid Syntax Reference

## C4 Model Overview

Visualizes software architecture at 4 levels:

| Level | Name | Audience | Description |
|-------|------|----------|-------------|
| 1 | System Context | Everyone | System and external systems/users relationships |
| 2 | Container | Technical team | Services, DBs, MQs — deployment units |
| 3 | Component | Developers | Internal components of key services |
| 4 | Code | Developers | Class/module level (unused in this plugin) |

## Mermaid C4 Syntax

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

## C4 Element Types

| Element | Mermaid Syntax | Usage |
|---------|---------------|-------|
| Person | `Person(alias, "name", "desc")` | Users, admins |
| System | `System(alias, "name", "desc")` | Target system |
| External System | `System_Ext(alias, "name", "desc")` | External integration |
| Container | `Container(alias, "name", "tech", "desc")` | Services, apps |
| DB | `ContainerDb(alias, "name", "tech", "desc")` | Databases |
| Queue | `ContainerQueue(alias, "name", "tech", "desc")` | Message queues |
| Component | `Component(alias, "name", "tech", "desc")` | Internal modules |
| Boundary | `Container_Boundary(alias, "name")` | Grouping |
| Relationship | `Rel(from, to, "label")` | Dependencies |

## Relationship (Rel) Label Guide

| Type | Label Examples |
|------|---------------|
| REST API | `"REST/HTTP"`, `"GET /api/users"` |
| gRPC | `"gRPC"` |
| Message | `"publish/subscribe"`, `"Kafka: topic-name"` |
| DB access | `"JDBC"`, `"SQL"`, `"MongoDB Driver"` |
| File | `"S3"`, `"NFS"` |

## Rules

1. alias: lowercase + digits only (no hyphens, spaces)
2. Names and descriptions may use Korean
3. Mermaid C4 diagrams render natively in Obsidian 1.4+
4. GitHub also supports Mermaid C4
5. Split complex diagrams by service group
