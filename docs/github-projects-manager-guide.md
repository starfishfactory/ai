# 📋 GitHub Projects Manager Agent - 사용 가이드

> GitHub Projects 칸반 보드를 Claude Code에서 자동으로 관리하는 Agent

---

## 📋 목차

1. [개요](#개요)
2. [빠른 시작](#빠른-시작)
3. [사전 준비](#사전-준비)
4. [사용 시나리오](#사용-시나리오)
5. [명령어 예시](#명령어-예시)
6. [문제 해결](#문제-해결)
7. [고급 활용](#고급-활용)

---

## 개요

### 🎯 무엇을 할 수 있나요?

GitHub Projects Manager Agent는 다음을 자동화합니다:

- ✅ **프로젝트 생성**: 새로운 칸반 보드 자동 생성
- ✅ **아이템 관리**: Issue/PR을 프로젝트에 추가
- ✅ **상태 자동 변경**: Todo → In Progress → Done
- ✅ **다중 환경 지원**: 여러 장비에서 동일한 프로젝트 관리

### 💡 왜 사용하나요?

**문제 상황**:
- 여러 장비(NAS, 로컬 Mac 등)에서 작업할 때 진행 상황 추적이 어려움
- 긴 호흡의 AI 작업을 체계적으로 관리하고 싶음
- 수동으로 칸반 보드를 업데이트하는 것이 번거로움

**해결책**:
- Claude Code에서 자연어로 요청만 하면 자동으로 프로젝트 관리
- 작업 시작/완료 시 자동으로 상태 업데이트
- 웹 UI로 언제든지 전체 진행 상황 확인

---

## 빠른 시작

### 1️⃣ Agent 설치 확인

Agent가 이미 설치되어 있는지 확인:

```bash
ls -la ~/.claude/agents/"molidae-advanced:github-projects-manager.md"
```

또는 Claude Code에서:
```
/agents
```

### 2️⃣ 첫 사용

Claude Code에서 자연어로 요청:

```
새 프로젝트를 생성해줘: "AI 개발 작업"
```

Agent가 자동으로:
1. GitHub Projects 생성
2. 기본 상태 필드 설정 (Todo, In Progress, Done)
3. 프로젝트 URL 반환

### 3️⃣ Issue 추가

```
Issue #123을 프로젝트에 추가해줘
```

### 4️⃣ 상태 변경

```
Issue #123 상태를 "In Progress"로 변경해줘
```

---

## 사전 준비

### ✅ 필수 요구사항

#### 1. GitHub CLI 설치

```bash
# macOS
brew install gh

# 확인
gh --version
```

#### 2. GitHub Personal Access Token

**Classic Token 생성**:
1. https://github.com/settings/tokens/new 접속
2. Note: `claude-code-projects`
3. Expiration: 90 days (권장)
4. **Scopes 선택**:
   - ✅ `repo` (전체)
   - ✅ `project` ⚠️ **필수!**
5. "Generate token" 클릭

**토큰 적용**:
```bash
echo "YOUR_TOKEN" | gh auth login --with-token

# 확인
gh auth status
# 출력에 'project' scope가 포함되어 있어야 함
```

#### 3. Agent 파일 확인

```bash
# Agent Markdown 파일
ls ~/.claude/agents/"molidae-advanced:github-projects-manager.md"

# Helper Script
ls ~/IdeaProjects/molidae/ai/scripts/github-projects-helper.sh
```

---

## 사용 시나리오

### 시나리오 1️⃣: 새 프로젝트 시작

**상황**: 새로운 AI 프로젝트를 시작하고 칸반 보드로 관리하고 싶음

**Claude Code에서**:
```
"AI 챗봇 개발" 프로젝트를 생성해줘
```

**Agent 동작**:
1. GitHub Projects 생성
2. 기본 칼럼 설정 (Todo, In Progress, Done)
3. 프로젝트 URL 반환

**결과**:
```
✅ 프로젝트 생성: AI 챗봇 개발
ℹ 프로젝트 번호: 4
ℹ URL: https://github.com/users/[username]/projects/4
```

---

### 시나리오 2️⃣: 작업 시작할 때

**상황**: 새로운 기능 개발을 시작하면서 Issue를 프로젝트에 추가

**Claude Code에서**:
```
Issue #42를 프로젝트 #3에 추가하고 "In Progress"로 변경해줘
```

**Agent 동작**:
1. Issue #42의 Node ID 조회
2. 프로젝트 #3에 아이템 추가
3. 상태를 "In Progress"로 변경

**결과**:
- 웹 UI에서 Issue가 "In Progress" 칼럼에 표시됨
- 다른 장비(NAS 등)에서도 진행 상황 확인 가능

---

### 시나리오 3️⃣: 작업 완료할 때

**상황**: 기능 개발이 완료되어 PR을 머지함

**Claude Code에서**:
```
Issue #42를 "Done"으로 변경해줘
```

**Agent 동작**:
1. 프로젝트에서 Issue #42 찾기
2. 상태를 "Done"으로 변경

**결과**:
- 웹 UI에서 Issue가 "Done" 칼럼으로 이동
- 완료된 작업 시각적으로 확인 가능

---

### 시나리오 4️⃣: 프로젝트 현황 확인

**상황**: 현재 진행 중인 프로젝트 목록 확인

**Claude Code에서**:
```
내 GitHub Projects 목록을 보여줘
```

**Agent 동작**:
1. 사용자의 모든 프로젝트 조회
2. 최근 업데이트 순으로 정렬

**결과**:
```
4: AI 챗봇 개발
3: GitHub Projects Agent - Test
2: 테스트 칸반 프로젝트
1: @username's untitled project
```

---

## 명령어 예시

### 프로젝트 관리

```bash
# 새 프로젝트 생성
"새 프로젝트 생성해줘: [프로젝트 이름]"

# 프로젝트 목록 조회
"내 프로젝트 목록 보여줘"

# 특정 프로젝트 ID 조회
"프로젝트 #3의 ID를 알려줘"
```

### Issue/PR 관리

```bash
# Issue를 프로젝트에 추가
"Issue #123을 프로젝트 #2에 추가해줘"

# PR을 프로젝트에 추가
"PR #45를 프로젝트에 추가해줘"

# Issue ID 조회
"starfishfactory/ai 저장소의 Issue #10 ID를 조회해줘"
```

### 상태 변경

```bash
# 작업 시작
"Issue #123을 'In Progress'로 변경해줘"

# 작업 완료
"Issue #123을 'Done'으로 변경해줘"

# 상태 되돌리기
"Issue #123을 'Todo'로 변경해줘"
```

### 복합 작업

```bash
# 한 번에 처리
"Issue #99를 프로젝트 #3에 추가하고 바로 'In Progress'로 변경해줘"

# 여러 Issue 한꺼번에
"Issue #101, #102, #103을 프로젝트에 추가해줘"
```

---

## 문제 해결

### ❌ "Token has not been granted the required scopes"

**원인**: GitHub Token에 `project` scope가 없음

**해결**:
1. 새 Classic Token 생성 (위의 "사전 준비" 참고)
2. `project` scope 체크박스 선택 필수
3. `gh auth login --with-token`으로 적용

**확인**:
```bash
gh auth status
# 출력에 'project' scope 포함 여부 확인
```

---

### ❌ "Could not resolve to a node with the global id"

**원인**: 잘못된 ID 또는 권한 없는 리소스 접근

**해결**:
1. Issue/PR 번호가 정확한지 확인
2. 저장소 접근 권한 확인
3. ID 조회 명령어로 올바른 Node ID 획득:
   ```bash
   ./claude-code/scripts/github-projects-helper.sh get-issue-id owner/repo 123
   ```

---

### ❌ "Project not found"

**원인**: 프로젝트 번호가 잘못되었거나 삭제됨

**해결**:
1. 프로젝트 목록 조회:
   ```bash
   ./claude-code/scripts/github-projects-helper.sh list
   ```
2. 올바른 프로젝트 번호 확인
3. 웹 UI에서 프로젝트 존재 여부 확인

---

### ❌ Agent가 자동으로 선택되지 않음

**원인**: 키워드 매칭이 안 되거나 Agent 파일 문제

**해결**:
1. Agent 파일 확인:
   ```bash
   cat ~/.claude/agents/"molidae-advanced:github-projects-manager.md"
   ```
2. 명시적으로 키워드 사용:
   - "프로젝트", "Projects", "칸반", "보드"
   - "이슈", "TODO", "In Progress", "Done"
3. Agent 직접 선택 (Claude Code에서):
   ```
   molidae-advanced:github-projects-manager 에이전트로 프로젝트를 생성해줘
   ```

---

## 고급 활용

### 🔄 다중 환경 워크플로우

**시나리오**: NAS 컨테이너와 로컬 Mac에서 동시 작업

1. **NAS에서 작업 시작**:
   ```
   Issue #55를 프로젝트에 추가하고 "In Progress"로 변경
   ```

2. **로컬 Mac에서 확인**:
   ```
   프로젝트 #3 상태를 보여줘
   ```
   - 웹 UI에서 Issue #55가 "In Progress"에 있음을 확인

3. **로컬 Mac에서 작업 완료**:
   ```
   Issue #55를 "Done"으로 변경
   ```

4. **NAS에서 다시 확인**:
   - 자동으로 동기화되어 "Done" 상태 반영됨

---

### 🎯 프로젝트별 칸반 전략

#### 개인 프로젝트
```
프로젝트: "개인 학습"
- Todo: 학습할 주제
- In Progress: 현재 공부 중
- Done: 완료한 학습
```

#### 팀 협업 프로젝트
```
프로젝트: "서비스 개발"
- Todo: 백로그
- In Progress: 개발 중 (assignee 설정)
- Done: 완료 및 배포
```

#### 버그 트래킹
```
프로젝트: "버그 수정"
- Todo: 보고된 버그
- In Progress: 수정 중
- Done: 검증 완료
```

---

### 🚀 자동화 팁

#### Git Hook 연동 (향후)
```bash
# .git/hooks/post-commit
#!/bin/bash
# 커밋 메시지에서 Issue 번호 추출
# 자동으로 "In Progress"로 변경
```

#### CI/CD 연동 (향후)
```yaml
# .github/workflows/project-update.yml
on:
  pull_request:
    types: [closed]
jobs:
  update-project:
    # PR 머지 시 자동으로 "Done"으로 변경
```

---

## 📚 추가 자료

### 관련 문서
- [테스트 결과](../scripts/TEST_RESULTS.md) - Phase 1 검증 결과
- [Helper Script 소스](../scripts/github-projects-helper.sh) - 내부 구현 참고
- [Agent 설정](../agents/advanced/github-projects-manager.md) - Agent 설정 파일

### 외부 참고
- [GitHub Projects V2 문서](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [GitHub GraphQL API](https://docs.github.com/en/graphql)
- [gh CLI 문서](https://cli.github.com/manual/)

---

## 💬 피드백 및 기여

질문이나 제안사항은 GitHub Issues로 남겨주세요!

- 버그 리포트: Issue 생성
- 기능 요청: Issue 생성 (label: enhancement)
- 문서 개선: PR 환영합니다

---

**마지막 업데이트**: 2025-10-12
**Agent 버전**: Phase 1 (v1.0)
**테스트 상태**: ✅ 검증 완료
