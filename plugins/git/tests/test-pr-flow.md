# PR Flow Test Scenarios

Verify `pr.md` create mode redesign: AskUserQuestion 4+→0-2, pre-commit review GC loop, branch ensure, auto-commit/push/PR.

## Preconditions (all scenarios)
- Git repository with remote origin
- Any branch (Guard: Branch Ensure handles main/master → auto-branch after review)
- `plugins/git/commands/pr.md` loaded

---

## Scenario 1: Full flow — uncommitted changes on feat branch

**Given**: `feat/add-login` branch, unstaged changes exist, no prior commits ahead of origin
**When**: `/git:pr create`
**Then**:
1. Phase 1 executes:
   - `git status --porcelain` detects changes
   - `git add -A` auto-stages (no AskUserQuestion)
   - Sensitive file check runs (no matches → proceed)
   - `git diff --cached` collected for review
   - pr-reviewer agent invoked (Mode A, JSON)
   - Review result displayed (score + feedback)
   - **AskUserQuestion**: "Pass" / "Fix" (only user interaction in review)
   - User selects "Pass"
2. Guard: Branch Ensure (리뷰 후, 커밋 전):
   - `feat/add-login` → feature branch → AskUserQuestion: "Continue on `feat/add-login`?" / "New branch"
   - User selects "Continue"
   - Proceed to Phase 2
3. Phase 2 executes:
   - Lint runs (if detected)
   - Commit message auto-generated (gitmoji format, no AskUserQuestion)
   - `git commit` executed with HEREDOC + Co-Authored-By
4. Phase 3 executes:
   - `git push -u origin feat/add-login`
5. Phase 4 executes:
   - Existing PR check → none found
   - PR info collected (branch, commits, diff stat, issue)
   - PR title/body auto-generated (no AskUserQuestion)
   - `gh pr create` executed
   - PR URL printed

**Verify**:
- [ ] AskUserQuestion called exactly **2 times** (Pass/Fix + Continue/New branch)
- [ ] Review happens **before** commit
- [ ] Branch ensure happens **after review**, **before commit**
- [ ] Commit message follows `<gitmoji> <type>(<scope>): <subject>` format
- [ ] PR body includes Summary, Changes, Test Plan sections
- [ ] No Phase 0 prerequisite check (no `gh --version` / `gh auth status`)

---

## Scenario 2: Already committed — no uncommitted changes

**Given**: `feat/update-api` branch, all changes committed, 2 commits ahead of origin
**When**: `/git:pr create`
**Then**:
1. Phase 1 skipped: `git status --porcelain` empty → unpushed exist → skip to Phase 3
2. Guard skipped: Phase 1 스킵 시 브랜치 ensure도 스킵 (이미 피처 브랜치)
3. Phase 2 skipped: no new commit needed
4. Phase 3 executes: push 2 commits
5. Phase 4 executes: PR created from existing commits

**Verify**:
- [ ] No AskUserQuestion at all
- [ ] No pr-reviewer invocation
- [ ] Phase 3 push includes all unpushed commits
- [ ] PR title derived from branch name (multiple commits)

---

## Scenario 3: Review → "Fix" → GC loop

**Given**: `fix/null-check` branch, staged changes with issues (score < 80)
**When**: `/git:pr create`, user selects "Fix"
**Then**:
1. Phase 1 iteration 1:
   - Auto-stage → review → score 65 (REVISE)
   - AskUserQuestion: "Pass" / "Fix"
   - User selects "Fix"
2. Interactive code modification:
   - Review feedback displayed for user reference
   - User and Claude fix code collaboratively (Edit/Read tools)
   - When fixes confirmed: `git add -A` re-stages, iteration counter increments
3. Phase 1 iteration 2:
   - Re-collect diff (Step 1.2)
   - Re-review with updated diff + previous review JSON
   - Score 85 (PASS)
   - Display "Review passed (85/100)"
4. Phase 2-4: commit → push → PR (normal flow)

**Verify**:
- [ ] AskUserQuestion called exactly **1 time** per iteration (Pass/Fix)
- [ ] Re-review uses updated `git diff --cached`
- [ ] Previous review context passed to reviewer on iteration 2+
- [ ] GC loop max 3 iterations enforced
- [ ] After max iterations: auto-proceed to Phase 2 with warning

---

## Scenario 4: Review → "Pass" → auto-commit

