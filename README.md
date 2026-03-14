# Christopher-Kit

A portable dev toolkit for setting up a familiar development environment on any machine. Clone the repo, copy or symlink the configs you need, and get to work.

## What's Included

- **Ghostty** — Terminal config with Cyberdream color palette and semi-transparent background
- **Claude Status Line** — Two-line status bar showing session info, git status, context usage, and rate limits

## Getting Started

```bash
git clone https://github.com/christopherrobin/Christopher-Kit.git
cd Christopher-Kit
```

Copy or symlink the configs you need to their expected locations. Setup instructions for each config are documented in their respective directories.

## Directory Structure

```
Christopher-Kit/
├── ghostty/              # Ghostty terminal config
│   ├── config
│   └── README.md
├── claude/
│   └── statusline/       # Claude Code status line script
│       ├── statusline-command.sh
│       └── README.md
├── CLAUDE.md
├── README.md
└── LICENSE
```

## Customization

These configs reflect one person's preferences. Fork the repo and adapt anything to suit your own workflow — swap keybindings, change themes, adjust paths.

## License

[MIT](LICENSE)
