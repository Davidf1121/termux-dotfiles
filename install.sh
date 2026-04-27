#!/bin/bash
set -e

# Main entry point for the God-Tier dotfiles installation
# Supports -v/--verbose and -d/--debug flags

export VERBOSE=false
for arg in "$@"; do
    case $arg in
        -v|--verbose|-d|--debug) VERBOSE=true ;;
    esac
done

[ "$VERBOSE" = true ] && echo "🔍 Verbose mode enabled." && set -x

# Get the directory where the script is located
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

echo "🛰️  Starting Environment Detection..."

# OS Detection
OS_TYPE=$( [ -d "/data/data/com.termux" ] && echo "termux" || echo "linux" )
INSTALLER="$DOTFILES_DIR/install-$OS_TYPE.sh"

echo "📱 Detected $OS_TYPE environment."
chmod +x "$INSTALLER"

# Standardized call to installer
if [ "$VERBOSE" = true ]; then
    bash -x "$INSTALLER"
else
    bash "$INSTALLER"
fi
