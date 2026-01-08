# 시장분석 전문가 플러그인 개발 계획서

## 📋 개요

| 항목 | 내용 |
|------|------|
| **플러그인명** | market-analyst |
| **버전** | 1.0.0 |
| **목적** | 학술적 근거에 기반한 시장분석 전문가 AI 플러그인 |
| **준수 표준** | ISO 20252:2019 (시장조사 품질관리) |

---

## 🎯 핵심 방법론 (학술적 출처)

### 채택 프레임워크

| 프레임워크 | 창시자 | 연도 | 출처 | 용도 |
|------------|--------|------|------|------|
| **Porter's Five Forces** | Michael E. Porter | 1979 | Harvard Business Review | 산업 경쟁환경 분석 |
| **PESTEL Analysis** | Francis J. Aguilar | 1967 | "Scanning the Business Environment" | 거시환경 분석 |
| **SWOT Analysis** | Albert S. Humphrey | 1960s | Stanford Research Institute | 내부역량/외부환경 분석 |
| **TAM/SAM/SOM** | - | - | 업계 표준 | 시장 규모 추정 |
| **BCG Matrix** | Boston Consulting Group | 1970s | BCG | 포트폴리오 분석 |
| **GE/McKinsey Matrix** | McKinsey & Company | 1970s | McKinsey | 사업부 우선순위 |

---

## 📁 최종 디렉토리 구조

```
plugins/market-analyst/
├── .claude-plugin/
│   └── plugin.json              # 플러그인 메타데이터
│
├── skills/                      # 지식 베이스 (Phase 2)
│   ├── iso-20252-standards.md   # ISO 품질 표준
│   ├── porter-five-forces.md    # Porter 이론 상세
│   ├── pestel-framework.md      # PESTEL 이론 상세
│   ├── swot-framework.md        # SWOT 이론 상세
│   ├── market-sizing-methods.md # TAM/SAM/SOM 방법론
│   └── consulting-frameworks.md # BCG/McKinsey 매트릭스
│
├── agents/                      # 전문 에이전트 (Phase 3)
│   ├── macro-analyst.md         # PESTEL 거시환경 분석가
│   ├── competitive-analyst.md   # Porter 경쟁환경 분석가
│   ├── strategic-analyst.md     # SWOT 전략 분석가
│   ├── market-sizer.md          # 시장규모 추정 전문가
│   └── report-synthesizer.md    # 종합 리포트 작성자
│
├── commands/                    # 슬래시 명령어 (Phase 4)
│   ├── pestel.md                # /pestel [산업]
│   ├── porter.md                # /porter [산업]
│   ├── swot.md                  # /swot [기업/제품]
│   ├── market-size.md           # /market-size [시장]
│   ├── competitor.md            # /competitor [경쟁사목록]
│   └── full-analysis.md         # /full-analysis [주제]
│
├── .mcp.json                    # MCP 서버 설정 (Phase 5)
├── README.md                    # 사용 가이드
└── CHANGELOG.md                 # 변경 이력
```

---

## 🔧 Phase 1: 플러그인 기초 설정

### 1.1 plugin.json 작성

```json
{
  "name": "market-analyst",
  "version": "1.0.0",
  "description": "학술적 방법론 기반 시장분석 전문가 플러그인 (Porter, PESTEL, SWOT, TAM/SAM/SOM)",
  "author": {
    "name": "starfishfactory"
  },
  "license": "MIT",
  "keywords": [
    "market-analysis",
    "porter-five-forces",
    "pestel",
    "swot",
    "tam-sam-som",
    "competitive-analysis"
  ],
  "commands": "./commands/",
  "agents": "./agents/",
  "skills": "./skills/",
  "mcpServers": "./.mcp.json"
}
```

### 1.2 작업 항목
- [ ] 디렉토리 구조 생성
- [ ] plugin.json 작성
- [ ] README.md 초안 작성

### 1.3 예상 산출물
- `plugins/market-analyst/.claude-plugin/plugin.json`
- `plugins/market-analyst/README.md`

---

## 📚 Phase 2: 스킬(Skills) 모듈 개발

스킬은 에이전트가 참조하는 **지식 베이스**입니다. 각 분석 프레임워크의 이론적 배경, 분석 방법, 템플릿을 포함합니다.

### 2.1 iso-20252-standards.md
ISO 20252:2019 시장조사 품질 표준 요약
- 조사 계획 수립 기준
- 데이터 수집 품질 요건
- 결과 보고 표준

