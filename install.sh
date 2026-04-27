#!/bin/bash

# Get the directory where the script is located
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

# OS Detection
if [ -d "/data/data/com.termux" ]; then
    echo "Detected Termux environment."
    chmod +x "$DOTFILES_DIR/install-termux.sh"
    "$DOTFILES_DIR/install-termux.sh"
else
    echo "Detected Linux environment."
    chmod +x "$DOTFILES_DIR/install-linux.sh"
    "$DOTFILES_DIR/install-linux.sh"
fi
