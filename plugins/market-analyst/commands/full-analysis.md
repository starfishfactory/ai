---
description: Run full market analysis (PESTEL + Porter + SWOT + TAM/SAM/SOM)
allowed-tools: WebSearch, WebFetch, Read, Write, Task
argument-hint: <industry/market>
---
# Full Market Analysis: $ARGUMENTS

## Request
Perform full market analysis for **$ARGUMENTS**.

## Analysis Sequence
Use the Task tool to invoke the following agents sequentially:
1. **market-sizer** agent -> TAM/SAM/SOM analysis
2. **macro-analyst** agent -> PESTEL analysis
3. **competitive-analyst** agent -> Porter's Five Forces analysis
4. **strategic-analyst** agent -> SWOT/TOWS analysis
5. **report-synthesizer** agent -> Synthesize final report

## Output Format
```
# [Topic] Full Market Analysis Report

## Executive Summary
- Market size: TAM/SAM/SOM
- Growth outlook: CAGR
- Industry attractiveness: High/Medium/Low
- Key opportunities/threats

## 1. Market Size (TAM/SAM/SOM)
## 2. Macro Environment (PESTEL)
## 3. Competitive Environment (Five Forces)
## 4. SWOT/Strategy
## 5. Strategic Recommendations

## Sources
```

## Quality Criteria
- Cover all analysis areas
- Cite sources
- Comply with ISO 20252 standards
