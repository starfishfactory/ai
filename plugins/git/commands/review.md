---
description: 100-pt deduction code review
allowed-tools: Read, Bash, Glob, Grep
argument-hint: "[pr [N]]"
---
# Review: $ARGUMENTS
## Arg Parse
- Empty → **diff mode** (staged changes, JSON output)
- `pr` → **pr mode** (auto-detect PR, Markdown output)
- `pr <N>` → **pr mode** (PR #N, Markdown output)

Read `skills/review-criteria/SKILL.md` for scoring rules + output schema.

## diff mode

**0. Iteration context**: If previous review JSON provided inline, parse for `resolved_from_previous` in Step 5.

**1. Collect diff**
```bash
git diff --cached
git diff --cached --stat
```
Empty → "No staged changes to review." → **exit**.

**2. Assess scope**: File + line count. 500+ lines → note "Consider splitting".

**3. Good practices**: Scan for clear separation, error handling, tests, consistent style, appropriate abstraction.

**4. Category eval**: Per criteria table (Functionality→Readability→Reliability→Performance) — assign confidence, deduct **high** only, every issue needs concrete fix.

**5. Build JSON**: Per SKILL.md schema. `score`=100-deductions, `verdict` per threshold, `resolved_from_previous` from context. **JSON only**.

## pr mode

**1. Identify PR**: `$ARGUMENTS` number or `gh pr view --json number --jq '.number'`. Fail → exit.

**2. Collect PR data**
```bash
gh pr view <N> --json title,body,files,additions,deletions
gh pr diff <N>
```
Fail → "Cannot fetch PR #N." + exit. Empty diff → "No file changes." + exit.

**3-5**: Same as diff mode Steps 2-4.

**6. Build Markdown**: Per SKILL.md template — Assessment, Good Practices, Critical/Important/Nice-to-have. **Markdown only**.
