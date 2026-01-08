---
description: 종합 시장분석 실행 (PESTEL + Porter + SWOT + TAM/SAM/SOM)
allowed-tools: WebSearch, WebFetch, Read, Write, Task
argument-hint: <산업/시장>
---

# 종합 시장분석: $ARGUMENTS

## 분석 요청
**$ARGUMENTS**에 대해 종합 시장분석을 수행하세요.

## 분석 순서
Task 도구를 사용하여 다음 에이전트들을 순차 호출하세요:

1. **market-sizer** 에이전트 → TAM/SAM/SOM 분석
2. **macro-analyst** 에이전트 → PESTEL 분석
3. **competitive-analyst** 에이전트 → Porter's Five Forces 분석
4. **strategic-analyst** 에이전트 → SWOT/TOWS 분석
5. **report-synthesizer** 에이전트 → 종합 보고서 작성

## 출력 형식

```
# [주제] 종합 시장분석 보고서

## Executive Summary
- 시장 규모: TAM/SAM/SOM
- 성장 전망: CAGR
- 산업 매력도: 높음/중간/낮음
- 핵심 기회/위협

## 1. 시장 규모 (TAM/SAM/SOM)
## 2. 거시환경 (PESTEL)
## 3. 경쟁환경 (Five Forces)
## 4. SWOT/전략
## 5. 전략적 권고

## 출처
```

## 품질 기준
- 모든 분석 영역 포함
- 출처 명시
- ISO 20252 표준 준수
