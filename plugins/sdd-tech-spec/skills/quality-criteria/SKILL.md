---
name: quality-criteria
description: Tech Spec quality evaluation criteria (100-point deduction system, 5 categories) and Critic feedback JSON output format
user-invocable: false
---

# Tech Spec Quality Evaluation Criteria

100-point deduction system. Evaluate across 5 categories; deduct per item within each category's max limit.

## Category 1: Completeness (30 pts max)

| Check Item | Deduction |
|----------|------------|
| Missing required section (per type) | -5/each |
| Goals < 3 | -4 |
| Non-Goals < 2 | -3 |
| No detailed design section | -5 |
| No functional requirements (FR) | -4 |
| No non-functional requirements (NFR) | -3 |
| Risks < 2 | -3 |
| No alternative review | -3 |

## Category 2: Specificity (25 pts max)

| Check Item | Deduction |
|----------|------------|
| Vague adjectives ("appropriate", "efficient", "fast", "high") | -3/each (max -9) |
| NFR without numeric targets (response time, availability, throughput, etc.) | -5 |
| Untestable requirements (FR/NFR without verification criteria) | -3/each (max -9) |
| No Mermaid diagrams (architecture/sequence) | -3 |

## Category 3: Consistency (15 pts max)

| Check Item | Deduction |
|----------|------------|
| Goal item not reflected in detailed design | -5/each |
| Same concept uses different terms | -3/each |
| FR/NFR number reference does not exist | -3/each |

## Category 4: Feasibility (15 pts max)

| Check Item | Deduction |
|----------|------------|
| Dependencies of used technologies not specified | -5 |
| Logical order violation between milestones | -5 |
| Technical/business constraints not identified | -5 |

## Category 5: Risk Management (15 pts max)

| Check Item | Deduction |
|----------|------------|
| Risks < 3 (need >= 1 each of technical/schedule/external) | -5 |
| No impact/probability assessment per risk | -5 |
| No mitigation strategy per risk | -5 |

## Verdict Criteria

Default thresholds (Standard tier). See Tier-Specific Adjustments below for Light/Deep overrides.

| Score | Verdict | Action |
|------|------|------|
| >= 80 | **PASS** | End loop, proceed to final output |
| 60-79 | **REVISE** | Next Generator-Critic iteration |
| < 60 | **FAIL** | Ask user to choose: continue/revise/cancel |

## Critic Feedback JSON Output Format

Critic agent MUST output evaluation results in this JSON schema:

```json
{
  "score": 72,
  "verdict": "REVISE",
  "categories": {
    "completeness": {
      "score": 22,
      "max": 30,
      "issues": [
        "Only 2 Goals (minimum 3 required)",
        "Alternative review section missing"
      ]
    },
    "specificity": {
      "score": 18,
      "max": 25,
      "issues": [
        "NFR-002 'high availability' has no numeric target",
        "No Mermaid sequence diagram"
      ]
    },
    "consistency": {
      "score": 12,
      "max": 15,
      "issues": [
        "Goal 3 'ensure scalability' not reflected in detailed design"
      ]
    },
    "feasibility": {
      "score": 10,
      "max": 15,
      "issues": [
        "Redis dependency not specified in dependencies section"
      ]
    },
    "risk": {
      "score": 10,
      "max": 15,
      "issues": [
        "No external-type risk (need >= 1 each of technical/schedule/external)"
      ]
    }
  },
  "feedback": [
    {
      "section": "4.2 Non-Functional Requirements",
      "severity": "major",
      "issue": "'high availability' has no numeric target",
      "suggestion": "Specify as '99.9% availability (annual downtime <= 8.76 hours)'"
    },
    {
      "section": "2.1 Goals",
      "severity": "minor",
      "issue": "Only 2 Goals exist",
      "suggestion": "Add 1 more Goal related to core functionality"
    }
  ]
}
```

### Field Descriptions

- `score`: Total score (0-100)
- `verdict`: "PASS" | "REVISE" | "FAIL"
- `categories`: Per-category scores and issue lists
  - `score`: Category earned score
  - `max`: Category max score
  - `issues`: Array of deduction reasons
- `feedback`: Array of specific improvement feedback
  - `section`: Section number/name
  - `severity`: "major" (critical defect) | "minor" (minor defect)
  - `issue`: Problem description
  - `suggestion`: Specific improvement suggestion

## Tier-Specific Adjustments

### Light Tier (PASS >= 70)

| Adjustment | Change |
|-----------|--------|
| Goals minimum | 2 (not 3) → no deduction at 2 |
| Non-Goals minimum | 1 (not 2) → no deduction at 1 |
| Risks minimum | 1 (not 3) → no type diversity required |
| Alternative review | Not required → no deduction if absent |
| Mermaid diagrams | Optional → no deduction if absent |
| NFR numeric targets | Deduct only if NFR section exists but lacks targets |

### Standard Tier (PASS >= 80)

Default criteria. No adjustments. All deduction tables apply as-is.

### Deep Tier (PASS >= 85)

| Adjustment | Change |
|-----------|--------|
| Goals minimum | 5 (not 3) → -4 if < 5 |
| Non-Goals minimum | 3 (not 2) → -3 if < 3 |
| Mermaid minimum | 3 (not 1) → -3 per missing below 3 |
| Alternatives minimum | 3 (not 2) → -3 if < 3 |
| Risks minimum | 5 with quantitative matrix → -5 if < 5 |
| All 10 sections | Required → -5 per missing section |
| Risk matrix | Must include probability % and impact severity scale |

## Generator's Unresolved Items

When Generator cannot apply Critic feedback, mark as `## Unresolved Feedback` section at the end of the spec.

Per-item format:

```markdown
## Unresolved Feedback

### [major] Section 4.2 Non-Functional Requirements
**Original feedback**: 'high availability' has no numeric target
**Reason not applied**: Cannot determine SLA numbers in current infra environment, need ops team discussion

### [minor] Section 8 Milestones
**Original feedback**: No basis for milestone duration estimates
**Reason not applied**: Cannot estimate specific durations before team resource confirmation
```

Report this section as residual issues in final output if present.
