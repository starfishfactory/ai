---
description: 브랜치 생성/전환/정리
allowed-tools: Bash, AskUserQuestion
argument-hint: "<create|switch|cleanup> [옵션]"
---

# 브랜치 관리: $ARGUMENTS

브랜치 생성, 전환, 정리를 수행한다.

---

## 인자 파싱

`$ARGUMENTS` 첫 단어로 모드를 결정한다:
- `create` → create 모드
- `switch` → switch 모드
- `cleanup` → cleanup 모드
- 없으면 → AskUserQuestion으로 모드 선택

---

## create 모드

### Step 1: 타입 선택
AskUserQuestion으로 브랜치 타입 선택:
- feat / fix / chore / docs / refactor / test

### Step 2: 이슈 번호 (선택)
AskUserQuestion으로 이슈 번호 입력. 없으면 생략.

### Step 3: 브랜치 설명
AskUserQuestion으로 브랜치 설명 입력 (예: "add user login").

### Step 4: 브랜치 생성
- 설명을 kebab-case로 변환
- 브랜치명 생성: `<type>/<issue>-<desc>` 또는 `<type>/<desc>` (이슈번호 없을 때)
- `git checkout -b <branch>` 실행
- **실패** → "동일 이름의 브랜치가 이미 존재합니다" 등 에러 표시 후 **종료**
- **성공** → "브랜치 생성 완료: `<branch>`" 출력

---

## switch 모드

### Step 1: 브랜치 목록 조회
`git branch --format='%(refname:short)'` → 현재 브랜치를 제외한 목록 조회.

### Step 2: 변경사항 확인
`git status --porcelain` → 변경사항이 있으면:
- AskUserQuestion: "커밋되지 않은 변경사항이 있습니다. stash할까요?"
- Yes → `git stash push -m "auto-stash by git plugin"`

### Step 3: 브랜치 선택
AskUserQuestion으로 전환할 브랜치 선택.

### Step 4: 브랜치 전환
- `git checkout <branch>` 실행
- **실패** → 에러 표시 + stash를 했다면 "`git stash pop`으로 변경사항을 복구하세요" 안내 후 **종료**
- **성공** → "브랜치 전환 완료: `<branch>`" 출력

---

## cleanup 모드

### Step 1: 기본 브랜치 감지
`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'` → base 브랜치 (main 또는 master).
실패 시 → `main`을 기본값으로 사용.

### Step 2: merged 브랜치 감지
`git branch --merged <base>` → base에 이미 병합된 브랜치 목록.
base 브랜치, develop, 현재 브랜치는 제외.

### Step 3: stale 브랜치 감지
`git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:unix)'` → 각 브랜치의 마지막 커밋 시각 확인.
- 임계값 계산: `date -v-30d +%s` (macOS) — 30일 전 unix timestamp
- `committerdate:unix < threshold`인 브랜치 = stale
- merged 목록과 중복되는 것은 merged로 분류

### Step 4: 삭제 후보 제시
AskUserQuestion으로 삭제 후보 목록을 제시한다:
- **[merged]** 라벨: base에 이미 병합된 브랜치
- **[stale]** 라벨: 30일 이상 미활동 브랜치

### Step 5: 삭제 실행
- 사용자가 승인한 브랜치만 `git branch -d <branch>` 순회 실행
- **삭제 실패 (unmerged)** → 경고 표시 + 해당 브랜치 건너뛰기 (강제 삭제 `-D` 안 함)
- 완료 → 삭제된 브랜치 수 출력
