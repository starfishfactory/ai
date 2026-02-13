---
description: MSA environment Agent Teams parallel analysis + cross-validation + C4 report generation
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
argument-hint: <project path>
---

# MSA Onboarding Analysis (Agent Teams): $ARGUMENTS

> **Agent Teams is experimental.**
> - Enable: add `{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }` to settings.json or .claude/settings.json
> - Docs: https://code.claude.com/docs/en/agent-teams
> - Cost: ~7x tokens (plan mode). More with Opus teammates
> - Requires tmux: `brew install tmux` (macOS) / `sudo apt install tmux` (Linux)
> - iTerm2: Settings → General → Magic → Enable Python API
> - **Unsupported terminals**: VS Code integrated terminal, Windows Terminal, Ghostty (split pane mode)

## Target

Path: `$ARGUMENTS`

> If `$ARGUMENTS` is empty, use current directory (`.`).

## Phase 0: Project Scan + User Confirmation

### Auto-Scan

Directory structure:
!`find ${ARGUMENTS:-.} -maxdepth 2 -type d 2>/dev/null | head -50`

Build files:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "package.json" -o -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" -o -name "go.mod" -o -name "Cargo.toml" -o -name "requirements.txt" -o -name "pyproject.toml" \) 2>/dev/null`

Docker config:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "Dockerfile" -o -name "docker-compose*.yml" -o -name "docker-compose*.yaml" \) 2>/dev/null`

Kubernetes config:
!`find ${ARGUMENTS:-.} -maxdepth 4 \( -name "*.yaml" -o -name "*.yml" \) \( -path "*/k8s/*" -o -path "*/kubernetes/*" -o -path "*/helm/*" -o -path "*/deploy/*" \) 2>/dev/null | head -30`

CI/CD config:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "Jenkinsfile" -o -name ".gitlab-ci.yml" -o -path "*/.github/workflows/*" -o -name "Makefile" \) 2>/dev/null`

### User Confirmation

Use AskUserQuestion to confirm:
- **Report output path**: where to save generated docs (default: `./msa-onboard-report`)

## Phase 1: Parallel Analysis (Agent Teams — spawn 3 teammates)

**Critical instructions:**
- **NEVER analyze directly.** MUST spawn 3 teammates for parallel analysis.
- Wait until ALL teammates complete.
- Status display may not update. Manually check if status stalls, then proceed.
- **Do NOT dismiss the team yet.** Teammates serve as Generators in Phase 2 GC loop. Dismiss team only after Phase 2 loop completes.

### Teammate 1: Service Discoverer (service-discoverer)

Spawn with this prompt:

```
You are an expert at identifying microservices in MSA projects.
Target project path: ${ARGUMENTS:-.}

## Analysis Process

1. **Project structure**: Determine mono-repo / multi-repo from top-level directory structure. Check independence of subdirectories.

2. **Build-file-based service identification**: Treat each build file directory as a potential service:
   - package.json → Node.js (Express, NestJS, Next.js, etc.)
   - pom.xml → Java (Spring Boot, Quarkus, etc.)
   - build.gradle / build.gradle.kts → Java/Kotlin (Spring Boot, etc.)
   - go.mod → Go (gin, echo, fiber, etc.)
   - Cargo.toml → Rust
   - requirements.txt / pyproject.toml → Python (FastAPI, Django, Flask, etc.)

3. **Framework detection**: Identify exact framework per service:
   - Java/Kotlin: spring-boot-starter-web, quarkus, micronaut
   - Node.js: express, @nestjs/core, fastify, koa
   - Python: fastapi, django, flask
   - Go: gin-gonic, echo, fiber

4. **Dockerfile-based confirmation**: Directories with Dockerfile = independent deployment unit. Check FROM image for runtime, collect EXPOSE port info, check multi-stage build patterns.

5. **Service role inference**: Infer roles from directory names, package names, README:
   - *-gateway, *-api: API Gateway
   - *-auth, *-user: Auth/User management
   - *-order, *-payment: Business domain
   - *-common, *-shared, *-lib: Shared library (not a service)

## Output

Save results to {output_path}/_service-discovery.json:

{
  "type": "mono-repo | multi-repo",
  "services": [
    {
      "name": "service name",
      "path": "relative path",
      "language": "Java | TypeScript | Python | Go",
      "framework": "Spring Boot | Express | FastAPI",
      "buildTool": "Gradle | Maven | npm | pip",
      "port": 8080,
      "role": "API Gateway | Business Service | ...",
      "hasDockerfile": true
    }
  ],
  "libraries": [
    {
      "name": "shared library name",
      "path": "relative path"
    }
  ]
}

Report the saved file path when done.
```

