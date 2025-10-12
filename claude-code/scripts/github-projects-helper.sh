#!/bin/bash

# GitHub Projects Manager Helper Script
# Agent가 사용할 GraphQL 쿼리 예제 및 테스트용 함수

set -euo pipefail

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로깅 함수
log_info() {
    echo -e "${BLUE}ℹ${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}✅${NC} $1" >&2
}

log_error() {
    echo -e "${RED}❌${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1" >&2
}

# 사용자 ID 조회
get_user_id() {
    log_info "사용자 ID 조회 중..."

    local user_id=$(gh api graphql -f query='
    {
      viewer {
        id
        login
      }
    }' --jq '.data.viewer.id')

    if [ -z "$user_id" ]; then
        log_error "사용자 ID를 조회할 수 없습니다."
        return 1
    fi

    echo "$user_id"
}

# 프로젝트 생성
create_project() {
    local title="$1"
    local owner_id="$2"

    log_info "프로젝트 생성 중: $title"

    local result=$(gh api graphql -f query='
    mutation($ownerId: ID!, $title: String!) {
      createProjectV2(input: {
        ownerId: $ownerId
        title: $title
      }) {
        projectV2 {
          id
          number
          title
          url
        }
      }
    }' -f ownerId="$owner_id" -f title="$title")

    local project_id=$(echo "$result" | jq -r '.data.createProjectV2.projectV2.id')
    local project_number=$(echo "$result" | jq -r '.data.createProjectV2.projectV2.number')
    local project_url=$(echo "$result" | jq -r '.data.createProjectV2.projectV2.url')

    if [ "$project_id" != "null" ]; then
        log_success "프로젝트 생성: $title"
        log_info "프로젝트 번호: $project_number"
        log_info "URL: $project_url"
        echo "$project_id"
    else
        log_error "프로젝트 생성 실패"
        echo "$result" | jq '.' >&2
        return 1
    fi
}

# 프로젝트 목록 조회
list_projects() {
    log_info "프로젝트 목록 조회 중..."

    gh api graphql -f query='
    {
      viewer {
        projectsV2(first: 10, orderBy: {field: UPDATED_AT, direction: DESC}) {
          nodes {
            number
            title
            url
            updatedAt
          }
        }
      }
    }' --jq '.data.viewer.projectsV2.nodes[] | "\(.number): \(.title)"'
}

# 프로젝트 ID 조회 (번호로)
get_project_id() {
    local project_number="$1"

    log_info "프로젝트 #$project_number ID 조회 중..."

    local project_id=$(gh api graphql -f query='
    query($number: Int!) {
      viewer {
        projectV2(number: $number) {
          id
        }
      }
    }' -F number="$project_number" --jq '.data.viewer.projectV2.id')

    if [ "$project_id" != "null" ] && [ -n "$project_id" ]; then
        echo "$project_id"
    else
        log_error "프로젝트 #$project_number를 찾을 수 없습니다."
        return 1
    fi
}

# 상태 필드 ID 조회
get_status_field_id() {
    local project_id="$1"

    log_info "상태 필드 ID 조회 중..."

    gh api graphql -f query='
    query($projectId: ID!) {
      node(id: $projectId) {
        ... on ProjectV2 {
          fields(first: 20) {
            nodes {
              ... on ProjectV2SingleSelectField {
                id
                name
                options {
                  id
                  name
                }
              }
            }
          }
        }
      }
    }' -f projectId="$project_id" --jq '.data.node.fields.nodes[] | select(.name == "Status") | {fieldId: .id, options: .options}'
}

# Issue에서 node ID 조회
get_issue_id() {
    local repo="$1"
    local issue_number="$2"

    log_info "Issue #$issue_number ID 조회 중..."

    local owner=$(echo "$repo" | cut -d'/' -f1)
    local name=$(echo "$repo" | cut -d'/' -f2)

    local issue_id=$(gh api graphql -f query='
    query($owner: String!, $name: String!, $number: Int!) {
      repository(owner: $owner, name: $name) {
        issue(number: $number) {
          id
        }
      }
    }' -f owner="$owner" -f name="$name" -F number="$issue_number" --jq '.data.repository.issue.id')

    if [ "$issue_id" != "null" ] && [ -n "$issue_id" ]; then
        echo "$issue_id"
    else
        log_error "Issue #$issue_number를 찾을 수 없습니다."
        return 1
    fi
}

# 프로젝트에 아이템 추가
add_item_to_project() {
    local project_id="$1"
    local content_id="$2"

    log_info "프로젝트 아이템 추가 중..."

    local result=$(gh api graphql -f query='
    mutation($projectId: ID!, $contentId: ID!) {
      addProjectV2ItemById(input: {
        projectId: $projectId
        contentId: $contentId
      }) {
        item {
          id
        }
      }
    }' -f projectId="$project_id" -f contentId="$content_id")

    local item_id=$(echo "$result" | jq -r '.data.addProjectV2ItemById.item.id')

    if [ "$item_id" != "null" ]; then
        log_success "프로젝트 아이템 추가 완료"
        echo "$item_id"
    else
        log_error "아이템 추가 실패"
        echo "$result" | jq '.' >&2
        return 1
    fi
}

# 아이템 상태 변경
update_item_status() {
    local project_id="$1"
    local item_id="$2"
    local field_id="$3"
    local option_id="$4"

    log_info "아이템 상태 변경 중..."

    local result=$(gh api graphql -f query='
    mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
      updateProjectV2ItemFieldValue(input: {
        projectId: $projectId
        itemId: $itemId
        fieldId: $fieldId
        value: {
          singleSelectOptionId: $optionId
        }
      }) {
        projectV2Item {
          id
        }
      }
    }' -f projectId="$project_id" -f itemId="$item_id" -f fieldId="$field_id" -f optionId="$option_id")

    local updated_item_id=$(echo "$result" | jq -r '.data.updateProjectV2ItemFieldValue.projectV2Item.id')

    if [ "$updated_item_id" != "null" ]; then
        log_success "상태 변경 완료"
        return 0
    else
        log_error "상태 변경 실패"
        echo "$result" | jq '.' >&2
        return 1
    fi
}

# 도움말
show_help() {
    cat <<EOF
GitHub Projects Manager Helper Script

사용법:
  $0 <command> [arguments]

명령어:
  list                          프로젝트 목록 조회
  create <title>                새 프로젝트 생성
  get-project-id <number>       프로젝트 ID 조회
  get-status-field <project_id> 상태 필드 정보 조회
  get-issue-id <repo> <number>  Issue ID 조회
  add-item <project_id> <issue_id> 프로젝트에 아이템 추가
  update-status <project_id> <item_id> <field_id> <option_id> 상태 변경

예시:
  # 프로젝트 목록
  $0 list

  # 새 프로젝트 생성
  $0 create "AI Agent 개발"

  # Issue를 프로젝트에 추가
  $0 add-item PROJECT_ID ISSUE_ID

EOF
}

# 메인 실행 로직
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    local command="$1"
    shift

    case "$command" in
        list)
            list_projects
            ;;
        create)
            if [ $# -lt 1 ]; then
                log_error "프로젝트 제목을 입력하세요."
                exit 1
            fi
            local user_id=$(get_user_id)
            create_project "$1" "$user_id"
            ;;
        get-project-id)
            if [ $# -lt 1 ]; then
                log_error "프로젝트 번호를 입력하세요."
                exit 1
            fi
            get_project_id "$1"
            ;;
        get-status-field)
            if [ $# -lt 1 ]; then
                log_error "프로젝트 ID를 입력하세요."
                exit 1
            fi
            get_status_field_id "$1"
            ;;
        get-issue-id)
            if [ $# -lt 2 ]; then
                log_error "저장소와 Issue 번호를 입력하세요."
                exit 1
            fi
            get_issue_id "$1" "$2"
            ;;
        add-item)
            if [ $# -lt 2 ]; then
                log_error "프로젝트 ID와 Issue ID를 입력하세요."
                exit 1
            fi
            add_item_to_project "$1" "$2"
            ;;
        update-status)
            if [ $# -lt 4 ]; then
                log_error "프로젝트 ID, 아이템 ID, 필드 ID, 옵션 ID를 입력하세요."
                exit 1
            fi
            update_item_status "$1" "$2" "$3" "$4"
            ;;
        *)
            log_error "알 수 없는 명령어: $command"
            show_help
            exit 1
            ;;
    esac
}

# 스크립트가 직접 실행될 때만 main 호출
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
