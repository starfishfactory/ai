---
description: Generate C4 model Mermaid diagrams from analysis results (standalone)
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
argument-hint: <project path>
---

# C4 Diagram Generation: $ARGUMENTS

## Target

Path: `$ARGUMENTS`

> If `$ARGUMENTS` is empty, analyze current directory (`.`).

## Auto-Scan Results

Directory structure:
!`find ${ARGUMENTS:-.} -maxdepth 2 -type d 2>/dev/null | head -50`

Build files:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "package.json" -o -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" -o -name "go.mod" \) 2>/dev/null`

Docker:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "Dockerfile" -o -name "docker-compose*.yml" -o -name "docker-compose*.yaml" \) 2>/dev/null`

## Execution

### 1. User Confirmation

Use AskUserQuestion to confirm output path (default: `./msa-onboard-report`).

### 2. Quick Analysis

Read project structure and build files to identify services and dependencies. Perform directly:
- Service identification (build files + Dockerfile)
- Infra analysis (docker-compose, k8s)
- Dependency mapping (HTTP, gRPC, MQ, DB)

### 3. C4 Diagram Generation

Reference `c4-mermaid-reference.md` and `output-templates.md` to generate files with 3-level Mermaid diagrams:
- `01-system-context.md` (Level 1: C4Context)
- `02-container.md` (Level 2: C4Container)
- `03-components/{service}.md` (Level 3: C4Component, per major service)

Also generate:
- `README.md` (TOC + overview)
- `04-service-catalog.md` (service list)
- `05-infra-overview.md` (infrastructure)
- `06-dependency-map.md` (dependency map + graph LR diagram)

## Mermaid C4 Syntax Rules

- alias: lowercase + digits only (no hyphens, spaces)
- `Person(alias, "name", "desc")`
- `System(alias, "name", "desc")` / `System_Ext(alias, "name", "desc")`
- `Container(alias, "name", "tech", "desc")`
- `ContainerDb(alias, "name", "tech", "desc")`
- `ContainerQueue(alias, "name", "tech", "desc")`
- `Component(alias, "name", "tech", "desc")`
- `Container_Boundary(alias, "name")`
- `Rel(from, to, "label")`

## Obsidian Compatibility

- Include YAML frontmatter (`created`, `tags` required)
- Wiki links for cross-references: `[[02-container|Container Diagram]]`
- Tags: `#c4-model`, `#msa`, `#architecture`
