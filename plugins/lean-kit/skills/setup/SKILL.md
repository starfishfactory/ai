---
name: setup
description: Verify plugin installation, check dependencies, show catalog
model: sonnet
allowed-tools: Read, Bash, Glob, AskUserQuestion
argument-hint: "[--check | --force]"
---

# Plugin Setup & Diagnostics: $ARGUMENTS

Verify SF plugin installation, check dependencies, and display the plugin catalog.

## Phase 1: Pre-flight Checks

Run the following checks in parallel:

### 1.1 CLI Tools

| Tool | Check Command | Required By |
|------|--------------|-------------|
| gh | `gh --version` + `gh auth status` | git plugin (PR creation/review) |
| jq | `jq --version` | lean-kit (statusline, auto-permit) |
| tmux | `which tmux` | msa-onboard-team (Agent Teams) |
| node | `node --version` | lean-kit (hooks scripts) |

### 1.2 Plugin Registry

Read `.claude-plugin/marketplace.json` from the repository root (use Glob to find it).
Extract the list of registered plugins.

## Phase 2: Plugin Integrity Verification

For each plugin in marketplace.json:

### 2.1 Structure Check

| Item | Check | Status |
|------|-------|--------|
| plugin.json | `{plugin_path}/.claude-plugin/plugin.json` exists and is valid JSON | PASS/FAIL |
| skills/ | `{plugin_path}/skills/` directory exists | PASS/FAIL |
| SKILL.md files | At least one `SKILL.md` found under skills/ | PASS/FAIL |

### 2.2 Agent Check

Scan `{plugin_path}/agents/*.md` and `agents/core/*.md` + `agents/advanced/*.md`:
- Verify each file exists and has valid frontmatter (name, model fields)

### 2.3 Hook Check

If `{plugin_path}/hooks/hooks.json` exists:
- Parse JSON validity
- Verify referenced scripts exist

## Phase 3: Catalog Output

### 3.1 Plugin × Skill Matrix

```
Plugin Catalog
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{plugin-name} (v{version})
  Skills: /plugin:skill1, /plugin:skill2, ...
  Agents: agent1 (model), agent2 (model), ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 3.2 Core/Advanced Agents

```
Core Agents
  - {name} ({model}): {description}

Advanced Agents
  - {name} ({model}): {description}
```

## Phase 4: Dependency Guidance

For each missing tool from Phase 1, show installation instructions:

| Tool | macOS | Linux |
|------|-------|-------|
| gh | `brew install gh` | `sudo apt install gh` |
| jq | `brew install jq` | `sudo apt install jq` |
| tmux | `brew install tmux` | `sudo apt install tmux` |
| node | `brew install node` | See nodejs.org |

## Output

Display results as formatted markdown directly (not in code blocks).
If `$ARGUMENTS` contains `--check`, run checks only (no catalog).
If `$ARGUMENTS` contains `--force`, re-run all checks even if cached.
