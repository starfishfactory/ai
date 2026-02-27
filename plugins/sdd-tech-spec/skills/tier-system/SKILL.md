---
name: tier-system
description: Light/Standard/Deep tier definitions with auto-selection heuristics
user-invocable: false
---

# Spec Tier System

Three complexity tiers govern spec depth, evaluation criteria, and G-C loop iterations.

## Tier Definitions

| Dimension | Light | Standard | Deep |
|-----------|-------|----------|------|
| Pages | 1–2 | 5–10 | 10–20 |
| Min Goals | 2 | 3 | 5 |
| Min Non-Goals | 1 | 2 | 3 |
| Mermaid diagrams | Optional | 1+ required | 3+ required |
| Alternative review | Not required | 2+ alternatives | 3+ alternatives |
| Risks | 1 min | 3 min (1+ per type) | 5+ quantitative matrix |
| G-C loop max | 1 | 3 | 5 |
| PASS threshold | 70 | 80 | 85 |
| Fit | Bug fix, config, hotfix | Mid-size feature, API change | New system, large migration |

## Auto-Selection Heuristics

Apply in priority order:

1. **User explicit**: If user specifies tier, use directly
2. **Keyword match**:
   - Light → fix, patch, config, hotfix, typo, bump, rename, tweak
   - Standard → feature, api, endpoint, service, module, integration
   - Deep → architecture, migration, platform, infrastructure, redesign, rewrite
3. **Code context** (when project path provided):
   - Estimated changed files <5 → Light
   - 5–20 → Standard
   - &gt;20 → Deep
4. **Confirm**: Always present suggested tier via AskUserQuestion before proceeding

## Tier → Template Mapping

| Tier | Template | Section Scope |
|------|----------|---------------|
| Light | `references/light-template.md` | Overview, Goals/Non-Goals, Solution, Requirements, Risks(optional) |
| Standard | `references/full-template.md` | Per spec-type mapping (see tech-spec-template SKILL) |
| Deep | `references/full-template.md` | All 10 sections required + quantitative risk matrix |

## Tier Impact on Evaluation

See quality-criteria SKILL for tier-specific deduction adjustments and PASS thresholds.
