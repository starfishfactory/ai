---
description: Branch create/switch/cleanup
allowed-tools: Bash, AskUserQuestion
argument-hint: "<create|switch|cleanup> [options]"
---
# Branch Management: $ARGUMENTS
## Argument Parsing
Determine mode from first word of `$ARGUMENTS`:
- `create` → create mode
- `switch` → switch mode
- `cleanup` → cleanup mode
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
