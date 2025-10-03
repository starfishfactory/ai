# 📚 GitHub Projects Manager Agent 사용 가이드

> **작성일**: 2025-10-03
> **대상**: GitHub Projects로 작업을 관리하고 싶은 개발자

---

## 📋 목차

1. [시작하기 전에](#시작하기-전에)
2. [초기 설정](#초기-설정)
3. [Agent 설치](#agent-설치)
4. [기본 사용법](#기본-사용법)
5. [고급 기능](#고급-기능)
6. [다중 환경 설정](#다중-환경-설정)
7. [문제 해결](#문제-해결)

---

## 시작하기 전에

### ✅ 필요한 것

```yaml
필수 요구사항:
  - GitHub 계정
  - GitHub CLI (gh) 설치 및 인증
  - Claude Code 설치
  - GitHub Projects V2 보드 1개

선택 사항:
  - 여러 개발 환경 (NAS, 로컬 등)
```

### 🔍 사전 확인

```bash
# 1. GitHub CLI 설치 확인
gh --version
# 출력: gh version 2.40.0 (2024-01-01)

# 2. 인증 상태 확인
gh auth status
# 출력: ✓ Logged in to github.com account starfishfactory

# 3. Claude Code 설치 확인
claude --version
# 출력: claude-code version 0.x.x
```

---

## 초기 설정

### 1️⃣ GitHub Token에 Project Scope 추가

현재 token에 `project` scope가 없으면 추가해야 합니다.

```bash
# 현재 token scope 확인
gh auth status

# project scope가 없다면 재인증
gh auth login

# 선택 옵션:
# - What account do you want to log into? GitHub.com
# - What is your preferred protocol for Git operations? HTTPS
# - Authenticate Git with your GitHub credentials? Yes
# - How would you like to authenticate GitHub CLI? Login with a web browser
```

**웹 브라우저에서:**
1. GitHub Settings → Developer settings → Personal access tokens
2. Fine-grained tokens 선택
3. 새 토큰 생성 또는 기존 토큰 편집
4. **Permissions** 섹션에서 `Projects: Read and write` 선택
5. 저장

**확인:**
```bash
# GraphQL로 권한 테스트
gh api graphql -f query='
{
  viewer {
    projectsV2(first: 1) {
      nodes {
        title
      }
    }
  }
}'

# 성공 시 프로젝트 목록이 출력됨
```

### 2️⃣ GitHub Projects 보드 생성

```bash
# 옵션 1: 웹에서 생성 (권장)
# https://github.com/users/[username]/projects/new
# - Template: Board 선택
# - 이름: "My Development Tasks"
# - 상태 필드 추가: Todo, In Progress, Done

# 옵션 2: CLI로 조회 (이미 있다면)
gh api graphql -f query='
{
  viewer {
    projectsV2(first: 5) {
      nodes {
        number
        title
      }
    }
  }
}' --jq '.data.viewer.projectsV2.nodes[] | "\(.number): \(.title)"'

# 출력 예시:
# 1: My Development Tasks
# 2: Team Sprint Board
```

### 3️⃣ 프로젝트 ID 및 필드 ID 조회

```bash
# 프로젝트 정보 조회 (프로젝트 번호 = 1)
gh api graphql -f query='
{
  viewer {
    projectV2(number: 1) {
      id
      title
      field(name: "Status") {
        ... on ProjectV2SingleSelectField {
          id
          options {
            id
            name
          }
        }
      }
    }
  }
}' > ~/.claude/github-project-info.json

# 결과 저장됨
cat ~/.claude/github-project-info.json
```

**결과 예시:**
```json
{
  "data": {
    "viewer": {
      "projectV2": {
        "id": "PVT_kwDOABCDEF",
        "title": "My Development Tasks",
        "field": {
          "id": "PVTSSF_lADOABCDEF",
          "options": [
            {"id": "abc123", "name": "Todo"},
            {"id": "def456", "name": "In Progress"},
            {"id": "ghi789", "name": "Done"}
          ]
        }
      }
    }
  }
}
```

### 4️⃣ 설정 파일 생성

```bash
# 설정 디렉토리 생성
mkdir -p ~/.claude

# 프로젝트 설정 저장
cat > ~/.claude/github-projects-config.sh << 'EOF'
# GitHub Projects 설정
export GITHUB_PROJECT_NUMBER=1
export GITHUB_PROJECT_ID="PVT_kwDOABCDEF"  # 실제 ID로 변경
export GITHUB_STATUS_FIELD_ID="PVTSSF_lADOABCDEF"  # 실제 ID로 변경

# 상태 옵션 ID
export STATUS_TODO_ID="abc123"  # 실제 ID로 변경
export STATUS_IN_PROGRESS_ID="def456"  # 실제 ID로 변경
export STATUS_DONE_ID="ghi789"  # 실제 ID로 변경
EOF

# 권한 설정
chmod 600 ~/.claude/github-projects-config.sh

# 활성화
source ~/.claude/github-projects-config.sh
```

---

## Agent 설치

### 📦 Agent 파일 다운로드

```bash
# 1. AI 프로젝트 클론 (처음이라면)
git clone https://github.com/starfishfactory/ai.git ~/molidae/ai
cd ~/molidae/ai

# 2. Main 브랜치로 전환
git checkout main
git pull

# 3. Agent 디렉토리 확인
ls -la claude-code/agents/github/
```

### 🔗 Agent 설치 (심볼릭 링크)

```bash
# Claude Code agents 디렉토리로 심볼릭 링크 생성
ln -sf ~/molidae/ai/claude-code/agents/github/github-projects-manager.json \
       ~/.claude/agents/github-projects-manager.json

# 설치 확인
ls -la ~/.claude/agents/

# Claude Code에서 확인
/agents
```

**예상 출력:**
```
Available agents:
- code-reviewer
- test-generator
- korean-docs
- github-projects-manager  ← 새로 추가됨
```

---

## 기본 사용법

### 📝 시나리오 1: 새 작업 시작

```bash
# Claude Code 실행
claude

# 대화 시작
> "새로운 기능 개발: 사용자 로그인 구현을 시작합니다"
```

**Agent 자동 동작:**
1. `github-projects-manager` agent 자동 선택
2. GitHub Issue 생성
3. Projects 아이템 추가
4. 상태를 "Todo"로 설정

**출력 예시:**
```
🤖 github-projects-manager agent가 선택되었습니다.

✅ Issue #5 생성: 사용자 로그인 구현
✅ Projects 아이템 추가 완료
📋 상태: Todo
🔗 https://github.com/starfishfactory/my-repo/issues/5

작업을 시작할 준비가 되었습니다!
```

### 🚀 시나리오 2: 작업 진행 중으로 변경

```bash
> "Issue #5 작업을 시작합니다"
```

**출력:**
```
✅ Issue #5 상태 변경: Todo → In Progress
🔧 작업 시작!
```

### ✅ 시나리오 3: 작업 완료 및 PR 생성

```bash
# 코드 작성 후...
> "Issue #5 작업을 완료했습니다. PR을 생성해주세요"
```

**출력:**
```
✅ PR #10 생성: feat: 사용자 로그인 구현
✅ Issue #5와 PR #10 연결 완료
✅ 상태 변경: In Progress → Done
🔗 https://github.com/starfishfactory/my-repo/pull/10

축하합니다! 작업이 완료되었습니다.
```

---

## 고급 기능

### 🎯 직접 GraphQL 쿼리 실행

```bash
> "프로젝트 아이템 목록을 조회해주세요"
```

**출력:**
```
📊 현재 진행 중인 작업:

In Progress (2):
- Issue #5: 사용자 로그인 구현
- Issue #8: API 성능 최적화

Todo (3):
- Issue #12: 단위 테스트 추가
- Issue #15: 문서 업데이트
- Issue #17: 버그 수정

Done (5):
- PR #10: 사용자 로그인 구현
- ...
```

### 🔄 상태 직접 변경

```bash
> "Issue #12를 In Progress로 변경해주세요"
```

**출력:**
```
✅ Issue #12 상태 변경: Todo → In Progress
```

### 🏷️ 커스텀 필드 업데이트 (고급)

```bash
> "Issue #5의 우선순위를 High로 설정해주세요"
```

**출력:**
```
✅ Issue #5 우선순위 변경: Medium → High
```

---

## 다중 환경 설정

### 🖥️ NAS 컨테이너 설정

**NAS에서:**
```bash
# 1. SSH로 접속
ssh user@nas.local

# 2. 설정 파일 복사
scp ~/.claude/github-projects-config.sh user@nas.local:~/.claude/

# 3. Agent 파일 복사
scp -r ~/.claude/agents/ user@nas.local:~/.claude/

# 4. GitHub CLI 인증 (토큰 공유)
gh auth login

# 5. 테스트
claude
> "테스트 작업을 시작합니다"
```

### 🔄 설정 동기화

```bash
# 로컬에서 설정 변경 시
# 1. Git으로 관리 (추천)
cd ~/molidae/ai
git add claude-code/agents/
git commit -m "✨ feat: GitHub Projects agent 업데이트"
git push

# 2. NAS에서 동기화
ssh user@nas.local
cd ~/molidae/ai
git pull
```

---

## 문제 해결

### ❌ "project scope가 필요합니다" 에러

**문제:**
```
Error: Your token has not been granted the required scopes
Required: ['read:project']
```

**해결:**
1. [초기 설정 1️⃣](#1️⃣-github-token에-project-scope-추가) 참고
2. Token에 project scope 추가
3. `gh auth login` 재실행

### ❌ "프로젝트를 찾을 수 없습니다" 에러

**문제:**
```
Error: Could not resolve to a ProjectV2 with the number 1
```

**해결:**
```bash
# 프로젝트 번호 확인
gh api graphql -f query='
{
  viewer {
    projectsV2(first: 10) {
      nodes {
        number
        title
      }
    }
  }
}' --jq '.data.viewer.projectsV2.nodes[]'

# 올바른 번호로 설정 업데이트
nano ~/.claude/github-projects-config.sh
# GITHUB_PROJECT_NUMBER를 실제 번호로 변경
```

### ❌ Agent가 자동 선택되지 않음

**문제:**
Agent가 자동으로 선택되지 않고 기본 agent가 실행됨

**해결:**
```bash
# 1. Agent 파일 확인
cat ~/.claude/agents/github-projects-manager.json

# 2. 키워드를 명시적으로 사용
> "github-projects-manager agent로 새 작업을 시작해주세요"

# 3. Agent description 업데이트 (PROACTIVELY 키워드 추가)
```

### ❌ "GraphQL 에러" 발생

**문제:**
```
Error: Something went wrong while executing your query
```

**해결:**
```bash
# 1. 상세 에러 확인
gh api graphql -f query='...' --verbose

# 2. 캐시 파일 삭제 및 재시도
rm ~/.claude/github-project-info.json
source ~/.claude/github-projects-config.sh

# 3. 프로젝트 ID 재조회
gh api graphql -f query='...' > ~/.claude/github-project-info.json
```

### 🐛 디버그 모드

```bash
# 상세 로그 활성화
export CLAUDE_DEBUG=1

# Agent 실행 로그 확인
tail -f ~/.claude/logs/github-projects-manager.log
```

---

## 자주 묻는 질문 (FAQ)

### Q1: 여러 프로젝트를 동시에 사용할 수 있나요?

**A:** 현재는 하나의 프로젝트만 지원합니다. 여러 프로젝트를 사용하려면:
```bash
# 프로젝트별 설정 파일 생성
~/.claude/github-projects-config-project1.sh
~/.claude/github-projects-config-project2.sh

# 사용 시 선택적으로 로드
source ~/.claude/github-projects-config-project1.sh
```

### Q2: Classic Projects도 지원하나요?

**A:** 아니요, Projects V2 (GraphQL API)만 지원합니다.

### Q3: 조직(Organization) 프로젝트도 사용 가능한가요?

**A:** 네, 가능합니다. 프로젝트 ID 조회 시 조직 프로젝트를 선택하면 됩니다.

```bash
gh api graphql -f query='
{
  organization(login: "my-org") {
    projectV2(number: 1) {
      id
    }
  }
}'
```

### Q4: 성능은 어떤가요?

**A:** 매우 효율적입니다:
- 평균 응답 시간: 2-3초
- 토큰 사용량: ~600 토큰/작업
- API 호출: 1-2회/작업

---

## 추가 리소스

### 📚 관련 문서
- [개발 계획 문서](./github-projects-integration-plan.md)
- [테스트 시나리오](./github-projects-test-scenarios.md)
- [GitHub Projects API 문서](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects)

### 🔗 유용한 링크
- [GitHub CLI 문서](https://cli.github.com/manual/)
- [Claude Code 문서](https://docs.claude.com/claude-code)
- [GraphQL Explorer](https://docs.github.com/en/graphql/overview/explorer)

### 💬 도움 받기
- GitHub Issues: [starfishfactory/ai/issues](https://github.com/starfishfactory/ai/issues)
- 문서 개선 제안: Pull Request 환영

---

**문서 버전**: 1.0
**최종 업데이트**: 2025-10-03

**즐거운 개발 되세요! 🚀**
