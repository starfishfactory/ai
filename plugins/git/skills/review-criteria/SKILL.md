---
name: review-criteria
description: 100-pt deduction review criteria, thresholds, confidence, output schemas
user-invocable: false
---

# Code Review Quality Criteria

100-point deduction system. Evaluate across 4 categories; deduct per item within each category's max limit.

## Category 1: Functionality (30 pts max)

| Check Item | Deduction |
|------------|-----------|
| Logic errors or incorrect behavior | -5/each (max -15) |
| Edge cases not handled | -3/each (max -9) |
| Missing error handling for external calls | -3/each (max -6) |

## Category 2: Readability (25 pts max)

| Check Item | Deduction |
|------------|-----------|
| Unclear variable/function names | -3/each (max -9) |
| Overly complex logic without comments | -4/each (max -8) |
| Inconsistent code style | -2/each (max -8) |

## Category 3: Reliability (25 pts max)

| Check Item | Deduction |
|------------|-----------|
| Null/undefined not checked | -4/each (max -8) |
| Resource leak risk (unclosed connections, files) | -5/each (max -10) |
| Debug/test code left in (console.log, TODO, debugger) | -3/each (max -7) |

## Category 4: Performance (20 pts max)

| Check Item | Deduction |
|------------|-----------|
| Unnecessary loops or redundant computation | -4/each (max -8) |
| N+1 query or unoptimized DB access | -5/each (max -10) |
| Memory leak risk | -2/each (max -4) |

## Verdict Criteria

| Score | Verdict | Action |
|-------|---------|--------|
| >= 80 | **PASS** | End loop, proceed |
| 60-79 | **REVISE** | Next iteration |
| < 60 | **FAIL** | Ask user to choose: continue/fix/cancel |

## Mode A: JSON Output Format

Reviewer agent MUST output evaluation results in this JSON schema:

```json
{
  "score": 85,
  "verdict": "PASS",
  "categories": {
    "functionality": { "deducted": 5, "max": 30, "issues": ["Edge case: empty input not handled in parseArgs()"] },
    "readability": { "deducted": 3, "max": 25, "issues": ["Variable 'x' in processData() is unclear"] },
    "reliability": { "deducted": 4, "max": 25, "issues": ["console.log left in auth.js:42"] },
    "performance": { "deducted": 3, "max": 20, "issues": [] }
  },
  "good_practices": ["Proper error handling in API layer", "Tests added for new features"],
  "feedback": [
    {
      "file": "src/auth.js:42",
      "category": "reliability",
      "severity": "major",
      "deduction": 3,
      "issue": "console.log left in production code",
      "suggestion": "Remove or replace with structured logger"
    }
  ]
}
```

### Field Descriptions

- `score`: 100 minus total deductions
- `verdict`: "PASS" | "REVISE" | "FAIL"
- `categories`: Per-category deduction totals and issue lists
  - `deducted`: Points deducted in this category
  - `max`: Category max score
  - `issues`: Array of deduction reasons
- `good_practices`: Array of positive observations
- `feedback`: Array of specific improvement items
  - `file`: `file:line` location
  - `category`: functionality | readability | reliability | performance
  - `severity`: "major" | "minor"
  - `deduction`: Points deducted for this item
  - `issue`: Problem description
  - `suggestion`: Specific fix suggestion

## Mode B: Markdown Output Format

Sections: Overall Assessment (2-3 sentence summary) → Good Practices → Critical Issues → Important Issues → Nice-to-have.

Per issue:

```markdown
### {issue title}
- **File**: `{file:line}`
- **Category**: {category}
- **Description**: {problem}
- **Suggestion**: {improvement}
```
