# AGENTS.md

## What this repo is
Dotfiles for Termux (Android) and Linux. Shell: zsh + Oh My Zsh + Powerlevel10k. Editor: Neovim (lazy.nvim, Lua). Multiplexer: tmux (Oh My Tmux + Tokyo Night). File managers: yazi, ranger.

## Install / deploy flow
```
bash install.sh            # dispatcher — auto-detects Termux vs Linux, calls install-*.sh
bash install.sh --verbose  # enables set -x tracing
bash debug-install.sh      # prints system info then runs install.sh --verbose
```
- `install-termux.sh` uses `pkg` for packages; `install-linux.sh` uses `apt`/`sudo`.
- The `deploy` function **copies** files (not symlinks) and `rm -rf` targets first.

## Dev workflow (3 scripts)
| Script | Purpose |
|---|---|
| `install-*.sh` | Copies files to system (production) |
| `symlink.sh` | Interactive selective symlinks for live editing (dev) |
| `sync.sh` | Copies local changes back into the repo (backup) |

**Security**: Do not symlink Neovim config if it contains private tokens. `~/.user_name` is in `.gitignore` (never commit it).

## Architecture — directory boundaries
| Path | Contents |
|---|---|
| `zsh/.zshrc` | Shell config: aliases, identity (`$MY_USER`), plugins, interactive guards |
| `tmux/.tmux.conf.local` | Oh My Tmux overrides — Tokyo Night theme, status bar with cached metrics |
| `config/nvim/` | Neovim — `init.lua` bootstraps `lua/config/` (options, keymaps, lazy) + `lua/plugins/` |
| `config/fastfetch/` | `config.jsonc` + `logo.txt` — uses `~` placeholder for logo paths |
| `termux/` | `termux.properties` + `colors.properties` (Termux app settings) |

## Quirks an agent will miss
- **Fastfetch logo paths**: `config.jsonc` uses `~/.config/fastfetch/logo.txt` as placeholder. Installers `sed` this to the real `$HOME` path during deploy. Do not hardcode absolute paths.
- **Interactive guards**: Greeting/fastfetch calls in `.zshrc` are gated by `[[ $- == *i* ]]` — keep this pattern for any new non-silent init output.
- **Tmux status bar caching**: Termux API calls (battery, temp) run every 30s in a background process (`_update_battery_cache`) to avoid UI lag. Do not call `termux-api` directly in status-right.
- **Oh My Tmux base**: `install-*.sh` clones `gpakosz/.tmux` to `~/.tmux` and deploys `~/.tmux.conf`. `.tmux.conf.local` is the repo's customization overlay.
- **Oh My Zsh plugins**: Powerlevel10k, zsh-syntax-highlighting, zsh-autosuggestions are git-cloned into `$ZSH_CUSTOM`.

## Conventions
- Commits: conventional prefixes (`feat:`, `fix:`, `docs:`, `refactor:`).
- Always verify environment before OS-specific commands (`pkg` vs `apt`).
- Theme: Tokyo Night across all components.
- Nerd Font required for icons.

## Existing instruction sources
- `GEMINI.md` — architectural mandates and technical standards (read before making structural changes).
- `CONTRIBUTING.md` — architecture overview and workflow details.
- `README.md` — user-facing feature list and alias reference.

## Music Player (Free) - Custom Python
- **App**: `bin/music.py` - Custom Python + mpv IPC socket
- **Commands**: `m <url|file>` (play), `m pause`, `m next`, `m prev`, `m stop`, `m info`
- **Shortcuts**: `p` (play), `mnext`, `mprev`, `minfo`
- **Config**: `config/mpv/mpv.conf` — music profile with IPC at `/tmp/mpvsocket`
- **Cache**: `~/.cache/music_current` for tmux status bar (avoids lag)
