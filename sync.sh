#!/bin/bash

# Sync script to manually update the repository with local changes
# This prevents sensitive data in your active config from being auto-tracked.

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

msg() {
    echo -e "🚀 $1"
}

confirm() {
    read -p "❓ $1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

msg "Starting manual sync: Local Config -> Repository"

# 1. Zsh
if confirm "Sync .zshrc?"; then
    cp "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc"
    msg "Synced .zshrc"
fi

# 2. Tmux
if confirm "Sync .tmux.conf.local?"; then
    cp "$HOME/.tmux.conf.local" "$DOTFILES_DIR/tmux/.tmux.conf.local"
    msg "Synced .tmux.conf.local"
fi

# 3. Neovim
if confirm "Sync Neovim config? (WARNING: Check for private data/tokens first!)"; then
    rm -rf "$DOTFILES_DIR/config/nvim"
    cp -r "$HOME/.config/nvim" "$DOTFILES_DIR/config/nvim"
    # Safety: Remove common local-only files
    rm -rf "$DOTFILES_DIR/config/nvim/.git"
    rm -rf "$DOTFILES_DIR/config/nvim/lazy-lock.json"
    msg "Synced Neovim config"
fi

# 4. Fastfetch
if confirm "Sync Fastfetch config?"; then
    cp "$HOME/.config/fastfetch/config.jsonc" "$DOTFILES_DIR/config/fastfetch/config.jsonc"
    [ -f "$HOME/.config/fastfetch/logo.txt" ] && cp "$HOME/.config/fastfetch/logo.txt" "$DOTFILES_DIR/config/fastfetch/logo.txt"
    msg "Synced Fastfetch config"
fi

# 5. MPV (music)
if confirm "Sync MPV config (~/.config/mpv)?"; then
    rm -rf "$DOTFILES_DIR/config/mpv"
    mkdir -p "$DOTFILES_DIR/config/mpv"
    cp -r "$HOME/.config/mpv"/* "$DOTFILES_DIR/config/mpv/" 2>/dev/null || true
    msg "Synced MPV config"
fi

# 6. Music player script
if confirm "Sync music app (bin/music.py)?"; then
    [ -f "$HOME/termux-dotfiles/bin/music.py" ] && cp "$HOME/termux-dotfiles/bin/music.py" "$DOTFILES_DIR/bin/music.py"
    msg "Synced music app"
fi

# 7. Zsh music helper
if confirm "Sync Zsh music helper (~/.zsh_music)?"; then
    [ -f "$HOME/.zsh_music" ] && cp "$HOME/.zsh_music" "$DOTFILES_DIR/zsh/.zsh_music"
    # Also allow syncing from the dotfiles path if linked
    [ -f "$HOME/termux-dotfiles/zsh/.zsh_music" ] && cp "$HOME/termux-dotfiles/zsh/.zsh_music" "$DOTFILES_DIR/zsh/.zsh_music"
    msg "Synced Zsh music helper"
fi

# 5. Termux Properties
if confirm "Sync Termux properties?"; then
    cp "$HOME/.termux/termux.properties" "$DOTFILES_DIR/termux/termux.properties"
    cp "$HOME/.termux/colors.properties" "$DOTFILES_DIR/termux/colors.properties"
    msg "Synced Termux properties"
fi

msg "✅ Sync complete! Review changes with 'git diff' before committing."
