# Christopher-Kit

A personal dev toolkit repo containing portable configs, scripts, and tools for setting up a development environment on any machine.

## Directory Structure

Configs and tools are organized by the application or tool they belong to:

```
Christopher-Kit/
├── ghostty/              # Ghostty terminal config
├── zsh/                  # Zsh config with Powerlevel10k and shell helpers
├── claude/
│   ├── statusline/       # Claude Code status line script
│   ├── hooks/            # Hook scripts (subagent tracking for the status line)
│   ├── settings/         # Example settings.json
│   ├── skills/           # Custom slash commands (each listed in claude/skills/README.md)
│   └── agents/           # Specialized AI agents
│       ├── core/         # Code review, testing, docs, performance
│       ├── orchestrators/ # Project analysis, team config, tech lead
│       ├── specialized/  # Framework experts (React, Python, Prisma, etc.)
│       └── universal/    # Cross-framework specialists
```

Each top-level directory corresponds to a single tool or application. Subdirectories group related features (e.g., `claude/statusline/`). Each directory includes a README with prerequisites and setup instructions.

## Guidelines

### Security - Review Everything Before Committing

This repo may be released publicly. Before adding any file:

- Strip API keys, tokens, and secrets
- Remove or generalize personal paths (e.g., `/Users/yourname/` → `~/` or `$HOME/`)
- Remove PII (emails, usernames tied to accounts)
- Replace sensitive values with placeholder comments explaining what goes there
- Example configs must use obvious placeholders (e.g. `<your-token>`) or token-free flows like OAuth, never anything shaped like a real credential
- Flag anything questionable to the user before committing

### Keep Configs Useful to Others

- Add comments explaining non-obvious settings so someone new can understand the "why"
- Prefer generic, portable values over machine-specific hardcoded ones
- Document any dependencies or prerequisites in the directory's own README if needed

### Keep It Simple

- These are config files and shell scripts, not applications - don't over-engineer
- No abstraction layers or templating unless there's a clear need
- Flat, obvious file organization over clever nesting

### Shell Script Constraints

Scripts target macOS's stock `/bin/bash` 3.2 with BSD userland:

- No bash 4+ features: no `declare -A`, `mapfile`, or `${var^^}`
- BSD tools, not GNU: `stat -f %m` (not `stat -c`), and there is no `timeout` command
- Bound any wait/retry loop with a counter rather than an external timeout
- Sanity-check with `/bin/bash -n` (not just your PATH's bash, which may be newer)

## Adding New Content

When bringing a new config or tool into the repo:

1. **Locate** the source file on the current machine
2. **Review** it for secrets, PII, and hardcoded personal paths
3. **Sanitize** - replace sensitive values with placeholders or comments
4. **Place** it in the correct directory (create a new top-level directory if it's a new tool)
5. **Comment** any non-obvious settings
6. **Update** the root README's "What's Included" section, the directory's own README, and this file's directory structure
