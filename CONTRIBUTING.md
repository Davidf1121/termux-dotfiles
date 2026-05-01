# Development & Architecture

This document outlines the structure and logic of the environment to help maintain consistency during updates or feature additions.

## Project Structure
- `install.sh`: The dispatcher script. It detects the OS (Termux vs. Linux) and delegates to the appropriate sub-installer.
- `install-termux.sh` / `install-linux.sh`: Core installation logic. Uses a `deploy` function for robust symlinking using absolute paths.
- `zsh/.zshrc`: The heart of the shell environment. Handles identity, aliases, and tool initializations.
- `tmux/.tmux.conf.local`: Custom styling for the Oh My Tmux framework. Contains forced overrides for the Tokyo Night theme.
- `config/fastfetch/`: System information configuration including the JSON schema and custom logo.

## Key Systems

### Dynamic Identity
The environment uses a persistent naming system:
- **Storage**: `~/.user_name`
- **Logic**: The variable `$MY_USER` is exported in `.zshrc`.
- **Sync**: The `setname` function updates the storage file, updates the current session's environment, and re-sources the config.
- **Integration**: `$MY_USER` is passed to the Fastfetch title and the Tmux status bar.

### Shell Startup (Interactive Guard)
To ensure stability and compatibility with Powerlevel10k's instant prompt:
- No console output should occur during the main `.zshrc` initialization.
- The `cls` command (which handles the greeting and Fastfetch) is triggered at the very end of `.zshrc` using `[[ $- == *i* ]] && cls` to ensure it only runs in interactive sessions.

### Fastfetch Configuration
- **Version Compatibility**: Avoid using deprecated command-line flags. Prefer passing overrides via environment variables (e.g., `FASTFETCH_TITLE_FQDN`) or the `-S` structure flag.
- **Logo Paths**: Use absolute paths in `config.jsonc` to avoid resolution issues when the shell starts in different directories.

### Tmux Styling
- The Tokyo Night theme is enforced via direct `set -g` commands in the `user customizations` section of `.tmux.conf.local` to override framework defaults reliably.
- **Icons**: Uses Nerd Font glyphs (ensure a compatible font is active).
- **Status Bar Caching**: To prevent UI lag when calling `termux-api` (e.g., for battery or temp), a background caching mechanism is used. The `_update_battery_cache` function runs every 30 seconds as a background process, ensuring the status bar remains responsive.

## Workflow for Changes
1. **Symlinks**: Always use absolute paths for symlinks to prevent broken references in Termux's unique directory structure.
2. **Commit Style**: Use conventional commit prefixes (`feat:`, `fix:`, `docs:`, `refactor:`).
3. **Environment Detection**: Always check for the environment before running OS-specific package commands (e.g., `pkg` for Termux, `apt` for Linux).
