# Light Tier Tech Spec Template

Abbreviated template for small changes (bug fix, config change, hotfix).
1–2 pages. Focus on what changes and why.

## YAML Frontmatter

```yaml
---
title: {Spec title}
status: draft
tags: [{tags}]
created: {YYYY-MM-DD}
spec-type: {feature-design | system-architecture | api-spec}
tier: light
---
```

## Section Structure

### 1. Overview

```markdown
## 1. Overview

### 1.1 Problem
{What is broken or needs changing. 2-3 sentences.}

### 1.2 Motivation
{Why now. Business/technical driver.}
```

### 2. Goals & Non-Goals

```markdown
## 2. Goals & Non-Goals

### 2.1 Goals
1. {Goal 1}
2. {Goal 2}

### 2.2 Non-Goals
1. {Explicit exclusion}
```

### 3. Solution

```markdown
## 3. Solution

{Describe the approach. Include code snippets or diagrams if helpful.}

### 3.1 Changes

| File/Component | Change | Reason |
|---------------|--------|--------|
| {path} | {what changes} | {why} |
```

### 4. Requirements

```markdown
## 4. Requirements

| ID | Requirement | Acceptance Criteria | Priority |
|----|------------|-------------------|----------|
| FR-001 | {Description} | {Verifiable criteria} | P0 |
```

### 5. Risks (optional)

```markdown
## 5. Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| {Risk} | {Impact} | {Response} |
```

## Notes

- Mermaid diagrams: optional (include only if clarifying)
- Alternative review: not required
- NFR: include only if relevant (e.g., performance-sensitive fix)
- Timeline: not required (implied: small scope)
