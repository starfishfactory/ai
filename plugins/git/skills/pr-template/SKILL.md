---
name: pr-template
description: PR body GFM template and auto-generation rules
user-invocable: false
---
# PR Body GFM Template

## Project PR Template Detection

### Search Order (first match wins)
Repo root (`git rev-parse --show-toplevel`), then:
1. `{root}/.github/PULL_REQUEST_TEMPLATE.md`
2. `{root}/.github/pull_request_template.md`
3. `{root}/PULL_REQUEST_TEMPLATE.md`
4. `{root}/pull_request_template.md`
5. `{root}/docs/PULL_REQUEST_TEMPLATE.md`
6. `{root}/.github/PULL_REQUEST_TEMPLATE/` dir (1→auto, 2+→AskUserQuestion)

### When Project Template Found
Use as base. Auto-fill matching sections:

| Section Header Match (case-insensitive contains) | Fill Rule |
|---|---|
| "summary", "description", "what", "overview" | Commit history-based summary (Summary rules below) |
| "changes", "what changed", "changelog" | Diff stat top 5 files (Changes rules below) |
| "test", "testing", "how to test", "qa" | Test file analysis (Test Plan rules below) |
| "issue", "linked", "reference", "related" | `Closes #N` (Related Issue rules below) |
| "breaking" | Commit message BREAKING CHANGE analysis |
| No match | Keep original placeholder as-is |

Append footer: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`

No template found → fall back to built-in Template below.

## Template
```markdown
## Summary
<!-- Auto-generated from commit history: 3-5 line summary -->

## Changes
<!-- Auto-generated from diff stat: top 5 files -->
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

### Summary
- 1 commit → use commit message body
- Multiple → synthesize into 3-5 line summary

### Changes
- `git diff --stat` → top 5 files by changed lines
- Infer description from file paths

### Test Plan
- Test files (`*.test.*`, `*.spec.*`, `**/tests/**`) added/modified → "Unit tests added/modified"
- No test changes → empty checklist (`- [ ] `)

### Breaking Changes
- Commit messages contain `BREAKING CHANGE` or `!` → include details
- Otherwise → "None"

### Related Issue
- Branch regex `/(\d+)-/` → `Closes #number`
- No match → remove section

## PR Title Rules
- 1 commit → commit subject (remove gitmoji, max 70 chars)
- Multiple → branch name → kebab-to-space + capitalize (e.g. `feat/123-add-login` → "Add login")
- Max 70 chars
