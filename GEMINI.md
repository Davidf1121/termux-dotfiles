# GEMINI.md: Repository Development Mandates

This document takes absolute precedence over general workflows. It defines the architectural standards, system-wide dependencies, and development protocols for the **Termux & Linux Dotfiles** project.

## 1. Core Philosophy
- **Aesthetic Performance**: Every tool must be "fancy" (Tokyo Night theme, icons, Powerline symbols) without sacrificing Termux responsiveness.
- **Modular Deployment**: Configuration must be decoupled from installation logic. Installers (`install-*.sh`) handle environment detection and symlinking; the `config/` directory holds the logic.
- **Portability**: Maintain compatibility between Termux (ARM/Android) and Linux (x86/Debian).

## 2. Technical Standards

### Tmux & Status Bar
- **Custom Functions**: All custom metrics (CPU, RAM, Identity) must be defined as POSIX shell functions at the end of `tmux/.tmux.conf.local`.
- **Optimization**: Resource-intensive calls (like `termux-api`) **MUST** use the background caching pattern (`_update_battery_cache`) to prevent terminal lag.
- **Expansion**: Use `#(shell command)` syntax in `set -g status-right` for live updates.

### Neovim Configuration
- **Manager**: Use `lazy.nvim` for plugin management.
- **Structure**: Maintain a modular Lua structure:
    - `lua/config/`: Core settings and keymaps.
    - `lua/plugins/`: Atomic plugin definitions categorized by function (core, lsp, utils).
- **Theme**: Always synchronize with the Tokyo Night color palette.

### Shell (Zsh)
- **Identity**: The `setname` function is the source of truth for user identity. It must update `~/.user_name` and export `$MY_USER`.
- **Guards**: Interactive commands (like `cls` or `fastfetch`) must be gated by `[[ $- == *i* ]]` to avoid breaking non-interactive shell executions.

## 3. Deployment Protocol

### Symlinking (The `deploy` Function)
- **Absolute Paths**: Always use absolute paths for symlinks to prevent broken references in Termux's unique file system.
- **Aggressive Cleaning**: Installers must `rm -rf` the target before symlinking to ensure a clean state.

### Fastfetch Sync
- **Logo Resolution**: Fastfetch configs must use a `~` placeholder for logo paths. The installer is responsible for using `sed` to replace this with the actual `$HOME` path during deployment.

## 4. Maintenance & Evolution
- **Package Management**: Use `pkg` for Termux and `apt` for Linux. Always check for tool existence before aliasing.
- **Version Control**: Use conventional commits (`feat:`, `fix:`, `docs:`).
- **Environment Detection**: Always use the dispatcher pattern (`install.sh`) to detect the OS before running sub-installers.

---
*This document is a living mandate. When adding features, update this file to reflect new architectural decisions.*
