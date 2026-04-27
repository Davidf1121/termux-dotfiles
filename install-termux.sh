#!/bin/bash

# Termux installation script with enhanced error handling and visibility
set -e          # Exit immediately if a command exits with a non-zero status
set -u          # Treat unset variables as an error
set -o pipefail # Return the exit code of the last command in the pipe that failed

# Logging setup
LOG_FILE="install.log"
VERBOSE=${VERBOSE:-false}

# Redirect stdout and stderr to the log file and show progress live
exec > >(tee -i "$LOG_FILE") 2>&1

# Function to print messages
msg() {
    echo -e "$1"
}

# Get the directory where the script is located (absolute path)
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

msg "🚀 Deploying God-Tier Environment for Termux..."
msg "📝 Logging all output to $LOG_FILE"

# Ensure coreutils for realpath
if ! command -v realpath > /dev/null 2>&1; then
    msg "Installing coreutils..."
    pkg update && pkg install -y coreutils
fi

# Robust deployment function with absolute paths
deploy() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        msg "⚠️  Source $src does not exist, skipping..."
        return 0 # Return 0 to prevent set -e from stopping the script during "skips"
    fi

    # Convert to absolute paths
    src=$(realpath "$src")
    dest=$(realpath -m "$dest")

    msg "🔗 Linking $src -> $dest"
    
    # Ensure parent directory exists
    mkdir -p "$(dirname "$dest")"
    
    # Remove existing destination safely
    rm -rf "$dest"
    ln -sf "$src" "$dest"
    msg "✅ Successfully linked $src"
}

# Git helper function
git_clone_or_update() {
    local repo_url="$1"
    local target_dir="$2"
    
    if [ -d "$target_dir" ]; then
        msg "🔄 Updating $target_dir..."
        git -C "$target_dir" pull || (msg "⚠️ Failed to update $target_dir, continuing..." && return 0)
    else
        msg "📥 Cloning $repo_url into $target_dir..."
        git clone --depth 1 "$repo_url" "$target_dir"
    fi
}

# Update package list using pkg
msg "🔄 Updating package lists..."
pkg update
pkg upgrade -y

# Force re-installation/update of core tools (btop removed)
msg "🛠️ Installing/Updating core tools..."
pkg install -y --reinstall zsh git curl wget tmux fzf cmatrix fastfetch starship eza bat zoxide ranger yazi

# Refresh command hash
hash -r

# Setup Zsh & Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    msg "🐚 Installing Oh My Zsh..."
    # Oh My Zsh installation can fail if not handled properly in non-interactive environments
    CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install plugins and themes
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
mkdir -p "$ZSH_CUSTOM/plugins"
mkdir -p "$ZSH_CUSTOM/themes"

msg "🔌 Setting up Zsh plugins & themes..."
msg "📥 Downloading Powerlevel10k..."
git_clone_or_update "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"

msg "📥 Downloading plugins..."
git_clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git_clone_or_update "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# Setup Font for Powerlevel10k
msg "📥 Downloading Meslo Nerd Font for Termux..."
mkdir -p "$HOME/.termux"
curl -fLo "$HOME/.termux/font.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"

# Setup Tmux
msg "🪟 Setting up Oh My Tmux..."
git_clone_or_update "https://github.com/gpakosz/.tmux.git" "$HOME/.tmux"
deploy "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"

# Apply Configs using absolute paths
msg "⚙️ Applying configurations..."
deploy "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
deploy "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"

# Fastfetch standard location explanation
msg "ℹ️ Fastfetch configurations are located in $HOME/.config/fastfetch/ (standard location)"
mkdir -p "$HOME/.config/fastfetch"
for file in "$DOTFILES_DIR/config/fastfetch/"*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/.config/fastfetch/$filename"
        if [ "$filename" = "config.jsonc" ]; then
            msg "🔧 Configuring Fastfetch with absolute logo path..."
            # Use sed to replace ~ with actual $HOME while copying
            sed "s|~/.config/fastfetch/logo.txt|$HOME/.config/fastfetch/logo.txt|g" "$file" > "$target"
        else
            deploy "$file" "$target"
        fi
    fi
done

# Termux-specific configurations
msg "📱 Applying Termux-specific settings..."
deploy "$DOTFILES_DIR/termux/colors.properties" "$HOME/.termux/colors.properties"
if command -v termux-reload-settings > /dev/null 2>&1; then
    msg "♻️ Reloading Termux settings..."
    termux-reload-settings
fi

# Disable login message
touch "$HOME/.hushlogin"

# Change default shell to zsh
msg "🐚 Changing default shell to zsh..."
chsh -s zsh

msg "✨ Termux Deployment Successful!"
msg "👉 Please restart Termux or type 'zsh' to begin."
msg "📜 Check $LOG_FILE for details."
