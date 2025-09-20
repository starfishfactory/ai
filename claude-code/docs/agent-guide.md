# 🤖 에이전트 상세 활용 가이드

> 각 에이전트의 특징과 효과적인 사용법

## 📋 목차

1. [Core 에이전트](#core-에이전트)
2. [Personal 에이전트](#personal-에이전트)
3. [Specialized 에이전트](#specialized-에이전트)
4. [에이전트 조합 활용법](#에이전트-조합-활용법)
5. [실전 시나리오](#실전-시나리오)

---

## Core 에이전트

### 🔍 code-reviewer
**용도**: 포괄적인 코드 검토 및 품질 개선

**자동 선택 트리거**:
- "코드를 검토해주세요"
- "이 함수에 문제가 있나요?"
- "성능을 개선해주세요"
- "보안 문제를 확인해주세요"

**주요 기능**:
- 코드 품질 분석 (가독성, 유지보수성)
- 보안 취약점 탐지
- 성능 최적화 제안
- 베스트 프랙티스 적용 가이드
- TDD 관점에서의 테스트 가능성 검토

**활용 예시**:
```javascript
// 검토 요청 예시
function loginUser(username, password) {
    if (username && password) {
        return authenticateUser(username, password);
    }
    return false;
}

// 요청: "이 로그인 함수를 검토해주세요"
```

### 🧪 test-generator
**용도**: TDD 기반 테스트 케이스 생성

**자동 선택 트리거**:
- "테스트를 작성해주세요"
- "TDD로 개발하고 싶어요"
- "테스트 케이스가 필요해요"
- "Red-Green-Refactor"

**주요 기능**:
- 실패하는 테스트 우선 작성 (Red)
- 엣지 케이스 및 경계값 테스트
- Mock 객체 활용 테스트
- 테스트 커버리지 개선
- 한국어 주석과 설명 포함

**활용 예시**:
```javascript
// 함수 정의
function calculateDiscount(price, discountRate) {
    // 구현 예정
}

// 요청: "이 할인 계산 함수의 TDD 테스트를 작성해주세요"
```

### 🐛 debug-expert
**용도**: 체계적인 디버깅 및 문제 해결

**자동 선택 트리거**:
- "에러가 발생했어요"
- "버그를 찾아주세요"
- "디버깅 도움이 필요해요"
- "왜 작동하지 않나요?"

**주요 기능**:
- 에러 메시지 분석
- 스택 트레이스 해석
- 근본 원인 분석
- 단계별 해결 방법 제시
- 재현 가능한 테스트 케이스 생성

**활용 예시**:
```
Error: Cannot read property 'name' of undefined
    at UserProfile.render (UserProfile.js:15)
    at ReactDOM.render (react-dom.js:1234)

// 요청: "이 에러의 원인을 분석하고 해결해주세요"
```

### 📚 documentation-helper
**용도**: 체계적인 한국어 문서 작성

**자동 선택 트리거**:
- "문서를 작성해주세요"
- "README를 만들어주세요"
- "API 가이드가 필요해요"
- "사용법을 설명해주세요"

**주요 기능**:
- 구조화된 마크다운 문서
- 목차와 단계별 가이드
- 실제 사용 예시 포함
- 적절한 이모지 활용
- 개발자 친화적 설명

**활용 예시**:
```javascript
class UserService {
    createUser(userData) { /* ... */ }
    updateUser(id, userData) { /* ... */ }
    deleteUser(id) { /* ... */ }
}

// 요청: "이 UserService 클래스의 API 문서를 작성해주세요"
```

---

## Personal 에이전트

### 🧪 tdd-coach
**용도**: TDD 방법론 전문 가이드

**자동 선택 트리거**:
- "TDD로 시작하고 싶어요"
- "Red-Green-Refactor"
- "테스트 주도 개발"
- "실패하는 테스트부터"

**주요 기능**:
- TDD 사이클 단계별 안내
- 실패하는 테스트 작성 가이드
- 최소한의 구현 코드 제안
- 리팩토링 방향 제시
- 각 단계별 완료 조건 명시

**TDD 사이클 예시**:
```javascript
// 1. Red: 실패하는 테스트
describe('User Registration', () => {
    it('should create user with valid email', () => {
        const user = registerUser('test@example.com', 'password123');
        expect(user.email).toBe('test@example.com');
        expect(user.id).toBeDefined();
    });
});

// 요청: "사용자 등록 기능을 TDD로 개발하고 싶어요"
```

### 🇰🇷 korean-docs
**용도**: 한국어 특화 문서 작성

**자동 선택 트리거**:
- "한국어로 문서를"
- "상세한 가이드를"
- "단계별 설명을"
- "구조화된 문서를"

**주요 기능**:
- 한국 개발 문화에 맞는 문서
- 단계별 상세 설명
- 실무 중심 예시
- 마크다운 구조 최적화
- 이모지와 시각적 요소 활용

**문서 구조 예시**:
```markdown
# 🚀 프로젝트 이름

## 📋 목차
1. [시작하기](#시작하기)
2. [설치 방법](#설치-방법)
3. [사용법](#사용법)

## 🛠️ 시작하기
### 필수 요구사항
- Node.js 16 이상
- npm 또는 yarn

### 📦 설치 방법
...
```

### ✨ gitmoji-pr
**용도**: 깃모지 기반 PR 작성

**자동 선택 트리거**:
- "PR을 작성해주세요"
- "Pull Request"
- "깃모지로"
- "변경사항을 정리해주세요"

**주요 기능**:
- 변경사항 분석 및 카테고리화
- 적절한 깃모지 선택
- 체계적인 PR 템플릿
- 리뷰어를 위한 명확한 설명
- 테스트 및 검증 항목 포함

**깃모지 매핑 예시**:
- ✨ `:sparkles:` - 새로운 기능
- 🐛 `:bug:` - 버그 수정
- 📚 `:books:` - 문서 추가/수정
- ♻️ `:recycle:` - 코드 리팩토링
- ✅ `:white_check_mark:` - 테스트 추가/수정

### 📝 step-validator
**용도**: 개발 단계별 검증

**자동 선택 트리거**:
- "검증해주세요"
- "완료되었나요?"
- "다음 단계로"
- "체크리스트"

**주요 기능**:
- 단계별 완료 조건 확인
- 품질 검증 체크리스트
- 다음 단계 진행 가이드
- 테스트 및 빌드 상태 확인
- 코드 리뷰 준비 상태 점검

**검증 체크리스트 예시**:
```markdown
## ✅ 기능 개발 완료 체크리스트

### 코드 품질
- [ ] 모든 테스트 통과
- [ ] 코드 커버리지 80% 이상
- [ ] Linting 오류 없음
- [ ] 타입 검사 통과

### 문서화
- [ ] README 업데이트
- [ ] API 문서 작성
- [ ] 변경사항 기록

### 배포 준비
- [ ] 빌드 성공
- [ ] 환경별 테스트 완료
- [ ] 보안 검사 통과
```

---

## Specialized 에이전트

### 🏗️ api-architect
**용도**: REST API 설계 및 구현

**자동 선택 트리거**:
- "API를 설계해주세요"
- "엔드포인트"
- "REST API"
- "OpenAPI"

**주요 기능**:
- RESTful API 설계 원칙 적용
- OpenAPI 스펙 작성
- 데이터 모델 정의
- 인증/권한 관리 설계
- API 문서 자동 생성

### ⚡ performance-optimizer
**용도**: 성능 분석 및 최적화

**자동 선택 트리거**:
- "성능을 개선해주세요"
- "느려요"
- "최적화"
- "병목"

**주요 기능**:
- 성능 병목 지점 분석
- 메모리 사용량 최적화
- 데이터베이스 쿼리 개선
- 캐싱 전략 제안
- 성능 측정 테스트 작성

### 🔒 security-auditor
**용도**: 보안 취약점 분석

**자동 선택 트리거**:
- "보안을 확인해주세요"
- "취약점"
- "보안 검사"
- "OWASP"

**주요 기능**:
- OWASP Top 10 기반 검사
- 인증/권한 관리 검토
- 데이터 암호화 확인
- 보안 헤더 설정 검토
- 보안 테스트 케이스 작성

---

## 에이전트 조합 활용법

### 🔄 개발 워크플로우 조합

#### 1. 새 기능 개발 (TDD)
```
tdd-coach → test-generator → code-reviewer → step-validator
```

#### 2. 버그 수정
```
debug-expert → test-generator → code-reviewer → step-validator
```

#### 3. API 개발
```
api-architect → test-generator → security-auditor → korean-docs
```

#### 4. 성능 개선
```
performance-optimizer → test-generator → code-reviewer → step-validator
```

#### 5. 릴리즈 준비
```
step-validator → korean-docs → gitmoji-pr
```

---

## 실전 시나리오

### 시나리오 1: 새로운 사용자 인증 기능 개발

```text
1. "사용자 인증 기능을 TDD로 개발하고 싶어요"
   → tdd-coach가 Red-Green-Refactor 사이클 가이드

2. "로그인 함수의 테스트를 작성해주세요"
   → test-generator가 포괄적인 테스트 케이스 생성

3. "이 인증 로직의 보안을 확인해주세요"
   → security-auditor가 보안 취약점 검사

4. "현재 단계가 완료되었는지 확인해주세요"
   → step-validator가 완료 조건 체크

5. "인증 API 사용 가이드를 작성해주세요"
   → korean-docs가 체계적인 문서 생성

6. "인증 기능 추가 PR을 작성해주세요"
   → gitmoji-pr이 깃모지 포함 PR 생성
```

### 시나리오 2: 성능 문제 해결

```text
1. "API 응답이 너무 느려요. 성능을 개선해주세요"
   → performance-optimizer가 병목 분석

2. "최적화된 코드를 검토해주세요"
   → code-reviewer가 품질 및 성능 검토

3. "성능 테스트를 작성해주세요"
   → test-generator가 성능 측정 테스트 생성

4. "최적화 결과를 문서화해주세요"
   → korean-docs가 성능 개선 보고서 작성
```

### 시나리오 3: 오픈소스 프로젝트 준비

```text
1. "이 프로젝트의 README를 작성해주세요"
   → korean-docs가 포괄적인 README 생성

2. "기여 가이드라인을 만들어주세요"
   → korean-docs가 CONTRIBUTING.md 작성

3. "코드 품질을 전체적으로 검토해주세요"
   → code-reviewer가 전체 코드베이스 검토

4. "보안 검사를 해주세요"
   → security-auditor가 전체 보안 감사

5. "릴리즈 PR을 작성해주세요"
   → gitmoji-pr이 릴리즈 노트 포함 PR 생성
```

---

## 💡 팁과 베스트 프랙티스

### 효과적인 에이전트 활용법

1. **구체적인 요청하기**
   ```text
   ❌ "코드를 확인해주세요"
   ✅ "이 사용자 인증 함수의 보안과 성능을 검토해주세요"
   ```

2. **컨텍스트 제공하기**
   ```text
   ❌ "테스트를 작성해주세요"
   ✅ "결제 처리 함수의 TDD 테스트를 작성해주세요. 실패 케이스와 엣지 케이스를 포함해서요"
   ```

3. **단계별 진행하기**
   ```text
   1단계: TDD 시작 (tdd-coach)
   2단계: 테스트 작성 (test-generator)
   3단계: 코드 구현
   4단계: 리뷰 (code-reviewer)
   5단계: 검증 (step-validator)
   ```

### 에이전트 선택 최적화

- **PROACTIVELY** 키워드가 포함된 설명이 자동 선택 확률을 높임
- 작업의 성격을 명확히 표현하면 적절한 에이전트가 선택됨
- 필요시 에이전트 이름을 직접 지정하여 명시적 호출 가능

---

*각 에이전트는 지속적으로 개선되고 있습니다. 사용 피드백을 통해 더 나은 에이전트로 발전시켜 나가겠습니다! 🚀*