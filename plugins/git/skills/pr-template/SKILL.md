---
name: pr-template
description: PR body GFM template, auto-generation rules, and review checklist
user-invocable: false
---
# PR Body GFM Template
## Template
```markdown
## Summary
<!-- Auto-generated from commit history: 3-5 line summary of PR purpose and key changes -->

## Changes
<!-- Auto-generated from diff stat: top 5 files by changed lines -->
- {change description} (`{file path}`)

## Test Plan
- [ ] {test item}

## Breaking Changes
None

## Related Issue
Closes #{issue_number}

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```
## Auto-Generation Rules
### Summary Section
- 1 commit → use that commit message body
- Multiple commits → synthesize commit messages into 3-5 line summary
### Changes Section
- Based on `git diff --stat` results
- List top 5 files by changed line count
- Infer change description from file paths
### Test Plan Section
- Test files (`*.test.*`, `*.spec.*`, `**/tests/**`) added/modified → auto-add "Unit tests added/modified" item
- No test changes → provide empty checklist (`- [ ] `)
### Breaking Changes Section
- If commit messages contain `BREAKING CHANGE` or `!` → include details
- Otherwise → "None"
### Related Issue Section
- Extract issue number from branch name: regex `/(\d+)-/`
- Success → `Closes #number`
- Failure → remove section
## PR Title Rules
- 1 commit → use commit message subject (remove gitmoji, max 70 chars)
- Multiple commits → generate from branch name
  - e.g. `feat/123-add-login` → "Add login"
  - Convert kebab-case to space-separated + capitalize first letter
- Max 70 chars
## Review Checklist
### Functionality
- [ ] Requirements correctly implemented?
- [ ] Edge cases handled?
- [ ] Error handling adequate?
- [ ] Input validation sufficient?
### Readability
- [ ] Function/variable names clear?
- [ ] Code structure easy to understand?
- [ ] Complex logic has explanatory comments?
- [ ] No unnecessary complexity?
### Reliability
- [ ] Test coverage sufficient?
- [ ] Null/undefined checks present?
- [ ] No race condition risks?
- [ ] Resources properly cleaned up (close, cleanup)?
### Performance
- [ ] No unnecessary loops/operations?
- [ ] No memory leak risks?
- [ ] DB query optimization needed?
- [ ] No N+1 query issues?
