# Task Decomposition Template

## YAML Frontmatter

```yaml
---
title: Tasks — {Spec Title}
source-spec: {spec-filename.md}
created: {YYYY-MM-DD}
total-tasks: {N}
complexity-summary: "S:{n}, M:{n}, L:{n}, XL:{n}"
---
```

## Example

```markdown
---
title: Tasks — User Authentication System
source-spec: user-auth-system.md
created: 2025-01-15
total-tasks: 8
complexity-summary: "S:2, M:3, L:2, XL:1"
---

## Phase 1: Foundation

### T-001: Create user database schema
- **Complexity**: M
- **Spec refs**: FR-001, FR-002
- **Dependencies**: none
- **Description**: Create user table with email, password_hash, role, created_at fields. Add migration and seed data.
- **Acceptance criteria**:
  - [ ] Migration creates users table with all required fields
  - [ ] Unique constraint on email
  - [ ] Seed script creates test users

### T-002: Set up authentication middleware
- **Complexity**: M
- **Spec refs**: FR-003, NFR-001
- **Dependencies**: T-001
- **Description**: Implement JWT-based auth middleware. Token validation, refresh token flow, role extraction.
- **Acceptance criteria**:
  - [ ] Valid JWT passes middleware, invalid returns 401
  - [ ] Refresh token endpoint returns new access token
  - [ ] Role is extracted and available in request context

## Phase 2: Core Implementation

### T-003: Implement signup endpoint
- **Complexity**: M
- **Spec refs**: FR-001
- **Dependencies**: T-001, T-002
- **Description**: POST /api/auth/signup — validate input, hash password, create user, return JWT.
- **Acceptance criteria**:
  - [ ] Valid signup returns 201 with JWT
  - [ ] Duplicate email returns 409
  - [ ] Invalid input returns 400 with validation errors

### T-004: Implement login endpoint
- **Complexity**: S
- **Spec refs**: FR-002
- **Dependencies**: T-001, T-002
- **Description**: POST /api/auth/login — verify credentials, return JWT pair.
- **Acceptance criteria**:
  - [ ] Correct credentials return 200 with access + refresh tokens
  - [ ] Wrong password returns 401

## Phase 3: Integration

### T-005: Add rate limiting
- **Complexity**: S
- **Spec refs**: NFR-002
- **Dependencies**: T-003, T-004
- **Description**: Add rate limiter to auth endpoints. 10 req/min per IP for login, 5 req/min for signup.
- **Acceptance criteria**:
  - [ ] 11th login request within 1 min returns 429
  - [ ] Rate limit headers present in response

## Dependency Graph

\`\`\`mermaid
graph TD
    subgraph Phase 1: Foundation
        T001[T-001: DB Schema]
        T002[T-002: Auth Middleware]
    end
    subgraph Phase 2: Core
        T003[T-003: Signup]
        T004[T-004: Login]
    end
    subgraph Phase 3: Integration
        T005[T-005: Rate Limiting]
    end
    T001 --> T002
    T001 --> T003
    T001 --> T004
    T002 --> T003
    T002 --> T004
    T003 --> T005
    T004 --> T005
\`\`\`

## Coverage Matrix

| Spec Element | Tasks |
|-------------|-------|
| FR-001 | T-001, T-003 |
| FR-002 | T-001, T-004 |
| FR-003 | T-002 |
| NFR-001 | T-002 |
| NFR-002 | T-005 |
| Goal 1: Secure auth | T-001, T-002, T-003, T-004 |
| Goal 2: Rate protection | T-005 |
```
