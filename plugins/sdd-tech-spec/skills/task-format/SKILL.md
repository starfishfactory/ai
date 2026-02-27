---
name: task-format
description: Task decomposition output format definition
user-invocable: false
---

# Task Output Format

Standard format for decomposed tasks from Tech Spec.

## Document Structure

```markdown
---
title: Tasks — {Spec Title}
source-spec: {spec-filename.md}
created: {YYYY-MM-DD}
total-tasks: {N}
complexity-summary: "S:{n}, M:{n}, L:{n}, XL:{n}"
---

## Phase 1: {Phase Name}

### T-001: {Task Title}
- **Complexity**: S/M/L/XL
- **Spec refs**: FR-001, Goal 1
- **Dependencies**: none
- **Description**: {1-2 sentences}
- **Acceptance criteria**:
  - [ ] {Criterion 1}
  - [ ] {Criterion 2}

## Dependency Graph

\`\`\`mermaid
graph TD
    T001[T-001: Title] --> T003[T-003: Title]
    T002[T-002: Title] --> T003
\`\`\`

## Coverage Matrix

| Spec Element | Tasks |
|-------------|-------|
| FR-001 | T-001, T-003 |
| Goal 1 | T-001, T-002 |
```

## Field Definitions

| Field | Required | Description |
|-------|----------|-------------|
| ID | Yes | T-NNN format, sequential |
| Title | Yes | Verb + object, concise action |
| Complexity | Yes | S(<2h) / M(2-8h) / L(1-2d) / XL(3-5d) |
| Spec refs | Yes | FR/Goal/NFR IDs this task fulfills |
| Dependencies | Yes | Task IDs or "none" |
| Description | Yes | Implementation scope, 1-2 sentences |
| Acceptance criteria | Yes | 2-3 checkboxes, verifiable |

## Phase Grouping

| Phase | Purpose | Typical Tasks |
|-------|---------|---------------|
| 1: Foundation | Setup, data models, core interfaces | Schema, project setup, base classes |
| 2: Core | Main feature implementation | Business logic, API endpoints |
| 3: Integration | Cross-cutting, wiring | Auth, logging, monitoring hooks |
| 4: Polish | Quality, docs, edge cases | Tests, docs, error handling |

## Complexity Guide

| Size | Duration | Scope Example |
|------|----------|---------------|
| S | <2 hours | Config change, single-file edit |
| M | 2-8 hours | New endpoint, model + migration |
| L | 1-2 days | Feature module, multi-file change |
| XL | 3-5 days | Subsystem, cross-service change |

XL tasks should be reviewed for splitting. Tasks >5d must be split.

## Full Template

Read `references/task-template.md` for the complete template with examples.
