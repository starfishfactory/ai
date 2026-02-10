---
description: MSA 프로젝트에서 마이크로서비스 식별 (단독 실행)
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
argument-hint: <프로젝트 경로>
---

# 서비스 식별: $ARGUMENTS

## 분석 대상

경로: `$ARGUMENTS`

> `$ARGUMENTS`가 비어있으면 현재 디렉토리(`.`)를 분석합니다.

## 자동 스캔 결과

디렉토리 구조:
!`find ${ARGUMENTS:-.} -maxdepth 2 -type d 2>/dev/null | head -50`

빌드 파일:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "package.json" -o -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" -o -name "go.mod" -o -name "Cargo.toml" -o -name "requirements.txt" -o -name "pyproject.toml" \) 2>/dev/null`

Docker 파일:
!`find ${ARGUMENTS:-.} -maxdepth 3 -name "Dockerfile" 2>/dev/null`

## 분석 프로세스

위 스캔 결과를 기반으로 직접 분석합니다:

1. **프로젝트 구조 파악**: mono-repo / multi-repo 판별
2. **빌드 파일 기반 서비스 식별**: package.json, pom.xml, build.gradle 등
3. **프레임워크 탐지**: Spring Boot, Express, NestJS, FastAPI, gin 등
4. **Dockerfile 기반 확인**: 독립 배포 단위, FROM 이미지, EXPOSE 포트
5. **서비스 역할 추론**: gateway, auth, order 등 역할 분류

## 출력

분석 결과를 서비스 목록 표로 정리합니다:

| 서비스 | 경로 | 언어 | 프레임워크 | 포트 | 역할 | Dockerfile |
|--------|------|------|-----------|------|------|------------|

공통 라이브러리가 있다면 별도로 정리합니다:

| 라이브러리 | 경로 |
|-----------|------|

아키텍처 유형 (mono-repo / multi-repo)도 함께 출력합니다.