### Teammate 2: Infra Analyzer (infra-analyzer)

Spawn with this prompt:

```
You are an expert at analyzing infrastructure configuration in MSA projects.
Target project path: ${ARGUMENTS:-.}

## Analysis Process

1. **Docker Compose analysis** (docker-compose*.yml / docker-compose*.yaml):
   - services: name, image, build context per service
   - ports: port mapping (host:container)
   - networks: network config, service grouping
   - volumes: volume mounts, data persistence
   - depends_on: startup order, dependencies
   - environment: env var keys only (never collect values)
   - healthcheck: health check config

2. **Kubernetes analysis** (YAML manifests):
   - Deployment: replicas, image, resources, env
   - Service: type (ClusterIP/NodePort/LoadBalancer), ports
   - Ingress: host, path, TLS
   - ConfigMap: key list (no values)
   - Secret: key list (no values)
   - HPA: minReplicas, maxReplicas, metrics
   - PVC: storage size, accessMode
   - Helm charts: Chart.yaml (name, version, dependencies), values.yaml (key config keys)

3. **CI/CD pipeline analysis**:
   - GitHub Actions: .github/workflows/*.yml
   - GitLab CI: .gitlab-ci.yml
   - Jenkins: Jenkinsfile
   - Focus: build stages, deployment strategy, environment separation, secrets management

4. **Environment config analysis**:
   - .env.example / .env.sample: key list
   - application.yml / application.properties: profile structure
   - Per-environment config separation patterns

> IMPORTANT: NEVER collect actual secret values. Analyze key names and structure only.

## Output

Save results to {output_path}/_infra-analysis.json:

{
  "containerOrchestration": {
    "type": "Docker Compose | Kubernetes | ECS",
    "services": ["service list"],
    "networks": ["network list"]
  },
  "cicd": {
    "tool": "GitHub Actions | GitLab CI | Jenkins",
    "stages": ["build", "test", "deploy"],
    "environments": ["dev", "staging", "prod"]
  },
  "networking": {
    "ingressRoutes": [
      { "host": "example.com", "path": "/api", "service": "api-gateway" }
    ]
  },
  "storage": {
    "databases": [
      { "name": "db-name", "type": "PostgreSQL", "connectedServices": ["svc1"] }
    ],
    "volumes": ["volume list"]
  }
}

Report the saved file path when done.
```

### Teammate 3: Dependency Mapper (dependency-mapper)

Spawn with this prompt:

