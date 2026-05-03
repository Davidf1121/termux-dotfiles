# Termux Dotfiles

A collection of configuration files to set up a modern and functional terminal environment on Termux (Android). This setup focuses on providing a clean interface with useful productivity tools.

## Preview
![Main Terminal](Screenshot_2026-04-25-20-50-34-473-edit_com.termux.jpg)
![File Manager](Screenshot_2026-04-25-13-18-07-766-edit_com.termux.jpg)
![Latest Update](Screenshot_2026-05-01-00-20-43-504-edit_com.termux.jpg)

## Core Components
- **Shell**: `zsh` managed with Oh My Zsh.
- **Theme**: Powerlevel10k for a detailed and responsive prompt.
- **Editor**: `neovim` with a modular Lua configuration (LSP, Autocomplete, Treesitter).
- **File Managers**: `yazi` and `ranger`.
- **Multiplexer**: `tmux` with a custom Tokyo Night color scheme.
- **Tools**: Includes `eza` for directory listings, `bat` for file viewing, and `zoxide` for navigation.

## Key Features
- **Minecraft-style Completion**: Real-time ghost-text suggestions and fuzzy-searchable tab completion.
    - Press **Tab** to open the interactive menu.
    - Press **Right Arrow** or **End** to accept ghost-text suggestions.
- **Modern History**: Interactive shell history with `atuin` (press `Ctrl-r`).
- **Floating Terminals**: Quick-access floating windows in Tmux (press `prefix + g`).
- **Fancy Greeting**: A custom Neovim startup dashboard with `alpha-nvim`.

... (existing content) ...

## Development Workflow
This repository is designed for safe and flexible development:
- **`install.sh`**: Default installation method. Copies files to your system (safe from accidental edits).
- **`symlink.sh`**: Development method. Selectively link files to the repo for real-time updates.
- **`sync.sh`**: Manual backup. Copy your local configuration changes back into the repository.
- **Dynamic Identity**: Use the `setname` command to update your user handle across the shell, Fastfetch, and Tmux status bar.
- **Integrated Navigation**: `y` command opens Yazi and automatically changes the shell directory to the last visited path upon exit.
- **System Metrics**: The Tmux status bar displays real-time information including battery status, CPU usage, RAM, and temperature.
- **Dynamic Dashboard**: A dedicated second status row appears automatically when playing music, featuring a pip-style progress bar, live track timer, and Tokyo Night themed segments.
- **Optimized Performance**: Status bar metrics are cached in the background to ensure terminal responsiveness.
- **Custom Greeting**: The `cls` (or `clear`) command provides a clean screen along with a personalized greeting and system overview.
- **Termux-Optimized**: Installer and packages are specifically configured for Termux (ARM/Android) environment.

## Commands and Aliases

| Command | Description |
| :--- | :--- |
| `ls` | `eza` (modern replacement for ls) |
| `ll` | `eza -lah` (detailed list with hidden files) |
| `la` | `eza -a` (list all files) |
| `lt` | `eza --tree` (hierarchical tree view) |
| `cat` | `bat` (file viewer with syntax highlighting) |
| `fm` | `ranger` (file manager) |
| `y` / `yazi` | `yazi` (file manager with auto-cd) |
| `ff` | `fastfetch` (system information display) |
| `mux` | `tmux` (terminal multiplexer) |
| `z <dir>` | `zoxide` (directory jumping) |
| `matrix` | `cmatrix` (terminal screensaver) |
| `weather` | Display current weather information |
| `fdown` | Search files with a live preview window |
| `setname` | Update your display name across the environment |
| `zrc` | Reload Zsh configuration |
| `ezrc` | Edit Zsh configuration |
| `cls` | Clear terminal and show greeting |
| `m <url\|file\|query>` | Custom Python music player (auto-search) |
| `m search <query>` | Interactive search (fzf if available) |
| `m history` | Show playback history |
| `m replay [index]` | Replay from history |
| `m seek <sec>` | Seek forward/backward |
| `m forward`/`backward` | Quick seek ±10s |
| `m watch` | Watch with progress bar |
| `p` | Shortcut for music player |
| `mpause`/`mstop`/`minfo` | Music controls |

## Music Player

Custom standalone music player (`bin/music.py`) - just mpv, no pip deps:

- Backend: `mpv` with IPC socket at `~/.cache/mpv_socket`
- Audio: PulseAudio
- Cache: `~/.cache/music_current` for tmux display
- History: `~/.cache/music_history` for playback history
- Sources: Local files, folders, URLs (YouTube, direct)

Install:

```bash
pkg install mpv pulseaudio ffmpeg python
```

Usage:

```bash
# Direct play
m https://youtu.be/...   # Play YouTube
m /sdcard/Music          # Play folder
m song.mp3               # Play file

# Smart search (auto-plays first result)
m never gonna give you up  # Auto-search and play

# Interactive search (with fzf if available)
m search <query>         # Search YouTube and select

# History & replay
m history                # Show playback history
m replay                 # Replay last track
m replay 3               # Replay 3rd track from history

# Playback control
m pause                  # Toggle pause
m stop                   # Stop
m info                   # Show current track
m watch                  # Watch with progress bar (Tokyo Night theme)

# Seek controls
m seek 30               # Seek forward 30 seconds
m seek -10              # Seek backward 10 seconds
m forward                # Seek forward 10s (default)
m forward 30            # Seek forward 30s
m backward               # Seek backward 10s (default)
m backward 20           # Seek backward 20s
```

Aliases: `p` (play), `mpause`, `mstop`, `minfo`

## Installation
To install the dotfiles, run the following command:
```bash
bash install.sh
```

*Note: A Nerd Font (such as MesloLGS NF) is required to correctly display icons and symbols.*

## Troubleshooting
If you encounter issues during installation, you can use the debug script:
```bash
bash debug-install.sh
```

## Recent Updates
- **Termux-Only Installer**: Optimized for Termux deployment (Linux temporarily removed).
- **Music Player QoL**: Added auto-search, history, replay, seek controls, and fzf integration.
- **Watch Display**: Tokyo Night themed real-time music progress bar with colored UI.
- **Performance Fixes**: Asynchronous caching for system metrics in Tmux.
- **Unified Identity**: Improved synchronization for the `setname` system.
- **Startup Speed**: Optimized Zsh initialization using interactive shell guards.
