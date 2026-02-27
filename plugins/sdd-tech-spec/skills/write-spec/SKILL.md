---
name: write-spec
description: Write a Tech Spec using SDD methodology (Generator-Critic loop with tier system)
context: fork
allowed-tools: Read, Write, Glob, Grep, Bash, Task, AskUserQuestion
argument-hint: "<Spec topic/feature description>"
---

# Tech Spec Writing: $ARGUMENTS

Write a Tech Spec based on SDD (Specification-Driven Development) methodology.
Use Generator-Critic loop pattern: generate draft > critique > improve, iterating until quality threshold is met.

## Phase 0: Context Collection

### Step 0.0: Discuss Linkage
Check for `_discuss-summary.md` in current directory:
- **If found**: Read and load as context. Inform user: "Found discussion summary. Using it as input."
  - Extract suggested spec-type and tier from summary
  - Pre-fill Goals/Non-Goals from summary scope section
- **If not found**: Use AskUserQuestion: "Run `/sdd-tech-spec:discuss` first to explore requirements, or proceed directly?"
  - "Discuss first": Instruct user to run discuss command, then re-run write-spec
  - "Proceed": Continue to Step 0.1

### Step 0.1: Select Spec Type
Use AskUserQuestion to confirm spec type:
- **Feature Design** (feature-design): User stories, interface contracts, acceptance criteria
- **System Architecture** (system-architecture): C4 model, inter-service communication, data flow
- **API Spec** (api-spec): Endpoints, request/response schemas, error codes
- **Other**: Apply generic template

If discuss summary suggested a spec-type, present it as default.

### Step 0.2: Select Tier
Determine tier using auto-selection heuristics from tier-system SKILL:
1. Check if user explicitly specified tier
2. Match topic keywords: fix/patch/config → Light, feature/api → Standard, architecture/migration → Deep
3. If project path available, estimate changed files: <5 → Light, 5-20 → Standard, >20 → Deep
4. Use AskUserQuestion to confirm suggested tier:
   - **Light**: 1-2 pages, G-C loop max 1, PASS >= 70 — for bug fix, config change
   - **Standard**: 5-10 pages, G-C loop max 3, PASS >= 80 — for features, API changes
   - **Deep**: 10-20 pages, G-C loop max 5, PASS >= 85 — for new systems, migrations

If discuss summary suggested a tier, present it as default.

### Step 0.3: Project Path (optional)
Use AskUserQuestion to get project path for code analysis.
Default: "none" (skip code analysis).

### Step 0.4: Output Path
Use AskUserQuestion to confirm output path.
Default: `./docs/specs/`

### Step 0.5: Project Context Scan (if project path provided)
Auto-scan the following when project path is provided:
- Directory structure (Glob `**/*`) > reflect in architecture section
- Build files (Glob `**/package.json`, `**/pom.xml`, `**/build.gradle*`, `**/Cargo.toml`, `**/go.mod`) > reflect in dependencies section
- Existing API endpoints (Grep `@(Get|Post|Put|Delete|Patch)Mapping|router\.(get|post|put|delete)|app\.(get|post|put|delete)`) > reflect in API spec section
- Tech stack detection > reflect in detailed design section

### Load Skills
Read the following skill files for context:
- `skills/sdd-framework/SKILL.md`
- `skills/tier-system/SKILL.md`
- `skills/tech-spec-template/SKILL.md`
- `skills/quality-criteria/SKILL.md`
- `skills/spec-examples/SKILL.md`

## Phase 1: Goals/Non-Goals Confirmation

### Step 1.1: Generate Goals/Non-Goals Draft
Invoke spec-generator via Task tool:
- **Prompt**: Read and include `agents/spec-generator.md` content
- **Input**: Topic (`$ARGUMENTS`), spec type, tier, project context, discuss summary (if available)
- **Request**: Draft Goals/Non-Goals only (not full spec)
- **subagent_type**: `general-purpose`

### Step 1.2: User Confirmation
Use AskUserQuestion to present Goals/Non-Goals draft and request confirmation/revision.
Save user-revised content as confirmed Goals/Non-Goals.

## Phase 2: Generator-Critic Loop

Max iterations by tier: **Light: 1** / **Standard: 3** / **Deep: 5**

Iteration N (N = 1, 2, ... max):

### Step 2.N.1: Invoke Generator
Invoke spec-generator via Task tool:
- **Prompt**: Read and include `agents/spec-generator.md` content
- **Input**:
  - (N=1): Topic, confirmed Goals/Non-Goals, spec type, tier, project context, related skill content
  - (N>1): Previous spec draft full text + Critic feedback JSON full text
- **subagent_type**: `general-purpose`
- **Output**: Write to `{output-path}/_draft-v{N}.md`

### Step 2.N.2: Invoke Critic
Invoke spec-critic via Task tool:
- **Prompt**: Read and include `agents/spec-critic.md` content
- **Input**: `_draft-v{N}.md` content + original requirements (topic, Goals/Non-Goals) + tier
- **subagent_type**: `general-purpose`
- **Output**: Write to `{output-path}/_review-v{N}.json`

### Step 2.N.3: Verdict
Check `score` and `verdict` from `_review-v{N}.json` (thresholds per tier):
- **PASS**: End loop, proceed to Phase 3
- **REVISE**: Proceed to next iteration (output score and key issues summary)
- **FAIL**: Use AskUserQuestion to request choice:
  - "Continue": Proceed to next iteration (same as REVISE)
  - "Revise": Reset Goals/Non-Goals, return to Phase 1
  - "Cancel": Preserve temp files and exit

### If PASS not achieved after max iterations
Proceed to Phase 3 with last version.
Include residual issue list from last review JSON in final output.

## Phase 3: Final Output

### Step 3.1: Save Final Spec
Save confirmed spec to `{output-path}/{title-slug}.md`.
- Filename: Convert title to kebab-case slug (transliterate Korean to English)
- Finalize YAML frontmatter metadata:
  ```yaml
  ---
  title: {Spec title}
  status: draft
  tags: [{related tags}]
  created: {today YYYY-MM-DD}
  spec-type: {selected type}
  tier: {selected tier}
  ---
  ```

### Step 3.2: Clean Up Temp Files
Use AskUserQuestion to confirm temp file (`_draft-*`, `_review-*`, `_discuss-summary.md`) retention:
- "Delete": Remove via Bash rm `{output-path}/_draft-*` `{output-path}/_review-*`
- "Keep": Leave as-is (for debugging/history)

### Step 3.3: Result Summary
Output the following:
- Final score, verdict, and tier
- Number of Generator-Critic iterations
- Residual issue list (if any)
- Final file path
- Suggested next step: `/sdd-tech-spec:decompose-tasks {file-path}` for task breakdown
