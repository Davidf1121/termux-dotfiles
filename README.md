# Termux Dotfiles: Davidf's Personal Setup

A modern, fast, and good-looking Termux environment. This setup is built for productivity and aesthetics, focusing on a clean CLI experience.

## What's inside?
- **Shell**: `zsh` with Oh My Zsh.
- **Theme**: Powerlevel10k (the one with all the cool icons).
- **File Managers**: `yazi` (super fast) and `ranger` (classic).
- **Multiplexer**: `tmux` with a custom Tokyo Night theme.
- **Modern Tools**: `eza` for listing files, `bat` for reading them, and `zoxide` to jump around directories instantly.

## Cool Features
- **Dynamic Identity**: Change your CLI name anytime with the `setname` command. It updates your greeting, Fastfetch, and Tmux status bar all at once.
- **Fast Navigation**: Use `y` to open the Yazi file manager. When you quit, you'll automatically `cd` into the last folder you were looking at.
- **Fancy Status**: A custom Tokyo Night Tmux bar with Powerline symbols and floating pane titles.
- **Smart Clear**: The `cls` (or `clear`) command doesn't just empty the screen—it gives you a fresh greeting and system overview.

## Quick Shortcuts (Aliases)

| Command | What it does |
| :--- | :--- |
| `ls` / `ll` | Modern file listing with icons (`eza`) |
| `cat` | Syntax highlighted file preview (`bat`) |
| `ff` | Show system info (`fastfetch`) |
| `mux` | Start/Attach Tmux |
| `z <dir>` | Jump to any folder you've visited before |
| `y` | Fast file manager with auto-cd |
| `setname` | Update your display name everywhere |
| `zrc` | Reload your shell config |

## How to Install
Just run the main installer and let it do its thing:
```bash
bash install.sh
```

*Note: Make sure to use a Nerd Font (like MesloLGS NF) in your terminal settings so all the icons show up correctly!*

## Troubleshooting
If something breaks during installation, you can run the debug script to see exactly what's going wrong:
```bash
bash debug-install.sh
```
