---
description: MSA 환경 Agent Teams 병렬 분석 + 교차 검증 + C4 리포트 생성
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
argument-hint: <프로젝트 경로>
---

# MSA 온보딩 분석 (Agent Teams): $ARGUMENTS

> ⚠️ **Agent Teams는 실험적 기능입니다**
> - 활성화: settings.json 또는 .claude/settings.json에 `{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }` 추가
> - 공식 문서: https://code.claude.com/docs/en/agent-teams
> - 비용: ~7x tokens (plan mode 기준). Opus teammates 사용 시 더 증가
> - tmux 설치 필요: `brew install tmux` (macOS) / `sudo apt install tmux` (Linux)
> - iTerm2 사용 시: Settings → General → Magic → Enable Python API
> - **미지원 터미널**: VS Code 통합 터미널, Windows Terminal, Ghostty (split pane 모드)

## 분석 대상

경로: `$ARGUMENTS`

> `$ARGUMENTS`가 비어있으면 현재 디렉토리(`.`)를 분석 대상으로 사용합니다.

---

## Phase 0: 프로젝트 스캔 + 사용자 확인

### 자동 스캔

디렉토리 구조:
!`find ${ARGUMENTS:-.} -maxdepth 2 -type d 2>/dev/null | head -50`

빌드 파일:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "package.json" -o -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" -o -name "go.mod" -o -name "Cargo.toml" -o -name "requirements.txt" -o -name "pyproject.toml" \) 2>/dev/null`

Docker 설정:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "Dockerfile" -o -name "docker-compose*.yml" -o -name "docker-compose*.yaml" \) 2>/dev/null`

Kubernetes 설정:
!`find ${ARGUMENTS:-.} -maxdepth 4 \( -name "*.yaml" -o -name "*.yml" \) \( -path "*/k8s/*" -o -path "*/kubernetes/*" -o -path "*/helm/*" -o -path "*/deploy/*" \) 2>/dev/null | head -30`

CI/CD 설정:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "Jenkinsfile" -o -name ".gitlab-ci.yml" -o -path "*/.github/workflows/*" -o -name "Makefile" \) 2>/dev/null`

### 사용자 확인

AskUserQuestion을 사용하여 다음을 확인합니다:
- **리포트 출력 경로**: 생성할 문서를 저장할 경로 (기본값: `./msa-onboard-report`)

---

## Phase 1: 병렬 분석 (Agent Teams — 3명 teammate spawn)

**중요 지침:**
- **절대 직접 분석하지 마세요.** 반드시 3명의 teammate를 spawn하여 병렬로 분석합니다.
- 모든 teammate가 완료될 때까지 대기하세요.
- teammate의 작업 완료 상태가 표시되지 않을 수 있습니다. 상태가 업데이트되지 않으면 수동으로 확인 후 진행하세요.
- teammate가 완료되면 팀을 정리하여 유휴 토큰 소비를 방지하세요.

### Teammate 1: 서비스 식별자 (service-discoverer)

다음 지침으로 teammate를 spawn하세요:

```
당신은 MSA 프로젝트에서 마이크로서비스를 식별하는 전문가입니다.
분석 대상 프로젝트 경로: ${ARGUMENTS:-.}

## 분석 프로세스

1. **프로젝트 구조 파악**: 최상위 디렉토리 구조로 mono-repo / multi-repo 판별. 각 하위 디렉토리의 독립성 확인.

2. **빌드 파일 기반 서비스 식별**: 각 빌드 파일이 있는 디렉토리를 잠재적 서비스로 판별:
   - package.json → Node.js (Express, NestJS, Next.js 등)
   - pom.xml → Java (Spring Boot, Quarkus 등)
   - build.gradle / build.gradle.kts → Java/Kotlin (Spring Boot 등)
   - go.mod → Go (gin, echo, fiber 등)
   - Cargo.toml → Rust
   - requirements.txt / pyproject.toml → Python (FastAPI, Django, Flask 등)

3. **프레임워크 탐지**: 서비스별 사용 프레임워크를 정확히 판별:
   - Java/Kotlin: spring-boot-starter-web, quarkus, micronaut
   - Node.js: express, @nestjs/core, fastify, koa
   - Python: fastapi, django, flask
   - Go: gin-gonic, echo, fiber

4. **Dockerfile 기반 확인**: Dockerfile이 있는 디렉토리는 독립 배포 단위로 확정. FROM 이미지에서 런타임 확인, EXPOSE 포트 정보 수집, 멀티스테이지 빌드 패턴 확인.

5. **서비스 역할 추론**: 디렉토리명, 패키지명, README 등에서 서비스 역할을 추론:
   - *-gateway, *-api: API 게이트웨이
   - *-auth, *-user: 인증/사용자 관리
   - *-order, *-payment: 비즈니스 도메인
   - *-common, *-shared, *-lib: 공통 라이브러리 (서비스 아님)

## 출력

결과를 {출력경로}/_service-discovery.json 파일에 JSON 형식으로 저장하세요:

{
  "type": "mono-repo | multi-repo",
  "services": [
    {
      "name": "서비스 이름",
      "path": "상대 경로",
      "language": "Java | TypeScript | Python | Go",
      "framework": "Spring Boot | Express | FastAPI",
      "buildTool": "Gradle | Maven | npm | pip",
      "port": 8080,
      "role": "API Gateway | Business Service | ...",
      "hasDockerfile": true
    }
  ],
  "libraries": [
    {
      "name": "공통 라이브러리 이름",
      "path": "상대 경로"
    }
  ]
}

작업이 완료되면 저장한 파일 경로를 보고하세요.
```

