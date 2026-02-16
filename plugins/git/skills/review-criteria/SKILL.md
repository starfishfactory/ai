---
name: review-criteria
description: 100-pt deduction review criteria, thresholds, confidence, output schemas
user-invocable: false
---

# Code Review Criteria

100-pt deduction, 4 categories.

## Functionality (30 pts max)

| Check | Deduction |
|-------|-----------|
| Logic error / incorrect behavior | -5/each, max -15 |
| Unhandled edge case | -3/each, max -9 |
| Missing error handling (external calls) | -3/each, max -6 |

## Readability (25 pts max)

| Check | Deduction |
|-------|-----------|
| Unclear variable/function name | -3/each, max -9 |
| Complex logic without comments | -4/block, max -8 |
| Inconsistent code style | -2/each, max -8 |

## Reliability (25 pts max)

| Check | Deduction |
|-------|-----------|
| Null/undefined unchecked | -4/each, max -8 |
| Resource leak (unclosed connection/file) | -5/each, max -10 |
| Debug/test code left (console.log, print, TODO, debugger) | -3/each, max -7 |

## Performance (20 pts max)

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
| **high** | Exact line citeable, fix deterministic | Deducted |
| **medium** | Likely but context/env-dependent | Shown, not deducted |
| **low** | Stylistic/speculative/uncertain | Collapsed, not deducted |

Downgrade — never `high` if: no specific line → `medium`; invisible config/env → `medium`; "might"/"could" → `low`; unfamiliar lang/framework → `low`.

## Auto-Filter

Skip: (1) pre-existing issues in unchanged lines, (2) lint-detectable formatting/imports/whitespace, (3) speculative w/o evidence in diff. Uncertain → `low`.

**Suggestion**: concrete code fix per item — before/after or exact change.

## Iteration Context

Previous review JSON provided → compare items, resolved → `resolved_from_previous` array, deduct NEW only, re-report unresolved same deduction.

## JSON Schema (diff mode)

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

Fields: `score`=100−high deductions. `verdict` per table. `resolved_from_previous`: "{file:line} - {resolution}" strings, empty if none. `categories.*.score`: high-confidence subtotal. `feedback[].deduction`: 0 for medium/low. `good_practices`: positive patterns.

## Markdown Template (pr mode)

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

Severity mapping: **major** (≥4 pts) → Critical Issues (high), **minor** (≤3 pts) → Important Issues (high), medium/low confidence → Nice-to-have.

## Principles

1. Solutions over problems
2. Critical-first order
3. Acknowledge good patterns
4. Concrete fix per issue
5. Out-of-scope → Nice-to-have
6. Deduct verified only (high)
7. Track previous resolution
