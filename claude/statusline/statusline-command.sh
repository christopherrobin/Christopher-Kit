#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Claude Code Status Line                                                    ║
# ║  A four-line status bar for Claude Code CLI                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# LAYOUT:
#   Line 1: session time | project name | lines diff | git branch
#   Line 2: model | active subagents
#   Line 3: context window bar
#   Line 4: 5h rate limit bar
#
# PREREQUISITES:
#   - macOS (uses BSD stat and the security/Keychain CLI throughout)
#   - Nerd Font (e.g. MesloLGS NF) for icons - without it icons render as boxes
#   - jq (for parsing JSON input)
#   - macOS Keychain access (for rate limit API - uses Claude Code OAuth token)
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
model_name=$(echo "$input" | jq -r '.model.display_name // empty')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

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
    # Sweep stamp files left behind by sessions older than a day
    find /tmp -maxdepth 1 -name '.claude_session_*' -mtime +1 -delete 2>/dev/null
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
  # Check for uncommitted changes, staged or unstaged (skip optional locks)
  if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || \
     ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
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

# ── Context progress bar (33 chars wide, gradient + half-block) ───────────────
bar=""
bar_color=""
if [ -n "$used_pct" ]; then
  used_int=$(echo "$used_pct" | awk '{printf "%d", $1}')
  filled=$(echo "$used_pct" | awk '{printf "%d", ($1 * 33 / 100 + 0.5)}')
  empty=$((33 - filled))
  bar=""
  # Color based on overall usage: green → yellow → red
  # Each filled block gets a color based on its position in the TOTAL bar (0-100%)
  for ((i=0; i<filled; i++)); do
    pos_pct=$((i * 100 / 33))
    if [ "$pos_pct" -lt 50 ]; then
      color_code="71"   # muted green
    elif [ "$pos_pct" -lt 75 ]; then
      color_code="222"  # muted yellow/amber
    else
      color_code="167"  # muted red
    fi
    bar="${bar}\033[38;5;${color_code}m▆"
  done
  # Empty portion in dark grey
  for ((i=0; i<empty; i++)); do bar="${bar}\033[38;5;235m▆"; done
  bar="${bar}\033[0m"

  # Bar color = color of the rightmost filled block (matches the gradient tip)
  if [ "$filled" -le 0 ]; then
    bar_color=$'\033[38;5;71m'    # muted green
  else
    tip_pos=$(( (filled - 1) * 100 / 33 ))
    if [ "$tip_pos" -lt 50 ]; then
      bar_color=$'\033[38;5;71m'    # muted green
    elif [ "$tip_pos" -lt 75 ]; then
      bar_color=$'\033[38;5;222m'   # muted amber
    else
      bar_color=$'\033[38;5;167m'   # muted red
    fi
  fi
fi

# ── Usage limits (cached, refreshed every 60s) ────────────────────────────────
usage_5h=""
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
  # Round to integer
  [ -n "$usage_5h" ] && usage_5h=$(awk "BEGIN {printf \"%.0f\", $usage_5h}")
fi

# ── Nerd Font icons ─────────────────────────────────────────────────────────
icon_folder=$(printf '\xef\x81\xbb')
icon_git_branch=$(printf '\xef\x84\xa6')
icon_bolt=$(printf '\xf3\xb0\x93\x85')
icon_robot=$(printf '\xee\xb8\x8d')
icon_clock=$(printf '\xef\x94\xa0')
icon_model=$(printf '\xf3\xb0\x99\xb4')
icon_chevron=$(printf '\xef\x91\xa0')
icon_local=$(printf '\xef\x91\x90')

# ── ANSI colors ──────────────────────────────────────────────────────────────
magenta=$'\033[35m'
red=$'\033[31m'
dim=$'\033[2m'
light_grey=$'\033[38;5;250m'
bright_cyan=$'\033[38;5;117m'
bold=$'\033[1m'
reset=$'\033[0m'

# ── Assemble output ───────────────────────────────────────────────────────────
# Line 1: session time | project name | lines diff | git branch | agent
line1=""

# Session duration
if [ -n "$session_dur" ]; then
  line1="${line1}${light_grey}${icon_clock}${reset} ${light_grey}${session_dur}${reset} ${light_grey}${icon_chevron}${reset}  "
fi