```
You are an expert at statically analyzing inter-service dependencies in MSA projects.
Target project path: ${ARGUMENTS:-.}

## Analysis Process

1. **HTTP call detection**: Detect HTTP calls from each service to others
   - Java/Spring: RestTemplate, WebClient, FeignClient
   - Node.js: axios, fetch, got, node-fetch
   - Python: requests, httpx, aiohttp
   - Go: http.Client, http.Get, http.Post
   - URL patterns: http://, https://, URLs containing service names
   - Service discovery: Eureka client, Consul agent, K8s Service DNS
   - Env-var-based: SERVICE_URL, API_HOST, etc.

2. **gRPC communication detection**:
   - .proto file locations and service definitions
   - gRPC stub generation code
   - gRPC client configuration

3. **Message queue communication detection**:
   - Kafka: KafkaTemplate/KafkaProducer(producer), @KafkaListener/KafkaConsumer(consumer), topic names
   - RabbitMQ: @RabbitListener, amqplib, pika, Exchange/Queue/Routing Key
   - Redis Pub/Sub: RedisMessageListenerContainer, ioredis

4. **Database connection mapping**:
   - JDBC URL (jdbc:postgresql://, jdbc:mysql://) → PostgreSQL, MySQL
   - mongoose.connect, MongoClient → MongoDB
   - redis://, RedisTemplate, ioredis → Redis
   - SQLAlchemy, SQLALCHEMY_DATABASE_URI → Python ORM
   - gorm.Open, sql.Open → Go
   - Map DB names → services to detect shared DB access

5. **External system integrations**:
   - AWS SDK calls (S3, SQS, SNS, DynamoDB)
   - External API calls (payment, email, SMS, etc.)
   - OAuth/OIDC integrations (Keycloak, Auth0, etc.)

## Confidence Labeling

Label each dependency:
- **Confirmed**: directly verified in code
- **[Needs Verification]**: found only in config files or inferred

> IMPORTANT: Do not guess. Dependencies not confirmed in code MUST be marked [Needs Verification].

## Output

Save results to {output_path}/_dependency-map.json:

{
  "serviceDependencies": [
    {
      "from": "service-a",
      "to": "service-b",
      "protocol": "REST | gRPC | Kafka | RabbitMQ",
      "detail": "GET /api/users | topic: user-events",
      "confidence": "Confirmed | [Needs Verification]"
    }
  ],
  "databaseConnections": [
    {
      "service": "service-a",
      "database": "db-name",
      "type": "PostgreSQL | MongoDB | Redis",
      "accessPattern": "JDBC | Mongoose | ioredis"
    }
  ],
  "externalSystems": [
    {
      "service": "service-a",
      "external": "AWS S3",
      "protocol": "SDK",
      "purpose": "file storage"
    }
  ],
  "messageQueues": [
    {
      "producer": "service-a",
      "consumer": "service-b",
      "broker": "Kafka",
      "topic": "user-events"
    }
  ]
}

Report the saved file path when done.
```

### Teammate Completion Wait

- **NEVER proceed to next Phase** until all 3 teammates complete.
- If status display stalls, manually check JSON output file existence:
  - `{output_path}/_service-discovery.json`
  - `{output_path}/_infra-analysis.json`
  - `{output_path}/_dependency-map.json`
- Proceed to Phase 2 when all files exist.
- **Do NOT dismiss the team.** Phase 2 GC loop requires Teammates as Generators. Dismiss after Phase 2 loop completes.

## Phase 2: Cross-Validation — Generator-Critic Loop (max 3 rounds)

> **Roles**: Critic = Lead (cross-validation), Generator = Teammates (feedback-based JSON fixes)

Reference `verification-standards.md` "Cross-Validation — 5 Steps".

### Loop Procedure (Round 1~3)

Each round:

#### Critic (Lead): Cross-Validation

1. Read and load all 3 JSON files
2. **Step 1 — Service consistency**: service-discoverer vs dependency-mapper service list comparison
3. **Step 2 — Infra-dependency alignment**: infra-analyzer vs dependency-mapper DB/port/network comparison
4. **Step 3 — Completeness check**: detect missing services/communications against Dockerfile/docker-compose (use Grep/Glob)
5. **Step 4 — Devil's Advocate**: verify `[Needs Verification]` items in source code (use Read/Grep)
6. **Step 5 — Confidence score**: deduction from 100

#### Verdict and Branching

| Score | Verdict | Action |
|-------|---------|--------|
| 80-100 | PASS | Exit loop → dismiss team → proceed to Phase 3 |
| < 80 | WARN/FAIL | Write feedback → instruct Generator(Teammates) to fix → next round |

#### Generator (Teammates): Feedback-Based Fixes

If Critic(Lead) scores below PASS, send **specific fix instructions** to relevant Teammate per discrepancy:
- e.g., "service-discoverer: unify user-svc → user-service"
- e.g., "dependency-mapper: order-service → Redis connection missing, confirmed in source — add it"
- e.g., "infra-analyzer: Redis missing from DB storage — add it"

Each Teammate fixes their own JSON file. Proceed to next round after fixes complete.

### Loop Exit Conditions

| Condition | Action |
|-----------|--------|
| PASS(80+) achieved | Dismiss team → proceed to Phase 3 |
| 3 rounds done, WARN(60-79) | Dismiss team with warnings → proceed to Phase 3 |
| 3 rounds done, FAIL(0-59) | Dismiss team → AskUserQuestion: (1) Continue (2) Re-analyze (3) Cancel |

