---
description: 분석 결과를 기반으로 C4 모델 Mermaid 다이어그램 생성 (단독 실행)
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
argument-hint: <프로젝트 경로>
---

# C4 다이어그램 생성: $ARGUMENTS

## 분석 대상

경로: `$ARGUMENTS`

> `$ARGUMENTS`가 비어있으면 현재 디렉토리(`.`)를 분석합니다.

## 자동 스캔 결과

디렉토리 구조:
!`find ${ARGUMENTS:-.} -maxdepth 2 -type d 2>/dev/null | head -50`

빌드 파일:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "package.json" -o -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" -o -name "go.mod" \) 2>/dev/null`

Docker:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "Dockerfile" -o -name "docker-compose*.yml" -o -name "docker-compose*.yaml" \) 2>/dev/null`

## 실행

### 1. 사용자 확인

AskUserQuestion으로 출력 경로를 확인합니다 (기본값: `./msa-onboard-report`).

### 2. 빠른 분석

프로젝트 구조와 빌드 파일을 읽어 서비스 목록과 의존성을 파악합니다. 직접 분석을 수행합니다:
- 서비스 식별 (빌드 파일 + Dockerfile)
- 인프라 분석 (docker-compose, k8s)
- 의존성 매핑 (HTTP, gRPC, MQ, DB)

### 3. C4 다이어그램 생성

`c4-mermaid-reference.md`와 `output-templates.md`를 참조하여 다음 3개 레벨의 Mermaid 다이어그램을 포함한 파일을 생성합니다:
- `01-system-context.md` (Level 1: C4Context)
- `02-container.md` (Level 2: C4Container)
- `03-components/{service}.md` (Level 3: C4Component, 주요 서비스별)

추가로 다음 파일도 생성합니다:
- `README.md` (목차 + 개요)
- `04-service-catalog.md` (서비스 목록)
- `05-infra-overview.md` (인프라 구성)
- `06-dependency-map.md` (의존성 맵 + graph LR 다이어그램)

## Mermaid C4 문법 규칙

- alias는 영문 소문자 + 숫자만 (하이픈, 공백 불가)
- `Person(alias, "이름", "설명")`
- `System(alias, "이름", "설명")` / `System_Ext(alias, "이름", "설명")`
- `Container(alias, "이름", "기술", "설명")`
- `ContainerDb(alias, "이름", "기술", "설명")`
- `ContainerQueue(alias, "이름", "기술", "설명")`
- `Component(alias, "이름", "기술", "설명")`
- `Container_Boundary(alias, "이름")`
- `Rel(from, to, "라벨")`

## Obsidian 호환

- YAML 프론트매터 포함 (`created`, `tags` 필수)
- 위키 링크로 다른 문서 참조: `[[02-container|Container Diagram]]`
- 태그: `#c4-model`, `#msa`, `#architecture`
