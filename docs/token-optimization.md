# Token Optimization Guide

## Classification Principle

Runtime-loaded files → English telegraphic. Non-loaded → keep Korean.
Key question: "Does Claude context window consume this file at runtime?"

## Target Files (English Telegraphic)

- `commands/*.md` — slash command prompts
- `agents/*.md` — agent prompts
- `skills/**/SKILL.md` — skill prompts

Style: English imperative/telegraphic. Short phrases, drop filler words.

## Non-Target Files (Korean OK)

- `README.md` — user-facing docs
- `scripts/*.sh` — run as external shell (hooks, statusline)
- `tests/*.sh` — developer manual tests
- `*.json` — config/manifests (no prose)
- `install.sh` / `uninstall.sh` — one-time scripts

NOTE: `scripts/` and `tests/` were initially misclassified as targets,
then reverted (commits 044f42c→7b4e4c0, 5d9ab4d→489e7ea).

## Special Case: CLAUDE.md

Loaded every conversation as project instructions.
Keep Korean for readability, but minimize length — every line costs tokens.

## New File Rule

Write target files in English telegraphic FROM THE START.
No Korean-draft-then-convert workflow. Frontmatter also in English.

## Semantic Preservation

Must preserve:
- frontmatter (`---`, description, allowed-tools, argument-hint)
- tool calls (Bash, Read, AskUserQuestion)
- conditional branches (if/else, error flows)
- output schemas/templates
- code block contents

Allowed: shorten descriptions, remove blank lines, simplify headings.
Forbidden: skip steps, drop conditions, remove error handling.

## Conversion Patterns

- Korean sentences → English imperative/lists (25-30% savings)
- Table headers → English (`아이콘/항목/설명` → `Icon/Item/Description`)
- Comments → concise English (`# skip blank/comment lines`)

Example:
```
Bad:  "사용자 입력이 없으면 기본값을 사용합니다"
Good: "No input → use default"
```

## Verification

1. Measure: `python3 scripts/measure-tokens.py --baseline <plugin-dir>`
   Target: 25-40% reduction on target files
2. Completeness: all Steps/Phases, tool calls, error branches preserved
