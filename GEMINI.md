# GEMINI.md: Repository Development Mandates

This document takes absolute precedence over general workflows. It defines the architectural standards, system-wide dependencies, and development protocols for the **Termux Dotfiles** project.

## 1. Core Philosophy
- **Aesthetic Performance**: Every tool must be "fancy" (Tokyo Night theme, icons, Powerline symbols) without sacrificing Termux responsiveness.
- **Modular Deployment**: Configuration must be decoupled from installation logic. The installer handles deployment; the `config/` directory holds the logic.
- **Termux-First**: All configurations are optimized for Termux (ARM/Android). Linux support has been temporarily removed pending full port testing.

## 2. Technical Standards

### Tmux & Status Bar
- **Custom Functions**: All custom metrics (CPU, RAM, Identity) must be defined as POSIX shell functions at the end of `tmux/.tmux.conf.local`.
- **Optimization**: Resource-intensive calls (like `termux-api`) **MUST** use the background caching pattern (`_update_battery_cache`) to prevent terminal lag.
- **Dynamic 2nd Row**: Use `set -g status 2` for the music dashboard. The `now_playing` function MUST safely toggle status rows (checking current state first) to avoid infinite recursion loops.
- **Shell Functions**: All custom shell functions in `.tmux.conf.local` MUST be commented with `# ` at the start of every line to be parsed correctly by the "Oh My Tmux" framework.
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

### Music Player
- **App**: Custom Python at `bin/music.py` with mpv IPC socket.
- **No pip deps**: Just mpv + socat + ffprobe + yt-dlp.
- **Core commands**: `m <url|file|query>` (play/auto-search), `m search <query>`, `m pause`, `m stop`, `m info`, `m watch`
- **QoL features**:
  - `m <query>` - Auto-search and play first result
  - `m history` - Show playback history
  - `m replay [index]` - Replay from history (last if no index)
  - `m seek <seconds>` - Seek forward/backward
  - `m forward/backward` - Quick seek ±10s
  - `m search` - Interactive selection with fzf (if available)
- **Audio**: PulseAudio (auto-started on play).
- **Cache**: Write to `~/.cache/music_current` for tmux.
- **History**: Auto-recorded to `~/.cache/music_history` on each play.

## 3. Deployment Protocol

### Deployment (The `deploy` Function)
- **Copying**: Configuration files must be **copied** from the repository to the target location, NOT symlinked. This prevents active local edits (which might contain secrets) from being automatically tracked by the repository.
- **Aggressive Cleaning**: Installers must `rm -rf` the target before deploying to ensure a clean state.

### Manual Synchronization
- **`sync.sh`**: Use the dedicated sync script to manually back up local configuration changes into the repository.
- **`symlink.sh`**: For easier development, use this script to selectively symlink files. This allows real-time updates for non-sensitive files (like Zsh) while keeping sensitive files (like Neovim) as isolated copies.
- **Safety**: Always audit files for private tokens or sensitive data before running `sync.sh` or choosing to symlink a directory.

### Fastfetch Sync
- **Logo Resolution**: Fastfetch configs must use a `~` placeholder for logo paths. The installer is responsible for using `sed` to replace this with the actual `$HOME` path during deployment.

## 4. Maintenance & Evolution
- **Package Management**: Use `pkg` for Termux. Always check for tool existence before aliasing.
- **Version Control**: Use conventional commits (`feat:`, `fix:`, `docs:`). Local commits are the default; **NEVER** push to the remote repository unless explicitly commanded by the user.
- **Termux-Only**: The installer (`install.sh`) is Termux-only. Linux support has been temporarily removed.

---
*This document is a living mandate. When adding features, update this file to reflect new architectural decisions.*
