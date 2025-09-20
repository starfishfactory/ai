#!/bin/bash

# Claude Code 에이전트 설정 스크립트
# 작성자: molidae/ai 개인 라이브러리
# 용도: TDD 및 한국어 문서화 중심 개발 스타일에 최적화된 에이전트 설정

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수들
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 스크립트 위치 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(dirname "$SCRIPT_DIR")/agents"
USER_AGENTS_DIR="$HOME/.claude/agents"

log_info "🤖 Claude Code 에이전트 설정을 시작합니다..."
log_info "📁 에이전트 소스: $AGENTS_DIR"
log_info "📁 설치 위치: $USER_AGENTS_DIR"

# 사전 조건 확인
if [ ! -d "$AGENTS_DIR" ]; then
    log_error "에이전트 디렉토리를 찾을 수 없습니다: $AGENTS_DIR"
    exit 1
fi

# 사용자 레벨 디렉토리 생성
log_info "사용자 레벨 에이전트 디렉토리를 생성합니다..."
mkdir -p "$USER_AGENTS_DIR"

# 기존 에이전트 확인
if [ "$(ls -A "$USER_AGENTS_DIR" 2>/dev/null)" ]; then
    log_warning "기존 에이전트가 발견되었습니다:"
    ls -la "$USER_AGENTS_DIR"
    echo ""
    read -p "기존 에이전트를 모두 제거하시겠습니까? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$USER_AGENTS_DIR"/*
        log_success "기존 에이전트를 제거했습니다."
    else
        log_info "기존 에이전트를 유지합니다. 중복되는 에이전트는 덮어씌워집니다."
    fi
fi

# 설정 방식 선택
echo ""
log_info "설정 방식을 선택하세요:"
echo "1) 🎯 전체 에이전트 (추천 - Core + Personal + Specialized)"
echo "2) 🛠️  Core 에이전트만 (기본 - 코드리뷰, 테스트, 디버그, 문서화)"
echo "3) 🎨 Core + Personal 에이전트 (개인화 - TDD, 한국어, 깃모지 포함)"
echo "4) 📋 개별 선택 (고급 사용자용)"
echo ""

read -p "선택 (1-4): " -n 1 -r
echo ""

case $REPLY in
    1)
        log_info "전체 에이전트를 설정합니다..."

        # Core 에이전트
        log_info "Core 에이전트 설정 중..."
        ln -sf "$AGENTS_DIR"/core/*.json "$USER_AGENTS_DIR"/

        # Personal 에이전트
        log_info "Personal 에이전트 설정 중..."
        ln -sf "$AGENTS_DIR"/personal/*.json "$USER_AGENTS_DIR"/

        # Specialized 에이전트
        log_info "Specialized 에이전트 설정 중..."
        ln -sf "$AGENTS_DIR"/specialized/*.json "$USER_AGENTS_DIR"/

        log_success "전체 에이전트를 설정했습니다."
        ;;

    2)
        log_info "Core 에이전트를 설정합니다..."
        ln -sf "$AGENTS_DIR"/core/*.json "$USER_AGENTS_DIR"/
        log_success "Core 에이전트를 설정했습니다."
        ;;

    3)
        log_info "Core + Personal 에이전트를 설정합니다..."

        # Core 에이전트
        log_info "Core 에이전트 설정 중..."
        ln -sf "$AGENTS_DIR"/core/*.json "$USER_AGENTS_DIR"/

        # Personal 에이전트
        log_info "Personal 에이전트 설정 중..."
        ln -sf "$AGENTS_DIR"/personal/*.json "$USER_AGENTS_DIR"/

        log_success "Core + Personal 에이전트를 설정했습니다."
        ;;

    4)
        log_info "개별 선택 모드입니다."

        # Core 에이전트 선택
        echo ""
        log_info "🛠️  Core 에이전트를 선택하세요:"

        for agent in "$AGENTS_DIR"/core/*.json; do
            agent_name=$(basename "$agent" .json)
            read -p "  - $agent_name (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ln -sf "$agent" "$USER_AGENTS_DIR"/
                log_success "  $agent_name 추가됨"
            fi
        done

        # Personal 에이전트 선택
        echo ""
        log_info "🎨 Personal 에이전트를 선택하세요:"

        for agent in "$AGENTS_DIR"/personal/*.json; do
            agent_name=$(basename "$agent" .json)
            read -p "  - $agent_name (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ln -sf "$agent" "$USER_AGENTS_DIR"/
                log_success "  $agent_name 추가됨"
            fi
        done

        # Specialized 에이전트 선택
        echo ""
        log_info "🚀 Specialized 에이전트를 선택하세요:"

        for agent in "$AGENTS_DIR"/specialized/*.json; do
            agent_name=$(basename "$agent" .json)
            read -p "  - $agent_name (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ln -sf "$agent" "$USER_AGENTS_DIR"/
                log_success "  $agent_name 추가됨"
            fi
        done

        log_success "개별 선택 설정이 완료되었습니다."
        ;;

    *)
        log_error "잘못된 선택입니다."
        exit 1
        ;;
esac

# JSON 파일 유효성 검사
echo ""
log_info "에이전트 파일 유효성을 검사합니다..."

invalid_count=0
for agent_file in "$USER_AGENTS_DIR"/*.json; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file")
        if command -v jq &> /dev/null; then
            if jq empty "$agent_file" 2>/dev/null; then
                log_success "  $agent_name ✓"
            else
                log_error "  $agent_name ✗ (JSON 형식 오류)"
                ((invalid_count++))
            fi
        else
            log_warning "  $agent_name ? (jq가 설치되지 않아 검증할 수 없음)"
        fi
    fi
done

if [ $invalid_count -gt 0 ]; then
    log_error "$invalid_count 개의 에이전트 파일에 오류가 있습니다."
    log_warning "jq를 설치하여 JSON 유효성 검사를 활성화하는 것을 권장합니다: brew install jq"
fi

# 설정 결과 확인
echo ""
log_info "📋 설정된 에이전트 목록:"
ls -la "$USER_AGENTS_DIR"

# 에이전트 개수 확인
agent_count=$(ls -1 "$USER_AGENTS_DIR"/*.json 2>/dev/null | wc -l | tr -d ' ')
echo ""
log_success "총 $agent_count 개의 에이전트가 설정되었습니다."

# 다음 단계 안내
echo ""
log_info "🎉 설정이 완료되었습니다!"
echo ""
echo "다음 단계:"
echo "1. Claude Code를 실행하세요"
echo "2. '/agents' 명령으로 설정된 에이전트를 확인하세요"
echo "3. 개발 작업 시 에이전트가 자동으로 선택되거나 직접 호출하세요"
echo ""
echo "주요 에이전트 활용법:"
echo "  • 코드 리뷰: '이 코드를 검토해주세요'"
echo "  • TDD 개발: '새 기능을 TDD로 개발하고 싶어요'"
echo "  • 문서 작성: 'API 가이드를 작성해주세요'"
echo "  • PR 작성: '이 변경사항의 PR을 작성해주세요'"
echo ""
echo "자세한 사용법은 README.md를 참조하세요!"

# 프로젝트별 설정 안내
echo ""
read -p "현재 프로젝트에도 에이전트를 설정하시겠습니까? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "$(pwd)/.git/config" ] || [ -d "$(pwd)/.git" ]; then
        log_info "현재 디렉토리에 프로젝트별 에이전트를 설정합니다..."
        mkdir -p "$(pwd)/.claude/agents"

        # 사용자 에이전트를 프로젝트로 복사 (심볼릭 링크)
        for agent in "$USER_AGENTS_DIR"/*.json; do
            if [ -f "$agent" ]; then
                ln -sf "$agent" "$(pwd)/.claude/agents/"
            fi
        done

        log_success "프로젝트별 에이전트 설정이 완료되었습니다."
        log_info "이제 이 프로젝트에서도 동일한 에이전트를 사용할 수 있습니다."
    else
        log_warning "현재 디렉토리가 Git 프로젝트가 아닙니다."
        log_info "프로젝트 루트에서 다시 실행해주세요."
    fi
fi

echo ""
log_success "🚀 모든 설정이 완료되었습니다. 즐거운 개발 되세요!"