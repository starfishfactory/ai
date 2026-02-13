---
description: Automated PR creation and code review
allowed-tools: Read, Bash, Task, AskUserQuestion, Glob
argument-hint: "[create|review [PR_number]]"
---
# PR: $ARGUMENTS
## Argument Parsing
Parse `$ARGUMENTS`:
- Empty or `create` → **create mode**
- `review` → **review mode** (auto-detect current branch PR)
- `review <number>` → **review mode** (use specified PR number)
## Common Phase 0: Prerequisites
### Step 0.1: Verify gh CLI
Run `gh --version` → if missing, print "gh CLI required. Install: `brew install gh`" and **exit**.
### Step 0.2: Verify Authentication
Run `gh auth status` → if not authenticated, print "Run `gh auth login` first" and **exit**.
## create Mode
### Phase 1: Handle Uncommitted Changes
`git status --porcelain` → if changes exist:
1. Print "Uncommitted changes detected. Committing first."
2. Read skill files:
   - `skills/smart-commit/SKILL.md`
   - `skills/gitmoji-convention/SKILL.md`
3. Execute smart-commit skill's Step 1~4 (Staging → Lint → Message Generation → Commit)
4. **Lint failure** → print "Fix lint errors and retry" and **exit** (abort PR creation)
5. After commit, proceed to next Phase
### Phase 2: Push
- `git rev-list --count @{u}..HEAD 2>/dev/null || echo "no-upstream"` → check unpushed commits or no upstream
- If unpushed → `git push -u origin $(git rev-parse --abbrev-ref HEAD)`
- **Failure** → print "Push failed. Run `git pull --rebase` and retry" and **exit**
### Phase 3: Collect PR Info
Gather in parallel:
- `git rev-parse --abbrev-ref HEAD` → current branch
- `git rev-parse --abbrev-ref origin/HEAD | sed 's|origin/||'` → base branch
- `git log origin/<base>..HEAD --oneline` → commit history
- `git diff origin/<base>..HEAD --stat` → change stats
- Extract issue number from branch name (regex: `/(\d+)-/`)
- If issue number found → `gh issue view <number> --json title,body` (ignore failure)
### Phase 4: Generate PR Body
1. Read `skills/pr-template/SKILL.md`
2. **PR title**:
   - 1 commit → use commit message (remove gitmoji, max 70 chars)
   - Multiple commits → generate from branch name
3. **PR body** (apply pr-template skill template):
   - **Summary**: commit history-based summary
   - **Changes**: diff stat-based key changed files
   - **Test Plan**: auto-fill based on test file additions/modifications
   - **Related Issue**: `Closes #<issue_number>` (if available)
4. AskUserQuestion to confirm/edit title + body
### Phase 5: Create PR
- Run `gh pr create --title "..." --body "..."` (use HEREDOC)
- **Failure** → show error (e.g. "PR already exists") + advise `gh pr view --web`
- **Success** → print PR URL
### Phase 6: Link Review
- AskUserQuestion: "Run PR review now?"
- If approved → execute review mode Phase 1~4 below (using created PR number)
## review Mode
### Phase 1: Identify PR
- If `$ARGUMENTS` has PR number → use it
- Otherwise → `gh pr view --json number --jq '.number'` → auto-detect current branch PR
- **Failure** → print "No PR found for current branch. Specify a PR number." and **exit**
### Phase 2: Collect PR Info + Diff
- `gh pr view <number> --json title,body,files,additions,deletions`
- `gh pr diff <number>`
### Phase 3: Invoke pr-reviewer Agent
1. Read `agents/pr-reviewer.md` → load agent prompt
2. Call Task(subagent_type: `general-purpose`):
   - **System prompt**: full `agents/pr-reviewer.md` content (role/process/output format/principles)
   - **Context section**: PR metadata (title, body, files, additions, deletions)
   - **Analysis target**: full `gh pr diff` output
   - **Request**: "Analyze this PR per the review process and produce feedback in the specified output format"
### Phase 4: Output Results
- Format and display agent review feedback
- AskUserQuestion: "Post review comment to PR?"
- If approved → run `gh pr comment <number> --body "..."`
