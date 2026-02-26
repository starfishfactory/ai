# Project Instructions

## Language Rules

- **Code & prompt files** (`.md` in `commands/`, `agents/`, `skills/`): English — optimized for token efficiency and LLM comprehension.
- **README files**: Korean — intended for Korean-speaking end users.

This separation is intentional: prompts are consumed by models (English maximizes clarity per token), while READMEs are consumed by humans (Korean serves the target audience).

## 플러그인 작성 — 토큰 최적화

런타임 로드 파일은 영문 텔레그래픽으로 작성한다:

- `commands/*.md`, `agents/*.md`, `skills/**/SKILL.md`

비대상 파일(`README.md`, `scripts/`, `tests/` 등)은 한국어 유지.

플러그인 파일 생성·수정 시 [`docs/token-optimization.md`](docs/token-optimization.md)를 참조.

## 보안 — 개인 정보 보호

이 저장소는 **public repo**이다.
개인 정보(이메일, API 키, 비밀번호, 개인 경로 등)가 포함된 변경사항은 **절대 push 금지**.

- 커밋 전 개인 정보 노출 여부를 반드시 확인
- `.env`, 크레덴셜 파일 등은 커밋 대상에서 제외
- 의심스러운 경우 push 전 사용자에게 확인 요청
