#!/bin/bash

# Termux installation script with enhanced error handling and visibility
set -e          # Exit immediately if a command exits with a non-zero status
set -u          # Treat unset variables as an error
set -o pipefail # Return the exit code of the last command in the pipe that failed

# Logging setup
LOG_FILE="install.log"
exec > >(tee -i "$LOG_FILE") 2>&1

# Get the directory where the script is located (absolute path)
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

echo "🚀 Deploying God-Tier Environment for Termux..."
echo "📝 Logging to $LOG_FILE"

# Ensure coreutils for realpath
if ! command -v realpath > /dev/null 2>&1; then
    echo "Installing coreutils..."
    apt update && apt install -y coreutils
fi

# Robust deployment function with absolute paths
deploy() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        echo "⚠️  Source $src does not exist, skipping..."
        return 1
    fi

    # Convert to absolute path
    src=$(realpath "$src")

    echo "🔗 Linking $src -> $dest"
    
    # Ensure parent directory exists
    mkdir -p "$(dirname "$dest")"
    
    # Remove existing destination safely
    rm -rf "$dest"
    ln -sf "$src" "$dest"
    echo "✅ Successfully linked $src"
}

# Git helper function
git_clone_or_update() {
    local repo_url="$1"
    local target_dir="$2"
    
    if [ -d "$target_dir" ]; then
        echo "🔄 Updating $target_dir..."
        git -C "$target_dir" pull || (echo "⚠️ Failed to update $target_dir, continuing..." && return 0)
    else
        echo "📥 Cloning $repo_url into $target_dir..."
        git clone --depth 1 "$repo_url" "$target_dir"
    fi
}

# Update package list using apt
echo "🔄 Updating package lists..."
apt update
apt upgrade -y

# Force re-installation/update of core tools
echo "🛠️ Installing/Updating core tools..."
apt install -y --reinstall zsh git curl wget tmux fzf btop cmatrix fastfetch starship eza bat zoxide ranger yazi

# Refresh command hash
hash -r

# Setup Zsh & Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    # Oh My Zsh installation can fail if not handled properly in non-interactive environments
    CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
mkdir -p "$ZSH_CUSTOM/plugins"
echo "🔌 Setting up Zsh plugins..."
git_clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git_clone_or_update "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# Setup Tmux
echo "🪟 Setting up Oh My Tmux..."
git_clone_or_update "https://github.com/gpakosz/.tmux.git" "$HOME/.tmux"
deploy "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"

# Apply Configs using absolute paths
echo "⚙️ Applying configurations..."
deploy "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
deploy "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"

# Fastfetch standard location explanation
echo "ℹ️ Fastfetch configurations are located in $HOME/.config/fastfetch/ (standard location)"
mkdir -p "$HOME/.config/fastfetch"
for file in "$DOTFILES_DIR/config/fastfetch/"*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/.config/fastfetch/$filename"
        if [ "$filename" = "config.jsonc" ]; then
            echo "🔧 Configuring Fastfetch with absolute logo path..."
            # Use sed to replace ~ with actual $HOME while copying
            sed "s|~/.config/fastfetch/logo.txt|$HOME/.config/fastfetch/logo.txt|g" "$file" > "$target"
        else
            deploy "$file" "$target"
        fi
    fi
done

# Termux-specific configurations
echo "📱 Applying Termux-specific settings..."
deploy "$DOTFILES_DIR/termux/colors.properties" "$HOME/.termux/colors.properties"
if command -v termux-reload-settings > /dev/null 2>&1; then
    echo "♻️ Reloading Termux settings..."
    termux-reload-settings
fi

# Disable login message
touch "$HOME/.hushlogin"

# Change default shell to zsh
echo "🐚 Changing default shell to zsh..."
chsh -s zsh

echo "✨ Termux Deployment Successful!"
echo "👉 Please restart Termux or type 'zsh' to begin."
echo "📜 Check $LOG_FILE for details."
