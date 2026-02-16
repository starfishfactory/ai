---
name: review-criteria
description: Code review 100-point deduction criteria, verdict thresholds, confidence levels, and output schemas
user-invocable: false
---

# Code Review Criteria

100-point deduction system. Evaluate across 4 categories.

## Category 1: Functionality (30 pts max)

| Check | Deduction |
|-------|-----------|
| Logic error / incorrect behavior | -5/each, max -15 |
| Unhandled edge case | -3/each, max -9 |
| Missing error handling (external calls) | -3/each, max -6 |

## Category 2: Readability (25 pts max)

| Check | Deduction |
|-------|-----------|
| Unclear variable/function name | -3/each, max -9 |
| Complex logic without comments | -4/block, max -8 |
| Inconsistent code style | -2/each, max -8 |

## Category 3: Reliability (25 pts max)

| Check | Deduction |
|-------|-----------|
| Null/undefined unchecked | -4/each, max -8 |
| Resource leak (unclosed connection/file) | -5/each, max -10 |
| Debug/test code left (console.log, print, TODO, debugger) | -3/each, max -7 |

## Category 4: Performance (20 pts max)

| Check | Deduction |
|-------|-----------|
| Unnecessary loop / redundant computation | -4/each, max -8 |
| N+1 query / unoptimized DB access | -5/each, max -10 |
| Memory leak risk | -2/each, max -4 |

## Verdict

| Score | Verdict | Action |
|-------|---------|--------|
| >= 80 | **PASS** | Commit allowed |
| 60-79 | **REVISE** | Revision recommended |
| < 60 | **FAIL** | Revision required |

## Confidence Levels

| Level | Criteria | Score impact |
|-------|----------|-------------|
| **high** | Can cite exact code line proving the issue. Fix is deterministic | Deducted |
| **medium** | Likely issue but depends on runtime context or external state | Shown, no deduction |
| **low** | Stylistic, speculative, or uncertain. "I'm not sure" is valid | Collapsed, no deduction |

Downgrade triggers (never assign `high` if any apply):
- Cannot point to specific line → max `medium`
- Depends on config/env not visible in diff → max `medium`
- "Might" / "could" / "possibly" reasoning → `low`
- Unfamiliar language/framework patterns → `low`

## Auto-Filter Rules

Skip — do NOT report:
1. **Pre-existing**: issue in unchanged lines (before this diff)
2. **Lint-detectable**: formatting, unused imports, trailing whitespace — skip if project has linter
3. **Speculative**: "might cause issues" without concrete evidence in current diff

When uncertain → assign `low`, never `high`.

## Suggestion Rule

Concrete code fix per item — no abstract advice. Provide before/after or exact change.

## Iteration Context

When previous review JSON is provided:
1. Compare previous feedback items against current diff
2. Mark resolved items in `resolved_from_previous` array
3. Focus deductions on NEW issues only
4. Previously reported but unresolved items: re-report with same deduction

## JSON Output Schema (diff mode)

Output JSON only — no explanatory text.

```json
{
  "score": 0,
  "verdict": "PASS | REVISE | FAIL",
  "resolved_from_previous": [],
  "categories": {
    "functionality": { "score": 0, "max": 30, "issues": [] },
    "readability": { "score": 0, "max": 25, "issues": [] },
    "reliability": { "score": 0, "max": 25, "issues": [] },
    "performance": { "score": 0, "max": 20, "issues": [] }
  },
  "good_practices": [],
  "feedback": [
    {
      "file": "file:line",
      "category": "functionality|readability|reliability|performance",
      "severity": "major|minor",
      "confidence": "high|medium|low",
      "deduction": 0,
      "issue": "Problem description",
      "suggestion": "Specific code fix"
    }
  ]
}
```

### Field Rules
- `score`: 100 minus total deductions (high-confidence only)
- `verdict`: per threshold table
- `resolved_from_previous`: array of "{file:line} - {resolution}" strings. Empty array if no previous review
- `categories.*.score`: deduction subtotal per category (high-confidence only)
- `categories.*.issues`: description strings
- `feedback[].deduction`: 0 for medium/low confidence items
- `good_practices`: highlight positive patterns found

## Markdown Output Template (pr mode)

```markdown
## Overall Assessment
{2-3 sentence summary}. Score: {score}/100 ({verdict})

## Good Practices
- {practice}

## Critical Issues
### {title}
- **File**: `{file:line}`
- **Category**: {category}
- **Confidence**: {confidence}
- **Description**: {problem}
- **Suggestion**: {specific fix}

## Important Issues
{same format}

## Nice-to-have
{same format, medium/low confidence items here}
```

### Severity Classification
- **major**: deduction >= 4 per instance
- **minor**: deduction <= 3 per instance

### Section Mapping
- Critical Issues: major severity + high confidence
- Important Issues: minor severity + high confidence
- Nice-to-have: medium/low confidence (any severity)

## Principles

1. Solutions over problems
2. Critical-first order
3. Acknowledge good patterns
4. Concrete fix per issue
5. Out-of-scope → Nice-to-have
6. Deduct verified only (high)
7. Track previous resolution
