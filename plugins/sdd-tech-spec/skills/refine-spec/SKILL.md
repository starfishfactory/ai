---
name: refine-spec
description: Apply feedback to an existing Tech Spec for one-pass improvement
context: fork
allowed-tools: Read, Write, Glob, Grep, Task, AskUserQuestion
argument-hint: "<Spec file path>"
---

# Tech Spec Refinement: $ARGUMENTS

Run one Generator-Critic loop on an existing Tech Spec file to improve quality.
Back up the original as `.bak` file and overwrite with the improved version.

## Step 1: Read Spec File

Read the file at `$ARGUMENTS` path using Read.
If the file does not exist, output an error message and exit.

## Step 2: Detect Spec Type

Check the `spec-type` field in YAML frontmatter:
- `feature-design`: Feature Design
- `system-architecture`: System Architecture
- `api-spec`: API Spec
- Missing or other value: Treat as "other"

## Step 3: Load Skills and Agent Prompts

Read the following files:
- `agents/spec-critic.md`: Critic agent prompt
- `agents/spec-generator.md`: Generator agent prompt
- `skills/quality-criteria/SKILL.md`: Evaluation criteria and deduction tables
- `skills/sdd-framework/SKILL.md`: SDD methodology and type guides
- `skills/tech-spec-template/SKILL.md`: Output template
- `skills/spec-examples/SKILL.md`: Writing pattern examples

## Step 4: Invoke Critic (Evaluate Current State)

Invoke spec-critic via Task tool:
- **Prompt**: Include `agents/spec-critic.md` content
- **Input**: Full spec content, spec type, quality-criteria SKILL, sdd-framework SKILL
- **subagent_type**: `general-purpose`
- **Output**: Obtain feedback JSON

Output current score and key issues summary to user.

## Step 5: Invoke Generator (Apply Feedback)

Invoke spec-generator via Task tool:
- **Prompt**: Include `agents/spec-generator.md` content
- **Input**:
  - Full original spec
  - Full Critic feedback JSON
  - Spec type
  - Related skill content (tech-spec-template, spec-examples, sdd-framework)
- **subagent_type**: `general-purpose`
- **Request**: Output full improved spec with feedback applied

## Step 6: Backup and Save

1. Copy original file to `{original-filename}.bak` (Bash `cp`)
2. Write improved spec to original path using Write

## Step 7: Post-Improvement Re-evaluation (optional)

Re-evaluate improved spec with Critic to confirm score change.
This step is for result summary only; no additional iterations.

## Step 8: Output Result Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Tech Spec Refinement Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

File: {file path}
Backup: {backup file path}

Score Change: {before} -> {after} ({verdict})

Category Changes:
  Completeness:    {before} -> {after}
  Specificity:     {before} -> {after}
  Consistency:     {before} -> {after}
  Feasibility:     {before} -> {after}
  Risk Management: {before} -> {after}

Key Improvements:
  - {improvement 1}
  - {improvement 2}

Residual Issues (if any):
  - {unresolved issue}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
