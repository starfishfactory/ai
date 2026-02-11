---
name: sdd-framework
description: SDD(Specification-Driven Development) 방법론 핵심 원칙 및 Spec 유형별 가이드
user-invocable: false
---

# SDD (Specification-Driven Development) 프레임워크

## 핵심 원칙

### 1. Specification-First
코드보다 명세가 먼저다. 구현 전에 "무엇을 만들 것인가"를 정의한다.
- 명세는 구현의 계약(contract)이다
- 명세가 없는 코드는 방향 없는 항해와 같다
- 명세 변경은 코드 변경보다 비용이 적다

### 2. Intent Over Implementation
의도(why)를 구현(how)보다 우선한다.
- "어떻게 구현할까" 이전에 "왜 필요한가"를 명확히 한다
- Goals/Non-Goals로 범위를 확정한 후 설계를 시작한다
- 대안 검토를 통해 선택의 근거를 문서화한다

### 3. Drift Detection
명세와 구현의 괴리를 지속적으로 감지하고 교정한다.
- 구현 중 명세와 달라지는 부분을 추적한다
- 변경이 불가피하면 명세를 먼저 업데이트한다
- 리뷰 시 명세-코드 일치 여부를 검증한다

---

## Spec 유형별 가이드

### 기능 설계 (Feature Design)

사용자 관점의 기능 명세. 인터페이스 계약과 수용 기준 중심.

**핵심 질문**:
- 사용자가 이 기능으로 무엇을 할 수 있는가?
- 성공적인 동작의 기준은 무엇인가?
- 예외 상황은 어떻게 처리하는가?

**강조 섹션**: Goals/Non-Goals, 기능 요구사항(FR), 비기능 요구사항(NFR), 성공 지표
**핵심 산출물**:
- 사용자 스토리 (As a... I want... So that...)
- 수용 기준 (Given/When/Then)
- 인터페이스 계약 (입력/출력/에러)
- 상태 전이 다이어그램 (해당 시)

### 시스템 아키텍처 (System Architecture)

시스템 구성요소 간 관계와 데이터 흐름 중심.

**핵심 질문**:
- 어떤 컴포넌트/서비스가 필요한가?
- 컴포넌트 간 통신 방식은?
- 데이터는 어디에 어떻게 저장되는가?
- 장애 시 시스템은 어떻게 동작하는가?

**강조 섹션**: 상세 설계(아키텍처/데이터 모델), 의존성 & 제약사항, 리스크 & 완화 전략
**핵심 산출물**:
- C4 모델 다이어그램 (Context, Container, Component)
- 시퀀스 다이어그램 (주요 흐름)
- 데이터 모델 ERD
- 배포 아키텍처

### API 스펙 (API Specification)

엔드포인트별 요청/응답 스키마와 에러 처리 중심.

**핵심 질문**:
- 어떤 엔드포인트가 필요한가?
- 각 엔드포인트의 요청/응답 스키마는?
- 인증/인가 방식은?
- 에러 코드와 응답 형식은?

**강조 섹션**: API 상세(엔드포인트/스키마), 기능 요구사항, 의존성 & 제약사항
**핵심 산출물**:
- 엔드포인트 목록 (HTTP Method + Path + 설명)
- 요청/응답 JSON 스키마
- 에러 코드 테이블
- 인증 흐름 다이어그램

---

## 업계 사례 요약

### Google Design Doc
- 구조: Context → Goals/Non-Goals → Design → Alternatives → Cross-cutting concerns
- 특징: 대안 검토 필수, 디자인 리뷰 프로세스, 문서 수명주기 관리
- 참고: "Design Docs at Google" (Industrial Empathy, 2020)

### Lyft Tech Spec
- 구조: Problem → Solution → Design → Rollout → Risks
- 특징: 롤아웃 계획 포함, 메트릭 기반 성공 기준, 단계적 배포 전략
- 참고: "Writing Technical Specs at Lyft" (Lyft Engineering Blog)

### Amazon Working Backwards (PR/FAQ)
- 구조: Press Release → FAQ → Technical Spec
- 특징: 고객 관점 먼저, 역방향 접근, 내부/외부 FAQ 분리
- 참고: "Working Backwards" (Colin Bryar & Bill Carr, 2021)

---

## 참고문헌
1. Google. "Design Docs at Google". Industrial Empathy, 2020
2. Lyft Engineering. "Writing Technical Specs at Lyft"
3. Bryar, C. & Carr, B. (2021). "Working Backwards". St. Martin's Press
4. Skelton, M. & Pais, M. (2019). "Team Topologies". IT Revolution
