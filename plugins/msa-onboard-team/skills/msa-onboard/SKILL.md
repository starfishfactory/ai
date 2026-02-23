---
name: msa-onboard
description: MSA analysis context (C4 reference, output templates, verification standards)
user-invocable: false
---

# MSA Onboarding Analysis Context

Not user-invocable. Provides reference files for `msa-onboard` command and Agent Teams teammates.

## Included Files

| File | Purpose | Consumer |
|------|---------|----------|
| `references/c4-mermaid-reference.md` | C4 level Mermaid syntax + element types | Lead (Phase 3: report generation) |
| `references/output-templates.md` | Markdown templates per output file (Obsidian-compatible) | Lead (Phase 3: report generation) |
| `references/verification-standards.md` | Cross-validation 5 steps + report verification 4 steps | Lead (Phase 2, 4: verification) |

## Analysis Architecture

```
[Phase 0] Lead: project scan + output path confirmation
[Phase 1] 3 Teammates parallel: service-discoverer, infra-analyzer, dependency-mapper → JSON
[Phase 2] Lead: cross-validation → confidence score(0-100) + discrepancy list
[Phase 3] Lead: C4 report generation (output-templates, c4-mermaid-reference)
[Phase 4] Lead: report verification → quality score(0-100) + fix suggestions
[Phase 5] Lead: final output
```

- Phase 1 only uses Agent Teams (3 teammates parallel)
- Phase 2-5 performed by Lead directly
- No agents/ directory (no subagents)
