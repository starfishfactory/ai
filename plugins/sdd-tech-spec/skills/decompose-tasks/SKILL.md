---
name: decompose-tasks
description: Decompose Tech Spec into implementation tasks (Generator-Critic loop)
context: fork
allowed-tools: Read, Write, Glob, Grep, Bash, Task, AskUserQuestion
argument-hint: "<spec file path>"
---

# Task Decomposition: $ARGUMENTS

Decompose a Tech Spec into implementation tasks using task-planner/task-critic Generator-Critic loop.

## Phase 0: Spec Loading

### Step 0.1: Read Spec
Read the spec file from `$ARGUMENTS`. Extract:
- spec-type from YAML frontmatter
- tier from YAML frontmatter (default: standard)
- Goals, FR, NFR, dependencies

### Step 0.2: Validate Spec
Verify spec has minimum required elements:
- Goals section with ≥2 items
- At least 1 FR

If insufficient, warn user and ask whether to proceed.

### Step 0.3: Output Path
Use AskUserQuestion to confirm output path.
Default: same directory as spec file.

### Load Skills
Read the following skill files:
- `skills/sdd-framework/SKILL.md`
- `skills/task-format/SKILL.md`
- `skills/task-format/references/task-template.md`

## Phase 1: Generator-Critic Loop (max 2 iterations)

Iteration N (N = 1, 2):

### Step 1.N.1: Invoke Task Planner
Invoke task-planner via Task tool:
- **Prompt**: Read and include `agents/task-planner.md` content
- **Input**:
  - (N=1): Full spec text + task-format SKILL content
  - (N>1): Previous task output + Critic feedback JSON
- **subagent_type**: `general-purpose`
- **Output**: Write to `{output-path}/_tasks-v{N}.md`

### Step 1.N.2: Invoke Task Critic
Invoke task-critic via Task tool:
- **Prompt**: Read and include `agents/task-critic.md` content
- **Input**: `_tasks-v{N}.md` content + original spec (for coverage check)
- **subagent_type**: `general-purpose`
- **Output**: Write to `{output-path}/_task-review-v{N}.json`

### Step 1.N.3: Verdict
Check score and verdict from `_task-review-v{N}.json`:
- **PASS** (>=80): End loop, proceed to Phase 2
- **REVISE** (60-79): Proceed to next iteration
- **FAIL** (<60): Use AskUserQuestion:
  - "Continue": Proceed to next iteration
  - "Cancel": Preserve temp files and exit

### If PASS not achieved after 2 iterations
Proceed to Phase 2 with last version. Include residual issues in output.

## Phase 2: User Review

### Step 2.1: Present Tasks
Display task summary to user:
- Total tasks, complexity distribution
- Phase breakdown
- Coverage matrix
- Mermaid dependency graph

### Step 2.2: User Adjustment
Use AskUserQuestion: "Adjust tasks, approve, or cancel?"
- **Approve**: Proceed to Phase 3
- **Adjust**: Apply user changes, skip re-evaluation
- **Cancel**: Preserve temp files and exit

## Phase 3: Final Output

### Step 3.1: Save Task File
Save to `{output-path}/{spec-slug}-tasks.md`
- Include YAML frontmatter with source-spec reference
- Include all phases, tasks, dependency graph, coverage matrix

### Step 3.2: Clean Up
Use AskUserQuestion to confirm temp file retention:
- "Delete": Remove `_tasks-*`, `_task-review-*`
- "Keep": Leave for debugging/history

### Step 3.3: Result Summary
Output:
- Final score and verdict
- Total tasks and complexity distribution
- Number of iterations
- Residual issues (if any)
- File path
