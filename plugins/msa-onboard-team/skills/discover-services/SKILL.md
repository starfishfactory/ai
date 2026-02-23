---
name: discover-services
description: Identify microservices in an MSA project (standalone)
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
argument-hint: <project path>
---

# Service Discovery: $ARGUMENTS

## Target

Path: `$ARGUMENTS`

> If `$ARGUMENTS` is empty, analyze current directory (`.`).

## Auto-Scan Results

Directory structure:
!`find ${ARGUMENTS:-.} -maxdepth 2 -type d 2>/dev/null | head -50`

Build files:
!`find ${ARGUMENTS:-.} -maxdepth 3 \( -name "package.json" -o -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" -o -name "go.mod" -o -name "Cargo.toml" -o -name "requirements.txt" -o -name "pyproject.toml" \) 2>/dev/null`

Docker files:
!`find ${ARGUMENTS:-.} -maxdepth 3 -name "Dockerfile" 2>/dev/null`

## Analysis Process

Analyze directly based on scan results above:

1. **Project structure**: Determine mono-repo / multi-repo
2. **Build-file-based service identification**: package.json, pom.xml, build.gradle, etc.
3. **Framework detection**: Spring Boot, Express, NestJS, FastAPI, gin, etc.
4. **Dockerfile-based confirmation**: Independent deployment units, FROM image, EXPOSE ports
5. **Service role inference**: Classify roles — gateway, auth, order, etc.

## Output

Present results as a service list table:

| Service | Path | Language | Framework | Port | Role | Dockerfile |
|---------|------|----------|-----------|------|------|------------|

List shared libraries separately if found:

| Library | Path |
|---------|------|

Also output architecture type (mono-repo / multi-repo).