#### User Choice Handling (on FAIL)

- **(1) Continue**: proceed to Phase 3 with FAIL warning
- **(2) Re-analyze**: restart from Phase 0 — re-confirm output path, spawn new teammates
- **(3) Cancel**: abort. Keep existing analysis results (`_*.json`)

### Post-Loop Team Dismissal

After GC loop ends, **MUST dismiss team** to prevent idle token consumption.

### Output

Save cross-validation results to `{output_path}/_cross-validation.json`. Include loop history (`round`, `history`).

## Phase 3: C4 Report Generation (Lead performs directly)

Reference `output-templates.md` and `c4-mermaid-reference.md` to generate directly.

### Files to Generate

```
{output_path}/
├── README.md                    # TOC + overview + verification summary
├── 01-system-context.md         # Level 1 C4Context diagram
├── 02-container.md              # Level 2 C4Container diagram
├── 03-components/               # Level 3 C4Component (per major service)
│   ├── {service-1}.md
│   └── {service-2}.md
├── 04-service-catalog.md        # Service list + tech stack
├── 05-infra-overview.md         # Infrastructure config
└── 06-dependency-map.md         # Dependency map + graph LR diagram
```

### Rules

- All files include YAML frontmatter (`created`, `tags` required)
- Mermaid alias: lowercase + digits only (no hyphens, spaces, underscores)
- Obsidian wiki links for cross-references: `[[filename|display]]`
- Reflect corrections from cross-validation
- If cross-validation score is WARN, include `[CAUTION]` marker and issue list in README.md

## Phase 4: Report Verification — Generator-Critic Self-Reflection Loop (max 3 rounds)

> **Roles**: Generator = Lead (fix report), Critic = Lead (verify report). Self-Reflection pattern.
> Rule-based verification (Mermaid syntax, Obsidian links) — no separate agent needed. Team already dismissed in Phase 2.

Reference `verification-standards.md` "Report Verification — 4 Steps".

### Loop Procedure (Round 1~3)

Each round:

#### Critic (Lead): Report Verification

1. **Step 1 — Mermaid syntax validity**: alias rules, structure, element syntax
2. **Step 2 — Obsidian link validity**: wiki links, frontmatter
3. **Step 3 — C4 model completeness**: Level 1/2/3 required elements
4. **Step 4 — Analysis-report consistency**: analysis JSON vs report content comparison

#### Verdict and Branching

| Score | Verdict | Action |
|-------|---------|--------|
| 80-100 | PASS | Exit loop → proceed to Phase 5 |
| < 80 | WARN/FAIL | Write feedback (issue list) → Generator(Lead) fixes → next round |

#### Generator (Lead): Feedback-Based Fixes

If Critic(Lead) scores below PASS, fix `autoFixable` items first:
- Fix Mermaid alias violations (e.g., `user-service` → `userservice`)
- Fix broken Obsidian links
- Add missing C4 elements
- Record fix history in `_report-audit.json` `fixHistory`

### Loop Exit Conditions

| Condition | Action |
|-----------|--------|
| PASS(80+) achieved | Proceed to Phase 5 |
| 3 rounds done, 60+ | Proceed to Phase 5 with warnings |
| 3 rounds done, < 60 | `Quality verification failed` warning + error list + manual fix guide |

### Output

Save report verification results to `{output_path}/_report-audit.json`. Include loop history (`round`, `history`, `fixHistory`).

## Phase 5: Final Output

Present to user:

1. **Generated file list** (with paths)
2. **Confidence score** (cross-validation): score/100
   - 80-100: PASS
   - 60-79: WARN — summary of items needing manual review
   - 0-59: FAIL — major issue list
3. **Quality score** (report verification): score/100
   - 80-100: PASS
   - 60-79: WARN — auto-fixed/unfixed items summary
   - 0-59: FAIL — error list + manual fix guide
4. **Key issues summary** (if any)
5. **How to view in Obsidian**:
   ```
   Open {output_path} as an Obsidian vault to render C4 Mermaid diagrams and inter-document links.
   ```
