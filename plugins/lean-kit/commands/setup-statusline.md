---
description: Install statusline v3 (plan detection + element customization)
allowed-tools: Read, Bash, Edit, Glob, AskUserQuestion, Write
---

# Setup Statusline v3

Install lean-kit 1-line compact statusline and configure optimal settings for your plan type.

## Procedure

### Step 1: Copy statusline.sh

Copy `scripts/statusline.sh` from this plugin to `~/.claude/statusline.sh`.

1. Glob to find `scripts/statusline.sh` absolute path
2. Run Bash:
   ```bash
   cp <absolute_path> ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
   ```

### Step 2: Auto-detect Plan

Detect plan type from `~/.claude.json`:
- `billingType=stripe_subscription` + `hasExtraUsageEnabled=true` → **Max**
- `billingType=stripe_subscription` + `hasExtraUsageEnabled=false` → **Pro**
- No oauthAccount → **API**

Confirm/override via AskUserQuestion:
```
Detected plan: {detected_plan}
Is this correct?
Options: [Yes] [Pro] [Max] [API]
```

### Step 3: Select Display Elements

Present plan-specific defaults and accept user customization.

**Recommended defaults:**
- **Pro**: Cost OFF, rest ON
- **Max**: Cost OFF, Extra ON, rest ON
- **API**: Extra OFF, rest ON

AskUserQuestion(multiSelect) to select elements to turn OFF:
```
Based on recommended defaults, any additional elements to disable?
Options (multiSelect):
[ ] 👤 Account (SHOW_ACCOUNT)
[ ] 📁 Directory (SHOW_DIR)
[ ] 🌿 Git (SHOW_GIT)
[ ] 🤖 Model (SHOW_MODEL)
[ ] 🧠 Context (SHOW_CONTEXT)
[ ] 💰 Cost (SHOW_COST)
[ ] 📋 Plan (SHOW_PLAN)
[ ] ⚡ Extra (SHOW_EXTRA_USAGE)
[ ] ⌛ Session (SHOW_SESSION)
```

### Step 4: Generate statusline.conf

Write `~/.claude/statusline.conf` reflecting user selections:
```bash
# lean-kit statusline v3.0 config
# 0=hide, 1=show
SHOW_ACCOUNT=1
SHOW_DIR=1
SHOW_GIT=1
SHOW_MODEL=1
SHOW_CONTEXT=1
SHOW_COST=0          # Pro/Max recommended: OFF
SHOW_SESSION=1
SHOW_PLAN=1
SHOW_EXTRA_USAGE=1
PLAN_TYPE=           # Empty = auto-detect
```

### Step 5: Configure settings.json

Read `~/.claude/settings.json`:
- If `statusLine` field exists → AskUserQuestion to confirm replacement
- If absent or agreed → Edit to add:
  ```json
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
  ```
- Do not modify any other fields

### Step 6: Verify

```bash
echo '{"cwd":"/tmp","model":{"display_name":"Opus"}}' | ~/.claude/statusline.sh
```

Success if 1-line output shows configured elements. Takes effect on Claude Code restart.

## Display Items

| Icon | Item | Description |
|------|------|-------------|
| 👤 | Account | Email from ~/.claude.json |
| 📁 | Directory | Current project path |
| 🌿 | Git branch | Current branch/commit |
| 🤖 | Model | Claude model name |
| 🧠 | Context remaining | With progress bar |
| 💰 | Cost + burn rate | For API users ($/h) |
| 📋 | Plan type | Pro/Max/API |
| ⚡ | Extra Usage | Max plan only |
| ⌛ | Session remaining | ccusage integration |

## Config File

`~/.claude/statusline.conf` controls display elements.
`STATUSLINE_CONF` env var overrides the config path.
