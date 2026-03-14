# Christopher-Kit

A portable dev toolkit with Claude Code agents, shell configs, and terminal setup.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-agents%20%26%20skills-CC785C?style=for-the-badge)](claude/agents/)
[![Zsh](https://img.shields.io/badge/zsh-Powerlevel10k-8B5CF6?style=for-the-badge)](zsh/)
[![Ghostty](https://img.shields.io/badge/terminal-Ghostty-0A209F?style=for-the-badge)](ghostty/)
[![MIT License](https://img.shields.io/badge/license-MIT-333333?style=for-the-badge)](LICENSE)

Every time you set up a new machine, you spend hours recreating your dev environment - shell config, terminal theme, editor preferences, AI tooling. This repo is the fix. Clone it, symlink what you need, and get back to building.

## What's Included

- **[Zsh](zsh/)** - Custom `.zshrc` with Powerlevel10k, utility functions, and shell helpers
- **[Ghostty](ghostty/)** - Terminal config with Cyberdream color palette and semi-transparent background
- **[Claude Code](claude/)**
  - **[Status Line](claude/statusline/)** - Two-line status bar showing session time, git status, context usage, and rate limits
  - **[Skills](claude/skills/)** - Custom slash commands (`/msg`, `/review-me`, `/grind`, `/audit`, `/scaffold`, `/deps`)
  - **[Agents](claude/agents/)** - 36 specialized AI agents (React, Next.js, TypeScript, Python, Prisma, AWS, and more)
  - **[Settings](claude/settings/)** - Example settings.json with MCP server configs (Context7, MUI, Tailwind, GitHub, AWS)

### How It Works Together

This isn't just a collection of configs - it's an integrated workflow where agents and skills work as a team.

The **[tech-lead-orchestrator](claude/agents/orchestrators/tech-lead-orchestrator.md)** is the brain. Give it a complex task and it analyzes your codebase, breaks the work into subtasks, and delegates each one to the right specialist - React expert for components, TypeScript expert for types, Prisma expert for database queries. It coordinates the entire build, then runs code review when everything's done.

The skills are your entry points into this system:

- `/scaffold` - Plan and build a new feature end-to-end through the orchestrator
- `/grind` - Verify your approach with the tech lead, then implement improvements
- `/review-me` - Code review with security, DRY, and performance checks
- `/audit` - Full codebase health check (architecture + quality)
- `/deps` - Check for outdated or vulnerable packages

The **project-analyst** auto-detects your tech stack and the **team-configurator** wires up the right agents for your project.

## Quick Start

```bash
git clone https://github.com/christopherrobin/Christopher-Kit.git
cd Christopher-Kit
```

Each directory has its own README with detailed setup instructions. Pick what you need:

### Shell Config
```bash
cp zsh/.zshrc ~/.zshrc
cp zsh/.p10k.zsh ~/.p10k.zsh
```

### Ghostty Terminal
```bash
cp ghostty/config ~/.config/ghostty/config
```

### Claude Code
```bash
# Agents
ln -sf "$(pwd)/claude/agents" ~/.claude/agents

# Skills
cp -r claude/skills/* ~/.claude/skills/

# Status line + settings
cp claude/statusline/statusline-command.sh ~/.claude/statusline-command.sh
cp claude/settings/settings.example.json ~/.claude/settings.json
```

### Preview

<table>
<tr>
<td align="center"><img src="zsh/terminal-preview.png" width="380"><br><em>Shell startup with Powerlevel10k</em></td>
<td align="center"><img src="claude/statusline/statusline-preview.png" width="420"><br><em>Claude Code status line</em></td>
</tr>
</table>

## Customization

These configs reflect one person's preferences. Fork the repo and adapt anything to suit your own workflow - swap keybindings, change themes, adjust paths.

The agents and skills included here are a solid starting point, but the best ones you'll ever use are the ones you write yourself. Use the `skill-expert` and `agent-expert` agents to create your own, tailored to how you actually work.

## Contributing

PRs welcome. If you've built a useful skill, agent, or config that fits the toolkit, open a pull request. Keep it generic - no project-specific content.

## License

[MIT](LICENSE)
