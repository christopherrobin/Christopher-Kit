# Christopher-Kit

A personal dev toolkit repo containing portable configs, scripts, and tools for setting up a development environment on any machine.

## Directory Structure

Configs and tools are organized by the application or tool they belong to:

```
Christopher-Kit/
├── ghostty/              # Ghostty terminal config
│   ├── config
│   └── README.md
├── claude/
│   └── statusline/       # Claude Code status line script
│       ├── statusline-command.sh
│       └── README.md
```

Each top-level directory corresponds to a single tool or application. Subdirectories group related features (e.g., `claude/statusline/`). Each directory includes a README with prerequisites and setup instructions.

## Guidelines

### Security — Review Everything Before Committing

This repo may be released publicly. Before adding any file:

- Strip API keys, tokens, and secrets
- Remove or generalize personal paths (e.g., `/Users/yourname/` → `~/` or `$HOME/`)
- Remove PII (emails, usernames tied to accounts)
- Replace sensitive values with placeholder comments explaining what goes there
- Flag anything questionable to the user before committing

### Keep Configs Useful to Others

- Add comments explaining non-obvious settings so someone new can understand the "why"
- Prefer generic, portable values over machine-specific hardcoded ones
- Document any dependencies or prerequisites in the directory's own README if needed

### Keep It Simple

- These are config files and shell scripts, not applications — don't over-engineer
- No abstraction layers or templating unless there's a clear need
- Flat, obvious file organization over clever nesting

## Adding New Content

When bringing a new config or tool into the repo:

1. **Locate** the source file on the current machine
2. **Review** it for secrets, PII, and hardcoded personal paths
3. **Sanitize** — replace sensitive values with placeholders or comments
4. **Place** it in the correct directory (create a new top-level directory if it's a new tool)
5. **Comment** any non-obvious settings
6. **Update** the README's "What's Included" section and directory structure
