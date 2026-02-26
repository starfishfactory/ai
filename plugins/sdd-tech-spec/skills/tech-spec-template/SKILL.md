---
name: tech-spec-template
description: Tech Spec GFM output template and per-type required/optional section mapping
user-invocable: false
---

# Tech Spec GFM Output Template

Reference template for SDD Tech Spec output format.

## Quick Reference

- **Frontmatter**: YAML with title, status, tags, created, spec-type
- **10 Sections**: Overview → Goals/Non-Goals → Detailed Design → Requirements → Dependencies → Metrics → Risks → Timeline → Alternatives → Appendix
- **Heading hierarchy**: Start from `##` (H2). `#` (H1) = document title
- **Links**: Standard markdown only `[text](file.md)`. No `[[wiki links]]`
- **Diagrams**: Mermaid code blocks

## Per-Type Required Sections

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
