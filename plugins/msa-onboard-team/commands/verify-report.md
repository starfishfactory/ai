---
description: Run cross-validation + quality verification on existing MSA report (Lead performs directly)
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
argument-hint: <report path>
---

# Standalone Report Verification: $ARGUMENTS

## Target

Report path: `$ARGUMENTS`

> If `$ARGUMENTS` is empty, use AskUserQuestion to confirm report path.

## Report File Scan

!`ls -la ${ARGUMENTS:-.} 2>/dev/null`

## Phase 1: Report Existence Check

Verify these files exist:
- `README.md`
- `01-system-context.md`
- `02-container.md`
- `03-components/` (directory)
- `04-service-catalog.md`
- `05-infra-overview.md`
- `06-dependency-map.md`

Notify user if files are missing.

## Phase 2: Analysis Result Reconstruction

Extract analysis results from report content:
- `04-service-catalog.md` → service list
- `05-infra-overview.md` → infra info
- `06-dependency-map.md` → dependency info

If JSON files exist separately (`_service-discovery.json`, `_infra-analysis.json`, `_dependency-map.json`), use them directly.

## Phase 3: Cross-Validation — Generator-Critic Self-Reflection Loop (max 3 rounds)

> **Roles**: Generator = Lead (fix analysis results), Critic = Lead (perform cross-validation). Self-Reflection pattern.
> No Agent Teams used in verify-report; Lead performs both roles.
> Step 3 (completeness check) requires source code comparison — use AskUserQuestion to get original project path.

Reference `verification-standards.md` "Cross-Validation — 5 Steps".

### Loop Procedure (Round 1~3)

Each round:

#### Critic (Lead): Cross-Validation

1. **Service consistency**: service list vs dependency map comparison
2. **Infra-dependency alignment**: infra info vs dependency map comparison
3. **Completeness check**: AskUserQuestion for original project path, then compare source code
4. **Devil's Advocate**: verify `[Needs Verification]` items in source code
5. **Confidence score**: deduction from 100

#### Verdict and Branching

| Score | Verdict | Action |
|-------|---------|--------|
| 80-100 | PASS | Exit loop → proceed to Phase 4 |
| < 80 | WARN/FAIL | Write feedback → Generator(Lead) fixes JSON/report → next round |

#### Generator (Lead): Feedback-Based Fixes

If Critic(Lead) scores below PASS, fix discrepancies directly:
- Unify service name mismatches
- Add missing dependencies/DB connections
- Update `[Needs Verification]` items

### Loop Exit Conditions

| Condition | Action |
|-----------|--------|
| PASS(80+) achieved | Proceed to Phase 4 immediately |
| 3 rounds done, WARN(60-79) | Proceed to Phase 4 with warnings |
| 3 rounds done, FAIL(0-59) | AskUserQuestion: (1) Continue (2) Cancel |

## Phase 4: Report Verification — Generator-Critic Self-Reflection Loop (max 3 rounds)

> **Roles**: Generator = Lead (fix report), Critic = Lead (verify report). Self-Reflection pattern.

Reference `verification-standards.md` "Report Verification — 4 Steps".

### Loop Procedure (Round 1~3)

Each round:

#### Critic (Lead): Report Verification

1. **Mermaid syntax validity**: alias rules, structure, element syntax
2. **Obsidian link validity**: wiki links, frontmatter
3. **C4 model completeness**: Level 1/2/3 required elements
4. **Analysis-report consistency**: reconstructed analysis results vs report comparison

#### Verdict and Branching

| Score | Verdict | Action |
|-------|---------|--------|
| 80-100 | PASS | Exit loop → proceed to Phase 5 |
| < 80 | WARN/FAIL | Write feedback (issue list) → Generator(Lead) fixes → next round |

#### Generator (Lead): Feedback-Based Fixes

If Critic(Lead) scores below PASS, fix `autoFixable` items first:
- Fix Mermaid alias rule violations (e.g., `user-service` → `userservice`)
- Fix broken Obsidian links
- Add missing C4 elements
- Record fix history in `_report-audit.json` `fixHistory`

### Loop Exit Conditions (Report Verification)

| Condition | Action |
|-----------|--------|
| PASS(80+) achieved | Proceed to Phase 5 immediately |
| 3 rounds done, 60+ | Proceed to Phase 5 with warnings |
| 3 rounds done, < 60 | `Quality verification failed` warning + error list + manual fix guide |

## Phase 5: Result Output

Present to user:

1. **Confidence score** (cross-validation): score/100
   - 80-100: PASS
   - 60-79: WARN — summary of items needing manual review
   - 0-59: FAIL — major issue list
2. **Quality score** (report verification): score/100
   - 80-100: PASS
   - 60-79: WARN — auto-fixed/unfixed items summary
   - 0-59: FAIL — error list + manual fix guide
3. **Discovered issues** (sorted by severity)
4. **Fix suggestions** (auto-fixable status indicated)
