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
│   ├── statusline/       # Claude Code status line script
│   │   ├── statusline-command.sh
│   │   └── README.md
│   ├── skills/           # Custom slash commands
│   │   ├── msg/          # /msg — generate commit messages
│   │   ├── review-me/    # /review-me — code review
│   │   └── README.md
│   └── agents/           # Specialized AI agents
│       ├── core/         # Code review, testing, docs, performance
│       ├── orchestrators/ # Project analysis, team config, tech lead
│       ├── specialized/  # Framework experts (React, Python, Prisma, etc.)
│       ├── universal/    # Cross-framework specialists
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

### Coding Philosophy

All code produced by agents in this toolkit should follow these principles:

- **DRY** — Don't repeat yourself. Extract reusable utilities instead of copy-pasting. But don't abstract prematurely — wait until a pattern is clear before extracting.
- **Functional over imperative** — Prefer pure functions over side effects. Use `map`/`filter`/`reduce` over imperative loops. Compose small functions over writing monolithic ones.
- **Immutable by default** — Use `const`, `readonly`, and immutable data structures. Mutate only when there's a clear performance reason.
- **Composable and reusable** — Design functions and components for reuse from the start. Small, focused units that compose together.
- **Scalable patterns** — Write code that works for 10 items and 10,000 items. Consider data growth, not just current state.

## Adding New Content

When bringing a new config or tool into the repo:

1. **Locate** the source file on the current machine
2. **Review** it for secrets, PII, and hardcoded personal paths
3. **Sanitize** — replace sensitive values with placeholders or comments
4. **Place** it in the correct directory (create a new top-level directory if it's a new tool)
5. **Comment** any non-obvious settings
6. **Update** the README's "What's Included" section and directory structure
