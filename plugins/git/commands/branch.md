---
description: Branch create/switch/cleanup/ensure
allowed-tools: Bash, AskUserQuestion, Read, Glob
argument-hint: "<create|switch|cleanup|ensure> [options]"
---
# Branch Management: $ARGUMENTS
## Argument Parsing
Determine mode from first word of `$ARGUMENTS`:
- `create` → create mode
- `switch` → switch mode
- `cleanup` → cleanup mode
- `ensure` → ensure mode
- Empty → AskUserQuestion to select mode
## create Mode
### Step 1: Select Type
AskUserQuestion to choose branch type: feat / fix / chore / docs / refactor / test
### Step 2: Issue Number (Optional)
AskUserQuestion for issue number. Skip if none.
### Step 3: Branch Description
AskUserQuestion for branch description (e.g. "add user login").
### Step 4: Create Branch
- Convert description to kebab-case
- Generate branch name: `<type>/<issue>-<desc>` or `<type>/<desc>` (no issue)
- Run `git checkout -b <branch>`
- **Failure** → show error (e.g. "Branch already exists") and **exit**
- **Success** → print "Branch created: `<branch>`"
## switch Mode
### Step 1: List Branches
`git branch --format='%(refname:short)'` → list branches excluding current.
### Step 2: Check Uncommitted Changes
`git status --porcelain` → if changes exist:
- AskUserQuestion: "Uncommitted changes detected. Stash them?"
- Yes → `git stash push -m "auto-stash by git plugin"`
### Step 3: Select Branch
AskUserQuestion to choose target branch.
### Step 4: Switch Branch
- Run `git checkout <branch>`
- **Failure** → show error + if stashed, advise "Run `git stash pop` to restore changes" and **exit**
- **Success** → print "Switched to branch: `<branch>`"
## cleanup Mode
### Step 1: Detect Base Branch
`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'` → base branch (main or master).
Failure → default to `main`.
### Step 2: Detect Merged Branches
`git branch --merged <base>` → list branches already merged into base.
Exclude base branch, develop, and current branch.
### Step 3: Detect Stale Branches
`git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:unix)'` → check last commit time per branch.
- Threshold: `date -v-30d +%s` (macOS) — unix timestamp 30 days ago
- `committerdate:unix < threshold` = stale
- Deduplicate: branches in merged list stay classified as merged
### Step 4: Present Deletion Candidates
AskUserQuestion with candidate list:
- **[merged]** label: branches already merged into base
- **[stale]** label: branches inactive for 30+ days
### Step 5: Execute Deletion
- Delete only user-approved branches via `git branch -d <branch>` loop
- **Deletion failure (unmerged)** → show warning + skip (do NOT force `-D`)
- Done → print count of deleted branches
## ensure Mode
Ensure current branch is a feature branch. Called by `pr.md` after review, before commit.
Staged changes must be preserved across branch operations.
### Step 1: Current Branch Detection
`git rev-parse --abbrev-ref HEAD` → current branch name.
### Step 2: Branch Routing
- **Case A — main/master**:
  1. `git stash push -m "ensure-auto-stash"` (preserve staged changes)
  2. `git pull origin <current>`
  3. `git stash pop` (restore staged changes)
  4. If stash pop conflict → show error + "Resolve conflicts and retry." → **exit**
  5. → Step 3 (Auto Branch Creation — no AskUserQuestion)
- **Case B — feature branch**:
  1. AskUserQuestion: "Continue on `<branch>`?" / "New branch"
  2. "Continue" → **done** (proceed to caller)
  3. "New branch" →
     a. Detect base branch: `git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||'` → fallback `main`
     b. `git stash push -m "ensure-auto-stash"` (preserve staged changes)
     c. `git checkout <base>` + `git pull origin <base>`
     d. `git stash pop` (restore staged changes)
     e. If stash pop conflict → show error → **exit**
     f. → Step 3 (Auto Branch Creation)
### Step 3: Auto Branch Creation
Read `skills/gitmoji-convention/SKILL.md`.
1. **Type inference**:
   - `git diff --cached --name-only` → staged file list
   - Match against gitmoji-convention diff file pattern rules → inferred type
   - No single match → default `feat`
2. **Description**:
   - Common parent directory of staged files → kebab-case
   - e.g. `src/auth/login.ts`, `src/auth/oauth.ts` → `auth`
3. **Branch name**: `<type>/<description>`
   - If type == description (e.g. `docs/docs`) → use `<type>/update` instead
4. `git checkout -b <branch>`
   - **Failure** → show error → **exit**
   - **Success** → print "Branch created: `<branch>`" → **done**
