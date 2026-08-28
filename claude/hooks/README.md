# Claude Hooks

Hook scripts for Claude Code lifecycle events.

## track-subagents.sh

Tracks which subagents are currently running by writing their names to a per-session state file at `/tmp/.claude_subagents_<session_id>`. The [status line](../statusline/) reads this file to show active agents next to the model name.

- `SubagentStart` appends the agent type to the file
- `SubagentStop` removes the first matching entry (and deletes the file when it empties)

Writes are guarded by a lock with a bounded wait, so a killed process can never wedge Claude Code: abandoned locks are stolen after 5 seconds, and the hook gives up and proceeds unlocked after ~2 seconds rather than hang.

## Prerequisites

- `jq` for JSON parsing
- macOS (uses BSD `stat`)

## Setup

1. Copy the script:

```bash
mkdir -p ~/.claude/hooks
cp track-subagents.sh ~/.claude/hooks/track-subagents.sh
```

2. Wire it up in `~/.claude/settings.json` (already included in [settings.example.json](../settings/settings.example.json)):

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/track-subagents.sh" }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/track-subagents.sh" }
        ]
      }
    ]
  }
}
```

Without this hook installed, the status line's agent display always shows `N/A`.
