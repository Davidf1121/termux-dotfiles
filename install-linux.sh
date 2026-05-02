#!/bin/bash

# Linux installation script with enhanced error handling and consistency
set -e
set -u
set -o pipefail

# Logging setup
LOG_FILE="install.log"
exec > >(tee -i "$LOG_FILE") 2>&1

# Get the directory where the script is located (absolute path)
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

export DEBIAN_FRONTEND=noninteractive

echo "🚀 Deploying Environment for Linux..."

# Pre-seed debconf for non-interactive keyboard-configuration
if command -v debconf-set-selections > /dev/null 2>&1; then
    echo 'keyboard-configuration keyboard-configuration/layoutcode string us' | sudo debconf-set-selections
    echo 'keyboard-configuration keyboard-configuration/modelcode string pc105' | sudo debconf-set-selections
    echo 'console-setup console-setup/charmap select UTF-8' | sudo debconf-set-selections
fi

# Ensure coreutils for realpath
if ! command -v realpath > /dev/null 2>&1; then
    echo "Installing coreutils..."
    sudo apt-get update && sudo apt-get install -y coreutils
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

# Update package list
echo "🔄 Updating packages..."
sudo apt-get update -y
hash -r

# Essential dependencies
echo "🛠️ Installing essential dependencies..."
sudo apt-get install -yq zsh git curl wget tmux fzf cmatrix software-properties-common gpg which neovim ripgrep python3 python3-pip nodejs

# Install Fastfetch via PPA
if ! command -v fastfetch > /dev/null 2>&1; then
    echo "📥 Installing Fastfetch via PPA..."
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    sudo apt-get update -y
    sudo apt-get install -yq fastfetch
fi

# Install Eza
if ! command -v eza > /dev/null 2>&1; then
    echo "📥 Installing Eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -y
    sudo apt-get install -yq eza
fi

# Install Bat
if ! command -v bat > /dev/null 2>&1 && ! command -v batcat > /dev/null 2>&1; then
    echo "📥 Installing bat..."
    sudo apt-get install -yq bat
fi

# Install Zoxide
if ! command -v zoxide > /dev/null 2>&1; then
    echo "📥 Installing zoxide..."
    curl -sS https://zoxide.xyz/install.sh | bash
fi

# Install Ranger/Yazi
echo "📥 Installing ranger..."
sudo apt-get install -yq ranger
if ! command -v yazi > /dev/null 2>&1; then
    echo "📥 Attempting to install yazi..."
    sudo apt-get install -yq yazi || echo "⚠️ Could not install yazi automatically. Please install it manually: https://yazi-rs.github.io/docs/installation"
fi

# Refresh command hash
hash -r

# Setup Zsh & Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if command -v zsh > /dev/null 2>&1; then
        echo "🐚 Installing Oh My Zsh..."
        CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "⚠️  Zsh is not installed. Skipping Oh My Zsh setup."
    fi
fi

# Install plugins and themes
if [ -d "$HOME/.oh-my-zsh" ]; then
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    mkdir -p "$ZSH_CUSTOM/plugins"
    mkdir -p "$ZSH_CUSTOM/themes"
    echo "🔌 Setting up Zsh plugins & themes..."
    echo "📥 Downloading Powerlevel10k..."
    git_clone_or_update "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"
    echo "📥 Downloading plugins..."
    git_clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    git_clone_or_update "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "ℹ️  NOTE: Please install a Nerd Font (e.g., MesloLGS NF) on your Linux system to see icons correctly."
fi

# Setup Tmux
echo "🪟 Setting up Oh My Tmux..."
git_clone_or_update "https://github.com/gpakosz/.tmux.git" "$HOME/.tmux"
deploy "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"

# Apply Configs using absolute paths
echo "⚙️ Applying configurations..."
deploy "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
deploy "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"
deploy "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

# Handle fastfetch configs specially for absolute logo path
echo "ℹ️ Configuring Fastfetch..."
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

# Disable login message
touch "$HOME/.hushlogin"

# Change default shell to zsh
ZSH_PATH=$(command -v zsh)
if [ -n "$ZSH_PATH" ]; then
    echo "🐚 Changing default shell to zsh..."
    sudo chsh -s "$ZSH_PATH" "$USER"
else
    echo "⚠️  Zsh not found, cannot change shell."
fi

echo "✨ Linux Deployment Successful!"
echo "👉 Please restart your terminal or type 'zsh' to begin."
echo "📜 Check $LOG_FILE for details."
