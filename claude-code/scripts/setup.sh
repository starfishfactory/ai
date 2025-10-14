#!/bin/bash

# Claude Code 에이전트 설정 스크립트 v2.0
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
log_info "에이전트 팩을 선택하세요:"
echo ""
echo "🚀 1) Core Pack (4개) - 모든 사용자 추천"
echo "   • code-reviewer: 코드 가독성과 유지보수성 검토"
echo "   • test-generator: TDD 테스트 케이스 생성"
echo "   • debug-expert: 디버깅 및 문제 해결"
echo "   • korean-docs: 한국어 기술 문서 작성"
echo ""
echo "⚡ 2) Advanced Pack (6개) - Core + 특수 목적"
echo "   • Core Pack + security-auditor + github-projects-manager"
echo "   • 보안 검토 및 프로젝트 관리 포함"
echo ""
echo "🛠️  3) Custom - 개별 선택 (고급 사용자용)"
echo ""

read -p "선택 (1-3): " -n 1 -r
echo ""

case $REPLY in
    1)
        log_info "🚀 Core Pack을 설정합니다..."
        log_info "기본 개발 워크플로우에 필요한 핵심 에이전트입니다!"

        ln -sf "$AGENTS_DIR"/core/*.md "$USER_AGENTS_DIR"/
        log_success "Core Pack 설정 완료 (4개 에이전트)"
        ;;

    2)
        log_info "⚡ Advanced Pack을 설정합니다..."
        log_info "Core + 보안 및 프로젝트 관리 기능을 포함합니다!"

        # Core + Advanced
        ln -sf "$AGENTS_DIR"/core/*.md "$USER_AGENTS_DIR"/
        ln -sf "$AGENTS_DIR"/advanced/*.md "$USER_AGENTS_DIR"/
        log_success "Advanced Pack 설정 완료 (6개 에이전트)"
        ;;

    3)
        log_info "🛠️  Custom 설정 모드입니다."

        # Core 에이전트 선택
        echo ""
        log_info "🚀 Core 에이전트를 선택하세요 (추천: 모두 선택):"

        for agent in "$AGENTS_DIR"/core/*.md; do
            agent_name=$(basename "$agent" .md)
            read -p "  - $agent_name (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ln -sf "$agent" "$USER_AGENTS_DIR"/
                log_success "  $agent_name 추가됨"
            fi
        done

        # Advanced 에이전트 선택
        echo ""
        log_info "⚡ Advanced 에이전트를 선택하세요:"

        for agent in "$AGENTS_DIR"/advanced/*.md; do
            agent_name=$(basename "$agent" .md)
            read -p "  - $agent_name (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ln -sf "$agent" "$USER_AGENTS_DIR"/
                log_success "  $agent_name 추가됨"
            fi
        done

        log_success "Custom 설정이 완료되었습니다."
        ;;

    *)
        log_error "잘못된 선택입니다."
        exit 1
        ;;
esac

# Markdown 파일 유효성 검사
echo ""
log_info "에이전트 파일 유효성을 검사합니다..."

invalid_count=0
for agent_file in "$USER_AGENTS_DIR"/*.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file")
        # Markdown 파일이므로 YAML frontmatter 존재 확인
        if head -n 1 "$agent_file" | grep -q "^---$"; then
            log_success "  $agent_name ✓"
        else
            log_error "  $agent_name ✗ (YAML frontmatter 없음)"
            ((invalid_count++))
        fi
    fi
done

if [ $invalid_count -gt 0 ]; then
    log_error "$invalid_count 개의 에이전트 파일에 오류가 있습니다."
fi

# 설정 결과 확인
echo ""
log_info "📋 설정된 에이전트 목록:"
ls -la "$USER_AGENTS_DIR"

# 에이전트 개수 확인
agent_count=$(ls -1 "$USER_AGENTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
echo ""
log_success "총 $agent_count 개의 에이전트가 설정되었습니다."

# 다음 단계 안내
echo ""
log_info "🎉 설정이 완료되었습니다!"
echo ""
echo "🎉 다음 단계:"
echo "1. Claude Code를 실행하세요"
echo "2. '/agents' 명령으로 설정된 에이전트를 확인하세요"
echo "3. 개발 작업 시 에이전트가 자동으로 선택되거나 직접 호출하세요"
echo ""
echo "💡 주요 에이전트 활용법:"
echo "  🔍 코드 리뷰: '이 코드를 검토해주세요'"
echo "  🧪 TDD 개발: '새 기능을 테스트부터 작성해주세요'"
echo "  📚 문서 작성: 'API 가이드를 작성해주세요'"
echo "  🐛 디버깅: '이 에러를 분석해주세요'"
if [ $agent_count -ge 5 ]; then
echo "  🔒 보안 검토: '보안을 확인해주세요'"
echo "  📋 프로젝트 관리: '프로젝트를 생성해줘'"
fi
echo ""
echo "📖 더 많은 에이전트가 필요하다면:"
echo "  • 이 스크립트를 다시 실행하여 더 큰 팩으로 업그레이드"
echo "  • Custom 모드로 필요한 에이전트만 추가"
echo ""
echo "📚 자세한 사용법은 README.md를 참조하세요!"

# 프로젝트별 설정 안내
echo ""
read -p "현재 프로젝트에도 에이전트를 설정하시겠습니까? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "$(pwd)/.git/config" ] || [ -d "$(pwd)/.git" ]; then
        log_info "현재 디렉토리에 프로젝트별 에이전트를 설정합니다..."
        mkdir -p "$(pwd)/.claude/agents"

        # 사용자 에이전트를 프로젝트로 복사 (심볼릭 링크)
        for agent in "$USER_AGENTS_DIR"/*.md; do
            if [ -f "$agent" ]; then
                ln -sf "$agent" "$(pwd)/.claude/agents/"
            fi
        done

        log_success "프로젝트별 에이전트 설정이 완료되었습니다."
        log_info "이 프로젝트에서도 동일한 에이전트를 사용할 수 있습니다."
    else
        log_warning "현재 디렉토리가 Git 프로젝트가 아닙니다."
        log_info "프로젝트 루트에서 다시 실행해주세요."
    fi
fi

echo ""
log_success "🚀 모든 설정이 완료되었습니다. 즐거운 개발 되세요!"
