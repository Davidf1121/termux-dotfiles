#!/bin/bash

# Get the directory where the script is located (absolute path)
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

echo "🚀 Deploying God-Tier Environment for Termux..."

# Robust deployment function
deploy() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        echo "⚠️  Source $src does not exist, skipping..."
        return 1
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dest")"
    
    # Remove existing destination safely
    rm -rf "$dest"
    ln -sf "$src" "$dest"
    echo "✅ Linked $src -> $dest"
}

# Update package list
echo "Updating packages..."
pkg update -y && pkg upgrade -y
hash -r

# Essential dependencies
echo "Installing essential dependencies..."
pkg install -y zsh git curl wget tmux fzf btop cmatrix fastfetch starship eza bat zoxide ranger yazi

# Refresh command hash
hash -r

# Setup Zsh & Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
mkdir -p "$ZSH_CUSTOM/plugins"
echo "Installing Zsh plugins..."
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# Setup Tmux
if [ ! -d "$HOME/.tmux" ]; then
    echo "Setting up Oh My Tmux..."
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    deploy "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
fi

# Apply Configs using absolute paths
echo "Applying configurations..."
deploy "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
deploy "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"

# Handle fastfetch configs specially for absolute logo path
mkdir -p "$HOME/.config/fastfetch"
for file in "$DOTFILES_DIR/config/fastfetch/"*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/.config/fastfetch/$filename"
        if [ "$filename" = "config.jsonc" ]; then
            echo "Configuring Fastfetch with absolute logo path..."
            # Use sed to replace ~ with actual $HOME while copying
            sed "s|~/.config/fastfetch/logo.txt|$HOME/.config/fastfetch/logo.txt|g" "$file" > "$target"
        else
            deploy "$file" "$target"
        fi
    fi
done

# Termux-specific configurations
echo "Applying Termux-specific settings..."
deploy "$DOTFILES_DIR/termux/colors.properties" "$HOME/.termux/colors.properties"
if command -v termux-reload-settings > /dev/null 2>&1; then
    termux-reload-settings
fi

# Disable login message
touch "$HOME/.hushlogin"

# Change default shell to zsh
echo "Changing default shell to zsh..."
chsh -s zsh

echo "✅ Termux Deployment Successful! Please restart Termux or type 'zsh' to begin."
