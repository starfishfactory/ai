---
name: tech-spec-template
description: Tech Spec GFM output template and per-type required/optional section mapping
user-invocable: false
---

# Tech Spec GFM Output Template

## YAML Frontmatter

All specs start with this YAML frontmatter:

```yaml
---
title: {Spec title}
status: draft
tags: [{related tags}]
created: {YYYY-MM-DD}
spec-type: {feature-design | system-architecture | api-spec}
---
```

- `status`: Progresses draft > review > approved
- `spec-type`: Matches type classification from sdd-framework SKILL

## Section Structure

### 1. Overview

```markdown
## 1. Overview

### 1.1 Background
{Why this spec is needed. Current situation and problems.}

### 1.2 Motivation
{Why this work is needed now. Business/technical motivation.}

### 1.3 Problem Statement
{Define the core problem to solve in 1-2 sentences.}
```

### 2. Goals & Non-Goals

```markdown
## 2. Goals & Non-Goals

### 2.1 Goals
1. {Specific, measurable goal 1}
2. {Specific, measurable goal 2}
3. {Specific, measurable goal 3}

### 2.2 Non-Goals
1. {Explicitly excluded item 1}
2. {Explicitly excluded item 2}
```

### 3. Detailed Design

```markdown
## 3. Detailed Design

### 3.1 Architecture

{Describe overall system/feature structure.}

\`\`\`mermaid
graph TD
    A[Component A] --> B[Component B]
    B --> C[Component C]
\`\`\`

### 3.2 Data Model

{Define core data structures and relationships.}

| Field | Type | Description | Constraints |
|------|------|------|----------|
| id | UUID | Unique identifier | PK, NOT NULL |

### 3.3 API Design

#### `POST /api/v1/resource`

**Request**:
\`\`\`json
{
  "field": "value"
}
\`\`\`

**Response** (200 OK):
\`\`\`json
{
  "id": "uuid",
  "field": "value"
}
\`\`\`

**Error Codes**:
| Code | Description |
|------|------|
| 400 | Bad request |
| 404 | Resource not found |

### 3.4 Sequence Diagram

\`\`\`mermaid
sequenceDiagram
    participant Client
    participant Server
    participant DB
    Client->>Server: Request
    Server->>DB: Query
    DB-->>Server: Result
    Server-->>Client: Response
\`\`\`
```

### 4. Functional Requirements (FR) + Non-Functional Requirements (NFR)

```markdown
## 4. Requirements

### 4.1 Functional Requirements (FR)

| ID | Requirement | Acceptance Criteria | Priority |
|----|---------|----------|---------|
| FR-001 | {Feature description} | {Verifiable criteria} | P0/P1/P2 |
| FR-002 | {Feature description} | {Verifiable criteria} | P0/P1/P2 |

### 4.2 Non-Functional Requirements (NFR)

| ID | Category | Requirement | Target Metric |
|----|---------|---------|----------|
| NFR-001 | Performance | {Specific requirement} | {Numeric target} |
| NFR-002 | Availability | {Specific requirement} | {Numeric target} |
| NFR-003 | Security | {Specific requirement} | {Numeric target} |
```

### 5. Dependencies & Constraints

```markdown
## 5. Dependencies & Constraints

### 5.1 Dependencies

| Dependency | Type | Description | Impact |
|--------|------|------|------|
| {Service/library} | Technical/Organizational | {Description} | {Impact if unmet} |

### 5.2 Constraints

- **Technical**: {Tech stack, infrastructure constraints}
- **Business**: {Budget, schedule, staffing constraints}
- **Regulatory**: {Legal, compliance constraints}
```

### 6. Success Metrics & Test Criteria

```markdown
## 6. Success Metrics & Test Criteria

### 6.1 Success Metrics

| Metric | Current Value | Target Value | Measurement Method |
|------|--------|--------|----------|
| {KPI} | {Current} | {Target} | {Method} |

### 6.2 Test Criteria

- **Unit tests**: {Coverage target, key test cases}
- **Integration tests**: {Scenarios, verification items}
- **Performance tests**: {Load conditions, expected results}
```

