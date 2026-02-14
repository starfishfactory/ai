---
description: Branch create/switch/cleanup/ensure
allowed-tools: Bash, AskUserQuestion, Read, Glob
argument-hint: "<create|switch|cleanup|ensure> [options]"
---
# Branch: $ARGUMENTS
## Arg Parse
First word of `$ARGUMENTS`:
- `create` / `switch` / `cleanup` / `ensure` → that mode
- Empty → AskUserQuestion to select
## create
1. AskUserQuestion: type (feat/fix/chore/docs/refactor/test)
2. AskUserQuestion: issue number (optional, skip if none)
3. AskUserQuestion: description (e.g. "add user login")
4. kebab-case desc → `<type>/<issue>-<desc>` or `<type>/<desc>`
   `git checkout -b <branch>` → fail: error+exit / ok: print name
## switch
1. `git branch --format='%(refname:short)'` → list (exclude current)
2. `git status --porcelain` → changes? AskUserQuestion stash? → yes: `git stash push -m "auto-stash by git plugin"`
3. AskUserQuestion: select branch
4. `git checkout <branch>` → fail: error (if stashed, advise `git stash pop`)+exit / ok: print
## cleanup
1. `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'` → base. Fail → `main`
2. `git branch --merged <base>` → merged list. Exclude base/develop/current
3. `git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:unix)'` → stale if `committerdate:unix < $(date -v-30d +%s)`. Dedup: merged stays merged
4. AskUserQuestion: [merged]/[stale] candidates
5. `git branch -d <branch>` loop (user-approved only). Fail(unmerged) → warn+skip. Print deleted count
## ensure
Ensure feature branch. Called by pr.md post-review, pre-commit.
Preserve staged changes across all branch ops.
### Step 1
`git rev-parse --abbrev-ref HEAD` → current branch
### Step 2: Routing
**Case A (main/master)**:
1. `git stash push -m "ensure-auto-stash"`
2. `git pull origin <current>`
3. `git stash pop` → conflict: error+exit
4. → Step 3 (no AskUserQuestion)

**Case B (feature)**:
1. AskUserQuestion: "Continue on `<branch>`?" / "New branch"
2. Continue → **done**
3. New branch →
   - Base: `git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||'` → fallback `main`
   - `git stash push` → `git checkout <base>` + `git pull origin <base>` → `git stash pop` → conflict: error+exit
   - → Step 3
### Step 3: Auto Branch Creation
Read `skills/gitmoji-convention/SKILL.md`.
1. `git diff --cached --name-only` → match gitmoji-convention diff patterns → type. No match → `feat`
2. Common parent dir of staged files → kebab-case → description
3. Name: `<type>/<desc>`. If type==desc → `<type>/update`
4. `git checkout -b <branch>` → fail: error+exit / ok: print "Branch created: `<branch>`"
