---
name: pr
description: Automated PR creation with pre-commit review and code review
context: fork
allowed-tools: Read, Bash, Task, AskUserQuestion, Glob
argument-hint: "[create|review [PR_number]]"
---
# PR: $ARGUMENTS

## Argument Parsing
Parse `$ARGUMENTS`:
- Empty or `create` → **create mode**
- `review` → **review mode** (auto-detect current branch PR)
- `review <number>` → **review mode** (specified PR number)

## Common Phase 0: Prerequisites
- `gh --version` → missing → "gh CLI required. Install: `brew install gh`" → **exit**
- `gh auth status` → not authenticated → "Run `gh auth login` first" → **exit**

## create Mode

### Phase 1: Pre-Commit Review (GC Loop, max 3 iterations)

#### Step 1.0: Check for changes
`git status --porcelain` → no changes → `git rev-list --count @{u}..HEAD 2>/dev/null` → no unpushed → **skip to Phase 4**. Unpushed exist → **skip to Phase 3**.

#### Step 1.1: Staging
Read `skills/smart-commit/SKILL.md` + `skills/gitmoji-convention/SKILL.md`.
smart-commit Step 1 (Staging) + extended:
- Check: `git diff --cached --name-only` (staged) + `git diff --name-only` (unstaged) + `git ls-files --others --exclude-standard` (untracked)
- Untracked exist → include in staging prompt
- AskUserQuestion: "Stage all" / "Select files" / "Stage tracked only" → execute

#### Step 1.1.5: Lint
Read `skills/smart-commit/SKILL.md`. Execute smart-commit Step 2 (Lint). Failure → **exit**.

#### Step 1.2: Collect staged diff
Parallel: `git diff --cached` (review target) + `git diff --cached --stat` (stats) + `git rev-parse --abbrev-ref HEAD` (branch)

#### Iteration N (N = 1, 2, 3):

##### Step 1.N.3: Invoke pr-reviewer (Mode A)
1. Read `agents/pr-reviewer.md`
2. Task(subagent_type: `general-purpose`):
   - System prompt: pr-reviewer.md content
   - Directive: "PRE-COMMIT review (Mode A). Output JSON only."
   - Context: branch, diff stats, iteration N
   - Input N=1: `git diff --cached` | N>1: + previous review JSON
   - Request: "Evaluate staged changes per Mode A. Output JSON."

##### Step 1.N.4: Verdict
Parse JSON → `score` + `verdict`:
- **PASS (>= 80)**: Show score + good_practices → "Review passed (score/100)" → Phase 2
- **REVISE (60-79)**: Show feedback. AskUserQuestion: "Fix and re-review (Recommended)" / "Proceed anyway" / "Cancel"
  - Fix → display feedback → AskUserQuestion "Ready?" → re-stage → if diff unchanged, warn + AskUserQuestion "Re-review anyway" / "Proceed to commit" / "Cancel" → next iteration
- **FAIL (< 60)**: Show all feedback (critical first). AskUserQuestion: "Fix and re-review" / "Proceed (not recommended)" / "Cancel"
  - Fix → same flow as REVISE → next iteration

##### After 3 iterations without PASS
Print last score + residual issues. AskUserQuestion: "Proceed with known issues" / "Cancel".
Pass to Phase 2: last review score + iteration count.

### Phase 2: Commit
smart-commit Step 2~4 (Lint → Message → Commit):
- Step 2: `npm run lint` or `make lint` → failure → "Fix lint errors and retry" → **exit**
- Step 3: gitmoji-convention type → subject/body generation
- Step 4: HEREDOC commit + Co-Authored-By

### Phase 3: Push
- `git rev-list --count @{u}..HEAD 2>/dev/null || echo "no-upstream"` → check unpushed
- Unpushed → `git push -u origin $(git rev-parse --abbrev-ref HEAD)`
- Failure → "Push failed. Run `git pull --rebase` and retry" → **exit**

### Phase 4: Collect PR Info
Parallel: current branch + base branch (from `origin/HEAD`) + `git log origin/<base>..HEAD --oneline` + `git diff origin/<base>..HEAD --stat`.
Branch regex `/(\d+)-/` → issue number → `gh issue view <number> --json title,body` (ignore failure).

### Phase 5: Generate PR Body

#### Step 5.1: Detect Project PR Template
Repo root → search priority: `.github/PULL_REQUEST_TEMPLATE.md` → `.github/pull_request_template.md` → `PULL_REQUEST_TEMPLATE.md` → `pull_request_template.md` → `docs/PULL_REQUEST_TEMPLATE.md` → first match wins.
None → `.github/PULL_REQUEST_TEMPLATE/` dir (1→auto, 2+→AskUserQuestion). Nothing → `skills/pr-template/SKILL.md` built-in.

#### Step 5.2: Generate PR body
- Template found → fill per pr-template skill mapping (case-insensitive header match)
- No template → pr-template skill flow

#### Step 5.3: PR title
1 commit → commit message (remove gitmoji, max 70 chars). Multiple → generate from branch name.

#### Step 5.4: AskUserQuestion to confirm/edit title + body

### Phase 6: Create PR
- `gh pr create --title "..." --body "..."` (HEREDOC)
- Failure → show error + advise `gh pr view --web`
- Success → print PR URL + AskUserQuestion "Run PR review now?" → approved → execute review mode (using created PR number)

## review Mode

### Phase 1: Identify PR
- `$ARGUMENTS` has number → use it
- Otherwise → `gh pr view --json number --jq '.number'`
- Failure → "No PR found. Specify PR number." → **exit**

### Phase 2: Collect PR Info + Diff
`gh pr view <number> --json title,body,files,additions,deletions` + `gh pr diff <number>`

### Phase 3: Invoke pr-reviewer Agent
1. Read `agents/pr-reviewer.md`
2. Task(subagent_type: `general-purpose`):
   - System prompt: pr-reviewer.md content
   - Directive: "PR review (Mode B). Output Markdown."
   - Context: PR metadata (title, body, files, additions, deletions)
   - Input: `gh pr diff` output
   - Request: "Analyze per Mode B. Produce Markdown feedback."

### Phase 4: Output Results
- Display review feedback
- AskUserQuestion: "Post review comment to PR?"
- Approved → `gh pr comment <number> --body "..."`
