# Termux Dotfiles: High-Performance Terminal Setup

A comprehensive configuration suite for Termux, designed for a high-end development experience with a focus on speed, aesthetics, and modern CLI tooling.

## Core Components

### Shell and Theme
- **Zsh**: The primary shell environment.
- **Oh My Zsh**: Framework for managing Zsh configurations and plugins.
- **Powerlevel10k**: A highly customizable, low-latency Zsh theme that provides visual indicators for git status, command execution time, and system state.

### Key Plugins
- **zsh-syntax-highlighting**: Provides real-time color feedback for commands.
- **zsh-autosuggestions**: Offers command completions based on history.
- **Zoxide**: A smarter `cd` command that learns your navigation habits for faster directory jumping.
- **FZF**: A command-line fuzzy finder used for interactive history search and file navigation.

### Visuals and Tooling
- **Fastfetch**: A modern system information tool with a custom JSON configuration for a sleek system overview.
- **LSD**: A rewrite of `ls` with support for icons and enhanced color schemes.
- **Bat**: A `cat` clone with syntax highlighting and Git integration.
- **Tmux**: A terminal multiplexer configured with "Oh My Tmux" for a high-end status dashboard.
- **CMatrix**: A terminal-based matrix digital rain simulator.

## Installation and Setup

The included `install.sh` script automates the deployment of this environment:

1. Clone the repository.
2. Ensure the `install.sh` script is executable: `chmod +x install.sh`.
3. Execute the script: `./install.sh`.
4. Restart the shell: `exec zsh`.

Upon the first run of Zsh, the Powerlevel10k configuration wizard will start automatically to help you finalize the visual style.
