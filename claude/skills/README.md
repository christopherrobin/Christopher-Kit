# Claude Skills

Custom slash commands for Claude Code. Each skill is a markdown file with frontmatter that defines when and how Claude should use it.

## Included Skills

| Skill | Command | Description |
|-------|---------|-------------|
| [msg](msg/) | `/msg` | Generate a Conventional Commits message from your current diff |
| [review-me](review-me/) | `/review-me` | Compare current branch to base and run a code review |
| [grind](grind/) | `/grind` | Verify changes with tech-lead-orchestrator, then implement improvements |
| [audit](audit/) | `/audit` | Full codebase health check — architecture, security, quality |
| [scaffold](scaffold/) | `/scaffold` | Plan and build a new feature with tech-lead + specialists |
| [deps](deps/) | `/deps` | Check for outdated, vulnerable, or unused dependencies |

## Setup

Copy the skill directories into your Claude config:

```bash
cp -r msg ~/.claude/skills/msg
cp -r review-me ~/.claude/skills/review-me
cp -r grind ~/.claude/skills/grind
cp -r audit ~/.claude/skills/audit
cp -r scaffold ~/.claude/skills/scaffold
cp -r deps ~/.claude/skills/deps
```

Skills are automatically detected by Claude Code once placed in `~/.claude/skills/`.

## Creating Your Own

A skill is a directory containing a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: What the skill does
allowed-tools: Bash(git:*), Read, Glob
---
```

The body is a markdown prompt that tells Claude how to execute the skill.
