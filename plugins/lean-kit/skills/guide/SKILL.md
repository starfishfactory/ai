---
name: guide
description: Show lean-kit feature overview and activation status
allowed-tools: Read, Bash
---

# lean-kit Guide

Check activation status of all 3 lean-kit features and show usage guide.

## Step 1: Check Activation Status

Check the following 2 items and store as internal variables.

### 1-1. Statusline Status

Read `~/.claude/settings.json` with Read.
- `statusLine.command` contains `statusline.sh` → `statusline_active=true`
- Missing or not found → `statusline_active=false`

### 1-2. Auto-permit Status

Run via Bash:
```bash
echo "${LEAN_KIT_AUTO_PERMIT:-0}"
```
- Output `1` → `autopermit_active=true`
- Otherwise → `autopermit_active=false`

> **Note**: Notification is auto-registered via hooks.json on plugin install. Always active.

## Step 2: Render Feature Guide

Render the content below as **markdown directly** (not inside code blocks). Dynamically show each feature's **Status** column based on Step 1 results.

Summary table:

| # | Feature | Description | Platform | Status |
|---|---------|-------------|----------|--------|
| 1 | Notification | macOS desktop alert on approval/input needed | macOS | ✅ Auto-active |
| 2 | Auto-permit | Auto-approve safe tool/command permissions | All | Step 1-2 result |
| 3 | Statusline | 1-line compact status bar at terminal bottom | All | Step 1-1 result |

Feature 1 — **Notification (macOS Desktop Alert)**:

Displays macOS native notifications when user input is needed (approval, idle, question).
- Status: Auto-active on plugin install (built into hooks.json)
- Platform: macOS only (auto-skip on non-macOS)
- Requirement: GUI session required (auto-skip on SSH/headless)

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `LEAN_KIT_SOUND` | `Glass` | Notification sound (empty string = silent) |
| `LEAN_KIT_DEBUG` | `0` | Enable debug logging when `1` |

Feature 2 — **Auto-permit (Permission Auto-Approval)**:

Auto-approves safe Bash commands, file edits, and MCP read tools.
- Status: **opt-in required** (set `LEAN_KIT_AUTO_PERMIT=1`)
- Dependency: `jq` (auto-skip if not installed)
- Customization: `~/.claude/hooks/lean-kit-permit.conf`

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `LEAN_KIT_AUTO_PERMIT` | `0` | Enable when `1` |
| `LEAN_KIT_DEBUG` | `0` | Enable debug logging when `1` |
| `LEAN_KIT_PERMIT_CONF` | `~/.claude/hooks/lean-kit-permit.conf` | Custom rules file path |

Feature 3 — **Statusline (1-Line Compact Status Bar)**:

Displays account, directory, branch, model, context, cost, and session info in 1 line at terminal bottom.
- Status: Requires manual `statusLine.command` setup in `~/.claude/settings.json`
- Setup: Run `/lean-kit:setup-statusline`
- Dependencies: `jq` (required), `ccusage` (optional, for session remaining time)

Output items:

| Icon | Item |
|------|------|
| 👤 | Anthropic account |
| 📁 | Working directory |
| 🌿 | Git branch |
| 🤖 | Model name |
| 🧠 | Context remaining % |
| 💰 | Cost + burn rate |
| ⌛ | Session remaining time |

## Step 3: Show Required Actions

Based on Step 1 results, guide only items that need action.

- If `autopermit_active=false`:
  > To enable Auto-permit, add to your shell profile (`.zshrc` etc.):
  > `export LEAN_KIT_AUTO_PERMIT=1`
  > To use immediately in the current session, run the same command in your terminal.

- If `statusline_active=false`:
  > To set up Statusline, run `/lean-kit:setup-statusline`.

- If all features are active:
  > All features are active!
