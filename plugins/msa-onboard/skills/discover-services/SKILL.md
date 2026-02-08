---
name: discover-services
description: MSA 프로젝트에서 마이크로서비스를 식별하고 기술 스택을 분석
argument-hint: <프로젝트 경로>
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
model: sonnet
---

# 서비스 식별

MSA 프로젝트에서 마이크로서비스를 식별하고 기술 스택을 분석합니다.

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

## 분석 지침

1. **프로젝트 유형 판별**: mono-repo / multi-repo
2. **서비스 경계 식별**: 빌드 파일이 있는 각 디렉토리를 서비스 후보로
3. **기술 스택 분석**: 빌드 파일 내용을 읽어 프레임워크, 언어, 의존성 파악
4. **Dockerfile 확인**: 독립 배포 단위 확정, 포트 정보 수집
5. **라이브러리 구분**: `*-common`, `*-shared`, `*-lib`는 서비스가 아닌 공통 라이브러리

## 출력

분석 결과를 서비스 목록 표로 정리합니다:

| 서비스 | 경로 | 언어 | 프레임워크 | 포트 | 역할 |
|--------|------|------|-----------|------|------|
| ... | ... | ... | ... | ... | ... |

공통 라이브러리가 있다면 별도로 정리합니다.
