# 에이전트 라이브러리

`~/.claude/agents/`에 심볼릭 링크로 설치하는 Claude Code 서브에이전트 모음이다.
각 에이전트의 상세 동작 방식은 해당 `.md` 파일에 정의되어 있다.

## Core Pack

기본 개발 워크플로우에 필요한 핵심 에이전트 4개이다.

| 에이전트 | 목적 |
|----------|------|
| `code-reviewer` | 코드 가독성/유지보수성 검토. 네이밍, 중복, 에러 처리 등을 점검한다. |
| `test-generator` | TDD 기반 테스트 케이스 생성. Red-Green-Refactor 사이클을 따른다. |
| `debug-expert` | 체계적 디버깅 및 문제 해결. 근본 원인을 분석하고 해결책을 제시한다. |
| `korean-docs` | 한국어 기술 문서 작성. 목차, 가이드, 예시를 포함한 구조화된 문서를 생성한다. |

## Advanced Pack

보안 감사, API 문서화, 프로젝트 관리 등 특수 목적 에이전트 3개이다.

| 에이전트 | 목적 |
|----------|------|
| `dfs` | API 기능명세(DFS) 문서 작성. Controller에서 외부 API까지 전체 플로우를 분석한다. |
| `security-auditor` | OWASP 기반 보안 취약점 분석. 인증, 주입 공격, XSS 등을 검토한다. |
| `github-projects-manager` | GitHub Projects 칸반 보드 관리. 프로젝트 생성, 작업 상태 변경을 자동화한다. |

## 설치

### 자동 설치 (권장)

```bash
./scripts/setup.sh
```

Core Pack만 설치하거나, Advanced Pack을 포함한 전체 설치, 또는 개별 선택이 가능하다.

### 수동 설치

```bash
# Core Pack
ln -sf /path/to/starfishfactory/ai/agents/core/*.md ~/.claude/agents/

# Advanced Pack
ln -sf /path/to/starfishfactory/ai/agents/advanced/*.md ~/.claude/agents/
```

### 설치 확인

```bash
ls -la ~/.claude/agents/
```

## 사용법

### 자동 선택

Claude가 작업 내용을 분석하여 적절한 에이전트를 자동 선택한다.

```
> 이 함수를 검토해줘        → code-reviewer 자동 선택
> 테스트부터 작성해줘       → test-generator 자동 선택
> 이 에러 원인을 분석해줘   → debug-expert 자동 선택
```

### 명시적 호출

특정 에이전트를 직접 지정할 수도 있다.

```
@debug-expert 이 에러를 분석해줘
@security-auditor 배포 전 보안 검토해줘
```

## 커스터마이징

### 에이전트 수정

각 에이전트의 Markdown 파일을 직접 편집하여 동작 방식을 변경할 수 있다.
YAML frontmatter의 `description`에 키워드를 추가하면 자동 선택 확률이 높아진다.

### 새 에이전트 추가

`templates/agent-template.md`를 복사하여 새 에이전트를 만들 수 있다.
작성 방법은 [에이전트 활용 가이드](../docs/agent-guide.md)를 참고하라.

## 디렉터리 구조

```
agents/
├── core/                        # Core Pack (4개)
│   ├── code-reviewer.md
│   ├── test-generator.md
│   ├── debug-expert.md
│   └── korean-docs.md
├── advanced/                    # Advanced Pack (3개)
│   ├── dfs.md
│   ├── security-auditor.md
│   └── github-projects-manager.md
└── templates/
    └── agent-template.md        # 새 에이전트 템플릿
```
