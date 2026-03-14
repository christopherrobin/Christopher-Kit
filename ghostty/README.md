# Ghostty

Terminal emulator config using the [Cyberdream](https://github.com/scottmckendry/cyberdream.nvim) color palette with a semi-transparent dark background.

## Prerequisites

- [Ghostty](https://ghostty.org) installed
- [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts) font installed

## Setup

Copy or symlink the config file to Ghostty's config directory:

```bash
# macOS / Linux
cp config ~/.config/ghostty/config

# Or symlink to keep it linked to the repo
ln -sf "$(pwd)/config" ~/.config/ghostty/config
```

Restart Ghostty to apply changes.

## What's Configured

| Setting | Value |
|---------|-------|
| Font | MesloLGS NF, size 14 |
| Background | Dark (#0f1115), 92% opacity with blur |
| Cursor | Hot pink (#ff69b4) |
| Color palette | Cyberdream |
