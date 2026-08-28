# Claude Code Settings

Example `settings.json` for Claude Code with a custom status line and subagent-tracking hooks, plus install commands for the MCP servers I use.

## Setup

If you already have a `~/.claude/settings.json`, back it up and merge by hand instead of copying (settings.json also holds your permissions, model choice, and plugins). On a fresh machine:

```bash
cp settings.example.json ~/.claude/settings.json
```

## What's Configured

### Status Line
Custom four-line status bar showing session info, git status, active model and agents, context usage, and rate limits. Requires the [statusline script](../statusline/) to be installed.

### Hooks
`SubagentStart` / `SubagentStop` hooks that track running subagents for the status line's agent display. Requires the [hook script](../hooks/) to be installed at `~/.claude/hooks/track-subagents.sh`.

## MCP Servers

Claude Code registers MCP servers through the `claude mcp add` CLI. User-scope servers live in `~/.claude.json` (managed by the CLI - no need to touch it by hand); project-scope servers live in that project's `.mcp.json`.

Install the ones you want:

```bash
# Context7 - up-to-date docs for any library
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest

# MUI - Material-UI component docs and examples
claude mcp add --scope user mui-mcp -- npx -y @mui/mcp@latest

# Tailwind CSS - class reference and docs
claude mcp add --scope user tailwindcss -- npx -y tailwindcss-mcp-server

# GitHub - official remote server (OAuth on first use, no token needed)
claude mcp add --scope user --transport http github https://api.githubcopilot.com/mcp/

# AWS - AWS service integration (uses your local AWS credentials)
claude mcp add --scope user aws-mcp -- uvx mcp-proxy-for-aws@latest https://aws-mcp.us-east-1.api.aws/mcp
```

Verify with `claude mcp list`.

| Server | What It Does | Requires |
|--------|-------------|----------|
| [Context7](https://github.com/upstash/context7) | Fetch up-to-date documentation for any library | npx |
| [MUI MCP](https://mui.com/material-ui/getting-started/mcp/) | Material-UI component docs and examples | npx |
| [Tailwind MCP](https://www.npmjs.com/package/tailwindcss-mcp-server) | Tailwind CSS class reference and docs | npx |
| [GitHub MCP](https://github.com/github/github-mcp-server) | GitHub API access (issues, PRs, repos) | OAuth sign-in on first use |
| [AWS MCP](https://github.com/aws/mcp-proxy-for-aws) | AWS service integration | uvx + AWS credentials |
