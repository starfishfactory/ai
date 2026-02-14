---
name: smart-commit
description: Smart commit workflow guide (shared reference for commit.md and pr.md)
user-invocable: false
---
# Smart Commit Process
Execute the following steps in order. **Always load gitmoji-convention skill as reference.**
## Step 1: Staging
- `git diff --cached --name-only` → check staged files
- `git diff --name-only` → check unstaged files
- If no staged but unstaged exist → AskUserQuestion for staging method:
  - "Add all": `git add -A`
  - "Select files": present file list, `git add <file>` for user-selected files
- After staging, `git diff --cached --name-only` → if still no staged files, print "No changes to commit" and **exit**
- If both empty → print "No changes to commit" and **exit**
## Step 2: Lint
- If `package.json` has `scripts.lint` → run `npm run lint`
- If `Makefile` has `lint` target → run `make lint`
- Neither detected → skip lint step
- Lint failure → show error + print "Fix lint errors before committing" and **exit**
## Step 3: Commit Message Generation
1. **Determine type**: apply gitmoji-convention skill's type decision priority rules
   - Branch name → diff file pattern inference → AskUserQuestion
2. **Gitmoji mapping**: map determined type → emoji from gitmoji-convention mapping table
3. **Scope**: common parent directory of changed files (optional, omit if none)
4. **Subject**: imperative summary of changes, max 50 chars
5. **Body**: add list of major changes when 3+ files changed
6. **Format**: `<gitmoji> <type>(<scope>): <subject>`
7. AskUserQuestion to confirm/edit generated message
## Step 4: Commit Execution
- Run `git commit` (HEREDOC format, include Co-Authored-By)
  ```
  git commit -m "$(cat <<'EOF'
  <gitmoji> <type>(<scope>): <subject>

  <body>

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```
- Failure → show error and **exit**
- Success → run `git log -1 --oneline` to display commit result
