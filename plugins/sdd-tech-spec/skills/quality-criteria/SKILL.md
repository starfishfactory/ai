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
