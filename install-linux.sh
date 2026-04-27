#!/bin/bash

# Get the directory where the script is located (absolute path)
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

echo "🚀 Deploying God-Tier Environment for Linux..."

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
sudo apt update
hash -r

# Essential dependencies
echo "Installing essential dependencies..."
sudo apt install -y zsh git curl wget tmux fzf btop cmatrix software-properties-common gpg which

# Install Fastfetch via PPA
if ! command -v fastfetch > /dev/null 2>&1; then
    echo "Installing Fastfetch via PPA..."
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    sudo apt update
    sudo apt install -y fastfetch
fi

# Install Eza
if ! command -v eza > /dev/null 2>&1; then
    echo "Installing Eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
fi

# Install Starship
if ! command -v starship > /dev/null 2>&1; then
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install Bat
if ! command -v bat > /dev/null 2>&1 && ! command -v batcat > /dev/null 2>&1; then
    sudo apt install -y bat
fi

# Install Zoxide
if ! command -v zoxide > /dev/null 2>&1; then
    curl -sS https://zoxide.xyz/install.sh | bash
fi

# Install Ranger/Yazi
sudo apt install -y ranger
if ! command -v yazi > /dev/null 2>&1; then
    echo "Attempting to install yazi..."
    sudo apt install -y yazi || echo "Could not install yazi automatically. Please install it manually: https://yazi-rs.github.io/docs/installation"
fi

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

# Disable login message
touch "$HOME/.hushlogin"

# Change default shell to zsh
echo "Changing default shell to zsh..."
sudo chsh -s $(command -v zsh) $USER

echo "✅ Linux Deployment Successful! Please restart your terminal or type 'zsh' to begin."