### 7. Risks & Mitigation

```markdown
## 7. Risks & Mitigation

| ID | Risk | Type | Probability | Impact | Mitigation |
|----|--------|------|------|--------|----------|
| R-001 | {Risk description} | Technical/Schedule/External | H/M/L | H/M/L | {Specific response} |
| R-002 | {Risk description} | Technical/Schedule/External | H/M/L | H/M/L | {Specific response} |
| R-003 | {Risk description} | Technical/Schedule/External | H/M/L | H/M/L | {Specific response} |
```

### 8. Milestones & Timeline

```markdown
## 8. Milestones & Timeline

| Phase | Milestone | Deliverables | Estimated Duration |
|------|---------|--------|----------|
| 1 | {Milestone 1} | {Deliverables} | {Duration} |
| 2 | {Milestone 2} | {Deliverables} | {Duration} |
| 3 | {Milestone 3} | {Deliverables} | {Duration} |
```

### 9. Alternative Review

```markdown
## 9. Alternative Review

### 9.1 Reviewed Alternatives

#### Alternative A: {Name}
- **Description**: {Description}
- **Pros**: {Pros}
- **Cons**: {Cons}

#### Alternative B: {Name}
- **Description**: {Description}
- **Pros**: {Pros}
- **Cons**: {Cons}

### 9.2 Selection Rationale
{Reason for choosing current design and rationale for rejecting alternatives}
```

### 10. Appendix

```markdown
## 10. Appendix

### 10.1 Glossary

| Term | Definition |
|------|------|
| {Term} | {Definition} |

### 10.2 References
- [{Resource name}]({URL or file path})
```

## Per-Type Required/Optional Mapping

### Feature Design (feature-design)

| Section | Required/Optional | Notes |
|------|----------|------|
| 1. Overview | Required | |
| 2. Goals & Non-Goals | **Required** | Goals 3+, Non-Goals 2+ |
| 3. Detailed Design | Optional | 3.3 API Design only if applicable |
| 4. Requirements | **Required** | Both FR and NFR |
| 5. Dependencies & Constraints | Optional | |
| 6. Success Metrics & Test Criteria | **Required** | |
| 7. Risks & Mitigation | Optional | |
| 8. Milestones & Timeline | Optional | |
| 9. Alternative Review | Optional | |
| 10. Appendix | Optional | |

### System Architecture (system-architecture)

| Section | Required/Optional | Notes |
|------|----------|------|
| 1. Overview | Required | |
| 2. Goals & Non-Goals | Required | |
| 3. Detailed Design | **Required** | Architecture, data model, sequence required |
| 4. Requirements | Optional | Detailed FR optional |
| 5. Dependencies & Constraints | **Required** | |
| 6. Success Metrics & Test Criteria | Optional | |
| 7. Risks & Mitigation | **Required** | |
| 8. Milestones & Timeline | Optional | |
| 9. Alternative Review | Required | |
| 10. Appendix | Optional | |

### API Spec (api-spec)

| Section | Required/Optional | Notes |
|------|----------|------|
| 1. Overview | Required | |
| 2. Goals & Non-Goals | Required | |
| 3. Detailed Design | **Required** | 3.3 API Design required |
| 4. Requirements | **Required** | Include error codes |
| 5. Dependencies & Constraints | **Required** | Include auth/authz |
| 6. Success Metrics & Test Criteria | Optional | |
| 7. Risks & Mitigation | Optional | |
| 8. Milestones & Timeline | Optional | |
| 9. Alternative Review | Optional | |
| 10. Appendix | Optional | |

## Markdown Rules

1. **GFM standard**: Use GitHub Flavored Markdown only
2. **Links**: Use standard links `[text](file.md)` only. No `[[wiki links]]`
3. **Diagrams**: Use Mermaid code blocks (````mermaid`)
4. **Code blocks**: Specify language (````json`, ````yaml`, ````sql`, etc.)
5. **Tables**: GFM pipe table format
6. **Heading hierarchy**: Start from `##` (H2). `#` (H1) corresponds to document title (frontmatter title)
