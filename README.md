# Termux & Linux Dotfiles

A collection of configuration files to set up a modern and functional terminal environment on Termux and Linux. This setup focuses on providing a clean interface with useful productivity tools.

## Preview
![Main Terminal](Screenshot_2026-04-25-20-50-34-473-edit_com.termux.jpg)
![File Manager](Screenshot_2026-04-25-13-18-07-766-edit_com.termux.jpg)
![Latest Update](Screenshot_2026-05-01-00-20-43-504-edit_com.termux.jpg)

## Core Components
- **Shell**: `zsh` managed with Oh My Zsh.
- **Theme**: Powerlevel10k for a detailed and responsive prompt.
- **File Managers**: `yazi` and `ranger`.
- **Multiplexer**: `tmux` with a custom Tokyo Night color scheme.
- **Tools**: Includes `eza` for directory listings, `bat` for file viewing, and `zoxide` for navigation.

## Key Features
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
