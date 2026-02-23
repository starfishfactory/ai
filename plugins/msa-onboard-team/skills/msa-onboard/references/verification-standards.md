# Verification Standards

Lead references this document during Phase 2 (cross-validation) and Phase 4 (report verification).

## Cross-Validation (Phase 2) — 5 Steps

### Step 1: Service Consistency

Compare service-discoverer and dependency-mapper results.

| Check Item | Source A | Source B | Discrepancy Type |
|------------|----------|----------|-----------------|
| Service existence | service-discoverer.services | dependency-mapper.serviceDependencies.from/to | Missing or ghost service |
| Service name | service-discoverer.services[].name | dependency-mapper.serviceDependencies[].from/to | Naming mismatch |
| Service count | service-discoverer.services.length | Unique services referenced in dependency-mapper | Count mismatch |

**Scoring**: -5 per mismatch. Ghost service (exists only in dependency-mapper): -10.

### Step 2: Infra-Dependency Alignment

Compare infra-analyzer and dependency-mapper results.

| Check Item | Source A | Source B | Discrepancy Type |
|------------|----------|----------|-----------------|
| Port mapping | infra-analyzer.containerOrchestration.services | dependency-mapper.serviceDependencies.detail | Port mismatch |
| DB connection | infra-analyzer.storage.databases | dependency-mapper.databaseConnections | DB missing/mismatch |
| Network isolation | infra-analyzer.containerOrchestration.networks | dependency-mapper.serviceDependencies | Possible isolation violation |

**Scoring**: Port mismatch -3. DB mismatch -5. Network isolation violation -8.

### Step 3: Completeness Check

Detect services defined in Dockerfile/docker-compose but missing from analysis results.

| Check Item | Detection Method |
|------------|-----------------|
| Undetected service | `Dockerfile` search results vs service-discoverer results |
| Undetected HTTP comm | `RestTemplate`, `WebClient`, `axios`, `fetch` code search |
| Undetected gRPC | `.proto` file search |
| Undetected MQ | `KafkaTemplate`, `@KafkaListener`, `amqplib` code search |
| Undetected DB | `jdbc:`, `mongoose.connect`, `redis://` code search |

**Scoring**: -10 per undetected service. -5 per undetected communication/DB.

### Step 4: Devil's Advocate

Verify items marked `[Needs Verification]` directly in source code.

- Confirmed: change `[Needs Verification]` → `Confirmed`
- Failed verification: add to discrepancy list
- Unable to verify: keep `[Needs Verification]` + note in report

**Scoring**: -5 per failed verification. -2 per unable-to-verify.

### Step 5: Confidence Score Calculation

**Base score**: 100, subtract deductions.

| Score | Verdict | Action |
|-------|---------|--------|
| 80-100 | PASS | Display `Confidence: N%` at report top. Exit loop immediately |
| < 80 | WARN/FAIL | Generator-Critic loop: Critic(Lead) feedback → Generator(Teammate/Lead) fixes JSON → re-verify (max 3 rounds) |

**Post-loop final verdict**:

| Condition | Action |
|-----------|--------|
| PASS(80+) achieved | Proceed to Phase 3 |
| 3 rounds done, WARN(60-79) | Add `[CAUTION]` marker + issue list in appendix + "manual review recommended". Proceed to Phase 3 |
| 3 rounds done, FAIL(0-59) | Abort report generation. AskUserQuestion: (1) Continue (2) Re-analyze (3) Cancel |

**Output format**:

```json
{
  "round": 2,
  "score": 85,
  "verdict": "PASS",
  "history": [
    { "round": 1, "score": 68, "verdict": "WARN", "deductionCount": 7 },
    { "round": 2, "score": 85, "verdict": "PASS", "deductionCount": 3 }
  ],
  "deductions": [
    { "step": 1, "item": "Service name mismatch: user-svc vs user-service", "points": -5 },
    { "step": 3, "item": "Undetected DB connection: order-service → Redis", "points": -5 },
    { "step": 4, "item": "Unable to verify: payment-service → external-pg", "points": -2 }
  ],
  "corrections": [
    { "field": "dependency-mapper.serviceDependencies[2].to", "from": "user-svc", "to": "user-service", "round": 1 },
    { "field": "dependency-mapper.databaseConnections[+]", "added": "order-service → Redis", "round": 1 }
  ]
}
```

## Report Verification (Phase 4) — 4 Steps

### Step 1: Mermaid Syntax Validity

#### Alias rules

- Lowercase + digits only
- No hyphens(`-`), spaces, underscores(`_`), Korean

**Conversion rule**: `user-service` → `userservice`, `api-gateway` → `apigateway`

#### Structure validation

