# conventions

팀 코딩 컨벤션 및 표준을 자동 로드하는 Claude Code 플러그인이다.

## 기능

세션 시작 시 팀 코딩 표준을 자동으로 컨텍스트에 로드한다. 별도 커맨드 실행 없이 Claude가 팀 컨벤션을 인지한 상태로 코드를 작성한다.

| 영역 | 주요 내용 |
|------|-----------|
| Kotlin/Java | 네이밍, Spring 패턴, 에러 처리 |
| TypeScript | 네이밍, React 패턴, 비동기 처리 |
| General | Git 워크플로우, 코드 리뷰, 문서화 |

`user-invocable: false`로 설정되어 있어 사용자가 직접 호출하지 않고, 자동으로 컨텍스트에 포함된다.

## 설치

### 마켓플레이스 (권장)

클론 없이 Claude Code 안에서 바로 설치한다.

```shell
/plugin marketplace add starfishfactory/ai
/plugin install conventions@starfishfactory-ai
```

### 플러그인 모드

repo를 클론한 후 로컬 경로를 지정한다.

```bash
claude --plugin-dir ./plugins/conventions
```

## 업데이트

### 마켓플레이스

마켓플레이스를 갱신하여 플러그인을 업데이트한다.

```shell
/plugin marketplace update starfishfactory-ai
```

### 플러그인 모드

로컬 저장소를 pull한 후 Claude Code를 재시작한다.

```bash
git pull origin main
```

## 제거

### 마켓플레이스

```shell
/plugin uninstall conventions@starfishfactory-ai
```

### 플러그인 모드

`--plugin-dir` 옵션을 제거하면 된다.

## 구조

```
plugins/conventions/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── coding-standards/
        └── SKILL.md
```
