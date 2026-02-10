---
name: msa-onboard
description: MSA 분석 보조 컨텍스트 (C4 참조, 출력 템플릿, 검증 기준)
user-invocable: false
---

# MSA 온보딩 분석 보조 컨텍스트

이 스킬은 사용자가 직접 호출하지 않습니다. `msa-onboard` 커맨드와 Agent Teams의 teammates가 참조하는 보조 파일을 제공합니다.

## 포함 파일

| 파일 | 용도 | 참조 주체 |
|------|------|-----------|
| `c4-mermaid-reference.md` | C4 모델 레벨별 Mermaid 문법 + 요소 타입 | Lead (Phase 3: 리포트 생성) |
| `output-templates.md` | 출력 파일별 마크다운 템플릿 (Obsidian 호환) | Lead (Phase 3: 리포트 생성) |
| `verification-standards.md` | 교차 검증 5단계 + 리포트 검증 4단계 기준 | Lead (Phase 2, 4: 검증) |

## 분석 아키텍처

```
[Phase 0] Lead: 프로젝트 스캔 + 출력 경로 확인
[Phase 1] Teammates 3명 병렬: service-discoverer, infra-analyzer, dependency-mapper → JSON
[Phase 2] Lead: 교차 검증 → 신뢰도 점수(0-100) + 불일치 목록
[Phase 3] Lead: C4 리포트 생성 (output-templates, c4-mermaid-reference 참조)
[Phase 4] Lead: 리포트 검증 → 품질 점수(0-100) + 수정 제안
[Phase 5] Lead: 최종 출력
```

- Phase 1만 Agent Teams (3 teammates 병렬)
- Phase 2-5는 Lead가 직접 수행
- agents/ 디렉토리 없음 (subagent 미사용)