**Given**: `refactor/cleanup` branch, staged changes, review score 90 (PASS)
**When**: `/git:pr create`, review passes automatically
**Then**:
1. Phase 1: auto-stage → review → PASS (90/100) → no review AskUserQuestion needed
2. Guard: Branch Ensure → `refactor/cleanup` → AskUserQuestion: "Continue on `refactor/cleanup`?" / "New branch" → "Continue"
3. Phase 2: auto-commit (lint → message → commit)
4. Phase 3: push
5. Phase 4: PR created

**Verify**:
- [ ] PASS verdict skips review AskUserQuestion
- [ ] Branch ensure AskUserQuestion 1회 (Continue/New branch)
- [ ] Commit message auto-generated without confirmation
- [ ] Total AskUserQuestion count: **1** (branch ensure only)

---

## Scenario 5: gh CLI not installed / not authenticated

**Given**: `feat/new-feature` branch, gh CLI not installed or not authenticated
**When**: `/git:pr create`
**Then**:
1. Phase 1-2: normal flow (staging → review → commit)
2. Phase 3: `git push` succeeds (git push doesn't need gh)
3. Phase 4: `gh pr create` fails
   - Error detected: gh CLI missing or auth failure
   - Fallback message displayed:
     - Missing: "gh CLI required. Install: `brew install gh`"
     - Not authenticated: "Run `gh auth login` first"
   - No crash, graceful exit

**Verify**:
- [ ] No Phase 0 pre-check (no upfront `gh --version` / `gh auth status`)
- [ ] Failure occurs at Phase 4, not earlier
- [ ] Commit and push still succeed even without gh
- [ ] Clear fallback instruction provided

---

## Scenario 6: Mixed — committed + uncommitted changes

**Given**: `feat/dashboard` branch, 1 commit ahead of origin + additional unstaged changes
**When**: `/git:pr create`
**Then**:
1. Phase 1 executes:
   - `git status --porcelain` detects uncommitted changes
   - `git add -A` auto-stages
   - Review diff includes: `git diff --cached` (uncommitted) + `git diff origin/<base>..HEAD` (committed)
   - pr-reviewer reviews full scope
2. Phase 2: new commit for staged changes
3. Phase 3: push all commits (previous + new)
4. Phase 4: PR covers all commits

**Verify**:
- [ ] Review covers both committed and uncommitted changes
- [ ] Only uncommitted changes are in the new commit
- [ ] PR includes all commits since base branch divergence

---

## Scenario 7: review mode unchanged

**Given**: `feat/existing` branch, PR #42 already exists
**When**: `/git:pr review 42`
**Then**:
1. review mode Phase 1-4 executes as v1.0.0
2. pr-reviewer invoked in Mode B (Markdown output)
3. Review feedback displayed
4. AskUserQuestion: "Post review comment to PR?" / "Skip" (preserved from v1.0.0)

**Verify**:
- [ ] review mode logic preserved from v1.0.0
- [ ] Mode B output format unchanged
- [ ] AskUserQuestion for comment posting retained
- [ ] No interference from create mode changes

---

## Scenario 8: main/master → 리뷰 후 자동 브랜치 생성

**Given**: `main` branch, `src/auth/login.ts` + `src/auth/oauth.ts` 파일 변경
**When**: `/git:pr create`
**Then**:
1. Phase 1 실행 (main에서도 정상 동작):
   - `git add -A` auto-stage
   - Sensitive file check
   - pr-reviewer invoked → score 85 (PASS)
   - "Review passed (85/100)" 출력
2. Guard: Branch Ensure (리뷰 통과 후, 커밋 전):
   - `git rev-parse --abbrev-ref HEAD` → `main` 감지
   - `git stash push` → `git pull origin main` → `git stash pop`
   - Auto Branch Creation:
     - `git diff --cached --name-only` → `src/auth/login.ts`, `src/auth/oauth.ts`
     - gitmoji-convention diff pattern → `src/**` new files → `feat`
     - 공통 부모 디렉토리: `auth` → description: `auth`
     - Branch name: `feat/auth`
     - `git checkout -b feat/auth`
     - "Branch created: `feat/auth`"
   - AskUserQuestion 없음 (main/master는 자동)
3. Phase 2: commit on `feat/auth`
4. Phase 3: push `feat/auth`
5. Phase 4: PR created

**Verify**:
- [ ] 리뷰가 main에서도 정상 실행
- [ ] 리뷰 통과 후 브랜치 자동 생성 (AskUserQuestion 없음)
- [ ] 커밋은 새 피처 브랜치 `feat/auth`에서 실행
- [ ] 스테이징된 변경이 `checkout -b` 후에도 유지
- [ ] gitmoji-convention diff pattern으로 type 추론

---

## Scenario 9: Sensitive files auto-unstaged

**Given**: `feat/api-keys` branch, `.env.local` and `credentials.json` in working tree
**When**: `/git:pr create`
**Then**:
1. Phase 1 Step 1.1: `git add -A` stages everything including sensitive files
2. Step 1.1b: sensitive file check detects `.env.local`, `credentials.json`
3. Auto-unstage: `git reset HEAD .env.local credentials.json`
4. Print warning with file list + "Add to .gitignore if unintentional."
5. Review proceeds with remaining staged files only

**Verify**:
- [ ] Sensitive files auto-unstaged (no AskUserQuestion)
- [ ] Warning message displayed
- [ ] Review does NOT include sensitive files
- [ ] Remaining files still staged and reviewed

---

## Scenario 10: PR already exists for branch

**Given**: `feat/existing-pr` branch, PR #99 already exists, no uncommitted changes, no unpushed commits
**When**: `/git:pr create`
**Then**:
1. Step 1.0: `git status --porcelain` empty → no unpushed → check existing PR
2. `gh pr view` returns PR URL
3. Print: existing PR URL
4. **exit**

**Verify**:
- [ ] No duplicate PR creation attempted
- [ ] Existing PR URL displayed
- [ ] Graceful exit

---

## Scenario 11: 피처 브랜치에서 New branch 선택

**Given**: `feat/old-feature` branch, `docs/guide.md` + `docs/api.md` 파일 변경
**When**: `/git:pr create` → 리뷰 통과 → AskUserQuestion에서 "New branch" 선택
**Then**:
1. Phase 1 실행:
   - `git add -A` auto-stage
   - pr-reviewer invoked → score 82 (PASS)
   - "Review passed (82/100)" 출력
2. Guard: Branch Ensure (리뷰 통과 후, 커밋 전):
   - `git rev-parse --abbrev-ref HEAD` → `feat/old-feature` (피처 브랜치)
   - AskUserQuestion: "Continue on `feat/old-feature`?" / "New branch"
   - 사용자 "New branch" 선택
   - `git stash push` → base branch checkout + pull → `git stash pop`
   - Auto Branch Creation:
     - `git diff --cached --name-only` → `docs/guide.md`, `docs/api.md`
     - gitmoji-convention diff pattern → `*.md` → `docs`
     - 공통 부모 디렉토리: `docs` → description: `docs`
     - Branch name: `docs/docs`
     - 중복 시 description 재조정 (e.g. `docs/update`)
     - `git checkout -b docs/update`
     - "Branch created: `docs/update`"
3. Phase 2: commit on `docs/update`
4. Phase 3: push `docs/update`
5. Phase 4: PR created

**Verify**:
- [ ] 스테이징된 변경이 새 브랜치로 이동
- [ ] AskUserQuestion 1회 (Continue/New branch)
- [ ] gitmoji-convention diff pattern으로 type 추론 (`docs`)
- [ ] type과 description 중복 시 description 재조정

---

## Acceptance Criteria (global)

| Metric | v1.0.0 | v1.1.0 Target |
|--------|--------|---------------|
| AskUserQuestion (create, happy path PASS, main) | 4+ | **0** (auto-branch, no AskUserQ) |
| AskUserQuestion (create, happy path PASS, feature) | 4+ | **1** (Continue/New branch) |
| AskUserQuestion (create, happy path REVISE/FAIL) | 4+ | **2** (Pass/Fix + Continue/New branch) |
| AskUserQuestion (create, fix loop) | 6+ | 1 per review iter + 1 branch ensure |
| Pre-commit review | Yes (GC max 3) | Yes (GC max 3) |
| Phase 0 pre-check | Yes | No (lazy fallback) |
| Branch ensure (post-review) | No | Yes (auto-branch from main, AskUserQ on feature) |
| Sensitive file protection | No | Yes (auto-unstage) |
| PR duplicate check | No | Yes (existing PR detection) |
| review mode changes | N/A | Preserved (AskUserQuestion for comment posting retained) |
