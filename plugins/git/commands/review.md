---
description: Code review with 100-point deduction scoring
allowed-tools: Read, Bash, Glob, Grep
argument-hint: "[pr [N]]"
---
# Review: $ARGUMENTS
## Arg Parse
- Empty → **diff mode** (staged changes, JSON output)
- `pr` → **pr mode** (auto-detect PR, Markdown output)
- `pr <N>` → **pr mode** (PR #N, Markdown output)

## Load Criteria
Read `skills/review-criteria/SKILL.md` → scoring rules, confidence levels, output schema.

## diff mode

### Step 1: Collect diff
```bash
git diff --cached
git diff --cached --stat
```
Empty diff → print "No staged changes to review." → **exit**.

### Step 2: Assess scope
- File count + line count from stat
- 500+ lines → note "Consider splitting" in feedback

### Step 3: Identify good practices
Scan diff for: clear function separation, proper error handling, tests added, consistent style, appropriate abstraction.

### Step 4: Category evaluation
For each category (Functionality → Readability → Reliability → Performance):
1. Check each item in criteria table
2. Assign confidence level per finding (high/medium/low)
3. Deduct only for **high confidence** items
4. Every issue MUST include specific code fix suggestion

### Step 5: Build JSON
Per `skills/review-criteria/SKILL.md` JSON schema:
- Calculate `score` = 100 - sum(high-confidence deductions)
- Set `verdict` per threshold (PASS ≥80 / REVISE 60-79 / FAIL <60)
- `resolved_from_previous`: if previous review JSON provided as context, compare and list resolved items. Otherwise empty array.
- Output **JSON only** — no explanatory text before or after.

## pr mode

### Step 1: Identify PR
`$ARGUMENTS` has number → use it. Else `gh pr view --json number --jq '.number'`. Fail → "No PR found." + exit.

### Step 2: Collect PR data
```bash
gh pr view <N> --json title,body,files,additions,deletions
gh pr diff <N>
```

### Step 3: Assess scope
Same as diff mode Step 2.

### Step 4: Identify good practices
Same as diff mode Step 3.

### Step 5: Category evaluation
Same as diff mode Step 4.

### Step 6: Build Markdown
Per `skills/review-criteria/SKILL.md` Markdown template:
- Overall Assessment with score
- Good Practices list
- Critical Issues (major + high confidence)
- Important Issues (minor + high confidence)
- Nice-to-have (medium/low confidence)
- Output **Markdown only**.
