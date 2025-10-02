# AI Tools & Automation

개인 AI 도구 및 자동화 스크립트 모음

## 프로젝트

### [Claude Code Slack Notifier](./claude-code/hooks)

Claude Code 작업 완료 시 Slack으로 자동 알림하는 훅 시스템

**주요 기능:**
- ✅ 작업 완료 자동 알림 (간결한 포맷)
- 📝 프롬프트 헤더 표시 (스마트 자르기)
- 💬 응답 메시지 표시 (스마트 자르기)
- 📁 작업 디렉토리 경로 표시
- 🛡️ 안전한 JSON 처리
- 📊 에러 로깅

**설치:**
```bash
cd claude-code/hooks
chmod +x install.sh
./install.sh
```

자세한 내용은 [설치 가이드](./claude-code/hooks/README.md) 참조
