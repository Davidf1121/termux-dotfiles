# Termux Dotfiles: God-Tier Setup

High-performance Termux environment with modern CLI tools.

## Core Toolset
- **Shell**: Zsh + Oh My Zsh
- **Prompt**: Powerlevel10k
- **Navigation**: Zoxide, Yazi (file manager), Ranger
- **System**: Fastfetch, Tmux
- **Utils**: Eza (modern ls), Bat (syntax cat), FZF

## Font Requirement
This setup uses Powerlevel10k, which requires a Nerd Font for icons to display correctly.
- **Termux/Linux**: Run `p10k configure` upon first launch. Powerlevel10k will offer to install the recommended MesloLGS NF font for you. Follow the on-screen instructions to complete the setup.

## Commands and Aliases

| Command | Action |
| :--- | :--- |
| `ls` | `eza` (directory listing) |
| `ll` | `eza -lah` (long listing with hidden files) |
| `la` | `eza -a` (all files) |
| `lt` | `eza --tree --level=2` (tree view) |
| `cat` | `bat` (syntax-highlighted cat) |
| `fm` | `ranger` (file manager) |
| `y` / `yazi` | `yazi` (fast file manager with auto-cd) |
| `ff` | `fastfetch` (system overview) |
| `mux` | `tmux` (terminal multiplexer) |
| `z <dir>` | `zoxide` (intelligent directory navigation) |
| `matrix` | `cmatrix` (hacker-style rain) |
| `weather` | `wttr.in` (terminal weather report) |
| `fdown` | Search files with live `bat` preview |
| `zrc` | `source ~/.zshrc` (reload shell) |
| `ezrc` | `nano ~/.zshrc` (edit config) |
| `cls` | `clear` (clear screen) |

## Example image
![alt text](Screenshot_2026-04-25-20-50-34-473-edit_com.termux.jpg)
![alt text](Screenshot_2026-04-25-13-18-07-766-edit_com.termux.jpg)
## Installation

Run the following command to deploy the full environment:

```bash
bash install.sh
```

## Troubleshooting

If you encounter any issues during installation, use the debug installer for full visibility:

```bash
bash debug-install.sh
```

This will provide detailed logs and system information to help diagnose the problem.
