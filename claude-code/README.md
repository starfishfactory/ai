# 🤖 Claude Code 에이전트 라이브러리

> TDD와 한국어 문서화를 중심으로 한 개인 개발 스타일에 최적화된 서브에이전트 컬렉션

## 📋 목차

1. [개요](#개요)
2. [에이전트 팩 구성](#에이전트-팩-구성)
3. [설치 및 설정](#설치-및-설정)
4. [사용법](#사용법)
5. [에이전트 상세 설명](#에이전트-상세-설명)
6. [활용 예시](#활용-예시)
7. [팩 선택 가이드](#팩-선택-가이드)

---

## 개요

이 저장소는 개인 프로젝트 개발에 최적화된 Claude Code 서브에이전트들을 모아놓은 라이브러리입니다. **단계별로 도입할 수 있는 3가지 팩**으로 구성되어 처음 사용자도 부담 없이 시작할 수 있습니다.

### 🎯 핵심 특징
- **🧪 TDD 중심**: 테스트 우선 개발 방식
- **🇰🇷 한국어 친화**: 상세하고 체계적인 한국어 설명
- **📝 단계별 검증**: 각 단계마다 철저한 검증
- **🎯 점진적 확장**: 필요에 따라 단계별로 추가

---

## 🎯 에이전트 팩 구성

### 🚀 Starter Pack (2개) - 첫 경험용
**"Claude Code 에이전트를 처음 사용해보고 싶어요"**

| 에이전트 | 목적 | 자동 선택 트리거 |
|----------|------|------------------|
| `code-reviewer` | 코드 품질/보안/성능 검토 | "코드를 검토해주세요" |
| `test-generator` | TDD 기반 테스트 케이스 생성 | "테스트를 작성해주세요" |

**추천 대상**: Claude Code 에이전트를 처음 사용하는 모든 개발자

### 🎨 Essential Pack (4개) - 일반 사용자 추천
**"개인 개발 스타일에 맞춰서 사용하고 싶어요"**

| 에이전트 | 목적 | 개인화 요소 |
|----------|------|-------------|
| **Starter Pack** | **위 2개 포함** | |
| `korean-docs` | 한국어 기술 문서 작성 | 체계적 마크다운 구조 |
| `debug-expert` | 체계적인 문제 해결 | 단계별 디버깅 가이드 |

**추천 대상**: 한국어 문서화와 체계적인 개발 프로세스를 중요시하는 개발자

### ⚡ Professional Pack (7개) - 전문가용
**"모든 기능을 사용해서 전문적으로 개발하고 싶어요"**

| 에이전트 | 목적 | 전문 분야 |
|----------|------|-----------|
| **Essential Pack** | **위 4개 포함** | |
| `api-architect` | REST API 설계 및 구현 | OpenAPI, 데이터 모델링 |
| `performance-optimizer` | 성능 분석 및 최적화 | 병목 분석, 캐싱 전략 |
| `security-auditor` | 보안 취약점 분석 | OWASP, 인증/권한 관리 |

**추천 대상**: 전문적인 웹 개발, API 개발, 성능/보안이 중요한 프로젝트

---

## 🛠️ 설치 및 설정

### 1. 자동 설정 (추천)
```bash
# 자동 설정 스크립트 실행
~/molidae/ai/claude-code/scripts/setup.sh
```

스크립트에서 제공하는 옵션:
- **🚀 Starter Pack**: 처음 사용자 (2개)
- **🎨 Essential Pack**: 일반 사용자 (4개)
- **⚡ Professional Pack**: 전문가 (7개)
- **🛠️ Custom**: 개별 선택

### 2. 수동 설정
```bash
# Starter Pack (2개)
ln -sf ~/molidae/ai/claude-code/agents/starter/* ~/.claude/agents/

# Essential Pack (Starter + 2개 추가)
ln -sf ~/molidae/ai/claude-code/agents/starter/* ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/essential/* ~/.claude/agents/

# Professional Pack (Essential + 3개 추가)
ln -sf ~/molidae/ai/claude-code/agents/starter/* ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/essential/* ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/professional/* ~/.claude/agents/
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
> 이 함수의 성능을 개선해주세요
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
> korean-docs 에이전트로 README를 작성해주세요
```

---

## 📖 에이전트 상세 설명

### 🚀 Starter Pack

#### 🔍 code-reviewer
- **목적**: 포괄적인 코드 검토 및 품질 개선
- **특징**: 품질, 보안, 성능을 종합적으로 검토
- **자동 선택**: "코드를 검토해주세요", "성능을 개선해주세요"
- **출력**: 우선순위별 개선 사항과 구체적인 수정 방법

#### 🧪 test-generator
- **목적**: TDD 기반 테스트 케이스 생성
- **특징**: Red-Green-Refactor 사이클 지원
- **자동 선택**: "테스트를 작성해주세요", "TDD로 개발"
- **출력**: 포괄적인 테스트 케이스와 한국어 주석

### 🎨 Essential Pack 추가

#### 📚 korean-docs
- **목적**: 체계적인 한국어 기술 문서 작성
- **특징**: 목차, 예시, 베스트 프랙티스 포함
- **자동 선택**: "문서를 작성해주세요", "가이드를 만들어주세요"
- **출력**: 구조화된 마크다운 문서

#### 🐛 debug-expert
- **목적**: 체계적인 디버깅 및 문제 해결
- **특징**: 근본 원인 분석과 단계별 해결 방법
- **자동 선택**: "에러가 발생했어요", "디버깅을 도와주세요"
- **출력**: 문제 분석과 해결 방법, 예방책

### ⚡ Professional Pack 추가

#### 🏗️ api-architect
- **목적**: REST API 설계 및 구현
- **특징**: OpenAPI 스펙 작성, 데이터 모델 정의
- **자동 선택**: "API를 설계해주세요", "엔드포인트"
- **출력**: 완전한 API 설계 및 구현 가이드

#### ⚡ performance-optimizer
- **목적**: 성능 분석 및 최적화
- **특징**: 병목 분석, 캐싱 전략, 데이터베이스 최적화
- **자동 선택**: "성능을 개선해주세요", "느려요"
- **출력**: 성능 병목 분석과 최적화 방안

#### 🔒 security-auditor
- **목적**: 보안 취약점 분석 및 강화
- **특징**: OWASP Top 10 기반 검사, 인증/권한 관리
- **자동 선택**: "보안을 확인해주세요", "취약점"
- **출력**: 보안 취약점 리포트와 개선 방안

---

## 🎯 특수 목적 Agent

팩과 별도로 특정 워크플로우를 위한 전문 Agent들입니다.

### 📋 github-projects-manager

- **목적**: GitHub Projects 칸반 보드 자동 관리
- **특징**:
  - 새 프로젝트 생성 및 칸반 보드 설정
  - Issue/PR을 프로젝트에 자동 추가
  - 상태 자동 변경 (Todo → In Progress → Done)
  - 다중 환경 지원 (NAS, 로컬 등)
- **자동 선택**: "프로젝트 생성", "칸반", "보드", "이슈 추가", "상태 변경"
- **출력**: 프로젝트 URL, 작업 추적 현황
- **위치**: `agents/github/github-projects-manager.json`
- **필수 조건**:
  - GitHub CLI (`gh`) 설치
  - GitHub Personal Access Token with `project` scope
- **사용 가이드**: [GitHub Projects Manager 가이드](docs/github-projects-manager-guide.md)

**사용 예시**:
```text
# 프로젝트 생성
> "AI 챗봇 개발" 프로젝트를 생성해줘

# Issue 추가 및 상태 변경
> Issue #42를 프로젝트에 추가하고 "In Progress"로 변경해줘

# 작업 완료
> Issue #42를 "Done"으로 변경해줘
```

---

## 🎯 활용 예시

### Starter Pack 활용 시나리오
```text
1. "이 로그인 함수를 검토해주세요"
   → code-reviewer가 보안과 품질 검토

2. "사용자 등록 기능의 테스트를 작성해주세요"
   → test-generator가 TDD 테스트 케이스 생성
```

### Essential Pack 활용 시나리오
```text
1. "프로젝트 README를 작성해주세요"
   → korean-docs가 체계적인 한국어 문서 생성

2. "이 에러가 왜 발생하는지 분석해주세요"
   → debug-expert가 근본 원인 분석 및 해결책 제시
```

### Professional Pack 활용 시나리오
```text
1. "사용자 관리 API를 설계해주세요"
   → api-architect가 완전한 REST API 설계

2. "이 애플리케이션이 너무 느려요"
   → performance-optimizer가 성능 병목 분석

3. "보안 검토를 해주세요"
   → security-auditor가 종합적인 보안 감사
```

---

## 🤔 팩 선택 가이드

### 어떤 팩을 선택해야 할까요?

#### 🚀 Starter Pack을 선택하세요 (2개)
- ✅ Claude Code 에이전트를 처음 사용
- ✅ 부담 없이 핵심 기능만 경험하고 싶음
- ✅ 간단한 개인 프로젝트 개발

#### 🎨 Essential Pack을 선택하세요 (4개)
- ✅ 한국어 문서화가 중요함
- ✅ 체계적인 디버깅 프로세스를 원함
- ✅ 일상적인 개발 작업에 활용하고 싶음
- ✅ 개인 개발 스타일에 맞춘 도구를 원함

#### ⚡ Professional Pack을 선택하세요 (7개)
- ✅ API 개발을 자주 함
- ✅ 성능 최적화가 중요한 프로젝트
- ✅ 보안이 중요한 애플리케이션 개발
- ✅ 전문적인 웹 개발 프로젝트

### 🔄 팩 업그레이드
언제든지 설정 스크립트를 다시 실행하여 더 큰 팩으로 업그레이드할 수 있습니다!

```bash
# 업그레이드하고 싶을 때
~/molidae/ai/claude-code/scripts/setup.sh
```

---

## 📁 프로젝트 구조

```
~/molidae/ai/claude-code/
├── agents/
│   ├── starter/                 # 2개 핵심 에이전트 (첫 경험용)
│   │   ├── code-reviewer.json
│   │   └── test-generator.json
│   ├── essential/               # 2개 개인화 에이전트 (일반 사용자)
│   │   ├── korean-docs.json
│   │   └── debug-expert.json
│   ├── professional/           # 3개 전문 에이전트 (고급 사용자)
│   │   ├── api-architect.json
│   │   ├── performance-optimizer.json
│   │   └── security-auditor.json
│   └── github/                 # 특수 목적 에이전트
│       └── github-projects-manager.json
├── docs/
│   ├── agent-guide.md          # 상세 활용 가이드
│   ├── setup-guide.md          # 설정 가이드
│   └── github-projects-manager-guide.md  # GitHub Projects 가이드
├── scripts/
│   ├── setup.sh               # 자동 설정 스크립트 (팩 선택)
│   ├── github-projects-helper.sh  # GitHub Projects API 헬퍼
│   └── TEST_RESULTS.md        # GitHub Projects Agent 테스트 결과
├── templates/
│   └── agent-template.json    # 새 에이전트 템플릿
└── README.md                  # 메인 가이드
```

---

## 🛠️ 커스터마이징

### 에이전트 수정
각 에이전트의 JSON 파일을 편집하여 개인 스타일에 맞게 커스터마이징할 수 있습니다.

```json
{
  "name": "custom-agent",
  "description": "개인화된 설명 추가. PROACTIVELY 키워드로 자동 선택 확률 증가",
  "tools": ["Read", "Write", "Edit"],
  "model": "sonnet"
}
```

### 새로운 에이전트 추가
`templates/agent-template.json`을 참고하여 새로운 에이전트를 만들 수 있습니다.

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

---

## 🎉 시작해보세요!

```bash
# 1. 자동 설정 스크립트 실행
~/molidae/ai/claude-code/scripts/setup.sh

# 2. Starter Pack부터 시작 (추천)

# 3. Claude Code에서 확인
/agents

# 4. 첫 에이전트 사용
# "이 코드를 검토해주세요"
```

**작은 것부터 시작해서 점진적으로 확장하세요!** 🚀

---

*이 라이브러리는 개인 개발 스타일에 맞춰 지속적으로 업데이트됩니다.*