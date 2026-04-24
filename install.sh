#!/bin/bash

echo "🚀 Starting God-Tier Termux Installation..."

# 1. Update and Install Packages
pkg update -y
pkg install zsh fastfetch --color git curl lsd bat zoxide fzf cmatrix tmux -y

# 2. Setup Zsh & Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. Install Zsh Plugins & Themes
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k 2>/dev/null
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting 2>/dev/null
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions 2>/dev/null

# 4. Setup Tmux (Oh My Tmux)
if [ ! -d "$HOME/.tmux" ]; then
    cd ~ && git clone https://github.com/gpakosz/.tmux.git && ln -s -f .tmux/.tmux.conf .
fi

# 5. Apply Configs from Repo
cd ~/termux-dotfiles
cp zsh/.zshrc ~/.zshrc
mkdir -p ~/.config/fastfetch --color
cp config/fastfetch --color/config.jsonc ~/.config/fastfetch --color/config.jsonc
mkdir -p ~/.termux
cp termux/colors.properties ~/.termux/colors.properties
cp tmux/.tmux.conf.local ~/.tmux.conf.local

termux-reload-settings
chsh -s zsh

echo "✅ Installation Complete! Run 'exec zsh' to start."
