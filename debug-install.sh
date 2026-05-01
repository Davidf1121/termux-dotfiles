#!/bin/bash
# Environment Troubleshooting & Debug Installer
# This script collects system information and runs the installer with full verbosity.

echo "🔍 Starting Debug Installation..."
echo "=========================================="
echo "📊 System Information:"
echo "Date: $(date)"
echo "OS: $(uname -a)"
if command -v termux-info > /dev/null 2>&1; then
    echo "Termux Info:"
    termux-info
fi
echo "Uptime: $(uptime)"
echo "Disk Usage:"
df -h .
echo "Memory Info:"
if command -v free > /dev/null 2>&1; then
    free -m
else
    echo "free command not available"
fi
echo "User: $(whoami)"
echo "Shell: $SHELL"
echo "Termux check: $([ -d /data/data/com.termux ] && echo "Yes" || echo "No")"
echo "=========================================="

# Run the main installer with verbose flag
# The verbose flag in install.sh will handle 'set -x' and pass it down
bash "$(dirname "$0")/install.sh" --verbose "$@"

echo "=========================================="
echo "📝 Debug session complete."
echo "📜 If there were errors, please check the output above or 'install.log'."
