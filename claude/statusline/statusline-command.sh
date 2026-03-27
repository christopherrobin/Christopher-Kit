#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Claude Code Status Line                                                    ║
# ║  A two-line status bar for Claude Code CLI                                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# LAYOUT:
#   Line 1: session time | folder name | git ahead/behind | git branch
#   Line 2: context bar | 5h rate limit | lines diff
#
# PREREQUISITES:
#   - Nerd Font (e.g. MesloLGS NF) for icons — without it icons render as boxes
#   - jq (for parsing JSON input)
#   - macOS Keychain access (for rate limit API — uses Claude Code OAuth token)
#
# SETUP:
#   1. Copy this file to ~/.claude/statusline-command.sh
#   2. Add to ~/.claude/settings.json:
#      {
#        "statusLine": {
#          "type": "command",
#          "command": "bash ~/.claude/statusline-command.sh"
#        }
#      }
#
# FEATURES:
#   - Git branch, dirty indicator (tracked files only), ahead/behind remote
#   - Context window progress bar with green/yellow/red gradient
#   - Blinking warning at 87%+ context usage
#   - 5-hour rate limit usage (fetched from Anthropic API, cached 60s)
#   - Session duration, lines added/removed
#   - Worktree and agent name (shown when active)
#   - All icons use Nerd Font codepoints via hex byte sequences

input=$(cat)

# ── Extract fields ──────────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
session_name=$(echo "$input" | jq -r '.session_name // empty')

ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

agent_name=$(echo "$input" | jq -r '.agent.name // empty')
worktree_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
worktree_path=$(echo "$input" | jq -r '.worktree.path // empty')

lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
# ── Session duration (self-tracked) ──────────────────────────────────────────
session_id=$(echo "$input" | jq -r '.session_id // empty')
session_dur=""
if [ -n "$session_id" ]; then
  stamp_file="/tmp/.claude_session_${session_id}"
  if [ ! -f "$stamp_file" ]; then
    date +%s > "$stamp_file"
  fi
  start_epoch=$(cat "$stamp_file")
  now_epoch=$(date +%s)
  elapsed=$((now_epoch - start_epoch))
  hours=$((elapsed / 3600))
  mins=$(( (elapsed % 3600) / 60 ))
  secs=$((elapsed % 60))
  if [ "$hours" -gt 0 ]; then
    session_dur="${hours}h ${mins}m"
  else
    session_dur="${mins}m"
  fi
fi

# ── Project name (current directory name) ────────────────────────────────────
project_name=""
if [ -n "$cwd" ]; then
  project_name=$(basename "$cwd")
fi


# ── Git info ─────────────────────────────────────────────────────────────────
git_branch=""
git_status_icon=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  # Check for uncommitted changes (skip optional locks)
  if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null; then
    git_status_icon="*"
  fi
  # Ahead/behind remote
  git_ahead_behind="↑0↓0"
  local_ref=$(git -C "$cwd" symbolic-ref -q HEAD 2>/dev/null)
  if [ -n "$local_ref" ]; then
    remote_ref=$(git -C "$cwd" for-each-ref --format='%(upstream:short)' "$local_ref" 2>/dev/null)
    if [ -n "$remote_ref" ]; then
      ahead=$(git -C "$cwd" rev-list --count "${remote_ref}..HEAD" 2>/dev/null || echo 0)
      behind=$(git -C "$cwd" rev-list --count "HEAD..${remote_ref}" 2>/dev/null || echo 0)
      git_ahead_behind="↑${ahead}↓${behind}"
    fi
  fi
fi

# ── Context progress bar (20 chars wide, gradient + half-block) ───────────────
bar=""
bar_color=""
if [ -n "$used_pct" ]; then
  used_int=$(echo "$used_pct" | awk '{printf "%d", $1}')
  filled=$(echo "$used_pct" | awk '{printf "%d", ($1 * 15 / 100 + 0.5)}')
  empty=$((15 - filled))
  bar=""
  # Color based on overall usage: green → yellow → red
  # Each filled block gets a color based on its position in the TOTAL bar (0-100%)
  for ((i=0; i<filled; i++)); do
    pos_pct=$((i * 100 / 15))
    if [ "$pos_pct" -lt 50 ]; then
      color_code="71"   # muted green
    elif [ "$pos_pct" -lt 75 ]; then
      color_code="179"  # muted yellow/amber
    else
      color_code="167"  # muted red
    fi
    bar="${bar}\033[38;5;${color_code}m█"
  done
  # Empty portion in dark grey
  for ((i=0; i<empty; i++)); do bar="${bar}\033[38;5;240m░"; done
  bar="${bar}\033[0m"

  # Bar color for chip icon and percentage
  if [ "$used_int" -ge 75 ]; then
    bar_color="$red"
  elif [ "$used_int" -ge 50 ]; then
    bar_color="$yellow"
  else
    bar_color="$green"
  fi
