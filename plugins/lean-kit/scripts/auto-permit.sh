#!/usr/bin/env bash
#
# lean-kit auto-permit.sh - PermissionRequest auto-approval
# Auto-approves safe tools/commands when permission dialog appears.
#
# Environment variables:
#   LEAN_KIT_AUTO_PERMIT=1  Must be set for activation (opt-in)
#   LEAN_KIT_DEBUG=1        Debug logging
#
# Config file (optional): ~/.claude/hooks/lean-kit-permit.conf
#   If file does not exist, default rules below are used.
#   If file exists, only matching sections are overridden.
#
# Dependency: jq
# Limitation: Does not work in non-interactive mode (-p) (official limitation)

# === Check opt-in ===
[ "${LEAN_KIT_AUTO_PERMIT:-0}" != "1" ] && exit 0

# === Check jq dependency ===
command -v jq &>/dev/null || exit 0

# === Default rules (used when config file is absent) ===
read -r -d '' DEFAULT_DENY_BASH <<'RULES' || true
rm -rf /
rm -rf ~
sudo rm
mkfs
dd if=
chmod -R 777 /
RULES

read -r -d '' DEFAULT_ALLOW_BASH <<'RULES' || true
git
npm
npx
node
python
pip
brew
ls
cat
head
tail
wc
echo
mkdir
cp
mv
chmod
touch
ln
curl
wget
jq
gh
docker
make
cargo
yarn
pnpm
which
type
env
printenv
pwd
date
whoami
id
uname
sort
uniq
diff
find
grep
rg
sed
awk
tr
xargs
tee
source
bash
sh
test
claude
realpath
dirname
basename
RULES

read -r -d '' DEFAULT_DENY_FILES <<'RULES' || true
.env
credentials
.ssh/
.gnupg/
secrets
.git/
RULES

read -r -d '' DEFAULT_ALLOW_TOOLS <<'RULES' || true
Edit
Write
NotebookEdit
Task
RULES

read -r -d '' DEFAULT_ALLOW_MCP <<'RULES' || true
mcp__*get*
mcp__*list*
mcp__*read*
mcp__*search*
mcp__*query*
mcp__*fetch*
mcp__*view*
mcp__*find*
mcp__*count*
mcp__*describe*
mcp__*show*
RULES

# === Config file (optional override) ===
CONF="${LEAN_KIT_PERMIT_CONF:-$HOME/.claude/hooks/lean-kit-permit.conf}"

INPUT=$(cat)
[ -z "$INPUT" ] && exit 0

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
[ -z "$TOOL_NAME" ] && exit 0

# === Debug logging ===
if [ "${LEAN_KIT_DEBUG:-0}" = "1" ]; then
  LOG="$HOME/.claude/hooks/lean-kit-debug.log"
  echo "[$(date)] auto-permit: tool=$TOOL_NAME" >> "$LOG"
fi

# JSON response helpers
allow_json() {
  printf '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
}
deny_json() {
  printf '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","message":"%s"}}}' "$1"
}

# Read section from config file, fall back to defaults (bash 3.2 compatible)
read_section() {
  local section="$1"
  # If section exists in config file, read from file
  if [ -f "$CONF" ] && grep -q "^\[$section\]" "$CONF" 2>/dev/null; then
    sed -n "/^\[$section\]/,/^\[/p" "$CONF" | grep -v '^\[' | grep -v '^#' | grep -v '^$'
    return
  fi
  # Use defaults
  case "$section" in
    deny_bash)    echo "$DEFAULT_DENY_BASH" ;;
    allow_bash)   echo "$DEFAULT_ALLOW_BASH" ;;
    deny_files)   echo "$DEFAULT_DENY_FILES" ;;
    allow_tools)  echo "$DEFAULT_ALLOW_TOOLS" ;;
    allow_mcp)    echo "$DEFAULT_ALLOW_MCP" ;;
  esac
}

# === 1. Bash command handling ===
if [ "$TOOL_NAME" = "Bash" ]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

  # Deny section: substring pattern matching
  while IFS= read -r pattern; do
    case "$CMD" in *$pattern*)
      deny_json "Blocked by deny rule: $pattern"
      exit 0 ;;
    esac
  done < <(read_section "deny_bash")

  # Allow section: prefix matching
  while IFS= read -r prefix; do
    case "$CMD" in "$prefix"\ *|"$prefix")
      allow_json; exit 0 ;;
    esac
  done < <(read_section "allow_bash")

  exit 0  # Unclassified → prompt user
fi

# === 2. File modification tools ===
case "$TOOL_NAME" in
  Edit|Write|NotebookEdit)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    # deny_files section: protect sensitive files
    while IFS= read -r pattern; do
      case "$FILE_PATH" in *$pattern*)
        exit 0 ;;  # Fall back to user prompt
      esac
    done < <(read_section "deny_files")
    # Approve if tool is in allow_tools
    if read_section "allow_tools" | grep -qx "$TOOL_NAME"; then
      allow_json; exit 0
    fi ;;
esac

# === 3. Other tools (Task, MCP, etc.) ===
if read_section "allow_tools" | grep -qx "$TOOL_NAME"; then
  allow_json; exit 0
fi

# === 4. MCP tools - pattern matching ===
while IFS= read -r pattern; do
  case "$TOOL_NAME" in $pattern)
    allow_json; exit 0 ;;
  esac
done < <(read_section "allow_mcp")

# === 5. Unmatched → prompt user ===
exit 0