### Teammate 2: 인프라 분석자 (infra-analyzer)

다음 지침으로 teammate를 spawn하세요:

```
당신은 MSA 프로젝트의 인프라 설정을 분석하는 전문가입니다.
분석 대상 프로젝트 경로: ${ARGUMENTS:-.}

## 분석 프로세스

1. **Docker Compose 분석** (docker-compose*.yml / docker-compose*.yaml):
   - services: 각 서비스 이름, 이미지, 빌드 컨텍스트
   - ports: 포트 매핑 (호스트:컨테이너)
   - networks: 네트워크 구성, 서비스 그룹핑
   - volumes: 볼륨 마운트, 데이터 영속성
   - depends_on: 서비스 시작 순서, 의존성
   - environment: 환경변수 키 (값은 수집하지 않음)
   - healthcheck: 헬스체크 설정

2. **Kubernetes 분석** (YAML manifests):
   - Deployment: replicas, image, resources, env
   - Service: type (ClusterIP/NodePort/LoadBalancer), ports
   - Ingress: host, path, TLS
   - ConfigMap: 키 목록 (값 제외)
   - Secret: 키 목록 (값 제외)
   - HPA: minReplicas, maxReplicas, 메트릭
   - PVC: 스토리지 크기, accessMode
   - Helm 차트: Chart.yaml (이름, 버전, dependencies), values.yaml (주요 설정 키)

3. **CI/CD 파이프라인 분석**:
   - GitHub Actions: .github/workflows/*.yml
   - GitLab CI: .gitlab-ci.yml
   - Jenkins: Jenkinsfile
   - 분석 포인트: 빌드 단계, 배포 전략, 환경 분리, 시크릿 관리 방식

4. **환경 설정 분석**:
   - .env.example / .env.sample 파일의 키 목록
   - application.yml / application.properties의 프로파일 구조
   - 환경별 설정 분리 패턴

> 중요: 실제 시크릿 값은 절대 수집하지 않습니다. 키 이름과 구조만 분석합니다.

## 출력

결과를 {출력경로}/_infra-analysis.json 파일에 JSON 형식으로 저장하세요:

{
  "containerOrchestration": {
    "type": "Docker Compose | Kubernetes | ECS",
    "services": ["서비스 목록"],
    "networks": ["네트워크 목록"]
  },
  "cicd": {
    "tool": "GitHub Actions | GitLab CI | Jenkins",
    "stages": ["build", "test", "deploy"],
    "environments": ["dev", "staging", "prod"]
  },
  "networking": {
    "ingressRoutes": [
      { "host": "example.com", "path": "/api", "service": "api-gateway" }
    ]
  },
  "storage": {
    "databases": [
      { "name": "db-name", "type": "PostgreSQL", "connectedServices": ["svc1"] }
    ],
    "volumes": ["volume 목록"]
  }
}

작업이 완료되면 저장한 파일 경로를 보고하세요.
```

### Teammate 3: 의존성 매퍼 (dependency-mapper)

다음 지침으로 teammate를 spawn하세요:

```
당신은 MSA 프로젝트의 서비스 간 의존성을 정적 분석으로 매핑하는 전문가입니다.
분석 대상 프로젝트 경로: ${ARGUMENTS:-.}

## 분석 프로세스

1. **HTTP 호출 탐지**: 각 서비스 코드에서 다른 서비스로의 HTTP 호출 탐지
   - Java/Spring: RestTemplate, WebClient, FeignClient
   - Node.js: axios, fetch, got, node-fetch
   - Python: requests, httpx, aiohttp
   - Go: http.Client, http.Get, http.Post
   - URL 패턴: http://, https://, 서비스명 포함 URL
   - 서비스 디스커버리: Eureka client, Consul agent, K8s Service DNS
   - 환경변수 기반: SERVICE_URL, API_HOST 등

2. **gRPC 통신 탐지**:
   - .proto 파일 위치 및 service 정의
   - gRPC stub 생성 코드
   - gRPC 클라이언트 설정

3. **메시지 큐 통신 탐지**:
   - Kafka: KafkaTemplate/KafkaProducer(producer), @KafkaListener/KafkaConsumer(consumer), Topic 이름
   - RabbitMQ: @RabbitListener, amqplib, pika, Exchange/Queue/Routing Key
   - Redis Pub/Sub: RedisMessageListenerContainer, ioredis

4. **데이터베이스 연결 매핑**:
   - JDBC URL (jdbc:postgresql://, jdbc:mysql://) → PostgreSQL, MySQL
   - mongoose.connect, MongoClient → MongoDB
   - redis://, RedisTemplate, ioredis → Redis
   - SQLAlchemy, SQLALCHEMY_DATABASE_URI → Python ORM
   - gorm.Open, sql.Open → Go
   - DB명 → 서비스 매핑으로 같은 DB를 공유하는 서비스도 탐지

5. **외부 시스템 연동**:
   - AWS SDK 호출 (S3, SQS, SNS, DynamoDB)
   - 외부 API 호출 (결제, 이메일, SMS 등)
   - OAuth/OIDC 연동 (Keycloak, Auth0 등)

## 신뢰도 표기

각 의존성에 대해 신뢰도를 표기합니다:
- **확인됨**: 코드에서 직접 확인된 의존성
- **[확인 필요]**: 설정 파일에만 있거나, 추론에 의한 의존성

> 중요: 추측하지 않습니다. 코드에서 확인되지 않은 의존성은 반드시 [확인 필요]로 표기합니다.

## 출력

결과를 {출력경로}/_dependency-map.json 파일에 JSON 형식으로 저장하세요:

{
  "serviceDependencies": [
    {
      "from": "service-a",
      "to": "service-b",
      "protocol": "REST | gRPC | Kafka | RabbitMQ",
      "detail": "GET /api/users | topic: user-events",
      "confidence": "확인됨 | [확인 필요]"
    }
  ],
  "databaseConnections": [
    {
      "service": "service-a",
      "database": "db-name",
      "type": "PostgreSQL | MongoDB | Redis",
      "accessPattern": "JDBC | Mongoose | ioredis"
    }
  ],
  "externalSystems": [
    {
      "service": "service-a",
      "external": "AWS S3",
      "protocol": "SDK",
      "purpose": "파일 저장"
    }
  ],
  "messageQueues": [
    {
      "producer": "service-a",
      "consumer": "service-b",
      "broker": "Kafka",
      "topic": "user-events"
    }
  ]
}

작업이 완료되면 저장한 파일 경로를 보고하세요.
```

### Teammate 완료 대기

- 3명의 teammate가 모두 완료될 때까지 **절대 다음 Phase로 진행하지 마세요**.
- 상태 표시가 업데이트되지 않으면 각 teammate의 JSON 출력 파일 존재 여부를 수동 확인하세요:
  - `{출력경로}/_service-discovery.json`
  - `{출력경로}/_infra-analysis.json`
  - `{출력경로}/_dependency-map.json`
- 모든 파일이 존재하면 Phase 2로 진행합니다.

---

## Phase 2: 교차 검증 (Lead 직접 수행)

`verification-standards.md`의 "교차 검증 — 5단계"를 참조하여 직접 수행합니다.

### 수행 절차

