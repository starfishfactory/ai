# Market Analyst Plugin (시장분석 전문가 플러그인)

학술적 방법론에 기반한 시장분석 전문가 Claude Code 플러그인입니다.

## 개요

| 항목 | 내용 |
|------|------|
| **버전** | 1.0.0 |
| **라이선스** | MIT |
| **품질 표준** | ISO 20252:2019 |

## 핵심 방법론

| 프레임워크 | 창시자 | 연도 | 용도 |
|------------|--------|------|------|
| **Porter's Five Forces** | Michael E. Porter (Harvard) | 1979 | 산업 경쟁환경 분석 |
| **PESTEL Analysis** | Francis J. Aguilar (Harvard) | 1967 | 거시환경 분석 |
| **SWOT Analysis** | Albert S. Humphrey (SRI) | 1960s | 내부역량/외부환경 분석 |
| **TAM/SAM/SOM** | - | - | 시장 규모 추정 |
| **BCG/McKinsey Matrix** | BCG, McKinsey | 1970s | 포트폴리오 분석 |

## 설치

```bash
# 프로젝트 범위 설치
claude plugin install market-analyst --scope project

# 로컬 테스트
claude run --plugin-dir /path/to/market-analyst
```

## 명령어

| 명령어 | 설명 | 예시 |
|--------|------|------|
| `/pestel` | PESTEL 거시환경 분석 | `/pestel 전기차 산업` |
| `/porter` | Porter's Five Forces 분석 | `/porter 클라우드 서비스 시장` |
| `/swot` | SWOT 분석 및 전략 도출 | `/swot 테슬라` |
| `/market-size` | TAM/SAM/SOM 시장규모 추정 | `/market-size AI SaaS` |
| `/competitor` | 경쟁사 분석 | `/competitor 애플, 삼성, 화웨이` |
| `/full-analysis` | 종합 시장분석 | `/full-analysis 한국 이커머스 시장` |

## 구조

```
market-analyst/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 메타데이터
├── skills/                  # 지식 베이스 (6개)
│   ├── iso-20252-standards.md
│   ├── porter-five-forces.md
│   ├── pestel-framework.md
│   ├── swot-framework.md
│   ├── market-sizing-methods.md
│   └── consulting-frameworks.md
├── agents/                  # 전문 에이전트 (5개)
│   ├── macro-analyst.md
│   ├── competitive-analyst.md
│   ├── strategic-analyst.md
│   ├── market-sizer.md
│   └── report-synthesizer.md
├── commands/                # 슬래시 명령어 (6개)
│   ├── pestel.md
│   ├── porter.md
│   ├── swot.md
│   ├── market-size.md
│   ├── competitor.md
│   └── full-analysis.md
├── .mcp.json               # MCP 서버 설정
├── PLAN.md                 # 개발 계획서
└── README.md               # 사용 가이드
```

## 스킬 (Skills)

에이전트가 참조하는 지식 베이스입니다.

| 스킬 | 내용 |
|------|------|
| `iso-20252-standards.md` | ISO 20252:2019 시장조사 품질 표준 |
| `porter-five-forces.md` | Porter 5 Forces 이론 및 분석 방법 |
| `pestel-framework.md` | PESTEL 분석 프레임워크 |
| `swot-framework.md` | SWOT/TOWS 분석 방법론 |
| `market-sizing-methods.md` | TAM/SAM/SOM 시장규모 추정 방법 |
| `consulting-frameworks.md` | BCG/McKinsey 컨설팅 프레임워크 |

## 에이전트 (Agents)

특정 분석 영역을 담당하는 전문가 AI입니다.

| 에이전트 | 역할 |
|----------|------|
| `macro-analyst` | PESTEL 거시환경 분석 |
| `competitive-analyst` | Porter's Five Forces 경쟁 분석 |
| `strategic-analyst` | SWOT 분석 및 전략 도출 |
| `market-sizer` | TAM/SAM/SOM 시장규모 추정 |
| `report-synthesizer` | 종합 보고서 작성 |

## 사용 예시

### 1. PESTEL 분석

```
/pestel 전기차 산업
```

**출력**: 정치적, 경제적, 사회적, 기술적, 환경적, 법적 요인 분석

### 2. Porter's Five Forces 분석

```
/porter 클라우드 서비스 시장
```

**출력**: 5가지 경쟁요인 분석 및 산업 매력도 평가

### 3. SWOT 분석

```
/swot 테슬라
```

**출력**: SWOT 매트릭스 + TOWS 전략 도출

### 4. 시장규모 추정

```
/market-size AI SaaS 시장
```

**출력**: TAM/SAM/SOM 추정 및 성장 전망

### 5. 종합 분석

```
/full-analysis 한국 이커머스 시장
```

**출력**: PESTEL + Porter + SWOT + 시장규모 종합 보고서

## 출력 품질 기준

### ISO 20252:2019 준수
- 방법론 명시
- 출처 표기
- 가정 및 한계 명시
- 데이터 검증

### 분석 요건
- 정량적 데이터 포함
- 복수 출처 교차 검증
- 트렌드 방향 명시
- 전략적 시사점 도출

## 참고 문헌

1. Porter, M.E. (1979). "How Competitive Forces Shape Strategy", Harvard Business Review
2. Porter, M.E. (2008). "The Five Competitive Forces That Shape Strategy", Harvard Business Review
3. Aguilar, F.J. (1967). "Scanning the Business Environment", Harvard University
4. Humphrey, A.S. (1960-1970). SWOT Analysis, Stanford Research Institute
5. ISO 20252:2019 - Market, opinion and social research

## 라이선스

MIT License

---

**Made with Claude Code Plugin System**
