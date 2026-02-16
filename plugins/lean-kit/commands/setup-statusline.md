---
description: Install statusline v3 (plan detection + element customization)
allowed-tools: Bash, AskUserQuestion
---

# Setup Statusline v3

2-phase install: detect → collect user prefs → single shell execution.

## Step 1: Detect & Collect

Run detection:
```bash
bash <plugin_root>/scripts/setup-statusline.sh --detect
```

Output format: `PLAN=Max JQ=1 CCUSAGE=1`

If JQ=0 or CCUSAGE=0 in output, inform user: missing deps will be auto-installed in Step 2.

Parse result, then AskUserQuestion:

**Q1 — Plan confirm** (single select):
- header: "Plan"
- question: "Detected plan: {PLAN}. Correct?"
- options: [Yes (Recommended)], [Pro], [Max], [API]

**Q2 — Elements to hide** (multiSelect):
- header: "Hide"
- question: "Disable any elements? (plan defaults already applied: Pro/Max→Cost OFF, API→Extra OFF)"
- options:
  - 👤 Account (ACCOUNT)
  - 🧠 Context (CONTEXT)
  - 💰 Cost (COST)
  - ⌛ Session (SESSION)

If Q1 answer != "Yes", override plan value.

## Step 2: Execute

Build hide list from Q2 selections. Run:
```bash
bash <plugin_root>/scripts/setup-statusline.sh --plan {plan} --hide {comma_items}
```

Omit `--hide` if no items selected.

Display script output to user. Done.

## Display Items

| Icon | Item | Key |
|------|------|-----|
| 👤 | Account | ACCOUNT |
| 📁 | Directory | DIR |
| 🌿 | Git branch | GIT |
| 🤖 | Model | MODEL |
| 🧠 | Context | CONTEXT |
| 💰 | Cost | COST |
| 📋 | Plan | PLAN |
| ⚡ | Extra Usage | EXTRA |
| ⌛ | Session | SESSION |
