# Claude Code Status Line

A two-line status bar for the Claude Code CLI that shows session info, git status, context usage, and rate limits at a glance.

```
⏱ 12m  project-name ❯ ↑0 ↓0 ❯  main    (line 1)
 ████████░░░░░░░ 53%   5h 12%   +42 -7  (line 2)
```

## Prerequisites

- [Nerd Font](https://github.com/romkatv/powerlevel10k#fonts) (e.g. MesloLGS NF) for icons
- `jq` for JSON parsing
- macOS Keychain access (for rate limit feature — uses Claude Code's OAuth token at runtime)

## Setup

1. Copy the script to Claude's config directory:

```bash
cp statusline-command.sh ~/.claude/statusline-command.sh
```

2. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
```

## What It Shows

### Line 1
| Element | Description |
|---------|-------------|
| Session duration | Time since the conversation started |
| Project name | Current directory name |
| Git ahead/behind | Commits ahead/behind remote |
| Git branch | Branch name with dirty indicator (`*`) |
| Worktree | Shown when a git worktree is active |
| Agent | Shown when a subagent is running |

### Line 2
| Element | Description |
|---------|-------------|
| Context bar | Green/yellow/red progress bar with percentage. Blinks at 87%+ |
| 5h rate limit | Anthropic API rate limit usage (cached 60s) |
| Lines diff | Lines added/removed in the session |

## Notes

- The rate limit feature fetches usage data from the Anthropic API using your Claude Code OAuth token stored in macOS Keychain. No credentials are hardcoded — they're read at runtime. This feature only works on macOS with an active Claude Code session.
- Icons require a Nerd Font — without one they'll render as boxes.
- Usage data is cached in `/tmp/.claude_usage_cache` and refreshed every 60 seconds to avoid excessive API calls.