### 2.2 porter-five-forces.md
Porter의 5가지 경쟁요인 분석
- **출처**: Porter, M.E. (1979). "How Competitive Forces Shape Strategy", Harvard Business Review
- **구성요소**:
  1. 신규 진입자 위협 (Threat of New Entrants)
  2. 공급자 교섭력 (Bargaining Power of Suppliers)
  3. 구매자 교섭력 (Bargaining Power of Buyers)
  4. 대체재 위협 (Threat of Substitutes)
  5. 기존 경쟁자 간 경쟁 (Industry Rivalry)
- **분석 템플릿 포함**

### 2.3 pestel-framework.md
PESTEL 거시환경 분석
- **출처**: Aguilar, F.J. (1967). "Scanning the Business Environment", Harvard
- **구성요소**:
  1. Political (정치적)
  2. Economic (경제적)
  3. Social (사회적)
  4. Technological (기술적)
  5. Environmental (환경적)
  6. Legal (법적)
- **분석 템플릿 포함**

### 2.4 swot-framework.md
SWOT 분석
- **출처**: Humphrey, A.S. (1960s). Stanford Research Institute
- **구성요소**:
  - Internal: Strengths, Weaknesses
  - External: Opportunities, Threats
- **TOWS 매트릭스 전략 도출 방법 포함**

### 2.5 market-sizing-methods.md
TAM/SAM/SOM 시장규모 추정
- **Top-Down 방식**: 전체 시장 → 세분화
- **Bottom-Up 방식**: 단위 판매량 × 가격
- **계산 공식 및 예시**

### 2.6 consulting-frameworks.md
컨설팅 회사 프레임워크
- **BCG Growth-Share Matrix**: Stars, Cash Cows, Question Marks, Dogs
- **GE/McKinsey 9-Box Matrix**: 산업 매력도 vs 경쟁 강점

### 2.7 작업 항목
- [ ] iso-20252-standards.md 작성
- [ ] porter-five-forces.md 작성
- [ ] pestel-framework.md 작성
- [ ] swot-framework.md 작성
- [ ] market-sizing-methods.md 작성
- [ ] consulting-frameworks.md 작성

---

## 🤖 Phase 3: 에이전트(Agents) 개발

각 에이전트는 특정 분석 영역을 담당하는 **전문가 AI**입니다.

### 3.1 macro-analyst.md (거시환경 분석가)
```yaml
역할: PESTEL 프레임워크 기반 거시환경 분석
참조 스킬: pestel-framework.md, iso-20252-standards.md
출력: PESTEL 분석 보고서
```

### 3.2 competitive-analyst.md (경쟁환경 분석가)
```yaml
역할: Porter's Five Forces 기반 산업 경쟁구조 분석
참조 스킬: porter-five-forces.md
출력: 산업 경쟁력 분석 보고서
```

### 3.3 strategic-analyst.md (전략 분석가)
```yaml
역할: SWOT 분석 및 전략 도출
참조 스킬: swot-framework.md
출력: SWOT 매트릭스 + TOWS 전략
```

### 3.4 market-sizer.md (시장규모 추정 전문가)
```yaml
역할: TAM/SAM/SOM 시장규모 추정
참조 스킬: market-sizing-methods.md
출력: 시장규모 추정 보고서 (Top-Down + Bottom-Up)
```

### 3.5 report-synthesizer.md (종합 리포트 작성자)
```yaml
역할: 개별 분석 결과를 종합하여 최종 보고서 작성
참조 스킬: 모든 스킬
출력: 종합 시장분석 보고서
```

### 3.6 작업 항목
- [ ] macro-analyst.md 작성
- [ ] competitive-analyst.md 작성
- [ ] strategic-analyst.md 작성
- [ ] market-sizer.md 작성
- [ ] report-synthesizer.md 작성

---

## ⌨️ Phase 4: 슬래시 명령어(Commands) 개발

사용자가 직접 호출하는 **인터페이스**입니다.

### 4.1 명령어 목록

| 명령어 | 용도 | 호출 에이전트 |
|--------|------|--------------|
| `/pestel [산업]` | 거시환경 분석 | macro-analyst |
| `/porter [산업]` | 경쟁환경 분석 | competitive-analyst |
| `/swot [기업/제품]` | SWOT 분석 | strategic-analyst |
| `/market-size [시장]` | 시장규모 추정 | market-sizer |
| `/competitor [기업1,기업2,...]` | 경쟁사 비교 | competitive-analyst |
| `/full-analysis [주제]` | 종합 분석 | 모든 에이전트 순차 호출 |

### 4.2 명령어 파일 구조 예시

