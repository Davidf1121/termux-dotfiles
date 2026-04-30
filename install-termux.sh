#!/bin/bash

# Termux installation script with enhanced error handling and visibility
# set -e          # Removed for maximum robustness as requested
set -u          # Treat unset variables as an error
set -o pipefail # Return the exit code of the last command in the pipe that failed

# Logging setup
VERBOSE=${VERBOSE:-false}

# Function to print messages
msg() {
    echo -e "$1" >&1
}

# Get the directory where the script is located (absolute path)
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

msg "🚀 Deploying God-Tier Environment for Termux..."

# Ensure coreutils for realpath (though we're moving away from its dependency in deploy)
if ! command -v realpath > /dev/null 2>&1; then
    msg "Installing coreutils..."
    pkg update && pkg install -y coreutils
fi

# Deployment function - Aggressive cleaning and absolute paths
deploy() {
    local src="$1"
    local dest="$2"
    
    msg "🔗 Symlinking $(basename "$src") -> $dest"
    
    # Aggressively remove whatever is currently at the target path
    rm -f "$dest" || rm -rf "$dest"
    
    # Ensure parent directory exists
    mkdir -p "$(dirname "$dest")"
    
    # Use paths directly (expected to be absolute)
    ln -sf "$src" "$dest"
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

# Force re-installation/update of core tools (btop and starship removed)
msg "🛠️ Installing/Updating core tools..."
pkg install -y --reinstall zsh git curl wget tmux fzf cmatrix fastfetch eza bat zoxide ranger yazi figlet

# Refresh command hash
hash -r

# Setup Zsh & Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    msg "🐚 Installing Oh My Zsh..."
    CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install plugins and themes
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins"
mkdir -p "$ZSH_CUSTOM/themes"

msg "🔌 Setting up Zsh plugins & themes..."
msg "📥 Downloading Powerlevel10k..."
git_clone_or_update "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"

msg "📥 Downloading plugins..."
git_clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git_clone_or_update "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# Setup Tmux
msg "🪟 Setting up Oh My Tmux..."
git_clone_or_update "https://github.com/gpakosz/.tmux.git" "$HOME/.tmux"
deploy "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"

# Apply Configs
msg "⚙️ Applying configurations..."
deploy "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
deploy "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"

# Fastfetch standard location - Handle with loop and sed for logo path
msg "ℹ️ Configuring Fastfetch..."
mkdir -p "$HOME/.config/fastfetch"
for file in "$DOTFILES_DIR/config/fastfetch/"*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/.config/fastfetch/$filename"
        # Ensure any existing config or broken link is removed
        rm -f "$target" || rm -rf "$target"
        if [ "$filename" = "config.jsonc" ]; then
            msg "🔧 Configuring Fastfetch with absolute logo path..."
            # Use sed to replace ~ with actual $HOME
            sed "s|~/.config/fastfetch/logo.txt|$HOME/.config/fastfetch/logo.txt|g" "$file" > "$target"
        else
            deploy "$file" "$target"
        fi
    fi
done

# Termux-specific configurations - Direct write Neon theme
msg "📱 Applying Termux-specific settings..."
mkdir -p "$HOME/.termux"
# Ensure any existing file or broken link is removed
rm -f "$HOME/.termux/colors.properties" || rm -rf "$HOME/.termux/colors.properties"
cat <<EOF > "$HOME/.termux/colors.properties"
# Neon Theme
background: #1a1b26
foreground: #a9b1d6
cursor: #c0caf5
color0: #15161e
color1: #f7768e
color2: #9ece6a
color3: #e0af68
color4: #7aa2f7
color5: #bb9af7
color6: #7dcfff
color7: #a9b1d6
color8: #414868
color9: #f7768e
color10: #9ece6a
color11: #e0af68
color12: #7aa2f7
color13: #bb9af7
color14: #7dcfff
color15: #c0caf5
EOF

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
