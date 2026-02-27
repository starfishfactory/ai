---
name: tech-spec-template
description: Tech Spec GFM output template with tier-based and per-type section mapping
user-invocable: false
---

# Tech Spec GFM Output Template

Reference template for SDD Tech Spec output format.

## Quick Reference

- **Frontmatter**: YAML with title, status, tags, created, spec-type, tier
- **10 Sections**: Overview → Goals/Non-Goals → Detailed Design → Requirements → Dependencies → Metrics → Risks → Timeline → Alternatives → Appendix
- **Heading hierarchy**: Start from `##` (H2). `#` (H1) = document title
- **Links**: Standard markdown only `[text](file.md)`. No `[[wiki links]]`
- **Diagrams**: Mermaid code blocks

## Tier-Based Section Requirements

| Section | Light | Standard | Deep |
|---------|:-----:|:--------:|:----:|
| 1. Overview | R | R | R |
| 2. Goals & Non-Goals | R | R | R |
| 3. Detailed Design | Brief | Per-type | **R** (all subsections) |
| 4. Requirements | R (FR only) | R (FR+NFR) | **R** (FR+NFR+acceptance) |
| 5. Dependencies | O | Per-type | **R** |
| 6. Metrics & Tests | O | Per-type | **R** |
| 7. Risks | O (1 min) | Per-type (3 min) | **R** (5+ quantitative) |
| 8. Timeline | O | O | **R** |
| 9. Alternatives | O | Per-type (2+) | **R** (3+) |
| 10. Appendix | O | O | O |

- **Light**: Use `references/light-template.md`
- **Standard**: Use `references/full-template.md` + per-type mapping below
- **Deep**: Use `references/full-template.md` + all sections required

## Per-Type Required Sections (Standard tier)

| Section | Feature Design | System Architecture | API Spec |
|---------|:---:|:---:|:---:|
| 1. Overview | R | R | R |
| 2. Goals & Non-Goals | **R** | R | R |
| 3. Detailed Design | O | **R** | **R** |
| 4. Requirements | **R** | O | **R** |
| 5. Dependencies | O | **R** | **R** |
| 6. Metrics & Tests | **R** | O | O |
| 7. Risks | O | **R** | O |
| 8. Timeline | O | O | O |
| 9. Alternatives | O | R | O |
| 10. Appendix | O | O | O |

R = Required, O = Optional, **R** = Critical required

## Full Template

Read `references/full-template.md` for the complete section-by-section template with examples and detailed formatting rules.
Read `references/light-template.md` for the abbreviated Light tier template.
