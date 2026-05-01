# My Termux & Linux Setup

Yo! This is my personal collection of dotfiles. It makes Termux and Linux look awesome and work even better. If you want a fast, clean terminal with all the cool icons, you're in the right place.

## Check it out
![Main Terminal](Screenshot_2026-04-25-20-50-34-473-edit_com.termux.jpg)
![File Manager](Screenshot_2026-04-25-13-18-07-766-edit_com.termux.jpg)
![Latest Update](Screenshot_2026-05-01-00-20-43-504-edit_com.termux.jpg)

## The Goods
- **Shell**: `zsh` with Oh My Zsh (because plain bash is boring).
- **Theme**: Powerlevel10k (the one with all the sweet icons).
- **File Managers**: `yazi` (blazing fast) and `ranger` (the classic).
- **Multiplexer**: `tmux` with a custom Tokyo Night vibe.
- **Modern Tools**: `eza` for lists, `bat` for reading, and `zoxide` to jump around folders instantly.

## Sweet Features
- **Change your name**: Use the `setname` command to update your CLI handle everywhere—greeting, Fastfetch, and Tmux.
- **Easy navigation**: Hit `y` to open Yazi. When you quit, you'll land right in the folder you were just looking at.
- **Fancy Status Bar**: A custom Tokyo Night Tmux bar with live stats like battery, CPU, RAM, and temp.
- **Live Monitoring**: The status bar stays updated in real-time without slowing anything down.
- **Smart Clear**: Running `cls` or `clear` gives you a fresh greeting and system overview instead of just a blank screen.
- **Works Everywhere**: One installer for both Termux and standard Linux (like Ubuntu/Debian).

## Handy Shortcuts

| Command | What it does |
| :--- | :--- |
| `ls` | `eza` (modern file listing) |
| `ll` | `eza -lah` (long list with hidden files) |
| `la` | `eza -a` (show everything) |
| `lt` | `eza --tree` (neat tree view) |
| `cat` | `bat` (reading with syntax highlighting) |
| `fm` | `ranger` (old school file manager) |
| `y` / `yazi` | `yazi` (super fast manager with auto-cd) |
| `ff` | `fastfetch` (quick system info) |
| `mux` | `tmux` (start or attach to a session) |
| `z <dir>` | `zoxide` (jump to a folder) |
| `matrix` | `cmatrix` (hacker mode) |
| `weather` | See what the weather is like outside |
| `fdown` | Search files with a live preview |
| `setname` | Update your name across the whole setup |
| `zrc` | Reload your config |
| `ezrc` | Edit your config in nano |
| `cls` | Clear screen + fresh greeting |

## How to get it
Just run the installer and let it do the work:
```bash
bash install.sh
```

*Note: You'll need a Nerd Font (like MesloLGS NF) in your terminal settings for all the icons to show up!*

## If things go wrong
If the install hits a snag, try the debug script:
```bash
bash debug-install.sh
```

## What's new
I've been busy making this thing better:
- **Modular Installers**: Cleaner scripts for different systems.
- **No More Lag**: Fixed the Tmux status bar so it doesn't stutter.
- **Identity Sync**: Your `setname` now carries over everywhere.
- **Fast Startup**: Optimized everything so your shell opens instantly.