1. 3개 JSON 파일을 읽어 메모리에 로드
2. **1단계 — 서비스 일관성**: service-discoverer ↔ dependency-mapper 서비스 목록 대조
3. **2단계 — 인프라-의존성 정합**: infra-analyzer ↔ dependency-mapper DB/포트/네트워크 대조
4. **3단계 — 완전성 검사**: Dockerfile/docker-compose 기준으로 누락 서비스/통신 탐지 (Grep/Glob 사용)
5. **4단계 — Devil's Advocate**: `[확인 필요]` 항목을 소스 코드에서 직접 확인 (Read/Grep 사용)
6. **5단계 — 신뢰도 점수 산출**: 100점 기준 감점 방식

### 판정 기준

| 점수 | 판정 | 처리 |
|------|------|------|
| 80-100 | PASS | 리포트 상단에 `✅ 신뢰도: N%` 표시. Phase 3 진행 |
| 60-79 | WARN | `⚠️ [주의]` 마커 + 부록에 이슈 목록 + "수동 확인 권장". Phase 3 진행 |
| 0-59 | FAIL | 리포트 생성 중단. AskUserQuestion으로 사용자에게 선택지 제공: (1) 계속 진행 (2) 재분석 (3) 취소 |

### 출력

교차 검증 결과를 `{출력경로}/_cross-validation.json`에 저장합니다.

---

## Phase 3: C4 리포트 생성 (Lead 직접 수행)

`output-templates.md`와 `c4-mermaid-reference.md`를 참조하여 직접 생성합니다.

### 생성할 파일

```
{출력경로}/
├── README.md                    # 목차 + 개요 + 검증 결과 요약
├── 01-system-context.md         # Level 1 C4Context 다이어그램
├── 02-container.md              # Level 2 C4Container 다이어그램
├── 03-components/               # Level 3 C4Component (주요 서비스별)
│   ├── {service-1}.md
│   └── {service-2}.md
├── 04-service-catalog.md        # 서비스 목록 + 기술 스택
├── 05-infra-overview.md         # 인프라 구성
└── 06-dependency-map.md         # 의존성 맵 + graph LR 다이어그램
```

### 규칙

- 모든 파일에 YAML 프론트매터 포함 (`created`, `tags` 필수)
- Mermaid alias는 영문 소문자 + 숫자만 (하이픈, 공백, 언더스코어 불가)
- Obsidian 위키 링크로 문서 간 참조: `[[파일명|표시명]]`
- 교차 검증에서 발견된 수정사항을 반영
- 교차 검증 점수가 WARN인 경우 README.md에 `⚠️ [주의]` 마커와 이슈 목록 포함

---

## Phase 4: 리포트 검증 (Lead 직접 수행)

`verification-standards.md`의 "리포트 검증 — 4단계"를 참조하여 직접 수행합니다.

### 수행 절차

1. **1단계 — Mermaid 문법 유효성**: alias 규칙, 구조 검증, 요소별 문법 확인
2. **2단계 — Obsidian 링크 유효성**: 위키 링크, 프론트매터 검증
3. **3단계 — C4 모델 완전성**: Level 1/2/3 필수 요소 확인
4. **4단계 — 분석결과-리포트 일치성**: 분석 JSON과 리포트 내용 대조

### 판정 기준

| 점수 | 처리 |
|------|------|
| 80-100 | Phase 5로 진행 (최종 출력) |
| 60-79 | Mermaid alias/링크 등 자동 수정 가능 항목 수정 → 재검증 1회. 재검증 후에도 미달 시 오류 목록과 함께 출력 |
| 0-59 | `❌ 품질 검증 미달` 경고 + 오류 목록 + 수동 수정 가이드와 함께 출력 |

### 출력

리포트 검증 결과를 `{출력경로}/_report-audit.json`에 저장합니다.

---

## Phase 5: 최종 출력

사용자에게 다음을 출력합니다:

1. **생성된 파일 목록** (경로 포함)
2. **신뢰도 점수** (교차 검증): 점수/100
   - 80-100: ✅ PASS
   - 60-79: ⚠️ WARN — 수동 확인 권장 항목 요약
   - 0-59: ❌ FAIL — 주요 이슈 목록
3. **품질 점수** (리포트 검증): 점수/100
   - 80-100: ✅ PASS
   - 60-79: ⚠️ WARN — 자동 수정/미수정 항목 요약
   - 0-59: ❌ FAIL — 오류 목록 + 수동 수정 가이드
4. **주요 이슈 요약** (있는 경우)
5. **Obsidian에서 여는 방법**:
   ```
   Obsidian 볼트로 {출력경로}를 열면 C4 Mermaid 다이어그램과 문서 간 링크가 렌더링됩니다.
   ```
