# AI Tools & Automation

개인 AI 도구 및 자동화 스크립트 모음

## 프로젝트

### [Claude Code Slack Notifier](./claude-code/hooks)

Claude Code 작업 완료 시 Slack으로 자동 알림하는 훅 시스템

**주요 기능:**
- ✅ **각 응답 완료 시 자동 알림** (Stop 훅)
- 📝 프롬프트 헤더 표시 (200자 제한)
- 💬 응답 메시지 표시 (200자 제한)
- 📁 작업 디렉토리 경로 표시
- 🔄 중복 알림 방지
- 🛡️ 안전한 JSON 처리 (jq)

**설치:**
```bash
cd claude-code/hooks
chmod +x install.sh
./install.sh
```

자세한 내용은 [설치 가이드](./claude-code/hooks/README.md) 참조
