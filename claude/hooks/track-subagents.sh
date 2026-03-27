#!/usr/bin/env bash
# Track active subagents by writing/removing entries in a temp file.
# Used by SubagentStart / SubagentStop hooks.

input=$(cat)
AGENT_TYPE=$(echo "$input" | jq -r '.agent_type // empty')
HOOK_EVENT=$(echo "$input" | jq -r '.hook_event_name')
SESSION_ID=$(echo "$input" | jq -r '.session_id // "default"')

FILE="/tmp/.claude_subagents_${SESSION_ID}"

LOCKDIR="${FILE}.lock"
acquire_lock() { while ! mkdir "$LOCKDIR" 2>/dev/null; do sleep 0.05; done; }
release_lock() { rmdir "$LOCKDIR" 2>/dev/null; }
trap release_lock EXIT

if [ "$HOOK_EVENT" = "SubagentStart" ] && [ -n "$AGENT_TYPE" ]; then
  acquire_lock
  echo "$AGENT_TYPE" >> "$FILE"
  release_lock
elif [ "$HOOK_EVENT" = "SubagentStop" ] && [ -n "$AGENT_TYPE" ]; then
  if [ -f "$FILE" ]; then
    acquire_lock
    # Remove first matching line only (BSD sed compatible via awk)
    awk -v agent="$AGENT_TYPE" '!found && $0 == agent {found=1; next} {print}' "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"
    # Clean up empty file
    [ ! -s "$FILE" ] && rm -f "$FILE"
    release_lock
  fi
fi
exit 0
