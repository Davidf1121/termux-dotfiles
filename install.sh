#!/bin/bash

# Main entry point for the God-Tier dotfiles installation
# Supports -v/--verbose and -d/--debug flags

set -e
set -u
set -o pipefail

VERBOSE=false
export VERBOSE

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

# OS Detection and Execution
if [ -d "/data/data/com.termux" ]; then
    INSTALLER="$DOTFILES_DIR/install-termux.sh"
    echo "📱 Detected Termux environment."
else
    INSTALLER="$DOTFILES_DIR/install-linux.sh"
    echo "💻 Detected Linux environment."
fi

chmod +x "$INSTALLER"
if [ "$VERBOSE" = true ]; then
    bash -x "$INSTALLER"
else
    "$INSTALLER"
fi
