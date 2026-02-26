# market-analyst

학술적 방법론에 기반한 시장분석 전문가 플러그인이다.

5개 에이전트가 PESTEL, Porter's Five Forces, SWOT, TAM/SAM/SOM 등 학술 프레임워크를 병렬로 분석하여 종합 시장분석 보고서를 생성한다.

## 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/market-analyst:pestel` | PESTEL 거시환경 분석 |
| `/market-analyst:porter` | Porter's Five Forces 분석 |
| `/market-analyst:swot` | SWOT 분석 및 전략 도출 |
| `/market-analyst:market-size` | TAM/SAM/SOM 시장규모 추정 |
| `/market-analyst:competitor` | 경쟁사 분석 |
| `/market-analyst:full-analysis` | 종합 시장분석 |

사용 예시:

```
/market-analyst:pestel 전기차 산업
/market-analyst:porter 클라우드 서비스 시장
/market-analyst:swot 테슬라
/market-analyst:market-size AI SaaS 시장
/market-analyst:competitor 애플, 삼성, 화웨이
/market-analyst:full-analysis 한국 이커머스 시장
```

## 구성 요소

### 에이전트

5개 전문 에이전트가 각 분석 영역을 담당한다.

| 에이전트 | 역할 |
|----------|------|
| `macro-analyst` | PESTEL 거시환경 분석 |
| `competitive-analyst` | Porter's Five Forces 경쟁 분석 |
| `strategic-analyst` | SWOT 분석 및 전략 도출 |
| `market-sizer` | TAM/SAM/SOM 시장규모 추정 |
| `report-synthesizer` | 종합 보고서 작성 |

### 스킬

에이전트가 참조하는 지식 베이스이다.

| 스킬 | 내용 |
|------|------|
| `iso-20252-standards` | ISO 20252:2019 시장조사 품질 표준 |
| `porter-five-forces` | Porter 5 Forces 이론 및 분석 방법 |
| `pestel-framework` | PESTEL 분석 프레임워크 |
| `swot-framework` | SWOT/TOWS 분석 방법론 |
| `market-sizing-methods` | TAM/SAM/SOM 시장규모 추정 방법 |
| `consulting-frameworks` | BCG/McKinsey 컨설팅 프레임워크 |

## 핵심 방법론

| 프레임워크 | 창시자 | 용도 |
|------------|--------|------|
| Porter's Five Forces | Michael E. Porter (Harvard, 1979) | 산업 경쟁환경 분석 |
| PESTEL Analysis | Francis J. Aguilar (Harvard, 1967) | 거시환경 분석 |
| SWOT Analysis | Albert S. Humphrey (SRI, 1960s) | 내부역량/외부환경 분석 |
| TAM/SAM/SOM | - | 시장 규모 추정 |
| BCG/McKinsey Matrix | BCG, McKinsey (1970s) | 포트폴리오 분석 |

## 품질 기준

ISO 20252:2019 시장조사 품질 표준을 준수한다.

- 방법론을 명시한다
- 출처를 표기한다
- 가정 및 한계를 명시한다
- 복수 출처를 교차 검증한다
- 정량적 데이터를 포함한다
- 전략적 시사점을 도출한다

## 설치

### 마켓플레이스 (권장)

```shell
/plugin marketplace add starfishfactory/ai
/plugin install market-analyst@starfishfactory-ai
```

### 플러그인 모드

```bash
claude --plugin-dir ./plugins/market-analyst
```

## 업데이트

### 마켓플레이스

```shell
/plugin marketplace update starfishfactory-ai
```

### 플러그인 모드

```bash
git pull origin main
```

## 제거

### 마켓플레이스

```shell
/plugin uninstall market-analyst@starfishfactory-ai
```

### 플러그인 모드

`--plugin-dir` 옵션을 제거하면 된다.

## 구조

```
plugins/market-analyst/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── competitive-analyst.md
│   ├── macro-analyst.md
│   ├── market-sizer.md
│   ├── report-synthesizer.md
│   └── strategic-analyst.md
├── commands/
│   ├── competitor.md
│   ├── full-analysis.md
│   ├── market-size.md
│   ├── pestel.md
│   ├── porter.md
│   └── swot.md
├── skills/
│   ├── consulting-frameworks/SKILL.md
│   ├── iso-20252-standards/SKILL.md
│   ├── market-sizing-methods/SKILL.md
│   ├── pestel-framework/SKILL.md
│   ├── porter-five-forces/SKILL.md
│   └── swot-framework/SKILL.md
├── .mcp.json
└── README.md
```
