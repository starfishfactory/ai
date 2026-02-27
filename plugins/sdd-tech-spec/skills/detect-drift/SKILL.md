---
name: detect-drift
description: Detect drift between Tech Spec and implementation code
context: fork
allowed-tools: Read, Write, Glob, Grep, Bash, Task, AskUserQuestion
argument-hint: "<spec file path>"
---

# Drift Detection: $ARGUMENTS

Compare Tech Spec against actual codebase to detect divergence (drift).

## Phase 0: Setup

### Step 0.1: Read Spec
Read spec file from `$ARGUMENTS`. Extract spec-type, tier from YAML frontmatter.

### Step 0.2: Project Path
Use AskUserQuestion to get project root path for code scanning.
No default — project path is required for drift detection.

### Step 0.3: Load Skills
Read `skills/sdd-framework/SKILL.md` for spec type context.

## Phase 1: Extract Spec Elements

Parse spec to build verifiable element list:

### API Endpoints (from Sections 3.3, 4)
Extract: HTTP method, path, request schema, response schema, error codes

### Data Models (from Section 3.2)
Extract: Entity/table names, field names, field types, constraints

### Dependencies (from Section 5)
Extract: Library/service names, version constraints

### Configuration (from Section 5.2, any config refs)
Extract: Config key names, expected types/values

## Phase 2: Code Scan

Invoke drift-analyzer via Task tool:
- **Prompt**: Read and include `agents/drift-analyzer.md` content
- **Input**: Extracted spec elements + project path
- **subagent_type**: `general-purpose`
- **Task**: For each element type, scan codebase and classify

## Phase 3: Report Generation

### Step 3.1: Generate Drift Report
Write report to `{spec-directory}/{spec-slug}-drift.md`:

```markdown
---
title: Drift Report — {Spec Title}
source-spec: {spec-filename}
scanned: {YYYY-MM-DD}
project-path: {path}
---

## Summary

| Status | Count | Critical | Warning | Info |
|--------|-------|----------|---------|------|
| MATCH | N | - | - | - |
| DRIFT | N | N | N | N |
| MISSING_IN_CODE | N | N | N | N |
| EXTRA_IN_CODE | N | N | N | N |

## Detailed Findings

### API Endpoints
| Spec Element | Code Location | Status | Severity | Detail |
|...|

### Data Models
...

### Dependencies
...

### Configuration
...

## Recommendations
1. {Prioritized action items}
```

### Step 3.2: Result Summary
Output to user:
- Overall drift score (% MATCH)
- Critical findings count
- Report file path
- Recommended actions (update spec or update code)
