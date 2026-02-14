---
description: Automated PR creation with pre-commit review and code review
allowed-tools: Read, Bash, Task, AskUserQuestion, Glob, Edit
argument-hint: "[create|review [PR_number]]"
---
# PR: $ARGUMENTS

## Argument Parsing
Parse `$ARGUMENTS`:
- Empty or `create` → **create mode**
- `review` → **review mode** (auto-detect current branch PR)
- `review <number>` → **review mode** (specified PR number)

## create Mode

### Phase 1: Staging + Pre-Commit Review (GC Loop, max 3 iterations)

#### Step 1.0: Check for changes
`git status --porcelain` → no output → check unpushed: `git rev-list --count @{u}..HEAD 2>/dev/null`
- Unpushed exist → **skip to Phase 3**
- No unpushed → check if PR already exists: `gh pr view --json url --jq '.url' 2>/dev/null` → exists → print PR URL → **exit**. Not exists → "No changes and no PR. Nothing to do." → **exit**

#### Step 1.1: Auto-staging
- `git add -A` — stage all changes automatically
- Print: "Staged all changes for review."

#### Step 1.1b: Sensitive file check
- `git diff --cached --name-only` → scan **filenames only** (not directory paths) for patterns: `.env*`, `*.key`, `*.pem`, `credentials*`, `*secret*`, `*.p12`, `*.pfx`
- If matched → print warning with file list → `git reset HEAD <file>` for each sensitive file → print: "Unstaged N sensitive file(s). Add to .gitignore if unintentional."

#### Step 1.2: Collect review target diff
Parallel:
- `git diff --cached` → staged diff (primary review target)
- `git diff --cached --stat` → change statistics
- `git rev-parse --abbrev-ref HEAD` → current branch
- Base branch detection: `git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||'` → fallback: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null` → fallback: `main`

If commits already ahead of base (`git rev-list --count origin/<base>..HEAD 2>/dev/null` > 0):
- Also collect: `git diff origin/<base>..HEAD` → combine with staged diff for full-scope review
- Print: "Review includes N prior commit(s) + staged changes."

Set iteration counter: N = 1.

#### Iteration N (N = 1, 2, 3):

##### Step 1.N.1: Invoke pr-reviewer (Mode A)
1. Read `agents/pr-reviewer.md`
2. Task(subagent_type: `general-purpose`):
   - System prompt: pr-reviewer.md content
   - Directive: "PRE-COMMIT review (Mode A). Output JSON only."
   - Context: branch name, diff stats, iteration N
   - Input N=1: full diff | N>1: full diff + previous review JSON
   - Request: "Evaluate changes per Mode A. Output JSON."

##### Step 1.N.2: Verdict handling
Parse JSON → `score` + `verdict`:

- **PASS (>= 80)**:
  Print: "Review passed (score/100)" + good_practices summary.
  → **Guard: Branch Ensure** (no AskUserQuestion)

- **REVISE (60-79)** or **FAIL (< 60)**:
  Display: score, category breakdown, feedback items (Critical first → Important → Nice-to-have).
  AskUserQuestion: "Pass" / "Fix"
  - **"Pass"** → **Guard: Branch Ensure**
  - **"Fix"** →
    1. Display feedback items for user reference
    2. User and Claude fix code collaboratively (normal conversation using Edit/Read tools)
    3. When user explicitly confirms fixes are done (e.g., "done", "ready", "re-review"):
       - `git add -A` re-stage all changes
       - Increment iteration counter: N = N + 1
       - Go to **Step 1.2** (re-collect diff) → continue to **Step 1.N.1** (re-invoke reviewer)

##### After 3 iterations without PASS
Print last score + remaining issues.
→ Auto-proceed to **Guard: Branch Ensure** with warning: "Proceeding after 3 review iterations (score: N/100)."

### Guard: Branch Ensure (post-review, pre-commit)
Read `commands/branch.md`. Execute **ensure mode**.
This ensures commit happens on a feature branch, not main/master.
Staged changes are preserved across `git checkout -b`.

### Phase 2: Auto-Commit

Read `skills/smart-commit/SKILL.md` + `skills/gitmoji-convention/SKILL.md`.
Execute smart-commit **Steps 2-4 only** (Step 1 staging already completed in Phase 1).
**Override for Step 3**: Skip AskUserQuestion for message confirmation — generate and commit without user review.

#### Step 2.1: Lint (smart-commit Step 2)
- `package.json` has `scripts.lint` → `npm run lint`
- `Makefile` has `lint` target → `make lint`
- Neither → skip
- Failure → "Fix lint errors and retry." → **exit**

#### Step 2.2: Commit message generation (smart-commit Step 3, no AskUserQuestion)
1. **Type**: gitmoji-convention priority (current branch name post-ensure → diff pattern). If ambiguous → use branch type.
2. **Gitmoji**: map type → emoji
3. **Scope**: common parent directory of changed files (optional)
4. **Subject**: imperative summary, max 50 chars
5. **Body**: list major changes when 3+ files changed
6. **Format**: `<gitmoji> <type>(<scope>): <subject>`
- Print generated message — **no AskUserQuestion** (override smart-commit Step 3)

#### Step 2.3: Commit execution (smart-commit Step 4)
```
git commit -m "$(cat <<'EOF'
<gitmoji> <type>(<scope>): <subject>

<body>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```
- Failure → show error → **exit**
- Success → `git log -1 --oneline` to display result

### Phase 3: Push
- `git rev-list --count @{u}..HEAD 2>/dev/null || echo "no-upstream"` → check unpushed
- Unpushed or no-upstream → `git push -u origin $(git rev-parse --abbrev-ref HEAD)`
- Push failure:
  - Rejection (non-fast-forward) → "Run `git pull --rebase` and retry." → **exit**
  - Other → show error → **exit**

### Phase 4: PR Creation

#### Step 4.0: Check existing PR
- `gh pr view --json number,url 2>/dev/null` → if PR exists → print "PR already exists: <url>" → **exit**

#### Step 4.1: Collect PR metadata (parallel)
- `git rev-parse --abbrev-ref HEAD` → current branch
- Base branch: `git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||'` → fallback: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null` → fallback: `main`
- `git log origin/<base>..HEAD --oneline` → commit history
- `git diff origin/<base>..HEAD --stat` → diff statistics
- Branch regex `/(\d+)-/` → issue number → `gh issue view <number> --json title,body` (failure → ignore)

#### Step 4.2: PR title
- 1 commit → commit subject (remove gitmoji, max 70 chars)
- Multiple commits → branch name → kebab-to-space + capitalize first letter (max 70 chars)

#### Step 4.3: PR body generation
Read `skills/pr-template/SKILL.md`.

Detect project PR template (search order per pr-template skill):
- Found → auto-fill matching sections per skill mapping
- Not found → use built-in template

Auto-fill: Summary (commit history), Changes (diff stat top 5), Test Plan (test file detection), Related Issue (`Closes #N`), Breaking Changes.
Append footer: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`

Print generated title + body — **no AskUserQuestion**

#### Step 4.4: Create PR
```bash
gh pr create --base <base> --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```
- Success → print PR URL
- Failure → detect cause:
  - `gh: command not found` → "gh CLI required. Install: `brew install gh`"
  - `not logged` / `auth` → "Run `gh auth login` first."
  - Other → show error + "Try `gh pr create --web` for browser-based creation."

---

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
- AskUserQuestion: "Post review comment to PR?" / "Skip"
  - Post → `gh pr comment <number> --body "<review markdown>"`
  - Skip → end
