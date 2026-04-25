#!/bin/bash

echo "🚀 Deploying God-Tier Termux Environment..."

# Update and install all tools
pkg update -y
pkg install zsh git curl starship eza bat btop ranger yazi fzf tmux fastfetch zoxide cmatrix -y

# Setup Zsh & Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install plugins/themes
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k 2>/dev/null
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting 2>/dev/null
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions 2>/dev/null

# Setup Tmux
if [ ! -d "$HOME/.tmux" ]; then
    cd ~ && git clone https://github.com/gpakosz/.tmux.git && ln -s -f .tmux/.tmux.conf .
fi

# Apply Configs
cp zsh/.zshrc ~/.zshrc
mkdir -p ~/.config/fastfetch
cp config/fastfetch/* ~/.config/fastfetch/
mkdir -p ~/.termux
cp termux/colors.properties ~/.termux/colors.properties
cp tmux/.tmux.conf.local ~/.tmux.conf.local

termux-reload-settings
chsh -s zsh

echo "✅ Deployment Successful! Run 'exec zsh' to start."
