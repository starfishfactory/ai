# Daily Report Template

Generate a Korean-language daily report following this 9-section structure.
Use the collected JSON data as the single source of truth for all numbers.

---

## Section 1: Overview (개요)

Markdown table with key metrics:

| Item | Value |
|------|-------|
| **Total Sessions** | {count} (main {n} + worker {n} + empty {n}) |
| **Active Hours** | {HH:MM} ~ {HH:MM} KST (~{N}h) |
| **Total Commits** | {count} |
| **Active Projects** | {count} |
| **Total Tokens** | {X}M (input {X}K + output {X}K + cache_read {X}M + cache_create {X}M) |
| **Estimated Cost** | **${total}** |
| **Model** | {model name} |

Token formatting: use M for millions, K for thousands. Round to 1 decimal.

---

## Section 2: Work Details (일감 상세)

For each project (sorted by cost descending):

### 2.N {project-name}

**Work Goal**: 1-2 sentence summary inferred from prompts and commit messages.

**Session Flow**: ASCII diagram showing session chain with timestamps, IDs, and relationships.
```
sessionId (HH:MM ~ HH:MM) description
    ├─ sessionId (HH:MM ~ HH:MM) description
    │   ├─ sessionId (worker: role)
    │   └─ sessionId (worker: role)
    └─ sessionId (HH:MM ~ HH:MM) description
```

**Commits ({count})**:
| Hash | Message |
|------|---------|
| `{short-hash}` | {message} |

**Key Events**: bullet list of notable patterns (team agents, retries, carry-over, etc.)

| Item | Value |
|------|-------|
| Sessions | {count} (main {n} + worker {n}) |
| Tokens | {X}M |
| Cost | ${amount} |

---

## Section 3: Metadata (메타데이터)

### Session Timeline (KST, chronological)

Full session table sorted by start time:

| Start | End | Duration | Project | Session | Cost |
|-------|-----|----------|---------|---------|------|

> Note: carry-over sessions started on previous day.

---

## Section 4: Token & Cost Analysis (토큰 & 비용 분석)

### 4.1 Token Distribution

| Token Type | Count | Cost | Share |
|------------|-------|------|-------|
| Non-cached Input | | | |
| Cache Creation | | | |
| Cache Read | | | |
| Output | | | |
| **Total** | | | |

### 4.2 Cost by Project

ASCII bar chart, descending by cost.
```
project-a  ████████████████  ${amount} ({pct}%)
project-b  ████████          ${amount} ({pct}%)
```

### 4.3 Cost Efficiency

| Project | Commits | Cost | Cost/Commit |
|---------|---------|------|-------------|

> Analysis note explaining outliers.

### 4.4 Cache Efficiency

| Metric | Value |
|--------|-------|
| Cache Hit Rate | {pct}% |
| Cost without Cache | ${amount} |
| Actual Input Cost | ${amount} |
| Cache Savings | **${amount}** |

---

## Section 5: Session Flow & Connections (세션 흐름 & 연결 관계)

### 5.1 Project Switch Timeline

ASCII timeline grid showing concurrent sessions per project per hour.

### 5.2 Session Connection Patterns

Identify and describe patterns:
1. **Team Agent Parallel** — orchestrator → workers
2. **Context Overflow → Continuation** — long sessions
3. **Iterative Fix Loop** — repeated sessions on same issue
4. **Multi-repo Work** — parallel work across repos

### 5.3 Hourly Activity (KST)

ASCII histogram of active sessions per hour.

---

## Section 6: Prompt Keyword Analysis (프롬프트 키워드 분석)

### 6.1 Frequent Keywords

| Keyword | Count | Note |
|---------|-------|------|

### 6.2 Work Type Classification

ASCII bar chart of work categories (Implementation, Planning, Git, etc.)

### 6.3 Prompt Pattern Analysis

Numbered list of identified recurring prompt patterns.

---

## Section 7: Automation & Tool Usage (자동화 & 도구 사용 분석)

### 7.1 Tool Frequency

| Tool | Count | Share | Purpose |
|------|-------|-------|---------|

### 7.2 Subagent Usage

| Subagent Type | Count | Primary Use |
|---------------|-------|-------------|

### 7.3 Slash Commands

| Command | Count |
|---------|-------|

### 7.4 Automated Hooks

| Hook | Trigger | Function |
|------|---------|----------|

---

## Section 8: Trend Comparison (주간 트렌드 비교)

If previous report exists at `~/.claude/daily-reports/{prev-date}/report.md`:
- Compare key metrics (sessions, commits, cost, cache hit rate)
- Show delta (↑/↓)

If no previous report:
- Record current day as **baseline**

---

## Section 9: Improvement Suggestions (개선 제안)

Four subcategories with 2-3 actionable items each:

### 9.1 Prompt Improvement
### 9.2 Workflow Improvement
### 9.3 Tool Usage Improvement
### 9.4 Cost Optimization

Each item: data-backed observation + specific suggestion.
Reference best-practices.md for external backing where applicable.