# Project name
if [ -n "$project_name" ]; then
  line1="${line1}${light_grey}${icon_folder}${reset} ${light_grey}${project_name}${reset} ${light_grey}${icon_chevron}${reset}"
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
  muted_green=$'\033[38;5;71m'
  muted_red=$'\033[38;5;167m'
  diff_part="  ${muted_green}+${lines_added}${reset} ${muted_red}-${lines_removed}${reset}"
  line1="${line1}${diff_part} ${light_grey}${icon_chevron}${reset}  ${muted_pink}${icon_git_branch}${reset} ${bold}${muted_pink}${git_branch}${reset}${muted_pink}${git_status_icon}${reset}"
fi

# Agent
if [ -n "$agent_name" ]; then
  line1="${line1}  ${magenta}⚙ ${agent_name}${reset}"
fi


# Line 3: context bar
line3=""
line4=""
if [ -n "$bar" ] && [ -n "$used_pct" ]; then
  bar_rendered=$(printf "${bar}")
  ctx_warning=""
  if [ "$used_int" -ge 87 ]; then
    blink=$'\033[5m'
    ctx_warning=" ${blink}${red}!${reset}"
  fi
  line3="${bar_color}${icon_local}${reset}  ${bar_rendered} ${bar_color}${used_pct}%${reset}${ctx_warning}"
fi
if [ -n "$usage_5h" ]; then
  # Session limit bar (33 chars wide, gradient like context bar)
  session_bar=""
  session_filled=$(awk "BEGIN {printf \"%d\", ($usage_5h * 33 / 100 + 0.5)}")
  session_empty=$((33 - session_filled))
  for ((i=0; i<session_filled; i++)); do
    pos_pct=$((i * 100 / 33))
    if [ "$pos_pct" -lt 50 ]; then
      sc="71"    # muted green (matches +lines)
    elif [ "$pos_pct" -lt 75 ]; then
      sc="222"   # muted amber
    else
      sc="167"   # muted red
    fi
    session_bar="${session_bar}\033[38;5;${sc}m▆"
  done
  for ((i=0; i<session_empty; i++)); do session_bar="${session_bar}\033[38;5;235m▆"; done
  session_bar="${session_bar}\033[0m"
  session_bar_rendered=$(printf "${session_bar}")

  # Color = rightmost filled block of the session bar (matches the gradient tip)
  if [ "$session_filled" -le 0 ]; then
    u5_color=$'\033[38;5;71m'    # muted green
  else
    tip_pos=$(( (session_filled - 1) * 100 / 33 ))
    if [ "$tip_pos" -lt 50 ]; then
      u5_color=$'\033[38;5;71m'    # muted green
    elif [ "$tip_pos" -lt 75 ]; then
      u5_color=$'\033[38;5;222m'   # muted amber
    else
      u5_color=$'\033[38;5;167m'   # muted red
    fi
  fi

  session_warning=""
  if [ "$usage_5h" -ge 85 ]; then
    blink=$'\033[5m'
    session_warning=" ${blink}${red}!${reset}"
  fi

  line4="${u5_color}${icon_bolt}${reset}  ${session_bar_rendered} ${u5_color}${usage_5h}%${reset}${session_warning}"
fi

# Active subagents (rendered on line 2)
subagent_file="/tmp/.claude_subagents_${session_id}"
agents=""
if [ -f "$subagent_file" ] && [ -s "$subagent_file" ]; then
  # Stale guard: if file not modified in 5 min, agents likely finished without cleanup
  file_age=$(( $(date +%s) - $(stat -f %m "$subagent_file") ))
  if [ "$file_age" -ge 300 ]; then
    rm -f "$subagent_file"
  else
    # Plain read is safe: the hook only appends or atomically renames the file
    agents=$(cat "$subagent_file" 2>/dev/null | sort | uniq -c | awk '{if ($1 > 1) printf "%s ×%s, ", $2, $1; else printf "%s, ", $2}' | sed 's/, $//')
  fi
fi
# Agent portion (robot + active subagents, or N/A when idle)
if [ -n "$agents" ]; then
  agent_part="${bright_cyan}${icon_robot}${reset}  ${bright_cyan}${agents}${reset}"
else
  agent_part="${bright_cyan}${icon_robot}${reset}  ${bright_cyan}N/A${reset}"
fi

# Model portion (shown first)
model_part=""
if [ -n "$model_name" ]; then
  light_purple=$'\033[38;5;141m'
  model_part="${light_purple}${icon_model} ${model_name}${reset}"
fi

# Line 2: model first, then agents
if [ -n "$model_part" ]; then
  line2="${model_part}  ${agent_part}"
else
  line2="${agent_part}"
fi

out="${line1}"$'\n'"${line2}"
[ -n "$line3" ] && out="${out}"$'\n'"${line3}"
[ -n "$line4" ] && out="${out}"$'\n'"${line4}"
printf "%s" "$out"
