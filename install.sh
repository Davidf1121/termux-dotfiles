#!/bin/bash

# Get the directory where the script is located
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

echo "🚀 Deploying God-Tier Termux Environment..."

# Update and install all tools
pkg update -y && pkg upgrade -y
pkg install zsh git curl starship eza bat ranger yazi fzf tmux fastfetch zoxide cmatrix -y

# Setup Zsh & Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
echo "Installing Zsh plugins..."
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# Setup Tmux
if [ ! -d "$HOME/.tmux" ]; then
    echo "Setting up Oh My Tmux..."
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
fi

# Create necessary directories
mkdir -p ~/.config/fastfetch
mkdir -p ~/.termux

# Apply Configs using symlinks
echo "Applying configurations..."
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# Symlink all fastfetch configs
for file in "$DOTFILES_DIR/config/fastfetch/"*; do
    [ -f "$file" ] && ln -sf "$file" "$HOME/.config/fastfetch/$(basename "$file")"
done

ln -sf "$DOTFILES_DIR/termux/colors.properties" "$HOME/.termux/colors.properties"
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"

# Disable login message
touch ~/.hushlogin

# Reload Termux settings
termux-reload-settings

# Change default shell to zsh
chsh -s zsh

echo "✅ Deployment Successful! Run 'exec zsh' to start."
