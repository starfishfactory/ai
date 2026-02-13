---
name: gitmoji-convention
description: Gitmoji + Conventional Commits 규칙, 브랜치-커밋 타입 매핑, diff 기반 타입 추론 규칙
user-invocable: false
---

# Gitmoji + Conventional Commits 규칙

## Gitmoji 타입 매핑 테이블

| 타입 | Gitmoji | 설명 |
|------|---------|------|
| feat | ✨ | 새로운 기능 |
| fix | 🐛 | 버그 수정 |
| docs | 📝 | 문서 업데이트 |
| style | 🎨 | 코드 포맷팅 (기능 변경 없음) |
| refactor | ♻️ | 리팩토링 |
| test | ✅ | 테스트 추가/수정 |
| chore | 🔧 | 빌드/설정 변경 |
| perf | ⚡ | 성능 개선 |
| ci | 💚 | CI 설정 변경 |
| build | 📦 | 빌드 시스템/의존성 |
| revert | ⏪ | 이전 커밋 되돌리기 |

---

## Conventional Commits 형식

```
<gitmoji> <type>(<scope>): <subject>

<body>

<footer>
```

- **subject**: 50자 이내, 명령형, 소문자 시작, 마침표 없음
- **body**: 변경 이유와 이전 동작과의 차이 설명 (3개 이상 파일 변경 시 추가)
- **footer**: Breaking Changes, 이슈 참조 등

---

## 브랜치 타입 → 커밋 타입 매핑

| 브랜치 접두사 | 커밋 타입 | Gitmoji |
|---------------|-----------|---------|
| feat/* | feat | ✨ |
| fix/* | fix | 🐛 |
| chore/* | chore | 🔧 |
| docs/* | docs | 📝 |
| refactor/* | refactor | ♻️ |
| test/* | test | ✅ |
| perf/* | perf | ⚡ |

---

## Diff 기반 타입 추론 규칙 (파일 패턴)

| 파일 패턴 | 추론 타입 |
|-----------|-----------|
| `*.test.*`, `*_test.*`, `*.spec.*`, `**/tests/**`, `**/test/**`, `**/__tests__/**` | test ✅ |
| `*.md`, `docs/**`, `README*`, `LICENSE*`, `CHANGELOG*` | docs 📝 |
| `Dockerfile`, `.github/**`, `*.yml` (CI), `.gitlab-ci.yml`, `Jenkinsfile` | ci 💚 |
| `package.json`만, `pom.xml`만, `build.gradle*`만, `go.mod`만 | chore 🔧 |
| `.gitignore`, `.eslintrc*`, `tsconfig.json`, `.prettierrc*` | chore 🔧 |
| `src/**` 신규 파일 추가 | feat ✨ |
| 복합 변경 (위 패턴 혼합) | 사용자에게 선택 요청 |

---

## 타입 결정 우선순위

1. **브랜치명에서 추출한 타입** — 브랜치 접두사가 위 매핑 테이블에 있으면 해당 타입 사용
2. **Diff 파일 패턴 추론** — 변경된 파일들의 패턴이 단일 타입에 수렴하면 해당 타입 사용
3. **AskUserQuestion으로 사용자 입력** — 위 두 방법으로 결정 불가 시 사용자에게 선택 요청

---

## Scope 결정 규칙 (선택)

- 변경 파일들의 공통 상위 디렉토리명 사용
  - 예: `src/auth/login.ts`, `src/auth/oauth.ts` → scope=`auth`
- 단일 파일 변경 → scope 생략 가능
- 모노레포 → 패키지명 사용
