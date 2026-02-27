---
name: discuss
description: Socratic requirements exploration before spec writing
context: fork
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
argument-hint: "<topic or feature to explore>"
---

# Requirements Discussion: $ARGUMENTS

Socratic exploration of requirements before writing a Tech Spec.
Adaptive questioning — adjust depth based on user responses. Skip phases when answers are already clear.

## Phase 1: Problem Framing

Ask via AskUserQuestion (adapt based on context, do not ask mechanically):
- What problem does this solve?
- What is the current situation? What's broken or missing?
- Why is this needed now? What triggered this work?
- Who reported this need? (user feedback, metric, tech debt, etc.)

If project path available, scan codebase for relevant context:
- Glob for related files/modules
- Grep for related keywords, TODOs, FIXMEs

Summarize understanding before proceeding. Ask user to confirm or correct.

## Phase 2: Scope Exploration

Ask via AskUserQuestion:
- What is the smallest version that delivers value? (MVP scope)
- What is explicitly out of scope? (future phases, non-goals)
- Are there related features or systems affected?
- Any hard deadlines or constraints?

If codebase context available, suggest scope based on code structure.

## Phase 3: Users & Stakeholders

Ask via AskUserQuestion:
- Who are the primary users? (roles, personas)
- How do they interact with this? (UI, API, CLI, background)
- What defines success from the user's perspective?
- Are there secondary stakeholders? (ops, security, compliance)

## Phase 4: Technical Constraints

Ask via AskUserQuestion:
- What existing systems must this integrate with?
- Are there technology constraints? (language, framework, infra)
- Performance requirements? (latency, throughput, availability)
- Security/compliance requirements?

If project path available, auto-detect:
- Tech stack from build files
- Existing architecture from directory structure
- Current dependencies

## Phase 5: Synthesis & Handoff

### Step 5.1: Generate Summary
Synthesize all responses into `_discuss-summary.md`:

```markdown
---
title: Discussion Summary — {Topic}
created: {YYYY-MM-DD}
topic: {$ARGUMENTS}
---

## Problem Statement
{Synthesized problem description}

## Scope

### In Scope
- {item}

### Out of Scope
- {item}

## Users & Success Criteria
- Primary users: {who}
- Success criteria: {what}

## Technical Context
- Existing systems: {what}
- Constraints: {what}
- Tech stack: {detected or stated}

## Suggested Spec Type
{feature-design / system-architecture / api-spec} — because {reason}

## Suggested Tier
{light / standard / deep} — because {reason}

## Key Decisions
- {Decision 1}: {rationale}

## Open Questions
- {Unresolved question}
```

### Step 5.2: Save and Handoff
Save `_discuss-summary.md` to current directory (or output path if specified).
Inform user:
- Summary file path
- Suggested next step: `/sdd-tech-spec:write-spec {topic}` (will auto-detect summary)

## Adaptive Principles

1. **No mechanical lists**: Adapt questions to user's responses. If Phase 1 answers already cover scope, shorten Phase 2
2. **Early exit**: If requirements are already clear (e.g., user provides detailed brief), skip to Phase 5
3. **Code-informed**: Use codebase scan results to ask targeted questions
4. **One question at a time**: Ask 1-2 questions per turn, not a wall of questions
5. **Summarize often**: Reflect understanding back to user before moving to next phase
