# Claude Code Settings

Example `settings.json` for Claude Code with MCP server integrations and a custom status line.

## Setup

Copy the example and add your own tokens:

```bash
cp settings.example.json ~/.claude/settings.json
```

Then edit `~/.claude/settings.json` to fill in your credentials.

## What's Configured

### Status Line
Custom two-line status bar showing session info, git status, context usage, and rate limits. Requires the [statusline script](../statusline/) to be installed.

### MCP Servers

| Server | What It Does | Requires |
|--------|-------------|----------|
| [Context7](https://github.com/upstash/context7) | Fetch up-to-date documentation for any library | npx |
| [MUI MCP](https://github.com/nicholasgriffintn/mui-mcp) | Material-UI component docs and examples | npx |
| [Tailwind MCP](https://github.com/nicholasgriffintn/tailwindcss-mcp-server) | Tailwind CSS class reference and docs | npx |
| [GitHub MCP](https://github.com/modelcontextprotocol/servers) | GitHub API access (issues, PRs, repos) | npx + GitHub PAT |
| [AWS MCP](https://github.com/aws/aws-mcp) | AWS service integration | uvx + AWS credentials |

## Credentials

The GitHub MCP server requires a personal access token. Generate one at [github.com/settings/tokens](https://github.com/settings/tokens) and replace `<your-github-token>` in the settings file.

The AWS MCP server uses your local AWS credentials (`~/.aws/credentials` or environment variables).
