---
description: Gitmoji + Conventional Commits smart commit
allowed-tools: Read, Bash, AskUserQuestion, Glob
argument-hint: "[commit message (optional, auto-generated if omitted)]"
---
# Smart Commit: $ARGUMENTS
## Phase 0: Context Collection
### Step 0.1: Check Changes
Run `git status --porcelain` → if no changes, print "No changes to commit" and **exit**.
### Step 0.2: Extract Branch Info
Run `git rev-parse --abbrev-ref HEAD` → extract type and issue number from branch name.
Parse rule: `<type>/<issue>-<desc>` or `<type>/<desc>`
- e.g. `feat/123-add-login` → type=feat, issue=123
- e.g. `fix/resolve-crash` → type=fix, issue=none
### Step 0.3: Load Skills
Read the following skill files for context:
- `skills/gitmoji-convention/SKILL.md`
- `skills/smart-commit/SKILL.md`
### Step 0.4: Argument Handling
If `$ARGUMENTS` provides a commit message:
- `git diff --cached --name-only` → check staged files
- If no staged → run `git add -A` (fast-commit intent, add all)
- Select appropriate gitmoji from gitmoji-convention mapping table
- Prepend gitmoji to message → **jump to Phase 4 (commit execution)**
- Format: `<gitmoji> <user message>`
- **Note**: lint is skipped (fast-commit path with user-specified message)
## Phase 1~4: Delegate to smart-commit Skill
If `$ARGUMENTS` has no message, execute smart-commit skill Steps 1~4 in order:
1. **Step 1: Staging** — check staged/unstaged → select staging method
2. **Step 2: Lint** — detect lint tool → run → exit on failure
3. **Step 3: Commit Message Generation** — determine type (branch→diff→user) → gitmoji mapping → generate message → confirm
4. **Step 4: Commit Execution** — HEREDOC commit → output result
Pass branch type and issue number from Phase 0 to Step 3's type determination.
Reference gitmoji-convention skill's type decision priority and mapping tables.
