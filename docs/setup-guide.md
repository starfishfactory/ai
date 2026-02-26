# 에이전트 설정 가이드

에이전트를 `~/.claude/agents/`에 심볼릭 링크로 연결하여 사용한다. 자동 설정 스크립트 또는 수동 명령어로 설정할 수 있다.

## 팩 구성

### Core Pack (4개)

```
agents/core/
├── code-reviewer.md
├── test-generator.md
├── debug-expert.md
└── korean-docs.md
```

### Advanced Pack (3개)

Core Pack을 포함하며, 추가 에이전트를 제공한다.

```
agents/advanced/
├── dfs.md
├── security-auditor.md
└── github-projects-manager.md
```

## 자동 설정 (권장)

```bash
./scripts/setup.sh
```

실행하면 팩을 선택할 수 있다. 기존 설정이 있으면 덮어쓴다.

## 수동 설정

```bash
mkdir -p ~/.claude/agents
```

Core Pack만 설치하는 경우:

```bash
ln -sf $(pwd)/agents/core/*.md ~/.claude/agents/
```

Advanced Pack(Core 포함)을 설치하는 경우:

```bash
ln -sf $(pwd)/agents/core/*.md ~/.claude/agents/
ln -sf $(pwd)/agents/advanced/*.md ~/.claude/agents/
```

## 설정 확인

```bash
ls -la ~/.claude/agents/
```

정상적으로 설정되면 각 `.md` 파일이 원본 경로를 가리키는 심볼릭 링크로 표시된다.

## 문제 해결

### 에이전트가 표시되지 않을 때

심볼릭 링크 상태를 확인하고, 깨진 링크가 있으면 제거 후 재설정한다.

```bash
# 링크 상태 확인
ls -la ~/.claude/agents/

# 깨진 링크 제거
find ~/.claude/agents/ -type l ! -exec test -e {} \; -delete

# 재설정
./scripts/setup.sh
```

### 깨진 링크 일괄 수정

저장소 경로가 변경된 경우, 기존 링크를 모두 제거하고 다시 설정한다.

```bash
rm -f ~/.claude/agents/*.md
./scripts/setup.sh
```
