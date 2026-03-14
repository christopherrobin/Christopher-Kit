# Zsh Configuration

Custom `.zshrc` with Powerlevel10k prompt, utility functions, and shell helpers.

## Prerequisites

- [Oh My Zsh](https://ohmyz.sh/) installed
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme installed
- [Nerd Font](https://github.com/romkatv/powerlevel10k#fonts) (e.g., MesloLGS NF) for prompt symbols and shell function emoji

## Setup

Copy the config files to your home directory:

```bash
cp .zshrc ~/.zshrc
cp .p10k.zsh ~/.p10k.zsh
```

Restart your shell or run `source ~/.zshrc` to apply.

## What's Included

### Shell Framework
- Oh My Zsh with `git` and `wd` plugins
- Powerlevel10k with Pure style, Snazzy color palette, single-line minimalist prompt

### Color & Emoji Variables
ANSI color codes (`$BOLD`, `$CYAN`, `$MAGENTA`, `$ENDCOLOR`) and emoji unicode variables (`$BEER`, `$NERD`) used by the utility functions.

### Utility Functions

| Function | Description |
|----------|-------------|
| `fullbar "char" "$COLOR"` | Print a full-width terminal bar with repeating characters |
| `fullbarEmoji $EMOJI` | Print a full-width bar with repeating emoji |
| `custom_prompt "text"` | Styled prompt output with beer and nerd emoji |
| `commands` | Show available custom functions |
| `config` | Open `.zshrc` in VS Code |
| `claudeInit` | Initialize Claude AI team configurator for current project |
| `myinfo` | Display user, time, date, hostname, node version, git branch |
| `root` | Navigate to home directory |
| `update` | Run `git fetch && git pull` |

### Auto-run
`myinfo` runs automatically on shell startup to show environment info.

## Customization

- Edit the emoji variables to use your preferred icons
- Modify `custom_prompt()` to change the prompt style
- Add your own navigation functions (e.g., shortcuts to project directories)
- Update the `commands()` function when you add new functions to keep the help text current
