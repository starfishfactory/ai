---
name: setup-statusline
description: Install 1-line compact statusline
allowed-tools: Read, Bash, Edit, Glob, AskUserQuestion
---

# Setup Statusline

Install the lean-kit 1-line compact statusline.

## Procedure

### Step 1: Copy statusline.sh

Copy `scripts/statusline.sh` from this plugin to `~/.claude/statusline.sh`.

1. Use Glob to locate `scripts/statusline.sh` absolute path
2. Run via Bash:
   ```bash
   cp <resolved_absolute_path> ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
   ```

### Step 2: Configure settings.json

Read `~/.claude/settings.json` with Read:
- If `statusLine` field already exists → use AskUserQuestion to confirm replacement
- If absent or user agrees → add via Edit:
  ```json
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
  ```
- Do NOT modify any other fields

### Step 3: Verify

```bash
echo '{"cwd":"/tmp","model":{"display_name":"Opus"}}' | ~/.claude/statusline.sh
```

Success if 1-line output contains 📁 and 🤖 icons. Applies after Claude Code restart.

## Output Items

| Icon | Item |
|------|------|
| 👤 | Anthropic account |
| 📁 | Working directory |
| 🌿 | Git branch |
| 🤖 | Model name |
| 🧠 | Context remaining % |
| 💰 | Cost + burn rate |
| ⌛ | Session remaining time |
