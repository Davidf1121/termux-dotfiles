# Termux & Linux Dotfiles

A collection of configuration files to set up a modern and functional terminal environment on Termux and Linux. This setup focuses on providing a clean interface with useful productivity tools.

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
- **`install-*.sh`**: Default installation method. Copies files to your system (safe from accidental edits).
- **`symlink.sh`**: Development method. Selectively link files to the repo for real-time updates.
- **`sync.sh`**: Manual backup. Copy your local configuration changes back into the repository.
- **Dynamic Identity**: Use the `setname` command to update your user handle across the shell, Fastfetch, and Tmux status bar.
- **Integrated Navigation**: `y` command opens Yazi and automatically changes the shell directory to the last visited path upon exit.
- **System Metrics**: The Tmux status bar displays real-time information including battery status, CPU usage, RAM, and temperature.
- **Optimized Performance**: Status bar metrics are cached in the background to ensure terminal responsiveness.
- **Custom Greeting**: The `cls` (or `clear`) command provides a clean screen along with a personalized greeting and system overview.
- **Cross-Platform**: A unified installer supports both Termux and standard Linux distributions (Debian/Ubuntu).

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
| `yt` | `yewtube` (YouTube TUI player) |
| `mplay` | `mpv --profile=music <file|URL>` (play audio) |
| `mpause`/`mnext`/`mprev` | Control mpv via IPC socket |

## Music Player

This dotfiles set includes a lightweight music setup (YouTube streaming + local files):

- Backend: `mpv` with an IPC socket at `/tmp/mpvsocket` (configured in `config/mpv/mpv.conf`).
- TUI: `yewtube` for browsing and streaming YouTube without API keys.
- Controls: helper script at `zsh/.zsh_music` exposes `mplay`, `mpause`, `mnext`, `mprev`, `mvol`, and `minfo`.

Install the player with the installer or manually:

```bash
pkg install ffmpeg python python-yt-dlp socat
pip install yt-dlp yewtube
```

Usage examples:

```bash
yt                # Launch yewtube TUI
mplay <url|dir>   # Play a URL or folder
mpause            # Toggle pause
mnext             # Next track
mprev             # Previous track
```

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
- **Modular Installer**: Separate scripts for Termux and Linux for better maintenance.
- **Performance Fixes**: Asynchronous caching for system metrics in Tmux.
- **Unified Identity**: Improved synchronization for the `setname` system.
- **Startup Speed**: Optimized Zsh initialization using interactive shell guards.
