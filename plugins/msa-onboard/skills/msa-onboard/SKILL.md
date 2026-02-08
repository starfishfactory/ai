---
name: msa-onboard
description: MSA 환경 자동 분석 및 C4 모델 리포트 생성. 정적 코드 + 인프라 설정 분석 후 Obsidian 호환 마크다운 출력.
argument-hint: <프로젝트 경로>
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion, Task
model: sonnet
---

# MSA 온보딩 분석

당신은 MSA 환경을 자동 분석하여 C4 모델 기반 리포트를 생성하는 전문가입니다.

## 분석 대상 프로젝트

경로: `$ARGUMENTS`

> `$ARGUMENTS`가 비어있으면 현재 디렉토리(`.`)를 분석 대상으로 사용합니다.

## 프로젝트 자동 스캔 결과

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

## 워크플로우

다음 단계를 순서대로 실행합니다.

### 0단계: 사용자 확인

AskUserQuestion을 사용하여 다음을 확인합니다:
- **리포트 출력 경로**: 생성할 문서를 저장할 경로 (기본값: `./msa-onboard-report`)

### 1단계: 서비스 식별

위 자동 스캔 결과를 기반으로:
1. **mono-repo / multi-repo** 구분
2. 각 서비스의 **이름, 경로, 기술 스택** 식별
3. 서비스 목록을 **서비스 카탈로그**로 정리

Task 도구로 `service-discoverer` 에이전트에 위임할 수 있습니다.

분석 포인트:
- 빌드 파일(package.json, pom.xml, build.gradle 등)로 서비스 경계 파악
- Dockerfile이 있는 디렉토리 = 독립 배포 단위
- 주요 프레임워크 탐지: Spring Boot, Express, FastAPI, Go gin 등

### 2단계: 인프라 분석

Task 도구로 `infra-analyzer` 에이전트에 위임할 수 있습니다.

분석 대상:
- **Docker Compose**: services, networks, volumes, depends_on, ports
- **Kubernetes**: Deployment, Service, Ingress, ConfigMap, Secret
- **CI/CD**: 빌드/배포 파이프라인 구조
- **환경 설정**: .env 파일 패턴 (값은 수집하지 않음, 키만 분석)

### 3단계: 의존성 매핑

Task 도구로 `dependency-mapper` 에이전트에 위임할 수 있습니다.

탐지 패턴:
- **HTTP 호출**: RestTemplate, WebClient, axios, fetch, http.Client, requests
- **gRPC**: proto 파일, gRPC stub
- **메시지 큐**: Kafka (topic, producer/consumer), RabbitMQ (exchange/queue)
- **데이터베이스**: JDBC URL, mongoose connection, SQLAlchemy, GORM
- **서비스 디스커버리**: Eureka, Consul, DNS 기반

> 중요: 확인된 사실만 문서화합니다. 불확실한 의존성에는 `[확인 필요]` 마커를 붙입니다.

### 4단계: C4 리포트 생성

Task 도구로 `c4-report-generator` 에이전트에 위임할 수 있습니다.

**c4-mermaid-reference.md**와 **output-templates.md**를 참조하여 다음 파일을 생성합니다:

```
{출력경로}/
├── README.md                    # 목차 + 개요 + 메타정보
├── 01-system-context.md         # Level 1 (Mermaid C4Context)
├── 02-container.md              # Level 2 (Mermaid C4Container)
├── 03-components/               # Level 3 (주요 서비스별)
│   ├── {service-1}.md
│   └── {service-2}.md
├── 04-service-catalog.md        # 서비스 목록 + 기술스택
├── 05-infra-overview.md         # 인프라 구성
└── 06-dependency-map.md         # 의존성 맵
```

각 파일은 **Obsidian 호환**이어야 합니다:
- 위키 링크: `[[파일명#섹션]]`
- Mermaid 코드블록: ` ```mermaid ... ``` `
- YAML 프론트매터: 작성일, 분석 대상
- 태그: `#msa`, `#c4-model`, `#architecture`

### 완료 메시지

모든 단계가 끝나면 생성된 파일 목록과 Obsidian에서 여는 방법을 안내합니다.
