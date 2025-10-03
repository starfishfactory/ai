# 🧪 GitHub Projects Agent 테스트 시나리오

> **작성일**: 2025-10-03
> **목적**: Agent 검증을 위한 실제 테스트 시나리오 정의

---

## 📋 목차

1. [테스트 환경 설정](#테스트-환경-설정)
2. [시나리오 0: 프로젝트 생성](#시나리오-0-프로젝트-생성)
3. [시나리오 1: 기본 워크플로우](#시나리오-1-기본-워크플로우)
4. [시나리오 2: PR 연동](#시나리오-2-pr-연동)
5. [시나리오 3: 병렬 작업](#시나리오-3-병렬-작업)
6. [시나리오 4: 에러 처리](#시나리오-4-에러-처리)
7. [검증 체크리스트](#검증-체크리스트)

---

## 테스트 환경 설정

### 🎯 테스트 프로젝트 생성

```bash
# 1. 테스트용 GitHub 저장소 생성
gh repo create test-github-projects-agent --private

# 2. GitHub Projects 보드 생성
# GitHub 웹에서 직접 생성:
# https://github.com/users/[username]/projects/new
# - 이름: "Test Project - Agent Validation"
# - Template: Board

# 3. 상태 필드 설정
# - Todo
# - In Progress
# - Done
```

### 🔧 필요한 설정 값

테스트 전에 아래 값들을 확인하세요:

```bash
# 프로젝트 번호 확인 (URL에서)
# https://github.com/users/[username]/projects/1
PROJECT_NUMBER=1

# 프로젝트 ID 조회
gh api graphql -f query='
{
  viewer {
    projectV2(number: 1) {
      id
    }
  }
}' --jq '.data.viewer.projectV2.id'

# 결과 예시: PVT_kwDOABCDEF
```

### 📝 환경 변수 설정

```bash
# ~/.claude/github-projects-config.sh
export GITHUB_PROJECT_NUMBER=1
export GITHUB_PROJECT_ID="PVT_kwDOABCDEF"  # 실제 ID로 변경
export GITHUB_REPO="starfishfactory/test-github-projects-agent"
```

---

## 시나리오 0: 프로젝트 생성

### 🎯 목표
새 GitHub Projects 보드를 자동으로 생성하고 기본 설정 검증

### 📝 단계별 실행

#### Step 1: 새 프로젝트 생성
```bash
# Claude Code에서 실행
"새 프로젝트를 생성해주세요: AI Agent 개발"
```

**예상 동작:**
```yaml
Agent 선택: github-projects-manager
실행 내용:
  1. 사용자 ID 조회
  2. 새 프로젝트 생성 (제목: "AI Agent 개발")
  3. 기본 상태 필드 생성 (Todo, In Progress, Done)

출력 예시:
  ✅ 프로젝트 생성: AI Agent 개발
  ✅ 상태 필드 설정: Todo, In Progress, Done
  📋 프로젝트 번호: 5
  🔗 https://github.com/users/[username]/projects/5
```

**검증 방법:**
- [ ] GitHub Projects에 새 프로젝트가 생성됨
- [ ] 프로젝트 제목이 "AI Agent 개발"로 설정됨
- [ ] 상태 필드가 3개 생성됨 (Todo, In Progress, Done)
- [ ] 프로젝트 URL이 정상 동작함

#### Step 2: 기존 프로젝트 조회
```bash
# Claude Code에서 실행
"현재 프로젝트 목록을 보여주세요"
```

**예상 동작:**
```yaml
실행 내용:
  1. 사용자의 모든 프로젝트 조회
  2. 프로젝트 목록 표시

출력 예시:
  📊 프로젝트 목록:

  1. AI Agent 개발 (방금 생성됨)
  2. 이전 프로젝트 1
  3. 이전 프로젝트 2
```

**검증 방법:**
- [ ] 모든 프로젝트가 조회됨
- [ ] 새로 생성한 프로젝트가 목록에 포함됨
- [ ] 프로젝트 번호와 제목이 정확함

---

## 시나리오 1: 기본 워크플로우

### 🎯 목표
새 작업 시작부터 완료까지 전체 흐름 검증

### 📝 단계별 실행

#### Step 1: 새 이슈 생성
```bash
# Claude Code에서 실행
"새 기능 개발: 사용자 인증 구현"
```

**예상 동작:**
```yaml
Agent 선택: github-projects-manager
실행 내용:
  1. Issue 생성 (GitHub)
  2. Projects에 아이템 자동 추가
  3. 초기 상태: Todo

출력 예시:
  ✅ Issue #1 생성: 사용자 인증 구현
  ✅ Projects 아이템 추가 완료
  📋 상태: Todo
  🔗 https://github.com/[username]/test-github-projects-agent/issues/1
```

**검증 방법:**
- [ ] GitHub Issues에 새 이슈 생성됨
- [ ] GitHub Projects에 아이템 표시됨
- [ ] 상태가 "Todo"로 설정됨
- [ ] 아이템이 이슈와 연결됨

#### Step 2: 작업 시작
```bash
# Claude Code에서 실행
"Issue #1 작업을 시작합니다"
```

**예상 동작:**
```yaml
Agent 선택: github-projects-manager
실행 내용:
  1. Issue #1의 프로젝트 아이템 조회
  2. 상태를 "In Progress"로 변경

출력 예시:
  ✅ Issue #1 상태 변경: Todo → In Progress
  🔧 작업을 시작하세요!
```

**검증 방법:**
- [ ] Projects 상태가 "In Progress"로 변경됨
- [ ] 칸반 보드에서 아이템이 올바른 컬럼으로 이동
- [ ] 타임스탬프 기록됨

#### Step 3: 작업 완료 및 PR 생성
```bash
# Claude Code에서 실행
"Issue #1 작업을 완료하고 PR을 생성합니다"
```

**예상 동작:**
```yaml
Agent 선택: github-projects-manager
실행 내용:
  1. PR 생성
  2. PR을 Projects 아이템과 연결
  3. 상태를 "Done"으로 변경

출력 예시:
  ✅ PR #1 생성: feat: 사용자 인증 구현
  ✅ Issue #1과 PR #1 연결 완료
  ✅ 상태 변경: In Progress → Done
  🔗 https://github.com/[username]/test-github-projects-agent/pull/1
```

**검증 방법:**
- [ ] PR이 생성됨
- [ ] PR이 Issue #1을 참조함
- [ ] Projects 상태가 "Done"으로 변경됨
- [ ] PR과 프로젝트 아이템이 연결됨

---

## 시나리오 2: PR 연동

### 🎯 목표
기존 이슈 없이 PR을 직접 생성하고 프로젝트 연결

### 📝 실행 단계

```bash
# 1. 직접 PR 생성
git checkout -b feature/new-feature
# ... 코드 작성 ...
git commit -m "feat: 새 기능 추가"
git push origin feature/new-feature

# 2. Claude Code에서 PR 생성 및 프로젝트 추가
"새 기능 PR을 생성하고 프로젝트에 추가해주세요"
```

**예상 동작:**
```yaml
실행 내용:
  1. PR 생성
  2. PR을 프로젝트 아이템으로 추가
  3. 초기 상태: In Progress (PR이므로)

출력:
  ✅ PR #2 생성: feat: 새 기능 추가
  ✅ Projects 아이템 추가 (PR #2)
  📋 상태: In Progress
```

**검증 방법:**
- [ ] PR이 생성됨
- [ ] Projects에 PR 아이템이 추가됨
- [ ] 상태가 "In Progress"로 설정됨

---

## 시나리오 3: 병렬 작업

### 🎯 목표
여러 작업을 동시에 관리하는 시나리오

### 📝 실행 단계

#### 환경 1: 로컬 Mac
```bash
# Terminal 1
"백엔드 API 개발 작업을 시작합니다"
```

#### 환경 2: NAS 컨테이너
```bash
# SSH로 접속 후
"프론트엔드 UI 개발 작업을 시작합니다"
```

**예상 결과:**
```yaml
GitHub Projects 보드:
  In Progress:
    - Issue #3: 백엔드 API 개발 (로컬에서)
    - Issue #4: 프론트엔드 UI 개발 (NAS에서)
  Todo:
    - (기타 작업들)
  Done:
    - Issue #1: 사용자 인증 구현
```

**검증 방법:**
- [ ] 두 작업 모두 Projects에 표시됨
- [ ] 각 작업이 독립적으로 관리됨
- [ ] 충돌 없이 상태 변경됨
- [ ] 양쪽 환경에서 동일한 agent 사용

---

## 시나리오 4: 에러 처리

### 🎯 목표
비정상 상황 처리 검증

### 📝 테스트 케이스

#### Case 1: 존재하지 않는 이슈
```bash
"Issue #999 작업을 시작합니다"
```

**예상 동작:**
```yaml
에러 메시지:
  ❌ Issue #999를 찾을 수 없습니다.
  💡 Issue 번호를 확인해주세요.
```

#### Case 2: 잘못된 프로젝트 ID
```bash
# 잘못된 PROJECT_ID 설정 후
"새 작업을 시작합니다"
```

**예상 동작:**
```yaml
에러 메시지:
  ❌ 프로젝트에 접근할 수 없습니다.
  💡 PROJECT_ID와 권한을 확인해주세요.
```

#### Case 3: Token 권한 부족
```bash
# project scope 없는 token 사용 시
```

**예상 동작:**
```yaml
에러 메시지:
  ❌ GitHub token에 'project' scope가 필요합니다.
  💡 Token 권한을 확인해주세요.
  📚 가이드: claude-code/docs/github-projects-usage-guide.md
```

**검증 방법:**
- [ ] 명확한 에러 메시지 출력
- [ ] 해결 방법 안내 포함
- [ ] 시스템이 안정적으로 유지됨

---

## 검증 체크리스트

### ✅ Phase 1: 기본 기능

#### 프로젝트 생성
- [ ] 새 프로젝트 생성 성공
- [ ] 프로젝트 제목 설정 확인
- [ ] 기본 상태 필드 생성 (Todo/In Progress/Done)
- [ ] 프로젝트 URL 정상 동작

#### GraphQL API 연동
- [ ] 프로젝트 ID 조회 성공
- [ ] 프로젝트 아이템 조회 성공
- [ ] 상태 필드 ID 조회 성공

#### 아이템 생성
- [ ] Issue 기반 아이템 생성
- [ ] PR 기반 아이템 생성
- [ ] 초기 상태 설정 (Todo)

#### 상태 변경
- [ ] Todo → In Progress 변경
- [ ] In Progress → Done 변경
- [ ] 상태 변경 이력 확인

### ✅ Phase 2: 워크플로우 통합

#### 자동 감지
- [ ] 작업 시작 키워드 감지
- [ ] PR 생성 감지
- [ ] 완료 키워드 감지

#### 자동 실행
- [ ] 키워드 감지 시 agent 자동 선택
- [ ] 아이템 자동 생성
- [ ] 상태 자동 변경

### ✅ Phase 3: 고급 기능

#### 다중 환경
- [ ] 로컬에서 정상 동작
- [ ] NAS 컨테이너에서 정상 동작
- [ ] 설정 파일 공유 확인

#### 성능
- [ ] 응답 시간 < 3초
- [ ] 토큰 사용량 < 600/작업
- [ ] 에러율 < 1%

#### 안정성
- [ ] 10회 연속 실행 성공
- [ ] 병렬 작업 충돌 없음
- [ ] 에러 복구 정상 동작

---

## 테스트 실행 가이드

### 🚀 빠른 시작

```bash
# 1. 테스트 환경 설정
cd /Users/yujinhyeong/IdeaProjects/molidae/ai
source claude-code/scripts/setup-test-env.sh

# 2. 시나리오 1 실행
./claude-code/scripts/run-test-scenario-1.sh

# 3. 결과 확인
# - GitHub Projects 보드 확인
# - 아이템 생성 및 상태 확인
# - 로그 파일 확인: /tmp/github-projects-test.log

# 4. 정리
./claude-code/scripts/cleanup-test-env.sh
```

### 📊 테스트 결과 기록

```markdown
# 테스트 결과 템플릿

## 시나리오 1: 기본 워크플로우
- 실행 일시: 2025-10-03 14:30
- 결과: ✅ 성공 / ❌ 실패
- 소요 시간: 2.5초
- 토큰 사용량: 580 토큰
- 이슈:
  - 없음

## 시나리오 2: PR 연동
- 실행 일시: 2025-10-03 14:35
- 결과: ✅ 성공
- 소요 시간: 3.1초
- 토큰 사용량: 620 토큰
- 이슈:
  - 없음

## 전체 요약
- 성공률: 100% (4/4)
- 평균 응답 시간: 2.8초
- 평균 토큰 사용량: 595 토큰
- 발견된 버그: 0개
```

---

## 다음 단계

1. ✅ 테스트 환경 설정
2. 📝 시나리오별 테스트 실행
3. 📊 결과 기록 및 분석
4. 🐛 버그 수정
5. ✅ 최종 검증 완료

---

**문서 버전**: 1.0
**최종 업데이트**: 2025-10-03
