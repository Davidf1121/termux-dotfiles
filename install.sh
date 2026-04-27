#!/bin/bash

# Main entry point for the God-Tier dotfiles installation
# Supports -v/--verbose and -d/--debug flags

set -e
set -u
set -o pipefail

VERBOSE=false

# Simple argument parsing
for arg in "$@"; do
    case $arg in
        -v|--verbose|-d|--debug)
            VERBOSE=true
            shift
            ;;
    esac
done

if [ "$VERBOSE" = true ]; then
    echo "🔍 Verbose mode enabled. Enabling command tracing (set -x)."
    set -x
fi

# Get the directory where the script is located
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

echo "🛰️  Starting Environment Detection..."

# OS Detection
if [ -d "/data/data/com.termux" ]; then
    echo "📱 Detected Termux environment."
    chmod +x "$DOTFILES_DIR/install-termux.sh"
    if [ "$VERBOSE" = true ]; then
        bash -x "$DOTFILES_DIR/install-termux.sh"
    else
        "$DOTFILES_DIR/install-termux.sh"
    fi
else
    echo "💻 Detected Linux environment."
    chmod +x "$DOTFILES_DIR/install-linux.sh"
    if [ "$VERBOSE" = true ]; then
        bash -x "$DOTFILES_DIR/install-linux.sh"
    else
        "$DOTFILES_DIR/install-linux.sh"
    fi
fi
