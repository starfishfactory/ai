# 🔧 Claude Code 에이전트 설정 가이드

> 심볼릭 링크를 활용한 효율적인 에이전트 관리 방법

## 📋 목차

1. [설정 방식 선택](#설정-방식-선택)
2. [사용자 레벨 설정 (추천)](#사용자-레벨-설정-추천)
3. [프로젝트별 설정](#프로젝트별-설정)
4. [선택적 설정](#선택적-설정)
5. [자동화 스크립트](#자동화-스크립트)
6. [문제 해결](#문제-해결)

---

## 설정 방식 선택

### 🌟 사용자 레벨 설정 (추천)
- **위치**: `~/.claude/agents/`
- **범위**: 모든 프로젝트에서 사용 가능
- **장점**: 한 번 설정으로 어디서든 사용
- **적합한 경우**: 개인 개발 환경

### 🎯 프로젝트별 설정
- **위치**: `[프로젝트]/.claude/agents/`
- **범위**: 해당 프로젝트에서만 사용
- **장점**: 프로젝트 특화 에이전트 가능
- **적합한 경우**: 팀 프로젝트, 특별한 요구사항

---

## 사용자 레벨 설정 (추천)

### 1. 디렉토리 생성
```bash
mkdir -p ~/.claude/agents
```

### 2. 전체 에이전트 링크
```bash
# 모든 에이전트를 한 번에 링크
ln -sf ~/molidae/ai/claude-code/agents/*/* ~/.claude/agents/
```

### 3. 설정 확인
```bash
# 링크된 에이전트 확인
ls -la ~/.claude/agents/

# 예상 결과:
# code-reviewer.json -> ~/molidae/ai/claude-code/agents/core/code-reviewer.json
# test-generator.json -> ~/molidae/ai/claude-code/agents/core/test-generator.json
# tdd-coach.json -> ~/molidae/ai/claude-code/agents/personal/tdd-coach.json
# ...
```

### 4. Claude Code에서 확인
```bash
# Claude Code 실행 후
/agents
```

---

## 프로젝트별 설정

### 1. 프로젝트 디렉토리에서 실행
```bash
# 프로젝트 루트에서
mkdir -p .claude/agents
```

### 2. 필요한 에이전트만 선택적 링크
```bash
# Core 에이전트 (기본)
ln -sf ~/molidae/ai/claude-code/agents/core/*.json ./.claude/agents/

# Personal 에이전트 (개인화)
ln -sf ~/molidae/ai/claude-code/agents/personal/*.json ./.claude/agents/

# 특정 Specialized 에이전트만
ln -sf ~/molidae/ai/claude-code/agents/specialized/api-architect.json ./.claude/agents/
```

### 3. 프로젝트별 커스터마이징
```bash
# 프로젝트 특화 에이전트 생성
cp ~/molidae/ai/claude-code/agents/core/code-reviewer.json ./.claude/agents/project-reviewer.json

# 프로젝트에 맞게 수정
vim ./.claude/agents/project-reviewer.json
```

---

## 선택적 설정

### 카테고리별 설정

#### Core 에이전트만 (최소 구성)
```bash
ln -sf ~/molidae/ai/claude-code/agents/core/*.json ~/.claude/agents/
```

#### Core + Personal 에이전트 (개인 개발)
```bash
ln -sf ~/molidae/ai/claude-code/agents/core/*.json ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/personal/*.json ~/.claude/agents/
```

#### 전체 에이전트 (완전 구성)
```bash
ln -sf ~/molidae/ai/claude-code/agents/*/*.json ~/.claude/agents/
```

### 개별 에이전트 설정
```bash
# 특정 에이전트만 선택
ln -sf ~/molidae/ai/claude-code/agents/personal/tdd-coach.json ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/core/test-generator.json ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/specialized/api-architect.json ~/.claude/agents/
```

---

## 자동화 스크립트

### setup.sh 스크립트 생성
```bash
#!/bin/bash
# ~/molidae/ai/claude-code/scripts/setup.sh

echo "🤖 Claude Code 에이전트 설정을 시작합니다..."

# 사용자 레벨 디렉토리 생성
mkdir -p ~/.claude/agents

# 기존 링크 제거 (선택사항)
read -p "기존 에이전트를 모두 제거하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f ~/.claude/agents/*
    echo "✅ 기존 에이전트를 제거했습니다."
fi

# 설정 방식 선택
echo "설정 방식을 선택하세요:"
echo "1) 전체 에이전트 (추천)"
echo "2) Core 에이전트만"
echo "3) Core + Personal 에이전트"
echo "4) 개별 선택"

read -p "선택 (1-4): " -n 1 -r
echo

case $REPLY in
    1)
        ln -sf ~/molidae/ai/claude-code/agents/*/*.json ~/.claude/agents/
        echo "✅ 전체 에이전트를 설정했습니다."
        ;;
    2)
        ln -sf ~/molidae/ai/claude-code/agents/core/*.json ~/.claude/agents/
        echo "✅ Core 에이전트를 설정했습니다."
        ;;
    3)
        ln -sf ~/molidae/ai/claude-code/agents/core/*.json ~/.claude/agents/
        ln -sf ~/molidae/ai/claude-code/agents/personal/*.json ~/.claude/agents/
        echo "✅ Core + Personal 에이전트를 설정했습니다."
        ;;
    4)
        echo "개별 선택 모드는 수동으로 설정해주세요."
        echo "예시: ln -sf ~/molidae/ai/claude-code/agents/core/code-reviewer.json ~/.claude/agents/"
        ;;
    *)
        echo "❌ 잘못된 선택입니다."
        exit 1
        ;;
esac

# 설정 확인
echo ""
echo "📋 설정된 에이전트 목록:"
ls -la ~/.claude/agents/

echo ""
echo "🎉 설정이 완료되었습니다!"
echo "Claude Code에서 '/agents' 명령으로 확인하세요."
```

### 스크립트 실행 권한 부여 및 실행
```bash
chmod +x ~/molidae/ai/claude-code/scripts/setup.sh
~/molidae/ai/claude-code/scripts/setup.sh
```

---

## 문제 해결

### 일반적인 문제들

#### 1. 에이전트가 표시되지 않음
**원인**: 심볼릭 링크가 제대로 생성되지 않음

**해결책**:
```bash
# 링크 상태 확인
ls -la ~/.claude/agents/

# 깨진 링크 제거
find ~/.claude/agents/ -type l ! -exec test -e {} \; -delete

# 다시 링크 생성
ln -sf ~/molidae/ai/claude-code/agents/*/*.json ~/.claude/agents/
```

#### 2. 권한 문제
**원인**: 파일 권한 부족

**해결책**:
```bash
# 권한 확인 및 수정
chmod 644 ~/molidae/ai/claude-code/agents/*/*.json
chmod 755 ~/.claude/agents/
```

#### 3. 경로 문제
**원인**: 상대 경로 사용으로 인한 문제

**해결책**:
```bash
# 절대 경로 사용 확인
realpath ~/molidae/ai/claude-code/agents/

# 정확한 절대 경로로 재설정
ln -sf $(realpath ~/molidae/ai/claude-code/agents)/*/*.json ~/.claude/agents/
```

### 에이전트 업데이트

#### 에이전트 파일 수정 후 반영
```bash
# 심볼릭 링크는 자동으로 최신 내용을 반영
# Claude Code 재시작만 하면 됨
```

#### 새로운 에이전트 추가 후 반영
```bash
# 새 에이전트 링크 추가
ln -sf ~/molidae/ai/claude-code/agents/새카테고리/새에이전트.json ~/.claude/agents/
```

### 디버깅 명령어

#### 설정 상태 확인
```bash
# 에이전트 디렉토리 확인
ls -la ~/.claude/agents/

# 심볼릭 링크 대상 확인
readlink ~/.claude/agents/*

# Claude Code 설정 디렉토리 확인
ls -la ~/.claude/
```

#### 에이전트 JSON 유효성 검사
```bash
# JSON 문법 검사
for file in ~/molidae/ai/claude-code/agents/*/*.json; do
    echo "Checking $file"
    jq empty "$file" && echo "✅ Valid" || echo "❌ Invalid"
done
```

---

## 추가 팁

### 백업 생성
```bash
# 현재 설정 백업
cp -r ~/.claude/agents/ ~/.claude/agents.backup.$(date +%Y%m%d)
```

### 프로젝트별 에이전트 관리
```bash
# 프로젝트별 설정 스크립트
echo '#!/bin/bash
mkdir -p .claude/agents
ln -sf ~/molidae/ai/claude-code/agents/core/*.json ./.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/personal/tdd-coach.json ./.claude/agents/
echo "프로젝트 에이전트 설정 완료"' > setup-project-agents.sh

chmod +x setup-project-agents.sh
```

### 성능 최적화
```bash
# 사용하지 않는 에이전트 제거로 성능 향상
rm ~/.claude/agents/불필요한에이전트.json
```

---

*설정 과정에서 문제가 발생하면 GitHub Issues에 문의해주세요! 🙋‍♂️*