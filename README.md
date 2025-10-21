# AI Tools & Automation

개인 AI 도구 및 자동화 스크립트 모음

## 📁 프로젝트 구조

```
ai/
├── README.md                       # 프로젝트 개요
├── .gitignore                      # Git 설정
│
├── agents/                         # Claude Code 에이전트
│   ├── README.md                   # 에이전트 가이드
│   ├── core/                       # 핵심 4개
│   ├── advanced/                   # 특수 목적 2개
│   └── templates/                  # 에이전트 템플릿
│
├── hooks/                          # Slack 알림 훅
│   ├── README.md
│   └── install.sh
│
├── scripts/                        # 자동화 스크립트
│   ├── setup.sh
│   ├── github-projects-helper.sh
│   └── TEST_RESULTS.md
│
└── docs/                           # 사용 가이드
    ├── agent-guide.md
    ├── setup-guide.md
    └── github-projects-manager-guide.md
```

---

## 🚀 주요 도구

### 1. [Claude Code 에이전트 라이브러리](./agents)

TDD와 한국어 문서화를 중심으로 한 개인 개발 스타일에 최적화된 서브에이전트 컬렉션

**에이전트 팩:**
- **🚀 Core Pack (4개)**: code-reviewer, test-generator, debug-expert, korean-docs
- **⚡ Advanced Pack (2개)**: security-auditor, github-projects-manager

**설치:**
```bash
./scripts/setup.sh
```

자세한 내용은 [에이전트 가이드](./agents/README.md) 참조

---

### 2. [Slack Notifier 훅](./hooks)

Claude Code 작업 완료 시 Slack으로 자동 알림하는 훅 시스템

**주요 기능:**
- ✅ **각 프롬프트-응답 마다 자동 알림** (UserPromptSubmit 훅)
- 📝 프롬프트 헤더 표시 (200자 제한)
- 💬 응답 메시지 표시 (200자 제한)
- 📁 작업 디렉토리 경로 표시
- 🔄 중복 알림 방지
- 🛡️ 안전한 JSON 처리 (jq)

**설치:**
```bash
cd hooks
chmod +x install.sh
./install.sh
```

자세한 내용은 [설치 가이드](./hooks/README.md) 참조
