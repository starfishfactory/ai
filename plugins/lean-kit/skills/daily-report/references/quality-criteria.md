# Daily Report Quality Criteria

100-point deduction-based scoring across 5 categories.
Start at 100, subtract for each violation found.

---

## Category 1: Data Accuracy (35 points)

Verify every number in the report against the source JSON.

| Violation | Deduction |
|-----------|-----------|
| Token count mismatch (off by >1%) | -7 per instance |
| Cost calculation error (off by >$0.10) | -7 per instance |
| Session count wrong | -7 |
| Commit count wrong | -7 |
| Incorrect session ID referenced | -5 per instance |
| Time range error (>5min off) | -3 per instance |

---

## Category 2: Completeness (25 points)

All 9 sections must be present and substantive.

| Violation | Deduction |
|-----------|-----------|
| Missing section entirely | -5 per section |
| Section present but empty/trivial (<2 sentences) | -3 per section |
| Missing project in Section 2 | -5 per project |
| Session timeline incomplete (missing sessions) | -3 per session |
| No commit table when commits exist | -3 |
| Missing trend comparison when previous report exists | -5 |

---

## Category 3: Numerical Consistency (20 points)

Cross-check numbers within the report itself.

| Violation | Deduction |
|-----------|-----------|
| Section 1 totals ≠ sum of Section 2 project subtotals | -5 per metric |
| Token breakdown doesn't sum to total | -5 |
| Cost breakdown doesn't sum to total | -5 |
| Session count in overview ≠ timeline row count | -5 |
| Percentage doesn't match raw numbers | -3 per instance |
| Bar chart proportions visually inconsistent with data | -2 per instance |

---

## Category 4: Analysis Quality (10 points)

Qualitative assessment of insights.

| Violation | Deduction |
|-----------|-----------|
| Improvement suggestion not backed by data | -3 per instance |
| Incorrect pattern identification | -3 per instance |
| Missing obvious pattern (e.g., team agent, carry-over) | -2 per pattern |
| Session flow diagram has wrong connections | -2 per error |
| Keyword analysis contradicts prompt data | -2 |

---

## Category 5: Format & Readability (10 points)

| Violation | Deduction |
|-----------|-----------|
| Broken markdown table | -2 per table |
| ASCII chart misaligned or wrong proportions | -2 per chart |
| Inconsistent number formatting (mixing M/K/raw) | -2 |
| Language inconsistency (report body not in Korean) | -3 |
| Section numbering error | -1 |

---

**Important**: Deductions within a category are capped at the category's maximum points. For example, Data Accuracy deductions cannot exceed 35 points total.

## Verdict Rules

| Score | Verdict | Action |
|-------|---------|--------|
| ≥80 | **PASS** | Proceed to final output |
| 60–79 | **REVISE** | Return feedback to generator for revision |
| <60 | **FAIL** | Halt and ask user for guidance |

## Output Format

```json
{
  "score": 85,
  "verdict": "PASS",
  "categories": {
    "dataAccuracy": { "score": 30, "max": 35, "deductions": [...] },
    "completeness": { "score": 22, "max": 25, "deductions": [...] },
    "numericalConsistency": { "score": 18, "max": 20, "deductions": [...] },
    "analysisQuality": { "score": 8, "max": 10, "deductions": [...] },
    "formatReadability": { "score": 7, "max": 10, "deductions": [...] }
  },
  "feedback": [
    "Section 4.1 token total (140.5M) doesn't match Section 1 (141.0M)",
    "Missing project 'mrt-eugene-docs' in Section 2"
  ]
}
```
