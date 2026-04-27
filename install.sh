#!/bin/bash

# Get the directory where the script is located (absolute path)
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

echo "🚀 Deploying God-Tier Environment..."

# OS Detection
IF_TERMUX=false
if [ -d "/data/data/com.termux" ]; then
    IF_TERMUX=true
    PKGER="pkg"
    UPDATE="pkg update -y && pkg upgrade -y"
    INSTALL="pkg install -y"
else
    IF_TERMUX=false
    PKGER="sudo apt"
    UPDATE="sudo apt update"
    INSTALL="sudo apt install -y"
fi

echo "Detected environment: $([ "$IF_TERMUX" = true ] && echo "Termux" || echo "Standard Linux")"

# Robust deployment function
deploy() {
    local src="$1"
    local dest="$2"
    echo "Linking $src -> $dest"
    rm -rf "$dest"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
}

# Update package list
echo "Updating packages..."
eval $UPDATE

# Essential dependencies
echo "Installing essential dependencies..."
if [ "$IF_TERMUX" = true ]; then
    $INSTALL zsh git curl wget tmux fzf btop cmatrix
else
    # On Linux, some tools might need extra steps or have different names
    $INSTALL zsh git curl wget tmux fzf btop cmatrix software-properties-common gpg
fi

# Install Fastfetch
if ! command -v fastfetch > /dev/null 2>&1; then
    if [ "$IF_TERMUX" = true ]; then
        $INSTALL fastfetch
    else
        echo "Installing Fastfetch via PPA..."
        sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
        sudo apt update
        $INSTALL fastfetch
    fi
fi

# Install Starship
if ! command -v starship > /dev/null 2>&1; then
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install Eza
if ! command -v eza > /dev/null 2>&1; then
    if [ "$IF_TERMUX" = true ]; then
        $INSTALL eza
    else
        echo "Installing Eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        $INSTALL eza
    fi
fi

# Install Bat
if ! command -v bat > /dev/null 2>&1 && ! command -v batcat > /dev/null 2>&1; then
    $INSTALL bat
fi

# Install Zoxide
if ! command -v zoxide > /dev/null 2>&1; then
    if [ "$IF_TERMUX" = true ]; then
        $INSTALL zoxide
    else
        curl -sS https://zoxide.xyz/install.sh | bash
    fi
fi

# Install Ranger/Yazi
$INSTALL ranger
if ! command -v yazi > /dev/null 2>&1; then
    if [ "$IF_TERMUX" = true ]; then
        $INSTALL yazi
    else
        echo "Attempting to install yazi..."
        $INSTALL yazi || echo "Could not install yazi automatically. Please install it manually: https://yazi-rs.github.io/docs/installation"
    fi
fi

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
        if [ "$filename" = "config.jsonc" ]; then
            echo "Configuring Fastfetch with absolute logo path..."
            rm -f "$HOME/.config/fastfetch/$filename"
            # Use sed to replace ~ with actual $HOME while copying
            sed "s|~/.config/fastfetch/logo.txt|$HOME/.config/fastfetch/logo.txt|g" "$file" > "$HOME/.config/fastfetch/$filename"
        else
            deploy "$file" "$HOME/.config/fastfetch/$filename"
        fi
    fi
done

# Termux-specific configurations
if [ "$IF_TERMUX" = true ]; then
    echo "Applying Termux-specific settings..."
    deploy "$DOTFILES_DIR/termux/colors.properties" "$HOME/.termux/colors.properties"
    termux-reload-settings
fi

# Disable login message
touch "$HOME/.hushlogin"

# Change default shell to zsh
echo "Changing default shell to zsh..."
if [ "$IF_TERMUX" = true ]; then
    chsh -s "$(command -v zsh)"
else
    sudo chsh -s "$(command -v zsh)" "$USER"
fi

echo "✅ Deployment Successful! Switching to zsh..."
exec "$(command -v zsh)" -l
