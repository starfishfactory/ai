---
name: review
description: Standalone code review with 100-point deduction scoring
context: fork
allowed-tools: Read, Bash, Task, AskUserQuestion, Glob, Grep
argument-hint: "[staged|working|<file-or-dir-path>]"
---

# Standalone Code Review: $ARGUMENTS

Independent code review using 100-point deduction scoring. Separate from PR workflow.

## Phase 0: Detect Review Target

Parse `$ARGUMENTS`:

| Argument | Target | Diff Command |
|----------|--------|-------------|
| `staged` or empty | Staged changes | `git diff --cached` |
| `working` | Unstaged working changes | `git diff` |
| file/dir path | Specific path | `git diff -- <path>` (try staged first, fall back to working) |

### Step 0.1: Collect diff
Run the appropriate diff command. Empty diff → "No changes found for review target." → **exit**.

### Step 0.2: Collect stats
Parallel: `git diff [flags] --stat` + `git rev-parse --abbrev-ref HEAD`

## Phase 1: Review (GC Loop, max 3 iterations)

#### Iteration N (N = 1, 2, 3):

##### Step 1.N.1: Invoke pr-reviewer (Mode A)
1. Read `agents/pr-reviewer.md` + `skills/review-criteria/SKILL.md`
2. Task(subagent_type: `general-purpose`):
   - System prompt: pr-reviewer.md content
   - Context: review-criteria content, branch, diff stats, iteration N
   - Directive: "Standalone review (Mode A). Output JSON only."
   - Input N=1: diff output | N>1: + previous review JSON
   - Request: "Evaluate changes per Mode A. Output JSON."

##### Step 1.N.2: Verdict
Parse JSON → `score` + `verdict`:
- **PASS (>= 80)**: → Phase 2
- **REVISE (60-79)**: Show feedback. AskUserQuestion: "Fix and re-review (Recommended)" / "Done reviewing" / "Cancel"
  - Fix → user fixes → re-collect diff → if diff unchanged, warn + AskUserQuestion "Re-review anyway" / "Done" / "Cancel" → next iteration
- **FAIL (< 60)**: Show all feedback (critical first). AskUserQuestion: "Fix and re-review" / "Done reviewing" / "Cancel"
  - Fix → same flow as REVISE → next iteration

##### After 3 iterations without PASS
Print last score + residual issues. AskUserQuestion: "Continue fixing" / "Done reviewing".

## Phase 2: Summary Output

Display final results:

```
## Review Result: {verdict} ({score}/100)

### Good Practices
{good_practices list}

### Issues Found
{feedback items, critical first}
```
