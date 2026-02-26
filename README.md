# starfishfactory/ai

Claude Code 플러그인과 에이전트를 모아놓은 저장소이다.

## 플러그인

마켓플레이스 또는 `--plugin-dir`로 설치할 수 있다.

| 플러그인 | 설명 | 마켓플레이스 |
|---------|------|:----------:|
| [lean-kit](plugins/lean-kit/) | macOS 알림, 퍼미션 자동 승인, statusline, 일일 리포트 | ✓ |
| [git](plugins/git/) | Gitmoji 스마트 커밋, 브랜치/PR 자동화 | ✓ |
| [market-analyst](plugins/market-analyst/) | PESTEL, Porter, SWOT, 시장규모 추정 | ✓ |
| [msa-onboard-team](plugins/msa-onboard-team/) | MSA 병렬 분석, C4 모델 리포트 생성 | ✓ |
| [sdd-tech-spec](plugins/sdd-tech-spec/) | SDD 방법론 기반 Tech Spec 작성 | ✓ |
| [conventions](plugins/conventions/) | 팀 코딩 컨벤션 및 표준 | ✓ |

### 빠른 설치

마켓플레이스에서 설치하는 방법이다.

```shell
/plugin marketplace add starfishfactory/ai
/plugin install lean-kit@starfishfactory-ai
```

로컬 디렉토리로 직접 설치하는 방법이다.

```shell
claude --plugin-dir ./plugins/lean-kit
```

## 에이전트

`~/.claude/agents/`에 심볼릭 링크로 설치하는 서브에이전트 라이브러리이다.

| 팩 | 에이전트 | 설명 |
|---|---------|------|
| Core | code-reviewer | 코드 가독성/유지보수성 검토 |
| Core | test-generator | TDD 테스트 케이스 생성 |
| Core | debug-expert | 디버깅 및 문제 해결 |
| Core | korean-docs | 한국어 기술 문서 작성 |
| Advanced | dfs | API 기능명세(DFS) 문서 작성 |
| Advanced | security-auditor | OWASP 기반 보안 검토 |
| Advanced | github-projects-manager | GitHub Projects 칸반 관리 |

자세한 내용은 [에이전트 가이드](agents/README.md)를 참고하라.

## 훅

| 훅 | 설명 |
|---|------|
| [Slack Notifier](hooks/) | Claude Code 작업 완료 시 Slack DM 자동 알림 |

## 구조

```
ai/
├── plugins/                        # Claude Code 플러그인
│   ├── lean-kit/
│   ├── git/
│   ├── market-analyst/
│   ├── msa-onboard-team/
│   ├── sdd-tech-spec/
│   └── conventions/
├── agents/                         # 서브에이전트 라이브러리
│   ├── core/
│   ├── advanced/
│   └── templates/
├── hooks/                          # Slack 알림 훅
├── docs/                           # 가이드 문서
└── .claude-plugin/
    └── marketplace.json            # 마켓플레이스 등록 정보
```
