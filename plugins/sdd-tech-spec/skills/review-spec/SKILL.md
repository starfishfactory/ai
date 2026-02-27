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

## Step 2: Detect Spec Type and Tier

Check YAML frontmatter fields:
- `spec-type`: feature-design / system-architecture / api-spec / other (missing = "other")
- `tier`: light / standard / deep (missing = "standard")

## Step 3: Load Skills and Agent Prompts

Read the following files:
- `agents/spec-critic.md`: Critic agent prompt
- `skills/quality-criteria/SKILL.md`: Evaluation criteria and deduction tables
- `skills/sdd-framework/SKILL.md`: SDD methodology and type guides
- `skills/tier-system/SKILL.md`: Tier definitions and evaluation adjustments

## Step 4: Invoke Critic

Invoke spec-critic via Task tool:
- **Prompt**: Include `agents/spec-critic.md` content
- **Input**:
  - Full spec file content
  - Spec type, tier
  - quality-criteria SKILL evaluation criteria
  - sdd-framework SKILL type guides
  - tier-system SKILL tier definitions
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
Tier: {tier}
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
