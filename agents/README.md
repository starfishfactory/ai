# 🤖 Claude Code 에이전트 라이브러리

> TDD와 한국어 문서화를 중심으로 한 개인 개발 스타일에 최적화된 서브에이전트 컬렉션

## 📋 목차

1. [개요](#개요)
2. [에이전트 팩 구성](#에이전트-팩-구성)
3. [설치 및 설정](#설치-및-설정)
4. [사용법](#사용법)
5. [에이전트 상세 설명](#에이전트-상세-설명)
6. [활용 예시](#활용-예시)
7. [프로젝트 구조](#프로젝트-구조)
8. [커스터마이징](#커스터마이징)

---

## 개요

이 저장소는 개인 프로젝트 개발에 최적화된 Claude Code 서브에이전트들을 모아놓은 라이브러리입니다. **간소화된 2단계 팩**으로 구성되어 명확하고 사용하기 쉽습니다.

### 🎯 핵심 특징
- **🧪 TDD 중심**: 테스트 우선 개발 방식
- **🇰🇷 한국어 친화**: 상세하고 체계적인 한국어 설명
- **📝 단계별 검증**: 각 단계마다 철저한 검증
- **✨ 명확한 역할**: 각 에이전트의 책임이 명확하게 분리

### 📚 공식 문서 준수
- Claude Code [공식 문서](https://docs.claude.com/en/docs/claude-code/sub-agents) 기준 구현
- Markdown + YAML frontmatter 형식 사용
- 단일 책임 원칙 (Single Responsibility) 준수

---

## 🎯 에이전트 팩 구성

### 🚀 Core Pack (4개) - 모든 사용자 추천
**"기본적인 개발 워크플로우에 필요한 핵심 agents"**

| 에이전트 | 목적 | 자동 선택 트리거 |
|----------|------|------------------|
| `code-reviewer` | 코드 가독성과 유지보수성 검토 | "코드 검토" |
| `test-generator` | TDD 테스트 케이스 생성 | "테스트 작성" |
| `debug-expert` | 디버깅 및 문제 해결 | "에러 분석" |
| `korean-docs` | 한국어 기술 문서 작성 | "문서 작성" |

**추천 대상**: 모든 개발자

### ⚡ Advanced Pack (2개) - 특수 목적
**"보안 및 프로젝트 관리가 필요할 때"**

| 에이전트 | 목적 | 사용 시점 |
|----------|------|-----------|
| `security-auditor` | OWASP 기반 보안 검토 | 프로덕션 배포 전 |
| `github-projects-manager` | GitHub Projects 칸반 보드 관리 | 프로젝트 관리 시 |

**추천 대상**: 보안이 중요하거나 GitHub Projects를 활용하는 개발자

---

## 🛠️ 설치 및 설정

### 1. 자동 설정 (추천)
```bash
# 자동 설정 스크립트 실행
~/IdeaProjects/molidae/ai/scripts/setup.sh
```

스크립트에서 제공하는 옵션:
- **🚀 Core Pack**: 모든 사용자 추천 (4개)
- **⚡ Advanced Pack**: Core + 특수 목적 (6개)
- **🛠️ Custom**: 개별 선택

### 2. 수동 설정
```bash
# Core Pack (4개)
ln -sf ~/IdeaProjects/molidae/ai/agents/core/*.md ~/.claude/agents/

# Advanced Pack (Core + 2개 추가)
ln -sf ~/IdeaProjects/molidae/ai/agents/core/*.md ~/.claude/agents/
ln -sf ~/IdeaProjects/molidae/ai/agents/advanced/*.md ~/.claude/agents/
```

### 3. 설정 확인
```bash
# 설치된 에이전트 확인
ls -la ~/.claude/agents/

# Claude Code에서 확인
/agents
```

---

## 🎮 사용법

### 자동 에이전트 선택 (추천)
Claude가 작업 내용을 분석하여 적절한 에이전트를 자동으로 선택합니다.

```text
# 예시 1: 코드 리뷰 요청
> 이 함수를 검토해주세요
→ code-reviewer 에이전트가 자동 선택

# 예시 2: TDD 개발
> 새로운 기능을 테스트부터 작성해주세요
→ test-generator 에이전트가 자동 선택

# 예시 3: 문서 작성
> 이 API에 대한 사용 가이드를 한국어로 작성해주세요
→ korean-docs 에이전트가 자동 선택
```

### 명시적 에이전트 호출
특정 에이전트를 직접 지정할 수도 있습니다.

```text
# 특정 에이전트 지정
> debug-expert 에이전트로 이 에러를 분석해주세요
> security-auditor 에이전트로 보안 검토를 해주세요
```

---

## 📖 에이전트 상세 설명

### 🚀 Core Pack

#### 🔍 code-reviewer
- **목적**: 코드 가독성과 유지보수성 검토
- **특징**: 베스트 프랙티스, 네이밍, 중복 코드 검토 (보안/성능은 제외)
- **출력**: 우선순위별 (Critical/Important/Nice to have) 개선 사항

#### 🧪 test-generator
- **목적**: TDD 기반 테스트 케이스 생성
- **특징**: Red-Green-Refactor 사이클, 한국어 주석
- **출력**: 정상/엣지/경계값/에러 케이스 테스트

#### 🐛 debug-expert
- **목적**: 체계적인 디버깅 및 문제 해결
- **특징**: 6단계 디버깅 프로세스 (재현-정보수집-가설-검증-해결-예방)
- **출력**: 근본 원인 분석과 해결 방법

#### 📚 korean-docs
- **목적**: 체계적인 한국어 기술 문서 작성
- **특징**: 목차, 가이드, 예시, 베스트 프랙티스 포함
- **출력**: 구조화된 마크다운 문서

### ⚡ Advanced Pack

#### 🔒 security-auditor
- **목적**: OWASP 기반 보안 취약점 분석
- **특징**: 인증/권한, 주입 공격, XSS, 데이터 보호, 보안 헤더 검토
- **출력**: 보안 취약점 리포트와 테스트 케이스

#### 📋 github-projects-manager
- **목적**: GitHub Projects 칸반 보드 자동 관리
- **특징**: 프로젝트 생성, 작업 추가, 상태 변경 (Todo/In Progress/Done)
- **필수 조건**: GitHub CLI (`gh`), Personal Access Token
- **출력**: 프로젝트 URL, 작업 추적 현황

**사용 예시**:
```text
> "AI 챗봇 개발" 프로젝트를 생성해줘
> Issue #42를 프로젝트에 추가하고 "In Progress"로 변경해줘
> Issue #42를 "Done"으로 변경해줘
```

---

## 🎯 활용 예시

### Core Pack 활용 시나리오
```text
1. "이 로그인 함수를 검토해주세요"
   → code-reviewer가 가독성과 유지보수성 검토

2. "사용자 등록 기능의 테스트를 작성해주세요"
   → test-generator가 TDD 테스트 케이스 생성

3. "프로젝트 README를 작성해주세요"
   → korean-docs가 체계적인 한국어 문서 생성

4. "이 에러가 왜 발생하는지 분석해주세요"
   → debug-expert가 근본 원인 분석 및 해결책 제시
```

### Advanced Pack 활용 시나리오
```text
1. "배포 전 보안 검토를 해주세요"
   → security-auditor가 OWASP 기반 종합 보안 감사

2. "새 프로젝트를 칸반 보드로 관리하고 싶어요"
   → github-projects-manager가 프로젝트 생성 및 관리
```

---

## 📁 프로젝트 구조

```
~/IdeaProjects/molidae/ai/
├── agents/                          # Claude Code 에이전트
│   ├── README.md                    # 에이전트 가이드
│   ├── core/                        # 4개 핵심 에이전트
│   │   ├── code-reviewer.md
│   │   ├── test-generator.md
│   │   ├── debug-expert.md
│   │   └── korean-docs.md
│   ├── advanced/                    # 2개 특수 목적 에이전트
│   │   ├── security-auditor.md
│   │   └── github-projects-manager.md
│   └── templates/
│       └── agent-template.md        # 새 에이전트 템플릿
├── hooks/                           # Slack 알림 훅
│   ├── README.md
│   └── install.sh
├── scripts/                         # 자동화 스크립트
│   ├── setup.sh                     # 자동 설정 스크립트
│   ├── github-projects-helper.sh    # GitHub Projects API 헬퍼
│   └── TEST_RESULTS.md              # 테스트 결과
├── docs/                            # 사용 가이드
│   ├── agent-guide.md               # 상세 활용 가이드
│   ├── setup-guide.md               # 설정 가이드
│   └── github-projects-manager-guide.md  # GitHub Projects 가이드
└── README.md                        # 프로젝트 개요
```

---

## 🛠️ 커스터마이징

### 에이전트 수정
각 에이전트의 Markdown 파일을 편집하여 개인 스타일에 맞게 커스터마이징할 수 있습니다.

```markdown
---
name: custom-agent
description: 개인화된 설명 추가. PROACTIVELY 키워드로 자동 선택 확률 증가
tools: Read, Write, Edit
model: sonnet
---

에이전트의 상세한 동작 방식을 여기에 작성합니다.
```

### 새로운 에이전트 추가
`templates/agent-template.md`를 참고하여 새로운 에이전트를 만들 수 있습니다.

---

## 🔄 변경 이력

### v2.0.0 (2025-10-14)
- ♻️ 구조 간소화: 8개 → 6개 agents
- ♻️ 팩 재구성: 3단계 → 2단계 (Core/Advanced)
- 🔧 형식 수정: JSON → Markdown + YAML frontmatter (공식 표준)
- ❌ 제거: api-architect, performance-optimizer (역할 중복)
- ✨ 개선: 각 agent 역할 명확화

---

## 🤝 기여 가이드

1. 새로운 에이전트 아이디어 제안
2. 기존 에이전트 개선 사항 피드백
3. 사용 경험 공유

---

## 📞 지원

- **이슈 리포팅**: GitHub Issues 활용
- **개선 제안**: Pull Request 환영
- **사용법 문의**: Discussions 섹션 활용
- **공식 문서**: [Claude Code Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)

---

## 🎉 시작해보세요!

```bash
# 1. 자동 설정 스크립트 실행
~/IdeaProjects/molidae/ai/scripts/setup.sh

# 2. Core Pack부터 시작 (추천)

# 3. Claude Code에서 확인
/agents

# 4. 첫 에이전트 사용
# "이 코드를 검토해주세요"
```

**간단하고 명확하게 시작하세요!** 🚀

---

*이 라이브러리는 Claude Code 공식 표준을 준수하며 개인 개발 스타일에 맞춰 지속적으로 업데이트됩니다.*
