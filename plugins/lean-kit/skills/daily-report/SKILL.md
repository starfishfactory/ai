---
name: daily-report
description: Generate daily Claude CLI activity report from session data
context: fork
allowed-tools: Read, Write, Bash, Task, Glob, Grep, AskUserQuestion
argument-hint: "[YYYY-MM-DD] (default: yesterday)"
---

# Daily Report Orchestrator

Generate a daily Claude CLI activity report by collecting session data and running a Generator-Critic verification loop.

## Phase 0: Data Collection

Collect session data using the Node.js script (zero LLM token consumption).

### Step 0.1: Determine Target Date

Parse the user argument for a date. Default: yesterday (KST).

```
TARGET_DATE = argument or yesterday
```

### Step 0.2: Check Existing Report

Check if a report already exists at `~/.claude/daily-reports/{TARGET_DATE}/report.md`.

If it exists, use AskUserQuestion to confirm overwrite:
> A report for {TARGET_DATE} already exists. Overwrite? (yes/no)

If the user says no, stop.

### Step 0.3: Run Data Collection Script

Find the script path relative to this SKILL.md file, then execute:

```bash
# The script is at: ../../scripts/collect-session-data.mjs (relative to this SKILL.md)
# Resolve the absolute path first:
SCRIPT_DIR=$(cd "$(dirname "$(find . -path '*/lean-kit/scripts/collect-session-data.mjs' -print -quit 2>/dev/null || echo 'plugins/lean-kit/scripts/collect-session-data.mjs')")" && pwd)
node "$SCRIPT_DIR/collect-session-data.mjs" {TARGET_DATE}
```

Alternatively, use Glob to find `**/lean-kit/scripts/collect-session-data.mjs` and run with the resolved path.

Capture the JSON output. If the output contains `"sessionCount": 0` or no projects, inform the user:
> No session data found for {TARGET_DATE}. Nothing to report.

Then stop.

### Step 0.4: Save Raw Data

Write the collected JSON to a temporary working file:
```
~/.claude/daily-reports/{TARGET_DATE}/_session-data.json
```

### Step 0.5: Check Previous Report

Look for the most recent previous report by checking dates before TARGET_DATE:
```bash
ls -d ~/.claude/daily-reports/*/report.md 2>/dev/null | sort -r | head -5
```

If a previous report exists, note its path for Section 8 trend comparison.

## Phase 1: Generator-Critic Loop

Run up to 2 iterations of generate → review.

### Loop Variables

```
MAX_ITERATIONS = 2
PASS_THRESHOLD = 80
REVISE_THRESHOLD = 60
iteration = 1
```

### Step 1.1: Generate Report (Task → report-generator)

Launch a report-generator agent (sonnet) with:

**Input prompt**:
```
Generate a daily activity report for {TARGET_DATE}.

## Session Data (source of truth)
{contents of _session-data.json}

## Report Template
{contents of references/report-template.md}

## Best Practices Reference
{contents of references/best-practices.md}

## Previous Report (for trend comparison)
{contents of previous report if exists, or "No previous report available — use baseline."}

{if iteration > 1: "## Critic Feedback from Previous Iteration\n" + feedback JSON}

Write the report to: ~/.claude/daily-reports/{TARGET_DATE}/_draft-v{iteration}.md
```

Use `subagent_type: "air-claudecode:software-engineer"` with `model: "sonnet"`.

### Step 1.2: Review Report (Task → report-critic)

Launch a report-critic agent (sonnet) with:

**Input prompt**:
```
Review this daily report for accuracy and completeness.

## Draft Report
{contents of _draft-v{iteration}.md}

## Source JSON Data (ground truth)
{contents of _session-data.json}

## Quality Criteria
{contents of references/quality-criteria.md}

Output your review as a JSON object with: score, verdict, categories, feedback[].
```

Use `subagent_type: "air-claudecode:software-engineer"` with `model: "sonnet"`.

### Step 1.3: Evaluate Verdict

Parse the critic's JSON output.

- **score ≥ 80 (PASS)**: Proceed to Phase 2.
- **score 60–79 (REVISE)**: If iteration < MAX_ITERATIONS, go to Step 1.1 with feedback. Otherwise, proceed to Phase 2 with a note about remaining issues.
- **score < 60 (FAIL)**: Use AskUserQuestion to inform user of critical issues and ask whether to continue, retry, or abort.

### Step 1.4: Save Review

Write the critic's JSON output to:
```
~/.claude/daily-reports/{TARGET_DATE}/_review-v{iteration}.json
```

## Phase 2: Final Output

### Step 2.1: Finalize Report

Copy the passing draft to the final location:
```
~/.claude/daily-reports/{TARGET_DATE}/report.md
```

### Step 2.2: Cleanup

Remove temporary files:
- `_draft-v*.md`
- `_review-v*.json`
- `_session-data.json`

### Step 2.3: Summary

Output a brief summary to the user:

```
✅ Daily report generated: ~/.claude/daily-reports/{TARGET_DATE}/report.md

📊 Summary:
- Sessions: {count}
- Projects: {count}
- Commits: {count}
- Total cost: ${amount}
- Quality score: {score}/100

{if score < 80: "⚠️ Note: Report scored {score}/100. Some issues may remain — review recommended."}
```

## Error Handling

- **Script execution failure**: Report the error and suggest running the script manually for diagnosis.
- **Empty JSON output**: Inform user no data was found for the target date.
- **Agent failure**: If a Task call fails, retry once. If it fails again, report the error.
- **File write failure**: Check directory permissions and report.