- Diagram type declaration (`C4Context`, `C4Container`, `C4Component`, `graph`)
- `title` declaration present
- All brackets matched: `(` ↔ `)`, `{` ↔ `}`
- `Rel(from, to, "label")` — from/to must be defined aliases
- No duplicate aliases
- Correct ` ```mermaid ` ~ ` ``` ` wrapping

#### Element syntax

```
Person(alias, "name", "desc")
System(alias, "name", "desc")
System_Ext(alias, "name", "desc")
Container(alias, "name", "tech", "desc")
ContainerDb(alias, "name", "tech", "desc")
ContainerQueue(alias, "name", "tech", "desc")
Component(alias, "name", "tech", "desc")
Container_Boundary(alias, "name") { ... }
Rel(from, to, "label")
```

**Scoring**: -5 per syntax error. -10 per undefined alias reference.

### Step 2: Obsidian Link Validity

#### Wiki link formats

| Pattern | Example |
|---------|---------|
| `[[filename]]` | `[[02-container]]` |
| `[[filename\|display]]` | `[[02-container\|Container Diagram]]` |
| `[[filename#section]]` | `[[04-service-catalog#Service List]]` |
| `[[path/filename]]` | `[[03-components/user-service]]` |
| `[[../filename]]` | `[[../02-container]]` |

#### YAML Frontmatter

```yaml
---
created: YYYY-MM-DD     # required
tags:                    # required
  - msa
  - c4-model
---
```

#### Checks

- All `[[...]]` links point to actually generated files
- `#section` references match actual headings in target file
- Relative paths under `03-components/` are correct
- YAML frontmatter is valid YAML
- Frontmatter contains `created`, `tags` fields

**Scoring**: -3 per broken link. -5 per missing/invalid frontmatter.

### Step 3: C4 Model Completeness

#### Level 1 (System Context) Required Elements

| Element | Importance |
|---------|-----------|
| title | Required |
| Person (min 1) | Required |
| System (min 1) | Required |
| Rel (min 1) | Required |
| System_Ext (if applicable) | Recommended |

#### Level 2 (Container) Required Elements

| Element | Importance |
|---------|-----------|
| title | Required |
| Container_Boundary | Required |
| All services included (full service-discoverer results) | Required |
| ContainerDb (if DB exists) | Recommended |
| ContainerQueue (if MQ exists) | Recommended |
| Rel (inter-service relationships) | Required |

#### Level 3 (Component) Required Elements

| Element | Importance |
|---------|-----------|
| title | Required |
| Container_Boundary | Required |
| Component (min 1) | Required |
| External dependencies | Recommended |

**Scoring**: -10 per missing required element. -3 per missing recommended element.

### Step 4: Analysis-Report Consistency

- All services from service-discoverer appear in Container diagram
- Key dependencies from dependency-mapper expressed as Rel
- DB/MQ from infra-analyzer expressed as ContainerDb/ContainerQueue
- Corrections from cross-validation reflected in report

**Scoring**: -10 per missing service. -5 per missing dependency. -5 per unreflected correction.

## Quality Score Final Calculation

**Base score**: 100, subtract all 4-step deductions.

| Score | Action |
|-------|--------|
| 80-100 | Final output. Exit loop immediately |
| < 80 | Generator-Critic loop: Critic(Lead) feedback → Generator(Lead) fixes → re-verify (max 3 rounds) |

**Post-loop final verdict**:

| Condition | Action |
|-----------|--------|
| PASS(80+) achieved | Final output |
| 3 rounds done, 60+ | Output with warnings |
| 3 rounds done, < 60 | `Quality verification failed` warning + error list + manual fix guide |

**Output format**:

```json
{
  "round": 2,
  "score": 88,
  "verdict": "PASS",
  "history": [
    { "round": 1, "score": 68, "verdict": "WARN", "issueCount": 5, "autoFixCount": 3, "manualFixCount": 2 },
    { "round": 2, "score": 88, "verdict": "PASS", "issueCount": 1, "autoFixCount": 0, "manualFixCount": 1 }
  ],
  "issues": [
    { "step": 2, "severity": "warning", "item": "03-components/order.md: [[../04-service-catalog#Orders]] section not found", "autoFixable": false }
  ],
  "fixHistory": [
    { "round": 1, "fixed": "02-container.md: alias 'user-service' → 'userservice'", "type": "mermaid-alias" },
    { "round": 1, "fixed": "01-system-context.md: Person element added", "type": "c4-element" },
    { "round": 1, "fixed": "03-components/order.md: broken link fixed", "type": "obsidian-link" }
  ],
  "autoFixCount": 0,
  "manualFixCount": 1
}
```