```markdown
---
description: PESTEL 거시환경 분석 실행
allowed-tools: WebSearch, WebFetch, Read, Write
---

# PESTEL 거시환경 분석

## 분석 대상
$ARGUMENTS

## 지시사항
1. pestel-framework 스킬을 참조하여 분석 수행
2. 각 요소(P,E,S,T,E,L)별 현황 조사
3. 시사점 도출
4. 표 형식으로 결과 정리
```

### 4.3 작업 항목
- [ ] pestel.md 작성
- [ ] porter.md 작성
- [ ] swot.md 작성
- [ ] market-size.md 작성
- [ ] competitor.md 작성
- [ ] full-analysis.md 작성

---

## 🔌 Phase 5: MCP 서버 연동 설정

외부 데이터 소스 연동을 위한 MCP 설정입니다.

### 5.1 .mcp.json 설정

```json
{
  "mcpServers": {
    "web-search": {
      "command": "npx",
      "args": ["@anthropic/mcp-server-fetch"],
      "description": "웹 검색 및 데이터 수집"
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "./reports"],
      "description": "분석 보고서 저장"
    }
  }
}
```

### 5.2 향후 확장 가능한 데이터 소스
- 금융 데이터 API (Yahoo Finance, Alpha Vantage)
- 뉴스 API (NewsAPI, Google News)
- 산업 보고서 (Statista, IBISWorld)

### 5.3 작업 항목
- [ ] .mcp.json 작성
- [ ] MCP 서버 연동 테스트

---

## 📝 Phase 6: 테스트 및 문서화

### 6.1 테스트 시나리오

| 테스트 | 명령어 | 예상 결과 |
|--------|--------|----------|
| PESTEL 테스트 | `/pestel 전기차 산업` | 6개 요소별 분석 표 |
| Porter 테스트 | `/porter 클라우드 서비스` | 5 Forces 분석 결과 |
| SWOT 테스트 | `/swot 테슬라` | SWOT 매트릭스 |
| 시장규모 테스트 | `/market-size AI SaaS` | TAM/SAM/SOM 추정치 |
| 종합 테스트 | `/full-analysis 한국 이커머스` | 종합 보고서 |

### 6.2 문서화 항목
- [ ] README.md 완성
- [ ] 각 명령어 사용 예시
- [ ] 출력 예시 스크린샷
- [ ] CHANGELOG.md 작성

### 6.3 작업 항목
- [ ] 단위 테스트 수행
- [ ] 통합 테스트 수행
- [ ] README.md 완성
- [ ] CHANGELOG.md 작성

---

## 📅 실행 순서 요약

```
Phase 1: 기초 설정
    ├── 1.1 디렉토리 생성
    ├── 1.2 plugin.json 작성
    └── 1.3 README.md 초안

Phase 2: 스킬 개발 (지식 베이스)
    ├── 2.1 ISO 표준
    ├── 2.2 Porter Five Forces
    ├── 2.3 PESTEL
    ├── 2.4 SWOT
    ├── 2.5 TAM/SAM/SOM
    └── 2.6 컨설팅 프레임워크

Phase 3: 에이전트 개발
    ├── 3.1 거시환경 분석가
    ├── 3.2 경쟁환경 분석가
    ├── 3.3 전략 분석가
    ├── 3.4 시장규모 전문가
    └── 3.5 종합 리포트 작성자

Phase 4: 명령어 개발
    ├── 4.1 /pestel
    ├── 4.2 /porter
    ├── 4.3 /swot
    ├── 4.4 /market-size
    ├── 4.5 /competitor
    └── 4.6 /full-analysis

Phase 5: MCP 연동
    ├── 5.1 .mcp.json 설정
    └── 5.2 연동 테스트

Phase 6: 테스트 및 문서화
    ├── 6.1 기능 테스트
    ├── 6.2 문서 완성
    └── 6.3 릴리스
```

---

## 📚 참고 문헌

1. Porter, M.E. (1979). "How Competitive Forces Shape Strategy", Harvard Business Review
2. Porter, M.E. (2008). "The Five Competitive Forces That Shape Strategy", Harvard Business Review
3. Aguilar, F.J. (1967). "Scanning the Business Environment", Harvard University
4. Humphrey, A.S. et al. (1960-1970). Stanford Research Institute TAPP Research
5. ISO 20252:2019 - Market, opinion and social research
6. BCG (1970s). Growth-Share Matrix
7. McKinsey & Company. GE/McKinsey Matrix

---

## ✅ 승인

이 계획서를 기반으로 개발을 진행합니다.

- 작성일: 2026-01-08
- 작성자: Claude Code
- 상태: 검토 대기