fi

# ── Usage limits (cached, refreshed every 60s) ────────────────────────────────
usage_5h=""
usage_7d=""
usage_cache="/tmp/.claude_usage_cache"
usage_ttl=60
fetch_usage=false

if [ -f "$usage_cache" ]; then
  cache_age=$(( $(date +%s) - $(stat -f %m "$usage_cache") ))
  if [ "$cache_age" -ge "$usage_ttl" ]; then
    fetch_usage=true
  fi
else
  fetch_usage=true
fi

if [ "$fetch_usage" = true ]; then
  creds_json=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  access_token=$(echo "$creds_json" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
  if [ -n "$access_token" ]; then
    usage_json=$(curl -s --max-time 3 \
      -H "Authorization: Bearer ${access_token}" \
      -H "anthropic-beta: oauth-2025-04-20" \
      "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
    if [ -n "$usage_json" ] && echo "$usage_json" | jq -e '.five_hour' >/dev/null 2>&1; then
      echo "$usage_json" > "$usage_cache"
    fi
  fi
fi

if [ -f "$usage_cache" ]; then
  usage_5h=$(jq -r '.five_hour.utilization // empty' "$usage_cache" 2>/dev/null)
  usage_7d=$(jq -r '.seven_day.utilization // empty' "$usage_cache" 2>/dev/null)
  # Round to integer
  [ -n "$usage_5h" ] && usage_5h=$(awk "BEGIN {printf \"%.0f\", $usage_5h}")
  [ -n "$usage_7d" ] && usage_7d=$(awk "BEGIN {printf \"%.0f\", $usage_7d}")
fi

# ── Nerd Font icons ─────────────────────────────────────────────────────────
icon_folder=$(printf '\xef\x81\xbb')
icon_git_branch=$(printf '\xef\x84\xa6')
icon_delta=$(printf '\xef\x81\x80')
icon_chip=$(printf '\xef\x93\xad')
icon_fire=$(printf '\xef\x92\x90')
icon_rocket=$(printf '\xef\x84\xb5')
icon_bolt=$(printf '\xf3\xb0\x93\x85')
icon_lock=$(printf '\xef\x80\xa3')
icon_robot=$(printf '\xee\xb8\x8d')
icon_clock=$(printf '\xef\x94\xa0')

# ── ANSI colors ──────────────────────────────────────────────────────────────
cyan=$'\033[36m'
green=$'\033[32m'
yellow=$'\033[33m'
magenta=$'\033[35m'
purple=$'\033[38;5;135m'
pink=$'\033[38;5;213m'
blue=$'\033[34m'
red=$'\033[31m'
dim=$'\033[2m'
light_grey=$'\033[38;5;250m'
bold=$'\033[1m'
reset=$'\033[0m'

# ── Assemble output ───────────────────────────────────────────────────────────
# Line 1: model | git | vim | agent | session
line1=""

# Session duration
if [ -n "$session_dur" ]; then
  bright_cyan=$'\033[38;5;117m'
  line1="${line1}${bright_cyan}${icon_clock}${reset} ${bright_cyan}${session_dur}${reset}  "
fi

# Project name
if [ -n "$project_name" ]; then
  almost_white=$'\033[38;5;253m'
  line1="${line1}${light_grey}${icon_folder}${reset} ${light_grey}${project_name}${reset} ❯"
fi

# Worktree
if [ -n "$worktree_branch" ]; then
  wt_display="${worktree_branch}"
  [ -n "$worktree_path" ] && wt_display="${wt_display} ${dim}${worktree_path}${reset}"
  line1="${line1} ${magenta}[worktree: ${wt_display}]${reset}"
fi

# Git branch
if [ -n "$git_branch" ]; then
  muted_pink=$'\033[38;5;175m'
  darker_pink=$'\033[38;5;132m'
  mg=$'\033[38;5;71m'
  mr=$'\033[38;5;167m'
  muted_green=$'\033[38;5;71m'
  muted_red=$'\033[38;5;167m'
  diff_part=" ${muted_green}+${lines_added}${reset} ${muted_red}-${lines_removed}${reset}"
  line1="${line1}${diff_part} ❯ ${muted_pink}${icon_git_branch}${reset} ${bold}${muted_pink}${git_branch}${reset}${muted_pink}${git_status_icon}${reset}"
fi

# Agent
if [ -n "$agent_name" ]; then
  line1="${line1}  ${magenta}⚙ ${agent_name}${reset}"
fi


# Line 2: context bar | rate limit | diff | timer
line2=""
if [ -n "$bar" ] && [ -n "$used_pct" ]; then
  bar_rendered=$(printf "${bar}")
  ctx_warning=""
  if [ "$used_int" -ge 87 ]; then
    blink=$'\033[5m'
    ctx_warning=" ${blink}${red}!${reset}"
  fi
  line2="${line2}${light_grey}${icon_chip}${reset} ${bar_rendered} ${bar_color}${used_pct}%${reset}${ctx_warning}"
fi
if [ -n "$usage_5h" ]; then
  # Session limit bar (10 chars wide, gradient like context bar)
  session_bar=""
  session_filled=$(awk "BEGIN {printf \"%d\", ($usage_5h * 10 / 100 + 0.5)}")
  session_empty=$((10 - session_filled))
  for ((i=0; i<session_filled; i++)); do
    pos_pct=$((i * 100 / 10))
    if [ "$pos_pct" -lt 50 ]; then
      sc="140"   # muted purple
    elif [ "$pos_pct" -lt 75 ]; then
      sc="179"   # muted amber
    else
      sc="167"   # muted red
    fi
    session_bar="${session_bar}\033[38;5;${sc}m█"
  done
  for ((i=0; i<session_empty; i++)); do session_bar="${session_bar}\033[38;5;240m░"; done
  session_bar="${session_bar}\033[0m"
  session_bar_rendered=$(printf "${session_bar}")

  if [ "$usage_5h" -ge 80 ]; then
    u5_color="$red"
  elif [ "$usage_5h" -ge 50 ]; then
    u5_color="$yellow"
  else
    u5_color=$'\033[38;5;140m'
  fi

  session_warning=""
  if [ "$usage_5h" -ge 85 ]; then
    blink=$'\033[5m'
    session_warning=" ${blink}${red}!${reset}"
  fi

  line2="${line2}  ${light_grey}${icon_bolt} 5h${reset} ${session_bar_rendered} ${u5_color}${usage_5h}%${reset}${session_warning}"
fi

# Line 3: active subagents
muted_yellow=$'\033[38;5;179m'
subagent_file="/tmp/.claude_subagents_${session_id}"
agents=""
if [ -f "$subagent_file" ] && [ -s "$subagent_file" ]; then
  # Stale guard: if file not modified in 5 min, agents likely finished without cleanup
  file_age=$(( $(date +%s) - $(stat -f %m "$subagent_file") ))
  if [ "$file_age" -ge 300 ]; then
    rm -f "$subagent_file"
  else
    # Read a snapshot — use lock to avoid garbled reads during concurrent writes
    lockdir="${subagent_file}.lock"
    mkdir "$lockdir" 2>/dev/null && locked=true || locked=false
    agents=$(cat "$subagent_file" 2>/dev/null | sort | uniq -c | awk '{if ($1 > 1) printf "%s ×%s, ", $2, $1; else printf "%s, ", $2}' | sed 's/, $//')
    [ "$locked" = true ] && rmdir "$lockdir" 2>/dev/null
  fi
fi
if [ -n "$agents" ]; then
  line3="${muted_yellow}${icon_robot}${reset}  ${muted_yellow}${agents}${reset}"
else
  line3="${muted_yellow}${icon_robot}${reset}  ${dim}No Agents Working${reset}"
fi

if [ -n "$line3" ]; then
  printf "%s\n%s\n%s" "$line1" "$line2" "$line3"
else
  printf "%s\n%s" "$line1" "$line2"
fi
