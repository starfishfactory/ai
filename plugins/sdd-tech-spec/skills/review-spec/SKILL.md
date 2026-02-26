---
name: review-spec
description: SDD quality review of an existing Tech Spec (read-only)
allowed-tools: Read, Grep, Glob, Task
argument-hint: "<Spec file path>"
---

# Tech Spec Review: $ARGUMENTS

Evaluate an existing Tech Spec file against SDD quality criteria.
No file modifications or creations; output evaluation results only.

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
- `skills/quality-criteria/SKILL.md`: Evaluation criteria and deduction tables
- `skills/sdd-framework/SKILL.md`: SDD methodology and type guides

## Step 4: Invoke Critic

Invoke spec-critic via Task tool:
- **Prompt**: Include `agents/spec-critic.md` content
- **Input**:
  - Full spec file content
  - Spec type
  - quality-criteria SKILL evaluation criteria
  - sdd-framework SKILL type guides
- **subagent_type**: `general-purpose`
- **Request**: Return evaluation results in quality-criteria SKILL JSON output format

## Step 5: Output Results

Format and output the Critic's evaluation results for readability.
Do not modify or create any files.

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Tech Spec Review Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

File: {file path}
Type: {spec type}
Score: {total}/100 ({verdict})

Category Scores:
  Completeness:    {score}/{max}
  Specificity:     {score}/{max}
  Consistency:     {score}/{max}
  Feasibility:     {score}/{max}
  Risk Management: {score}/{max}

Major Issues:
  - [{section}] {issue description}
    > {improvement suggestion}

Minor Issues:
  - [{section}] {issue description}
    > {improvement suggestion}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
