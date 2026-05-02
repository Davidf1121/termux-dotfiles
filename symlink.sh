#!/bin/bash

# symlink.sh: Selective symlinking for easier development
# Use this script to link repository files to your system for real-time updates.
# WARNING: Symlinking files with private data (like Neovim with tokens) 
# means your secrets will be visible to 'git status' and 'git diff'.

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

msg() {
    echo -e "🔗 $1"
}

confirm() {
    read -p "❓ Symlink $1? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

deploy_link() {
    local src="$1"
    local dest="$2"
    msg "Linking $(basename "$src") -> $dest"
    rm -rf "$dest"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
}

msg "Starting Selective Symlinking (Development Mode)"
echo "------------------------------------------------"
echo "⚠️  SECURITY WARNING: Symlinking will make your local configuration 
   edits immediately visible to the repository folder. Ensure you 
   do not have sensitive data, tokens, or private keys in files 
   you choose to symlink."
echo "------------------------------------------------"

# 1. Zsh
if confirm "Zsh config (.zshrc)"; then
    deploy_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
fi

# 2. Tmux
if confirm "Tmux config (.tmux.conf.local)"; then
    deploy_link "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"
fi

# 3. Neovim
if confirm "Neovim config (~/.config/nvim)"; then
    deploy_link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
fi

# 4. Fastfetch
if confirm "Fastfetch config"; then
    mkdir -p "$HOME/.config/fastfetch"
    deploy_link "$DOTFILES_DIR/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    deploy_link "$DOTFILES_DIR/config/fastfetch/logo.txt" "$HOME/.config/fastfetch/logo.txt"
fi

# 5. Termux Properties
if confirm "Termux properties (colors & keys)"; then
    mkdir -p "$HOME/.termux"
    deploy_link "$DOTFILES_DIR/termux/termux.properties" "$HOME/.termux/termux.properties"
    deploy_link "$DOTFILES_DIR/termux/colors.properties" "$HOME/.termux/colors.properties"
    if command -v termux-reload-settings > /dev/null 2>&1; then
        termux-reload-settings
    fi
fi

echo "------------------------------------------------"
msg "Selective symlinking complete!"
msg "Files you skipped remain as physical copies (safe from auto-sync)."
