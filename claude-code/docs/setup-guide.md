# 🔧 Claude Code 에이전트 설정 가이드

> 팩 기반 시스템으로 단계별 에이전트 관리

## 📋 목차

1. [팩 기반 설정 시스템](#팩-기반-설정-시스템)
2. [자동 설정 (추천)](#자동-설정-추천)
3. [수동 설정](#수동-설정)
4. [프로젝트별 설정](#프로젝트별-설정)
5. [문제 해결](#문제-해결)
6. [고급 사용법](#고급-사용법)

---

## 팩 기반 설정 시스템

### 🎯 설정 철학
- **점진적 학습**: 작은 것부터 시작해서 단계별 확장
- **사용자 친화**: 첫 사용자도 부담 없이 시작
- **전문가 지원**: 필요에 따라 전문 기능까지

### 📦 팩 구성

#### 🚀 Starter Pack (2개)
```
agents/starter/
├── code-reviewer.json      # 코드 품질/보안/성능 검토
└── test-generator.json     # TDD 기반 테스트 케이스 생성
```
**대상**: Claude Code 에이전트를 처음 사용하는 모든 개발자

#### 🎨 Essential Pack (4개)
```
agents/starter/             # Starter Pack 포함
agents/essential/
├── korean-docs.json        # 한국어 기술 문서 작성
└── debug-expert.json       # 체계적인 문제 해결
```
**대상**: 한국어 문서화와 체계적인 개발 프로세스를 중요시하는 개발자

#### ⚡ Professional Pack (7개)
```
agents/starter/             # Starter Pack 포함
agents/essential/           # Essential Pack 포함
agents/professional/
├── api-architect.json      # REST API 설계 및 구현
├── performance-optimizer.json  # 성능 분석 및 최적화
└── security-auditor.json  # 보안 취약점 분석
```
**대상**: 전문적인 웹 개발, API 개발, 성능/보안이 중요한 프로젝트

---

## 자동 설정 (추천)

### 🤖 설정 스크립트 실행
```bash
~/molidae/ai/claude-code/scripts/setup.sh
```

### 📋 스크립트 옵션
설정 시 다음 중 선택:

1. **🚀 Starter Pack (2개)** - 첫 경험용
   - 부담 없이 핵심 기능만 체험
   - 코드 리뷰와 테스트 생성에 집중

2. **🎨 Essential Pack (4개)** - 일반 사용자 추천
   - 개인 개발 스타일 완전 반영
   - 한국어 문서화 + 체계적 디버깅

3. **⚡ Professional Pack (7개)** - 전문가용
   - 모든 전문 기능 포함
   - API 개발, 성능 최적화, 보안 감사

4. **🛠️ Custom** - 개별 선택 (고급 사용자)

### ✅ 설정 확인
```bash
# Claude Code에서 확인
/agents

# 파일 시스템에서 확인
ls -la ~/.claude/agents/
```

---

## 수동 설정

### 🚀 Starter Pack 설정
```bash
# 디렉토리 생성
mkdir -p ~/.claude/agents

# Starter Pack 링크
ln -sf ~/molidae/ai/claude-code/agents/starter/*.json ~/.claude/agents/

# 설정 확인
ls -la ~/.claude/agents/
```

### 🎨 Essential Pack 설정
```bash
# Starter Pack + Essential Pack
ln -sf ~/molidae/ai/claude-code/agents/starter/*.json ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/essential/*.json ~/.claude/agents/
```

### ⚡ Professional Pack 설정
```bash
# 모든 팩 포함
ln -sf ~/molidae/ai/claude-code/agents/starter/*.json ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/essential/*.json ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/professional/*.json ~/.claude/agents/
```

### 🎯 개별 에이전트 선택
```bash
# 특정 에이전트만 설치
ln -sf ~/molidae/ai/claude-code/agents/starter/code-reviewer.json ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/essential/korean-docs.json ~/.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/professional/api-architect.json ~/.claude/agents/
```

---

## 프로젝트별 설정

### 1. 프로젝트 디렉토리 설정
```bash
# 프로젝트 루트에서
mkdir -p .claude/agents
```

### 2. 팩별 프로젝트 설정

#### 🚀 Starter Pack for Project
```bash
ln -sf ~/molidae/ai/claude-code/agents/starter/*.json ./.claude/agents/
```

#### 🎨 Essential Pack for Project
```bash
ln -sf ~/molidae/ai/claude-code/agents/starter/*.json ./.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/essential/*.json ./.claude/agents/
```

#### ⚡ Professional Pack for Project
```bash
ln -sf ~/molidae/ai/claude-code/agents/starter/*.json ./.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/essential/*.json ./.claude/agents/
ln -sf ~/molidae/ai/claude-code/agents/professional/*.json ./.claude/agents/
```

### 3. 프로젝트 특화 커스터마이징
```bash
# 기본 에이전트를 프로젝트용으로 복사
cp ~/molidae/ai/claude-code/agents/starter/code-reviewer.json ./.claude/agents/project-reviewer.json

# 프로젝트에 맞게 수정
vim ./.claude/agents/project-reviewer.json
```

---

## 고급 사용법

### 🔄 팩 업그레이드
언제든지 설정 스크립트를 다시 실행하여 더 큰 팩으로 업그레이드할 수 있습니다.

```bash
# 기존 Starter Pack에서 Essential Pack으로 업그레이드
~/molidae/ai/claude-code/scripts/setup.sh

# 선택: 🎨 Essential Pack (4개)
```

### 🎯 선택적 에이전트 추가
```bash
# Starter Pack 사용 중 특정 Professional 에이전트만 추가
ln -sf ~/molidae/ai/claude-code/agents/professional/api-architect.json ~/.claude/agents/

# Essential Pack 사용 중 성능 최적화 에이전트만 추가
ln -sf ~/molidae/ai/claude-code/agents/professional/performance-optimizer.json ~/.claude/agents/
```

### 📊 현재 설정 확인
```bash
# 설치된 에이전트 개수 확인
ls -1 ~/.claude/agents/*.json | wc -l

# 어떤 팩이 설치되었는지 확인
if [ -f ~/.claude/agents/api-architect.json ]; then
    echo "⚡ Professional Pack 설치됨"
elif [ -f ~/.claude/agents/korean-docs.json ]; then
    echo "🎨 Essential Pack 설치됨"
elif [ -f ~/.claude/agents/code-reviewer.json ]; then
    echo "🚀 Starter Pack 설치됨"
fi
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

# 설정 스크립트로 다시 설정
~/molidae/ai/claude-code/scripts/setup.sh
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

# 정확한 절대 경로로 재설정 (Starter Pack 예시)
ln -sf $(realpath ~/molidae/ai/claude-code/agents)/starter/*.json ~/.claude/agents/
```

#### 4. 팩 혼동 문제
**원인**: 여러 팩을 수동으로 설치하다가 혼동

**해결책**:
```bash
# 기존 에이전트 모두 제거
rm -f ~/.claude/agents/*

# 설정 스크립트로 깔끔하게 재설정
~/molidae/ai/claude-code/scripts/setup.sh
```

### 팩 관련 문제 해결

#### 현재 팩 상태 확인
```bash
# 설치된 에이전트로 팩 확인
if [ -f ~/.claude/agents/security-auditor.json ]; then
    echo "⚡ Professional Pack (7개) 설치됨"
elif [ -f ~/.claude/agents/debug-expert.json ]; then
    echo "🎨 Essential Pack (4개) 설치됨"
elif [ -f ~/.claude/agents/test-generator.json ]; then
    echo "🚀 Starter Pack (2개) 설치됨"
else
    echo "❌ 에이전트가 설치되지 않음"
fi
```

#### 팩 불완전 설치 해결
```bash
# 현재 팩을 완전히 재설치
~/molidae/ai/claude-code/scripts/setup.sh
# 기존 에이전트 제거: y
# 원하는 팩 선택
```

### 디버깅 명령어

#### 설정 상태 확인
```bash
# 에이전트 디렉토리 확인
ls -la ~/.claude/agents/

# 각 팩별 파일 존재 확인
echo "🚀 Starter Pack:"
ls ~/.claude/agents/{code-reviewer,test-generator}.json 2>/dev/null

echo "🎨 Essential Pack:"
ls ~/.claude/agents/{korean-docs,debug-expert}.json 2>/dev/null

echo "⚡ Professional Pack:"
ls ~/.claude/agents/{api-architect,performance-optimizer,security-auditor}.json 2>/dev/null
```

#### 심볼릭 링크 유효성 검사
```bash
# 모든 링크가 유효한지 확인
for link in ~/.claude/agents/*.json; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
        echo "❌ 깨진 링크: $link"
    elif [ -L "$link" ] && [ -e "$link" ]; then
        echo "✅ 정상 링크: $link"
    fi
done
```

#### JSON 유효성 검사
```bash
# 팩별 JSON 검사
echo "🔍 JSON 유효성 검사:"
for pack in starter essential professional; do
    echo "📦 $pack pack:"
    for file in ~/molidae/ai/claude-code/agents/$pack/*.json; do
        if [ -f "$file" ]; then
            agent_name=$(basename "$file" .json)
            if command -v jq &> /dev/null; then
                if jq empty "$file" 2>/dev/null; then
                    echo "  ✅ $agent_name"
                else
                    echo "  ❌ $agent_name (JSON 오류)"
                fi
            else
                echo "  ⚠️ $agent_name (jq 없음)"
            fi
        fi
    done
done
```

### 성능 최적화

#### 불필요한 에이전트 제거
```bash
# 사용하지 않는 Professional 에이전트만 제거 (Essential Pack 유지)
rm -f ~/.claude/agents/{api-architect,performance-optimizer,security-auditor}.json

# 특정 에이전트만 제거
rm -f ~/.claude/agents/security-auditor.json
```

#### 팩 다운그레이드
```bash
# Professional에서 Essential로 다운그레이드
rm -f ~/.claude/agents/{api-architect,performance-optimizer,security-auditor}.json

# Essential에서 Starter로 다운그레이드
rm -f ~/.claude/agents/{korean-docs,debug-expert}.json
```

### 프로젝트별 설정 문제

#### 프로젝트 에이전트가 작동하지 않음
```bash
# 프로젝트 루트에서 실행
pwd  # 프로젝트 루트인지 확인

# .claude/agents 디렉토리 확인
ls -la .claude/agents/

# 프로젝트별 에이전트 재설정
rm -rf .claude/agents/
mkdir -p .claude/agents/
ln -sf ~/.claude/agents/* .claude/agents/
```

---

## 🎯 빠른 해결 가이드

### 🚨 문제별 즉시 해결법

| 문제 | 즉시 해결 명령어 |
|------|------------------|
| 에이전트 안 보임 | `~/molidae/ai/claude-code/scripts/setup.sh` |
| 팩 혼동됨 | `rm -f ~/.claude/agents/* && ~/molidae/ai/claude-code/scripts/setup.sh` |
| 깨진 링크 | `find ~/.claude/agents/ -type l ! -exec test -e {} \\; -delete` |
| 권한 오류 | `chmod 644 ~/molidae/ai/claude-code/agents/*/*.json` |

### 💡 유지보수 명령어
```bash
# 월간 정리: 깨진 링크 제거 + 재설정
find ~/.claude/agents/ -type l ! -exec test -e {} \; -delete
~/molidae/ai/claude-code/scripts/setup.sh

# 백업 생성
cp -r ~/.claude/agents/ ~/.claude/agents.backup.$(date +%Y%m%d)
```

---

*설정 과정에서 문제가 발생하면 GitHub Issues에 문의해주세요! 🙋‍♂️*