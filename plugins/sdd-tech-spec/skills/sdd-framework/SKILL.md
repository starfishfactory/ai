---
name: sdd-framework
description: SDD (Specification-Driven Development) core principles and spec type guides
user-invocable: false
---

# SDD (Specification-Driven Development) Framework

## Core Principles

### 1. Specification-First
Spec before code. Define "what to build" before implementation.
- Spec is the contract for implementation
- Code without spec is navigation without direction
- Changing spec costs less than changing code

### 2. Intent Over Implementation
Prioritize why over how.
- Clarify "why needed" before "how to implement"
- Fix scope with Goals/Non-Goals before starting design
- Document rationale through alternative review

### 3. Drift Detection
Continuously detect and correct spec-implementation drift.
- Track deviations from spec during implementation
- Update spec first when changes are unavoidable
- Verify spec-code alignment during review

### 4. Tiered Depth
Match spec depth to change complexity.
- Light: Bug fix, config — 1–2 page spec
- Standard: Feature, API — 5–10 page spec (default)
- Deep: New system, migration — 10–20 page spec
- See tier-system SKILL for full definitions and auto-selection heuristics

### 5. Delta Spec
When modifying existing specs, produce delta (changes only) rather than full rewrite.
- Reference original spec sections
- Mark additions/modifications/deletions clearly
- Maintain traceability to original spec

## Spec Type Guides

### Feature Design

User-facing feature spec. Focus on interface contracts and acceptance criteria.

**Key questions**:
- What can users do with this feature?
- What defines successful behavior?
- How are edge cases handled?

**Key sections**: Goals/Non-Goals, FR, NFR, Success Metrics
**Key deliverables**:
- User stories (As a... I want... So that...)
- Acceptance criteria (Given/When/Then)
- Interface contracts (input/output/error)
- State transition diagrams (if applicable)

### System Architecture

Focus on component relationships and data flow.

**Key questions**:
- What components/services are needed?
- How do components communicate?
- Where and how is data stored?
- How does the system behave on failure?

**Key sections**: Detailed Design (architecture/data model), Dependencies & Constraints, Risks & Mitigation
**Key deliverables**:
- C4 model diagrams (Context, Container, Component)
- Sequence diagrams (main flows)
- Data model ERD
- Deployment architecture

### API Specification

Focus on per-endpoint request/response schemas and error handling.

**Key questions**:
- What endpoints are needed?
- What are the request/response schemas per endpoint?
- What is the auth/authz approach?
- What are the error codes and response formats?

**Key sections**: API Details (endpoints/schemas), FR, Dependencies & Constraints
**Key deliverables**:
- Endpoint list (HTTP Method + Path + Description)
- Request/response JSON schemas
- Error code table
- Auth flow diagram

## Industry References

### Google Design Doc
- Structure: Context > Goals/Non-Goals > Design > Alternatives > Cross-cutting concerns
- Features: Mandatory alternative review, design review process, document lifecycle management
- Ref: "Design Docs at Google" (Industrial Empathy, 2020)

### Lyft Tech Spec
- Structure: Problem > Solution > Design > Rollout > Risks
- Features: Rollout plan included, metric-based success criteria, phased deployment
- Ref: "Writing Technical Specs at Lyft" (Lyft Engineering Blog)

### Amazon Working Backwards (PR/FAQ)
- Structure: Press Release > FAQ > Technical Spec
- Features: Customer perspective first, reverse approach, internal/external FAQ separation
- Ref: "Working Backwards" (Colin Bryar & Bill Carr, 2021)

## References
1. Google. "Design Docs at Google". Industrial Empathy, 2020
2. Lyft Engineering. "Writing Technical Specs at Lyft"
3. Bryar, C. & Carr, B. (2021). "Working Backwards". St. Martin's Press
4. Skelton, M. & Pais, M. (2019). "Team Topologies". IT Revolution
