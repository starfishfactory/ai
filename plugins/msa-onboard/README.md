# msa-onboard

MSA 환경 자동 분석 및 C4 모델 리포트 생성 Claude Code 플러그인

## 개요

새 회사 입사 시 MSA 인프라를 빠르게 파악하기 위한 플러그인입니다. 프로젝트의 코드베이스와 인프라 설정을 자동 분석하여 **C4 모델 기반 Mermaid 다이어그램** + **Obsidian 호환 마크다운 문서**를 생성합니다.

## 설치

```bash
claude plugin add ./plugins/msa-onboard
```

## 사용법

### 전체 분석 (메인 스킬)

```
/msa-onboard:msa-onboard /path/to/msa-project
```

MSA 프로젝트를 분석하여 C4 모델 기반 리포트를 생성합니다:
1. 서비스 식별 (기술 스택, 빌드 도구, 포트)
2. 인프라 분석 (Docker, K8s, CI/CD)
3. 의존성 매핑 (HTTP, gRPC, MQ, DB)
4. C4 다이어그램 + Obsidian 문서 생성

### 서비스 식별만

```
/msa-onboard:discover-services /path/to/msa-project
```

서비스 목록과 기술 스택만 빠르게 파악합니다.

### C4 다이어그램만

```
/msa-onboard:generate-c4 /path/to/msa-project
```

C4 Mermaid 다이어그램만 생성합니다.

## 출력 구조

```
msa-onboard-report/
├── README.md                    # 목차 + 개요
├── 01-system-context.md         # C4 Level 1
├── 02-container.md              # C4 Level 2
├── 03-components/               # C4 Level 3
│   ├── {service-1}.md
│   └── {service-2}.md
├── 04-service-catalog.md        # 서비스 카탈로그
├── 05-infra-overview.md         # 인프라 구성
└── 06-dependency-map.md         # 의존성 맵
```

## Obsidian 호환

생성된 문서는 Obsidian에서 바로 사용할 수 있습니다:
- 위키 링크(`[[파일명]]`)로 문서 간 이동
- Mermaid 코드블록 네이티브 렌더링 (Obsidian 1.4+)
- YAML 프론트매터 + 태그 지원
- 별도 Obsidian 플러그인 불필요

## 분석 대상

| 카테고리 | 탐지 항목 |
|----------|----------|
| 빌드 파일 | package.json, pom.xml, build.gradle, go.mod, Cargo.toml, pyproject.toml |
| 컨테이너 | Dockerfile, docker-compose.yml |
| K8s | Deployment, Service, Ingress, Helm charts |
| CI/CD | GitHub Actions, GitLab CI, Jenkinsfile |
| 통신 | REST, gRPC, Kafka, RabbitMQ |
| DB | PostgreSQL, MySQL, MongoDB, Redis |

## 플러그인 구조

```
msa-onboard/
├── .claude-plugin/plugin.json       # 매니페스트
├── skills/
│   ├── msa-onboard/                 # 메인 분석 워크플로우
│   │   ├── SKILL.md
│   │   ├── c4-mermaid-reference.md  # C4 + Mermaid 문법 참조
│   │   └── output-templates.md      # 출력 템플릿
│   ├── discover-services/           # 서비스 식별 단독
│   │   └── SKILL.md
│   └── generate-c4/                 # C4 다이어그램 단독
│       └── SKILL.md
├── agents/
│   ├── service-discoverer.md        # 서비스 식별 에이전트
│   ├── infra-analyzer.md            # 인프라 분석 에이전트
│   ├── dependency-mapper.md         # 의존성 매핑 에이전트
│   └── c4-report-generator.md       # C4 문서 생성 에이전트
└── README.md
```

## 라이선스

MIT
