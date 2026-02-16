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
| Memory leak risk | -2/each |

## Verdict

| Score | Verdict | Action |
|-------|---------|--------|
| >= 80 | **PASS** | Commit allowed |
| 60-79 | **REVISE** | Revision recommended |
| < 60 | **FAIL** | Revision required |

## Confidence Levels

Every feedback item MUST include confidence:

| Level | Meaning | Display |
|-------|---------|---------|
| **high** | Definite issue, verifiable from code | Primary display |
| **medium** | Likely issue, needs context to confirm | Secondary display |
| **low** | Possible issue, stylistic or speculative | Collapsed/dimmed |

Rule: Only `high` confidence items contribute to score deductions. `medium`/`low` items appear in feedback but do NOT affect score.

## Actionable Suggestion Rule

Every feedback item MUST include a specific code fix suggestion. Abstract advice ("consider refactoring", "improve naming") is NOT acceptable. Provide exact code change or clear before/after.

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

### Section Mapping
- Critical Issues: major severity + high confidence
- Important Issues: minor severity + high confidence
- Nice-to-have: medium/low confidence (any severity)

## Review Principles

1. **Constructive**: solutions, not just problems
2. **Prioritized**: critical-first ordering
3. **Balanced**: acknowledge good parts
4. **Actionable**: concrete code fix per issue — no abstract advice
5. **Context-aware**: understand scope; out-of-scope → Nice-to-have
6. **Confidence-honest**: only deduct for verified issues (high confidence)
7. **Iteration-aware**: track previous feedback resolution on re-reviews
