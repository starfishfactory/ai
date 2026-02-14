---
description: Automated PR creation with pre-commit review and code review
allowed-tools: Read, Bash, Task, AskUserQuestion, Glob, Edit
argument-hint: "[create|review [PR_number]]"
---
# PR: $ARGUMENTS
## Arg Parse
- Empty / `create` → **create mode**
- `review` → **review mode** (auto-detect PR)
- `review <N>` → **review mode** (PR #N)

## create Mode

### Phase 1: Staging + Review (GC Loop, max 3)

#### 1.0 Check changes
`git status --porcelain` → empty:
- `git rev-list --count @{u}..HEAD 2>/dev/null` → unpushed? → **skip to Phase 3**
- No unpushed → `gh pr view --json url --jq '.url' 2>/dev/null` → exists: print URL+exit. None: "Nothing to do."+exit

#### 1.1 Auto-stage
`git add -A`. Print "Staged all changes."

#### 1.1b Sensitive file check
`git diff --cached --name-only` → scan **filenames only** for: `.env*`, `*.key`, `*.pem`, `credentials*`, `*secret*`, `*.p12`, `*.pfx`
Match → `git reset HEAD <file>` each + warn. Print "Unstaged N sensitive file(s)."

#### 1.2 Collect diff
Parallel:
- `git diff --cached` → staged diff
- `git diff --cached --stat` → stats
- `git rev-parse --abbrev-ref HEAD` → branch
- Base: `git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||'` → fallback `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'` → fallback `main`

If `git rev-list --count origin/<base>..HEAD` > 0:
- Also `git diff origin/<base>..HEAD` → combine for full-scope review
- Print "Review includes N prior commit(s) + staged."

N = 1.

#### Iteration N (1..3):

##### 1.N.1 Invoke pr-reviewer (Mode A)
1. Read `agents/pr-reviewer.md`
2. Task(general-purpose): system=pr-reviewer.md, directive="PRE-COMMIT Mode A, JSON only", context=branch+stats+N, input=diff (N>1: +prev JSON)

##### 1.N.2 Verdict
Parse JSON → score + verdict:
- **PASS (>=80)**: Print "Review passed (score/100)" + good_practices → **Guard**
- **REVISE/FAIL**: Show score+breakdown+feedback. AskUserQuestion: "Pass"/"Fix"
  - Pass → **Guard**
  - Fix → show feedback → user fixes with Edit/Read → confirms done → `git add -A` → N++ → back to 1.2

##### After 3 iterations
Print score+issues → **Guard** with warning "Proceeding after 3 iterations (score: N/100)."

### Guard: Branch Ensure (post-review, pre-commit)
Read `commands/branch.md` → execute **ensure mode**.
Ensures commit on feature branch. Staged changes preserved across `checkout -b`.

### Phase 2: Auto-Commit
Read `skills/smart-commit/SKILL.md` + `skills/gitmoji-convention/SKILL.md`.
Execute smart-commit Steps 2-4 only (Step 1 done in Phase 1). **No AskUserQuestion** for message.

#### 2.1 Lint
`package.json` has `scripts.lint` → `npm run lint`. `Makefile` has `lint` → `make lint`. Neither → skip. Fail → exit.

#### 2.2 Message gen
1. Type: gitmoji-convention (branch name post-ensure → diff pattern). Ambiguous → branch type
2. Gitmoji: type → emoji
3. Scope: common parent dir (optional)
4. Subject: imperative, max 50 chars
5. Body: list changes if 3+ files
6. Format: `<gitmoji> <type>(<scope>): <subject>`

#### 2.3 Commit
```
git commit -m "$(cat <<'EOF'
<gitmoji> <type>(<scope>): <subject>

<body>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```
Fail → error+exit. Ok → `git log -1 --oneline`

### Phase 3: Push
`git rev-list --count @{u}..HEAD 2>/dev/null || echo "no-upstream"` → unpushed/no-upstream: `git push -u origin $(git rev-parse --abbrev-ref HEAD)`
Reject(non-ff) → "Run `git pull --rebase`"+exit. Other → error+exit.

### Phase 4: PR Creation

#### 4.0 Existing PR check
`gh pr view --json number,url 2>/dev/null` → exists: print URL+exit

#### 4.1 Collect metadata (parallel)
- Branch: `git rev-parse --abbrev-ref HEAD`
- Base: `git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||'` → fallback `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'` → `main`
- `git log origin/<base>..HEAD --oneline`
- `git diff origin/<base>..HEAD --stat`
- Branch regex `/(\d+)-/` → issue# → `gh issue view <N> --json title,body` (fail → ignore)

#### 4.2 Title
1 commit → subject (no gitmoji, max 70). Multiple → branch name → kebab-to-space, capitalize.

#### 4.3 Body
Read `skills/pr-template/SKILL.md`. Detect project template → found: fill per skill mapping / not: built-in.
Auto-fill: Summary, Changes (top 5), Test Plan, Related Issue (`Closes #N`), Breaking Changes.
Footer: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`
No AskUserQuestion.

#### 4.4 Create
```bash
gh pr create --base <base> --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```
Ok → print URL. Fail: `gh: command not found` → "Install: `brew install gh`" / `not logged`|`auth` → "`gh auth login`" / other → error + "Try `gh pr create --web`"

---

## review Mode

### Phase 1: Identify PR
`$ARGUMENTS` has number → use it. Else `gh pr view --json number --jq '.number'`. Fail → "No PR found."+exit

### Phase 2: Collect
`gh pr view <N> --json title,body,files,additions,deletions` + `gh pr diff <N>`

### Phase 3: pr-reviewer (Mode B)
1. Read `agents/pr-reviewer.md`
2. Task(general-purpose): system=pr-reviewer.md, directive="PR review Mode B, Markdown", context=PR metadata, input=diff

### Phase 4: Output
Display feedback. AskUserQuestion: "Post comment?"/"Skip"
Post → `gh pr comment <N> --body "<markdown>"` / Skip → end
