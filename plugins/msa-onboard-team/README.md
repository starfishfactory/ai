# msa-onboard-team

MSA 환경을 **Agent Teams**로 병렬 분석하여 C4 모델 기반 리포트를 생성하는 Claude Code 플러그인입니다.

교차 검증과 리포트 품질 검증을 통해 분석 결과의 신뢰도를 높입니다.

## 주요 기능

- MSA 프로젝트의 서비스 구조, 인프라 설정, 서비스 간 의존성을 **3명의 teammate가 병렬** 분석
- C4 모델 (Level 1/2/3) Mermaid 다이어그램 생성
- Obsidian 호환 마크다운 문서 출력
- Lead가 직접 수행하는 교차 검증 → 신뢰도 점수(0-100)
- Lead가 직접 수행하는 리포트 검증 → 품질 점수(0-100)

## 아키텍처

```
[Phase 0] Lead: 프로젝트 스캔 + 출력 경로 확인
[Phase 1] Teammates 3명 병렬:
           ├── service-discoverer  → _service-discovery.json
           ├── infra-analyzer     → _infra-analysis.json
           └── dependency-mapper  → _dependency-map.json
[Phase 2] Lead: 교차 검증 → 신뢰도 점수(0-100) + 불일치 목록
[Phase 3] Lead: C4 리포트 생성 (output-templates, c4-mermaid-reference 참조)
[Phase 4] Lead: 리포트 검증 → 품질 점수(0-100) + 수정 제안
[Phase 5] Lead: 최종 출력
```

- **Phase 1만 Agent Teams** (3 teammates 병렬). Phase 2-5는 Lead가 직접 수행
- agents/ 디렉토리 없음 (subagent 미사용)
- 설계 근거: 3개 분석기는 상호 통신 불필요한 독립 작업 → Agent Teams에 적합

## 전제조건

### Agent Teams 실험적 기능 활성화 (필수)

미활성화 시 Agent Teams가 동작하지 않습니다.

**방법 1: settings.json**
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**방법 2: 환경변수**
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

> 공식 문서: https://code.claude.com/docs/en/agent-teams#enable-agent-teams

### tmux 또는 iTerm2 (split pane 모드)

```bash
brew install tmux     # macOS
sudo apt install tmux # Linux
```

- iTerm2: `it2` CLI 설치 + Settings → General → Magic → Enable Python API
- In-process mode는 모든 터미널에서 동작 (tmux 불필요)
- **미지원**: VS Code 통합 터미널, Windows Terminal, Ghostty (split pane 모드)

> tmux 레이아웃 파괴 방지를 위해 **새 tmux 세션**에서 실행을 권장합니다.

## 사용법

### 메인 커맨드 (Agent Teams 병렬 분석)

```
/msa-onboard-team:msa-onboard /path/to/project
```

### 추가 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/msa-onboard-team:verify-report <리포트 경로>` | 기존 리포트에 대해 교차 검증 + 품질 검증 |
| `/msa-onboard-team:discover-services <프로젝트 경로>` | 서비스 식별만 단독 실행 |
| `/msa-onboard-team:generate-c4 <프로젝트 경로>` | C4 다이어그램만 단독 생성 |

## 출력 파일 구조

```
{출력경로}/
├── README.md                    # 목차 + 개요 + 검증 결과 요약
├── 01-system-context.md         # Level 1 C4Context 다이어그램
├── 02-container.md              # Level 2 C4Container 다이어그램
├── 03-components/               # Level 3 C4Component (주요 서비스별)
│   ├── {service-1}.md
│   └── {service-2}.md
├── 04-service-catalog.md        # 서비스 목록 + 기술 스택
├── 05-infra-overview.md         # 인프라 구성
├── 06-dependency-map.md         # 의존성 맵 + graph LR 다이어그램
├── _service-discovery.json      # 서비스 식별 원시 결과
├── _infra-analysis.json         # 인프라 분석 원시 결과
├── _dependency-map.json         # 의존성 매핑 원시 결과
├── _cross-validation.json       # 교차 검증 결과
└── _report-audit.json           # 리포트 검증 결과
```

## 검증 기준

### 교차 검증 (Phase 2) — Lead 직접 수행

| 점수 | 판정 | 처리 |
|------|------|------|
| 80-100 | PASS | 리포트 상단 `✅ 신뢰도: N%` |
| 60-79 | WARN | `⚠️ [주의]` 마커 + 부록에 이슈 목록 + "수동 확인 권장" |
| 0-59 | FAIL | 리포트 생성 중단. 사용자에게 선택: (1) 계속 (2) 재분석 (3) 취소 |

### 리포트 검증 (Phase 4) — Lead 직접 수행

| 점수 | 처리 |
|------|------|
| 80-100 | 최종 출력 |
| 60-79 | Mermaid/링크 자동 수정 → 재검증 1회. 미달 시 오류 목록과 함께 출력 |
| 0-59 | `❌ 품질 검증 미달` 경고 + 오류 목록 + 수동 수정 가이드 |

## 비용 경고

| 항목 | 값 |
|------|---|
| 기본 비용 | ~7x tokens (plan mode 기준) |
| Opus teammates | 더 증가. 공홈 권고는 "Use Sonnet for teammates" |
| 유휴 토큰 | teammate 완료 후 미정리 시 유휴 토큰 소비 |

> 엔터프라이즈 플랜에서 Opus 4.6 사용 시 비용이 크게 증가합니다. 커맨드에 "작업 완료 후 팀 정리" 지침이 포함되어 있습니다.

## 공식 제한사항

1. `/resume`으로 teammate 복원 불가
2. teammate 작업 완료 표시 누락 가능 → 수동 확인 후 진행
3. teammate 종료 느림 (현재 작업 완료 후 종료)
4. 세션당 팀 1개만
5. 중첩 팀 불가
6. Lead 고정 (이전/승격 불가)
7. teammate 권한은 spawn 시 Lead 권한 상속
8. Split pane은 tmux/iTerm2 필요

## Agent Teams 훅

| 훅 | exit code 2 동작 |
|---|---|
| `TeammateIdle` | 피드백 보내고 teammate 작업 계속 |
| `TaskCompleted` | 완료 거부 + 피드백 전달 |

## 지원하는 기술 스택

| 영역 | 지원 |
|------|------|
| 언어 | Java, Kotlin, TypeScript, JavaScript, Python, Go, Rust |
| 프레임워크 | Spring Boot, Express, NestJS, FastAPI, Django, Flask, gin, echo |
| 인프라 | Docker Compose, Kubernetes, Helm |
| CI/CD | GitHub Actions, GitLab CI, Jenkins |
| 메시지 큐 | Kafka, RabbitMQ, Redis Pub/Sub |
| 데이터베이스 | PostgreSQL, MySQL, MongoDB, Redis |

## 유지보수 주의사항

- Spawn prompt는 `commands/msa-onboard.md`에 인라인으로 포함되어 있습니다
- 분석 로직 변경 시 spawn prompt도 함께 수정해야 합니다
- `skills/msa-onboard/` 하위 참조 파일 변경 시 커맨드 동작에 영향을 줄 수 있습니다
