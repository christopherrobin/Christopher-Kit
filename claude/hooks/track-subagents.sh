#!/usr/bin/env bash
# Track active subagents by writing/removing entries in a temp file.
# Used by SubagentStart / SubagentStop hooks.

input=$(cat)
AGENT_TYPE=$(echo "$input" | jq -r '.agent_type // empty')
HOOK_EVENT=$(echo "$input" | jq -r '.hook_event_name')
SESSION_ID=$(echo "$input" | jq -r '.session_id // "default"')

FILE="/tmp/.claude_subagents_${SESSION_ID}"

LOCKDIR="${FILE}.lock"
have_lock=false
release_lock() { [ "$have_lock" = true ] && rmdir "$LOCKDIR" 2>/dev/null; have_lock=false; }

# Bounded lock: wait up to ~2s, stealing locks abandoned by killed processes.
# Hooks block Claude Code, so giving up and proceeding unlocked beats hanging
# forever (the statusline self-heals stale state after 5 minutes anyway).
acquire_lock() {
  tries=0
  while ! mkdir "$LOCKDIR" 2>/dev/null; do
    lock_mtime=$(stat -f %m "$LOCKDIR" 2>/dev/null || date +%s)
    if [ $(( $(date +%s) - lock_mtime )) -ge 5 ]; then
      rmdir "$LOCKDIR" 2>/dev/null
      continue
    fi
    tries=$((tries + 1))
    [ "$tries" -ge 40 ] && return 0
    sleep 0.05
  done
  have_lock=true
  # Arm the trap only after we actually hold the lock, so a no-op invocation
  # never releases a lock owned by another running process
  trap release_lock EXIT
}

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
