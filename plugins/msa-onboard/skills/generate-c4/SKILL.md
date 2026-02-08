---
name: generate-c4
description: 분석 결과를 기반으로 C4 모델 Mermaid 다이어그램 생성
argument-hint: <프로젝트 경로>
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
model: sonnet
---

# C4 다이어그램 생성

프로젝트를 분석하여 C4 모델 Mermaid 다이어그램을 생성합니다.

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

## 워크플로우

### 1. 사용자 확인

AskUserQuestion으로 출력 경로를 확인합니다 (기본값: `./msa-onboard-report`).

### 2. 빠른 분석

프로젝트 구조와 빌드 파일을 읽어 서비스 목록과 의존성을 파악합니다.

### 3. C4 다이어그램 생성

다음 3개 레벨의 Mermaid 다이어그램을 생성합니다:

#### Level 1: System Context

```mermaid
C4Context
    title System Context - {시스템 이름}
    ...
```

#### Level 2: Container

```mermaid
C4Container
    title Container Diagram - {시스템 이름}
    ...
```

#### Level 3: Component (주요 서비스 상위 3개)

```mermaid
C4Component
    title Component Diagram - {서비스 이름}
    ...
```

### 4. 파일 생성

출력 경로에 다음 파일을 생성합니다:
- `01-system-context.md` (Level 1)
- `02-container.md` (Level 2)
- `03-components/{service}.md` (Level 3, 주요 서비스별)

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

- YAML 프론트매터 포함
- 위키 링크로 다른 문서 참조: `[[02-container]]`
- 태그: `#c4-model`, `#msa`, `#architecture`
