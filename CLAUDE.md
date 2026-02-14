# CLAUDE.md

## 플러그인 작성 — 토큰 최적화 규칙

플러그인 프롬프트 파일은 런타임에 Claude 컨텍스트 윈도우에 로드되어 토큰을 소비한다.
아래 규칙을 적용하여 토큰 사용량을 최소화한다.

### 대상 파일 (영문 텔레그래픽)

런타임에 로드되어 토큰을 소비하는 파일:

- `commands/*.md` — 슬래시 커맨드 프롬프트
- `agents/*.md` — 에이전트 프롬프트
- `skills/**/SKILL.md` — 스킬 프롬프트

**스타일**: 영어 명령형/텔레그래픽. 짧은 구문, 불필요한 단어 제거.

```
# Bad (한국어, 장황)
# 사용자 입력이 없으면 기본값을 사용합니다
assert "conf 없으면 📁 표시"

# Good (영문 텔레그래픽)
# Use default if no input
assert "No conf: show 📁"
```

### 비대상 파일 (한국어 유지)

런타임에 로드되지 않는 파일 — 한국어 유지:

- `README.md` — 사람을 위한 문서
- `CLAUDE.md` — 프로젝트 지침 (런타임 로드 아님)
- `scripts/*.sh` — 외부 셸 명령으로 실행 (훅, statusline 등)
- `tests/*.sh` — 개발자 수동 실행 테스트
- `*.json` — 설정/매니페스트 (산문 없음)
- `install.sh` / `uninstall.sh` — 1회성 설치 스크립트

### 변환 가이드라인

- 한국어 문장 → 영어 명령형/리스트 (25-30% 토큰 절감)
- 테이블 헤더 → 영문 (`아이콘/항목/설명` → `Icon/Item/Description`)
- 주석 → 간결한 영문 (`# skip blank/comment lines`)
